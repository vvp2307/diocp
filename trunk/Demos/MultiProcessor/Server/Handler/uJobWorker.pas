unit uJobWorker;
/// <summary>
///   下面大部分代码来自QDAC的 QWorker
/// </summary>

interface

uses
  Classes, SyncObjs, OTLObjectQueue, windows, SysUtils;

type
  TJobExecuteProc = procedure(pvObj:TObject) of object;

  TJobWorkerManager = class;

  TJobWorker = class(TThread)
  private
    FKeepAlive:Boolean;
    FIsBusy:Boolean;
  protected
    FOwner: TJobWorkerManager;
    FEvent: TEvent;
    FTimeout: Integer;
    procedure Execute; override;
  public
    constructor Create(AOwner: TJobWorkerManager); overload;
    destructor Destroy; override;
  end;


  TJobWorkerManager = class(TObject)
  private
    FJobQueue: TOtlObjectQueue;
    FCpuCounter:Integer;
    FLocker: TCriticalSection;
    FOnJobExecute: TJobExecuteProc;
    FTerminated: Boolean;
    FWorkerCount: Integer;
    FWorkers: array of TJobWorker;
    class function getCPUNumbers: Integer;
  protected
    FmaxWorkerCount: Integer;
    procedure notifyWorker;
    procedure setMaxWorkerCount(const Value: Integer);
    procedure removeWorker(AWorker: TObject);
  public
    constructor Create(AJobQueue: TOtlObjectQueue);
    destructor Destroy; override;
    procedure setThreadUseCPU(AHandle: THandle; ACpuNo: Integer);
    property maxWorkerCount: Integer read FmaxWorkerCount write setMaxWorkerCount;
    property Terminated: Boolean read FTerminated write FTerminated;
    property WorkerCount: Integer read FWorkerCount;

    property OnJobExecute: TJobExecuteProc read FOnJobExecute write FOnJobExecute;

  end;

implementation

{ TJobWorker }


constructor TJobWorker.Create(AOwner: TJobWorkerManager);
begin
  inherited Create(True);
  FKeepAlive := false;
  FTimeout := 15000;
  FreeOnTerminate := True;
  FEvent := TEvent.Create(nil, False, False, '');
  FOwner := AOwner;
end;

destructor TJobWorker.Destroy;
begin
  FEvent.Free;
  inherited;
end;

procedure TJobWorker.Execute;
var
  wr: TWaitResult;
  lvObj:TObject;
begin
  try
    Assert(Assigned(FOwner.FOnJobExecute), 'JobExecute none');


    while not(Terminated) do
    begin
      wr := FEvent.WaitFor(FTimeout);

      if (wr = wrSignaled)  then
      begin
        FIsBusy := True;
        try
          repeat
            if Terminated then Break;
            lvObj := FOwner.FJobQueue.Pop;
            if lvObj <> nil then
            try
              FOwner.FOnJobExecute(lvObj);
            finally
              lvObj.Free;
            end;
          until (lvObj = nil) or Terminated;
        finally
          FIsBusy := false;
        end;
      end
      else if not FKeepAlive then
      begin    //超时，退出
        self.Terminate;
        Break;
      end;
    end;
  finally
    FOwner.removeWorker(Self);
  end;
end;

constructor TJobWorkerManager.Create(AJobQueue: TOtlObjectQueue);
begin
  inherited Create;
  FLocker := TCriticalSection.Create();
  FJobQueue := AJobQueue;

  FCpuCounter := Self.getCPUNumbers;

  FWorkerCount := 2;
  SetLength(FWorkers, FmaxWorkerCount);
  FWorkers[0] := TJobWorker.Create(Self);
  FWorkers[0].FKeepAlive := True;
  FWorkers[0].Suspended := False;
  FWorkers[1] := TJobWorker.Create(Self);
  FWorkers[1].FKeepAlive := True;
  FWorkers[1].Suspended := False;

end;

destructor TJobWorkerManager.Destroy;
begin
  FLocker.Free;
  inherited Destroy;
end;

class function TJobWorkerManager.getCPUNumbers: Integer;
var
  lvSystemInfo: TSystemInfo;
begin
  GetSystemInfo(lvSystemInfo);
  Result := lvSystemInfo.dwNumberOfProcessors;
end;

procedure TJobWorkerManager.notifyWorker;
var
  i: Integer;

  lvIdleWorker, AWorker: TJobWorker;
begin
  FLocker.Enter;
  try
    lvIdleWorker := nil;
    if not FTerminated then
    begin
      for i := 0 to FWorkerCount - 1 do
      begin
        AWorker := FWorkers[i];
        if (AWorker <> nil) and (not AWorker.FIsBusy) then
        begin
          lvIdleWorker := AWorker;
          Break;
        end;
      end;
      if (lvIdleWorker = nil) and (FWorkerCount < maxWorkerCount) then
      begin
        lvIdleWorker := TJobWorker.Create(Self);
        FWorkers[FWorkerCount] := lvIdleWorker;

        setThreadUseCPU(lvIdleWorker.Handle, FWorkerCount mod FCpuCounter);
        Inc(FWorkerCount);
      end;
    end;
  finally
    FLocker.Leave;
  end;
  if lvIdleWorker <> nil then
  begin
    lvIdleWorker.Suspended := False;
    lvIdleWorker.FEvent.SetEvent;
  end;
end;

procedure TJobWorkerManager.setMaxWorkerCount(const Value: Integer);
var
  ATemp, AMaxLong: Integer;
begin
  if (Value >= 2) and (FmaxWorkerCount <> Value) then
  begin
    FLocker.Enter;
    try
      AMaxLong := Value shr 1;
      if FmaxWorkerCount > Value then
      begin
        while Value < FWorkerCount do
          removeWorker(FWorkers[FWorkerCount - 1]);
        FmaxWorkerCount := Value;
        SetLength(FWorkers, Value);
      end
      else
      begin
        FmaxWorkerCount := Value;
        SetLength(FWorkers, Value);
      end;
    finally
      FLocker.Leave;
    end;
  end;
end;

procedure TJobWorkerManager.removeWorker(AWorker: TObject);
var
  i, J: Integer;
begin
  FLocker.Enter;
  try
    for i := 0 to FWorkerCount - 1 do
    begin
      if FWorkers[i] = AWorker then
      begin
        for J := i to FWorkerCount - 2 do
          FWorkers[J] := FWorkers[J + 1];
        FWorkers[FWorkerCount - 1] := nil;
        Dec(FWorkerCount);
        Break;
      end;
    end;
  finally
    FLocker.Leave;
  end;

end;

procedure TJobWorkerManager.setThreadUseCPU(AHandle: THandle; ACpuNo: Integer);
begin
  SetThreadIdealProcessor(AHandle, ACpuNo);

end;

end.
