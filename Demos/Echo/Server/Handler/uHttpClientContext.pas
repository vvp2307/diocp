unit uHttpClientContext;

interface

uses
  Windows, JwaWinsock2, uBuffer, SyncObjs, Classes, SysUtils, uIOCPCentre;

type
  THttpClientContext = class(TIOCPClientContext)
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
  TesterINfo, JSonStream;



procedure THttpClientContext.dataReceived(const pvDataObject:TObject);
var
  lvString:TStrings;
begin
  InterlockedIncrement(TesterINfo.__RecvTimes);
  lvString := TStrings(pvDataObject);
  lvString.Clear;
  lvString.Text := FormatDateTime('yyyy-MM-dd hh:nn:ss', Now());
  writeObject(lvString);  
end;

procedure THttpClientContext.DoConnect;
begin
  inherited;
  InterlockedIncrement(TesterINfo.__ClientContextCount);
end;

procedure THttpClientContext.DoDisconnect;
begin
  inherited;
  InterlockedDecrement(TesterINfo.__ClientContextCount);
end;



procedure THttpClientContext.DoOnWriteBack;
begin
  inherited;
  InterlockedIncrement(TesterINfo.__SendTimes);
end;

end.
