unit uMyObjectIdTcpClientCoder;

interface

uses
  Classes, uMyObject,uOleVariantConverter,
  Windows,
  IdGlobal,
  IdTCPClient, uIOCPProtocol, Math, SysUtils;


const
  BUF_BLOCK_SIZE = 1024;

type
  TMyObjectCoderTools = class(TObject)
  private
    class function recvBuffer(pvSocket: TIdTCPClient; buf: Pointer; len: Cardinal):
        Integer;
    class function sendBuffer(pvSocket:TIdTCPClient; buf: Pointer; len: Cardinal):
        Integer;

  public
    /// <summary>
    ///   接收解码
    /// </summary>
    /// <returns> Boolean
    /// </returns>
    /// <param name="pvSocket"> (TClientSocket) </param>
    /// <param name="pvObject"> (TObject) </param>
    class function Decode(pvSocket: TIdTcpClient; pvObject: TObject): Boolean;

    /// <summary>
    ///   编码发送
    ///    result := 发送长度
    /// </summary>
    /// <param name="pvSocket"> (TClientSocket) </param>
    /// <param name="pvObject"> (TObject) </param>
    class function Encode(pvSocket: TIdTcpClient; pvObject: TObject): Integer;
  end;

implementation

{ TMyObjectCoderTools }

class function TMyObjectCoderTools.Decode(pvSocket: TIdTcpClient;
  pvObject: TObject): Boolean;
var
  lvStringLength, lvStreamLength:Integer;
  lvData, lvTemp:AnsiString;
  lvStream:TStream;

  l, lvRemain:Integer;
  lvBufData:PAnsiChar;
begin
  Result := false;
  lvStringLength := 0;
  lvStreamLength := 0;
  recvBuffer(pvSocket, @lvStringLength, SizeOf(Integer));
  recvBuffer(pvSocket, @lvStreamLength, SizeOf(Integer));
  if (lvStringLength = 0) and (lvStreamLength = 0) then exit;

 //读取json字符串
  if lvStringLength > 0 then
  begin
    SetLength(lvData, lvStringLength);
    l := recvBuffer(pvSocket, PAnsiChar(lvData), lvStringLength);
    TMyObject(pvObject).DataString := lvData;
  end;

  //读取Ole值
  if lvStreamLength > 0 then
  begin
    GetMem(lvBufData, lvStreamLength);
    try
      recvBuffer(pvSocket, lvBufData, lvStreamLength);
      lvStream := TMemoryStream.Create;
      try
        lvStream.WriteBuffer(lvBufData^, lvStreamLength);
        lvStream.Position := 0;

        TMyObject(pvObject).Ole := ReadOleVariant(lvStream);
      finally
        lvStream.Free;
      end;
    finally
      FreeMem(lvBufData, lvStreamLength);
    end;
  end;

  Result := true;
end;

class function TMyObjectCoderTools.Encode(pvSocket: TIdTcpClient;
  pvObject: TObject): Integer;
var
  lvMyObj:TMyObject;
  lvOleStream:TMemoryStream;
  lvOleLen, lvStringLen:Integer;
begin
  lvMyObj := TMyObject(pvObject);

  lvOleStream := TMemoryStream.Create;
  try
    WriteOleVariant(lvMyObj.Ole, lvOleStream);
    lvOleLen := lvOleStream.Size;
    lvOleStream.Position := 0;

    //字符串长度+ole长度 + 字符串数据 + Ole数据
    lvStringLen := Length(AnsiString(lvMyObj.DataString));

    Result := 0;
    Result := Result + sendBuffer(pvSocket,@lvStringLen,sizeOf(Integer));
    Result := Result + sendBuffer(pvSocket,@lvOleLen,sizeOf(Integer));
    Result := Result + sendBuffer(pvSocket,PAnsiChar(AnsiString(lvMyObj.DataString)), lvStringLen);
    Result := Result + sendBuffer(pvSocket,lvOleStream.Memory, lvOleLen);
    //result 发送长度
  finally
    lvOleStream.Free;
  end;
end;

class function TMyObjectCoderTools.recvBuffer(pvSocket: TIdTCPClient;
  buf: Pointer; len: Cardinal): Integer;
var
  lvBuf: TIdBytes;
begin
  pvSocket.Socket.ReadBytes(lvBuf, len);
  Result := IndyLength(lvBuf);
  CopyMemory(buf, @lvBuf[0], Result);
  SetLength(lvBuf, 0);
end;

class function TMyObjectCoderTools.sendBuffer(pvSocket: TIdTCPClient;
  buf: Pointer; len: Cardinal): Integer;
var
  lvBytes:TIdBytes;
begin
  SetLength(lvBytes, len);
  CopyMemory(@lvBytes[0], buf, len);
  pvSocket.Socket.Write(lvBytes, len);
  SetLength(lvBytes, 0);
  Result := len;

end;

end.
