unit uClientContext;

interface

uses
  Windows, uBuffer, SyncObjs, Classes, SysUtils, uIOCPCentre,
  uScriptMgr, cdsProvider, ADODB, superobject, uADOOperator;

type
  TClientContext = class(TIOCPClientContext)
  protected
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    procedure DoOnWriteBack; override;

    function getConnection(pvConnID:AnsiString):TADOConnection;

  private

    procedure getConnectionINfo(const pvDataObject:TObject);

    procedure executeApplyUpdate(const pvDataObject:TObject);

    procedure executeApplyUpdateEx(const pvDataObject:TObject);
    procedure openSQLScript(const pvDataObject:TObject);
    procedure openSQLScriptEx(const pvDataObject:TObject);
    procedure executeSQLScriptWithTrans(const pvDataObject:TObject);

    procedure executeSQLScriptWithTransEx(const pvDataObject:TObject);

    /// {withTrans:true, type:open, sql:""},
    procedure executeSQLScript(const pvDataObject:TObject);
    /// {withTrans:true, type:open, sql:""},
    procedure executeSQLScriptEx(const pvDataObject:TObject);

    procedure executeSyncBillINfo(const pvDataObject:TObject);

    procedure innerExecuteSyncBillINfo(const pvINfo: ISuperObject; pvTraceData:
        ISuperObject; pvADOOperator: TADOOperator);

  public


    /// <summary>
    ///   数据处理
    /// </summary>
    /// <param name="pvDataObject"> (TObject) </param>
    procedure dataReceived(const pvDataObject:TObject); override;


  end;

implementation

uses
  TesterINfo, JSonStream, udmMain, 
  uADOConnectionTools, uRunTimeINfoTools, uIOCPDebugger, DBClient, ComObj,
  FileLogger;



procedure TClientContext.dataReceived(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile, lvMsg:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID, lvType:String;
  lvADOOpera:TADOOperator;
  lvJSonScript, lvItem:ISuperObject;
  lvScript:TScriptMgr;
  lvWithTrans, lvTrace:Boolean;
begin
  StateINfo := '进入dataReceived';
  lvJsonStream := TJSonStream(pvDataObject);

  lvCmdIndex := lvJsonStream.JSon.I['cmdIndex'];

  InterlockedIncrement(TesterINfo.__RecvTimes);
  if lvCmdIndex = 101 then
  begin
    //客户端的发送测试<检测是否可用>
    //不做处理
  end else if lvCmdIndex = 102 then
  begin    //可以进行测试连接
    //回写数据
    writeObject(lvJsonStream);
  end else if lvCmdIndex = 103 then
  begin  //获取连接信息
    StateINfo := '获取连接信息连接';
    getConnectionINfo(lvJsonStream);
    writeObject(lvJsonStream);
  end else if lvCmdIndex= 1000 then
  begin                 //echo测试
    //回写数据
    writeObject(lvJsonStream);
  end else if lvCmdIndex = 1001 then
  begin  //根据sql获取一个数据，放在Stream中
  
    openSQLScriptEx(lvJsonStream);
    
    //回写数据
    writeObject(lvJsonStream);
  end else if lvCmdIndex = 1002 then  //保存数据到数据库
  begin
    executeApplyUpdateEx(lvJsonStream);
    //回写数据
    writeObject(lvJsonStream);
  end else if lvCmdIndex = 1003 then
  begin  //执行sql        {script:{key:script:}};  //{list:[{key:script:}]}
    executeSQLScriptWithTransEx(lvJsonStream);

    //回写数据
    writeObject(lvJsonStream);
  end else if lvCmdIndex = 1004 then
  begin  //执行sql        {withTrans:true, type:open, sql:""},
    executeSQLScriptEx(lvJsonStream);

    //回写数据
    writeObject(lvJsonStream);
    
  end else if lvCmdIndex = 1005 then
  begin  //同步状态信息
    executeSyncBillINfo(lvJsonStream);

    //回写数据
    writeObject(lvJsonStream);
  end else
  begin
    //返回数据
    writeObject(lvJsonStream);
  end;
  StateINfo := '执行完成dataReceived';
end;

procedure TClientContext.DoConnect;
begin
  inherited;
  Self.StateINfo := '建立连接成功!';
  InterlockedIncrement(TesterINfo.__ClientContextCount);
end;

procedure TClientContext.DoDisconnect;
begin
  inherited DoDisconnect;
  InterlockedDecrement(TesterINfo.__ClientContextCount);
end;



procedure TClientContext.DoOnWriteBack;
begin
  inherited;
  InterlockedIncrement(TesterINfo.__SendTimes);
end;

procedure TClientContext.executeApplyUpdate(const pvDataObject: TObject);
var
  lvList:TList;
  i: Integer;
  lvClient:TClientContext;
  lvJsonStream:TJsonStream;
  lvItem, lvTraceData:ISuperObject;
  lvXMLData, lvEncodeData, lvID:AnsiString;
  lvTrace:Boolean;
  lvADOOpera:TADOOperator;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    lvTraceData := SO();
    lvJsonStream.Stream.Position := 0;
    SetLength(lvEncodeData, lvJSonStream.Stream.Size);
    lvJsonStream.Stream.ReadBuffer(lvEnCodeData[1], lvJSonStream.Stream.Size);
      
    lvID := 'main';
    if lvJsonStream.Json.S['config.dbid'] <> '' then
    begin
      lvID := lvJsonStream.Json.S['config.dbid'];
    end;
    lvTrace := lvJsonStream.Json.B['config.trace'];

    self.StateINfo := '1002.' + DateTimeToStr(Now()) + ':准备借用一个lvADOOpera!';
    lvADOOpera :=  dmMain.beginUseADOOperator(lvID);
    try
       
      self.StateINfo := '1002.' + DateTimeToStr(Now()) + ':借用了一个lvADOOpera,准备打开连接!';
      try
        lvADOOpera.ReOpen;
        self.StateINfo :='1002.' + DateTimeToStr(Now()) +
          Format(':lvADOOpera打开连接成功,准备执行ExecuteApplyUpdate,超时设置[%d]', [lvADOOpera.Connection.CommandTimeout]);

        if lvTrace then
        begin
          lvADOOpera.TraceData := lvTraceData;
        end;
        lvADOOpera.ExecuteApplyUpdate(lvEncodeData);
        self.StateINfo := '1002.' + DateTimeToStr(Now()) + ':lvADOOpera,执行ExecuteApplyUpdate完成,准备回写数据';
      except
        on E:Exception do
        begin
          self.StateINfo :='1002.' + DateTimeToStr(Now()) + ':lvADOOpera,执行ExecuteApplyUpdate时出现了异常:' + e.Message;
          TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);
          raise;
        end;
      end;
    finally
      lvADOOpera.TraceData := nil;
      dmMain.endUseADOOperator(lvADOOpera);
    end;

    lvJsonStream.Clear();
    lvJsonStream.Json.O['trace'] := lvTraceData;
    lvJsonStream.setResult(True);
  except
    on e:Exception do
    begin
      lvJsonStream.Clear();
      lvJsonStream.setResult(False);
      lvJsonStream.Json.O['trace'] := lvTraceData;
      lvJsonStream.setResultMsg(e.Message);
    end;
  end;
