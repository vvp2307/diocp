unit uADOPoolGroupTools;

interface

uses
  uADOConnectionPool, uADOConnectionPoolGroup, superobject,
  SysUtils, Classes;

type
  TADOPoolGroupTools = class(TObject)
  public
    class function JsnParseFromFile(pvFile: string): ISuperObject;
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

class function TADOPoolGroupTools.JsnParseFromFile(pvFile: string):
    ISuperObject;
var
  lvStream: TMemoryStream;
  lvStr: AnsiString;
begin
  if FileExists(pvFile) then
  begin
    lvStream := TMemoryStream.Create;
    try
      lvStream.LoadFromFile(pvFile);
      lvStream.Position := 0;
      SetLength(lvStr, lvStream.Size);
      lvStream.ReadBuffer(lvStr[1], lvStream.Size);
      Result := SO(lvStr);
    finally
      lvStream.Free;
    end;
  end;
  if (Result = nil) or (not Result.IsType(stObject)) then Result := SO();
end;

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
  lvJSon := JsnParseFromFile(lvConfigFile);
  for lvItem in lvJSon.AsObject do
  begin
    lvPool := TADOConnectionPool.Create; 
    if lvItem.Value.I['maxcount'] <> 0 then
    begin
      //最大连接数
      lvPool.MaxCount := lvItem.Value.I['maxcount'];
    end else
    begin
      lvPool.MaxCount := 5;
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
    pvPoolGroup.Add(lvItem.Name,
      lvPool
      );
  end;
  
end;

end.
