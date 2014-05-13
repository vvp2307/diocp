unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uIOCPConsole, uIOCPJSonStreamDecoder, uIOCPJSonStreamEncoder,
  ExtCtrls, ComCtrls, ActnList, Menus, ImgList, uBuffer,
  Grids, ADODB, DBClient, ComObj, ActiveX, System.Actions;

type
  TfrmMain = class(TForm)
    btnService: TButton;
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    actlstMain: TActionList;
    ilMain: TImageList;
    pmTryIcon: TPopupMenu;
    mniShowMain: TMenuItem;
    N3: TMenuItem;
    mniStartService: TMenuItem;
    actStartService: TAction;
    actStopService: TAction;
    actExit: TAction;
    mniExit: TMenuItem;
    actShowMain: TAction;
    mniStopService: TMenuItem;
    tsConfig: TTabSheet;
    lblListenPort: TLabel;
    edtPort: TEdit;
    edtWorkCount: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    btnConfigOK: TButton;
    actConfigOK: TAction;
    actConfigEdit: TAction;
    btnConfigEdit: TButton;
    tsClientINfo: TTabSheet;
    lstClientINfo: TListView;
    actRefreshClientINfo: TAction;
    pnlClientINfoOperator: TPanel;
    btnRefreshClientINfo: TButton;
    tsMoniter: TTabSheet;
    mniRefreshClientINfo: TMenuItem;
    btn1: TButton;
    procedure actConfigEditExecute(Sender: TObject);
    procedure actConfigOKExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actRefreshClientINfoExecute(Sender: TObject);
    procedure actShowMainExecute(Sender: TObject);
    procedure actStartServiceExecute(Sender: TObject);
    procedure actStopServiceExecute(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btnDiscountAllClientClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FBuffer:TBufferLink;
    FIOCPConsole: TIOCPConsole;
    FDecoder:TIOCPJSonStreamDecoder;
    FEncoder:TIOCPJSonStreamEncoder;
    procedure refreshState;
    procedure DoConfigEdit(pvEditing:Boolean);
    procedure processTester;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uIOCPCentre, uClientContext, //uMemPool,
  uFMIOCPDebugINfo,
  uAppJSonConfig,
  FileLogger;
                              
{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  
  pgcMain.ActivePageIndex := 0;
  FBuffer := TBufferLink.Create;
  FDecoder := TIOCPJSonStreamDecoder.Create;
  FEncoder := TIOCPJSonStreamEncoder.Create;
  FIOCPConsole := TIOCPConsole.Create();

  //×¢²áÀ©Õ¹¿Í»§¶ËÀà
  TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

  //×¢²á½âÂëÆ÷
  TIOCPContextFactory.instance.registerDecoder(FDecoder);

  //×¢²á±àÂëÆ÷
  TIOCPContextFactory.instance.registerEncoder(FEncoder);

  with TFMIOCPDebugINfo.Create(Self) do
  begin
    Parent := tsMoniter;
    Align := alClient;
    IOCPConsole := FIOCPConsole;
    Active := True;
  end;

  refreshState;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  DoConfigEdit(False);
  TAppJSonConfig.instance.Reload;
  if TAppJSonConfig.instance.Config.S['config.port'] <> '' then
    edtPort.Text := TAppJSonConfig.instance.Config.S['config.port'];

  edtWorkCount.Text := IntToStr(TAppJSonConfig.instance.Config.I['config.workcount']);
  actStartService.Execute;
end;

destructor TfrmMain.Destroy;
begin
  FBuffer.Free;
  FIOCPConsole.close;
  FDecoder.Free;
  FEncoder.Free;
  FreeAndNil(FIOCPConsole);
  inherited Destroy;
end;

procedure TfrmMain.DoConfigEdit(pvEditing: Boolean);
var
  lvIsEditing:Boolean;
begin
  lvIsEditing := pvEditing;
  actConfigOK.Enabled := lvIsEditing and (not FIOCPConsole.Active);
  actConfigEdit.Enabled := (not lvIsEditing) and (not FIOCPConsole.Active);
  edtWorkCount.Enabled := actConfigOK.Enabled;
  edtPort.Enabled := actConfigOK.Enabled;
end;

procedure TfrmMain.actConfigEditExecute(Sender: TObject);
begin
  DoConfigEdit(true);
end;

procedure TfrmMain.actConfigOKExecute(Sender: TObject);
begin
  TAppJSonConfig.instance.Reload;
  TAppJSonConfig.instance.Config.I['config.port'] :=StrToInt(edtPort.Text);
  TAppJSonConfig.instance.Config.I['config.workcount'] := StrToInt(edtWorkCount.Text);
  TAppJSonConfig.instance.Save2File;
  DoConfigEdit(False);
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
   actStopService.Execute;
   Application.Terminate;
end;

procedure TfrmMain.actRefreshClientINfoExecute(Sender: TObject);
var
  lvList:TList;
  i: Integer;
  lvClient:TClientContext;
  lvItem:TListItem;

  lvConnectINfo:TStrings;
begin
  lstClientINfo.Items.Clear;
  lvList:=TList.Create;
  lvConnectINfo := TStringList.Create;
  try
    TIOCPContextFactory.instance.IOCPContextPool.getUsingList(lvList);
    for i := 0 to lvList.Count - 1 do
    begin
      lvClient := TClientContext(lvList[i]);
      lvItem := lstClientINfo.Items.Add;
      lvItem.Caption := lvClient.RemoteAddr;
      lvItem.SubItems.Add(IntToStr(lvClient.RemotePort));
      lvItem.SubItems.Add(lvClient.StateINfo);

      lvConnectINfo.Add('=======================================');
      lvConnectINfo.Add(lvItem.Caption);
      lvConnectINfo.Add(IntToStr(lvClient.RemotePort));
      lvConnectINfo.Add(lvClient.StateINfo);
    end;

    lvConnectINfo.SaveToFile(ExtractFilePath(ParamStr(0)) + 'connectINfo.txt');
  finally
    lvConnectINfo.Free;
    lvList.Free;
  end;
end;

procedure TfrmMain.actShowMainExecute(Sender: TObject);
begin
  if not Visible then Show;

  Self.BringToFront();
end;

procedure TfrmMain.actStartServiceExecute(Sender: TObject);
begin
  if not FIOCPConsole.Active then
  begin
    FIOCPConsole.Port := StrToInt(edtPort.Text);
    FIOCPConsole.WorkerCount := StrToInt(edtWorkCount.Text);
    FIOCPConsole.setSystemSocketHeartState(false);
    FIOCPConsole.open;
  end;  
  refreshState;
  DoConfigEdit(False);
end;

procedure TfrmMain.refreshState;
begin
  actStartService.Enabled := not FIOCPConsole.Active;
  actStopService.Enabled := not actStartService.Enabled;

  if actStartService.Enabled then
    btnService.Action := actStartService
  else
    btnService.Action := actStopService;

end;

procedure TfrmMain.actStopServiceExecute(Sender: TObject);
begin
  FIOCPConsole.close;
  refreshState;
  DoConfigEdit(False);
end;

procedure TfrmMain.btnDiscountAllClientClick(Sender: TObject);
begin
  FIOCPConsole.DisconnectAllClientContext;
end;


function f(p: Pointer): Integer;
begin
  //TfrmMain(p).processTester_CDSOperatorError;
end;

procedure TfrmMain.btn1Click(Sender: TObject);
var
  lvSource, lvDest:PAnsiChar;
begin
  lvSource := '1234567890';
  getMem(lvDest, 10);
  CopyMemory(lvDest, Pointer(Cardinal(lvSource) + 2), 8);

  ShowMessage(lvDest);
end;

procedure TfrmMain.btnOpenClick(Sender: TObject);
var
  i, iCount: Integer;
  tid: Cardinal; 
begin
//  iCount := StrToInt(edtThreadCount.Text);
//  for i:=1 to iCount do
//  begin
//    BeginThread(nil,0,f,Self,0,tid);
//  end;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
end;

procedure TfrmMain.processTester;
var
  i, j:Integer;
begin
  try
    i:= 0;
    j:= 0;
    while j < 100 do
    begin
      Inc(j);
      
    end;
  except
    on E:Exception do
    begin
      TFileLogger.instance.logErrMessage(IntToStr(i) + '---' + e.Message);
    end;
  end;
end;

initialization
  TFileLogger.instance.setAddThreadINfo(True);

end.