end;

procedure TClientContext.executeApplyUpdateEx(const pvDataObject:TObject);
var
  lvList:TList;
  i: Integer;
  lvClient:TClientContext;
  lvJsonStream:TJsonStream;
  lvItem, lvTraceData:ISuperObject;
  lvXMLData, lvEncodeData, lvID:AnsiString;
  lvTrace:Boolean;
  lvADOOpera:TADOOperator;
  lvConnection:TADOConnection;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try 
    lvTraceData := SO();
    lvJsonStream.Stream.Position := 0;
    SetLength(lvEncodeData, lvJSonStream.Stream.Size);
    lvJsonStream.Stream.ReadBuffer(lvEnCodeData[1], lvJSonStream.Stream.Size);
      
    lvID := 'main';
    if lvJsonStream.Json.S['config.dbid'] <> '' then
    begin
      lvID := lvJsonStream.Json.S['config.dbid'];
    end;
    lvTrace := lvJsonStream.Json.B['config.trace'];

    self.StateINfo := '1002.' + DateTimeToStr(Now()) + ':准备借用一个lvADOOpera!';
    lvADOOpera := TADOOperator.Create;
    try
      lvConnection := dmMain.beginUseADOConnection(lvID);
      try
        lvADOOpera.setConnection(lvConnection);
                                                                                 
        self.StateINfo := '1002.' + DateTimeToStr(Now()) + ':借用了一个lvADOOpera,准备打开连接!';
        try
          lvADOOpera.ReOpen;
          self.StateINfo :='1002.' + DateTimeToStr(Now()) +
            Format(':lvADOOpera打开连接成功,准备执行ExecuteApplyUpdate,超时设置[%d]', [lvADOOpera.Connection.CommandTimeout]);

          if lvTrace then
          begin
            lvADOOpera.TraceData := lvTraceData;
          end;
          lvADOOpera.ExecuteApplyUpdate(lvEncodeData);
          self.StateINfo := '1002.' + DateTimeToStr(Now()) + ':lvADOOpera,执行ExecuteApplyUpdate完成,准备回写数据';
        except
          on E:Exception do
          begin
            self.StateINfo :='1002.' + DateTimeToStr(Now()) + ':lvADOOpera,执行ExecuteApplyUpdate时出现了异常:' + e.Message;
            TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);
            raise;
          end;
        end;
      finally
        lvADOOpera.setConnection(nil);

        self.StateINfo := '1002.' + DateTimeToStr(Now()) + ':lvADOOpera.ADOConnection,准备归还';
        //归还到连接池
        dmMain.endUseADOConnection(lvID, lvConnection);
        self.StateINfo := '1002.' + DateTimeToStr(Now()) + ':lvADOOpera.ADOConnection,归还成功';
      end;
    finally
      lvADOOpera.Free;
    end;

    lvJsonStream.Clear();
    lvJsonStream.Json.O['trace'] := lvTraceData;
    lvJsonStream.setResult(True);
  except
    on e:Exception do
    begin
      lvJsonStream.Clear();
      lvJsonStream.setResult(False);
      lvJsonStream.Json.O['trace'] := lvTraceData;
      lvJsonStream.setResultMsg(e.Message);
    end;
  end;
