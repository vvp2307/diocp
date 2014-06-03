unit uWorkDispatcher;

interface

uses
  BaseQueue, uIOCPCentre, zmqapi, uJobReceiver, classes,
  SysUtils, uJobPushWorker;

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
    FPushQueue: TBaseQueue;
    FContext:TZMQContext;
    FSender:TZMQSocket;
    FReceiver:TZMQSocket;
    FJobReceiver:TJobReceiver;
    FJobPusher: TJobPushWorker;
    procedure OnJobExecute(pvDataObj:TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure start;
    procedure stop;
    procedure Push(pvDataObject:TObject; pvContext:TIOCPClientContext);

  end;

var
  workDispatcher:TWorkDispatcher;

implementation

uses
  JSonStream, uJSonStreamTools, FileLogger;



constructor TWorkDispatcher.Create;
begin
  inherited Create;
  FPushQueue := TBaseQueue.Create();
  FContext := TZMQContext.create();
  FSender := FContext.Socket(stPush);
  FReceiver := FContext.Socket(stPull);

  FJobReceiver := TJobReceiver.Create(FReceiver);
  FJobReceiver.Resume;
  FJobPusher := TJobPushWorker.Create(FSender, FPushQueue);
  FJobPusher.Resume;
end;

destructor TWorkDispatcher.Destroy;
begin

  stop;

  FJobPusher.notifyTerminate;
  FJobPusher.WaitFor;
  FJobPusher.Free;


  FJobReceiver.notifyTerminate;
  FJobReceiver.WaitFor;
  FJobReceiver.Free;


  FPushQueue.Free;
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
    begin                     //投递到iocp队列，发送回客户端
      if lvJobObj.FContext = nil then
      begin
        lvJobObj.FContext := TIOCPClientContext(TJsonStream(lvJobObj.FDataObject).Json.I['__contextID']);
      end;
      lvJobObj.FContext.writeObject(TJsonStream(lvJobObj.FDataObject));
      //lvJobObj.FDataObject.Free;
    end else
    begin                     //发送到逻辑进程
      TJsonStream(lvJobObj.FDataObject).Json.I['__contextID'] := LongInt(lvJobObj.Context);
      TJSonStreamTools.pack2Stream(TJsonStream(lvJobObj.FDataObject), lvStream);
      //lvJobObj.FDataObject.Free;
      lvStream.Position := 0;
      FSender.send(lvStream, lvStream.Size);
//      lvNewObj := TJobDataObject.Create;
//      lvNewObj.FType := 1;
//      lvNewObj.FContext := lvJobObj.FContext;
//      lvNewObj.FDataObject := lvJobObj.FDataObject;
//      FPushQueue.Push(lvNewObj);
    end;
    //TJSonStreamTools.pack2Stream()
  finally
    lvStream.Free;
  end;

end;

procedure TWorkDispatcher.Push(pvDataObject:TObject;
    pvContext:TIOCPClientContext);
var
  lvObj:TJobDataObject;
begin
  try
    lvObj := TJobDataObject.Create;
    lvObj.FOperaType := 0;
    lvObj.FContext := pvContext;
    lvObj.FDataObject := pvDataObject;
    FPushQueue.Push(lvObj);
    FJobPusher.notifyWork;
  except
    on E:Exception do
    begin
      TFileLogger.instance.logMessage('Push:' + E.Message, 'JOB_ERROR_');
    end;
  end;
end;


procedure TWorkDispatcher.start;
begin

  FSender.bind('tcp://*:5557');
  Freceiver.bind('tcp://*:5558');
  FJobReceiver.Enabled := true;
  FJobPusher.Enabled := true;
end;

procedure TWorkDispatcher.stop;
begin
  FJobReceiver.Enabled := false;
  FJobPusher.Enabled := false;
  try
    FSender.unbind('tcp://*:5557');

  except
  end;

  try
    Freceiver.unbind('tcp://*:5558');
  except
  end;

end;

initialization
  workDispatcher := TWorkDispatcher.Create;

finalization
  workDispatcher.Free;

end.
