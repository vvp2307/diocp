unit scriptParser;
{
  //2011年4月24日15:17:15, 修改了ObjectFind引起的内存泄露
  //Mofen
}

interface

uses
  superobject, SysUtils, Classes, uStrUtils, JsonUtils, DB, SyncObjs,
  IntfObject, uIScriptParser, uIConfigLoader;

const
  SCRIPT_HEAD = 'head';
  SCRIPT_END = 'end';
  SCRIPT_SEC = 'sec_';

  SUBITEM_L = '[#SUBITEM(';
  SUBITEM_R = ')]';


type
  EScriptEmptyExcpeiton = class(Exception);

  TParseType = (ptNormal, ptSQL);

  /// <summary>
  /// 脚本载入基类
  /// </summary>
  TBsScriptLoader = class(TObject)
  protected
    function GetScript(pvIndex: string): WideString; overload; virtual; abstract;
    function GetScript(pvIndex: string; pvVer: string): WideString; overload; virtual; abstract;

    function GetSQLConfig(pvIndex: string): ISuperObject; virtual; abstract;
  end;

  /// <summary>
  /// 脚本解析管理
  /// </summary>
  TScriptParser = class(TIntfObject, IScriptParser)
  private
    FGetMode: Integer; //获取方式0,默认, 1使用新的方式
    function GetScriptKey: Integer; stdcall;
    function GetScriptStep: Integer; stdcall;

    procedure SetScriptKey(const Value: Integer); stdcall;
    procedure SetScriptStep(const Value: Integer); stdcall;

    function GetObject: TObject; stdcall;
  private
    //线程互斥
    FCS: TCriticalSection;

    FScriptCache: ISuperObject;
    FScriptLoader: TBsScriptLoader;

    FParamList: string;
    FSysVars: string;
    FParamValues: string;

    //用户设置的值
    FParamSetValue: ISuperObject;
    FParseType: TParseType;

    FScript: string;
    FScriptKey: Integer;
    FScriptStep: Integer;
    FThreadSafe: Boolean;

    function GetSysBeginScript: string;
    function GetSysEndScript: string;
    procedure SetParamSetValue(const pvIndex: string; const AValue: Variant); stdcall;
  protected
    procedure ProcessParamList(vParam: ISuperObject);
    procedure ProcessParamListAsSQL(vParam: ISuperObject);
    procedure ProcessReplParam(vParam: ISuperObject);
    function CheckOutScript(pvScriptKey: Integer): ISuperObject;
    function CheckOutStepScript(pvScriptKey: Integer; pvStep: Integer): string;
  protected
    function GetParamList(): ISuperObject;
    function GetReplParamList(): ISuperObject;

    /// <summary>
    ///   解析子脚本
    /// </summary>
    procedure ParseSubScript;

    procedure CheckScriptLoader();
  public



    function GetParamPackage: ISuperObject;

    //合并参数
    procedure MergeJsnParams(pvJsnParams: ISuperObject; pvOverlay: Boolean); stdcall;

    procedure MergeParameters(pvParam: ISuperObject; pvClearBefore: Boolean = true);
    procedure CheckReady;
    constructor Create(pvScriptLoader: TBsScriptLoader);
    destructor Destroy; override;
    function ParseScriptAsSpExec(pvRaiseIfEmpty: Boolean = true): WideString;
    function ParseScriptAsSQL(pvRaiseIfEmpty: Boolean = true): WideString;


    function ParseScript(pvRaiseIfEmpty: Boolean = true): WideString; stdcall;

    //使用新的加载方式解析SQL
    function ParseSQLScript(pvRaiseIfEmpty: Boolean = true): WideString; stdcall;


    //打包脚本对象到JSon
    ///
    ///  {key:1,step:1,params:{@mm_Key:"xxxx---"}}
    function packScript: ISuperObject; stdcall;



    procedure Clear; stdcall;
    procedure ClearCache;

    procedure Lock; stdcall;
    procedure UnLock; stdcall;

    function ParamValueAsString(const pvIndex: string): string;
    property ParamSetValue[const pvIndex: string]: Variant write SetParamSetValue; default;
    property ScriptKey: Integer read GetScriptKey write SetScriptKey;
    property ScriptStep: Integer read GetScriptStep write SetScriptStep;

    property ParseType: TParseType read FParseType write FParseType;

    property ThreadSafe: Boolean read FThreadSafe write FThreadSafe;


  end;


implementation

uses FastStrings, FastStringFuncs, Variants, Forms, Dialogs;

