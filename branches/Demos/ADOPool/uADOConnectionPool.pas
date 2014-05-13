unit uADOConnectionPool;
/// <summary>
///  2014年4月9日 10:30:26
///    D10.天地弦
///
///   ADO连接池使用注意的地方
///     借出的连接组件，要保证其他线程的组件没有应用到该连接组件。
///     归还时，要确保引用该连接的其他组件都已经没有引用到该组件，
///     因为一旦归还，马上就可以被其他线程借出
///  使用经验:
///     连接池相对于其他池，最后第一个借用， 最后一个归还
/// </summary>

interface

uses
  uMyObjectPool, ADODB, SysUtils,ActiveX;

type
  TADOConnectionPool = class(TMyObjectPool)
  private
    FCommandTimeOut: Integer;
    FConnectionString:string;
  protected
    function createObject: TObject; override;
  public
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

procedure TADOConnectionPool.InitializeConnectionString(
    pvConnectionString:String);
begin
  FConnectionString := pvConnectionString;
end;

end.
