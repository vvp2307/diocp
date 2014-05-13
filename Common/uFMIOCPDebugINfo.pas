unit uFMIOCPDebugINfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls, uIOCPConsole, uIOCPCentre;

type
  TFMIOCPDebugINfo = class(TFrame)
    tmrTestINfo: TTimer;
    lblClientINfo: TLabel;
    lblRecvINfo: TLabel;
    lblSendINfo: TLabel;
    lblWorkCount: TLabel;
    lblMemINfo: TLabel;
    lblClientContextINfo: TLabel;
    lblSendAndRecvBytes: TLabel;
    lblSendBytes: TLabel;
    btnReset: TButton;
    lblRunTimeINfo: TLabel;
    procedure btnResetClick(Sender: TObject);
    procedure tmrTestINfoTimer(Sender: TObject);
  private
    FIOCPConsole: TIOCPConsole;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    { Private declarations }
  public
    class function createAsChild(pvParent:TWinControl;
      pvIOCPConsole:TIOCPConsole):TFMIOCPDebugINfo;
    property Active: Boolean read GetActive write SetActive;
    property IOCPConsole: TIOCPConsole read FIOCPConsole write FIOCPConsole; 
    
  end;

implementation

uses
  uIOCPDebugger, uIOCPFileLogger, uRunTimeINfoTools;

{$R *.dfm}

procedure TFMIOCPDebugINfo.btnResetClick(Sender: TObject);
begin
  TIOCPDebugger.resetDebugINfo;
end;

class function TFMIOCPDebugINfo.createAsChild(pvParent: TWinControl;
  pvIOCPConsole: TIOCPConsole): TFMIOCPDebugINfo;
begin
  Result := TFMIOCPDebugINfo.Create(pvParent.Owner);
  Result.Parent := pvParent;
  Result.Align := alClient;
  Result.Active := true;
end;

function TFMIOCPDebugINfo.GetActive: Boolean;
begin
  Result := tmrTestINfo.Enabled;
end;

procedure TFMIOCPDebugINfo.SetActive(const Value: Boolean);
begin
  tmrTestINfo.Enabled := Value;
end;

procedure TFMIOCPDebugINfo.tmrTestINfoTimer(Sender: TObject);
var
  lvCount, lvBusyCount:Integer;
begin
  try
    lblClientINfo.Caption := '连接数:' + IntToStr(TIOCPDebugger.clientCount);
    lblRecvINfo.Caption :=   '接收数据对象个数:' + IntToStr(TIOCPDebugger.recvObjectCount);
    lblSendINfo.Caption :=   '发送数据对象个数:' + IntToStr(TIOCPDebugger.sendObjectCount);
    if FIOCPConsole <> nil then
    begin
      lblWorkCount.Caption :=  '工作线程:' + IntToStr(FIOCPConsole.WorkerCount);
    end;

    lblSendAndRecvBytes.Caption :=
      Format('接收/发送字节数:%d/%d bytes, %d/%d blockCount',
        [TIOCPDebugger.recvBytes,
         TIOCPDebugger.sendBytes,
         TIOCPDebugger.recvBlockCount,
         TIOCPDebugger.sendBlockCount]);

    lblSendBytes.Caption :=
      Format('投递/发送字节数:%d/%d bytes',
        [TIOCPDebugger.WSASendBytes,
         TIOCPDebugger.sendBytes]);

    lblMemINfo.Visible := false;
//  不使用
//    lblMemINfo.Caption :=   Format(
//       'IO内存块池共(%d),可用(%d)',
//       [TIODataMemPool.instance.getCount, TIODataMemPool.instance.getUseableCount]);

    lvCount := TIOCPContextFactory.instance.IOCPContextPool.count;
    lvBusyCount := TIOCPContextFactory.instance.IOCPContextPool.BusyCount;
    lblClientContextINfo.Caption :=   Format(
       'ClientContext池共(%d),可用(%d)',
       [lvCount, lvCount - lvBusyCount]);

    lblRunTimeINfo.Caption :='程序已经运行:' +  TRunTimeINfoTools.getRunTimeINfo;
  except
    on E:Exception do
    begin
       TIOCPFileLogger.logErrMessage(self.ClassName+ '.tmrTestINfoTimer, 出现了异常:' + e.Message);
    end;
  end;

end;



end.
