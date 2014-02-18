unit ufrmMain;
{
  Indy用的版本是10.x的版本
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, 
  IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, ExtCtrls;

type
  TfrmMain = class(TForm)
    edtIP: TEdit;
    btnC_01: TButton;
    btnCloseSocket: TButton;
    edtPort: TEdit;
    mmoLog: TMemo;
    IdTCPClient: TIdTCPClient;
    tmrEchoTester: TTimer;
    edtRFile: TEdit;
    btnGetFile: TButton;
    lblFile: TLabel;
    btnUpload: TButton;
    dlgOpen: TOpenDialog;
    chkZip: TCheckBox;
    procedure btnCloseSocketClick(Sender: TObject);
    procedure btnC_01Click(Sender: TObject);
    procedure btnGetFileClick(Sender: TObject);
    procedure btnStopEchoClick(Sender: TObject);
    procedure btnUploadClick(Sender: TObject);
  private
    { Private declarations }
    FTesterList: TList;
    procedure ClearTester;
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

  FTesterList := TList.Create();

  refreshState;

end;

destructor TfrmMain.Destroy;
begin
  ClearTester;
  FreeAndNil(FTesterList);
  inherited Destroy;
end;

procedure TfrmMain.refreshState;
begin
  btnCloseSocket.Enabled := IdTCPClient.Connected;
  btnC_01.Enabled := not IdTCPClient.Connected;

  btnUpload.Enabled := btnCloseSocket.Enabled;
  btnGetFile.Enabled := btnCloseSocket.Enabled;
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

procedure TfrmMain.btnGetFileClick(Sender: TObject);

var
  lvFileStream:TFileStream;
  lvRecvObj, lvSendObj:TJsonStream;
  i, l, lvSize:Integer;
  lvFileName:String;
  lvCrc:Cardinal;
begin

  //将文件分段下载<每段固定大小>
  //循环发送
  //  {
  //     fileName:'xxxx',  //客户端请求文件
  //     start:0,          //客户端请求开始位置
  
  //     filesize:11111,   //文件总大小
  //     crc:xxxx,         //服务端返回
  //     blockSize:4096   //服务端返回
  //  }
  

  lvFileName := ExtractFilePath(ParamStr(0)) + 'tempFiles\' + edtRFile.Text;
  DeleteFile(lvFileName);

  lvFileStream := TFileStream.Create(lvFileName, fmCreate or fmShareDenyWrite);
  lvSendObj := TJsonStream.Create;
  lvRecvObj := TJsonStream.Create;
  try
    while true do
    begin
      lvSendObj.Clear();
      //请求文件下载
      lvSendObj.Json.S['cmd.namespace'] := 'fileaccess'; 
      lvSendObj.Json.I['cmd.index'] := 1;
      lvSendObj.Json.I['start'] := lvFileStream.Position;
      lvSendObj.Json.S['fileName'] := edtRFile.Text;
      lvSendObj.Json.B['config.stream.zip'] := chkZip.Checked;

      TIdTcpClientJSonStreamCoder.Encode(self.IdTCPClient, lvSendObj);
      TIdTcpClientJSonStreamCoder.Decode(self.IdTCPClient, lvRecvObj);
      if not lvRecvObj.getResult then
      begin
        raise Exception.Create(lvRecvObj.getResultMsg);
      end;

      lvCrc := TCRCTools.crc32Stream(lvRecvObj.Stream);
      if lvCrc <> lvRecvObj.Json.I['crc'] then
      begin
        raise Exception.Create('crc校验失败!');
      end;
      lvRecvObj.Stream.Position := 0;
      lvFileStream.CopyFrom(lvRecvObj.Stream, lvRecvObj.Stream.Size);

      //文件下载完成
      if lvFileStream.Size = lvRecvObj.Json.I['fileSize'] then
      begin
        Break;
      end;
    end;
  finally
    lvFileStream.Free;
    lvSendObj.Free;
    lvRecvObj.Free;
  end;

  ShowMessage('下载成功!');
end;

procedure TfrmMain.btnStopEchoClick(Sender: TObject);
begin
  ClearTester;
end;

procedure TfrmMain.btnUploadClick(Sender: TObject);
const
  SEC_SIZE = 1024 * 4 * 1000;
  //SEC_SIZE = 10;
var
  lvFileStream:TFileStream;
  lvRecvObj, lvSendObj:TJsonStream;
  i, l, lvSize:Integer;

begin
  //将文件分段传递<每段固定大小> 4K
  //循环发送
  //  {
  //     fileName:'xxxx',
  //     crc:xxxx,
  //     start:0,   //开始位置
  //     eof:true,  //最后一个
  //  }

  if not dlgOpen.Execute() then exit;

  lvFileStream := TFileStream.Create(dlgOpen.FileName, fmOpenRead);
  lvSendObj := TJsonStream.Create;
  lvRecvObj := TJsonStream.Create;
  try
//    lvFileStream.Position := 106496;
//    lvSendObj.Clear();
//    l := lvSendObj.Stream.CopyFrom(lvFileStream, SEC_SIZE);
//    if l <=SEC_SIZE then
//    begin
//      ShowMessage('OK');
//    end;
//    exit;

    while true do
    begin
      lvSendObj.Clear();
      lvSendObj.Json.S['cmd.namespace'] := 'fileaccess'; 
      lvSendObj.Json.I['cmd.index'] := 2;   //上传文件
      lvSendObj.Json.I['start'] := lvFileStream.Position;
      lvSendObj.Json.S['fileName'] := ExtractFileName(dlgOpen.FileName);
      lvSendObj.Json.B['config.stream.zip'] := chkZip.Checked;
      lvSize := Min(SEC_SIZE, lvFileStream.Size-lvFileStream.Position);
      l := lvSendObj.Stream.CopyFrom(lvFileStream, lvSize);
      if l = 0 then
      begin
        Break;
      end;
      lvSendObj.Json.I['size'] := l;
      lvSendObj.Json.B['eof'] := (lvFileStream.Position = lvFileStream.Size);
      lvSendObj.Json.I['crc'] := TCRCTools.crc32Stream(lvSendObj.Stream);
      TIdTcpClientJSonStreamCoder.Encode(self.IdTCPClient, lvSendObj);
      TIdTcpClientJSonStreamCoder.Decode(self.IdTCPClient, lvRecvObj);
      if not lvRecvObj.getResult then
      begin
        raise Exception.Create(lvRecvObj.getResultMsg);
      end;
      if (lvFileStream.Position = lvFileStream.Size) then
      begin
        Break;
      end;
    end;
  finally
    lvFileStream.Free;
    lvSendObj.Free;
    lvRecvObj.Free;
  end;

  ShowMessage('上传成功!');
end;

procedure TfrmMain.ClearTester;
begin

end;

end.
