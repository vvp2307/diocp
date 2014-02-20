unit uICSClientJSonStreamCoder;


interface

uses
  Classes, JSonStream, superobject, 
  Windows,
  OverbyteIcsWSocket,
  uNetworkTools, uZipTools, Math, SysUtils, uBuffer, uMyTypes;


const
  BUF_BLOCK_SIZE = 1024;
  
type
  TICSClientJSonStreamCoder = class(TObject)
  private
    class function recvBuffer(pvSocket:TWSocket; buf: Pointer; len: Cardinal):
        Integer;
    class function sendBuffer(pvSocket:TWSocket; buf: Pointer; len: Cardinal):
        Integer;
    class function sendStream(pvSocket:TWSocket; pvStream:TStream):Integer;
  public
    /// <summary>
    ///   接收解码
    /// </summary>
    /// <returns> Boolean
    /// </returns>
    /// <param name="pvSocket"> (TClientSocket) </param>
    /// <param name="pvObject"> (TObject) </param>
    class function Decode(pvSocket: TWSocket; pvObject: TObject): Integer;


    /// <summary>
    ///   解码成对象
    /// </summary>
    /// <returns> TObject
    /// </returns>
    /// <param name="inBuf"> (TBufferLink) </param>
    class function Decode4Buffer(const inBuf: TBufferLink): TObject;

    /// <summary>
    ///   编码发送
    /// </summary>
    /// <param name="pvSocket"> (TClientSocket) </param>
    /// <param name="pvObject"> (TObject) </param>
    class function Encode(pvSocket: TWSocket; pvObject: TObject): Integer;

  end;

implementation

uses
  FileLogger;

class function TICSClientJSonStreamCoder.Decode(pvSocket: TWSocket; pvObject:
    TObject): Integer;
var
  lvJSonLength, lvStreamLength:Integer;
  lvData, lvTemp:String;
  lvStream:TStream;

  lvJsonStream:TJsonStream;
  lvBytes:TBytes;

  l, lvRemain:Integer;
  lvBufBytes:array[0..1023] of byte;
begin
  Result := 0;
  lvJSonLength := 0;
  lvStreamLength := 0;
  //TFileLogger.instance.logDebugMessage('1100');
  l := recvBuffer(pvSocket, @lvJSonLength, SizeOf(Integer));
  Result := Result + l;

  l := recvBuffer(pvSocket, @lvStreamLength, SizeOf(Integer));

  Result := Result + l;

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
        Result := Result + l;
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
      Result := Result + l;
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
end;

class function TICSClientJSonStreamCoder.Decode4Buffer(const inBuf:
    TBufferLink): TObject;
var
  lvJSonLength, lvStreamLength:Integer;
  lvData:String;
  lvBuffer:array of Char;
  lvBufData:PAnsiChar;
  lvStream:TMemoryStream;
  lvJsonStream:TJsonStream;
  lvBytes:TBytes;
  lvValidCount:Integer;
begin
  Result := nil;

  //如果缓存中的数据长度不够包头长度，解码失败<json字符串长度,流长度>
  lvValidCount := inBuf.validCount;
  if (lvValidCount < SizeOf(Integer) + SizeOf(Integer)) then
  begin
    Exit;
  end;

  //记录读取位置
  inBuf.markReaderIndex;
  inBuf.readBuffer(@lvJSonLength, SizeOf(Integer));
  inBuf.readBuffer(@lvStreamLength, SizeOf(Integer));

  lvJSonLength := TNetworkTools.ntohl(lvJSonLength);
  lvStreamLength := TNetworkTools.ntohl(lvStreamLength);

  //如果缓存中的数据不够json的长度和流长度<说明数据还没有收取完毕>解码失败
  lvValidCount := inBuf.validCount;
  if lvValidCount < (lvJSonLength + lvStreamLength) then
  begin
    //返回buf的读取位置
    inBuf.restoreReaderIndex;
    exit;
  end else if (lvJSonLength + lvStreamLength) = 0 then
  begin
    //两个都为0<两个0>客户端可以用来作为自动重连使用
    Exit;
  end;



  //解码成功
  lvJsonStream := TJsonStream.Create;
  Result := lvJsonStream;

  //读取json字符串
  if lvJSonLength > 0 then
  begin
    SetLength(lvBytes, lvJSonLength);
    ZeroMemory(@lvBytes[0], lvJSonLength);
    inBuf.readBuffer(@lvBytes[0], lvJSonLength);

    lvData := TNetworkTools.Utf8Bytes2AnsiString(lvBytes);

    lvJsonStream.Json := SO(lvData);
  end else
  begin
    TFileLogger.instance.logMessage('接收到一次JSon为空的一次数据请求!', 'IOCP_ALERT_');
  end;


  //读取流数据 
  if lvStreamLength > 0 then
  begin
    GetMem(lvBufData, lvStreamLength);
    try
      inBuf.readBuffer(lvBufData, lvStreamLength);
      lvJsonStream.Stream.Size := 0;
      lvJsonStream.Stream.WriteBuffer(lvBufData^, lvStreamLength);

      //解压流
      if lvJsonStream.Json.B['config.stream.zip'] then
      begin
        //解压
        TZipTools.unCompressStreamEX(lvJsonStream.Stream);
      end;
    finally
      FreeMem(lvBufData, lvStreamLength);
    end;
  end;
end;

class function TICSClientJSonStreamCoder.Encode(pvSocket: TWSocket; pvObject:
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
    Result := sendStream(pvSocket, lvSendStream);
  finally
    lvSendStream.Free;
  end;
end;

class function TICSClientJSonStreamCoder.recvBuffer(pvSocket: TWSocket;
    buf: Pointer; len: Cardinal): Integer;
begin
  Result := pvSocket.Receive(buf, len);
end;

class function TICSClientJSonStreamCoder.sendBuffer(pvSocket: TWSocket;
  buf: Pointer; len: Cardinal): Integer;
begin
  Result := pvSocket.Send(buf, len);
end;

class function TICSClientJSonStreamCoder.sendStream(pvSocket: TWSocket;
  pvStream: TStream): Integer;
var
  lvBufBytes:array[0..BUF_BLOCK_SIZE-1] of byte;
  l, j, lvTotal:Integer;
begin
  Result := -1;
  if pvStream = nil then Exit;
  if pvStream.Size = 0 then Exit;

  lvTotal :=0;

  pvStream.Position := 0;
  repeat
    l := pvStream.Read(lvBufBytes[0], SizeOf(lvBufBytes));
    if (l > 0) and (pvSocket.State <> wsClosed) then
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
