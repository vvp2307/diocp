unit uDBAccessOperator;

interface

uses
  uICDSOperator, Classes, SysUtils, Uni;

type
  TDBAccessOperator = class(TInterfacedObject, IDBAccessOperator)
  private
    FOutString: String;
    FQuery: TUniQuery;
  public
    function executeSQL(pvCmdText:PAnsiChar): Integer; stdcall;
    function getTableFields(pvTable:PAnsiChar):PAnsiChar;stdcall;
  public
    constructor Create;
    destructor Destroy; override;
    procedure setConnection(connection: TUniConnection);
  end;

implementation

constructor TDBAccessOperator.Create;
begin
  inherited Create;
  FQuery := TUniQuery.Create(nil);
  FQuery.DisableControls;
  FQuery.ParamCheck := false;
end;

destructor TDBAccessOperator.Destroy;
begin
  FQuery.Free;
  inherited Destroy;
end;

{ TDBAccessOperator }

function TDBAccessOperator.executeSQL(pvCmdText:PAnsiChar): Integer;
begin
  FQuery.SQL.Clear;
  FQuery.SQL.Add(pvCmdText);
  FQuery.ExecSQL;
  Result := -1;
end;

function TDBAccessOperator.getTableFields(pvTable: PAnsiChar): PAnsiChar;
var
  lvStrs: TStringList;
begin
  if FQuery.Connection = nil then raise Exception.Create('√ª”–≈‰÷√Connection(TDBAccessOperator.getTableFields)');

  lvStrs := TStringList.Create;
  try
    FQuery.Connection.GetFieldNames(pvTable, lvStrs);
    FOutString := StringReplace(lvStrs.Text, sLineBreak, ';', [rfReplaceAll]);

    Result := PAnsiChar(FOutString);    
  finally
    lvStrs.Free;
  end;
end;

procedure TDBAccessOperator.setConnection(connection: TUniConnection);
begin
  FQuery.Connection := connection;
end;

end.
