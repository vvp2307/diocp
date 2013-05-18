unit uIOCPWorker;

interface

uses
  Classes, uIOCPCentre, uIOCPProtocol;

type
  TIOCPWorker = class(TThread)
  private
    FIOCPObject: TIOCPObject;
  public
    procedure Execute;override;
    procedure SetIOCPObject(const pvValue: TIOCPObject);
  end;

implementation

uses
  SysUtils, uIOCPFileLogger;

{ TIOCPWorker }

procedure TIOCPWorker.Execute;
var
   lvRET:Integer;
begin
   //得到创建线程是传递过来的IOCP
   while(not self.Terminated) do
   begin
     try
       try
         lvRET := FIOCPObject.processIOQueued;
         if lvRET = IOCP_RESULT_EXIT then
         begin
           TIOCPFileLogger.logDebugMessage('TIOCPWorker.FIOCPObject.processIOQueued, 工作线程已经退出!');
           Exit;
         end;
       except
          on E:Exception do
          begin
            TIOCPFileLogger.logErrMessage('TIOCPWorker.FIOCPObject.processIOQueued, 出现异常:' + e.Message);
          end;
       end;
     except
     end;
   end;
end;

procedure TIOCPWorker.SetIOCPObject(const pvValue: TIOCPObject);
begin
  FIOCPObject := pvValue;
end;

end.
