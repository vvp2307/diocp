unit udmMain;

interface

uses
  SysUtils, Classes, DB, ADODB, uCDSProvider, ADOConnConfig, uDBAccessOperator,
  uICDSOperator;

type
  TdmMain = class(TDataModule)
    conMain: TADOConnection;
  private
    FCDSProvider: TCDSProvider;

    FDBAccessOperator: IDBAccessOperator;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ExecuteApplyUpdate(const pvEncodeData: AnsiString);

    property CDSProvider: TCDSProvider read FCDSProvider;


    procedure DoConnnectionConfig;
  end;

var
  dmMain: TdmMain;

implementation

uses
  CDSOperatorWrapper;

{$R *.dfm}

constructor TdmMain.Create(AOwner: TComponent);
var
  lvDBAccess:TDBAccessOperator;
begin
  inherited Create(AOwner);
  FCDSProvider := TCDSProvider.Create();
  FCDSProvider.Connection := self.conMain;
  
  //数据解码使用
  lvDBAccess := TDBAccessOperator.Create;
  FDBAccessOperator := lvDBAccess;
  lvDBAccess.setConnection(self.conMain);

  TADOConnConfig.Instance.ADOConnection := conMain;
  TADOConnConfig.Instance.ReloadConfig;
end;

destructor TdmMain.Destroy;
begin
  //释放数据库操作接口
  FDBAccessOperator := nil;
  
  FCDSProvider.Free;
  TADOConnConfig.ReleaseInstance;
  inherited Destroy;
end;

procedure TdmMain.DoConnnectionConfig;
begin
  if TADOConnConfig.Instance.ConfigConnection then
  begin
    ;
  end;
end;

procedure TdmMain.ExecuteApplyUpdate(const pvEncodeData: AnsiString);
var
  lvSQL:AnsiString;
begin
  
  //进行解码
  with TCDSOperatorWrapper.createCDSDecode do
  begin
    setDBAccessOperator(FDBAccessOperator);
    setData(PAnsiChar(pvEncodeData));

    Execute;
    
    //解析好的SQL脚本
    lvSQL:= getUpdateSql;

    //事务执行脚本
    conMain.BeginTrans;
    try
      FDBAccessOperator.executeSQL(PAnsiChar(lvSQL));
      conMain.CommitTrans;
    except
      conMain.RollbackTrans;
      raise;
    end;

    //避免提前释放
    lvSQL := '';
  end;
end;

end.
