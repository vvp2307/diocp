unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uIOCPConsole, uMyObjectCoder, uOleVariantConverter,
  ExtCtrls,
  ComCtrls;

type
  TfrmMain = class(TForm)
    pgcMain: TPageControl;
    tsBase: TTabSheet;
    tsMoniter: TTabSheet;
    edtPort: TEdit;
    btnIOCPAPIRun: TButton;
    btnStopSevice: TButton;
    btnTestOle: TButton;
    procedure btnDiscountAllClientClick(Sender: TObject);
    procedure btnIOCPAPIRunClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnStopSeviceClick(Sender: TObject);
    procedure btnTestOleClick(Sender: TObject);
  private
    { Private declarations }
    FIOCPConsole: TIOCPConsole;
    FDecoder:TMyObjectDecoder;
    FEncoder:TMyObjectEncoder;
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
  uFMIOCPDebugINfo;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDecoder := TMyObjectDecoder.Create;
  FEncoder := TMyObjectEncoder.Create;

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

procedure TfrmMain.btnTestOleClick(Sender: TObject);
var
  ole, lvOle02:OleVariant;
  lvStream:TMemoryStream;
begin

  lvStream := TMemoryStream.Create;
  try

    ole :=VarArrayCreate([0, 1], varVariant);
    ole[0]:= Now();;
    ole[1]:= 'abc';
    WriteOleVariant(ole, lvStream);

    lvStream.Position := 0;

    lvOle02 := ReadOleVariant(lvStream);

    showMessage(lvOle02[1]);

  finally
    lvStream.Free;
  end;
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

