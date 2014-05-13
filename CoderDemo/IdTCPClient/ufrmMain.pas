unit ufrmMain;
{
  Indy用的版本是10.x的版本
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, 
  IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, ExtCtrls, Grids, DBGrids, DB, DBClient, uMyObjectIdTcpClientCoder;

type
  TfrmMain = class(TForm)
    edtIP: TEdit;
    btnC_01: TButton;
    btnCloseSocket: TButton;
    edtPort: TEdit;
    IdTCPClient: TIdTCPClient;
    pnlTopOperator: TPanel;
    Button1: TButton;
    btnTestSendMyObject: TButton;
    procedure btnCloseSocketClick(Sender: TObject);
    procedure btnC_01Click(Sender: TObject);
    procedure btnTestSendMyObjectClick(Sender: TObject);
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
  ComObj, uMyObject,  Math, uOleVariantConverter;

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

  btnTestSendMyObject.Enabled := btnCloseSocket.Enabled;
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

procedure TfrmMain.btnTestSendMyObjectClick(Sender: TObject);
var
  lvSendObj, lvRecvObj:TMyObject;
  ole:OleVariant;
begin
  lvSendObj := TMyObject.Create;
  lvRecvObj := TMyObject.Create;
  try

    //测试数据
    lvSendObj.DataString := '字符串数据abcd###VVV';
    ole :=VarArrayCreate([0, 1], varVariant);
    ole[0]:= Now();
    ole[1]:= True;
    lvSendObj.Ole := ole;

    //发送对象
    TMyObjectCoderTools.Encode(self.IdTCPClient, lvSendObj);

    //接收对象
    TMyObjectCoderTools.Decode(self.IdTCPClient, lvRecvObj);

    //显示测试数据
    ShowMessage(lvRecvObj.DataString);   // '字符串数据abcd###VVV';
    ShowMessage(lvRecvObj.Ole[0]);       // 时间
    ShowMessage(lvRecvObj.Ole[1]);       // true
  finally
    lvSendObj.Free;
    lvRecvObj.Free;
  end;
end;

end.
