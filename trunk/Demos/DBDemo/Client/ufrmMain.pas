unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uClientSocket, uD10ClientSocket,
  uJSonStreamClientCoder, ExtCtrls, Grids, DBGrids, DB, DBClient, ComCtrls,
  uRDBOperator, ScktComp, uTesterTools, uAppTools, WinSock2;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    btnOpen: TButton;
    btnCloseSocket: TButton;
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
    cbbHost: TComboBox;
    btnZipTester: TButton;
    cdsData2: TClientDataSet;
    dsData2: TDataSource;
    btnZipTester2: TButton;
    tsTester: TTabSheet;
    mmoTestLog: TMemo;
    pnlTop: TPanel;
    Label3: TLabel;
    edtNum: TEdit;
    btnDoTester: TButton;
    btnStopTester: TButton;
    tmrThread: TTimer;
    lblThreadCount: TLabel;
    lblBytesINfo: TLabel;
    btnGetServerINfo: TButton;
    Button1: TButton;
    procedure btnCloseSocketClick(Sender: TObject);
    procedure btnDoTesterClick(Sender: TObject);
    procedure btnGetServerINfoClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnOpenSQLClick(Sender: TObject);
    procedure btnPostClick(Sender: TObject);
    procedure btnOpenScriptClick(Sender: TObject);
    procedure btnStopTesterClick(Sender: TObject);
    procedure btnZipTester2Click(Sender: TObject);
    procedure btnZipTesterClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure tmrThreadTimer(Sender: TObject);
  private
    { Private declarations }
    FTesterList: TList;
    FRDBOperator:TRDBOperator;
    FCSocket:ScktComp.TClientSocket;
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
  CDSOperatorWrapper, uZipTools, uTester;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRDBOperator := TRDBOperator.Create;
  
  FClientSocket := TD10ClientSocket.Create();
  FClientSocket.registerCoder(TJSonStreamClientCoder.Create, True);
  FRDBOperator.Connection := FClientSocket;

  FCSocket := ScktComp.TClientSocket.Create(Self);
  FCSocket.ClientType := ctNonBlocking;
  
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

procedure TfrmMain.btnDoTesterClick(Sender: TObject);
var
  lvTester:TTester;
  i:Integer;
begin
  uTester.__stop:= false;
  for I := 1 to StrToInt(edtNum.Text) do
  begin
    lvTester := TTester.Create;
    lvTester.TesterCode := IntToStr(i);
    lvTester.Connection.Host := cbbHost.Text;
    lvTester.Connection.Port := StrToInt(edtPort.Text);
    lvTester.SQL := mmoSQL.Text;
    lvTester.Resume;
    FTesterList.Add(lvTester);
  end;
end;

procedure TfrmMain.btnGetServerINfoClick(Sender: TObject);
var
  lvJSonStream, lvRecvObject:TJsonStream;
  lvStream:TStream;
  lvData:AnsiString;
  l, j, x:Integer;
begin
  //self.checkSocketConnect;

  lvJSonStream := TJsonStream.Create;
  try
    lvJSonStream.JSon := SO();
    lvJSonStream.JSon.I['cmdIndex'] := 103;   //打开一个SQL脚本，获取数据
    FClientSocket.sendObject(lvJSonStream);
  finally
    lvJSonStream.Free;
  end;

  if FClientSocket.WaitForData() then
  begin
    //TFileLogger.instance.logDebugMessage('已经WaitForData');
    //读取数据
    lvRecvObject := TJsonStream.Create;
    try
      FClientSocket.recvObject(lvRecvObject);
      mmoData.Lines.Clear;
      mmoData.Lines.Add(lvRecvObject.Json.AsJSon(True, False));
    finally
      lvRecvObject.Free;
    end;
  end;

end;

procedure TfrmMain.btnOpenClick(Sender: TObject);
begin
  FClientSocket.close;
  FClientSocket.Host := cbbHost.Text;
  FClientSocket.Port := StrToInt(edtPort.Text);
  FClientSocket.open;

  refreshState;
end;

procedure TfrmMain.btnOpenSQLClick(Sender: TObject);
begin
  FRDBOperator.clear;
  FRDBOperator.RScript.S['sql'] := mmoSQL.Lines.Text;
  FRDBOperator.QueryCDS(cdsMain);
 // FRDBOperator.Connection.close;
  
end;

