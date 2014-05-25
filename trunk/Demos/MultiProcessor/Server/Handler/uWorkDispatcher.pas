unit uWorkDispatcher;

interface

uses
  OTLObjectQueue, uIOCPCentre, uJobWorker;

type
  TJobDataObject = class(TObject)
  private
    /// <summary>
    ///   0:投递给逻辑进程
    ///   1:回写给FContext
    /// </summary>
    FType:Byte;
    FContext:TIOCPClientContext;
    FDataObject:TObject;
  end;

  TWorkDispatcher = class(TObject)
  private
    FJobQueue: TOTLObjectQueue;
    FJobManager: TJobWorkerManager;
    procedure OnJobExecute(pvDataObj:TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure push(pvDataObject:TObject; pvContext:TIOCPClientContext);
  end;

var
  workDispatcher:TWorkDispatcher;

implementation

uses
  zmqapi;

constructor TWorkDispatcher.Create;
begin
  inherited Create;
  FJobQueue := TOTLObjectQueue.Create();
  FJobManager := TJobWorkerManager.Create();
  FJobManager.OnJobExecute := self.OnJobExecute;
end;

destructor TWorkDispatcher.Destroy;
begin
  FJobManager.Terminated := true;
  FJobManager.Free;
  FJobQueue.Free;
  inherited Destroy;
end;



procedure TWorkDispatcher.OnJobExecute(pvDataObj: TObject);
var
  lvContext:TZMQContext;
begin
  lvContext := TZMQContext.create;
  lvContext.Socket()
  ;
end;

procedure TWorkDispatcher.push(pvDataObject: TObject;
  pvContext: TIOCPClientContext);
var
  lvObj:TJobDataObject;
begin
  lvObj := TJobDataObject.Create;
  lvObj.FContext := pvContext;
  lvObj.FDataObject := pvDataObject;
  FJobQueue.Push(lvObj);
end;


initialization
  workDispatcher := TWorkDispatcher.Create;

finalization
  workDispatcher.Free;

end.
