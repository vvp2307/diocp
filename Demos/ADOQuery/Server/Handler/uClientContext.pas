unit uClientContext;

interface

uses
  Windows,  uBuffer, SyncObjs, Classes, SysUtils,
  uIOCPCentre, FileLogger, ADODB, uADOTools, ComObj, ActiveX;

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
  JSonStream, udmMain;



procedure TClientContext.dataReceived(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile:String;
  lvCmdIndex:Cardinal;
  lvXMLData, lvEncodeData:AnsiString;
  lvSQL, lvDebug:String;
  lvStream:TMemoryStream;
  lvADOQuery:TADOQuery;
  lvCounter:Integer;
begin
  lvJsonStream := TJSonStream(pvDataObject);

  lvCmdIndex := lvJsonStream.JSon.I['cmdIndex'];

  //echo测试
  if lvCmdIndex= 1000 then
  begin
    //回写数据
    writeObject(lvJsonStream);
  end else if lvCmdIndex = 1001 then
  begin  //根据sql获取一个数据，放在Stream中
    try
      lvSQL := lvJsonStream.Json.S['sql'];
      lvJsonStream.Clear();
      CoInitialize(nil);
      lvADOQuery:=TADOQuery.Create(nil);
      try
        lvADOQuery.Connection := dmMain.conMain;
        lvCounter := GetTickCount;
        lvADOQuery.SQL.Clear;
        lvADOQuery.SQL.Text := lvSQL;
        lvADOQuery.Open;
        lvCounter := GetTickCount - lvCounter;

        lvDebug := '打开SQL(ADOQuery.Open)耗时:' + intToStr(lvCounter) + sLineBreak;

        lvCounter := GetTickCount;
        lvStream := TADOTools.saveToStream(lvADOQuery);
        try
          lvCounter := GetTickCount - lvCounter;
          lvDebug := 'ADO流数据大小:' + FloatToStr(lvStream.Size/1000.00) + 'KB' + sLineBreak + lvDebug + '打包ADOQuery到流耗时:' + intToStr(lvCounter) + sLineBreak;
          lvStream.Position := 0;
          lvJsonStream.Json.S['debug'] := lvDebug;
          lvJsonStream.Stream.CopyFrom(lvStream, lvStream.Size);
          lvJsonStream.setResult(True);
        finally
          lvStream.Free;
        end;
      finally
        lvADOQuery.Free;
      end;
    except
      on e:Exception do
      begin
        lvJsonStream.Clear();
        lvJsonStream.setResult(False);
        lvJsonStream.setResultMsg(e.Message);
      end;
    end;
    
    //回写数据
    writeObject(lvJsonStream);

  end else
  begin
    //返回数据
    writeObject(lvJsonStream);
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
