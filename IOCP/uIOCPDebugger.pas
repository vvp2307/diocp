unit uIOCPDebugger;


interface

uses
  SyncObjs, Windows;

type
  TIOCPDebugger = class(TObject)
  public
    class procedure incSendbytesSize(pvSize:Integer);

    class procedure incWSASendbytesSize(pvSize:Integer);

    class procedure incRecvBytesSize(pvSize:Integer);

    class procedure incSendBlockCount();
    class procedure incRecvBlockCount();

    class procedure incSendObjectCount();
    class procedure incRecvObjectCount();

    class procedure incClientCount();
    class procedure decClientCount();

    class procedure resetDebugINfo;
  public
    class function WSASendBytes:Int64;
    class function sendBytes:Int64;
    class function recvBytes:Int64;
    class function clientCount:Integer;
    class function sendBlockCount:Integer;
    class function recvBlockCount:Integer;

    class function recvObjectCount:Integer;
    class function sendObjectCount:Integer;
  end;


implementation

var
  __cs:TCriticalSection;

  //在线数量
  __clientCount: Integer;
  
  //发送完成
  __sendbytes_size :Int64;

  //投递
  __WSASendBytes : Int64;

  __recvbytes_size :Int64;

  __sendBlockCount:Integer;

  __recvBlockCount:Integer;

  __recvObjectCount:Integer;

  __sendObjectCount:Integer;


class function TIOCPDebugger.recvBlockCount: Integer;
begin
  Result := __recvBlockCount; 
end;

class function TIOCPDebugger.recvBytes: Int64;
begin
  Result := __recvbytes_size;
end;

class function TIOCPDebugger.recvObjectCount: Integer;
begin
  Result := __recvObjectCount;
end;

class procedure TIOCPDebugger.resetDebugINfo;
begin
  __cs.Enter;
  try
    __sendbytes_size := 0;
    __recvbytes_size := 0;
    __sendBlockCount := 0;
    __recvBlockCount := 0;
    __WSASendBytes := 0;
    __recvObjectCount := 0;
    __sendObjectCount := 0;
  finally
    __cs.Leave;
  end;
  
end;

class function TIOCPDebugger.sendBlockCount: Integer;
begin
  Result := __sendBlockCount;
end;

class function TIOCPDebugger.sendBytes: Int64;
begin
  Result := __sendbytes_size;
end;

class function TIOCPDebugger.sendObjectCount: Integer;
begin
  Result := __sendObjectCount;
end;

class function TIOCPDebugger.WSASendBytes: Int64;
begin
  Result := __WSASendBytes;
end;

class function TIOCPDebugger.clientCount: Integer;
begin
  Result := __clientCount;
end;

class procedure TIOCPDebugger.decClientCount;
begin
  InterlockedDecrement(__clientCount);
end;

class procedure TIOCPDebugger.incClientCount;
begin
  InterlockedIncrement(__clientCount);
end;

class procedure TIOCPDebugger.incRecvBlockCount;
begin
  InterlockedIncrement(__recvBlockCount);  
end;

class procedure TIOCPDebugger.incRecvBytesSize(pvSize: Integer);
begin
  __cs.Enter;
  try
    //归零
    if MaxInt - __recvbytes_size < pvSize then
    begin
      __recvbytes_size := 0;
    end;
    
    __recvbytes_size :=__recvbytes_size + pvSize;
  finally
    __cs.Leave;
  end;
end;

class procedure TIOCPDebugger.incRecvObjectCount;
begin
  InterlockedIncrement(__recvObjectCount);
end;

class procedure TIOCPDebugger.incSendBlockCount;
begin
  InterlockedIncrement(__sendBlockCount);
end;

class procedure TIOCPDebugger.incSendbytesSize(pvSize:Integer);
begin
  __cs.Enter;
  try
    //归零
    if MaxInt - __sendbytes_size < pvSize then
    begin
      __sendbytes_size := 0;
    end;
    
    __sendbytes_size :=__sendbytes_size + pvSize;
  finally
    __cs.Leave;
  end;
end;

class procedure TIOCPDebugger.incSendObjectCount;
begin
  InterlockedIncrement(__sendObjectCount);
end;

class procedure TIOCPDebugger.incWSASendbytesSize(pvSize: Integer);
begin
  __cs.Enter;
  try
    //归零
    if MaxInt - __WSASendBytes < pvSize then
    begin
      __WSASendBytes := 0;
    end;

    __WSASendBytes :=__WSASendBytes + pvSize;
  finally
    __cs.Leave;
  end;
end;

initialization
  __sendbytes_size := 0;
  __recvbytes_size := 0;
  __clientCount := 0;
  __cs := TCriticalSection.Create;

finalization
  __cs.Free;

end.
