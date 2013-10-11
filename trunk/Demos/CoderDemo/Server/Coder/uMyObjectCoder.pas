unit uMyObjectCoder;

interface

uses
  uIOCPCentre, uBuffer, uMyObject, Classes, Variants, uOleVariantConverter,
  uIOCPFileLogger, uIOCPProtocol, Windows;

type
  TMyObjectDecoder = class(TIOCPDecoder)
  public
    /// <summary>
    ///   解码收到的数据,如果有接收到数据,调用该方法,进行解码
    /// </summary>
    /// <returns>
    ///   返回解码好的对象
    /// </returns>
    /// <param name="inBuf"> 接收到的流数据 </param>
    function Decode(const inBuf: TBufferLink): TObject; override;
  end;

  TMyObjectEncoder = class(TIOCPEncoder)
  public
    /// <summary>
    ///   编码要发送的对象
    /// </summary>
    /// <param name="pvDataObject"> 要进行编码的对象 </param>
    /// <param name="ouBuf"> 编码好的数据
    ///   字符串长度+ole长度 + 字符串数据 + Ole数据
    /// </param>
    procedure Encode(pvDataObject:TObject; const ouBuf: TBufferLink); override;
  end;

procedure VariantToStream(const Data: OleVariant; Stream: TStream);
function StreamToVariant(Stream: TStream): OleVariant;

implementation

procedure VariantToStream(const Data: OleVariant; Stream: TStream);
var p: Pointer;
begin
  p := VarArrayLock(Data);
  try
    Stream.Write(p^, VarArrayHighBound(Data, 1) + 1); //assuming low bound = 0
  finally
    VarArrayUnlock(Data);
  end;
end;

function StreamToVariant(Stream: TStream): OleVariant;
var p: Pointer;
begin
  Result := VarArrayCreate([0, Stream.Size - 1], varByte);
  p := VarArrayLock(Result);
  try
    Stream.Position := 0; //start from beginning of stream
    Stream.ReadBuffer(p^, Stream.Size);
  finally
    VarArrayUnlock(Result);
  end;
end;


function TMyObjectDecoder.Decode(const inBuf: TBufferLink): TObject;
var
  lvStringLen, lvStreamLength:Integer;
  lvData:AnsiString;
  lvBuffer:array of Char;
  lvBufData:PAnsiChar;
  lvStream:TMemoryStream;
  lvValidCount:Integer;
  lvBytes:TIOCPBytes;
begin
  Result := nil;

  //如果缓存中的数据长度不够包头长度，解码失败<字符串长度,Ole流长度>
  lvValidCount := inBuf.validCount;
  if (lvValidCount < SizeOf(Integer) + SizeOf(Integer)) then
  begin
    Exit;
  end;

  //记录读取位置
  inBuf.markReaderIndex;
  inBuf.readBuffer(@lvStringLen, SizeOf(Integer));
  inBuf.readBuffer(@lvStreamLength, SizeOf(Integer));


  //如果缓存中的数据不够json的长度和流长度<说明数据还没有收取完毕>解码失败
  lvValidCount := inBuf.validCount;
  if lvValidCount < (lvStringLen + lvStreamLength) then
  begin
    //返回buf的读取位置
    inBuf.restoreReaderIndex;
    exit;
  end else if (lvStringLen + lvStreamLength) = 0 then
  begin
    //两个都为0<两个0>客户端可以用来作为自动重连使用
    TIOCPFileLogger.logDebugMessage('接收到一次[00]数据!');
    Exit;
  end;



  //解码成功
  Result := TMyObject.Create;

  //读取json字符串
  if lvStringLen > 0 then
  begin
    SetLength(lvData, lvStringLen);
    inBuf.readBuffer(PAnsiChar(lvData), lvStringLen);
    TMyObject(Result).DataString := lvData;
  end;

  //读取Ole值
  if lvStreamLength > 0 then
  begin
    GetMem(lvBufData, lvStreamLength);
    try
      inBuf.readBuffer(lvBufData, lvStreamLength);
      lvStream := TMemoryStream.Create;
      try
        lvStream.WriteBuffer(lvBufData^, lvStreamLength);
        lvStream.Position := 0;

        TMyObject(Result).Ole := ReadOleVariant(lvStream);
      finally
        lvStream.Free;
      end;
    finally
      FreeMem(lvBufData, lvStreamLength);
    end;
  end;
end;

{ TMyObjectEncoder }

procedure TMyObjectEncoder.Encode(pvDataObject: TObject;
  const ouBuf: TBufferLink);
var
  lvMyObj:TMyObject;
  lvOleStream:TMemoryStream;
  lvOleLen, lvStringLen:Integer;
begin
  lvMyObj := TMyObject(pvDataObject);

  lvOleStream := TMemoryStream.Create;
  try
    WriteOleVariant(lvMyObj.Ole, lvOleStream);
    lvOleLen := lvOleStream.Size;
    lvOleStream.Position := 0;

    //字符串长度+ole长度 + 字符串数据 + Ole数据
    lvStringLen := Length(AnsiString(lvMyObj.DataString));

    ouBuf.AddBuffer(@lvStringLen,sizeOf(Integer));

    ouBuf.AddBuffer(@lvOleLen,sizeOf(Integer));

    ouBuf.AddBuffer(PAnsiChar(AnsiString(lvMyObj.DataString)), lvStringLen);

    ouBuf.AddBuffer(lvOleStream.Memory, lvOleLen);
  finally
    lvOleStream.Free;
  end;
end;

end.
