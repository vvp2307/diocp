unit uAppJSonConfig;
{
   获取工程的主配置文件
   1.同名的Json文件
   2.Config目录下的同名的配置文件
   3.当前目录下面的配置文件(AppConfig.jsn)
   4.Config目录下配置文件(AppConfig.jsn)
}




interface

uses
  superobject, SysUtils, uJSonTools;

type
  TAppJSonConfig = class(TObject)
  private
    FConfig: ISuperObject;
    FAppPath: string;
    FFile: string;
  public
    procedure Reload;
    procedure Save2File;

    constructor Create;
    destructor Destroy; override;
    class function instance: TAppJSonConfig;
    property Config: ISuperObject read FConfig;
  end;

implementation

var
  __instance: TAppJSonConfig;

function __ApplicationPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
  if Result[Length(Result)] <> '\' then
    Result := Result + '\';
end;

constructor TAppJSonConfig.Create;
begin
  inherited Create;
  Reload;
end;

destructor TAppJSonConfig.Destroy;
begin
  FConfig := nil;
  inherited Destroy;
end;

class function TAppJSonConfig.instance: TAppJSonConfig;
begin
  if __instance = nil then
  begin
    __instance := TAppJSonConfig.Create;
  end;
  Result := __instance;
end;

procedure TAppJSonConfig.Reload;
var
  lvFileName: string;

  function innerLoadFile(pvFile: string): Boolean;
  begin
    Result := false;
    if FileExists(pvFile) then
    begin
      FConfig := TJSonTools.JsnParseFromFile(pvFile);
      Result := FConfig <> nil;
      if Result then
      begin
        FFile := pvFile;
      end;
    end;

  end;
begin
  FConfig := nil;                             
  FAppPath := __ApplicationPath;
  lvFileName := ExtractFileName(ChangeFileExt(ParamStr(0), '.jsn'));
  if innerLoadFile(FAppPath + lvFileName) then
  else if innerLoadFile(FAppPath + 'config\' + lvFileName) then
  else if innerLoadFile(FAppPath + 'appConfig.jsn') then
  else if innerLoadFile(FAppPath + 'config\appConfig.jsn') then
  else begin
    FFile := FAppPath + 'config\appConfig.jsn';
    FConfig := SO();
  end;
end;

procedure TAppJSonConfig.Save2File;
begin
  if FConfig <> nil then
  begin
    ForceDirectories(ExtractFilePath(FFile));    
    TJSonTools.JsnSaveToFile(FConfig, FFile);
  end;
end;

initialization
  __instance := nil;

finalization
  if __instance <> nil then
  begin
    __instance.Free;
    __instance := nil;
  end;

end.