type
  /// <summary>
  /// 解析子脚本
  /// </summary>
  TSubScriptParser = class(TObject)
  private
    FScriptParser: TScriptParser;
    FWorkCount: Integer;
  protected
    procedure ProcessSubItemScript(pvScriptKey: Integer; const vJsnParam,
      vReplParam: ISuperObject);
  public
    constructor Create;
    destructor Destroy; override;
  end;

function TScriptParser.CheckOutScript(pvScriptKey: Integer): ISuperObject;
var
  lvKey: string;
  s: string;
  lvItem: ISuperObject;
begin
  lvKey := IntToStr(pvScriptKey);
  if FScriptCache.O[lvKey] = nil then
  begin
    if FGetMode = 1 then
    begin
      FScriptCache.O[lvKey] := FScriptLoader.GetSQLConfig(IntToStr(pvScriptKey));
    end else
    begin
      s := FScriptLoader.GetScript(lvKey);
      if s <> '' then
      begin
        lvItem := SO(s);
        try
          FScriptCache.O[lvKey] := lvItem;
        finally
          lvItem := nil;
        end;
      end;
    end;
  end;
  Result := FScriptCache.O[lvKey];
end;

function TScriptParser.CheckOutStepScript(pvScriptKey,
  pvStep: Integer): string;
var
  lvScriptItem: ISuperObject;
  lvSecKey: string;
begin
  lvScriptItem := CheckOutScript(pvScriptKey);
  if lvScriptItem <> nil then
  try
    lvSecKey := SCRIPT_SEC + IntToStr(pvStep);
    Result := lvScriptItem.S['script.' + lvSecKey];
  finally
    lvScriptItem := nil;
  end;  
end;

procedure TScriptParser.CheckReady;
begin
  if (ScriptKey = 0) or (ScriptStep = 0) then
  begin
    raise Exception.Create('ScriptKey 和 ScriptStep 不能为0！');
  end;
end;

procedure TScriptParser.CheckScriptLoader;
begin
  if FScriptLoader = nil then
    raise Exception.Create('不能解析SQL!没有检测到ScriptLoader对象');
end;

procedure TScriptParser.Clear;
begin
  FParamSetValue.Clear();
end;

procedure TScriptParser.ClearCache;
begin
  FScriptCache.Clear();
end;

constructor TScriptParser.Create(pvScriptLoader: TBsScriptLoader);
begin
  inherited Create;
  FScriptLoader := pvScriptLoader;
  FScriptCache := SO();

  FParamSetValue := SO([]);
  FParseType := ptNormal;

  FCS := TCriticalSection.Create;
end;

destructor TScriptParser.Destroy;
begin
  FCS.Free;
  FParamSetValue := nil;
  FScriptCache := nil;
  inherited Destroy;
end;

function TScriptParser.GetObject: TObject;
begin
  Result := Self;
end;

function TScriptParser.GetParamList: ISuperObject;
var
  lvItem: ISuperObject;
begin
  lvItem := CheckOutScript(FScriptKey);
  if lvItem <> nil then
  try
    Result := lvItem.O['param'];
  finally
    lvItem := nil;
  end;
end;

function TScriptParser.GetParamPackage: ISuperObject;
begin
  Result := Self.FParamSetValue;
end;

function TScriptParser.ParamValueAsString(const pvIndex: string): string;
begin
  Result := FParamSetValue.S[pvIndex];
end;

function TScriptParser.GetReplParamList: ISuperObject;
var
  lvItem: ISuperObject;
begin
  lvItem := CheckOutScript(FScriptKey);
  if lvItem <> nil then
  try
    Result := lvItem.O['repl'];
  finally
    lvItem := nil;
  end;

end;

procedure TScriptParser.Lock;
begin
  if ThreadSafe then FCS.Enter;
end;

procedure TScriptParser.MergeJsnParams(pvJsnParams: ISuperObject;
  pvOverlay: Boolean);
begin
  if pvJsnParams = nil then Exit;
  FParamSetValue.Merge(pvJsnParams, false, pvOverlay);
end;

procedure TScriptParser.MergeParameters(pvParam: ISuperObject; pvClearBefore:
  Boolean = true);
begin
  if pvParam = nil then Exit;
  if pvClearBefore then FParamSetValue.Clear(True);
  FParamSetValue.Merge(pvParam);
end;

function TScriptParser.ParseScript(pvRaiseIfEmpty: Boolean = true): WideString;
begin
  case FParseType of
    ptSQL: Result := ParseScriptAsSQL(pvRaiseIfEmpty);
  else
    Result := ParseScriptAsSpExec(pvRaiseIfEmpty);
  end;
