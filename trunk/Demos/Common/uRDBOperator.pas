unit uRDBOperator;
///
///  添加了DBID项目
///

interface

uses
  uD10ClientSocket, superobject, DBClient, JSonStream,
  Classes, SysUtils, DB, uNetworkTools, Windows, WinSock;

type
  TRDBOperator = class(TObject)
  private
    FConnection: TD10ClientSocket;
    FDBID: String;
    FRScript: ISuperObject;
    Ftrace: Boolean;
    FTraceData:ISuperObject;
    function getConfig:ISuperObject;
  public
    constructor Create;
    destructor Destroy; override;

    procedure clear;

    //1 尝试发送两个00,测试socket是否连接失效
    procedure checkSocketConnection;

    procedure QueryCDS(pvCDS: TClientDataSet);


    procedure ExecuteScript;

    function ApplyUpdate(pvCDS: TClientDataSet; pvTable, pvKey: string): Boolean;

    property Connection: TD10ClientSocket read FConnection write FConnection;

    property DBID: String read FDBID write FDBID;


    
    property RScript: ISuperObject read FRScript write FRScript;

    property trace: Boolean read Ftrace write Ftrace;
    property TraceData: ISuperObject read FTraceData;



  end;

implementation

uses
  CDSOperatorWrapper;

function TRDBOperator.ApplyUpdate(pvCDS: TClientDataSet; pvTable, pvKey:
    string): Boolean;
var
  lvJSonStream, lvRecvObject:TJsonStream;
  lvStream:TStream;
  lvData:AnsiString;
  l, j, x:Integer;
begin
  Result := false;
  if pvCDS.State in [dsInsert, dsEdit] then pvCDS.Post;
  
  if pvCDS.ChangeCount = 0 then
  begin
    Exit;
  end;
  FConnection.checkOpen;
  lvJSonStream := TJsonStream.Create;
  try
    lvJSonStream.JSon := SO();
    lvJSonStream.JSon.O['config'] := getConfig;
    lvJSonStream.JSon.I['cmdIndex'] := 1002;   //保存数据

    //打包修改记录
    with TCDSOperatorWrapper.createCDSEncode do
    begin
      setTableINfo(PAnsiChar(AnsiString(pvTable)), PAnsiChar(AnsiString(pvKey)));
      setData(pvCDS.Data, pvCDS.Delta);
      //执行编码
      Execute;
      lvData := getPackageData;
    end;

    lvJSonStream.Stream.Write(lvData[1], Length(lvData));

    FConnection.sendObject(lvJSonStream);
  finally
    lvJSonStream.Free;
  end;

  FConnection.WaitForData;
  
  //读取数据
  lvRecvObject := TJsonStream.Create;
  try
    FConnection.recvObject(lvRecvObject);
    FTraceData := lvRecvObject.Json.O['trace'];
    if not lvRecvObject.getResult then
    begin
      raise Exception.Create(lvRecvObject.getResultMsg);
    end else
    begin
      Result := true;
    end;
  finally
     lvRecvObject.Free;
  end;
end;

procedure TRDBOperator.clear;
begin
  FRScript := SO();
end;

constructor TRDBOperator.Create;
begin
  inherited Create;
  FRScript :=SO();  
end;

destructor TRDBOperator.Destroy;
begin
  FRScript := nil;
  inherited Destroy;
end;

procedure TRDBOperator.checkSocketConnection;
var
  lvRet:Integer;
  lvTempInteger:Integer;
begin
  //服务端解码器需要支持发送两个0
  lvTempInteger := 0;
  lvTempInteger := TNetworkTools.htonl(lvTempInteger);  
  lvRet :=  FConnection.sendBufferEx(@lvTempInteger, SizeOf(lvTempInteger));
  if lvRet = SOCKET_ERROR then
  begin  //服务端已经断开
    FConnection.close;
    Exit;
  end;
  lvRet :=  FConnection.sendBufferEx(@lvTempInteger, SizeOf(lvTempInteger));
  if lvRet = SOCKET_ERROR then
  begin  //服务端已经断开
    FConnection.close;
    Exit;
  end;
end;

procedure TRDBOperator.ExecuteScript;
var
  lvJSonStream, lvRecvObject:TJsonStream;
  lvStream:TStream;
  lvData:AnsiString;
  l, j, x:Integer;
begin
  FConnection.checkOpen;
  
  lvJSonStream := TJsonStream.Create;
  try
    lvJSonStream.JSon := SO();
    lvJSonStream.JSon.O['config'] := getConfig;
    lvJSonStream.JSon.I['cmdIndex'] := 1003;   //打开一个SQL脚本，获取数据
    lvJSonStream.Json.O['script'] := FRScript;
    FConnection.sendObject(lvJSonStream);
  finally
    lvJSonStream.Free;
  end;

  FConnection.WaitForData();

  //读取数据
  lvRecvObject := TJsonStream.Create;
  try
    FConnection.recvObject(lvRecvObject);
    FTraceData := lvRecvObject.Json.O['trace'];
    if not lvRecvObject.getResult then
    begin
      raise Exception.Create(lvRecvObject.getResultMsg);
    end;
  finally
    lvRecvObject.Free;
  end;
end;

function TRDBOperator.getConfig: ISuperObject;
begin
  Result := SO();
  if Ftrace then
  begin
    Result.B['trace'] := true;
  end;
  if FDBID <> '' then
  begin
    Result.S['dbid'] := FDBID;
  end;
  
end;

procedure TRDBOperator.QueryCDS(pvCDS: TClientDataSet);
var
  lvJSonStream, lvRecvObject:TJsonStream;
  lvStream:TStream;
  lvData:AnsiString;
  l, j, x:Integer;
begin
  self.checkSocketConnection;
  
  FConnection.checkOpen;
  lvJSonStream := TJsonStream.Create;
  try
    lvJSonStream.JSon := SO();
    lvJSonStream.JSon.O['config'] := getConfig;

    lvJSonStream.JSon.I['cmdIndex'] := 1001;   //打开一个SQL脚本，获取数据
    lvJSonStream.Json.O['script'] := FRScript;
    FConnection.sendObject(lvJSonStream);
  finally
    lvJSonStream.Free;
  end;

  FConnection.WaitForData();

  //读取数据
  lvRecvObject := TJsonStream.Create;
  try
    FConnection.recvObject(lvRecvObject);
    FTraceData := lvRecvObject.Json.O['trace'];
    if not lvRecvObject.getResult then
    begin
      raise Exception.Create(lvRecvObject.getResultMsg);
    end;

    SetLength(lvData, lvRecvObject.Stream.Size);
    lvRecvObject.Stream.Position := 0;
    lvRecvObject.Stream.ReadBuffer(lvData[1], lvRecvObject.Stream.Size);

    pvCDS.XMLData := lvData;
  finally
    lvRecvObject.Free;
  end;
end;

end.