end;

procedure TClientContext.openSQLScript(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile, lvMsg:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID, lvType:String;
  lvADOOpera:TADOOperator;
  lvJSonScript, lvItem:ISuperObject;
  lvScript:TScriptMgr;
  lvWithTrans, lvTrace:Boolean;
  lvTraceData:ISuperObject;
  lvConnection:TADOConnection;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    lvTraceData := SO();
    lvJSonScript := lvJsonStream.Json.O['script'];
    if lvJSonScript <> nil then
    begin
      lvSQL := dmMain.getSQLScript(lvJSonScript);
    end else
    begin
      lvSQL := lvJsonStream.Json.S['sql'];
    end;
      
    if lvSQL = '' then
    begin
      raise Exception.Create('没有指定要执行的SQL!');
    end;
    lvID := 'main';
    if lvJsonStream.Json.S['config.dbid'] <> '' then
    begin
      lvID := lvJsonStream.Json.S['config.dbid'];
    end;
    lvTrace := lvJsonStream.Json.B['config.trace'];
    if lvTrace then
    begin
      lvTraceData.S['sqls[]'] := lvSQL;
    end;
      
    self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':准备借用一个lvADOOpera!';
      
    //从对象池中借用
    lvADOOpera := dmMain.beginUseADOOperator(lvID);
    try
      self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':借用了一个lvADOOpera,准备打开连接!';
      try
        lvADOOpera.ReOpen;
        self.StateINfo :='1001.' + DateTimeToStr(Now()) +
          Format(':lvADOOpera打开连接成功,准备执行SQL语句,超时设置[%d]', [lvADOOpera.Connection.CommandTimeout]);
        lvXMLData := lvADOOpera.CDSProvider.QueryXMLData(lvSQL);
        self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':lvADOOpera,执行SQL语句完成,准备回写数据';
      except
        on E:Exception do
        begin
          self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':lvADOOpera,执行SQL语句时出现了异常:' + e.Message;
          TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);
          raise;
        end;
      end;

      lvJsonStream.Clear();
      lvJsonStream.Json.O['trace'] := lvTraceData;
      lvJsonStream.Stream.WriteBuffer(lvXMLData[1], Length(lvXMLData));
      lvJsonStream.setResult(True);
    finally
      self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':lvADOOpera,准备归还';
      //归还到连接池
      dmMain.endUseADOOperator(lvADOOpera);
      self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':lvADOOpera,归还成功';
    end;
  except
    on e:Exception do
    begin
      lvJsonStream.Clear();
      lvJsonStream.Json.O['trace'] := lvTraceData;
      lvJsonStream.setResult(False);
      lvJsonStream.setResultMsg(e.Message);
    end;
  end;
end;

function TClientContext.getConnection(pvConnID: AnsiString): TADOConnection;
begin

end;

procedure TClientContext.getConnectionINfo(const pvDataObject: TObject);
var
  lvList:TList;
  i: Integer;
  lvClient:TClientContext;
  lvJsonStream:TJsonStream;
  lvItem:ISuperObject;
begin
  lvJsonStream := TJSonStream(pvDataObject);

  lvJsonStream.Clear();

  lvList:=TList.Create;
  try
    TIOCPContextFactory.instance.IOCPContextPool.getUsingList(lvList);
    for i := 0 to lvList.Count - 1 do
    begin
      lvClient := TClientContext(lvList[i]);
      lvItem := SO();
      lvItem.S['addr'] := lvClient.RemoteAddr;
      lvItem.I['port'] := lvClient.RemotePort;
      lvItem.S['info'] := lvClient.StateINfo;
      lvJsonStream.Json.O['info.list[]'] := lvItem;
    end;

    lvJsonStream.Json.S['info.runInfo'] := TRunTimeINfoTools.getRunTimeINfo;
    lvJsonStream.Json.I['info.onlineNum'] :=  TIOCPDebugger.clientCount;

    lvJsonStream.Json.S['info.pool.connection'] := dmMain.PoolGroup.getPoolINfo;
    lvJsonStream.Json.S['info.pool.ADOOperator'] := Format('(总数:%d,使用:%d)',
        [dmMain.DBOperaPool.Count,
        dmMain.DBOperaPool.getBusyCount]);
  finally
    lvList.Free;
  end;
end;