end;

function TScriptParser.ParseScriptAsSpExec(pvRaiseIfEmpty: Boolean = true):
  WideString;
var
  lvParam, lvRepl, lvItem: ISuperObject;
  lvSecKey: string;
begin
  CheckScriptLoader;

  ParseSubScript();

  lvItem := CheckOutScript(FScriptKey);

  if lvItem <> nil then
  try
    lvSecKey := SCRIPT_SEC + IntToStr(FScriptStep);

    FScript := lvItem.S['script.' + lvSecKey];
    if FScript <> '' then
    begin
      lvParam := lvItem.O['param'];
      lvRepl := lvItem.O['repl'];
      try
        ProcessParamList(lvParam);
        ProcessReplParam(lvRepl);
      finally
        lvParam := nil;
        lvRepl := nil;
      end;
    end;

    if pvRaiseIfEmpty and (Trim(FScript) = '') then
    begin
      raise Exception.CreateFmt('脚本解析出现异常, 脚本(%d.%d)为空值', [FScriptKey, FScriptStep]);
    end;

    Result := Format('/* scriptkey = %d, scriptstep = %d */', [FScriptKey, FScriptStep]) + sLineBreak;
    Result := Result + 'EXEC sp_executesql ' + 'N' +
      sLineBreak +
      QuotedStr(FSysVars + GetSysBeginScript + FScript + GetSysEndScript) + sLineBreak + FParamList + FParamValues;
  finally
    lvItem := nil;
  end;

end;

function TScriptParser.ParseScriptAsSQL(pvRaiseIfEmpty: Boolean = true):
  WideString;
var
  lvParam, lvRepl, lvItem: ISuperObject;
  lvSecKey: string;
begin
  CheckScriptLoader;
  ParseSubScript();

  lvItem := CheckOutScript(FScriptKey);

  if lvItem <> nil then
  try
    lvSecKey := SCRIPT_SEC + IntToStr(FScriptStep);

    FScript := lvItem.S['script.' + lvSecKey];
    if FScript <> '' then
    begin
      lvParam := lvItem.O['param'];
      lvRepl := lvItem.O['repl'];

      ProcessParamListAsSQL(lvParam);
      ProcessReplParam(lvRepl);
    end;

    if pvRaiseIfEmpty and (Trim(FScript) = '') then
    begin
      raise EScriptEmptyExcpeiton.CreateFmt('脚本解析出现异常, 脚本(%d.%d)为空值', [FScriptKey, FScriptStep]);
    end;

    Result := Format('/* scriptkey = %d, scriptstep = %d */', [FScriptKey, FScriptStep]) + sLineBreak;
    Result := Result + FSysVars + GetSysBeginScript + FParamList + sLineBreak + FParamValues + FScript + sLineBreak + GetSysEndScript;
  finally
    lvItem := nil;
  end;
end;

procedure TScriptParser.ParseSubScript;
var
  lvParam, lvRepl: ISuperObject;
begin
  lvParam := SO();
  lvRepl := SO();
  try
    with TSubScriptParser.Create do
    try
      FScriptParser := self;
      ProcessSubItemScript(FScriptKey, lvParam, lvRepl);
    finally
      Free;
    end;
  finally
    lvParam := nil;
    lvRepl := nil;
  end;
end;

procedure TScriptParser.ProcessParamList(vParam: ISuperObject);
var
  lvItem: TSuperObjectIter;
  lvParamValue:ISuperObject;
  lvStr, lvValue: string;
