(*******************************************************************************
  自写unidac连接池
  不启用unidac自身池子


作者:Cobbler
     2011-1-23
     如有优化 请传作者一份 。谢谢！
     大富翁ID：eloveme
     邮箱：eloveme@tom.com
     QQ;250134558
********************************************************************************)

unit UntCobblerUniPool;

interface

uses
  classes, SysUtils, DateUtils, UntThreadTimer,
  Uni, DBAccess,
  SQLServerUniProvider, UniProvider, ActiveX;
//unidac必须的单元
//UniProvider, SQLServerUniProvider
//ODBCUniProvider,AccessUniProvider;
//数据库配置记录
//驱动;登陆用户;密码;服务器;数据库;端口;


type
  TUniCobbler = class
  private
    FFlag: boolean; //当前对象是否被使用
    FConnObj: TUniConnection; //数据库连接对象
    FConnStr: String;//连接字符串
    FAStart: TDateTime;//最后一次活动时间
  public
    constructor Create(tmpConnStr:string);overload;
    destructor Destroy;override;

    procedure checkConnect;

    property Flag:boolean  read FFlag write FFlag;
    property ConnObj: TUniConnection read FConnObj;
    property ConnStr: String read FConnStr write FConnStr;
    property AStart: TDateTime read FAStart write FAStart;
  end;

type
  TUniCobblerPool = class
    procedure OnMyTimer(Sender: TObject);//做轮询用
  private
    FPOOLNUMBER:Integer; //池大小
    FMPollingInterval:Integer;//轮询时间 以 分钟 为单位
    FList:TThreadList;//用来管理连接TADOCobbler
    FTime :TThreadedTimer;//主要做轮询
    FSXunHuan:Integer;//间隔多少秒 轮询一次 Flist

    function GetListCount:Integer; //返回池中 连接数
    procedure SetPoolCount(Value:Integer);//动态设置池大小
    function GetItems(Index: integer):TUniCobbler; //返回指定 TUniCobbler
    procedure SetFSXunHuan(Value:Integer);

    function CreateUniCobbler(const tmpConnStr:string):TUniCobbler;
  public
    constructor Create(const MaxNumBer:Integer;FreeMinutes :Integer= 60;TimerTime:Integer = 5000);overload;
    destructor Destroy;override;
    function GetUniCon(const tmpConnStr:string):TUniCobbler;//从池中取出可用的连接
    procedure FreeBackPool(Instance: TUniCobbler);//释放回归到池中

    procedure FreeUniCon; //回收池中许久未用的连接
    property Count:Integer read GetListCount;//返回已用池大小
    property  PoolCount:Integer read FPOOLNUMBER write SetPoolCount; //池容量属性
    property  Items[Index: integer]:TUniCobbler read GetItems;
    property Interval:Integer  read FSXunHuan write SetFSXunHuan;
  end;

implementation

uses
  ComObj;

{ TUniCobbler }
procedure TUniCobbler.checkConnect;
begin
  if not FConnObj.Connected then
  begin
    FConnObj.LoginPrompt := false;
    CoInitialize(nil);
    FConnObj.Connect;
  end;
end;

constructor TUniCobbler.Create(tmpConnStr: string);
begin
  FConnStr := tmpConnStr;
  FFlag := False;
  FAStart := Now;
  FConnObj := TUniConnection.Create(nil);
  FConnObj.ConnectString := tmpConnStr;
  FConnObj.LoginPrompt := False;
end;

destructor TUniCobbler.Destroy;
begin
  FFlag := False;
  FConnStr := '';
  FAStart := 0;
  if Assigned(FConnObj) then FreeAndNil(FConnObj);
  inherited;
end;

{ TUniCobblerPool }
constructor TUniCobblerPool.Create(const MaxNumBer:Integer;FreeMinutes :Integer= 60;TimerTime:Integer = 5000);
begin
  FPOOLNUMBER := MaxNumBer; //设置池大小
  FSXunHuan := TimerTime;//设置多少时间 秒 去轮询一次 Flist
  FMPollingInterval := FreeMinutes;// 连接池中 N 分钟 以上没用的 自动回收连接池
  FList := TThreadList.Create;
  FTime := TThreadedTimer.Create(nil);
  FTime.Enabled := False;
  FTime.Interval := TimerTime;//默认5秒检查一次
  FTime.OnTimer := OnMyTimer;
  FTime.Enabled := True;
end;

