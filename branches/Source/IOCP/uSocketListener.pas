unit uSocketListener;

interface

uses
  Classes, uIOCPCentre, SysUtils;

type
  TSocketListener = class(TThread)
  private
    FIOCPObject: TIOCPObject;                         
  public
    procedure Execute;override;
    procedure SetIOCPObject(const pvValue: TIOCPObject);
  end;

implementation

uses
  uIOCPFileLogger;

{ TSocketListener }

procedure TSocketListener.Execute;
begin
  try
    while not self.Terminated do
    begin
      try
        try
          FIOCPObject.acceptClient;
        except
          on E:Exception do
          begin
            TIOCPFileLogger.logErrMessage('TSocketListener.FIOCPObject.acceptClient, 出现异常:' + e.Message);
          end;
        end;
      except
      end;
    end;
  finally
    TIOCPFileLogger.logDebugMessage('TSocketListener已经退出!');
  end;
end;

procedure TSocketListener.SetIOCPObject(const pvValue: TIOCPObject);
begin
  FIOCPObject := pvValue;
end;

end.
