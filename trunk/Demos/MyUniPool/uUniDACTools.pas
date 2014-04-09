unit uUniDACTools;

interface

uses
  SysUtils, Classes, uUniConnectionPool,
  SQLServerUniProvider,
  SQLiteUniProvider,
  uUniConnectionPoolGroup, DBClient, uMyObjectPool, Uni,
  uUniPoolGroupTools, uUniOperator;

type
  TUniDACTools = class(TObject)
  public
    class procedure loadConfig;
    class procedure QueryCDS(pvCDS: TClientDataSet; pvSQL: String; pvConnID: string
        = '');
    class function createCDS(pvSQL: String; pvConnID: string = ''):TClientDataSet;

    class function executeSQL(pvSQL:string; pvConnID: string = ''): Integer;

    class procedure resetPool;

    class procedure createConnections(pvNum:Integer);

    class function borrowConnection(pvConnID: string = ''): TUniConnection;

    class procedure releaseConnection(pvConnection: TUniConnection; pvConnID:
        string = '');

  end;



implementation

uses
  FileLogger, ActiveX;

var
  __PoolGroup: TUniConnectionPoolGroup;
  __UniOperatorPool: TMyObjectPool;


class function TUniDACTools.borrowConnection(pvConnID: string = ''):
    TUniConnection;
var
  lvUniPool:TUniConnectionPool;
  lvConnID:AnsiString;
begin
  lvConnID := pvConnID;
  if lvConnID = '' then lvConnID := 'main';
  lvUniPool := __PoolGroup.getPool(lvConnID);

  if lvUniPool = nil then
    raise Exception.CreateFmt('无法从数据源池组中找到对应的数据源[%s]', [lvConnID]);

  Result := TUniConnection(lvUniPool.borrowObject);
  try 
    if not Result.Connected then
    begin
      Result.Connect;
    end;

  except
    lvUniPool.releaseObject(Result);
    raise;
  end;
end;

{ TUniDACTools }

class function TUniDACTools.createCDS(pvSQL, pvConnID: string): TClientDataSet;
begin
  Result := TClientDataSet.Create(nil);
  try
    QueryCDS(Result, pvSQL, pvConnID);
  except
    Result.Free;
    raise;
  end;
end;

class procedure TUniDACTools.createConnections(pvNum: Integer);
begin
  //__PoolGroup.createConnections(pvNum);
  __UniOperatorPool.createObjects(pvNum);
end;

class function TUniDACTools.executeSQL(pvSQL:string; pvConnID: string = ''):
    Integer;
var
  lvUniOperator:TUniOperator;
  lvUniPool:TUniConnectionPool;
  lvConn:TUniConnection;
  lvConnID:AnsiString;
begin
  lvConnID := pvConnID;
  if lvConnID = '' then lvConnID := 'main';
  lvUniPool := __PoolGroup.getPool(lvConnID);

  if lvUniPool = nil then
    raise Exception.CreateFmt('无法从数据源池组中找到对应的数据源[%s]', [lvConnID]);

  lvConn := TUniConnection(lvUniPool.borrowObject);
  try
    lvUniOperator := TUniOperator(__UniOperatorPool.borrowObject);
    try
      lvUniOperator.Connection :=lvConn;
      lvUniOperator.CDSProvider.ExecuteScript(pvSQL);
    finally
      __UniOperatorPool.releaseObject(lvUniOperator);
    end;
  finally
    lvUniPool.releaseObject(lvConn);
  end;
end;

class procedure TUniDACTools.loadConfig;
begin
  TUniPoolGroupTools.loadconfig(__PoolGroup);
end;

class procedure TUniDACTools.QueryCDS(pvCDS: TClientDataSet; pvSQL: String;
    pvConnID: string = '');
var
  lvUniOperator:TUniOperator;
  lvUniPool:TUniConnectionPool;
  lvConn:TUniConnection;
  lvConnID:AnsiString;
begin
  lvConnID := pvConnID;
  if lvConnID = '' then lvConnID := 'main';
  lvUniPool := __PoolGroup.getPool(lvConnID);

  if lvUniPool = nil then
    raise Exception.CreateFmt('无法从数据源池组中找到对应的数据源[%s]', [lvConnID]);

  lvConn := TUniConnection(lvUniPool.borrowObject);
  try
    if not lvConn.Connected then
    begin
      CoInitialize(nil);
      lvConn.Connect;
    end;
    lvUniOperator := TUniOperator(__UniOperatorPool.borrowObject);
    try
      lvUniOperator.Connection :=lvConn;
      pvCDS.Data := lvUniOperator.CDSProvider.QueryData(pvSQL);
    finally
      __UniOperatorPool.releaseObject(lvUniOperator);
    end;
  finally
    lvUniPool.releaseObject(lvConn);
  end;
end;

class procedure TUniDACTools.releaseConnection(pvConnection: TUniConnection;
    pvConnID: string = '');
var
  lvUniOperator:TUniOperator;
  lvUniPool:TUniConnectionPool;
  lvConnID:AnsiString;
  lvMsg:String;
begin
  lvConnID := pvConnID;
  if lvConnID = '' then lvConnID := 'main';
  lvUniPool := __PoolGroup.getPool(lvConnID);

  if lvUniPool = nil then
  begin
    lvMsg := Format('归还连接对象时出现异常, 无法从数据源池组中找到对应的数据源[%s]', [lvConnID]);
    TFileLogger.instance.logMessage(lvMsg, 'ERROR_LVL16_');
    raise Exception.Create(lvMsg);
  end;

  lvUniPool.releaseObject(pvConnection);
end;

class procedure TUniDACTools.resetPool;
begin
  __UniOperatorPool.waitForReleaseSingle;
  __UniOperatorPool.clearFreeObjects;
  __PoolGroup.waitForGiveBack;
  __PoolGroup.clear;

  loadConfig;
end;

initialization

  __PoolGroup := TUniConnectionPoolGroup.Create;
  __UniOperatorPool := TMyObjectPool.Create(TUniOperator);
  TUniDACTools.loadconfig();


finalization
  __UniOperatorPool.waitForReleaseSingle;
  __PoolGroup.waitForGiveBack;

  __PoolGroup.clear;
  __PoolGroup.Free;
  __UniOperatorPool.Free;







end.

