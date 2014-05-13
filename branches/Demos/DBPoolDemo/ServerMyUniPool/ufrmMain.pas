unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uIOCPConsole, uIOCPJSonStreamDecoder, uIOCPJSonStreamEncoder,
  ExtCtrls, superobject, ActiveX,
  ComCtrls, UniDacVcl, SQLServerUniProvider, MySQLUniProvider, uUniOperator;

type
  TfrmMain = class(TForm)
    pgcMain: TPageControl;
    tsBase: TTabSheet;
    tsMoniter: TTabSheet;
    edtPort: TEdit;
    btnIOCPAPIRun: TButton;
    btnStopSevice: TButton;
    tsConfig: TTabSheet;
    btnConnectionConfig: TButton;
    lblAccountID: TLabel;
    txtAccount: TComboBox;
    tsTester: TTabSheet;
    mmoSQL: TMemo;
    mmoSQL2: TMemo;
    btnOpen: TButton;
    btn1: TButton;
    procedure btn1Click(Sender: TObject);
    procedure btnConnectionConfigClick(Sender: TObject);
    procedure btnDiscountAllClientClick(Sender: TObject);
    procedure btnIOCPAPIRunClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnStopSeviceClick(Sender: TObject);
  private
    { Private declarations }
    FIOCPConsole: TIOCPConsole;
    FDecoder:TIOCPJSonStreamDecoder;
    FEncoder:TIOCPJSonStreamEncoder;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

type
  TThreadTester = class(TThread)
  public
    procedure execute;override;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uIOCPCentre, uClientContext, uBuffer, uMemPool, uIOCPDebugger,
  uFMIOCPDebugINfo, Uni, uUniConfigTools, FileLogger, uUniDACTools;

{$R *.dfm}

var
  __sql01:string; __sql02:string;

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDecoder := TIOCPJSonStreamDecoder.Create;
  FEncoder := TIOCPJSonStreamEncoder.Create;

  FIOCPConsole := TIOCPConsole.Create();

  with TFMIOCPDebugINfo.Create(Self) do
  begin
    Parent := tsMoniter;
    Align := alClient;
    IOCPConsole := FIOCPConsole;
    Active := True;
  end;

  //×¢²áÀ©Õ¹¿Í»§¶ËÀà
  TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

  //×¢²á½âÂëÆ÷
  TIOCPContextFactory.instance.registerDecoder(FDecoder);

  //×¢²á±àÂëÆ÷
  TIOCPContextFactory.instance.registerEncoder(FEncoder);
end;

destructor TfrmMain.Destroy;
begin
  FIOCPConsole.close;
  FDecoder.Free;
  FEncoder.Free;
  FreeAndNil(FIOCPConsole);
  inherited Destroy;
end;

procedure TfrmMain.btn1Click(Sender: TObject);
begin
   TThreadTester.Create;;
end;

procedure TfrmMain.btnConnectionConfigClick(Sender: TObject);
var
  lvConn, lvNewConn:TUniConnection;
  lvConnectDialog:TUniConnectDialog;
begin
  lvConn := TUniConnection.Create(nil);
  lvConnectDialog := TUniConnectDialog.Create(nil);
  try   
    lvConn.ConnectString := TUniConfigTools.getConnectionString(txtAccount.Text);
    lvConn.ConnectDialog :=lvConnectDialog;
    lvConnectDialog.StoreLogInfo := false;
    lvConnectDialog.OptionChanged;
    lvConnectDialog.Caption := 'ÅäÖÃÕÊÌ×[' +txtAccount.Text + ']Êý¾Ý¿âÁ¬½Ó';
    lvConnectDialog.ConnectButton := 'È·¶¨';
    lvConnectDialog.CancelButton := 'È¡Ïû';

    //lvConnectDialog.SavePassword := true;
    lvConnectDialog.StoreLogInfo := true;
    if lvConn.ConnectDialog.Execute then
    begin
      lvNewConn := TUniConnection.Create(nil);
      try
        lvNewConn.ConnectString := lvConn.ConnectString;
        lvNewConn.LoginPrompt := False;
        lvNewConn.Connect;
      finally
        lvNewConn.Free;
      end;
      TUniConfigTools.saveConnectionString(txtAccount.Text, lvConn.ConnectString);
    end;
  finally
    lvConn.Free;
    lvConnectDialog.Free;
  end;
end;

procedure TfrmMain.btnDiscountAllClientClick(Sender: TObject);
begin
  FIOCPConsole.DisconnectAllClientContext;
end;

procedure TfrmMain.btnIOCPAPIRunClick(Sender: TObject);
begin
  TUniDACTools.resetPool;
  if not FIOCPConsole.Active then
  begin
    //×¢²áÀ©Õ¹¿Í»§¶ËÀà
    TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

    //×¢²á½âÂëÆ÷
    TIOCPContextFactory.instance.registerDecoder(FDecoder);

    //×¢²á±àÂëÆ÷
    TIOCPContextFactory.instance.registerEncoder(FEncoder);

    //FIOCPConsole.WorkerCount := 1;
    FIOCPConsole.Port := StrToInt(edtPort.Text);
    FIOCPConsole.open;
  end;

  btnIOCPAPIRun.Enabled := not FIOCPConsole.Active;
  btnStopSevice.Enabled := not btnIOCPAPIRun.Enabled;

end;

procedure TfrmMain.btnOpenClick(Sender: TObject);
var
  i: Integer;
  tid: Cardinal;
begin
  __sql01 := mmoSQL.Lines.Text;
  __sql02 := mmoSQL2.Lines.Text;
  for i:=1 to 1 do
  begin
    //BeginThread(nil,0,f,Self,0,tid);
  end;

end;

procedure TfrmMain.btnResetClick(Sender: TObject);
begin
  TIOCPDebugger.resetDebugINfo;
end;

procedure TfrmMain.btnStopSeviceClick(Sender: TObject);
begin
  FIOCPConsole.close;
  btnIOCPAPIRun.Enabled := not FIOCPConsole.Active;
  btnStopSevice.Enabled := not btnIOCPAPIRun.Enabled;
end;

procedure TThreadTester.execute;
var
  lvConn:TUniConnection;
begin
  lvConn := TUniConnection.Create(nil);  //  (lvUniPool.borrowObject);
  try
    if not lvConn.Connected then
    begin
      lvConn.LoginPrompt := false;
      lvConn.ConnectString := 'Provider Name=SQL Server;Data Source=.;Database=haoMail_DIOCP;User ID=sa;Password=sa';
      CoInitialize(nil);
      lvConn.Connect;
    end;

  finally
    //CoUninitialize;
    lvConn.Free;
    exitthread(0);
  end;
end;

end.

