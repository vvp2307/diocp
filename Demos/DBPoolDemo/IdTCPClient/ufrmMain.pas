unit ufrmMain;
{
  Indy用的版本是10.x的版本
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, 
  IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, ExtCtrls, Grids, DBGrids, DB, DBClient;

type
  TfrmMain = class(TForm)
    edtIP: TEdit;
    btnC_01: TButton;
    btnCloseSocket: TButton;
    edtPort: TEdit;
    mmoSQL: TMemo;
    IdTCPClient: TIdTCPClient;
    txtAccount: TComboBox;
    lblaccountID: TLabel;
    pnlTopOperator: TPanel;
    dbgrdMain: TDBGrid;
    cdsMain: TClientDataSet;
    dsMain: TDataSource;
    btnOpenSQL: TButton;
    procedure btnCloseSocketClick(Sender: TObject);
    procedure btnC_01Click(Sender: TObject);
    procedure btnOpenSQLClick(Sender: TObject);
  private
    procedure refreshState;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ComObj, superobject, uMemoLogger,
  uEchoTester, uSocketTools, JSonStream, IdGlobal, uNetworkTools,
  uIdTcpClientJSonStreamCoder, uCRCTools, Math;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  refreshState;

end;

destructor TfrmMain.Destroy;
begin

  inherited Destroy;
end;

procedure TfrmMain.refreshState;
begin
  btnCloseSocket.Enabled := IdTCPClient.Connected;
  btnC_01.Enabled := not IdTCPClient.Connected;

  btnOpenSQL.Enabled := btnCloseSocket.Enabled;
end;

procedure TfrmMain.btnCloseSocketClick(Sender: TObject);
begin
  try
    IdTCPClient.Disconnect;
  finally
    refreshState;
  end;
end;

procedure TfrmMain.btnC_01Click(Sender: TObject);
begin
  IdTCPClient.Disconnect;
  IdTCPClient.Host := edtIP.Text;
  IdTCPClient.Port := StrToInt(edtPort.Text);
  IdTCPClient.Connect;

  refreshState;

end;

procedure TfrmMain.btnOpenSQLClick(Sender: TObject);
var
  lvRecvObj, lvSendObj:TJsonStream;
  i, l, lvSize:Integer;
  lvData:AnsiString;
begin
  lvSendObj := TJsonStream.Create;
  lvRecvObj := TJsonStream.Create;
  try
    lvSendObj.Clear();
    lvSendObj.Json.S['config.accountID'] := txtAccount.Text;
    lvSendObj.Json.I['cmdIndex'] := 1001;
    lvSendObj.Json.S['script.sql'] := mmoSQL.Lines.Text;
    TIdTcpClientJSonStreamCoder.Encode(self.IdTCPClient, lvSendObj);
    TIdTcpClientJSonStreamCoder.Decode(self.IdTCPClient, lvRecvObj);
    if not lvRecvObj.getResult then
    begin
      raise Exception.Create(lvRecvObj.getResultMsg);
    end;

    SetLength(lvData, lvRecvObj.Stream.Size);
    lvRecvObj.Stream.Position := 0;
    lvRecvObj.Stream.ReadBuffer(lvData[1], lvRecvObj.Stream.Size);

    cdsMain.XMLData := lvData;
  finally
    lvSendObj.Free;
    lvRecvObj.Free;
  end;

end;

end.
