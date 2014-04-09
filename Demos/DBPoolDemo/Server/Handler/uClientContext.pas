unit uClientContext;

interface

uses
  Windows, uBuffer, SyncObjs, Classes, SysUtils,
  uIOCPCentre, JSonStream;

type
  TClientContext = class(TIOCPClientContext)
  protected
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    procedure DoOnWriteBack; override;

  public
    /// <summary>
    ///   数据处理
    /// </summary>
    /// <param name="pvDataObject"> (TObject) </param>
    procedure dataReceived(const pvDataObject:TObject); override;
    /// <summary>
    ///   数据处理
    /// </summary>
    /// <param name="pvDataObject"> (TObject) </param>
    procedure openScript(const pvDataObject:TObject);
    /// <summary>
    ///   数据处理
    /// </summary>
    /// <param name="pvDataObject"> (TObject) </param>
    procedure openScript1(const pvDataObject:TObject);

  end;

implementation

uses
  uCRCTools, Math, uUniOperator, uUniPool, UntCobblerUniPool, uUniDACTools;





procedure TClientContext.dataReceived(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID:String;
  lvDBDataOperator:TUniOperator;
  lvPoolObj:TUniCobbler;

begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    lvCmdIndex := lvJsonStream.JSon.I['cmdIndex'];

    //执行SQL的命令ID
    if lvCmdIndex= 1001 then
    begin
      openScript1(lvJsonStream);
      //回写数据给客户端
      writeObject(lvJsonStream);
    end else
    begin
      //返回数据
      writeObject(lvJsonStream);
    end;
  except
    on E:Exception do
    begin
      lvJsonStream.Clear();
      lvJsonStream.setResult(False);
      lvJsonStream.setResultMsg(e.Message);
      writeObject(lvJsonStream);
    end;

  end;
end;

procedure TClientContext.openScript(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID:String;
  lvDBDataOperator:TUniOperator;
  lvPoolObj:TUniCobbler;

begin
  lvJsonStream := TJSonStream(pvDataObject);

  //客户端传递过来的帐套ID
  lvID := lvJsonStream.Json.S['config.accountID'];
  if lvID = '' then
  begin
    raise Exception.Create('没有指定帐套ID(config.accountID)');
  end;

  //客户端指定要执行的SQL
  lvSQL := lvJsonStream.Json.S['script.sql'];

  //客户端指定要执行的SQL
  lvSQL := lvJsonStream.Json.S['script.sql'];
  if lvSQL = '' then
  begin
    raise Exception.Create('没有指定要执行的SQL!');
  end;

  //通过帐套ID获取一个连接池对象
  lvPoolObj := TUniPool.getConnObject(lvID);
  try
    //打开连接
    lvPoolObj.checkConnect;

    //Uni数据库操作对象<可以改用对象池效率更好>
    lvDBDataOperator := TUniOperator.Create;
    try
      //设置使用的连接池
      lvDBDataOperator.Connection := lvPoolObj.ConnObj;
      self.StateINfo := '借用了一个lvADOOpera,准备打开连接!';
      try
        //获取一个查询的数据
        lvXMLData := lvDBDataOperator.CDSProvider.QueryXMLData(lvSQL);
        self.StateINfo := 'lvADOOpera,执行SQL语句完成,准备回写数据';
      except
        raise;
      end;

      lvJsonStream.Clear();
      lvJsonStream.Stream.WriteBuffer(lvXMLData[1], Length(lvXMLData));
      lvJsonStream.setResult(True);
    finally
      lvDBDataOperator.Free;
    end;
  finally
    //归还连接池
    TUniPool.releaseConnObject(lvPoolObj);
  end;

end;

procedure TClientContext.DoConnect;
begin
  inherited;
end;

procedure TClientContext.DoDisconnect;
begin
  inherited;
end;



procedure TClientContext.DoOnWriteBack;
begin
  inherited;
end;

procedure TClientContext.openScript1(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvID:String;
  lvDBDataOperator:TUniOperator;

begin
  lvJsonStream := TJSonStream(pvDataObject);

  //客户端传递过来的帐套ID
  lvID := lvJsonStream.Json.S['config.accountID'];
  if lvID = '' then
  begin
    raise Exception.Create('没有指定帐套ID(config.accountID)');
  end;

  //客户端指定要执行的SQL
  lvSQL := lvJsonStream.Json.S['script.sql'];

  //客户端指定要执行的SQL
  lvSQL := lvJsonStream.Json.S['script.sql'];
  if lvSQL = '' then
  begin
    raise Exception.Create('没有指定要执行的SQL!');
  end;

  with TUniDACTools.createCDS(lvSQL, lvID) do
  try
    self.StateINfo := '借用了一个lvADOOpera,准备打开连接!';
    try
      //获取一个查询的数据
      lvXMLData := lvDBDataOperator.CDSProvider.QueryXMLData(lvSQL);
      self.StateINfo := 'lvADOOpera,执行SQL语句完成,准备回写数据';
    except
      raise;
    end;

    lvJsonStream.Clear();
    lvJsonStream.Stream.WriteBuffer(lvXMLData[1], Length(lvXMLData));
    lvJsonStream.setResult(True);

  finally
    Free;
  end;
//  //通过帐套ID获取一个连接池对象
//  lvPoolObj := TUniPool.getConnObject(lvID);
//  try
//    //打开连接
//    lvPoolObj.checkConnect;
//
//    //Uni数据库操作对象<可以改用对象池效率更好>
//    lvDBDataOperator := TUniOperator.Create;
//    try
//      //设置使用的连接池
//      lvDBDataOperator.Connection := lvPoolObj.ConnObj;
//      self.StateINfo := '借用了一个lvADOOpera,准备打开连接!';
//      try
//        //获取一个查询的数据
//        lvXMLData := lvDBDataOperator.CDSProvider.QueryXMLData(lvSQL);
//        self.StateINfo := 'lvADOOpera,执行SQL语句完成,准备回写数据';
//      except
//        raise;
//      end;
//
//      lvJsonStream.Clear();
//      lvJsonStream.Stream.WriteBuffer(lvXMLData[1], Length(lvXMLData));
//      lvJsonStream.setResult(True);
//    finally
//      lvDBDataOperator.Free;
//    end;
//  finally
//    //归还连接池
//    TUniPool.releaseConnObject(lvPoolObj);
//  end;

end;

end.
