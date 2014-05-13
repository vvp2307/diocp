unit uFrameConfig;

interface

uses
  superobject;

type
  TFrameConfig = class(TObject)
  public
    class procedure setBasePath(const pvBasePath: String);
    class function getBasePath():String;
  end;

implementation

var
  __store:ISuperObject;

class function TFrameConfig.getBasePath: String;
begin
  Result := __store.S['config.basePath'];
end;

class procedure TFrameConfig.setBasePath(const pvBasePath: String);
begin
  __store.S['config.basePath'] := pvBasePath;
end;

initialization
  __store := SO();

finalization
  __store := nil;

end.
