unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uIOCPConsole, uIOCPJSonStreamDecoder, uIOCPJSonStreamEncoder,
  ExtCtrls;

type
  TfrmMain = class(TForm)
    edtPort: TEdit;
    btnIOCPAPIRun: TButton;
    btnStopSevice: TButton;
    pnlINfo: TPanel;
    lblClientINfo: TLabel;
    lblRecvINfo: TLabel;
    lblSendINfo: TLabel;
    lblWorkCount: TLabel;
    lblMemINfo: TLabel;
    tmrTestINfo: TTimer;
    lblClientContextINfo: TLabel;
    btnConnectConfig: TButton;
    procedure btnConnectConfigClick(Sender: TObject);
    procedure btnDiscountAllClientClick(Sender: TObject);
    procedure btnIOCPAPIRunClick(Sender: TObject);
    procedure btnStopSeviceClick(Sender: TObject);
    procedure tmrTestINfoTimer(Sender: TObject);
  private
    { Private declarations }
    FIOCPConsole: TIOCPConsole;
    FDecoder:TIOCPJSonStreamDecoder;
    FEncoder:TIOCPJSonStreamEncoder;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uIOCPCentre, uClientContext, TesterINfo, uBuffer, uMemPool, udmMain;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDecoder := TIOCPJSonStreamDecoder.Create;
  FEncoder := TIOCPJSonStreamEncoder.Create;
  FIOCPConsole := TIOCPConsole.Create();

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

procedure TfrmMain.btnConnectConfigClick(Sender: TObject);
begin
  dmMain.DoConnnectionConfig;
end;

procedure TfrmMain.btnDiscountAllClientClick(Sender: TObject);
begin
  FIOCPConsole.DisconnectAllClientContext;
end;

procedure TfrmMain.btnIOCPAPIRunClick(Sender: TObject);
begin
  if not FIOCPConsole.Active then
  begin
    FIOCPConsole.WorkerCount := 1;
    FIOCPConsole.Port := StrToInt(edtPort.Text);
    FIOCPConsole.open;
    tmrTestINfo.Enabled := true;
  end;

  btnIOCPAPIRun.Enabled := not FIOCPConsole.Active;
  btnStopSevice.Enabled := not btnIOCPAPIRun.Enabled;

end;

procedure TfrmMain.btnStopSeviceClick(Sender: TObject);
begin
  FIOCPConsole.close;
  btnIOCPAPIRun.Enabled := not FIOCPConsole.Active;
  btnStopSevice.Enabled := not btnIOCPAPIRun.Enabled;
end;

procedure TfrmMain.tmrTestINfoTimer(Sender: TObject);
var
  lvCount, lvBusyCount:Integer;
begin
  lblClientINfo.Caption := '连接数:' + IntToStr(TesterINfo.__ClientContextCount);
  lblRecvINfo.Caption :=   '接收数据次数:' + IntToStr(TesterINfo.__RecvTimes);
  lblSendINfo.Caption :=   '发送数据次数:' + IntToStr(TesterINfo.__SendTimes);
  lblWorkCount.Caption :=  '工作线程:' + IntToStr(FIOCPConsole.WorkerCount);
  lblMemINfo.Caption :=   Format(
     'IO内存块池共(%d),可用(%d)',
     [TIODataMemPool.instance.getCount, TIODataMemPool.instance.getUseableCount]);

  lvCount := TIOCPContextFactory.instance.IOCPContextPool.count;
  lvBusyCount := TIOCPContextFactory.instance.IOCPContextPool.BusyCount;
  lblClientContextINfo.Caption :=   Format(
     'ClientContext池共(%d),可用(%d)',
     [lvCount, lvCount - lvBusyCount]);
end;

end.
