unit uIdTcpClientJSonStreamCoder;

interface

uses
  Classes, JSonStream, SysUtils, superobject, 
  Windows,
  uMyTypes,
  IdGlobal,
  uNetworkTools, IdTCPClient, uZipTools, Math;


const
  BUF_BLOCK_SIZE = 1024;
  
type
  TIdTcpClientJSonStreamCoder = class(TObject)
  private
    class function recvBuffer(pvSocket: TIdTCPClient; buf: Pointer; len: Cardinal):
        Integer;
    class function sendBuffer(pvSocket:TIdTCPClient; buf: Pointer; len: Cardinal):
        Integer;
    class function sendStream(pvSocket:TIdTCPClient; pvStream:TStream):Integer;
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
    class function Encode(pvSocket: TIdTcpClient; pvObject: TObject): Integer;

  end;

implementation

uses
  uTesterTools, FileLogger;

class function TIdTcpClientJSonStreamCoder.Decode(pvSocket: TIdTcpClient;
    pvObject: TObject): Boolean;
var
  lvJSonLength, lvStreamLength:Integer;
  lvData, lvTemp:String;
  lvStream:TStream;

  lvJsonStream:TJsonStream;
  lvBytes:TBytes;

  l, lvRemain:Integer;
  lvBufBytes:array[0..1023] of byte;
begin
  Result := false;
  lvJSonLength := 0;
  lvStreamLength := 0;
  //TFileLogger.instance.logDebugMessage('1100');
  recvBuffer(pvSocket, @lvJSonLength, SizeOf(Integer));
  recvBuffer(pvSocket, @lvStreamLength, SizeOf(Integer));
  //TFileLogger.instance.logDebugMessage('1101');

  if (lvJSonLength = 0) and (lvStreamLength = 0) then exit;
  
  

  lvJSonLength := TNetworkTools.ntohl(lvJSonLength);
  lvStreamLength := TNetworkTools.ntohl(lvStreamLength);


  //TFileLogger.instance.logDebugMessage('1102, ' + InttoStr(lvJSonLength) + ',' + intToStr(lvStreamLength));

  lvJsonStream := TJsonStream(pvObject);
  lvJsonStream.Clear(True);
  //TFileLogger.instance.logDebugMessage('1103');
  //读取json字符串
  if lvJSonLength > 0 then
  begin
    //TFileLogger.instance.logDebugMessage('1104');

    lvStream:=TMemoryStream.Create();
    try
      lvRemain := lvJSonLength;
      while lvStream.Size < lvJSonLength do
      begin

        l := recvBuffer(pvSocket, @lvBufBytes[0], Min(lvRemain, (SizeOf(lvBufBytes))));
        TTesterTools.incRecvBytesSize(l);
        lvStream.WriteBuffer(lvBufBytes[0], l);
        lvRemain := lvRemain - l;
      end;


      SetLength(lvBytes, lvStream.Size);
      lvStream.Position := 0;
      lvStream.ReadBuffer(lvBytes[0], lvStream.Size);
      lvData := TNetworkTools.Utf8Bytes2AnsiString(lvBytes);

      lvJsonStream.Json := SO(lvData);
      if (lvJsonStream.Json = nil) or (lvJsonStream.Json.DataType <> stObject) then
      begin
        TFileLogger.instance.logMessage('接收JSon' + sLineBreak + lvData);
        TMemoryStream(lvStream).SaveToFile(ExtractFilePath(ParamStr(0)) + 'DEBUG_' + FormatDateTime('YYYYMMDDHHNNSS', Now()) + '.dat');
        raise Exception.Create('解码JSon对象失败,接收到得JSon字符串为!');
      end;
            
    finally
      lvStream.Free;
    end;


  end;

  //读取流数据 
  if lvStreamLength > 0 then
  begin
    lvStream := lvJsonStream.Stream;
    lvStream.Size := 0;
    lvRemain := lvStreamLength;
    while lvStream.Size < lvStreamLength do
    begin
      l := recvBuffer(pvSocket, @lvBufBytes[0], Min(lvRemain, (SizeOf(lvBufBytes))));
      TTesterTools.incRecvBytesSize(l);
      lvStream.WriteBuffer(lvBufBytes[0], l);
      lvRemain := lvRemain - l;
    end;

    //解压流
    if (lvJsonStream.Json <> nil) and (lvJsonStream.Json.B['config.stream.zip']) then
    begin
      //解压
      TZipTools.unCompressStreamEX(lvJsonStream.Stream);
    end;
  end;
  Result := true;
