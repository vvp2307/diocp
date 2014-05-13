unit uUniConfigTools;

interface

uses
  superobject, Classes, SysUtils;


type
  TUniConfigTools = class(TObject)
  private
    class function loadConfig: ISuperObject;
    class procedure saveConfig(pvConfig: ISuperObject);
  public
    class procedure saveConnectionString(pvID:string; pvConnectionString:String);
    class function getConnectionString(pvID:string):string;

  end;

implementation

class function TUniConfigTools.getConnectionString(pvID: string): string;
var
  lvConfig:ISuperObject;
begin
  Result := '';
  lvConfig := loadConfig;
  if lvConfig = nil then exit;
  Result := lvConfig.S[pvID + '.connString'];
end;

class function TUniConfigTools.loadConfig: ISuperObject;
var
  lvStrings:TStrings;
  lvFile:String;
begin
  lvFile := ExtractFilePath(ParamStr(0)) + 'config\dbpool.config';
  if FileExists(lvFile) then
  begin
    lvStrings := TStringList.Create;
    try
      lvStrings.LoadFromFile(lvFile);
      Result := SO(lvStrings.Text);
      if (Result <> nil) and (Result.DataType <> stObject) then
      begin
        Result := nil;
      end;
    finally
      lvStrings.Free;
    end;
  end else
  begin
    Result := nil;
  end;
end;

{ TUniConfigTools }

class procedure TUniConfigTools.saveConfig(pvConfig: ISuperObject);
var
  lvStrings:TStrings;
begin
  if pvConfig = nil then exit;
  lvStrings := TStringList.Create;
  try
    lvStrings.Text := pvConfig.AsJSon(True, False);
    lvStrings.SaveToFile(ExtractFilePath(ParamStr(0)) + 'config\dbpool.config');
  finally
    lvStrings.Free;
  end;
end;

class procedure TUniConfigTools.saveConnectionString(pvID:string;
    pvConnectionString:String);
var
  lvConfig:ISuperObject;
begin
  lvConfig := loadConfig;
  if lvConfig = nil then lvConfig := SO();
  lvConfig.S[pvID + '.connString'] := pvConnectionString;
  saveConfig(lvConfig);
end;

end.