begin
  FParamList := '';
  FParamValues := '';
  FSysVars := '';
  try
    if ObjectFindFirst(vParam, lvItem) then
    begin
      repeat
        if lvItem.val.I['kind'] = 0 then
        begin
          FParamList := FParamList + lvItem.key + ' ' + lvItem.val.S['type'] + ',';
          lvStr := LowerCase(lvItem.val.S['type']);

          lvParamValue := FParamSetValue.O[LowerCase(lvItem.key)];

          if lvParamValue = nil then lvValue := ''
          else lvValue := lvParamValue.AsString;

          if IfIn(lvStr, ['int', 'bigint', 'smallint', 'tinyint', 'image', 'money', 'bit']) then
          begin
            if lvValue = '' then lvValue := QuotedStr(lvValue);
          end else if Pos('numeric', lvStr) = 1 then
          begin
            if lvValue = '' then lvValue := QuotedStr(lvValue);
          end else if IfIn(lvStr, ['uniqueidentifier']) then
          begin
            if lvValue = '' then lvValue := 'NULL'
            else lvValue := QuotedStr(lvValue);
          end else if IfIn(lvStr, ['datetime']) then
          begin
            if lvParamValue = nil then lvValue := 'NULL'
            else if lvParamValue.IsType(stString) then
            lvValue := QuotedStr(lvValue)
            else lvValue := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', lvParamValue.AsDouble));
          end else
          begin
            lvValue := QuotedStr(lvValue);
          end;
          FParamValues := FParamValues + lvValue + ',';
        end else if lvItem.val.I['kind'] = 1 then
        begin
          FSysVars := FSysVars + Format('DECLARE %s %s', [lvItem.key, lvItem.val.S['type']]) + sLineBreak;
        end;
      until not ObjectFindNext(lvItem);
      if FParamList <> '' then
      begin
        SetLength(FParamList, Length(FParamList) - 1);
        SetLength(FParamValues, Length(FParamValues) - 1);

        FParamList := ', N''' + FParamList + ''',' + sLineBreak;
      end;
    end;
  finally
    if lvItem.Ite <> nil then
      ObjectFindClose(lvItem);
  end;

end;

procedure TScriptParser.ProcessParamListAsSQL(vParam: ISuperObject);
var
  lvItem: TSuperObjectIter;
  lvStr, lvValue: string;
  lvParamValue:ISuperObject;
begin
  FParamList := '';
  FParamValues := '';
  FSysVars := '';
  try
    if ObjectFindFirst(vParam, lvItem) then
    begin
      repeat
        if lvItem.val.I['kind'] = 0 then
        begin
          lvStr := Format('DECLARE %s %s', [lvItem.key, lvItem.val.S['type']]);

          FParamList := FParamList + lvStr + sLineBreak;

          lvStr := LowerCase(lvItem.val.S['type']);

          lvParamValue := FParamSetValue.O[LowerCase(lvItem.key)];
          if lvParamValue = nil then lvValue := ''
          else lvValue := lvParamValue.AsString;

          if IfIn(lvStr, ['int', 'bigint', 'smallint', 'tinyint', 'image', 'money']) then
          begin
            if lvValue = '' then lvValue := QuotedStr(lvValue);
          end else if Pos('numeric', lvStr) = 1 then
          begin
            if lvValue = '' then lvValue := QuotedStr(lvValue);
          end else if IfIn(lvStr, ['uniqueidentifier']) then
          begin
            if lvValue = '' then lvValue := 'NULL'
            else lvValue := QuotedStr(lvValue);
          end else if IfIn(lvStr, ['datetime']) then
          begin
            if lvParamValue = nil then lvValue := 'NULL'
            else if lvParamValue.IsType(stString) then
            lvValue := QuotedStr(lvValue)
            else lvValue := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', lvParamValue.AsDouble));
          end else
          begin
            lvValue := QuotedStr(lvValue);
          end;

          lvStr := Format(' SELECT %s=%s', [lvItem.key, lvValue]);
          FParamValues := FParamValues + lvStr + sLineBreak;
        end else if lvItem.val.I['kind'] = 1 then
        begin
          FSysVars := FSysVars + Format('DECLARE %s %s', [lvItem.key, lvItem.val.S['type']]) + sLineBreak;
        end;

      until not ObjectFindNext(lvItem);

      if FParamValues <> '' then
        FParamValues := FParamValues + '------------------------------------------------';
    end;
  finally
    ObjectFindClose(lvItem);
  end;
end;

procedure TScriptParser.ProcessReplParam(vParam: ISuperObject);
var
  lvItem: TSuperObjectIter;
begin

  try
    if ObjectFindFirst(vParam, lvItem) then
      repeat
        FScript := FastReplace(FScript, lvItem.key, FParamSetValue.S[LowerCase(lvItem.key)]);
      until not ObjectFindNext(lvItem);
  finally
    if lvItem.Ite <> nil then
      ObjectFindClose(lvItem);
  end;
end;

procedure TScriptParser.SetParamSetValue(const pvIndex: string; const AValue:
  Variant);
var
  lvKey: string;
begin
  lvKey := LowerCase(pvIndex);
  case FindVarData(AValue)^.VType of
    varInteger, varInt64, varWord, varSmallint:
      FParamSetValue.I[lvKey] := AValue;
    varDouble, varDate:
      FParamSetValue.D[lvKey] := AValue;
    varBoolean:
      if AValue then FParamSetValue.I[lvKey] := 1 else FParamSetValue.I[lvKey] := 0;
  else
    FParamSetValue.S[lvKey] := AValue;
  end;

end;

constructor TSubScriptParser.Create;
begin
  inherited Create;
  FWorkCount := 0;
end;

destructor TSubScriptParser.Destroy;
begin
  inherited Destroy;
end;

procedure TSubScriptParser.ProcessSubItemScript(pvScriptKey: Integer; const
  vJsnParam, vReplParam: ISuperObject);
var
  lvScriptItem: ISuperObject;
  lvItem: ISuperObject;
  lvKey, lvStep: Integer;
  lvScript, lvSubScript: string;
begin
  if FWorkCount > 100 then raise Exception.Create('解析子脚本超过100次，可能进入了相互引用!');

  lvScriptItem := FScriptParser.CheckOutScript(pvScriptKey);
  if lvScriptItem <> nil then
  begin
    try
      if lvScriptItem.I['subitems.count'] > 0 then
      begin
        lvScript := lvScriptItem.S['script'];
        while lvScriptItem.A['subitems.list'].Length > 0 do
        begin
          lvItem := lvScriptItem.A['subitems.list'].O[0];
          try
            lvKey := lvItem.I['key'];
            lvStep := lvItem.I['step'];
            if (lvKey = 0) or (lvKey = pvScriptKey) then
            begin
              if lvStep <> 0 then
              begin
                lvSubScript := FScriptParser.CheckOutStepScript(pvScriptKey, lvStep);
                lvScript := FastReplace(lvScript, lvItem.S['repl'], lvSubScript);
              end;
            end else if lvStep <> 0 then
            begin
              ProcessSubItemScript(lvKey, vJsnParam, vReplParam);
              lvSubScript := FScriptParser.CheckOutStepScript(lvKey, lvStep);
              lvScript := FastReplace(lvScript, lvItem.S['repl'], lvSubScript);
            end;
            lvScriptItem.A['subitems.list'].Delete(0);
          finally
            lvItem := nil;
          end;
        end;
        lvScriptItem.O['script'] := SO(lvScript);
      end;
      lvScriptItem.I['subitems.count'] := 0;

      //需要合并参数
      vJsnParam.Merge(lvScriptItem.O['param']);
      vReplParam.Merge(lvScriptItem.O['repl']);
      lvScriptItem.O['param'] := vJsnParam;
      lvScriptItem.O['repl'] := vReplParam;
    finally
      lvScriptItem := nil;
    end;
  end;



  inc(FWorkCount);
end;

function TScriptParser.GetScriptKey: Integer;
begin
  Result := FScriptKey;
end;

function TScriptParser.GetScriptStep: Integer;
begin
  Result := FScriptStep;
end;

function TScriptParser.GetSysBeginScript: string;
begin
  Result := '';
  //  Result := Result + '--------内置变量-------------' + sLineBreak;
  ////  Result := Result + 'DECLARE @_ErrMsg VARCHAR(300)   --错误信息' + sLineBreak;
  ////  Result := Result + 'DECLARE @_Int01 int        --存储值'   + sLineBreak;
  ////  Result := Result + 'DECLARE @_Int02 int        --存储值'   + sLineBreak;
  ////  Result := Result + 'DECLARE @_Str01 VARCHAR(300)   --存储值'   + sLineBreak;
  ////  Result := Result + 'DECLARE @_Str02 VARCHAR(300)   --存储值'   + sLineBreak;
  //  Result := Result + '--------内置变量-------------' + sLineBreak;
end;

function TScriptParser.GetSysEndScript: string;
begin
  Result := sLineBreak;
  Result := Result + 'GOTO _OK_END' + sLineBreak;
  Result := Result + '_ERR_END:' + sLineBreak;
  Result := Result + '_OK_END:' + sLineBreak;
end;

function TScriptParser.packScript: ISuperObject;
begin
  Result := SO();
  Result.I['key'] := self.FScriptKey;
  Result.I['step'] := self.FScriptStep;
  Result.O['params'] := FParamSetValue;
end;

function TScriptParser.ParseSQLScript(pvRaiseIfEmpty: Boolean = true):
  WideString;
begin
  FGetMode := 1;
  try
    Result := ParseScript(pvRaiseIfEmpty);
  finally
    FGetMode := 0;
  end;
end;

procedure TScriptParser.SetScriptKey(const Value: Integer);
begin
  FScriptKey := Value;
end;

procedure TScriptParser.SetScriptStep(const Value: Integer);
begin
  FScriptStep := Value;
end;

{ TScriptLoader }



procedure TScriptParser.UnLock;
begin
  if ThreadSafe then FCS.Leave;
end;

end.

