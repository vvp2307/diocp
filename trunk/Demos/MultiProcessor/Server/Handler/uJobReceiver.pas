unit uJobReceiver;

interface

uses
  Classes, zmqapi, OTLObjectQueue, SyncObjs, SysUtils;

type
  TJobReceiver = class(TThread)
  private
    FEvent: TEvent;
    FEnabled: Boolean;
    FReceiver: TZMQSocket;
    procedure SetEnabled(const Value: Boolean);
  public
    constructor Create(AReceiver: TZMQSocket);
    procedure Execute; override;
    property Enabled: Boolean read FEnabled write SetEnabled;
    destructor Destroy; override;
    procedure notifyTerminate();
  end;

implementation

uses
  JSonStream, uJSonStreamTools, uWorkDispatcher, FileLogger, uIOCPCentre;

constructor TJobReceiver.Create(AReceiver: TZMQSocket);
begin
  inherited Create(True);
  FEnabled := false;
  FReceiver := AReceiver;
  FreeOnTerminate := False;
  FEvent := TEvent.Create(nil, false, false, '');
end;

destructor TJobReceiver.Destroy;
begin
  FEvent.Free;
  inherited Destroy;
end;

procedure TJobReceiver.Execute;
var
  lvStream:TMemoryStream;
  lvJsonStream:TJsonStream;
  lvContext: TIOCPClientContext;

begin
  while not Terminated do
  begin
    if FEnabled then
    begin
      lvStream := TMemoryStream.Create;
      lvJsonStream := TJsonStream.Create;
      try
        try
          lvStream.Clear;
          self.FReceiver.recv(lvStream);
          lvStream.Position := 0;

          TJSonStreamTools.unPackFromStream(lvJsonStream, lvStream);

          lvContext := TIOCPClientContext(lvJsonStream.Json.I['__contextID']);

          lvJsonStream.json.Delete('__contextID');

          lvContext.writeObject(lvJsonStream);
        except
          on E:Exception do
          begin
            TFileLogger.instance.logMessage('TJobReceiver' + E.Message, 'JOB_ERROR_');
          end;
        end;
      finally
        lvJsonStream.Free;
        lvStream.Free;
      end;
    end else
    begin
      FEvent.WaitFor(1000 * 10);
    end;
  end;


end;

procedure TJobReceiver.notifyTerminate;
begin
  Terminate;
  FEvent.SetEvent;
end;



procedure TJobReceiver.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if FEnabled then
    begin
      FEvent.SetEvent;
    end;
  end;
end;

end.
