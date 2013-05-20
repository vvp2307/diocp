unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uClientSocket, uD10ClientSocket,
  uJSonStreamClientCoder, ExtCtrls, Grids, DBGrids, DB, DBClient, ComCtrls;

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
    procedure btnCloseSocketClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnEchoTesterClick(Sender: TObject);
    procedure btnOpenSQLClick(Sender: TObject);
    procedure btnPostClick(Sender: TObject);
    procedure btnStopEchoClick(Sender: TObject);
  private
    { Private declarations }
    FTesterList: TList;
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
  FClientSocket := TD10ClientSocket.Create();
  FClientSocket.registerCoder(TJSonStreamClientCoder.Create, True);
  
  FTesterList := TList.Create();

  refreshState;

end;

destructor TfrmMain.Destroy;
begin
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
var
  lvJSonStream, lvRecvObject:TJsonStream;
  lvStream:TStream;
  lvData:AnsiString;
  l, j, x:Integer;
begin
  lvJSonStream := TJsonStream.Create;
  try
    lvJSonStream.JSon := SO();
    lvJSonStream.JSon.I['cmdIndex'] := 1001;   //打开一个SQL脚本，获取数据
    lvJSonStream.Json.S['sql'] := mmoSQL.Lines.Text;

    FClientSocket.sendObject(lvJSonStream);
  finally
    lvJSonStream.Free;
  end;

  //读取数据
  lvRecvObject := TJsonStream.Create;
  try
    FClientSocket.recvObject(lvRecvObject);

    if not lvRecvObject.getResult then
    begin
      raise Exception.Create(lvRecvObject.getResultMsg);
    end;

    SetLength(lvData, lvRecvObject.Stream.Size);
    lvRecvObject.Stream.Position := 0;
    lvRecvObject.Stream.ReadBuffer(lvData[1], lvRecvObject.Stream.Size);

    cdsMain.XMLData := lvData;
  finally
     lvRecvObject.Free;
  end;
end;

procedure TfrmMain.btnPostClick(Sender: TObject);
var
  lvJSonStream, lvRecvObject:TJsonStream;
  lvStream:TStream;
  lvData:AnsiString;
  l, j, x:Integer;
begin
  if cdsMain.State in [dsInsert, dsEdit] then cdsMain.Post;
  
  if cdsMain.ChangeCount = 0 then
  begin
    ShowMessage('没有做任何修改!');
    exit;
  end;
  lvJSonStream := TJsonStream.Create;
  try
    lvJSonStream.JSon := SO();
    lvJSonStream.JSon.I['cmdIndex'] := 1002;   //打开一个SQL脚本，获取数据

    //打包修改记录
    with TCDSOperatorWrapper.createCDSEncode do
    begin
      setTableINfo(PAnsiChar(AnsiString(edtUpdateTable.Text)), PAnsiChar(AnsiString(edtKeyFields.Text)));
      setData(cdsMain.Data, cdsMain.Delta);
      //执行编码
      Execute;
      lvData := getPackageData;
    end;

    mmoData.Clear;
    mmoData.Lines.Add(lvData);

    lvJSonStream.Stream.Write(lvData[1], Length(lvData));

    FClientSocket.sendObject(lvJSonStream);
  finally
    lvJSonStream.Free;
  end;

  //读取数据
  lvRecvObject := TJsonStream.Create;
  try
    FClientSocket.recvObject(lvRecvObject);

    if not lvRecvObject.getResult then
    begin
      raise Exception.Create(lvRecvObject.getResultMsg);
    end else
    begin
      ShowMessage('保存成功!');
    end;
  finally
     lvRecvObject.Free;
  end;

  cdsMain.MergeChangeLog();

end;

procedure TfrmMain.btnStopEchoClick(Sender: TObject);
begin
  ClearTester;
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
