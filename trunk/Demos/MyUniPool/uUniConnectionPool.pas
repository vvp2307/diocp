unit uUniConnectionPool;

interface

uses
  uMyObjectPool, SysUtils,ActiveX, Uni;

type
  TUniConnectionPool = class(TMyObjectPool)
  private
    FCommandTimeOut: Integer;
    FConnectionString:string;
  protected
    function createObject: TObject; override;
  public
    procedure InitializeConnectionString(pvConnectionString:String); overload;

    //ÃëÊý
    property CommandTimeOut: Integer read FCommandTimeOut write FCommandTimeOut;


  end;

implementation




function TUniConnectionPool.createObject: TObject;
begin
  Result := TUniConnection.Create(nil);
  TUniConnection(Result).ConnectString := FConnectionString;
  if FCommandTimeOut <> 0 then
  begin
    //TUniConnection(Result).CommandTimeout := FCommandTimeOut;
  end;
end;

procedure TUniConnectionPool.InitializeConnectionString(
    pvConnectionString:String);
var
  lvConnectionString:String;
begin
  lvConnectionString := pvConnectionString;
  lvConnectionString := StringReplace(lvConnectionString, '%appPath%', ExtractFilePath(ParamStr(0)), [rfReplaceAll, rfIgnoreCase]);
  FConnectionString := lvConnectionString;
end;

end.
