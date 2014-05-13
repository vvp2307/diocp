unit uDBAccessOperator;

interface

uses
  uICDSOperator, ADODB, Classes, SysUtils, StrUtils;

type
  TDBAccessOperator = class(TInterfacedObject, IDBAccessOperator)
  private
    FOutString: AnsiString;
    FADOQuery: TADOQuery;
  public
    function executeSQL(pvCmdText:PAnsiChar): Integer; stdcall;
    function getTableFields(pvTable:PAnsiChar):PAnsiChar;stdcall;
  public
    constructor Create;
    destructor Destroy; override;
    procedure setConnection(connection:TADOConnection);
  end;

implementation

constructor TDBAccessOperator.Create;
begin
  inherited Create;
  FADOQuery := TADOQuery.Create(nil);
  FADOQuery.DisableControls;
  FADOQuery.ParamCheck := false;
end;

destructor TDBAccessOperator.Destroy;
begin
  FADOQuery.Free;
  inherited Destroy;
end;

{ TDBAccessOperator }

function TDBAccessOperator.executeSQL(pvCmdText:PAnsiChar): Integer;
begin
  FADOQuery.SQL.Clear;
  FADOQuery.SQL.Add(pvCmdText);
  Result := FADOQuery.ExecSQL;
end;

function TDBAccessOperator.getTableFields(pvTable: PAnsiChar): PAnsiChar;
var
  lvStrs: TStringList;
begin
  if FADOQuery.Connection = nil then raise Exception.Create('√ª”–≈‰÷√Connection(TDBAccessOperator.getTableFields)');

  lvStrs := TStringList.Create;
  try
    FADOQuery.Connection.GetFieldNames(pvTable, lvStrs);
    FOutString := StringReplace(lvStrs.Text, sLineBreak, ';', [rfReplaceAll]);

    Result := PAnsiChar(FOutString);    
  finally
    lvStrs.Free;
  end;
end;

procedure TDBAccessOperator.setConnection(connection:TADOConnection);
begin
  FADOQuery.Connection := connection;
end;

end.