procedure TClientContext.openSQLScriptEx(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile, lvMsg:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID, lvType:String;
  lvADOOpera:TADOOperator;
  lvJSonScript, lvItem:ISuperObject;
  lvScript:TScriptMgr;
  lvWithTrans, lvTrace:Boolean;
  lvTraceData:ISuperObject;
  lvConnection:TADOConnection;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    lvTraceData := SO();
    lvJSonScript := lvJsonStream.Json.O['script'];
    if lvJSonScript <> nil then
    begin
      lvSQL := dmMain.getSQLScript(lvJSonScript);
    end else
    begin
      lvSQL := lvJsonStream.Json.S['sql'];
    end;
      
    if lvSQL = '' then
    begin
      raise Exception.Create('没有指定要执行的SQL!');
    end;
    lvID := 'main';
    if lvJsonStream.Json.S['config.dbid'] <> '' then
    begin
      lvID := lvJsonStream.Json.S['config.dbid'];
    end;
    lvTrace := lvJsonStream.Json.B['config.trace'];
    if lvTrace then
    begin
      lvTraceData.S['sqls[]'] := lvSQL;
    end;
      
    self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':准备借用一个lvADOOpera!';
      
    //从对象池中借用
    lvADOOpera := TADOOperator(dmMain.DBOperaPool.borrowObject);
    try
      lvConnection := dmMain.beginUseADOConnection(lvID);
      try
//        try
//          lvConnection.Close;
//          lvConnection.Open();
//        except
//          on E:Exception do
//          begin
//            lvMsg := '数据库重连失败(openSQLScriptEx), ExceptionClass:' + E.ClassName + sLineBreak + e.Message;
//            try
//              dmMain.markWillFree(lvConnection, lvID);
//            except
//            end;                                              
//            TFileLogger.instance.logMessage(lvMsg, 'ADO_ERROR_');
//            raise Exception.Create(lvMsg);
//          end;          
//        end;

        lvADOOpera.setConnection(lvConnection);
        self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':借用了一个lvADOOpera,准备打开连接!';
        try
          self.StateINfo :='1001.' + DateTimeToStr(Now()) +
            Format(':lvADOOpera打开连接成功,准备执行SQL语句,超时设置[%d]', [lvConnection.CommandTimeout]);
          lvXMLData := lvADOOpera.CDSProvider.QueryXMLData(lvSQL);
          self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':lvADOOpera,执行SQL语句完成,准备回写数据';
        except
          on E:Exception do
          begin
            self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':lvADOOpera,执行SQL语句时出现了异常:' + e.Message;
            TFileLogger.instance.logMessage(self.StateINfo, 'ADOErr_');

            if TADOConnectionTools.checkConnectionNeedReconnect(lvConnection) then
            begin
              TFileLogger.instance.logMessage('标志释放该连接,' +  Self.StateINfo, 'ADO_ERROR_');
              dmMain.markWillFree(lvConnection, lvID);
            end;

            TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvConnection);
            raise;
          end;
        end;

        lvJsonStream.Clear();
        lvJsonStream.Json.O['trace'] := lvTraceData;
        lvJsonStream.Stream.WriteBuffer(lvXMLData[1], Length(lvXMLData));
        lvJsonStream.setResult(True);
      finally
        //lvADOOpera.setConnection(nil);
        self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':lvADOOpera.ADOConnection,准备归还';
        //归还到连接池
        dmMain.endUseADOConnection(lvID, lvConnection);
        self.StateINfo := '1001.' + DateTimeToStr(Now()) + ':lvADOOpera.ADOConnection,归还成功';
      end;
    finally
      dmMain.DBOperaPool.releaseObject(lvADOOpera);
    end;
  except
    on e:Exception do
    begin
      lvJsonStream.Clear();
      lvJsonStream.Json.O['trace'] := lvTraceData;
      lvJsonStream.setResult(False);
      lvJsonStream.setResultMsg(e.Message);
    end;
  end;
end;

