unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uIOCPConsole, uIOCPJSonStreamDecoder, uIOCPJSonStreamEncoder,
  ExtCtrls, superobject,
  ComCtrls;

type
  TfrmMain = class(TForm)
    pgcMain: TPageControl;
    tsBase: TTabSheet;
    tsMoniter: TTabSheet;
    edtPort: TEdit;
    btnIOCPAPIRun: TButton;
    btnStopSevice: TButton;
    edtBasePath: TEdit;
    btnSetBase: TButton;
    procedure btnDiscountAllClientClick(Sender: TObject);
    procedure btnIOCPAPIRunClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnSetBaseClick(Sender: TObject);
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
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uIOCPCentre, uClientContext, uBuffer, uMemPool, uIOCPDebugger,
  uFMIOCPDebugINfo, uFrameConfig;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  edtBasePath.Text := ExtractFilePath(ParamStr(0)) + 'Files\';
  TFrameConfig.setBasePath(edtBasePath.Text);

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

procedure TfrmMain.btnDiscountAllClientClick(Sender: TObject);
begin
  FIOCPConsole.DisconnectAllClientContext;
end;

procedure TfrmMain.btnIOCPAPIRunClick(Sender: TObject);
begin
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

procedure TfrmMain.btnResetClick(Sender: TObject);
begin
  TIOCPDebugger.resetDebugINfo;
end;

procedure TfrmMain.btnSetBaseClick(Sender: TObject);
begin
  TFrameConfig.setBasePath(edtBasePath.Text);
end;

procedure TfrmMain.btnStopSeviceClick(Sender: TObject);
begin
  FIOCPConsole.close;
  btnIOCPAPIRun.Enabled := not FIOCPConsole.Active;
  btnStopSevice.Enabled := not btnIOCPAPIRun.Enabled;
end;

end.

