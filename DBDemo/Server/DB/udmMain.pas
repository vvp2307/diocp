unit udmMain;

interface

uses
  SysUtils, Classes, DB, ADODB, uCDSProvider, ADOConnConfig, uDBAccessOperator,
  uICDSOperator, uADOConnectionPoolGroup, uADOPoolGroupTools,
  uDBOperatorPool, uADOOperator, uADOConnectionPool, uMyObjectPool, uScriptMgr,
  superobject;

type
  TdmMain = class(TDataModule)
  private
    FScriptPool:TMyObjectPool;
    FPoolGroup:TADOConnectionPoolGroup;
    FDBOperaPool:TDBOperatorPool;
  public
    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;
    
    property DBOperaPool: TDBOperatorPool read FDBOperaPool;

    property PoolGroup: TADOConnectionPoolGroup read FPoolGroup;
    
    function getConnectionPool(pvID:String): TADOConnectionPool;

    procedure markWillFree(pvObject:TADOConnection; pvConnID:string);

    function beginUseADOConnection(pvConnID: String): TADOConnection;

    procedure endUseADOConnection(pvConnID:string; pvObject:TObject);

    function beginUseADOOperator(pvConnID:String): TADOOperator;
    procedure endUseADOOperator(pvADOOperator:TADOOperator);

    function beginScriptObject():TScriptMgr;
    procedure endScriptObject(pvObject:TScriptMgr);

    function getSQLScript(const pvJSonScript:ISuperObject): string;

    procedure WaitForGiveBack;

    procedure resetPools;

  end;


var
  dmMain: TdmMain;

implementation

uses
  ActiveX, FileLogger, CDSOperatorWrapper;


{$R *.dfm}

constructor TdmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CoInitialize(nil);
  
  FScriptPool := TMyObjectPool.Create(TScriptMgr);
  
  FPoolGroup := TADOConnectionPoolGroup.Create();
  TADOPoolGroupTools.loadconfig(FPoolGroup);

  FDBOperaPool := TDBOperatorPool.Create;
  FDBOperaPool.MaxNum := 1000;

end;

destructor TdmMain.Destroy;
begin
  WaitForGiveBack;
  FScriptPool.Free;
  FPoolGroup.Free;
  FDBOperaPool.Free;
  inherited Destroy;
end;

function TdmMain.beginScriptObject: TScriptMgr;
var
  lvADOPool:TADOConnectionPool;
  lvConn:TADOConnection;
begin
  lvADOPool := FPoolGroup.getPool('sys');
  if lvADOPool = nil then
  begin
    raise Exception.Create('连接池中找不到[sys]的配置连接信息');
  end;

  Result := TScriptMgr(FScriptPool.borrowObject);
  try
    Result.checkReady;
    //暂时存放
    Result.ConnectionPool := lvADOPool;
    lvConn := TADOConnection(lvADOPool.borrowObject);
    try
      Result.setConnection(lvConn);
    except
      lvADOPool.releaseObject(lvConn);
      raise;
    end;
  except
    FScriptPool.releaseObject(Result);
    Result := nil;
    raise;
  end;
end;

function TdmMain.beginUseADOConnection(pvConnID: String): TADOConnection;
var
  lvADOPool:TADOConnectionPool;
  lvConn:TADOConnection;
begin
  lvADOPool := FPoolGroup.getPool(pvConnID);

  if lvADOPool = nil then
  begin
    raise Exception.Create('连接池中找不到[' + pvConnID + ']的配置连接信息');
  end;
  
  Result := TADOConnection(lvADOPool.borrowObject);
end;

function TdmMain.beginUseADOOperator(pvConnID:String): TADOOperator;
var
  lvADOPool:TADOConnectionPool;
  lvConn:TADOConnection;
begin
  lvADOPool := FPoolGroup.getPool(pvConnID);
  if lvADOPool = nil then
  begin
    raise Exception.Create('连接池中找不到[' + pvConnID + ']的配置连接信息');
  end;

  Result := TADOOperator(FDBOperaPool.borrowObject);
  if Result=nil then
  begin
    raise Exception.Create('FDBOperaPool.beginUseObject,失败');
  end;
  try
    //暂时存放
    Result.ConnectionPool := lvADOPool;
    lvConn := TADOConnection(lvADOPool.borrowObject);
    if lvConn=nil then raise Exception.Create('lvADOPool.beginUseObject,失败');
    try
      Result.setConnection(lvConn);
    except
      lvADOPool.releaseObject(lvConn);
      raise;
    end;
  except
    FDBOperaPool.releaseObject(Result);
    Result := nil;
    raise;
  end;
