unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uIOCPConsole, uIOCPJSonStreamDecoder, uIOCPJSonStreamEncoder,
  ExtCtrls, superobject,
  ComCtrls, UniDacVcl, SQLServerUniProvider, MySQLUniProvider, uUniOperator,
  UntCobblerUniPool;

type
  TfrmMain = class(TForm)
    pgcMain: TPageControl;
    tsBase: TTabSheet;
    tsMoniter: TTabSheet;
    edtPort: TEdit;
    btnIOCPAPIRun: TButton;
    btnStopSevice: TButton;
    tsConfig: TTabSheet;
    btnConnectionConfig: TButton;
    lblAccountID: TLabel;
    txtAccount: TComboBox;
    tsTester: TTabSheet;
    mmoSQL: TMemo;
    mmoSQL2: TMemo;
    btnOpen: TButton;
    procedure btnConnectionConfigClick(Sender: TObject);
    procedure btnDiscountAllClientClick(Sender: TObject);
    procedure btnIOCPAPIRunClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnStopSeviceClick(Sender: TObject);
  private
    { Private declarations }
    FIOCPConsole: TIOCPConsole;
    FDecoder:TIOCPJSonStreamDecoder;
    FEncoder:TIOCPJSonStreamEncoder;
    procedure processTester;
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
  uFMIOCPDebugINfo, Uni, uUniConfigTools, uUniPool, FileLogger;

{$R *.dfm}

var
  __sql01:string; __sql02:string;

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDecoder := TIOCPJSonStreamDecoder.Create;
  FEncoder := TIOCPJSonStreamEncoder.Create;

  FIOCPConsole := TIOCPConsole.Create();

  with TFMIOCPDebugINfo.Create(Self) do
  begin
    Parent := tsMoniter;
    Align := alClient;
    IOCPConsole := FIOCPConsole;
    Active := True;
  end;

  //注册扩展客户端类
  TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

  //注册解码器
  TIOCPContextFactory.instance.registerDecoder(FDecoder);

  //注册编码器
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

procedure TfrmMain.btnConnectionConfigClick(Sender: TObject);
var
  lvConn, lvNewConn:TUniConnection;
  lvConnectDialog:TUniConnectDialog;
begin
  lvConn := TUniConnection.Create(nil);
  lvConnectDialog := TUniConnectDialog.Create(nil);
  try   
    lvConn.ConnectString := TUniConfigTools.getConnectionString(txtAccount.Text);
    lvConn.ConnectDialog :=lvConnectDialog;
    lvConnectDialog.StoreLogInfo := false;
    lvConnectDialog.OptionChanged;
    lvConnectDialog.Caption := '配置帐套[' +txtAccount.Text + ']数据库连接';
    lvConnectDialog.ConnectButton := '确定';
    lvConnectDialog.CancelButton := '取消';

    lvConnectDialog.SavePassword := true;
    if lvConn.ConnectDialog.Execute then
    begin
      lvNewConn := TUniConnection.Create(nil);
      try
        lvNewConn.ConnectString := lvConn.ConnectString;
        lvNewConn.LoginPrompt := False;
        lvNewConn.Connect;
      finally
        lvNewConn.Free;
      end;
      TUniConfigTools.saveConnectionString(txtAccount.Text, lvConn.ConnectString);
    end;
  finally
    lvConn.Free;
    lvConnectDialog.Free;
  end;
end;

procedure TfrmMain.btnDiscountAllClientClick(Sender: TObject);
begin
  FIOCPConsole.DisconnectAllClientContext;
end;

procedure TfrmMain.btnIOCPAPIRunClick(Sender: TObject);
begin
  TUniPool.reset;
  if not FIOCPConsole.Active then
  begin
    //注册扩展客户端类
    TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

    //注册解码器
    TIOCPContextFactory.instance.registerDecoder(FDecoder);

    //注册编码器
    TIOCPContextFactory.instance.registerEncoder(FEncoder);

    //FIOCPConsole.WorkerCount := 1;
    FIOCPConsole.Port := StrToInt(edtPort.Text);
    FIOCPConsole.open;
  end;

  btnIOCPAPIRun.Enabled := not FIOCPConsole.Active;
  btnStopSevice.Enabled := not btnIOCPAPIRun.Enabled;

end;

function f(p: Pointer): Integer;
begin
  try
    TfrmMain(p).processTester;
  except
    on E:Exception do
    begin
      TFileLogger.instance.logErrMessage(e.Message);
    end;
  end;
end;

procedure TfrmMain.btnOpenClick(Sender: TObject);
var
  i: Integer;
  tid: Cardinal;
begin
  __sql01 := mmoSQL.Lines.Text;
  __sql02 := mmoSQL2.Lines.Text;
  for i:=1 to 1 do
  begin
    BeginThread(nil,0,f,Self,0,tid);
  end;

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

procedure TfrmMain.processTester;
var
  lvDBDataOperator:TUniOperator;
  lvPoolObj:TUniCobbler;
  lvXMLData:String;
  i, j:Integer;
begin
  try
    i:= 0;
    j:= 0;
    while j < 100 do
    begin
      Inc(j);
      //从对象池中借用
      //通过帐套ID获取一个连接池对象
      lvPoolObj := TUniPool.getConnObject('account2013');
      try
        //打开连接
        lvPoolObj.checkConnect;

        //Uni数据库操作对象<可以改用对象池效率更好>
        lvDBDataOperator := TUniOperator.Create;
        try
          try
            lvDBDataOperator.setConnection(lvPoolObj.ConnObj);
            lvXMLData := lvDBDataOperator.CDSProvider.QueryXMLData(__sql01);
          except
            on E:Exception do
            begin
              i:= 1;
              raise;
            end;
          end;
          try
            lvXMLData := lvDBDataOperator.CDSProvider.QueryXMLData(__sql02);
          except
            on E:Exception do
            begin
              i:= 2;
              //TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);
              raise;
            end;
          end;
        finally
          lvDBDataOperator.Free;
        end;
      finally
        TUniPool.releaseConnObject(lvPoolObj);
      end;
    end;
  except
    on E:Exception do
    begin
      TFileLogger.instance.logErrMessage(IntToStr(i) + '---' + e.Message);
    end;
  end;
end;

end.

