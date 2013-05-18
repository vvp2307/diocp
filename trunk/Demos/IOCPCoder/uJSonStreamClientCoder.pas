unit uJSonStreamClientCoder;
////
///  字符串转换成UTF8进行发送,数字也需要转换进行发送
///
////

interface

uses
  Classes, JSonStream, superobject, uClientSocket,
  IdGlobal, uNetworkTools, uD10ClientSocket;

type
  TJSonStreamClientCoder = class(TSocketObjectCoder)
  public
    /// <summary>
    ///   编码发送
    /// </summary>
    /// <param name="pvSocket"> (TClientSocket) </param>
    /// <param name="pvObject"> (TObject) </param>
    procedure Encode(pvSocket: TClientSocket; pvObject: TObject); override;
    
    /// <summary>
    ///   接收解码
    /// </summary>
    /// <returns> Boolean
    /// </returns>
    /// <param name="pvSocket"> (TClientSocket) </param>
    /// <param name="pvObject"> (TObject) </param>
    function Decode(pvSocket: TClientSocket; pvObject: TObject): Boolean; override;
  end;

implementation

uses
  Windows;

function TJSonStreamClientCoder.Decode(pvSocket: TClientSocket; pvObject:
    TObject): Boolean;
var
  lvJSonLength, lvStreamLength:Integer;
  lvData:String;
  lvStream:TStream;
  lvJsonStream:TJsonStream;
  lvBytes:TIdBytes;

  l:Integer;
  lvBufBytes:array[0..1023] of byte;
begin
  pvSocket.recvBuffer(@lvJSonLength, SizeOf(Integer));
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

    lvData := BytesToString(lvBytes, TIdTextEncoding.UTF8, TIdTextEncoding.Default);

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

procedure TJSonStreamClientCoder.Encode(pvSocket: TClientSocket; pvObject:
    TObject);
var
  lvJSonStream:TJsonStream;
  lvJSonLength:Integer;
  lvStreamLength:Integer;
  sData:String;
  lvStream:TStream;
  lvTempBuf:PAnsiChar;

  lvBytes, lvTempBytes:TIdBytes;
  
  l:Integer;
  lvBufBytes:array[0..1023] of byte;
begin
  if pvObject = nil then exit;
  lvJSonStream := TJsonStream(pvObject);

  sData := lvJSonStream.JSon.AsJSon(True);


  lvBytes := ToBytes(sData, TIdTextEncoding.UTF8);

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