procedure TClientContext.executeSQLScriptWithTrans(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile, lvMsg:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID, lvType:String;
  lvADOOpera:TADOOperator;
  lvJSonScript, lvItem:ISuperObject;
  lvScript:TScriptMgr;
  lvWithTrans, lvTrace:Boolean;
  lvTraceData:ISuperObject;
  lvConnection:TADOConnection;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
      lvTraceData := SO();
      lvID := 'main';
      if lvJsonStream.Json.S['config.dbid'] <> '' then
      begin
        lvID := lvJsonStream.Json.S['config.dbid'];
      end;
      lvTrace := lvJsonStream.Json.B['config.trace'];
      
      self.StateINfo := '1003.' + DateTimeToStr(Now()) + ':准备借用一个lvADOOpera!';

      lvADOOpera := dmMain.beginUseADOOperator(lvID);
      try
        try
          self.StateINfo := '1003.' + DateTimeToStr(Now()) + ':借用了一个lvADOOpera,准备打开连接!';
          lvADOOpera.ReOpen;
          self.StateINfo := '1003.' + DateTimeToStr(Now()) + 
            Format(':lvADOOpera打开连接成功,准备执行SQL语句,超时设置[%d]',
            [lvADOOpera.Connection.CommandTimeout]);

          lvJSonScript := lvJsonStream.Json.O['script'];
          if lvJSonScript <> nil then
          begin
            lvADOOpera.Connection.BeginTrans;
            try
              lvSQL := dmMain.getSQLScript(lvJSonScript);
              if lvTrace then
              begin
                lvTraceData.S['sqls[]'] := lvSQL;
              end;
              lvADOOpera.CDSProvider.ExecuteScript(lvSQL);

              lvADOOpera.Connection.CommitTrans;
            except
              lvADOOpera.Connection.RollbackTrans;
              raise;
            end;
          end else if lvJsonStream.Json.O['list'] <> nil then
          begin
            lvADOOpera.Connection.BeginTrans;
            try
              lvSQL := dmMain.getSQLScript(lvJSonScript);

              for lvItem in lvJsonStream.Json.O['list'] do
              begin
                lvSQL := '';
                if lvItem.S['sql'] <> '' then
                begin
                  lvSQL := lvItem.S['sql'];
                end else
                begin
                  lvSQL := dmMain.getSQLScript(lvJSonScript);
                end;

                if lvSQL <> '' then
                begin
                  if lvTrace then
                  begin
                    lvTraceData.S['sqls[]'] := lvSQL;
                  end;
                  lvADOOpera.CDSProvider.ExecuteScript(lvSQL);
                end;
              end;

              lvADOOpera.Connection.CommitTrans;
            except
              lvADOOpera.Connection.RollbackTrans;
              raise;
            end;
          end;
        except
          on E:Exception do
          begin
            self.StateINfo := '1003.' + DateTimeToStr(Now()) + ':lvADOOpera,执行SQL语句时出现了异常:' + e.Message;
            TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);
            raise;
          end;
        end;
        lvJsonStream.Clear();
        lvJsonStream.Json.O['trace'] := lvTraceData;
        lvJsonStream.setResult(True);
      finally
        dmMain.endUseADOOperator(lvADOOpera);
        self.StateINfo := '1003.' + DateTimeToStr(Now()) + ':lvADOOpera,归还成功';
      end;
    except
      on e:Exception do
      begin
        lvJsonStream.Clear();
        lvJsonStream.setResult(False);
        lvJsonStream.Json.O['trace'] := lvTraceData;
        lvJsonStream.setResultMsg(e.Message);
      end;
    end;
end;

procedure TClientContext.executeSQLScript(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile, lvMsg:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID, lvType:String;
  lvADOOpera:TADOOperator;
  lvJSonScript, lvItem:ISuperObject;
  lvScript:TScriptMgr;
  lvWithTrans, lvTrace:Boolean;
  lvTraceData:ISuperObject;
  lvConnection:TADOConnection;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    lvTraceData := SO();
    lvID := 'main';
    if lvJsonStream.Json.S['config.dbid'] <> '' then
    begin
      lvID := lvJsonStream.Json.S['config.dbid'];
    end;
    lvTrace := lvJsonStream.Json.B['config.trace'];
    lvADOOpera := dmMain.beginUseADOOperator(lvID);
    try
      try
        lvADOOpera.ReOpen;
        self.StateINfo :=
          Format('lvADOOpera打开连接成功,准备执行SQL语句,超时设置[%d]', [lvADOOpera.Connection.CommandTimeout]);

        lvSQL := lvJsonStream.Json.S['sql'];
        if lvSQL = '' then raise Exception.Create('没有指定需要执行的SQL');
        lvWithTrans := lvJsonStream.Json.B['withTrans'];
        lvType := lvJsonStream.Json.S['type'];
        if lvWithTrans then lvADOOpera.Connection.BeginTrans;
        try
          if lvTrace then
          begin
            lvTraceData.S['sqls[]'] := lvSQL;
          end;
          if SameText('open',lvType) then
          begin
            lvXMLData := lvADOOpera.CDSProvider.QueryXMLData(lvSQL);
          end else
          begin
            lvADOOpera.executeScript(lvSQL);
          end;
          if lvWithTrans then lvADOOpera.Connection.CommitTrans;
        except
          if lvWithTrans then lvADOOpera.Connection.RollbackTrans;
          raise;
        end;
      except
        TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);
        raise;
      end;
      lvJsonStream.Clear();
      lvJsonStream.Json.O['trace'] := lvTraceData;
      if SameText('open',lvType) then  //回写数据
        lvJsonStream.Stream.WriteBuffer(lvXMLData[1], Length(lvXMLData));
      lvJsonStream.setResult(True);
    finally
      dmMain.endUseADOOperator(lvADOOpera);
      self.StateINfo := 'lvADOOpera,归还成功';
    end;
  except
    on e:Exception do
    begin
      lvJsonStream.Clear();
      lvJsonStream.setResult(False);
      lvJsonStream.Json.O['trace'] := lvTraceData;
      lvJsonStream.setResultMsg(e.Message);
    end;
  end;
