unit uUniPoolGroupTools;

interface

uses
  uUniConnectionPool, uUniConnectionPoolGroup, superobject,
  SysUtils, Classes;

type
  TUniPoolGroupTools = class(TObject)
  public
    class function JsnParseFromFile(pvFile: string): ISuperObject;

    /// <summary>TUniPoolGroupTools.loadconfig
    /// </summary>
    /// <param name="pvPoolGroup"> (TUniConnectionPoolGroup) </param>
    /// <param name="pvConfigFile">
    /// {
    ///    "main":
    ///     {
    ///        connectionString:"",
    /// 	  },
    /// }
    /// </param>
    class function loadconfig(const pvPoolGroup: TUniConnectionPoolGroup): Boolean;
  end;

implementation

class function TUniPoolGroupTools.JsnParseFromFile(pvFile: string):
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

class function TUniPoolGroupTools.loadconfig(const pvPoolGroup:
    TUniConnectionPoolGroup): Boolean;
var
  lvJSon:ISuperObject;
  lvItem:TSuperObjectIter;
  lvConnectString:String;
  lvPool:TUniConnectionPool;
  lvConfigFile:String;
begin
  lvConfigFile := ExtractFilePath(ParamStr(0)) + 'config\dbpool.config';
  if not FileExists(lvConfigFile) then
  begin
    Result := false;
    exit;
  end;

  lvJSon := JsnParseFromFile(lvConfigFile);

  try
    if ObjectFindFirst(lvJSon, lvItem) then
    repeat

      lvPool := TUniConnectionPool.Create;
      if lvItem.val.I['maxcount'] <> 0 then
      begin
        //最大连接数
        lvPool.MaxNum := lvItem.val.I['maxcount'];
      end else
      begin
        lvPool.MaxNum := 5;
      end;

    
      if lvItem.val.O['connectionString'] <> nil then
      begin
        lvPool.InitializeConnectionString(lvItem.val.S['connectionString']);
      end else
      begin
        raise Exception.CreateFmt(
          '%s没有设置正确的连接串[connectionString]', [lvItem.key]);
      end;
      pvPoolGroup.Add(lvItem.key,
        lvPool
        );

    until not ObjectFindNext(lvItem);
  finally
    ObjectFindClose(lvItem);
  end;



  
end;

end.
