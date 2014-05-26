unit uWorkDispatcher;

interface

uses
  OTLObjectQueue, uIOCPCentre, uJobWorker, zmqapi, uJobReceiver, classes;

type
  TJobDataObject = class(TObject)
  private
    /// <summary>
    ///   0:投递给逻辑进程
    ///   1:回写给FContext
    /// </summary>
    FOperaType: Byte;
    FContext:TIOCPClientContext;
    FDataObject:TObject;
  public
    property Context: TIOCPClientContext read FContext write FContext;
    property DataObject: TObject read FDataObject write FDataObject;
    property OperaType: Byte read FOperaType write FOperaType;
  end;

  TWorkDispatcher = class(TObject)
  private
    FJobQueue: TOTLObjectQueue;
    FContext:TZMQContext;
    FSender:TZMQSocket;
    FReceiver:TZMQSocket;
    FJobReceiver:TJobReceiver;
    FJobManager: TJobWorkerManager;
    procedure OnJobExecute(pvDataObj:TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure start;
    procedure stop;
    procedure push(pvDataObject:TObject; pvContext:TIOCPClientContext);

  end;

var
  workDispatcher:TWorkDispatcher;

implementation

uses
  JSonStream, uJSonStreamTools;



constructor TWorkDispatcher.Create;
begin
  inherited Create;
  FJobQueue := TOTLObjectQueue.Create();
  FJobManager := TJobWorkerManager.Create(FJobQueue);
  FJobManager.OnJobExecute := self.OnJobExecute;

  FContext := TZMQContext.create();
  FSender := FContext.Socket(stPush);
  FReceiver := FContext.Socket(stPull);

  FJobReceiver := TJobReceiver.Create(FReceiver, FJobManager);
  FJobReceiver.Resume;
end;

destructor TWorkDispatcher.Destroy;
begin
  stop;
  FJobManager.Terminated := true;
  FJobManager.Free;

  FJobReceiver.notifyTerminate;
  FJobReceiver.WaitFor;
  FJobReceiver.Free;


  FJobQueue.Free;
  FSender.Free;
  FContext.Free;
  inherited Destroy;
end;



procedure TWorkDispatcher.OnJobExecute(pvDataObj: TObject);
var
  lvJobObj, lvNewObj:TJobDataObject;
  lvStream:TMemoryStream;
begin
  lvStream := TMemoryStream.Create;
  try
    lvJobObj := TJobDataObject(pvDataObj);
    if lvJobObj = nil then exit;

    if lvJobObj.OperaType = 1 then
    begin
      if lvJobObj.FContext = nil then
      begin
        lvJobObj.FContext := TIOCPClientContext(TJsonStream(lvJobObj.FDataObject).Json.I['__contextID']);
      end;
      lvJobObj.FContext.writeObject(TJsonStream(lvJobObj.FDataObject));
      lvJobObj.FDataObject.Free;
    end else
    begin
      TJsonStream(lvJobObj.FDataObject).Json.I['__contextID'] := LongInt(lvJobObj.Context);
      TJSonStreamTools.pack2Stream(TJsonStream(lvJobObj.FDataObject), lvStream);
      lvJobObj.FDataObject.Free;
      lvStream.Position := 0;
      FSender.send(lvStream, lvStream.Size);
//      lvNewObj := TJobDataObject.Create;
//      lvNewObj.FType := 1;
//      lvNewObj.FContext := lvJobObj.FContext;
//      lvNewObj.FDataObject := lvJobObj.FDataObject;
//      FJobQueue.Push(lvNewObj);
    end;
    //TJSonStreamTools.pack2Stream()
  finally
    lvStream.Free;
  end;

end;

procedure TWorkDispatcher.push(pvDataObject: TObject;
  pvContext: TIOCPClientContext);
var
  lvObj:TJobDataObject;
begin
  lvObj := TJobDataObject.Create;
  lvObj.FContext := pvContext;
  lvObj.FDataObject := pvDataObject;
  FJobManager.Push(lvObj);
end;


procedure TWorkDispatcher.start;
begin

  FSender.bind('tcp://*:5557');
  Freceiver.bind('tcp://*:5558');
  FJobManager.Enabled := true;
  FJobReceiver.Enabled := true;
end;

procedure TWorkDispatcher.stop;
begin
  FJobReceiver.Enabled := false;
  FSender.unbind('tcp://*:5557');
  Freceiver.unbind('tcp://*:5558');

  FJobManager.Enabled := false;
end;

initialization
  workDispatcher := TWorkDispatcher.Create;

finalization
  workDispatcher.Free;

end.