end;

procedure TdmMain.resetPools;
begin
  WaitForGiveBack;
  FScriptPool.resetPool;
  FPoolGroup.clear;
  TADOPoolGroupTools.loadconfig(FPoolGroup);  
  FDBOperaPool.resetPool;  
end;

procedure TdmMain.endScriptObject(pvObject: TScriptMgr);
begin
  if pvObject = nil then Exit;
  pvObject.ConnectionPool.releaseObject(pvObject.Connection);
  FScriptPool.releaseObject(pvObject);
end;

procedure TdmMain.endUseADOConnection(pvConnID: string; pvObject: TObject);
var
  lvADOPool:TADOConnectionPool;
  lvConn:TADOConnection;
begin
  try
    if pvObject = nil then
    begin
      TFileLogger.instance.logMessage(
        '异常TdmMain.endUseADOConnection(pvConnID: string; pvObject: TObject);pvObject=nil', 'ADOPool_ERR');
      Exit;
    end;

    if pvConnID = '' then
    begin
      TFileLogger.instance.logMessage(
        '异常TdmMain.endUseADOConnection(pvConnID: string; pvObject: TObject);pvConnID=nil', 'ADOPool_ERR');
      Exit;
    end;

    lvADOPool := FPoolGroup.getPool(pvConnID);

    if lvADOPool = nil then
    begin
      TFileLogger.instance.logMessage('连接池中找不到[' + pvConnID + ']的配置连接信息', 'ADOPool_ERR');
    end;

    lvADOPool.releaseObject(pvObject);
  except
    on E:Exception do
    begin
      TFileLogger.instance.logMessage('归还ADOConnection时出现了异常[' + pvConnID + ']' + e.Message, 'ADOPool_ERR');
    end;
  end;
end;

procedure TdmMain.endUseADOOperator(pvADOOperator:TADOOperator);
begin
  if pvADOOperator = nil then
  begin
    TFileLogger.instance.logMessage(
      '异常TdmMain.endUseADOOperator(pvADOOperator:TADOOperator)pvADOOperator=nil', 'ADOPool_ERR');
    Exit;
  end else
  begin
    pvADOOperator.ConnectionPool.releaseObject(pvADOOperator.Connection);
    FDBOperaPool.releaseObject(pvADOOperator);
  end;
end;

function TdmMain.getConnectionPool(pvID:String): TADOConnectionPool;
begin
  Result :=FPoolGroup.getPool(pvID);
end;

function TdmMain.getSQLScript(const pvJSonScript:ISuperObject): string;
var
  lvScript:TScriptMgr;
begin
  Result := '';
  if pvJSonScript = nil then exit;
  if pvJSonScript.O['sql'] <> nil then
  begin
    Result := pvJSonScript.S['sql'];
    Exit;
  end else
  begin
    lvScript := dmMain.beginScriptObject;
    try
      try
        lvScript.Connection.Close;
        lvScript.Connection.Open();
      except
        on E:Exception do
        begin
          raise Exception.Create('打开Script连接时出现了异常:' + e.Message);
        end;
      end;
      lvScript.ScriptParser.Clear;
      lvScript.ScriptParser.ScriptKey := pvJSonScript.I['key'];
      lvScript.ScriptParser.ScriptStep := pvJSonScript.I['step'];
      lvScript.ScriptParser.CheckReady;
      lvScript.ScriptParser.MergeParameters(pvJSonScript.O['params']);
      Result := lvScript.ScriptParser.ParseScript;
    finally
      dmMain.endScriptObject(lvScript);
    end;
  end;
end;

procedure TdmMain.markWillFree(pvObject: TADOConnection; pvConnID: string);
var
  lvADOPool:TADOConnectionPool;
  lvConn:TADOConnection;
begin
  lvADOPool := FPoolGroup.getPool(pvConnID);

  if lvADOPool = nil then
  begin
    raise Exception.Create('连接池中找不到[' + pvConnID + ']的配置连接信息');
  end;

  lvADOPool.makeObjectWillFree(pvObject);
end;

procedure TdmMain.WaitForGiveBack;
begin
  FScriptPool.waitForReleaseSingle;
  FDBOperaPool.waitForReleaseSingle;
  FPoolGroup.waitForGiveBack;
end;

end.
