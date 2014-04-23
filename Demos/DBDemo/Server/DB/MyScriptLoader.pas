unit MyScriptLoader;

interface

uses
  scriptParser, SysUtils, DB, MSSQLUtil;

type
  TMyScriptLoader = class(TBsScriptLoader)
  private
    FSQLUtil: TMSSQLUtil;
  protected
    function GetScript(pvIndex: string): WideString; override;
  public
    constructor Create(ASQLUtil: TMSSQLUtil);
    property SQLUtil: TMSSQLUtil read FSQLUtil write FSQLUtil;
  end;

implementation

constructor TMyScriptLoader.Create(ASQLUtil: TMSSQLUtil);
begin
  inherited Create;
  FSQLUtil := ASQLUtil;
end;

function TMyScriptLoader.GetScript(pvIndex: string): WideString;
begin
  if FSQLUtil = nil then raise Exception.Create('TMyScriptLoader没有传入SQLUtil值');
  Result := FSQLUtil.ExecuteAsString('select FScript from sys_Scripts where FBianHao=''' + pvIndex + '''');
end;

end.

