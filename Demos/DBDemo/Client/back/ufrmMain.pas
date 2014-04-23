unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uClientSocket, uD10ClientSocket,
  uJSonStreamClientCoder, ExtCtrls, Grids, DBGrids, DB, DBClient, ComCtrls,
  uRDBOperator;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    btnOpen: TButton;
    btnCloseSocket: TButton;
    edtIP: TEdit;
    edtPort: TEdit;
    mmoSQL: TMemo;
    btnOpenSQL: TButton;
    cdsMain: TClientDataSet;
    dsMain: TDataSource;
    edtUpdateTable: TEdit;
    edtKeyFields: TEdit;
    Label2: TLabel;
    Label1: TLabel;
    btnPost: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    mmoData: TMemo;
    DBGrid1: TDBGrid;
    btnOpenScript: TButton;
    edtCode: TEdit;
    procedure btnCloseSocketClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnEchoTesterClick(Sender: TObject);
    procedure btnOpenSQLClick(Sender: TObject);
    procedure btnPostClick(Sender: TObject);
    procedure btnStopEchoClick(Sender: TObject);
    procedure btnOpenScriptClick(Sender: TObject);
  private
    { Private declarations }
    FTesterList: TList;
    FRDBOperator:TRDBOperator;
    FClientSocket: TD10ClientSocket;
    procedure ClearTester;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure refreshState;
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ComObj, superobject, uMemoLogger,
  uEchoTester, uSocketTools, JSonStream, IdGlobal, uNetworkTools,
  CDSOperatorWrapper;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRDBOperator := TRDBOperator.Create;
  
  FClientSocket := TD10ClientSocket.Create();
  FClientSocket.registerCoder(TJSonStreamClientCoder.Create, True);

  FRDBOperator.Connection := FClientSocket;
  
  FTesterList := TList.Create();

  refreshState;

end;

destructor TfrmMain.Destroy;
begin
  FRDBOperator.Free;
  ClearTester;
  FreeAndNil(FTesterList);
  FreeAndNil(FClientSocket);
  inherited Destroy;
end;

procedure TfrmMain.refreshState;
begin
  btnCloseSocket.Enabled := FClientSocket.Active;
  btnOpen.Enabled := not FClientSocket.Active;
  btnOpenSQL.Enabled := FClientSocket.Active;
  btnPost.Enabled := FClientSocket.Active;

end;

procedure TfrmMain.btnCloseSocketClick(Sender: TObject);
begin
  FClientSocket.close;
  refreshState;
end;

procedure TfrmMain.btnOpenClick(Sender: TObject);
begin
  FClientSocket.close;
  FClientSocket.Host := edtIP.Text;
  FClientSocket.Port := StrToInt(edtPort.Text);
  FClientSocket.open;

  refreshState;
end;

procedure TfrmMain.btnEchoTesterClick(Sender: TObject);
var
  lvEchoTester:TEchoTester;
  i:Integer;
begin
//  for I := 1 to StrToInt(edtCount.Text) do
//  begin
//    lvEchoTester := TEchoTester.Create;
//    lvEchoTester.EchoCode := IntToStr(i);
//    lvEchoTester.Client.Host := edtIP.Text;
//    lvEchoTester.Client.Port := StrToInt(edtPort.Text);
//    lvEchoTester.Resume;
//    FTesterList.Add(lvEchoTester);
//  end;

end;

procedure TfrmMain.btnOpenSQLClick(Sender: TObject);
begin
  FRDBOperator.clear;
  FRDBOperator.RScript.S['sql'] := mmoSQL.Lines.Text;
  FRDBOperator.QueryCDS(cdsMain);
end;

procedure TfrmMain.btnPostClick(Sender: TObject);
begin
  if FRDBOperator.ApplyUpdate(cdsMain, edtUpdateTable.Text, edtKeyFields.Text) then
  begin
    cdsMain.MergeChangeLog();
  end;
end;

procedure TfrmMain.btnStopEchoClick(Sender: TObject);
begin
  ClearTester;
end;

procedure TfrmMain.btnOpenScriptClick(Sender: TObject);
begin
  try
    FRDBOperator.trace := true;
    FRDBOperator.clear;
    FRDBOperator.RScript.I['key'] := 11200003;
    FRDBOperator.RScript.I['step'] := 1;
    if edtCode.Text <> '' then
    begin
      FRDBOperator.RScript.S['params.$rep_where'] := ' and num=''' +  edtCode.Text + '''';
    end;
    FRDBOperator.QueryCDS(cdsMain);
  finally
    if FRDBOperator.TraceData <> nil then
    begin
      mmoData.Lines.Add(FRDBOperator.TraceData.AsJSon(True));
    end;
  end;

end;

procedure TfrmMain.ClearTester;
var
  i:Integer;
begin
  for i := 0 to FTesterList.Count - 1 do
  begin
    TEchoTester(FTesterList[i]).Terminate;
    TEchoTester(FTesterList[i]).WaitFor;
    TEchoTester(FTesterList[i]).Free;
  end;
  FTesterList.Clear;
end;

end.
