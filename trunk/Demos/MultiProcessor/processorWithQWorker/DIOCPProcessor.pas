unit DIOCPProcessor;

interface

uses
  zmqapi, classes, SysUtils, JSonStream, uJSonStreamTools, qworker;

type
  TDIOCPProcessor = class(TObject)
  private
    FPullWorkers: TQWorkers;

    FContext: TZMQContext;
    lvSocket:TZMQSocket;
    FPusher: TZMQSocket;

    procedure dowork(data:TStream);

    /// <summary>
    ///   数据接收，处理逻辑
    /// </summary>
    procedure OnDataReceive(AJob:PQJob);

    /// <summary>
    ///   数据处理完后，数据投递回去
    /// </summary>
    procedure OnWriteBack(AJob:PQJob);
  public
    constructor Create;
    destructor Destroy; override;
    procedure start;
  end;

implementation

constructor TDIOCPProcessor.Create;
begin
  inherited Create;
  FContext := TZMQContext.Create();
  FPullWorkers := TQWorkers.Create();
end;

destructor TDIOCPProcessor.Destroy;
begin
  FreeAndNil(FPullWorkers);
  FreeAndNil(FContext);
  inherited Destroy;
end;

procedure TDIOCPProcessor.dowork(data:TStream);
var
  lvJsonStream:TJsonStream;
begin
  lvJsonStream := TJsonStream.create();
  try
    data.position := 0;
    TJsonStreamTools.unPackFromStream(lvJsonStream, data);
    writeln(lvJsonStream.json.S['key']);
  finally
    lvJsonStream.Free;
  end;
end;

procedure TDIOCPProcessor.OnDataReceive(AJob:PQJob);
var
  lvStream:TMemoryStream;
  lvJsonStream:TJsonStream;
begin
  lvStream := TMemoryStream(AJob.Data);
  try
    lvJsonStream := TJsonStream.Create;
    try
      lvStream.Position := 0;
      TJSonStreamTools.unPackFromStream(lvJsonStream, lvStream);

      lvStream.Position := 0;

      ////
      ///  do something....
      ///
      writeln(lvJsonStream.json.S['key']);



      /// end do
      ///



      lvStream.Clear;

      //将lvJSonStream打包成lvStream
      TJSonStreamTools.pack2Stream(lvJsonStream, lvStream);

      ///
      ///  投递到回传队列
      FPullWorkers.Post(OnWriteBack, lvStream);
    finally
      lvJsonStream.Free;
    end;
  except
    lvStream.Free;
  end;

end;

procedure TDIOCPProcessor.OnWriteBack(AJob: PQJob);
var
  lvStream:TStream;
begin
  lvStream := TMemoryStream(AJob.Data);
  try
    lvStream.Position := 0;
    FPusher.send(lvStream, lvStream.Size);
  finally
    lvStream.Free;
  end;
end;

procedure TDIOCPProcessor.start;
var

  lvStream:TMemoryStream;
  lvMsg:UTF8String;
  l:Integer;
begin
  Writeln('demo for DIOCP logic multi-processor, QWorker inside!!!');

  lvSocket := FContext.Socket(stPull);
  lvSocket.connect( 'tcp://localhost:5557' );

  FPusher := FContext.Socket( stPush );
  FPusher.connect( 'tcp://localhost:5558' );

  while not FContext.Terminated do
  begin
    try
      lvStream := TMemoryStream.Create;
      lvStream.Clear;
      lvSocket.recv(lvStream);

      //投递到QWorker
      lvStream.Position := 0;
      Workers.Post(self.OnDataReceive, lvStream);
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  end;

end;

end.