end;

procedure TClientContext.executeSQLScriptEx(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile, lvMsg:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID, lvType:String;
  lvADOOpera:TADOOperator;
  lvJSonScript, lvItem:ISuperObject;
  lvScript:TScriptMgr;
  lvWithTrans, lvTrace:Boolean;
  lvTraceData:ISuperObject;
  lvConnection:TADOConnection;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    lvTraceData := SO();
    lvID := 'main';
    if lvJsonStream.Json.S['config.dbid'] <> '' then
    begin
      lvID := lvJsonStream.Json.S['config.dbid'];
    end;
    lvTrace := lvJsonStream.Json.B['config.trace'];
    lvADOOpera := TADOOperator.Create;
    try
      lvConnection := dmMain.beginUseADOConnection(lvID);
      try
        try
          lvADOOpera.setConnection(lvConnection);
          lvADOOpera.ReOpen;
          self.StateINfo :=
            Format('lvADOOpera打开连接成功,准备执行SQL语句,超时设置[%d]', [lvADOOpera.Connection.CommandTimeout]);

          lvSQL := lvJsonStream.Json.S['sql'];
          if lvSQL = '' then raise Exception.Create('没有指定需要执行的SQL');
          lvWithTrans := lvJsonStream.Json.B['withTrans'];
          lvType := lvJsonStream.Json.S['type'];
          if lvWithTrans then lvADOOpera.Connection.BeginTrans;
          try
            if lvTrace then
            begin
              lvTraceData.S['sqls[]'] := lvSQL;
            end;
            if SameText('open',lvType) then
            begin
              lvXMLData := lvADOOpera.CDSProvider.QueryXMLData(lvSQL);
            end else
            begin
              lvADOOpera.executeScript(lvSQL);
            end;
            if lvWithTrans then lvADOOpera.Connection.CommitTrans;
          except
            if lvWithTrans then lvADOOpera.Connection.RollbackTrans;
            raise;
          end;
        except
          TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);
          raise;
        end;
        lvJsonStream.Clear();
        lvJsonStream.Json.O['trace'] := lvTraceData;
        if SameText('open',lvType) then  //回写数据
          lvJsonStream.Stream.WriteBuffer(lvXMLData[1], Length(lvXMLData));
        lvJsonStream.setResult(True);
      finally
        lvADOOpera.setConnection(nil);
        
        self.StateINfo := '1004.' + DateTimeToStr(Now()) + ':lvADOOpera.ADOConnection,准备归还';
        //归还到连接池
        dmMain.endUseADOConnection(lvID, lvConnection);
        self.StateINfo := '1004.' + DateTimeToStr(Now()) + ':lvADOOpera.ADOConnection,归还成功';
      end;
    finally
      lvADOOpera.Free;
    end;
  except
    on e:Exception do
    begin
      lvJsonStream.Clear();
      lvJsonStream.setResult(False);
      lvJsonStream.Json.O['trace'] := lvTraceData;
      lvJsonStream.setResultMsg(e.Message);
    end;
  end;
end;

