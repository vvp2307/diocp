unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdTCPConnection, IdTCPClient, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, IdContext, ExtCtrls, IdCustomHTTPServer,
  IdHTTPServer, IdHTTP;

type
  TTester=class(TThread)
  public
    procedure execute;override;
  end;

type
  TForm1 = class(TForm)
    IdTCPServer1: TIdTCPServer;
    IdTCPClient1: TIdTCPClient;
    btnStart: TButton;
    btnOpenOnce: TButton;
    btnCloseOnce: TButton;
    edtCount: TEdit;
    btnDoTester: TButton;
    lblFCount: TLabel;
    btnDoStop: TButton;
    tmr1: TTimer;
    IdHTTPServer1: TIdHTTPServer;
    IdHTTP1: TIdHTTP;
    btnDoHttpTester: TButton;
    btnHttpStart: TButton;
    btnOpenUrl: TButton;
    btnTesterStop: TButton;
    edtUrl: TComboBox;
    procedure btnCloseOnceClick(Sender: TObject);
    procedure btnDoHttpTesterClick(Sender: TObject);
    procedure btnDoStopClick(Sender: TObject);
    procedure btnDoTesterClick(Sender: TObject);
    procedure btnHttpStartClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnOpenOnceClick(Sender: TObject);
    procedure btnOpenUrlClick(Sender: TObject);
    procedure btnTesterStopClick(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext; ARequestInfo:
        TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure tmr1Timer(Sender: TObject);
  private
    { Private declarations }
    FThreadList: TList;
    procedure refreshState;
  public
    constructor Create(AOwner:TComponent);override;
    destructor Destroy; override;

  end;

type
  THttpTester = class(TThread)
  public
    procedure execute;override;
  end;

type
  THttpUrlTester = class(TThread)
  private
    FUrl: String;
  public
    constructor Create(CreateSuspended: Boolean; const AUrl: String);
    procedure execute;override;
  end;

var
  Form1: TForm1;

  __count:Integer;
  __errCount:Integer;
  __tickcount:Cardinal;

implementation

{$R *.dfm}



destructor TForm1.Destroy;
begin
  btnDoStop.Click;
  FreeAndNil(FThreadList);
  inherited Destroy;
end;

procedure TForm1.btnCloseOnceClick(Sender: TObject);
begin
  IdTCPClient1.Disconnect;
  refreshState;
end;

procedure TForm1.btnDoStopClick(Sender: TObject);
begin
  while FThreadList.Count > 0 do
  begin
    TThread(FThreadList[0]).Terminate;
    TThread(FThreadList[0]).WaitFor;
    TThread(FThreadList[0]).Free;
    FThreadList.Delete(0);
  end;
end;

procedure TForm1.btnDoTesterClick(Sender: TObject);
var
  i:Integer;
begin
  btnDoStop.Click;
  for i := 1 to StrToInt(edtCount.Text) do
  begin
    FThreadList.Add(TTester.Create(false));
  end;

end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
  IdTCPServer1.Active := true;
  IdHTTPServer1.Active := true;
  refreshState;

end;

procedure TForm1.btnOpenOnceClick(Sender: TObject);
begin


  try
    IdHTTP1.Get('http://127.0.0.1:8083/?time='+ FloatToStr(Now()));
  except
    on e:Exception do
    begin
    ShowMessage('Http打开错误!' + sLineBreak + e.Message);
    end;
  end;

  try
    IdTCPClient1.Connect;
  except
    on e:Exception do
    begin
    ShowMessage('tcp打开错误!' + sLineBreak + e.Message);
    end; 
  end;



  refreshState;
end;

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited;
  FThreadList := TList.Create();
  refreshState;
end;

procedure TForm1.btnDoHttpTesterClick(Sender: TObject);
var
  i:Integer;
begin
  btnDoStop.Click;
  for i := 1 to StrToInt(edtCount.Text) do
  begin
    FThreadList.Add(THttpTester.Create(false));
  end;
end;

procedure TForm1.btnHttpStartClick(Sender: TObject);
var
  i:Integer;
begin
  btnDoStop.Click;
  for i := 1 to StrToInt(edtCount.Text) do
  begin
    FThreadList.Add(THttpUrlTester.Create(false, edtUrl.Text));
  end;
  __count := 0;
  __errCount := 0;
  __tickcount := GetTickCount;
end;

procedure TForm1.btnOpenUrlClick(Sender: TObject);
var
  lvRespData: TStringStream;
begin
  lvRespData := TStringStream.Create('');
  try
    IdHTTP1.Get(edtUrl.Text, lvRespData);
    ShowMessage(lvRespData.DataString);
  finally
    lvRespData.Free;
  end;
end;

procedure TForm1.btnTesterStopClick(Sender: TObject);
begin
  while FThreadList.Count > 0 do
  begin
    TThread(FThreadList[0]).Terminate;
    TThread(FThreadList[0]).WaitFor;
    TThread(FThreadList[0]).Free;
    FThreadList.Delete(0);
  end;
end;

procedure TForm1.IdHTTPServer1CommandGet(AContext: TIdContext; ARequestInfo:
    TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.ContentText := FormatDateTime('yyyy-MM-dd hh:nn:ss', Now());
end;

procedure TForm1.IdTCPServer1Execute(AContext: TIdContext);
begin
  ;
end;

procedure TForm1.refreshState;
begin
  btnStart.Enabled := not IdTCPServer1.Active;

  if not btnStart.Enabled then
  begin
    btnStart.Caption := '暴力服务端已经开启，接收9933连接';
  end;

  btnDoTester.Enabled := not btnStart.Enabled;
  btnDoHttpTester.Enabled := btnDoTester.Enabled;
  btnDoStop.Enabled := btnDoTester.Enabled;

  btnOpenOnce.Enabled := not IdTCPClient1.Connected;
  btnCloseOnce.Enabled := not btnOpenOnce.Enabled;



end;

procedure TForm1.tmr1Timer(Sender: TObject);
var
  lvTime:Cardinal;
begin
  lvTime := Trunc((GetTickCount - __tickcount)/1000);
  if lvTime = 0 then exit;  
  lblFCount.Caption := Format('成功次数:%d,失败次数:%d, 速度:%d /每秒',
    [__count, __errCount,
       Trunc(__count/lvTime)
    ]);
end;

{ TTester }

procedure TTester.execute;
var
  lvTcp:TIdTCPClient;
begin
  inherited;

  lvTcp := TIdTCPClient.Create(nil);
  try
    lvTcp.Host := '127.0.0.1';
    lvTcp.Port := 9933;
    while not self.Terminated do
    begin
      try
        lvTcp.Connect;
        Sleep(10);
        lvTcp.Disconnect;

        InterlockedIncrement(__count);
      except
        InterlockedIncrement(__errCount);
        Sleep(100);
      end;
    end;

  finally
    lvTcp.Free;
  end;

end;

{ THttpTester }

procedure THttpTester.execute;
var
  lvTcp:TIdHTTP;
begin
  inherited;

  lvTcp := TIdHTTP.Create(nil);
  try
    while not self.Terminated do
    begin
      try
        lvTcp.Get('http://127.0.0.1:8083/?time='+ FloatToStr(Now()));
        Sleep(10);

        InterlockedIncrement(__count);
      except
        InterlockedIncrement(__errCount);
        Sleep(100);
      end;
    end;

  finally
    lvTcp.Free;
  end;

end;

constructor THttpUrlTester.Create(CreateSuspended: Boolean; const AUrl: String);
begin
  inherited Create(CreateSuspended);
  FUrl := AUrl;
end;

{ THttpUrlTester }

procedure THttpUrlTester.execute;
var
  lvTcp:TIdHTTP;
  lvRespData: TStringStream;
  lvDateTime:TDateTime;
begin
  lvRespData := TStringStream.Create('');
  lvTcp := TIdHTTP.Create(nil);
  try
    while not self.Terminated do
    begin
      try
        lvRespData.Size := 0;
        lvTcp.Get(FUrl + '?time='+ FloatToStr(Now()), lvRespData);
        if lvTcp.ResponseCode = 200 then
        begin
          InterlockedIncrement(__count);
        end else
        begin
          InterlockedIncrement(__errCount);
        end;
        Sleep(1);

//        lvDateTime := StrToDateTime(trim(lvRespData.DataString));
//        if lvDateTime = 0 then raise Exception.Create('失败!');


      except
        InterlockedIncrement(__errCount);
        Sleep(100);
      end;
    end;

  finally
    lvRespData.Free;
    lvTcp.Free;
  end;

end;

end.
