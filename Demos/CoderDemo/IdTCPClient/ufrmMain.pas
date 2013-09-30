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
    Button1: TButton;
    cdsTemp: TClientDataSet;
    dbgrdTemp: TDBGrid;
    dsTemp: TDataSource;
    procedure btnCloseSocketClick(Sender: TObject);
    procedure btnC_01Click(Sender: TObject);
    procedure btnOpenSQLClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
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
  uSocketTools, JSonStream, IdGlobal, uNetworkTools,
  uIdTcpClientJSonStreamCoder, uCRCTools, Math, uOleVariantConverter;

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

    //帐套ID
    lvSendObj.Json.S['config.accountID'] := txtAccount.Text;

    //执行SQL的命令ID
    lvSendObj.Json.I['cmdIndex'] := 1001;

    //要执行的SQL
    lvSendObj.Json.S['script.sql'] := mmoSQL.Lines.Text;

    //发送到服务端进行处理<使用Indy进行传输>,如果需要使用ICS，可以在IOCPCoder文件夹中找到对应的uICSClientJSonStreamCoder.pas单元
    TIdTcpClientJSonStreamCoder.Encode(self.IdTCPClient, lvSendObj);

    //接收服务端处理的数据<使用Indy接收数据>
    TIdTcpClientJSonStreamCoder.Decode(self.IdTCPClient, lvRecvObj);
    if not lvRecvObj.getResult then
    begin
      raise Exception.Create(lvRecvObj.getResultMsg);
    end;

    //获取数据
    SetLength(lvData, lvRecvObj.Stream.Size);
    lvRecvObj.Stream.Position := 0;
    lvRecvObj.Stream.ReadBuffer(lvData[1], lvRecvObj.Stream.Size);

    //放入CDS的XMLDATA
    cdsMain.XMLData := lvData;
  finally
    lvSendObj.Free;
    lvRecvObj.Free;
  end;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  ole, lvOle02:OleVariant;
  lvStream:TMemoryStream;
begin

  lvStream := TMemoryStream.Create;
  try

    ole :=VarArrayCreate([0, 1], varVariant);
    ole[0]:= Now();;
    ole[1]:= cdsMain.Data;
    WriteOleVariant(ole, lvStream);

    lvStream.Position := 0;

    lvOle02 := ReadOleVariant(lvStream);

    cdsTemp.Data := lvOle02[1];

    showMessage(lvOle02[0]);

  finally
    lvStream.Free;
  end;

end;

end.
