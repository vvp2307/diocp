unit uMyObjectCoder;

interface

uses
  uIOCPCentre, uBuffer, uMyObject, Classes, Variants;

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
    /// <param name="ouBuf"> 编码好的数据 </param>
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
begin

end;

{ TMyObjectEncoder }

procedure TMyObjectEncoder.Encode(pvDataObject: TObject;
  const ouBuf: TBufferLink);
var
  lvMyObj:TMyObject;
  lvOleLen, lvStringLen:Integer;

begin
  lvMyObj := TMyObject(pvDataObject);
  lvStringLen := Length(lvMyObj.DataString);
  ouBuf.AddBuffer(@lvStringLen,sizeOf(Integer));



end;

end.
