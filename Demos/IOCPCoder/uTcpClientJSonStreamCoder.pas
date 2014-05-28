unit uTcpClientJSonStreamCoder;

interface

uses
  Classes, JSonStream, SysUtils, superobject,
  Sockets,
  Windows,
  uMyTypes,
  uNetworkTools, IdTCPClient, Math, uZipTools, uTcpClientTools;


const
  BUF_BLOCK_SIZE = 1024 * 10;
  
type
  TTcpClientJSonStreamCoder = class(TObject)
  private
  public
    /// <summary>
    ///   接收解码
    /// </summary>
    /// <returns> Boolean
    /// </returns>
    /// <param name="pvSocket"> (TClientSocket) </param>
    /// <param name="pvObject"> (TObject) </param>
    class function Decode(pvSocket: TTcpClient; pvObject: TObject): Boolean;

    /// <summary>
    ///   编码发送
    /// </summary>
    /// <param name="pvSocket"> (TClientSocket) </param>
    /// <param name="pvObject"> (TObject) </param>
    class function Encode(pvSocket: TTcpClient; pvObject: TObject): Integer;

  end;

implementation

uses
  uTesterTools, FileLogger;

class function TTcpClientJSonStreamCoder.Decode(pvSocket: TTcpClient; pvObject:
    TObject): Boolean;
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
  TTcpClientTools.recvBuffer(pvSocket, @lvJSonLength, SizeOf(Integer));
  TTcpClientTools.recvBuffer(pvSocket, @lvStreamLength, SizeOf(Integer));
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

        l := TTcpClientTools.recvBuffer(pvSocket, @lvBufBytes[0], Min(lvRemain, (SizeOf(lvBufBytes))));
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
      l := TTcpClientTools.recvBuffer(pvSocket, @lvBufBytes[0], Min(lvRemain, (SizeOf(lvBufBytes))));
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

class function TTcpClientJSonStreamCoder.Encode(pvSocket: TTcpClient; pvObject:
    TObject): Integer;
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
    l := TTcpClientTools.sendStream(pvSocket, lvSendStream);
    Result := l;
    TTesterTools.incSendbytesSize(l);
  finally
    lvSendStream.Free;
  end;
end;

end.
