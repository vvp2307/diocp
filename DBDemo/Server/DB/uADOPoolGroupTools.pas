unit uADOPoolGroupTools;

interface

uses
  uADOConnectionPool, uADOConnectionPoolGroup, superobject, uJSonTools,
  SysUtils;

type
  TADOPoolGroupTools = class(TObject)
  public
    /// <summary>TADOPoolGroupTools.loadconfig
    /// </summary>
    /// <param name="pvPoolGroup"> (IADOPoolGroup) </param>
    /// <param name="pvConfigFile">
    /// {
    ///    "main":
    ///     {
    /// 	    "host": "192.168.1.2",
    /// 		  "user": "sa",
    /// 		  "password": "efsa",
    /// 		  "database": "EF_DATA"
    /// 	  },
    /// }
    /// </param>
    class function loadconfig(const pvPoolGroup: TADOConnectionPoolGroup): Boolean;
  end;

implementation

class function TADOPoolGroupTools.loadconfig(const pvPoolGroup:
    TADOConnectionPoolGroup): Boolean;
var
  lvJSon:ISuperObject;
  lvItem:TSuperAvlEntry;
  lvConnectString:String;
  lvPool:TADOConnectionPool;
  lvConfigFile:String;
begin
  lvConfigFile := ExtractFilePath(ParamStr(0)) + 'config\dbpool.config';
  if not FileExists(lvConfigFile) then
  begin
    Result := false;
    exit;
  end;
  lvJSon := TJSonTools.JsnParseFromFile(lvConfigFile);
  for lvItem in lvJSon.AsObject do
  begin
    lvPool := TADOConnectionPool.Create; 
    if lvItem.Value.I['maxcount'] <> 0 then
    begin
      //最大连接数
      lvPool.MaxNum := lvItem.Value.I['maxcount'];
    end else
    begin
      lvPool.MaxNum := 5;
    end;

    //命令超时时间
    if lvItem.Value.I['commandTimeOut'] <> 0 then
    begin
      lvPool.CommandTimeOut := lvItem.Value.I['commandTimeOut'];
    end;

    
    if lvItem.Value.O['connectionString'] <> nil then
    begin
      lvPool.InitializeConnectionString(lvItem.Value.S['connectionString']);
    end else
    begin
      lvPool.InitializeConnectionString(
        lvItem.Value.S['host'],
        lvItem.Value.S['database'],
        lvItem.Value.S['user'],
        lvItem.Value.S['password']
        );
    end;
    lvPool.Name := lvItem.Name;
    pvPoolGroup.Add(lvItem.Name,
      lvPool
      );
  end;
  
end;

end.
