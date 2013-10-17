unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uIOCPConsole, uIOCPJSonStreamDecoder, uIOCPJSonStreamEncoder,
  ExtCtrls, superobject,
  ComCtrls, UniDacVcl, SQLServerUniProvider, MySQLUniProvider;

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
    procedure btnConnectionConfigClick(Sender: TObject);
    procedure btnDiscountAllClientClick(Sender: TObject);
    procedure btnIOCPAPIRunClick(Sender: TObject);
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

var
  frmMain: TfrmMain;

implementation

uses
  uIOCPCentre, uClientContext, uBuffer, uMemPool, uIOCPDebugger,
  uFMIOCPDebugINfo, Uni, uUniConfigTools, uUniPool;

{$R *.dfm}

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

  //注册扩展客户端类
  TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

  //注册解码器
  TIOCPContextFactory.instance.registerDecoder(FDecoder);

  //注册编码器
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
    lvConnectDialog.Caption := '配置帐套[' +txtAccount.Text + ']数据库连接';
    lvConnectDialog.ConnectButton := '确定';
    lvConnectDialog.CancelButton := '取消';

    lvConnectDialog.SavePassword := true;
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
  TUniPool.reset;
  if not FIOCPConsole.Active then
  begin
    //注册扩展客户端类
    TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

    //注册解码器
    TIOCPContextFactory.instance.registerDecoder(FDecoder);

    //注册编码器
    TIOCPContextFactory.instance.registerEncoder(FEncoder);

    //FIOCPConsole.WorkerCount := 1;
    FIOCPConsole.Port := StrToInt(edtPort.Text);
    FIOCPConsole.open;
  end;

  btnIOCPAPIRun.Enabled := not FIOCPConsole.Active;
  btnStopSevice.Enabled := not btnIOCPAPIRun.Enabled;

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

end.

