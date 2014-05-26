unit uJobReceiver;

interface

uses
  Classes, zmqapi, OTLObjectQueue, SyncObjs, uJobWorker;

type
  TJobReceiver = class(TThread)
  private
    FEvent: TEvent;
    FEnabled: Boolean;
    FReceiver: TZMQSocket;
    FJobMananger: TJobWorkerManager;
    procedure SetEnabled(const Value: Boolean);
  public
    constructor Create(AReceiver: TZMQSocket; AJobMananger: TJobWorkerManager);
    procedure Execute; override;
    property Enabled: Boolean read FEnabled write SetEnabled;

    destructor Destroy; override;
    procedure notifyTerminate();


  end;

implementation

uses
  JSonStream, uJSonStreamTools, uWorkDispatcher;

constructor TJobReceiver.Create(AReceiver: TZMQSocket; AJobMananger:
    TJobWorkerManager);
begin
  inherited Create(True);
  FEnabled := false;
  FReceiver := AReceiver;
  FreeOnTerminate := False;
  FEvent := TEvent.Create();
  FJobMananger := AJobMananger;
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
  lvJobObj:TJobDataObject;
begin
  lvStream := TMemoryStream.Create;
  lvJsonStream := TJsonStream.Create;
  try
    while not Terminated do
    begin
      if FEnabled then
      begin
        try
          lvStream.Clear;
          self.FReceiver.recv(lvStream);
          lvJsonStream.Clear();
          lvStream.Position := 0;
          TJSonStreamTools.unPackFromStream(lvJsonStream, lvStream);

          lvJobObj := TJobDataObject.Create;
          lvJobObj.OperaType := 1;
          lvJobObj.DataObject := lvJsonStream;
          FJobMananger.Push(lvJobObj);
        except

        end;
      end else
      begin
        FEvent.WaitFor(1000 * 10);
      end;
    end;
  finally
    lvStream.Free;
    lvJsonStream.Free;
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
