unit ufrmMain;

interface


uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uIOCPConsole, uIOCPJSonStreamDecoder, uIOCPJSonStreamEncoder,
  ExtCtrls, ComCtrls, ActnList, Menus, ImgList, uWinService, uBuffer,
  Grids, ADODB, DBClient, ComObj, ActiveX, superobject;

type
  TfrmMain = class(TForm)
    btnService: TButton;
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    actlstMain: TActionList;
    tsDBConfig: TTabSheet;
    ilMain: TImageList;
    pmTryIcon: TPopupMenu;
    mniShowMain: TMenuItem;
    N3: TMenuItem;
    mniStartService: TMenuItem;
    actStartService: TAction;
    actStopService: TAction;
    actExit: TAction;
    mniExit: TMenuItem;
    actShowMain: TAction;
    mniStopService: TMenuItem;
    btn1: TButton;
    Memo1: TMemo;
    tsConfig: TTabSheet;
    lblListenPort: TLabel;
    edtPort: TEdit;
    edtWorkCount: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    btnConfigOK: TButton;
    actConfigOK: TAction;
    actConfigEdit: TAction;
    btnConfigEdit: TButton;
    tsClientINfo: TTabSheet;
    lstClientINfo: TListView;
    actRefreshClientINfo: TAction;
    pnlClientINfoOperator: TPanel;
    btnRefreshClientINfo: TButton;
    tsMoniter: TTabSheet;
    tsPoolINfo: TTabSheet;
    mmoPoolINfo: TMemo;
    btnPoolINfo: TButton;
    mniRefreshClientINfo: TMenuItem;
    tsTester: TTabSheet;
    mmoSQL: TMemo;
    btnOpen: TButton;
    mmoSQL2: TMemo;
    edtThreadCount: TEdit;
    btnKILLDeadLock: TButton;
    actKillDeadPoolObject: TAction;
    icnmain: TTrayIcon;
    btnScripterTester: TButton;
    procedure actConfigEditExecute(Sender: TObject);
    procedure actConfigOKExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actKillDeadPoolObjectExecute(Sender: TObject);
    procedure actRefreshClientINfoExecute(Sender: TObject);
    procedure actShowMainExecute(Sender: TObject);
    procedure actStartServiceExecute(Sender: TObject);
    procedure actStopServiceExecute(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btnDiscountAllClientClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnPoolINfoClick(Sender: TObject);
    procedure btnScripterTesterClick(Sender: TObject);
    procedure icnmainDblClick(Sender: TObject);
  private
    { Private declarations }
    FBuffer:TBufferLink;
    FIOCPConsole: TIOCPConsole;
    FDecoder:TIOCPJSonStreamDecoder;
    FEncoder:TIOCPJSonStreamEncoder;
    procedure refreshState;
    procedure DoConfigEdit(pvEditing:Boolean);


    procedure processTester_Scripter();
    procedure processTester_debugHaveError;

    procedure processTester_debugPool;

    procedure processTester_CDSOperatorError;
    procedure processTester1;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure WMSysCommand(var Message: TMessage); message WM_SysCommand;

    
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uIOCPCentre, uClientContext, TesterINfo, uMemPool, udmMain,
  uWinServiceTools,uAppJSonConfig, uFMIOCPDebugINfo, uADOOperator,
  uADOConnectionPool, uADOConnectionTools, FileLogger, scriptParser;

{$R *.dfm}

var
  __sql01:string; __sql02:string;

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  
  pgcMain.ActivePageIndex := 0;
  FBuffer := TBufferLink.Create;
  FDecoder := TIOCPJSonStreamDecoder.Create;
  FEncoder := TIOCPJSonStreamEncoder.Create;
  FIOCPConsole := TIOCPConsole.Create();

  //注册扩展客户端类
  TIOCPContextFactory.instance.registerClientContextClass(TClientContext);

  //注册解码器
  TIOCPContextFactory.instance.registerDecoder(FDecoder);

  //注册编码器
  TIOCPContextFactory.instance.registerEncoder(FEncoder);

  with TFMIOCPDebugINfo.Create(Self) do
  begin
    Parent := tsMoniter;
    Align := alClient;
    IOCPConsole := FIOCPConsole;
    Active := True;
  end;

  refreshState;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  DoConfigEdit(False);
  TAppJSonConfig.instance.Reload;
  if TAppJSonConfig.instance.Config.S['config.port'] <> '' then
    edtPort.Text := TAppJSonConfig.instance.Config.S['config.port'];

  edtWorkCount.Text := IntToStr(TAppJSonConfig.instance.Config.I['config.workcount']);
  actStartService.Execute;
end;

procedure TfrmMain.processTester_CDSOperatorError;
var
  lvADOPool:TADOConnectionPool;
  lvADOConnection:TADOConnection;
  lvADOOpera:TADOOperator;
  lvXMLData:String;
  i, j:Integer;
  lvCDS:TClientDataSet;
  lvMasterKey: String;
begin
  try
    i:= 0;
    j:= 0;
    lvMasterKey := CreateClassID;
    while j < 100 do
    begin
      Inc(j);
      //从对象池中借用
      lvADOPool := dmMain.getConnectionPool('main');

      lvADOConnection :=TADOConnection(lvADOPool.borrowObject);
      try
        lvADOOpera := TADOOperator.Create;
        try
          lvADOOpera.setConnection(lvADOConnection);
          lvADOOpera.ReOpen;
          lvCDS := TClientDataSet.Create(nil);
          try
            lvCDS.Data := lvADOOpera.CDSProvider.QueryData('SELECT * FROM sync_INfoState WHERE FMasterKey = ''' + lvMasterKey + '''');
            if lvCDS.RecordCount = 0 then
            begin
              lvCDS.Append;
              lvCDS.FieldByName('FKey').AsString :=CreateClassID;
              lvCDS.FieldByName('FMasterKey').AsString := lvMasterKey;
            end else
            begin
              lvCDS.Edit;
            end;
            lvCDS.Post;

            lvADOOpera.ExecuteApplyUpdateCDS('sync_INfoState', 'FKey', lvCDS);

          finally
            lvCDS.Free;
          end;
        finally
          lvADOOpera.setConnection(nil);
          lvADOOpera.Free;
        end;
      finally
        lvADOPool.releaseObject(lvADOConnection);
      end;
    end;
  except
    on E:Exception do
    begin
      TFileLogger.instance.logErrMessage(IntToStr(j) + '---' + e.Message);
    end;
  end;
end;

procedure TfrmMain.processTester_debugHaveError;
var
  lvADOPool:TADOConnectionPool;
  lvADOConnection:TADOConnection;
  lvADOOpera:TADOOperator;
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
      lvADOPool := dmMain.getConnectionPool('main');

      lvADOConnection :=TADOConnection(lvADOPool.borrowObject);
      try
        lvADOOpera := TADOOperator(dmMain.DBOperaPool.borrowObject);
        try
          try
            lvADOOpera.setConnection(lvADOConnection);
            lvADOOpera.ReOpen;
            lvXMLData := lvADOOpera.CDSProvider.QueryXMLData(__sql01);
          except
            on E:Exception do
            begin
              i:= 1;
              raise;
            end;
          end;
          try
            lvADOOpera.ReOpen;
            lvXMLData := lvADOOpera.CDSProvider.QueryXMLData(__sql02);
          except
            on E:Exception do
            begin
              i:= 2;
              TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);
              raise;
            end;
          end;
        finally
          //lvADOOpera.setConnection(nil);
          dmMain.DBOperaPool.releaseObject(lvADOOpera)
        end;
      finally
        lvADOPool.releaseObject(lvADOConnection);
      end;
    end;
  except
    on E:Exception do
    begin
      TFileLogger.instance.logErrMessage(IntToStr(i) + '---' + e.Message);
    end;
  end;
end;

procedure TfrmMain.processTester_debugPool;
var
  lvADOPool:TADOConnectionPool;
  lvADOConnection:TADOConnection;
  lvADOOpera:TADOOperator;
  lvXMLData:String;
  i, j:Integer;
begin
  try
    i:= 0;
    j:= 0;
    while j < 100 do
    begin
      Inc(j);
      lvADOOpera := TADOOperator(dmMain.DBOperaPool.borrowObject);
      try
        Sleep(100);
      finally
        dmMain.DBOperaPool.releaseObject(lvADOOpera)
      end;

      lvADOOpera := TADOOperator(dmMain.DBOperaPool.borrowObject);
      try
        Sleep(200);
      finally
        dmMain.DBOperaPool.releaseObject(lvADOOpera)
      end;
    end;
  except
    on E:Exception do
    begin
      TFileLogger.instance.logErrMessage(IntToStr(i) + '---' + e.Message);
    end;
  end;
end;

procedure TfrmMain.processTester_Scripter;
var
  lvScript:ISuperObject;
  s :String;
  i, j:Integer;
  lvDataSet:TClientDataSet;
  lvADOOpera:TADOOperator;
  lvConnection:TADOConnection;
begin
  try
    TFileLogger.instance.logMessage(Format('任务开始执行', []), 'scripter_');
    j:= 0;
    lvDataSet := TClientDataSet.Create(nil);
    try
      //从对象池中借用
      lvADOOpera := TADOOperator(dmMain.DBOperaPool.borrowObject);
      try
        lvConnection := dmMain.beginUseADOConnection('sys');
        try
          lvADOOpera.setConnection(lvConnection);
          lvDataSet.Data := lvADOOpera.CDSProvider.QueryData('select * from sys_Scripts');
        finally
          dmMain.endUseADOConnection('sys', lvConnection);
        end;
      finally
        dmMain.DBOperaPool.releaseObject(lvADOOpera);
      end;
      lvDataSet.First;
      while not lvDataSet.Eof do
      begin
        for j := 1 to 50 do
        begin
          try
            lvScript := SO();
            lvScript.I['key'] := lvDataSet.FieldByName('FBianHao').AsInteger;
            lvScript.I['step'] := j;
            lvScript.S['params.@mm_Key'] := '{64E95178-00FE-43C3-B478-0B3662F6367E}';
            s := dmMain.getSQLScript(lvScript);
            Inc(i);
          except
            on E:EScriptEmptyExcpeiton do
            begin
              
              s := '';
              Break;
            end;
          end;
        end;
        lvDataSet.Next;
      end;
    finally
      lvDataSet.Free;
    end;
  except
    on E:Exception do
    begin
      TFileLogger.instance.logErrMessage(IntToStr(i) + '---' + e.Message);
    end;
  end;
  TFileLogger.instance.logMessage(Format('任务执行完成,共成功解析(%d)', [i]), 'scripter_');
  s := '';
end;

destructor TfrmMain.Destroy;
begin
  FBuffer.Free;
  FIOCPConsole.close;
  FDecoder.Free;
  FEncoder.Free;
  FreeAndNil(FIOCPConsole);
  inherited Destroy;
end;

procedure TfrmMain.DoConfigEdit(pvEditing: Boolean);
var
  lvIsEditing:Boolean;
begin
  lvIsEditing := pvEditing;
  actConfigOK.Enabled := lvIsEditing and (not FIOCPConsole.Active);
  actConfigEdit.Enabled := (not lvIsEditing) and (not FIOCPConsole.Active);
  edtWorkCount.Enabled := actConfigOK.Enabled;
  edtPort.Enabled := actConfigOK.Enabled;
end;

procedure TfrmMain.actConfigEditExecute(Sender: TObject);
begin
  DoConfigEdit(true);
end;

procedure TfrmMain.actConfigOKExecute(Sender: TObject);
begin
  TAppJSonConfig.instance.Reload;
  TAppJSonConfig.instance.Config.I['config.port'] :=StrToInt(edtPort.Text);
  TAppJSonConfig.instance.Config.I['config.workcount'] := StrToInt(edtWorkCount.Text);
  TAppJSonConfig.instance.Save2File;
  DoConfigEdit(False);
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
   actStopService.Execute;
   if TWinServiceTools.applicationIsServiceModeRunning then
   begin
     __ServiceInstance.DoTerminate;
   end else
   begin
      //Application.Terminate;
      close;
   end;
end;

procedure TfrmMain.actRefreshClientINfoExecute(Sender: TObject);
var
  lvList:TList;
  i: Integer;
  lvClient:TClientContext;
  lvItem:TListItem;

  lvConnectINfo:TStrings;
begin
  lstClientINfo.Items.Clear;
  lvList:=TList.Create;
  lvConnectINfo := TStringList.Create;
  try
    TIOCPContextFactory.instance.IOCPContextPool.getUsingList(lvList);
    for i := 0 to lvList.Count - 1 do
    begin
      lvClient := TClientContext(lvList[i]);
      lvItem := lstClientINfo.Items.Add;
      lvItem.Caption := lvClient.RemoteAddr;
      lvItem.SubItems.Add(IntToStr(lvClient.RemotePort));
      lvItem.SubItems.Add(lvClient.StateINfo);

      lvConnectINfo.Add('=======================================');
      lvConnectINfo.Add(lvItem.Caption);
      lvConnectINfo.Add(IntToStr(lvClient.RemotePort));
      lvConnectINfo.Add(lvClient.StateINfo);
    end;

    lvConnectINfo.SaveToFile(ExtractFilePath(ParamStr(0)) + 'connectINfo.txt');
  finally
    lvConnectINfo.Free;
    lvList.Free;
  end;
end;

procedure TfrmMain.actShowMainExecute(Sender: TObject);
begin
  if not Visible then Show;
end;

procedure TfrmMain.actStartServiceExecute(Sender: TObject);
begin
  if not FIOCPConsole.Active then
  begin
    FIOCPConsole.Port := StrToInt(edtPort.Text);
    FIOCPConsole.WorkerCount := StrToInt(edtWorkCount.Text);
    FIOCPConsole.open;
  end;  
  refreshState;
  DoConfigEdit(False);
end;

procedure TfrmMain.refreshState;
begin
  actStartService.Enabled := not FIOCPConsole.Active;
  actStopService.Enabled := not actStartService.Enabled;

  if actStartService.Enabled then
    btnService.Action := actStartService
  else
    btnService.Action := actStopService;

end;

procedure TfrmMain.actStopServiceExecute(Sender: TObject);
begin
  FIOCPConsole.close;
  dmMain.resetPools;
  refreshState;
  DoConfigEdit(False);
end;

procedure TfrmMain.btn1Click(Sender: TObject);
var
  lvInteger, lvReadInteger, lvValidCount:Integer;
begin
  lvInteger := 0;
  FBuffer.AddBuffer(@lvInteger, SizeOf(Integer));

  lvValidCount := FBuffer.validCount;

  Memo1.Lines.Add(IntToStr(lvValidCount));

  FBuffer.AddBuffer(@lvInteger, SizeOf(lvInteger));
    
  lvInteger := 120;
  FBuffer.AddBuffer(@lvInteger, SizeOf(lvInteger));
  lvInteger := 0;
  FBuffer.AddBuffer(@lvInteger, SizeOf(lvInteger));

  FBuffer.markReaderIndex;
  FBuffer.readBuffer(@lvReadInteger, SizeOf(lvInteger));
  Memo1.Lines.Add(IntToStr(lvReadInteger));
  FBuffer.readBuffer(@lvReadInteger, SizeOf(lvInteger));
  Memo1.Lines.Add(IntToStr(lvReadInteger));

  FBuffer.markReaderIndex;
  FBuffer.readBuffer(@lvReadInteger, SizeOf(lvInteger));
  Memo1.Lines.Add(IntToStr(lvReadInteger));
  FBuffer.readBuffer(@lvReadInteger, SizeOf(lvInteger));
  Memo1.Lines.Add(IntToStr(lvReadInteger));

  FBuffer.clearBuffer;
  
end;

procedure TfrmMain.btnDiscountAllClientClick(Sender: TObject);
begin
  FIOCPConsole.DisconnectAllClientContext;
end;

function ScripterRunner(p: Pointer): Integer;
begin
  TfrmMain(p).processTester_Scripter
end;


function f(p: Pointer): Integer;
begin
  TfrmMain(p).processTester_debugHaveError;
end;

procedure TfrmMain.actKillDeadPoolObjectExecute(Sender: TObject);
begin
  ///10分钟的连接
  mmoPoolINfo.Clear;
  mmoPoolINfo.Lines.Add('---连接池超时检测----');
  mmoPoolINfo.Lines.Add(dmMain.PoolGroup.killDeadObject());
  mmoPoolINfo.Lines.Add('---连接池当前信息----');
  mmoPoolINfo.Lines.Add(dmMain.PoolGroup.getPoolINfo);

end;

procedure TfrmMain.btnOpenClick(Sender: TObject);
var
  i, iCount: Integer;
  tid: Cardinal; 
begin
  __sql01 := mmoSQL.Lines.Text;
  __sql02 := mmoSQL2.Lines.Text;

  iCount := StrToInt(edtThreadCount.Text);
  for i:=1 to iCount do
  begin
    BeginThread(nil,0,f,Self,0,tid);
  end;
end;

procedure TfrmMain.btnPoolINfoClick(Sender: TObject);
begin
  mmoPoolINfo.Clear;
  mmoPoolINfo.Lines.Add('---连接池信息----');
  mmoPoolINfo.Lines.Add(dmMain.PoolGroup.getPoolINfo);

  mmoPoolINfo.Lines.Add('---ADOOperator池信息----');
  mmoPoolINfo.Lines.Add(Format('(总数:%d,使用:%d)',
        [dmMain.DBOperaPool.Count,
        dmMain.DBOperaPool.getBusyCount]));
end;

procedure TfrmMain.btnScripterTesterClick(Sender: TObject);
var
  i, iCount: Integer;
  tid: Cardinal; 
begin
  __sql01 := mmoSQL.Lines.Text;
  __sql02 := mmoSQL2.Lines.Text;

  iCount := StrToInt(edtThreadCount.Text);
  for i:=1 to iCount do
  begin
    BeginThread(nil,0,ScripterRunner,Self,0,tid);
  end;
end;

procedure TfrmMain.icnmainDblClick(Sender: TObject);
begin
  Show();
  if not Visible then self.Visible :=true;
end;

procedure TfrmMain.WMSysCommand(var Message: TMessage);
begin
  if Message.WParam = SC_CLOSE then
  begin
    Visible := false;
  end else if Message.WParam = SC_MINIMIZE then
  begin
    Visible := false;
  end else 
    inherited;
end;

procedure TfrmMain.processTester1;
var
  lvADOPool:TADOConnectionPool;
  lvADOConnection:TADOConnection;
  lvADOOpera:TADOOperator;
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
      lvADOPool := dmMain.getConnectionPool('main');
      lvADOConnection :=TADOConnection(lvADOPool.borrowObject);
      try
        lvADOOpera := TADOOperator.Create;
        try
          try
            lvADOOpera.setConnection(lvADOConnection);
            lvADOOpera.ReOpen;
            lvXMLData := lvADOOpera.CDSProvider.QueryXMLData(__sql01);
          except
            on E:Exception do
            begin
              i:= 1;
              raise;
            end;
          end;
          try
            lvADOOpera.ReOpen;
            lvXMLData := lvADOOpera.CDSProvider.QueryXMLData(__sql02);
          except
            on E:Exception do
            begin
              i:= 2;
              //TADOConnectionTools.checkRaiseUncontrollableConnectionException(lvADOOpera.Connection);
              raise;
            end;
          end;
        finally
           lvADOOpera.Free;
        end;
      finally
        lvADOPool.releaseObject(lvADOConnection);
      end;
    end;
  except
    on E:Exception do
    begin
      TFileLogger.instance.logErrMessage(IntToStr(i) + '---' + e.Message);
    end;
  end;
end;



initialization
  TFileLogger.instance.setAddThreadINfo(True);

end.
