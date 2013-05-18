unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uClientSocket, uD10ClientSocket,
  uJSonStreamClientCoder;

type
  TfrmMain = class(TForm)
    edtIP: TEdit;
    btnC_01: TButton;
    btnSendJSonStreamObject: TButton;
    btnCloseSocket: TButton;
    edtPort: TEdit;
    mmoLog: TMemo;
    btnEchoTester: TButton;
    edtCount: TEdit;
    btnStopEcho: TButton;
    btnSend100: TButton;
    procedure btnCloseSocketClick(Sender: TObject);
    procedure btnC_01Click(Sender: TObject);
    procedure btnEchoTesterClick(Sender: TObject);
    procedure btnSend100Click(Sender: TObject);
    procedure btnSendJSonStreamObjectClick(Sender: TObject);
    procedure btnStopEchoClick(Sender: TObject);
  private
    { Private declarations }
    FTesterList: TList;
    FClientSocket: TD10ClientSocket;
    procedure ClearTester;
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
  uEchoTester, uSocketTools, JSonStream;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FClientSocket := TD10ClientSocket.Create();
  FClientSocket.registerCoder(TJSonStreamClientCoder.Create, True);
  
  FTesterList := TList.Create();

end;

destructor TfrmMain.Destroy;
begin
  ClearTester;
  FreeAndNil(FTesterList);
  FreeAndNil(FClientSocket);
  inherited Destroy;
end;

procedure TfrmMain.btnCloseSocketClick(Sender: TObject);
begin
  FClientSocket.close;
end;

procedure TfrmMain.btnC_01Click(Sender: TObject);
begin
  FClientSocket.close;
  FClientSocket.Host := edtIP.Text;
  FClientSocket.Port := StrToInt(edtPort.Text);
  FClientSocket.open;
end;

procedure TfrmMain.btnEchoTesterClick(Sender: TObject);
var
  lvEchoTester:TEchoTester;
  i:Integer;
begin
  for I := 1 to StrToInt(edtCount.Text) do
  begin
    lvEchoTester := TEchoTester.Create;
    lvEchoTester.EchoCode := IntToStr(i);
    lvEchoTester.Client.Host := edtIP.Text;
    lvEchoTester.Client.Port := StrToInt(edtPort.Text);
    lvEchoTester.Resume;
    FTesterList.Add(lvEchoTester);
  end;

end;

procedure TfrmMain.btnSend100Click(Sender: TObject);
var
  i:Integer;
begin
  for i := 0 to 100 - 1 do
  begin
    btnSendJSonStreamObject.Click;
  end;
    
end;

procedure TfrmMain.btnSendJSonStreamObjectClick(Sender: TObject);
var
  lvJSonStream, lvRecvObject:TJsonStream;
  lvStream:TStream;
  lvData:String;
  l, j, x:Integer;
begin
  lvJSonStream := TJsonStream.Create;
  try
    lvJSonStream.JSon := SO();
    lvJSonStream.JSon.I['cmdIndex'] := 1000;   //echo 数据测试
    lvJSonStream.JSon.S['data'] := '测试发送打包数据';
    lvJSonStream.JSon.S['key'] := CreateClassID;
    lvStream := lvJSonStream.Stream;

    SetLength(lvData, 1024 * 1);
    FillChar(lvData[1], 1024 * 1, Ord('1'));
    lvStream.WriteBuffer(lvData[1], Length(lvData));

    FClientSocket.sendObject(lvJSonStream);

    TMemoLogger.infoMsg('数据发送成功！', mmoLog.Lines);
    lvRecvObject := TJsonStream.Create;
    try
      // TMemoLogger.infoMsg('数据接收成功！', mmoLog.Lines);
      FClientSocket.recvObject(lvRecvObject);
      TMemoLogger.infoMsg('==============================================' + sLineBreak
        + lvRecvObject.JSon.AsJSon(True)
        , mmoLog.Lines);
    finally
       lvRecvObject.Free;
    end;
  finally
    lvJSonStream.Free;
  end;   
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