function TUniCobblerPool.CreateUniCobbler(
  const tmpConnStr: string): TUniCobbler;
begin
  Result := nil;
  Result := TUniCobbler.Create(tmpConnStr);
  if Assigned(Result) then
  begin
    Result.Flag := True;
    Result.AStart := Now;
  end;
end;

destructor TUniCobblerPool.Destroy;
var
  i:integer;
  LockedList: TList;
begin
  if Assigned(FTime) then FreeAndNil(FTime);
  if Assigned(FList) then
  begin
    LockedList := FList.LockList;
    try
      for i := LockedList.Count - 1 downto 0  do
        TUniCobbler(LockedList.Items[i]).Free;
    finally
      FList.UnlockList;
      FreeAndNil(FList);
    end;
  end;
end;

function TUniCobblerPool.GetItems(Index: integer): TUniCobbler;
var
  LockedList: TList;
begin
  Result := nil;
  LockedList := FList.LockList;
  try
    if (Index < 0) or (Index > LockedList.Count) then Exit;
    Result := TUniCobbler(LockedList.Items[Index]);
  finally
    FList.UnlockList;
  end;
end;

function TUniCobblerPool.GetListCount: Integer;
var
  LockedList: TList;
begin
  Result := 0;
  LockedList := FList.LockList;
  try
    Result := LockedList.Count;
  finally
    FList.UnlockList;
  end;
end;
//根据字符串连接参数 取出当前连接池可以用
function TUniCobblerPool.GetUniCon(const tmpConnStr:string):TUniCobbler;
var
  i:Integer;
  LockedList: TList;
begin
  Result := nil;
  LockedList := FList.LockList;
  try
    for I := 0 to LockedList.Count - 1 do
    begin
      if not TUniCobbler(LockedList.Items[i]).Flag then //可用
      begin
        if SameStr(LowerCase(tmpConnStr),LowerCase(TUniCobbler(LockedList.Items[i]).ConnStr)) then  //找到
        begin
          Result:= TUniCobbler(LockedList.Items[i]);
          Result.Flag := True; //标记已经分配用了
          Result.AStart := Now;//记录时间
          Break;//退出循环
        end;
      end;
    end; // end for
    //如果池中未找到 则创建
    if not Assigned(Result) then
    begin
      Result := CreateUniCobbler(tmpConnStr);
      if Assigned(Result) then
      begin
        //池未满则添加到池中
        if LockedList.Count < FPOOLNUMBER then LockedList.Add(Result);
      end;
    end;
  finally
    FList.UnlockList;
  end;
end;
//释放连接池对象
procedure TUniCobblerPool.FreeBackPool(Instance: TUniCobbler);
var
  I: Integer;
  LockedList: TList;
  isPool:Boolean;
begin
  if not Assigned(Instance) then Exit;
  isPool:= False;
  LockedList := FList.LockList;
  try
    for i := 0 to LockedList.Count - 1 do
    begin
      if TUniCobbler(LockedList.Items[i]) = Instance then
      begin
        Instance.Flag := False;
        Instance.AStart := Now;
        isPool := True;
        Break;
      end
    end;
    if not isPool then FreeAndNil(Instance);
  finally
    FList.UnlockList;
  end;
end;

procedure TUniCobblerPool.FreeUniCon;
var
  i:Integer;
  LockedList: TList;
  function MyMinutesBetween(const ANow, AThen: TDateTime): Integer;
  begin
    Result := Round(MinuteSpan(ANow, AThen));
  end;
begin
  LockedList := FList.LockList;
  try
    for I := LockedList.Count - 1 downto 0 do
    begin
      if MyMinutesBetween(Now,TUniCobbler(LockedList.Items[i]).AStart) >= FMPollingInterval then //释放池子许久不用的ADO
      begin
        TUniCobbler(LockedList.Items[i]).Free;
        LockedList.Delete(I);
      end;
    end;
  finally
    FList.UnlockList;
  end;
end;

procedure TUniCobblerPool.OnMyTimer(Sender: TObject);
begin
  FreeUniCon;
end;

procedure TUniCobblerPool.SetFSXunHuan(Value: Integer);
begin
  if FSXunHuan <> Value then FSXunHuan := Value;
end;

procedure TUniCobblerPool.SetPoolCount(Value: Integer);
begin
  //新设置的池大小 不允许 小于 上次设置的大小
  if Value = 0 then Exit;
  if FPOOLNUMBER < Value then FPOOLNUMBER := Value;
end;



end.
