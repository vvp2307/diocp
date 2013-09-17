unit uClientContext;

interface

uses
  Windows, JwaWinsock2, uBuffer, SyncObjs, Classes, SysUtils,
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

  end;

implementation

uses
  uCRCTools, Math, uUniOperator, uUniPool, UntCobblerUniPool;





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

    //上传文件
    if lvCmdIndex= 1001 then
    begin
      lvID := lvJsonStream.Json.S['config.accountID'];
      if lvID = '' then
      begin
        raise Exception.Create('没有指定帐套ID(config.accountID)');
      end;
      lvSQL := lvJsonStream.Json.S['script.sql'];
      if lvSQL = '' then
      begin
        raise Exception.Create('没有指定要执行的SQL!');
      end;

      lvPoolObj := TUniPool.getConnObject(lvID);
      try
        lvPoolObj.checkConnect;
        //从连接池中借用
        lvDBDataOperator := TUniOperator.Create;
        try

          lvDBDataOperator.Connection := lvPoolObj.ConnObj;
          self.StateINfo := '借用了一个lvADOOpera,准备打开连接!';
          lvDBDataOperator.ReOpen;
          try
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
        TUniPool.releaseConnObject(lvPoolObj);
      end;
      //回写数据
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

end.