procedure TClientContext.executeSQLScriptWithTransEx(const
    pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile, lvMsg:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID, lvType:String;
  lvADOOpera:TADOOperator;
  lvJSonScript, lvItem:ISuperObject;
  lvScript:TScriptMgr;
  lvWithTrans, lvTrace:Boolean;
  lvTraceData:ISuperObject;
  lvConnection:TADOConnection;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    lvTraceData := SO();
    lvID := 'main';
    if lvJsonStream.Json.S['config.dbid'] <> '' then
    begin
      lvID := lvJsonStream.Json.S['config.dbid'];
    end;
    lvTrace := lvJsonStream.Json.B['config.trace'];

    self.StateINfo := '1003.' + DateTimeToStr(Now()) + ':准备借用一个lvADOOpera!';
    lvConnection := dmMain.beginUseADOConnection(lvID);
    try
      lvADOOpera := TADOOperator(dmMain.DBOperaPool.borrowObject);
      try
        lvADOOpera.setConnection(lvConnection);
        try
          self.StateINfo := '1003.' + DateTimeToStr(Now()) + ':借用了一个lvADOOpera,准备打开连接!';
          lvADOOpera.ReOpen;
          self.StateINfo := '1003.' + DateTimeToStr(Now()) +
            Format(':lvADOOpera打开连接成功,准备执行SQL语句,超时设置[%d]',
            [lvADOOpera.Connection.CommandTimeout]);

          lvJSonScript := lvJsonStream.Json.O['script'];
          if lvJSonScript <> nil then
          begin
            lvADOOpera.Connection.BeginTrans;
            try
              lvSQL := dmMain.getSQLScript(lvJSonScript);
              if lvTrace then
              begin
                lvTraceData.S['sqls[]'] := lvSQL;
              end;
              lvADOOpera.CDSProvider.ExecuteScript(lvSQL);

              lvADOOpera.Connection.CommitTrans;
            except
              lvADOOpera.Connection.RollbackTrans;
              raise;
            end;
          end else if lvJsonStream.Json.O['list'] <> nil then
          begin
            lvADOOpera.Connection.BeginTrans;
            try
              lvSQL := dmMain.getSQLScript(lvJSonScript);

              for lvItem in lvJsonStream.Json.O['list'] do
              begin
                lvSQL := '';
                if lvItem.S['sql'] <> '' then
                begin
                  lvSQL := lvItem.S['sql'];
                end else
                begin
                  lvSQL := dmMain.getSQLScript(lvJSonScript);
                end;

                if lvSQL <> '' then
                begin
                  if lvTrace then
                  begin
                    lvTraceData.S['sqls[]'] := lvSQL;
                  end;
                  lvADOOpera.CDSProvider.ExecuteScript(lvSQL);
                end;
              end;

              lvADOOpera.Connection.CommitTrans;
            except
              lvADOOpera.Connection.RollbackTrans;
              raise;
            end;
          end;
        except
          on E:Exception do
          begin
            self.StateINfo := '1003.' + DateTimeToStr(Now()) + ':lvADOOpera,执行SQL语句时出现了异常:' + e.Message;
            TFileLogger.instance.logMessage(self.StateINfo, 'ADOErr_');

            if TADOConnectionTools.checkConnectionNeedReconnect(lvConnection) then
            begin
              TFileLogger.instance.logMessage('标志释放该连接,' +  Self.StateINfo, 'ADO_ERROR_');
              dmMain.markWillFree(lvConnection, lvID);
            end;
            
            TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);

            raise;
          end;
        end;
        lvJsonStream.Clear();
        lvJsonStream.Json.O['trace'] := lvTraceData;
        lvJsonStream.setResult(True);
      finally
        lvADOOpera.setConnection(nil);
        dmMain.DBOperaPool.releaseObject(lvADOOpera);
      end;
    finally                                          
      self.StateINfo := '1003.' + DateTimeToStr(Now()) + ':lvADOOpera.ADOConnection,准备归还';
      //归还到连接池
      dmMain.endUseADOConnection(lvID, lvConnection);
      self.StateINfo := '1003.' + DateTimeToStr(Now()) + ':lvADOOpera.ADOConnection,归还成功';
    end;
  except
    on e:Exception do
    begin
      lvJsonStream.Clear();
      lvJsonStream.setResult(False);
      lvJsonStream.Json.O['trace'] := lvTraceData;
      lvJsonStream.setResultMsg(e.Message);
    end;
  end;
end;

procedure TClientContext.executeSyncBillINfo(const pvDataObject: TObject);
var
  lvJsonStream:TJSonStream;
  lvFile, lvMsg:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID, lvType:String;
  lvADOOpera:TADOOperator;
  lvJSonScript, lvItem:ISuperObject;
  lvScript:TScriptMgr;
  lvWithTrans, lvTrace:Boolean;
  lvTraceData:ISuperObject;
  lvConnection:TADOConnection;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    lvTraceData := SO();
    lvID := 'main';
    if lvJsonStream.Json.S['config.dbid'] <> '' then
    begin
      lvID := lvJsonStream.Json.S['config.dbid'];
    end;
    lvTrace := lvJsonStream.Json.B['config.trace'];
    lvConnection := dmMain.beginUseADOConnection(lvID);
    try
      lvADOOpera := dmMain.DBOperaPool.borrowObject as TADOOperator;
      try
        try
          lvADOOpera.setConnection(lvConnection);
//          lvADOOpera.ReOpen;
//          self.StateINfo :=
//            Format('1005.lvADOOpera打开连接成功,准备执行SQL语句,超时设置[%d]', [lvADOOpera.Connection.CommandTimeout]);

          lvADOOpera.Connection.BeginTrans;
          try
            lvADOOpera.TraceData := lvTraceData;
            
            innerExecuteSyncBillINfo(lvJsonStream.Json.O['sync.info'], lvTraceData, lvADOOpera);
            
            lvADOOpera.Connection.CommitTrans;
          except
            lvADOOpera.Connection.RollbackTrans;
            raise;
          end;
        except
          on E:Exception do
          begin
            self.StateINfo := '2001.' + DateTimeToStr(Now()) + ':lvADOOpera,执行executeSyncBillINfo时出现了异常:' + e.Message;
            TFileLogger.instance.logMessage(self.StateINfo, 'ADOErr_');

            if TADOConnectionTools.checkConnectionNeedReconnect(lvConnection) then
            begin
              TFileLogger.instance.logMessage('标志释放该连接,' +  Self.StateINfo, 'ADO_ERROR_');
              dmMain.markWillFree(lvConnection, lvID);
            end;
            TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);
            raise;
          end;
        end;
        lvJsonStream.Clear();
        lvJsonStream.Json.O['trace'] := lvTraceData;
        lvJsonStream.setResult(True);
      finally
        lvADOOpera.setConnection(nil);
        dmMain.DBOperaPool.releaseObject(lvADOOpera);
      end;
    finally
      self.StateINfo := '1005.' + DateTimeToStr(Now()) + ':lvADOOpera.ADOConnection,准备归还';
      //归还到连接池
      dmMain.endUseADOConnection(lvID, lvConnection);
      self.StateINfo := '1005.' + DateTimeToStr(Now()) + ':lvADOOpera.ADOConnection,归还成功';
    end;
  except
    on e:Exception do
    begin
      lvJsonStream.Clear();
      lvJsonStream.setResult(False);
      lvJsonStream.Json.O['trace'] := lvTraceData;
      lvJsonStream.setResultMsg(e.Message);
    end;
  end;  
