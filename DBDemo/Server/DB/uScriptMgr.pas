unit uScriptMgr;

interface

uses superobject, MyScriptLoader, MSSQLUtil, 
  scriptParser, SysUtils, Classes,  ADODB, uADOConnectionPool;


type
  TScriptMgr = class(TObject)
  private
    FConnection: TADOConnection;
    FConnectionPool: TADOConnectionPool;
    FSQLUtil: TMSSQLUtil;
    FScriptLoader: TBsScriptLoader;
    FScriptParser: TScriptParser;
  public
    procedure checkReady;
    constructor Create;
    destructor Destroy; override;
    
    procedure setConnection(pvConnection:TADOConnection);

    property Connection: TADOConnection read FConnection;
    
    //ÔÝÊ±´æ·Å
    property ConnectionPool: TADOConnectionPool read FConnectionPool write
        FConnectionPool;
        
    property ScriptParser: TScriptParser read FScriptParser;
  end;

implementation

procedure TScriptMgr.checkReady;
begin
  if FSQLUtil = nil then
  begin
    FSQLUtil := TMSSQLUtil.Create();
    FScriptLoader := TMyScriptLoader.Create(FSQLUtil);
    FScriptParser := TScriptParser.Create(FScriptLoader);
    FScriptParser.ParseType := ptSQL;
  end;
end;

constructor TScriptMgr.Create;
begin
  inherited Create; 
end;

destructor TScriptMgr.Destroy;
begin
  if FSQLUtil <> nil then
  begin
    FSQLUtil.Free;
    FScriptLoader.Free;
    FScriptParser.Free;
  end;
  inherited Destroy;
end;

procedure TScriptMgr.setConnection(pvConnection:TADOConnection);
begin
  FConnection := pvConnection;
  FSQLUtil.Connection := pvConnection;
end;

end.