procedure TfrmMain.btnPostClick(Sender: TObject);
begin
  if FRDBOperator.ApplyUpdate(cdsMain, edtUpdateTable.Text, edtKeyFields.Text) then
  begin
    cdsMain.MergeChangeLog();
  end;
end;

procedure TfrmMain.btnOpenScriptClick(Sender: TObject);
begin
  FRDBOperator.clear;
  FRDBOperator.RScript.I['key'] := 11200003;
  FRDBOperator.RScript.I['step'] := 1;
  if edtCode.Text <> '' then
  begin
    FRDBOperator.RScript.S['params.$rep_where'] := ' and num=''' +  edtCode.Text + '''';
  end;
  FRDBOperator.QueryCDS(cdsMain);

end;

procedure TfrmMain.btnStopTesterClick(Sender: TObject);
begin
  ClearTester;
end;

procedure TfrmMain.btnZipTester2Click(Sender: TObject);
var
  lvZipStream, lvStream:TMemoryStream;
  lvXMLData:String;
  lvBytes, lvZipBytes:TBytes;
begin
  lvXMLData := cdsMain.XMLData;
  lvStream := TMemoryStream.Create;
  lvStream.Write(lvXmlData[1], Length(lvXMLData));

  SetLength(lvBytes, lvStream.Size);
  lvStream.Position := 0;
  lvStream.Read(lvBytes[0], lvStream.Size);
  lvZipBytes := TBytes(TZipTools.compressBuf(lvBytes[0], lvStream.Size));

  lvZipStream := TMemoryStream.Create;
  lvZipStream.Write(lvZipBytes[0], Length(lvZipBytes));


  SetLength(lvZipBytes, lvZipStream.Size);
  lvZipStream.Position := 0;
  lvZipStream.Read(lvZipBytes[0], lvZipStream.Size);

  lvBytes := TBytes(TZipTools.unCompressBuf(lvZipBytes[0], Length(lvZipBytes)));
  lvStream.Clear;
  lvStream.Write(lvBytes[0], Length(lvBytes));

  SetLength(lvXMLData, lvStream.Size);
  lvStream.Position := 0;
  lvStream.ReadBuffer(lvXMLData[1], lvStream.Size);

  cdsData2.XMLData := lvXMLData;
  self.DBGrid1.DataSource := dsData2;
end;

procedure TfrmMain.btnZipTesterClick(Sender: TObject);
var
  lvZipStream, lvStream:TMemoryStream;
  lvXMLData:String;
  lvBytes, lvZipBytes:TBytes;
begin
  lvXMLData := cdsMain.XMLData;
  lvStream := TMemoryStream.Create;
  lvStream.Write(lvXmlData[1], Length(lvXMLData));

  TZipTools.compressStreamEx(lvStream);

  TZipTools.unCompressStreamEx(lvStream);
  
  SetLength(lvXMLData, lvStream.Size);
  lvStream.Position := 0;
  lvStream.ReadBuffer(lvXMLData[1], lvStream.Size);

  cdsData2.XMLData := lvXMLData;
  self.DBGrid1.DataSource := dsData2;



//      lvStream := lvJsonStream.Stream;
//      lvStream.Size := 0;
//      lvStream.WriteBuffer(lvUnZipBytes[0], Length(lvUnZipBytes));
end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
  HostEnt: PHostEnt;
  FRemoteAddr:String;
begin
  Size := SizeOf(SockAddrIn);
  getsockname(FClientSocket.SocketHandle, TSockAddr(SockAddrIn), Size);
  FRemoteAddr := inet_ntoa(SockAddrIn.sin_addr);
  ShowMessage(FRemoteAddr);
end;

procedure TfrmMain.ClearTester;
var
  i:Integer;
begin
  uTester.__stop:= true;
  for i := 0 to FTesterList.Count - 1 do
  begin
    TTester(FTesterList[i]).Terminate;
    TTester(FTesterList[i]).WaitFor;
    TTester(FTesterList[i]).Free;
  end;
  FTesterList.Clear;
end;

procedure TfrmMain.tmrThreadTimer(Sender: TObject);
begin
  lblThreadCount.Caption := Format('当前测试线程数:%d', [__TesterCount]);
  lblBytesINfo.Caption := Format('接收数据:%d,发送数据:%d', [__recvbytes_size, __sendbytes_size]);
end;

end.