end;

procedure TClientContext.innerExecuteSyncBillINfo(const pvINfo: ISuperObject;
    pvTraceData: ISuperObject; pvADOOperator: TADOOperator);
var
  lvCDS:TClientDataSet;
  lvTempStr, lvMasterKey:String;
begin
  if pvINfo = nil then exit;
  lvMasterKey := pvINfo.S['key'];
  if lvMasterKey = '' then exit;


  lvCDS := TClientDataSet.Create(nil);
  try
    lvCDS.Data := pvADOOperator.CDSProvider.QueryData('SELECT * FROM sync_INfoState WHERE FMasterKey = ''' + lvMasterKey + '''');
    if lvCDS.RecordCount = 0 then
    begin
      lvCDS.Append;
      lvCDS.FieldByName('FKey').AsString :=CreateClassID;
      lvCDS.FieldByName('FMasterKey').AsString := lvMasterKey;
    end else
    begin
      lvCDS.Edit;
    end;

    lvTempStr := pvINfo.S['code'];
    if lvTempStr <> '' then
      lvCDS.FieldByName('FBillCode').AsString := lvTempStr;

    lvTempStr := pvINfo.S['caption'];
    if lvTempStr <> '' then
      lvCDS.FieldByName('FBillCaption').AsString := lvTempStr;

    lvTempStr := pvINfo.S['billdate'];
    if lvTempStr <> '' then
    begin
      try
        lvCDS.FieldByName('FBillDate').AsDateTime := StrToDateTime(lvTempStr);
      except
      end;
    end;

    //下载信息
    lvTempStr := pvINfo.S['downstate'];
    if lvTempStr <> '' then
    begin
      lvCDS.FieldByName('FDownState').AsString := lvTempStr;

      lvTempStr := pvINfo.S['downmsg'];
      lvCDS.FieldByName('FDownMsg').AsString := lvTempStr;

      lvTempStr := pvINfo.S['syncID'];
      if lvTempStr <> '' then
        lvCDS.FieldByName('FDownID').AsString := lvTempStr;


      lvTempStr := pvINfo.S['organKey'];
      if lvTempStr <> '' then
        lvCDS.FieldByName('FDownOrganKey').AsString := lvTempStr;

      lvTempStr := pvINfo.S['organcode'];
      if lvTempStr <> '' then
        lvCDS.FieldByName('FDownOrganCode').AsString := lvTempStr;

      lvTempStr := pvINfo.S['organname'];
      if lvTempStr <> '' then
        lvCDS.FieldByName('FDownOrganName').AsString := lvTempStr;

      lvCDS.FieldByName('FDownTime').AsDateTime := Now();
    end;


    //上传信息
    lvTempStr := pvINfo.S['uploadstate'];
    if lvTempStr <> '' then
    begin
      lvCDS.FieldByName('FUploadState').AsString := lvTempStr;

      lvTempStr := pvINfo.S['uploadmsg'];
      lvCDS.FieldByName('FUploadMsg').AsString := lvTempStr;

      lvTempStr := pvINfo.S['syncID'];
      lvCDS.FieldByName('FUploadID').AsString := lvTempStr;


      lvTempStr := pvINfo.S['organKey'];
      if lvTempStr <> '' then
        lvCDS.FieldByName('FUploadOrganKey').AsString := lvTempStr;

      lvTempStr := pvINfo.S['organcode'];
      if lvTempStr <> '' then
        lvCDS.FieldByName('FUploadOrganCode').AsString := lvTempStr;

      lvTempStr := pvINfo.S['organname'];
      if lvTempStr <> '' then
        lvCDS.FieldByName('FUploadOrganName').AsString := lvTempStr;

      lvCDS.FieldByName('FUploadTime').AsDateTime := Now();
    end;

    lvCDS.Post;

    pvADOOperator.ExecuteApplyUpdateCDS('sync_INfoState', 'FKey', lvCDS);

  finally
    lvCDS.Free;
  end;
end;

end.
