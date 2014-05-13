unit uClientContext;

interface

uses
  Windows, Winsock2, uBuffer, SyncObjs, Classes, SysUtils,
  uIOCPCentre, JSonStream, FileLogger;

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
  uFrameConfig, uCRCTools, Math, uFileOperaHandler;





procedure TClientContext.dataReceived(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile, lvNameSpace:String;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    lvNameSpace := lvJsonStream.Json.S['cmd.namespace'];
    TFileLogger.instance.logDebugMessage(lvNameSpace);
    if SameText(lvNameSpace,'fileOpera') then
    begin
      TFileOperaHandler.Execute(lvJsonStream);
      writeObject(lvJsonStream);
    end else
    begin
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
