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



    

  end;

implementation






procedure TClientContext.dataReceived(const pvDataObject:TObject);
var
  lvJsonStream:TJSonStream;
  lvFile, lvNameSpace:String;
begin
  lvJsonStream := TJSonStream(pvDataObject);
  try
    //直接回写
    writeObject(lvJsonStream);
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
