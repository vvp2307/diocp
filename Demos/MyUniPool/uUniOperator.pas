unit uUniOperator;

interface

uses
  uCDSProvider, uDBAccessOperator, uICDSOperator,
  superobject, Uni;

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
    procedure AfterConstruction; override;
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

procedure TUniOperator.AfterConstruction;
begin
  inherited;
  FCDSProvider := TCDSProvider.Create();

  //数据解码使用
  FDBAccessObj := TDBAccessOperator.Create;
  FDBAccessOperator := FDBAccessObj;
end;

constructor TUniOperator.Create;
begin
  inherited Create;

end;

destructor TUniOperator.Destroy;
begin
  FCDSProvider.Free;
  FDBAccessOperator := nil;
  inherited Destroy;
end;

procedure TUniOperator.ExecuteApplyUpdate(const pvEncodeData: AnsiString);
begin

end;

procedure TUniOperator.executeScript(pvSQLScript: String);
var
  lvSQL:AnsiString;
begin
  lvSQL := pvSQLScript;
  FDBAccessOperator.executeSQL(PAnsiChar(lvSQL));
  lvSQL := '';
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
