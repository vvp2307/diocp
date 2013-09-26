unit uIOCPConsole;

interface

uses
  uIOCPCentre, uSocketListener, Classes, SysUtils;

type
  TIOCPConsole = class(TObject)
  private
    FActive:Boolean;
    
    FIOCPObject: TIOCPObject;

    FIOCPListener: TSocketListener;
    FPort: Integer;

    FWorkerCount: Integer;

    FWorkers: TList;

    function GetWorkerCount: Integer;

    /// <summary>
    ///   停止工作线程
    /// </summary>
    procedure stopWorkers;


    //1 停止监听线程
    procedure stopListener;


    /// <summary>
    ///   开启侦听线程
    /// </summary>
    procedure startListener;


    /// <summary>
    ///   开启工作线程
    /// </summary>
    procedure startWorkers;

  public
    constructor Create;
    destructor Destroy; override;

    procedure DisconnectAllClientContext;


    procedure open;
    procedure close;



    ///是否处理Socket心跳
    procedure setSystemSocketHeartState(pvValue:Boolean);

    function getSystemSocketHeartState:Boolean;


    property Active: Boolean read FActive;
    property Port: Integer read FPort write FPort;




    property WorkerCount: Integer read GetWorkerCount write FWorkerCount;
  end;

implementation

uses
  uIOCPWorker, uIOCPTools;

procedure TIOCPConsole.close;
begin
  //关闭服务端端口
  FIOCPObject.closeSSocket;

  //停止监听
  stopListener;

  //断开所有连接
  FIOCPObject.DisconnectAllClientContext;

  //等待资源的回归
  FIOCPObject.WaiteForResGiveBack;

  //停止工作线程
  stopWorkers;

  //标志状态
  FActive := false;
end;

constructor TIOCPConsole.Create;
begin
  inherited Create;
  FWorkers := TList.Create();
  FIOCPObject := TIOCPObject.Create();
end;

destructor TIOCPConsole.Destroy;
begin
  if FActive then close;
  FIOCPObject.Free;
  FWorkers.Free;
  inherited Destroy;
end;

procedure TIOCPConsole.DisconnectAllClientContext;
begin
  FIOCPObject.DisconnectAllClientContext;
end;

function TIOCPConsole.getSystemSocketHeartState: Boolean;
begin
  Result := FIOCPObject.systemSocketHeartState;
end;

function TIOCPConsole.GetWorkerCount: Integer;
begin
  if FWorkers.Count > 0 then
  begin
    Result := FWorkers.Count;
  end else
  begin
    Result := FWorkerCount;
  end;
end;

procedure TIOCPConsole.open;
begin
  FActive := false;

  try
    
    TIOCPTools.checkSocketInitialize;

    FIOCPObject.Port := FPort;

    //创建一个内核的IOCP句柄
    if not FIOCPObject.createIOCPCoreHandle then Exit;

    //创建监听端口
    if not FIOCPObject.createSSocket then exit;

    //开启工作线程
    startWorkers;

    //绑定监听
    if not FIOCPObject.ListenerBind then exit;

    //开启监听线程
    startListener;
    FActive := true;
  finally
    if not FActive then
    begin
      close;
    end;

  end;
end;

procedure TIOCPConsole.setSystemSocketHeartState(pvValue:Boolean);
begin
  if not FActive then
  begin
    FIOCPObject.systemSocketHeartState := pvValue;
  end else
  begin
    raise Exception.Create('服务开启后不允许修改该属性!');
  end;
end;

procedure TIOCPConsole.startListener;
begin
  FIOCPListener := TSocketListener.Create(True);
  FIOCPListener.SetIOCPObject(FIOCPObject);
  FIOCPListener.Resume;
end;

procedure TIOCPConsole.startWorkers;
var
  i, c:Integer;
  lvWorker:TIOCPWorker;
begin
  c := FWorkerCount;
  if c = 0 then
  begin
    c := TIOCPTools.getCPUNumbers * 2 - 1;
  end;


  for i := 0 to c - 1 do
  begin
    lvWorker := TIOCPWorker.Create(True);
    lvWorker.SetIOCPObject(FIOCPObject);
    lvWorker.Resume;
    FWorkers.Add(lvWorker);
  end;
end;

procedure TIOCPConsole.stopListener;
begin
  if FIOCPListener<> nil then
  begin
    FIOCPListener.Terminate;
    FIOCPListener.WaitFor;
    FIOCPListener.Free;
    FIOCPListener := nil;
  end; 
end;

procedure TIOCPConsole.stopWorkers;
var
  i:Integer;
  lvWoker:TIOCPWorker;
begin                        
  for I:=0 to FWorkers.Count - 1  do
  begin
     //投递一个IO退出请求
     FIOCPObject.PostExitIO;
  end;

  while FWorkers.Count > 0 do
  begin
    lvWoker := TIOCPWorker(FWorkers[0]);
    lvWoker.Terminate;
    lvWoker.WaitFor;
    lvWoker.Free;
    FWorkers.Delete(0);
  end;
end;

end.
