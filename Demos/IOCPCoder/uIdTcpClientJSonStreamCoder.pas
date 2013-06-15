unit uIdTcpClientJSonStreamCoder;

interface

uses
  Classes, JSonStream, superobject, uClientSocket,
  uNetworkTools, IdTCPClient;


type
  TIdTcpClientJSonStreamCoder = class(TObject)
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
    /// </summary>
    /// <param name="pvSocket"> (TClientSocket) </param>
    /// <param name="pvObject"> (TObject) </param>
    class procedure Encode(pvSocket: TIdTcpClient; pvObject: TObject);

  end;

implementation

class function TIdTcpClientJSonStreamCoder.Decode(pvSocket: TIdTcpClient;
    pvObject: TObject): Boolean;
var
  lvJSonLength, lvStreamLength:Integer;
  lvData:String;
  lvStream:TStream;
  lvJsonStream:TJsonStream;
  lvBytes:TBytes;

  l:Integer;
  lvBufBytes:array[0..1023] of byte;
begin
  pvSocket.IOHandler.ReadStream(@lvJSonLength, SizeOf(Integer));
  pvSocket.recvBuffer(@lvStreamLength, SizeOf(Integer));

  lvJSonLength := TNetworkTools.ntohl(lvJSonLength);
  lvStreamLength := TNetworkTools.ntohl(lvStreamLength);

  lvJsonStream := TJsonStream(pvObject);
  lvJsonStream.Clear(True);

  //读取json字符串
  if lvJSonLength > 0 then
  begin
    SetLength(lvBytes, lvJSonLength);
    ZeroMemory(@lvBytes[0], lvJSonLength);
    pvSocket.recvBuffer(@lvBytes[0], lvJSonLength);

    lvData := TNetworkTools.Utf8Bytes2AnsiString(lvBytes);

    lvJsonStream.Json := SO(lvData);
  end;


  //读取流数据 
  if lvStreamLength > 0 then
  begin
    lvStream := lvJsonStream.Stream;
    lvStream.Size := 0;
    while lvStream.Size < lvStreamLength do
    begin
      l := pvSocket.recvBuffer(@lvBufBytes[0], SizeOf(lvBufBytes));
      lvStream.WriteBuffer(lvBufBytes, l);
    end;
  end;
  Result := true;  
end;

class procedure TIdTcpClientJSonStreamCoder.Encode(pvSocket: TIdTcpClient;
    pvObject: TObject);
var
  lvJSonStream:TJsonStream;
  lvJSonLength:Integer;
  lvStreamLength:Integer;
  sData, lvTemp:String;
  lvStream:TStream;
  lvTempBuf:PAnsiChar;

  lvBytes, lvTempBytes:TBytes;
  
  l:Integer;
  lvBufBytes:array[0..1023] of byte;
begin
  if pvObject = nil then exit;
  lvJSonStream := TJsonStream(pvObject);

  sData := lvJSonStream.JSon.AsJSon(True);


  lvBytes := TNetworkTools.ansiString2Utf8Bytes(sData);

  lvJSonLength := Length(lvBytes);
  lvStream := lvJSonStream.Stream;

  lvJSonLength := TNetworkTools.htonl(lvJSonLength);
  pvSocket.sendBuffer(@lvJSonLength, SizeOf(lvJSonLength));


  if lvStream <> nil then
  begin
    lvStreamLength := lvStream.Size;
  end else
  begin
    lvStreamLength := 0;
  end;

  lvStreamLength := TNetworkTools.htonl(lvStreamLength);
  pvSocket.sendBuffer(@lvStreamLength, SizeOf(lvStreamLength));




  //json bytes
  pvSocket.sendBuffer(@lvBytes[0], Length(lvBytes));

  if lvStream.Size > 0 then
  begin
    lvStream.Position := 0;
    repeat
      l := lvStream.Read(lvBufBytes, SizeOf(lvBufBytes));
      pvSocket.sendBuffer(@lvBufBytes[0], l);
    until (l = 0);
  end;
end;

end.
