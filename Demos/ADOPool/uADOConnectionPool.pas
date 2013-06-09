unit uADOConnectionPool;

interface

uses
  uObjectPool, ADODB, SysUtils,ActiveX;

type
  TADOConnectionPool = class(TObjectPool)
  private
    FConnectionString:string;
  protected
    function createObject: TObject; override;
  public
    procedure InitializeConnectionString(pvServerName, pvDBName, pvUser,
        pvPassword: string; pvUseWindowsSecurity: Boolean = false); overload;
    procedure InitializeConnectionString(pvConnectionString:String); overload;
  end;

implementation



const
  C_01_DATASOURCE = 'Provider=SQLOLEDB.1;Data Source=%s;';
  C_02_USERINFO = 'User ID=%s;Password=%s;';
  C_03_DATABASE = 'Initial Catalog=%s;';
  C_04_END = 'Persist Security Info=True';
  C_04_NTLOGIN_END = 'Integrated Security=SSPI;Persist Security Info=False';

function TADOConnectionPool.createObject: TObject;
begin
  CoInitialize(nil);
  Result := TADOConnection.Create(nil);
  TADOConnection(Result).ConnectionString := FConnectionString;
end;

procedure TADOConnectionPool.InitializeConnectionString(pvServerName, pvDBName,
    pvUser, pvPassword: string; pvUseWindowsSecurity: Boolean = false);
var
  lvConnString:string;
begin
  lvConnString := Format(C_01_DATASOURCE, [pvServerName]);
  if not pvUseWindowsSecurity then
    lvConnString := lvConnString + Format(C_02_USERINFO, [pvUser, pvPassword]);

  lvConnString := lvConnString + Format(C_03_DATABASE, [pvDBName]);

  if pvUseWindowsSecurity then
    lvConnString := lvConnString + C_04_NTLOGIN_END
  else
    lvConnString := lvConnString + C_04_END;

  InitializeConnectionString(lvConnString);
end;

procedure TADOConnectionPool.InitializeConnectionString(
    pvConnectionString:String);
begin
  FConnectionString := pvConnectionString;
end;

end.
