unit uADOConnectionPool;

interface

uses
  uObjectPool, ADODB, SysUtils,ActiveX;

type
  TADOConnectionPool = class(TObjectPool)
  private
    FCommandTimeOut: Integer;
    FConnectionString:string;
  protected
    function createObject: TObject; override;
  public
    function beginUseObject: TObject; override;

    procedure endUseObject(const pvObj:TObject); override;
    procedure InitializeConnectionString(pvServerName, pvDBName, pvUser,
        pvPassword: string; pvUseWindowsSecurity: Boolean = false); overload;
    procedure InitializeConnectionString(pvConnectionString:String); overload;

    //秒数
    property CommandTimeOut: Integer read FCommandTimeOut write FCommandTimeOut;


  end;

implementation



const
  C_01_DATASOURCE = 'Provider=SQLOLEDB.1;Data Source=%s;';
  C_02_USERINFO = 'User ID=%s;Password=%s;';
  C_03_DATABASE = 'Initial Catalog=%s;';
  C_04_END = 'Persist Security Info=True';
  C_04_NTLOGIN_END = 'Integrated Security=SSPI;Persist Security Info=False';

function TADOConnectionPool.beginUseObject: TObject;
begin
  //暂时不用连接池....
  // 
  Result := createObject;  
end;

function TADOConnectionPool.createObject: TObject;
begin
  CoInitialize(nil);
  Result := TADOConnection.Create(nil);
  TADOConnection(Result).ConnectionString := FConnectionString;
  if FCommandTimeOut <> 0 then
  begin
    TADOConnection(Result).CommandTimeout := FCommandTimeOut;
  end;
  TADOConnection(Result).KeepConnection := true;
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

procedure TADOConnectionPool.endUseObject(const pvObj: TObject);
begin
  pvObj.Free;
end;

procedure TADOConnectionPool.InitializeConnectionString(
    pvConnectionString:String);
begin
  FConnectionString := pvConnectionString;
end;

end.
