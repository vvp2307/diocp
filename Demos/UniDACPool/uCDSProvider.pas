unit uCDSProvider;

interface

uses
  DBClient, Provider, SysUtils, ActiveX, Uni;

type
  TMyUniQuery = class(TUniQuery)
  protected
    /// <summary>
    ///   覆盖掉，避免TDataSetProvider.data时执行PSReset时重复刷新
    /// </summary>
    procedure PSReset;override;

  end;

  TCDSProvider = class(TObject)
  private
    FQuery: TMyUniQuery;
    FCDSTemp:TClientDataSet;
    FConnection: TUniConnection;
    FProvider: TDataSetProvider;
    procedure SetConnection(const AValue: TUniConnection);
  public
    constructor Create;
    
    destructor Destroy; override;
    
    //获取一个CDS.DATA数据包
    function QueryData(pvCmdText: string; pvOperaMsg: string = ''): OleVariant;

    //获取一个CDS.XMLDATA数据包
    function QueryXMLData(pvCmdText: string): string;

    procedure ExecuteScript(pvCmdText:String; pvOperaMsg: string = '');

    property Connection: TUniConnection read FConnection write SetConnection;
  end;

implementation

constructor TCDSProvider.Create;
begin
  inherited Create;
  CoInitialize(nil);
  FCDSTemp := TClientDataSet.Create(nil);
  FProvider := TDataSetProvider.Create(nil);
  FProvider.Options := FProvider.Options + [poIncFieldProps];

  FQuery := TUniQuery.Create(nil);
  FQuery.DisableControls;
  FQuery.ParamCheck := false;
  FProvider.DataSet := FQuery;
end;

destructor TCDSProvider.Destroy;
begin
  FreeAndNil(FCDSTemp);
  FreeAndNil(FQuery);
  FreeAndNil(FProvider);
  inherited Destroy;
end;

procedure TCDSProvider.ExecuteScript(pvCmdText, pvOperaMsg: string);
begin
  try
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Add(pvCmdText);
    FQuery.ExecSQL;
  except on e: Exception do
    begin
       raise;
    end;
  end;
end;

function TCDSProvider.QueryData(pvCmdText: string; pvOperaMsg: string = ''):
    OleVariant;
var
  i: Integer;
begin
  try
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Add(pvCmdText);
    FQuery.Open;
    for i := 0 to FQuery.FieldCount - 1 do
    begin
      FQuery.Fields[i].ReadOnly := false;
    end;
    Result := FProvider.Data;
  except on e: Exception do
    begin
       raise;
    end;
  end;

end;

function TCDSProvider.QueryXMLData(pvCmdText: string): string;
var
  i: Integer;
begin
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add(pvCmdText);
  FQuery.Open;
  for i := 0 to FQuery.FieldCount - 1 do
  begin
    FQuery.Fields[i].ReadOnly := false;
  end;

  FProvider.DataSet := FQuery;
  FCDSTemp.Data := FProvider.Data;
  Result := FCDSTemp.XMLData;
  FQuery.Close;
end;

procedure TCDSProvider.SetConnection(const AValue: TUniConnection);
begin
  FConnection := AValue;
  FQuery.Connection := FConnection;
end;

{ TMyUniQuery }

procedure TMyUniQuery.PSReset;
begin
  //inherited PSReset;
  
end;

end.
