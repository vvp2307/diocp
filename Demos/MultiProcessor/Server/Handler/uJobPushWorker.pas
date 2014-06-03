unit uJobPushWorker;

interface


uses
  Classes,  BaseQueue, zmqapi, SyncObjs, SysUtils;

type
  TJobPushWorker = class(TThread)
  private
    FEvent: TEvent;
    FEnabled: Boolean;
    FIsBusy: Boolean;
    FPusher: TZMQSocket;
    FJobQueue: TBaseQueue;
    procedure SetEnabled(const Value: Boolean);
  public
    constructor Create(aPusher: TZMQSocket; AJobQueue: TBaseQueue);
    procedure Execute; override;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property IsBusy: Boolean read FIsBusy write FIsBusy;
    destructor Destroy; override;
    procedure notifyTerminate();

    procedure notifyWork();

  end;

implementation

uses
  JSonStream, uJSonStreamTools, uWorkDispatcher, FileLogger;

constructor TJobPushWorker.Create(aPusher: TZMQSocket; AJobQueue: TBaseQueue);
begin
  inherited Create(True);
  FEnabled := false;
  FPusher := aPusher;
  FreeOnTerminate := False;
  FEvent := TEvent.Create(nil, false, false, '');
  FJobQueue := AJobQueue;
end;

destructor TJobPushWorker.Destroy;
begin
  FEvent.Free;
  inherited Destroy;
end;

procedure TJobPushWorker.Execute;
var
  lvStream:TMemoryStream;
  lvJsonStream:TJsonStream;
  lvJobObj:TJobDataObject;
begin
  lvStream := TMemoryStream.Create;
  try
    while not Terminated do
    begin
      FEvent.WaitFor(1000 * 30);
      FIsBusy:=true;
      try
        repeat
          if not FEnabled then Break;
          lvJobObj := TJobDataObject(FJobQueue.Pop);
          if lvJobObj = nil then break;
          try
            TJsonStream(lvJobObj.DataObject).Json.I['__contextID'] := LongInt(lvJobObj.Context);
            lvStream.Position := 0;
            TJSonStreamTools.pack2Stream(TJsonStream(lvJobObj.DataObject), lvStream);
            lvStream.Position := 0;
            FPusher.send(lvStream, lvStream.Size);
          finally
            lvJobObj.DataObject.Free;
            lvJobObj.Free;
          end;

        until (lvJobObj = nil) or (self.terminated);
      finally
        FIsBusy := false;
      end;

    end;
  finally
    lvStream.Free;
  end;

end;

procedure TJobPushWorker.notifyTerminate;
begin
  Terminate;
  FEvent.SetEvent;
end;



procedure TJobPushWorker.notifyWork;
begin
  if not FIsBusy then
  begin
    FEvent.SetEvent;
  end;
end;

procedure TJobPushWorker.SetEnabled(const Value: Boolean);
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
