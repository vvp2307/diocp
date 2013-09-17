unit uUniPool;

interface

uses
  UntCobblerUniPool, uUniConfigTools, superobject;

type
  TUniPool = class(TObject)
  public
    class function getConnObject(pvID:string): TUniCobbler;
    class procedure releaseConnObject(const pvPoolObj: TUniCobbler);
    class procedure reset;
  end;


implementation

uses
  SyncObjs, ActiveX;

var
  __instance:TUniCobblerPool;
  __cache:ISuperObject;
  __cs:TCriticalSection;

class function TUniPool.getConnObject(pvID:string): TUniCobbler;
var
  lvObj:TUniCobbler;
  lvConnString:String;
begin
  lvConnString := __cache.S[pvID];
  if lvConnString = '' then
  begin
    __cs.Enter;
    try
      lvConnString := TUniConfigTools.getConnectionString(pvID);
      __cache.S[pvID] := lvConnString;
    finally
      __cs.Leave;
    end;
  end;
  Result := __instance.GetUniCon(lvConnString);
end;

class procedure TUniPool.releaseConnObject(const pvPoolObj: TUniCobbler);
begin
  __instance.FreeBackPool(pvPoolObj);
end;


class procedure TUniPool.reset;
begin
  __cache.Clear();
  __instance.FreeUniCon;
end;

initialization
  __instance := TUniCobblerPool.Create(20);
  __cache := SO();
  __cs := TCriticalSection.Create;
  CoInitialize(nil);


finalization
  __instance.Free;
  __cache := nil;
  __cs.Free;



end.
