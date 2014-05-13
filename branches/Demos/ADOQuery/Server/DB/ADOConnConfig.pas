unit ADOConnConfig;

interface

uses
  ADODB, DB, SysUtils, AdoConEd, IniFiles;

type
  TADOConnConfig = class(TObject)
  private
    FADOConnection: TADOConnection;
    FConfigFile: string;
    FSection: string;
    procedure WriteConfig;
  protected
    constructor CreateInstance;
    class function AccessInstance(Request: Integer): TADOConnConfig;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReConfig(pvFile: string = ''; pvSection: string = '');
    function ReloadConfig: Boolean;
    function ConfigConnection: Boolean;
    property ADOConnection: TADOConnection read FADOConnection write FADOConnection;
  public
    class function Instance: TADOConnConfig;
    class procedure ReleaseInstance;
  end;

implementation

constructor TADOConnConfig.Create;
begin
  inherited Create;
  ReConfig;
end;

constructor TADOConnConfig.CreateInstance;
begin
  Create;
end;

destructor TADOConnConfig.Destroy;
begin
  if AccessInstance(0) = Self then AccessInstance(2);
  inherited Destroy;
end;

class function TADOConnConfig.AccessInstance(Request: Integer): TADOConnConfig;
{$J+}
const FInstance          : TADOConnConfig = nil;
{$J-}
begin
  case Request of
    0: ;
    1: if not Assigned(FInstance) then FInstance := CreateInstance;
    2: FInstance := nil;
  else
    raise Exception.CreateFmt('Illegal request %d in AccessInstance', [Request]);
  end;
  Result := FInstance;
end;

{ TADOConnConfig }

procedure TADOConnConfig.ReConfig(pvFile: string = ''; pvSection: string = '');
begin
  if pvFile = '' then
  begin
    FConfigFile := ExtractFilePath(ParamStr(0)) + 'appConfig.ini';
  end else
  begin
    FConfigFile := pvFile;
  end;
  if pvSection = '' then
  begin
    FSection := 'main';
  end else
  begin
    FSection := pvSection;
  end;
end;

function TADOConnConfig.ConfigConnection: Boolean;
begin
  Result := false;
  FADOConnection.Close;
  if EditConnectionString(FADOConnection) then
  begin
    WriteConfig; 
    FADOConnection.Connected := true;
    Result := true;
  end;
end;

class function TADOConnConfig.Instance: TADOConnConfig;
begin
  Result := AccessInstance(1);
end;

class procedure TADOConnConfig.ReleaseInstance;
begin
  AccessInstance(0).Free;
end;

function TADOConnConfig.ReloadConfig: Boolean;
var
  lvIniFile              : TIniFile;
  lvString               : string;
begin
  lvIniFile := TIniFile.Create(FConfigFile);
  try
    Result := false;
    lvString := lvIniFile.ReadString(FSection, 'connectionstring', '');
    if lvString <> '' then
    begin
      try
        FADOConnection.Close;
        FADOConnection.ConnectionString := lvString;
        FADOConnection.Connected := true;
        Result := true;
      except
        Result := false;
      end;
    end;
  finally
    lvIniFile.Free;
  end;
end;

procedure TADOConnConfig.WriteConfig;
var
  lvIniFile              : TIniFile;
begin
  lvIniFile := TIniFile.Create(FConfigFile);
  try
    lvIniFile.WriteString(FSection, 'connectionstring', FADOConnection.ConnectionString);
  finally
    lvIniFile.Free;
  end;
end;

end.

