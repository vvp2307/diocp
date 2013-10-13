unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uIOCPConsole, uIOCPJSonStreamDecoder, uIOCPJSonStreamEncoder,
  ExtCtrls, uZipTools, uIOCPProtocol, uFMIOCPDebugINfo, Vcl.ComCtrls, Data.DB,
  Data.Win.ADODB, uADOTools;

type
  TfrmMain = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    tsIOCPINfo: TTabSheet;
    edtPort: TEdit;
    btnIOCPAPIRun: TButton;
    btnStopSevice: TButton;
    btnConnectConfig: TButton;
    tsTester: TTabSheet;
    qryMain: TADOQuery;
    btnADOQueryTester: TButton;
    procedure btnConnectConfigClick(Sender: TObject);
    procedure btnDiscountAllClientClick(Sender: TObject);
    procedure btnIOCPAPIRunClick(Sender: TObject);
    procedure btnStopSeviceClick(Sender: TObject);
    procedure btnADOQueryTesterClick(Sender: TObject);
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
  uIOCPCentre, uClientContext, uBuffer, uMemPool, udmMain;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDecoder := TIOCPJSonStreamDecoder.Create;
  FEncoder := TIOCPJSonStreamEncoder.Create;
  FIOCPConsole := TIOCPConsole.Create();

  //×¢²áÀ©Õ¹¿Í»§¶ËÀà
  TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

  //×¢²á½âÂëÆ÷
  TIOCPContextFactory.instance.registerDecoder(FDecoder);

  //×¢²á±àÂëÆ÷
  TIOCPContextFactory.instance.registerEncoder(FEncoder);

  TFMIOCPDebugINfo.createAsChild(tsIOCPINfo, FIOCPConsole);

  PageControl1.ActivePageIndex :=0;
end;

destructor TfrmMain.Destroy;
begin
  FIOCPConsole.close;
  FDecoder.Free;
  FEncoder.Free;
  FreeAndNil(FIOCPConsole);
  inherited Destroy;
end;

procedure TfrmMain.btnADOQueryTesterClick(Sender: TObject);
var
  lvStream:TMemoryStream;
begin
  dmMain.qryMain.Active := true;
  lvStream := TMemoryStream.Create();
  try
    TADOTools.saveToStream(dmMain.qryMain, lvStream);
    lvStream.Position := 0;
    TADOTools.loadFromStream(self.qryMain, lvStream);
    ShowMessage(IntToStr(self.qryMain.RecordCount));


  finally
    lvStream.Free;
  end;

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

end.
