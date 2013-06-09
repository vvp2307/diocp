unit uTesterTools;

interface

uses
  SyncObjs;

type
  TTesterTools = class(TObject)
  public
    class procedure incSendbytesSize(pvSize:Integer);
    class procedure incRecvBytesSize(pvSize:Integer);
    class procedure clearTesterInfo();
  end;


var
  __sendbytes_size :Int64;
  __recvbytes_size :Int64;

implementation

var
  __cs:TCriticalSection;

class procedure TTesterTools.clearTesterInfo;
begin
  __cs.Enter;
  try
    __sendbytes_size := 0;
    __recvbytes_size := 0;
  finally
    __cs.Leave;
  end;
  
end;

class procedure TTesterTools.incRecvBytesSize(pvSize: Integer);
begin
  __cs.Enter;
  try
    __recvbytes_size :=__recvbytes_size + pvSize;
  finally
    __cs.Leave;
  end;
end;

class procedure TTesterTools.incSendbytesSize(pvSize:Integer);
begin
  __cs.Enter;
  try
    __sendbytes_size :=__sendbytes_size + pvSize;
  finally
    __cs.Leave;
  end;
end;

initialization
  __sendbytes_size := 0;
  __recvbytes_size := 0;
  __cs := TCriticalSection.Create;

finalization
  __cs.Free;

end.