end;

class function TIdTcpClientJSonStreamCoder.Encode(pvSocket: TIdTcpClient;
    pvObject: TObject): Integer;
var
  lvJSonStream:TJsonStream;
  lvJSonLength:Integer;
  lvStreamLength:Integer;
  sData, lvTemp:String;
  lvStream, lvSendStream:TStream;
  lvTempBuf:PAnsiChar;

  lvBytes, lvTempBytes:TBytes;
  
  l:Integer;
  lvBufBytes:array[0..1023] of byte;
begin
  if pvObject = nil then exit;
  lvJSonStream := TJsonStream(pvObject);
  
  //是否压缩流
  if (lvJSonStream.Stream <> nil) then
  begin
    if lvJSonStream.Json.O['config.stream.zip'] <> nil then
    begin
      if lvJSonStream.Json.B['config.stream.zip'] then
      begin
        //压缩流
        TZipTools.compressStreamEx(lvJSonStream.Stream);
      end;
    end else if lvJSonStream.Stream.Size > 0 then
    begin
      //压缩流
      TZipTools.compressStreamEx(lvJSonStream.Stream);
      lvJSonStream.Json.B['config.stream.zip'] := true;
    end;
  end;

  sData := lvJSonStream.JSon.AsJSon(True, false);
  //转换成Utf8格式的Bytes
  lvBytes := TNetworkTools.ansiString2Utf8Bytes(sData);
  lvJSonLength := Length(lvBytes);

  lvStream := lvJSonStream.Stream;
  if lvStream <> nil then
  begin
    lvStreamLength := lvStream.Size;
  end else
  begin
    lvStreamLength := 0;
  end;

  lvJSonLength := TNetworkTools.htonl(lvJSonLength);
  lvStreamLength := TNetworkTools.htonl(lvStreamLength);

//  pvSocket.sendBuffer(@lvJSonLength, SizeOf(lvJSonLength));
//  pvSocket.sendBuffer(@lvStreamLength, SizeOf(lvStreamLength));
//  //json bytes
//  pvSocket.sendBuffer(@lvBytes[0], Length(lvBytes));


  lvSendStream := TMemoryStream.Create;
  try
    lvSendStream.Write(lvJSonLength, SizeOf(lvJSonLength));
    lvSendStream.Write(lvStreamLength, SizeOf(lvStreamLength));
    lvSendStream.Write(lvBytes[0], Length(lvBytes));
    if (lvStream <> nil) and (lvStream.Size > 0) then
    begin
      lvStream.Position := 0;
      lvSendStream.CopyFrom(lvStream, lvStream.Size);
    end;

    
    //头信息和JSon数据
    l := sendStream(pvSocket, lvSendStream);
    Result := l;
    TTesterTools.incSendbytesSize(l);
  finally
    lvSendStream.Free;
  end;
end;

class function TIdTcpClientJSonStreamCoder.recvBuffer(pvSocket: TIdTCPClient;
    buf: Pointer; len: Cardinal): Integer;
var
  lvBuf: TIdBytes;
begin
  pvSocket.Socket.ReadBytes(lvBuf, len);
  Result := IndyLength(lvBuf);
  CopyMemory(buf, @lvBuf[0], Result);
  SetLength(lvBuf, 0);
end;

class function TIdTcpClientJSonStreamCoder.sendBuffer(pvSocket: TIdTCPClient;
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

class function TIdTcpClientJSonStreamCoder.sendStream(pvSocket: TIdTCPClient;
  pvStream: TStream): Integer;
var
  lvBufBytes:array[0..BUF_BLOCK_SIZE-1] of byte;
  l, j, lvTotal:Integer;
begin
  Result := 0;
  if pvStream = nil then Exit;
  if pvStream.Size = 0 then Exit;

  lvTotal :=0;
  
  pvStream.Position := 0;
  repeat
    FillMemory(@lvBufBytes[0], SizeOf(lvBufBytes), 0);
    l := pvStream.Read(lvBufBytes[0], SizeOf(lvBufBytes));
    if (l > 0) and pvSocket.Connected then
    begin
      j:=sendBuffer(pvSocket, @lvBufBytes[0], l);
      if j <> l then
      begin
        raise Exception.CreateFmt('发送Buffer错误指定发送%d,实际发送:%d', [j, l]);
      end else
      begin
        lvTotal := lvTotal + j;
      end;
    end else Break;
  until (l = 0);
  Result := lvTotal;
end;

end.
