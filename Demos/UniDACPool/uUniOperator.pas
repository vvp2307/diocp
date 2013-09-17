unit uUniOperator;

interface

uses
  uCDSProvider, uDBAccessOperator, uICDSOperator,
  ADODB, CDSOperatorWrapper, superobject, Uni;

type
  TUniOperator = class(TObject)
  private
    FConnection: TUniConnection;
    FCDSProvider: TCDSProvider;
    FDBAccessObj:TDBAccessOperator;
    FDBAccessOperator:IDBAccessOperator;
    FTraceData: ISuperObject;

    
  public
    constructor Create;
    
    destructor Destroy; override;

    procedure ReOpen;

    procedure ExecuteApplyUpdate(const pvEncodeData: AnsiString);

    procedure executeScript(pvSQLScript:String);
    
    procedure setConnection(pvConnection: TUniConnection);

    property CDSProvider: TCDSProvider read FCDSProvider;

    property Connection: TUniConnection read FConnection write SetConnection;

    property TraceData: ISuperObject read FTraceData write FTraceData;     
  end;

implementation

uses
  DBAccess;

constructor TUniOperator.Create;
begin
  inherited Create;
  FCDSProvider := TCDSProvider.Create();

  //数据解码使用
  FDBAccessObj := TDBAccessOperator.Create;
  FDBAccessOperator := FDBAccessObj;
end;

destructor TUniOperator.Destroy;
begin
  FCDSProvider.Free;
  FDBAccessOperator := nil;
  inherited Destroy;
end;

procedure TUniOperator.ExecuteApplyUpdate(const pvEncodeData: AnsiString);
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

    if FTraceData <> nil then
    begin
      FTraceData.S['sqls[]'] := lvSQL;
    end;

    //事务执行脚本
    FConnection.StartTransaction;
    try
      FDBAccessOperator.executeSQL(PAnsiChar(lvSQL));
      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;

    //避免提前释放
    lvSQL := '';
  end;
end;

procedure TUniOperator.executeScript(pvSQLScript: String);
begin

end;

procedure TUniOperator.ReOpen;
begin
  FConnection.Close;
  FConnection.Open();  
end;

procedure TUniOperator.setConnection(pvConnection: TUniConnection);
begin
  FConnection := pvConnection;
  FCDSProvider.Connection := pvConnection;
  FDBAccessObj.setConnection(pvConnection);
end;

end.
