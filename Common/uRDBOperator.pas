unit uRDBOperator;
///
///  添加了DBID项目
///    源文件存放E:\项目中心\PluginFrame\Source\Tools\DIOCP\Demos\Common
///  2013年5月28日 09:55:59
///    添加ExecuteCommandText函数
///  2013年5月28日 12:52:55
///    添加checkConnectionConnect函数
///

interface

uses
  uD10ClientSocket, superobject, DBClient, JSonStream,
  Classes, SysUtils, DB, uNetworkTools, Windows, WinSock;

type
  TRDBOperator = class(TObject)
  private
    FTrySend:TJsonStream;
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
    procedure checkSocketConnect;

    //1，尝试发送一个数据
    procedure checkConnectionConnect;

    procedure QueryCDS(pvCDS: TClientDataSet);


    procedure ExecuteScript;

    procedure ExecuteCommandText(pvCmdText:string);

    function ApplyUpdate(pvCDS: TClientDataSet; pvTable, pvKey: string): Boolean;

    property Connection: TD10ClientSocket read FConnection write FConnection;

    property DBID: String read FDBID write FDBID;


    
    property RScript: ISuperObject read FRScript write FRScript;

    property trace: Boolean read Ftrace write Ftrace;
    property TraceData: ISuperObject read FTraceData;
  end;

implementation

uses
  CDSOperatorWrapper, FileLogger;

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

  if FConnection.WaitForData then
  begin
    //读取数据
    lvRecvObject := TJsonStream.Create;
    try
      FConnection.recvObject(lvRecvObject);
      FTraceData := lvRecvObject.Json.O['trace'];
      if not lvRecvObject.getResult then
      begin
        raise Exception.Create('服务端返回信息:' + lvRecvObject.getResultMsg);
      end else
      begin
        Result := true;
      end;
    finally
       lvRecvObject.Free;
    end;
  end;
end;

procedure TRDBOperator.clear;
begin
  FRScript := SO();
end;

constructor TRDBOperator.Create;
begin
  inherited Create;
  FTrySend := TJsonStream.Create;
  FTrySend.Json.I['cmdIndex'] := 102;  //连接测试 
  FRScript :=SO();  
end;

destructor TRDBOperator.Destroy;
begin
  FTrySend.Free;
  FRScript := nil;
  inherited Destroy;
end;

procedure TRDBOperator.checkSocketConnect;
var
  lvRet:Integer;
  lvTempInteger:Integer;
begin
  if FConnection.Active then
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
end;

procedure TRDBOperator.checkConnectionConnect;
begin
  if FConnection.Active then
  begin
    FConnection.RaiseSocketException := false;
    try
      FConnection.sendObject(FTrySend);
      if FConnection.Active then FConnection.recvObject(FTrySend);      
    finally
      FConnection.RaiseSocketException := true;
    end;
  end;

  if not FConnection.Active then
  begin
    FConnection.open;
  end;
end;

procedure TRDBOperator.ExecuteCommandText(pvCmdText:string);
begin
  RScript.Clear();
  RScript.S['sql'] := pvCmdText;
  ExecuteScript;
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

  if FConnection.WaitForData() then
  begin
    //读取数据
    lvRecvObject := TJsonStream.Create;
    try
      FConnection.recvObject(lvRecvObject);
      FTraceData := lvRecvObject.Json.O['trace'];
      if not lvRecvObject.getResult then
      begin
        raise Exception.Create('服务端返回信息:' + lvRecvObject.getResultMsg);
      end;
    finally
      lvRecvObject.Free;
    end;
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
  //self.checkSocketConnect;
  FConnection.checkOpen;
  
  lvJSonStream := TJsonStream.Create;
  try
    lvJSonStream.JSon := SO();
    lvJSonStream.JSon.O['config'] := getConfig;

    lvJSonStream.JSon.I['cmdIndex'] := 1001;   //打开一个SQL脚本，获取数据
    lvJSonStream.Json.O['script'] := FRScript;
    FConnection.sendObject(lvJSonStream);
    //TFileLogger.instance.logDebugMessage('已经sendObject');
  finally
    lvJSonStream.Free;
  end;

  if FConnection.WaitForData() then
  begin
    //TFileLogger.instance.logDebugMessage('已经WaitForData');
    //读取数据
    lvRecvObject := TJsonStream.Create;
    try
      FConnection.recvObject(lvRecvObject);
      //TFileLogger.instance.logDebugMessage('已经lvRecvObject');
      FTraceData := lvRecvObject.Json.O['trace'];
      if not lvRecvObject.getResult then
      begin
        raise Exception.Create('服务端返回信息:' + lvRecvObject.getResultMsg);
      end;

      SetLength(lvData, lvRecvObject.Stream.Size);
      lvRecvObject.Stream.Position := 0;
      lvRecvObject.Stream.ReadBuffer(lvData[1], lvRecvObject.Stream.Size);

      pvCDS.XMLData := lvData;

      //TFileLogger.instance.logDebugMessage('已经XMLData');
    finally
      lvRecvObject.Free;
    end;
  end;
end;

end.
