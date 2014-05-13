unit uCDSProvider;

interface

uses
  DBClient, ADODB, Provider, SysUtils;

type
  TCDSProvider = class(TObject)
  private
    FADOQuery: TADOQuery;
    FCDSTemp:TClientDataSet;
    FConnection: TADOConnection;
    FProvider: TDataSetProvider;
    procedure SetConnection(const AValue: TADOConnection);
  public
    constructor Create;
    
    destructor Destroy; override;
    
    //获取一个CDS.DATA数据包
    function QueryData(pvCmdText: string; pvOperaMsg: string = ''): OleVariant;

    //获取一个CDS.XMLDATA数据包
    function QueryXMLData(pvCmdText: string; pvOperaMsg: string = ''): string;
    
    property Connection: TADOConnection read FConnection write SetConnection;
  end;

implementation

constructor TCDSProvider.Create;
begin
  inherited Create;
  FCDSTemp := TClientDataSet.Create(nil);
  FProvider := TDataSetProvider.Create(nil);
  FProvider.Options := FProvider.Options + [poIncFieldProps];

  FADOQuery := TADOQuery.Create(nil);
  FADOQuery.DisableControls;
  FADOQuery.ParamCheck := false;
  FProvider.DataSet := FADOQuery;
end;

destructor TCDSProvider.Destroy;
begin
  FreeAndNil(FCDSTemp);
  FreeAndNil(FADOQuery);
  FreeAndNil(FProvider);
  inherited Destroy;
end;

function TCDSProvider.QueryData(pvCmdText: string; pvOperaMsg: string = ''):
    OleVariant;
var
  i: Integer;
begin
  try
    FADOQuery.Close;
    FADOQuery.SQL.Clear;
    FADOQuery.SQL.Add(pvCmdText);
    FADOQuery.Open;
    for i := 0 to FADOQuery.FieldCount - 1 do
    begin
      FADOQuery.Fields[i].ReadOnly := false;
    end;
    Result := FProvider.Data;
  except on e: Exception do
    begin
       raise;
    end;
  end;

end;

function TCDSProvider.QueryXMLData(pvCmdText: string; pvOperaMsg: string =
    ''): string;
var
  i: Integer;
begin
  try
    FADOQuery.Close;
    FADOQuery.SQL.Clear;
    FADOQuery.SQL.Add(pvCmdText);
    FADOQuery.Open;
    for i := 0 to FADOQuery.FieldCount - 1 do
    begin
      FADOQuery.Fields[i].ReadOnly := false;
    end;

    FProvider.DataSet := FADOQuery;
    FCDSTemp.Data := FProvider.Data;
    Result := FCDSTemp.XMLData;
    FADOQuery.Close;
  except on e: Exception do
    begin
       raise;
    end;
  end; 
end;

procedure TCDSProvider.SetConnection(const AValue: TADOConnection);
begin
  FConnection := AValue;
  FADOQuery.Connection := FConnection;
end;

end.
