unit qworker;

interface
{$I 'qdac.inc'}
{$DEFINE QWORKER_SIMPLE_LOCK}
uses
  classes,types,sysutils,SyncObjs
    {$IFDEF QDAC_UNICODE},system.Diagnostics{$ENDIF}
    {$IFDEF POSIX},Posix.Unistd{$ENDIF}
    ,qstring,qrbtree;
{*QWorker是一个后台工作者管理对象，用于管理线程的调度及运行。在QWorker中，最小的
工作单位被称为作业（Job），作业可以：
  1、在指定的时间点自动按计划执行，类似于计划任务，只是时钟的分辨率可以更高
  2、在得到相应的信号时，自动执行相应的计划任务
【限制】
  1.时间间隔由于使用0.1ms为基本单位，因此，32位整数最大值为2147483647，除以
864000000后就可得结果约为2.485天，因此，QWorker中的作业延迟和定时重复间隔最大为
2.485天。
  2、最少工作者数为2个，无论是在单核心还是多核心机器上，这是最低限制。你可以
设置的最少工作者数必需大于等于2。工作者上限没做实际限制。
  3、长时间作业数量不得超过最多工作者数量的一半，以免影响正常普通作业的响应。
*}
const
  JOB_RUN_ONCE      =$01;//作业只运行一次
  JOB_IN_MAINTHREAD =$02;//作业只能在主线程中运行
  JOB_MAX_WORKERS   =$04;//尽可能多的开启可能的工作者线程来处理作业，暂不支持
  JOB_LONGTIME      =$08;//作业需要很长的时间才能完成，以便调度程序减少它对其它作业的影响
  JOB_SIGNAL_WAKEUP =$10;//作业根据信号需要唤醒
  JOB_TERMINATED    =$20;//作业不需要继续进行，可以结束了
  WORKER_ISBUSY     =$01;//工作者忙碌
  WORKER_PROCESSLONG=$02;//当前处理的一个长时间作业
  WORKER_RESERVED   =$04;//当前工作者是一个保留工作者
  Q1MillSecond      =10;//1ms
  Q1Second          =10000;//1s
  Q1Minute          =600000;//60s/1min
  Q1Hour            =36000000;//3600s/60min/1hour
  Q1Day             =864000000;//1day
type
  TQJobs=class;
  TQWorker=class;
  TQWorkers=class;
  PQSignal=^TQSignal;
  PQJob=^TQJob;
  ///<summary>作业处理回调函数</summary>
  ///<param name="AJob">要处理的作业信息</param>
  TQJobProc=procedure (AJob:PQJob) of object;
  TQJob=record
    FirstRunTime:Int64;//第一次开始作业时间
    StartTime:Int64;//第一次作业开始时间,8B
    PushTime:Int64;//入队时间
    PopTime:Int64;//出队时间
    NextTime:Int64;//下一次运行的时间,+8B=16B
    WorkerProc:TQJobProc;//作业处理函数+8/16B
    Owner:TQJobs;//作业所隶属的队列
    Next:PQJob;//下一个结点
    Worker:TQWorker;//当前作业工作者
    Runs:Integer;//已经运行的次数+4B
    MinUsedTime:Integer;//最小运行时间+4B
    TotalUsedTime:Integer;//运行总计花费的时间，TotalUsedTime/Runs可以得出平均执行时间+4B
    MaxUsedTime:Integer;//最大运行时间+4B
    Flags:Integer;//作业标志位+4B
    Data:Pointer;//附加数据内容
    case Integer of
      0:(
        SignalId: Integer;//信号编码
        Source: PQJob;//源作业地址
        );
      1:
        (Interval:Integer;//运行时间间隔，单位为0.1ms，实际精度受不同操作系统限制+4B
        FirstDelay:Integer;//首次运行延迟，单位为0.1ms，默认为0
        );
  end;
  /// <summary>工作者记录的辅助函数</summary>
  TQJobHelper=record helper for TQJob
  private
    function GetAvgTime: Integer;inline;
    function GetInMainThread: Boolean;inline;
    function GetIsLongtimeJob: Boolean;inline;
    function GetIsSignalWakeup: Boolean;inline;
//    function GetRunMaxWorkers: Boolean;inline;
    function GetRunonce: Boolean;inline;
    procedure SetRunonce(const Value: Boolean);inline;
    procedure SetInMainThread(const Value: Boolean);inline;
    procedure SetIsLongtimeJob(const Value: Boolean);inline;
    procedure SetIsSignalWakeup(const Value: Boolean);inline;
    function GetIsTerminated: Boolean;inline;
    procedure SetIsTerminated(const Value: Boolean);inline;
    function GetEscapedTime: Int64;inline;
  protected
    procedure UpdateNextTime;
    procedure AfterRun(AUsedTime:Int64);
  public
    constructor Create(AProc:TQJobProc);overload;
    /// <summary>值拷贝函数</summary>
    /// <remarks>Worker/Next/Source不会复制并会被置空，Owner不会被复制</remarks>
    procedure Assign(const ASource:PQJob);
    /// <summary>重置内容，以便为从队列中弹出做准备</summary>
    procedure Reset;inline;
    /// <summary>平均每次运行时间，单位为0.1ms</summary>
    property AvgTime:Integer read GetAvgTime;
    /// <summmary>本次已运行时间，单位为0.1ms</summary>
    property EscapedTime:Int64 read GetEscapedTime;
    /// <summary>是否只运行一次，投递作业时自动设置</summary>
    property Runonce:Boolean read GetRunonce;
    /// <summary>是否要求在主线程执行作业，实际效果比Windows的PostMessage相似</summary>
    property InMainThread:Boolean read GetInMainThread;
    /// <summary>是否是一个运行时间比较长的作业，用Workers.LongtimeWork设置</summary>
    property IsLongtimeJob:Boolean read GetIsLongtimeJob;
    /// <summary>是否是一个信号触发的作业</summary>
    property IsSignalWakeup:Boolean read GetIsSignalWakeup;
    /// <summary>是否要求结束当前作业</summary>
    property IsTerminated:Boolean read GetIsTerminated write SetIsTerminated;
  end;
  //作业队列对象的基类，提供基础的接口封装
  TQJobs=class
  protected
    FOwner:TQWorkers;
    function InternalPush(AJob:PQJob):Boolean;virtual;abstract;
    function InternalPop:PQJob;virtual;abstract;
    function GetCount:Integer;virtual;abstract;
    function GetEmpty: Boolean;
    /// <summary>投寄一个作业</summary>
    /// <param name="AJob">要投寄的作业</param>
    /// <remarks>外部不应尝试直接投寄任务到队列，其由TQWorkers的相应函数内部调用。</remarks>
    function Push(AJob:PQJob):Boolean;virtual;
    /// <summary>弹出一个作业</summary>
    /// <returns>返回当前可以执行的第一个作业</returns>
    function Pop:PQJob;virtual;
    /// <summary>清空所有作业</summary>
    procedure Clear;overload;virtual;
    /// <summary>清空一个对象关联的所有作业</summary>
    procedure Clear(AObject:Pointer);overload;virtual;abstract;
  public
    constructor Create(AOwner:TQWorkers);overload;virtual;
    destructor Destroy;override;
    ///不可靠警告：Count和Empty值仅是一个参考，在多线程环境下可能并不保证下一句代码执行时，会一致
    property Empty:Boolean read GetEmpty;//当前队列是否为空
    property Count:Integer read GetCount;//当前队列元素数量
  end;
  {$IFDEF QWORKER_SIMPLE_LOCK}
  //一个基于位锁的简单锁定对象，使用原子函数置位
  TQSimpleLock=class
  private
    FFlags:Integer;
  public
    constructor Create;
    procedure Enter;inline;
    procedure Leave;inline;
  end;
  {$ELSE}
  TQSimpleLock=TCriticalSection;
  {$ENDIF}
  //TQSimpleJobs用于管理简单的异步调用，没有触发时间要求的作业
  TQSimpleJobs=class(TQJobs)
  protected
    FFirst:PQJob;
    FCount:Integer;
    FLocker:TQSimpleLock;
    function InternalPush(AJob:PQJob):Boolean;override;
    function InternalPop:PQJob;override;
    function GetCount:Integer;override;
    procedure Clear(AObject:Pointer);override;
  public
    constructor Create(AOwner:TQWorkers);override;
    destructor Destroy;override;
  end;

  //TQRepeatJobs用于管理计划型任务，需要在指定的时间点触发
  TQRepeatJobs=class(TQJobs)
  protected
    FItems:TQRBTree;
    FLocker:TCriticalSection;
    FFirstFireTime:Int64;
    function InternalPush(AJob:PQJob):Boolean;override;
    function InternalPop:PQJob;override;
    function DoTimeCompare(P1,P2:Pointer):Integer;
    procedure DoJobDelete(ATree:TQRBTree;ANode:TQRBNode);
    function GetCount:Integer;override;
    procedure Clear;override;
    procedure Clear(AObject:Pointer);override;
  public
    constructor Create(AOwner:TQWorkers);override;
    destructor Destroy;override;
  end;
  {工作者线程使用单向链表管理，而不是进行排序检索是因为对于工作者数量有限，额外
  的处理反而不会直接最简单的循环直接有效
  }
  TQWorker=class(TThread)
  private
    function GetInLongtimeJob: Boolean;
    function GetIsBusy: Boolean;
    function GetIsIdle: Boolean;
    function GetIsReserved: Boolean;
    procedure SetIsReserved(const Value: Boolean);
    procedure SetIsBusy(const Value: Boolean);
  protected
    FOwner:TQWorkers;
    FEvent:TEvent;
    FTimeout:Integer;
    FNext:TQWorker;
    FFlags:Integer;
    FActiveJob:PQJob;
    FActiveJobProc:TQJobProc;
    procedure Execute;override;
    procedure FireInMainThread;
  public
    constructor Create(AOwner:TQWorkers);overload;
    destructor Destroy;override;
    ///<summary>判断当前是否处于长时间作业处理过程中</summary>
    property InLongtimeJob:Boolean read GetInLongtimeJob;
    ///<summary>判断当前是否空闲</summary>
    property IsIdle:Boolean read GetIsIdle;
    ///<summary>判断当前是否忙碌</summary>
    property IsBusy:Boolean read GetIsBusy;
    ///<summary>判断当前工作者是否是内部保留的工作者
    property IsReserved:Boolean read GetIsReserved;
  end;
  /// <summary>信号的内部定义</summary>
  TQSignal=record
    Id:Integer;///<summary>信号的编码</summary>
    Fired:Integer;//<summary>信号已触发次数</summary>
    Name:QStringW;///<summary>信号的名称</summary>
    First:PQJob;///<summary>首个作业</summary>
  end;
  /// <summary>作业空闲原因，内部使用</summary>
  /// <remarks>
  ///  irNoJob : 没有需要处理的作业，此时工作者会进行15秒释放等待状态，如果在15秒内
  ///   有新作业进来，则工作者会被唤醒，否则超时后会被释放
  ///  irTimeout : 工作者已经等待超时，可以被释放
  TWorkerIdleReason=(irNoJob,irTimeout);
  /// <summary>工作者管理对象，用来管理工作者和作业</summary>
  TQWorkers=class
  protected
    FWorkers:array of TQWorker;
    FEnabled: Boolean;
    FMinWorkers: Integer;
    FLocker:TCriticalSection;
    FSimpleJobs:TQSimpleJobs;
    FRepeatJobs:TQRepeatJobs;
    FSignalJobs:TQHashTable;
//    FSignals:array of TQSignal;
    FTimeWorker:TThread;
    FMaxWorkers:Integer;
    FLongTimeWorkers:Integer;//记录下长时间作业中的工作者，这种任务长时间不释放资源，可能会造成其它任务无法及时响应
    FMaxLongtimeWorkers:Integer;//允许最多同时执行的长时间任务数，不允许超过MaxWorkers的一半
    FWorkerCount:Integer;
    FMaxSignalId:Integer;
    FTerminating:Boolean;
    function Popup:PQJob;
    procedure SetMaxWorkers(const Value: Integer);
    procedure SetEnabled(const Value: Boolean);
    procedure SetMinWorkers(const Value: Integer);
    procedure WorkerIdle(AWorker:TQWorker;AReason:TWorkerIdleReason);
    procedure WorkerBusy(AWorker:TQWorker);
    procedure WorkerTerminate(AWorker:TObject);
    procedure FreeJob(AJob:PQJob);
    function LookupIdleWorker:TQWorker;
    procedure ClearWorkers;
    procedure SignalWorkDone(AJob:PQJob;AUsedTime:Int64);
    procedure DoJobFree(ATable:TQHashTable;AHash:Cardinal;AData:Pointer);
    function Post(AJob:PQJob):Boolean;overload;
    procedure SetMaxLongtimeWorkers(const Value: Integer);
    function SignalIdByName(const AName:QStringW):Integer;
    procedure FireSignalJob(ASignal:PQSignal);
  public
    constructor Create;overload;
    destructor Destroy;override;
    /// <summary>投寄一个后台立即开始的作业</summary>
    /// <param name="AJob">要执行的作业过程</param>
    /// <param name="AData">作业附加的用户数据指针</param>
    /// <param name="ARunInMainThread">作业要求在主线程中执行</param>
    /// <returns>成功投寄返回True，否则返回False</returns>
    function Post(AProc:TQJobProc;AData:Pointer;ARunInMainThread:Boolean=False):Boolean;overload;
    /// <summary>投寄一个后台定时开始的作业</summary>
    /// <param name="AJob">要执行的作业过程</param>
    /// <param name="AInterval">要定时执行的作业时间间隔，单位为0.1ms，如要间隔1秒，则值为10000</param>
    /// <param name="AData">作业附加的用户数据指针</param>
    /// <param name="ARunInMainThread">作业要求在主线程中执行</param>
    /// <returns>成功投寄返回True，否则返回False</returns>
    function Post(AProc:TQJobProc;AInterval:Integer;AData:Pointer;ARunInMainThread:Boolean=False):Boolean;overload;
    /// <summary>投寄一个延迟开始的作业</summary>
    /// <param name="AJob">要执行的作业过程</param>
    /// <param name="AInterval">要延迟的时间，单位为0.1ms，如要间隔1秒，则值为10000</param>
    /// <param name="AData">作业附加的用户数据指针</param>
    /// <param name="ARunInMainThread">作业要求在主线程中执行</param>
    /// <returns>成功投寄返回True，否则返回False</returns>
    function Delay(AProc:TQJobProc;ADelay:Integer;AData:Pointer;ARunInMainThread:Boolean=False):Boolean;
    /// <summary>投寄一个等待信号才开始的作业</summary>
    /// <param name="AJob">要执行的作业过程</param>
    /// <param name="ASignalId">等待的信号编码，该编码由RegisterSignal函数返回</param>
    /// <param name="AData">作业附加的用户数据指针</param>
    /// <param name="ARunInMainThread">作业要求在主线程中执行</param>
    /// <returns>成功投寄返回True，否则返回False</returns>
    function Wait(AProc:TQJobProc;ASignalId:Integer;AData:Pointer;ARunInMainThread:Boolean=False):Boolean;
    /// <summary>投寄一个在指定时间才开始的重复作业</summary>
    /// <param name="AProc">要定时执行的作业过程</param>
    /// <param name="ADelay">第一次执行前先延迟时间</param>
    /// <param name="AInterval">后续作业重复频率</param>
    /// <param name="ARunInMainThread">是否要求作业在主线程中执行</param>
    function At(AProc:TQJobProc;const ADelay,AInterval:Integer;AData:Pointer;ARunInMainThread:Boolean=False):Boolean;overload;
    /// <summary>投寄一个在指定时间才开始的重复作业</summary>
    /// <param name="AProc">要定时执行的作业过程</param>
    /// <param name="ATime">执行时间</param>
    /// <param name="AInterval">后续作业重复频率</param>
    /// <param name="ARunInMainThread">是否要求作业在主线程中执行</param>
    function At(AProc:TQJobProc;const ATime:TDateTime;const AInterval:Integer;AData:Pointer;ARunInMainThread:Boolean=False):Boolean;overload;
    /// <summary>投寄一个后台长时间执行的作业</summary>
    /// <param name="AJob">要执行的作业过程</param>
    /// <param name="AData">作业附加的用户数据指针</param>
    /// <returns>成功投寄返回True，否则返回False</returns>
    /// <remarks>长时间作业强制在后台线程中执行，而不允许投递到主线程中执行</remarks>
    function LongtimeJob(AProc:TQJobProc;AData:Pointer):Boolean;
    /// <summary>清除一个对象相关的所有作业</summary>
    /// <param name="AObject">要释放的作业关联对象</param>
    /// <remarks>一个对象如果计划了作业，则在自己释放前应调用本函数以清除关联的作业，
    ///  否则，未完成的作业可能会触发异常。</remarks>
    procedure Clear(AObject:Pointer);overload;
    /// <summary>清除所有投寄的指定过程作业</summary>
    /// <remarks>当前版本暂时不支持，如果需要，请调用Clear(AObject)清除所有相关作业后再重新加入需处理作业</remarks>
    procedure Clear(AProc:TQJobProc);overload;
    /// <summary>触发一个信号</summary>
    /// <param name="AId">信号编码，由RegisterSignal返回</param>
    /// <remarks>触发一个信号后，QWorkers会触发所有已注册的信号关联处理过程的执行</remarks>
    procedure Signal(AId:Integer);overload;
    /// <summary>按名称触发一个信号</summary>
    /// <param name="AName">信号名称</param>
    /// <remarks>触发一个信号后，QWorkers会触发所有已注册的信号关联处理过程的执行</remarks>
    procedure Signal(const AName:QStringW);overload;
    /// <summary>注册一个信号</summary>
    /// <param name="AName">信号名称</param>
    /// <remarks>
    /// 1.重复注册同一名称的信号将返回同一个编码
    /// 2.信号一旦注册，则只有程序退出时才会自动释放
    ///</remarks>
    function RegisterSignal(const AName:QStringW):Integer;//注册一个信号名称
    /// <summary>最大允许工作者数量，不能小于2</summary>
    property MaxWorkers:Integer read FMaxWorkers write SetMaxWorkers;
    /// <summary>最小工作者数量，不能小于2<summary>
    property MinWorkers:Integer read FMinWorkers write SetMinWorkers;
    /// <summary>最大允许的长时间作业工作者数量，等价于允许开始的长时间作业数量</summary>
    property MaxLongtimeWorkers:Integer read FMaxLongtimeWorkers write SetMaxLongtimeWorkers;
    /// <summary>是否允许开始作业，如果为false，则投寄的作业都不会被执行，直到恢复为True</summary>
    /// <remarks>Enabled为False时已经运行的作业将仍然运行，它只影响尚未执行的作来</remarks>
    property Enabled:Boolean read FEnabled write SetEnabled;
    /// <summary>是否正在释放TQWorkers对象自身</summary>
    property Terminating:Boolean read FTerminating;
  end;
//获取系统中CPU的核心数量
function GetCPUCount:Integer;
//获取当前系统的时间戳，最高可精确到0.1ms，但实际受操作系统限制
function GetTimestamp:Int64;
//设置线程运行的CPU
procedure SetThreadCPU(AHandle:THandle;ACpuNo:Integer);
//原子锁定与运算
function AtomicAnd(var Dest:Integer;const AMask:Integer): Integer;
//原子锁定或运算
function AtomicOr(var Dest:Integer;const AMask:Integer):Integer;
{$IFNDEF QDAC_UNICODE}
//为与XE6兼容，InterlockedCompareExchange等价
function AtomicCmpExchange(var Target: Integer; Value: Integer; Comparand: Integer): Integer;inline;
//等价于InterlockedExchanged
function AtomicExchange(var Target:Integer;Value:Integer):Integer;inline;
{$ENDIF}
var
  Workers:TQWorkers;
implementation
{$IFDEF MSWINDOWS}
  uses windows;
{$ENDIF}
resourcestring
  SNotSupportNow='当前尚未支持功能 %s';
  STooFewWorkers='指定的最小工作者数量太少(必需大于等于2)。';
  STooManyLongtimeWorker='不能允许太多长时间作业线程(最多允许工作者一半)。';
{$IFDEF MSWINDOWS}
type
  TGetTickCount64=function:Int64;
  TJobPool=class
  protected
    FFirst:PQJob;
    FCount:Integer;
    FSize:Integer;
    FLocker:TQSimpleLock;
  public
    constructor Create(AMaxSize:Integer);overload;
    destructor Destroy;override;
    procedure Push(AJob:PQJob);
    function Pop:PQJob;
    property Count:Integer read FCount;
    property Size:Integer read FSize write FSize;
  end;

{$ENDIF}
var
  JobPool:TJobPool;
{$IFDEF QDAC_UNICODE}
  _Watch:TStopWatch;
{$ELSE}
  GetTickCount64:TGetTickCount64;
  _PerfFreq:Int64;
{$ENDIF}
//兼容2007版的原子操作接口
{$IFNDEF QDAC_UNICODE}
function AtomicCmpExchange(var Target: Integer; Value: Integer; Comparand: Integer): Integer;inline;
begin
Result:=InterlockedCompareExchange(Target,Value,Comparand);
end;
function AtomicIncrement(var Target: Integer): Integer;inline;
begin
Result:=InterlockedIncrement(Target);
end;
function AtomicDecrement(var Target:Integer):Integer;inline;
begin
Result:=InterlockedDecrement(Target);
end;
function AtomicExchange(var Target:Integer;Value:Integer):Integer;
begin
Result:=InterlockedExchange(Target,Value);
end;
{$ENDIF !QDAC_UNICODE}
//位与，返回原值
function AtomicAnd(var Dest:Integer;const AMask:Integer): Integer;inline;
var
  i:Integer;
begin
repeat
  Result:=Dest;
  i:=Result and AMask;
until AtomicCmpExchange(Dest,i,Result)=Result;
end;
//位或，返回原值
function AtomicOr(var Dest:Integer;const AMask:Integer):Integer;inline;
var
  i:Integer;
begin
repeat
  Result:=Dest;
  i:=Result or AMask;
until AtomicCmpExchange(Dest,i,Result)=Result;
end;
{$IFDEF MSWINDOWS}
//function InterlockedCompareExchange64
{$ENDIF}

procedure SetThreadCPU(AHandle:THandle;ACpuNo:Integer);
begin
{$IFDEF MSWINDOWS}
SetThreadIdealProcessor(AHandle,ACpuNo);
{$ELSE}
//Linux/Andriod/iOS暂时忽略,XE6未引入sched_setaffinity定义
{$ENDIF}
end;


//返回值的时间精度为100ns，即0.1ms
function GetTimestamp:Int64;
begin
{$IFDEF QDAC_UNICODE}
Result:=_Watch.Elapsed.Ticks div 1000;
{$ELSE}
if _PerfFreq>0 then
  begin
  QueryPerformanceCounter(Result);
  Result:=Result * 10000 div _PerfFreq;
  end
else if Assigned(GetTickCount64) then
  Result:=GetTickCount64*10000
else
  Result:=GetTickCount*10000;
{$ENDIF}
end;

function GetCPUCount:Integer;
{$IFDEF MSWINDOWS}
var
  si:SYSTEM_INFO;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
GetSystemInfo(si);
Result:=si.dwNumberOfProcessors;
{$ELSE}//Linux,MacOS,iOS,Andriod{POSIX}
  {$IFDEF POSIX}
  Result := sysconf(_SC_NPROCESSORS_ONLN);
  {$ELSE}//不认识的操作系统，CPU数默认为1
  Result:=1;
  {$ENDIF !POSIX}
{$ENDIF !MSWINDOWS}
end;
{ TQJob }

procedure TQJobHelper.AfterRun(AUsedTime: Int64);
begin
Inc(Runs);
if AUsedTime>0 then
  begin
  Inc(TotalUsedTime,AUsedTime);
  if MinUsedTime=0 then
    MinUsedTime:=AUsedTime
  else if MinUsedTime>AUsedTime then
    MinUsedTime:=AUsedTime;
  if MaxUsedTime=0 then
    MaxUsedTime:=AUsedTime
  else if MaxUsedTime<AUsedTime then
    MaxUsedTime:=AUsedTime;
  end;
end;

procedure TQJobHelper.Assign(const ASource: PQJob);
begin
StartTime:=ASource.StartTime;
PushTime:=ASource.PushTime;//入队时间
PopTime:=ASource.PopTime;
NextTime:=ASource.NextTime;
WorkerProc:=ASource.WorkerProc;//作业处理函数+8/16B
Runs:=ASource.Runs;
MinUsedTime:=ASource.MinUsedTime;//最小运行时间+4B
TotalUsedTime:=ASource.TotalUsedTime;
MaxUsedTime:=ASource.MaxUsedTime;
Flags:=ASource.Flags;
Data:=ASource.Data;
SignalId:=ASource.SignalId;
//下面三个成员不拷贝
Worker:=nil;
Next:=nil;
Source:=nil;
end;

constructor TQJobHelper.Create(AProc: TQJobProc);
begin
WorkerProc:=AProc;
SetRunOnce(True);
end;

function TQJobHelper.GetAvgTime: Integer;
begin
if Runs>0 then
  Result:=TotalUsedTime div Runs
else
  Result:=0;
end;

function TQJobHelper.GetInMainThread: Boolean;
begin
Result:=(Flags and JOB_IN_MAINTHREAD)<>0;
end;

function TQJobHelper.GetIsLongtimeJob: Boolean;
begin
Result:=(Flags and JOB_LONGTIME)<>0;
end;

function TQJobHelper.GetIsSignalWakeup: Boolean;
begin
Result:=(Flags and JOB_SIGNAL_WAKEUP)<>0;
end;

function TQJobHelper.GetIsTerminated: Boolean;
begin
if Assigned(Worker) then
  Result:=Worker.Terminated or ((Flags and JOB_TERMINATED)<>0)
else
  Result:=(Flags and JOB_TERMINATED)<>0;
end;

function TQJobHelper.GetEscapedTime: Int64;
begin
Result:=GetTimeStamp-StartTime;
end;

//function TQJobHelper.GetRunMaxWorkers: Boolean;
//begin
//Result:=(Flags and JOB_MAX_WORKERS)<>0;
//end;

function TQJobHelper.GetRunonce: Boolean;
begin
Result:=(Flags and JOB_RUN_ONCE)<>0;
end;

procedure TQJobHelper.Reset;
begin
FillChar(Self,SizeOf(TQJob),0);
end;

procedure TQJobHelper.SetInMainThread(const Value: Boolean);
begin
if Value then
  Flags:=Flags or JOB_IN_MAINTHREAD
else
  Flags:=Flags and (not JOB_IN_MAINTHREAD);
end;


procedure TQJobHelper.SetIsLongtimeJob(const Value: Boolean);
begin
if Value then
  Flags:=Flags or JOB_LONGTIME
else
  Flags:=Flags and (not JOB_LONGTIME);
end;

procedure TQJobHelper.SetIsSignalWakeup(const Value: Boolean);
begin
if Value then
  Flags:=Flags or JOB_SIGNAL_WAKEUP
else
  Flags:=Flags and (not JOB_SIGNAL_WAKEUP);
end;

procedure TQJobHelper.SetIsTerminated(const Value: Boolean);
begin
if Value then
  Flags:=Flags or JOB_TERMINATED
else
  Flags:=Flags and (not JOB_TERMINATED);
end;

//procedure TQJobHelper.SetRunMaxWorkers(const Value: Boolean);
//begin
//if Value then
//  Flags:=Flags or JOB_MAX_WORKERS
//else
//  Flags:=Flags and (not JOB_MAX_WORKERS);
//end;

procedure TQJobHelper.SetRunonce(const Value: Boolean);
begin
if Value then
  Flags:=Flags or JOB_RUN_ONCE
else
  Flags:=Flags and (not JOB_RUN_ONCE);
end;

procedure TQJobHelper.UpdateNextTime;
begin
if (Runs=0) and (FirstDelay<>0) then
  NextTime:=PushTime+FirstDelay
else if Interval<>0 then
  begin
  if NextTime=0 then
    NextTime:=GetTimeStamp+Interval
  else
    Inc(NextTime,Interval);
  end
else
  NextTime:=GetTimeStamp;
end;

{ TQSimpleJobs }


procedure TQSimpleJobs.Clear(AObject:Pointer);
var
  AJob,ANext:PQJob;
begin
//先将SimpleJobs所有的异步作业清空，以防止被弹出执行
FLocker.Enter;
AJob:=FFirst;
FFirst:=nil;
FLocker.Leave;
while AJob<>nil do
  begin
  ANext:=AJob.Next;
  if TMethod(AJob.WorkerProc).Data=AObject then
    begin
    AJob.Next:=nil;
    FOwner.FreeJob(AJob);
    end
  else
    InternalPush(AJob);
  AJob:=ANext;
  end;
end;

constructor TQSimpleJobs.Create(AOwner:TQWorkers);
begin
inherited Create(AOwner);
FLocker:=TQSimpleLock.Create;
end;

destructor TQSimpleJobs.Destroy;
begin
inherited;
FreeObject(FLocker);
end;

function TQSimpleJobs.GetCount: Integer;
begin
Result:=FCount;
end;

function TQSimpleJobs.InternalPop: PQJob;
begin
FLocker.Enter;
Result:=FFirst;
if Result<>nil then
  begin
  FFirst:=Result.Next;
  Dec(FCount);
  end;
FLocker.Leave;
end;

function TQSimpleJobs.InternalPush(AJob: PQJob):Boolean;
begin
FLocker.Enter;
AJob.Next:=FFirst;
FFirst:=AJob;
Inc(FCount);
FLocker.Leave;
Result:=True;
end;

{ TQJobs }

procedure TQJobs.Clear;
var
  AItem:PQJob;
begin
repeat
  AItem:=Pop;
  if AItem<>nil then
    FOwner.FreeJob(AItem)
  else
    Break;
until 1>2;
end;

constructor TQJobs.Create(AOwner:TQWorkers);
begin
inherited Create;
FOwner:=AOwner;
end;

destructor TQJobs.Destroy;
begin
  Clear;
  inherited;
end;

function TQJobs.GetEmpty: Boolean;
begin
Result:=(Count=0);
end;

function TQJobs.Pop: PQJob;
begin
Result:=InternalPop;
if Result<>nil then
  begin
  Result.PopTime:=GetTimeStamp;
  Result.Next:=nil;
  end;
end;

function TQJobs.Push(AJob: PQJob):Boolean;
begin
AJob.Owner:=Self;
AJob.PushTime:=GetTimeStamp;
Result:=InternalPush(AJob);
if not Result then
  begin
  AJob.Next:=nil;
  FOwner.FreeJob(AJob);
  end;
end;

{ TQRepeatJobs }

procedure TQRepeatJobs.Clear;
begin
FItems.Clear;
end;

procedure TQRepeatJobs.Clear(AObject: Pointer);
var
  ANode,ANext:TQRBNode;
  APriorJob,AJob,ANextJob:PQJob;
  ACanDelete:Boolean;
begin
//现在清空重复的计划作业
FLocker.Enter;
try
  ANode:=FItems.First;
  while ANode<>nil do
    begin
    ANext:=ANode.Next;
    AJob:=ANode.Data;
    ACanDelete:=True;
    APriorJob:=nil;
    while AJob<>nil do
      begin
      ANextJob:=AJob.Next;
      if TMethod(AJob.WorkerProc).Data=AObject then
        begin
        if ANode.Data=AJob then
          ANode.Data:=AJob.Next;
        if Assigned(APriorJob) then
          APriorJob.Next:=AJob.Next;
        AJob.Next:=nil;
        FOwner.FreeJob(AJob);
        end
      else
        begin
        ACanDelete:=False;
        APriorJob:=AJob;
        end;
      AJob:=ANextJob;
      end;
    if ACanDelete then
      FItems.Delete(ANode);
    ANode:=ANext;
    end;
finally
  FLocker.Leave;
end;
end;

constructor TQRepeatJobs.Create(AOwner:TQWorkers);
begin
inherited;
FItems:=TQRBTree.Create(DoTimeCompare);
FItems.OnDelete:=DoJobDelete;
FLocker:=TCriticalSection.Create;
end;

destructor TQRepeatJobs.Destroy;
begin
inherited;
FreeObject(FItems);
FreeObject(FLocker);
end;

procedure TQRepeatJobs.DoJobDelete(ATree: TQRBTree; ANode: TQRBNode);
begin
FOwner.FreeJob(ANode.Data);
end;

function TQRepeatJobs.DoTimeCompare(P1, P2: Pointer): Integer;
begin
Result:=PQJob(P1).NextTime-PQJob(P2).NextTime;
end;

function TQRepeatJobs.GetCount: Integer;
begin
Result:=FItems.Count;
end;

function TQRepeatJobs.InternalPop: PQJob;
var
  ANode:TQRBNode;
  ATick:Int64;
begin
Result:=nil;
ATick:=GetTimestamp;
FLocker.Enter;
try
  if FItems.Count>0 then
    begin
    ANode:=FItems.First;
    if PQJob(ANode.Data).NextTime<=ATick then
      begin
      Result:=ANode.Data;
//      OutputDebugString(PWideChar('Result.NextTime='+IntToStr(Result.NextTime)+',Current='+IntToStr(ATick)));
      if Result.Next<>nil then//如果没有更多需要执行的作业，则删除结点，否则指向下一个
        ANode.Data:=Result.Next
      else
        begin
        ANode.Data:=nil;
        FItems.Delete(ANode);
        ANode:=FItems.First;
        if ANode<>nil then
          FFirstFireTime:=PQJob(ANode.Data).NextTime
        else//没有计划作业了，不需要了
          FFirstFireTime:=0;
        end;
      end;
    end;
finally
  FLocker.Leave;
end;
end;

function TQRepeatJobs.InternalPush(AJob: PQJob): Boolean;
var
  ANode:TQRBNode;
begin
//计算作业的下次执行时间
AJob.UpdateNextTime;
FLocker.Enter;
try
  ANode:=FItems.Find(AJob);
  if ANode=nil then
    begin
    FItems.Insert(AJob);
    FFirstFireTime:=PQJob(FItems.First.Data).NextTime;
    end
  else//如果已经存在同一时刻的作业，则自己挂接到其它作业头部
    begin
    AJob.Next:=PQJob(ANode.Data);
    ANode.Data:=AJob;//首个作业改为自己
    end;
  Result:=True;
finally
  FLocker.Leave;
end;
end;

{ TQWorker }

constructor TQWorker.Create(AOwner: TQWorkers);
begin
inherited Create(true);
FOwner:=AOwner;
FTimeout:=1000;
FreeOnTerminate:=True;
FFlags:=0;
FEvent:=TEvent.Create(nil,False,False,'');
end;

destructor TQWorker.Destroy;
begin
FreeObject(FEvent);
  inherited;
end;

procedure TQWorker.Execute;
var
  wr:TWaitResult;
begin
try
//  PostLog(llHint,'工作者 %d 开始工作',[ThreadId]);
  while not (Terminated or FOwner.FTerminating) do
    begin
    if FOwner.FRepeatJobs.FFirstFireTime<>0 then
      begin
      FTimeout:=(FOwner.FRepeatJobs.FFirstFireTime-GetTimeStamp) div 10;
      if FTimeout<0 then//时间已经到了？那么立刻执行
        FTimeout:=0;
      end
    else
      FTimeout:=15000;//15S如果仍没有作业进入，则除非自己是保留的线程对象，否则释放工作者
    if FTimeout<>0 then
      wr:=FEvent.WaitFor(FTimeout)
    else
      wr:=wrSignaled;
    if (wr=wrSignaled) or ((FOwner.FRepeatJobs.FFirstFireTime<>0) and (FOwner.FRepeatJobs.FFirstFireTime+10>=GetTimeStamp)) then
      begin
      if FOwner.FTerminating then
        Break;
      SetIsBusy(True);
      FOwner.WorkerBusy(Self);
      repeat
        FActiveJob:=FOwner.Popup;
        if FActiveJob<>nil then
          begin
          FActiveJob.Worker:=Self;
          FActiveJobProc:=FActiveJob.WorkerProc;//为Clear(AObject)准备判断，以避免FActiveJob线程不安全
          if FActiveJob.StartTime=0 then
            begin
            FActiveJob.StartTime:=GetTimeStamp;
            FActiveJob.FirstRunTime:=FActiveJob.StartTime;
            end
          else
            FActiveJob.StartTime:=GetTimeStamp;
          try
            if FActiveJob.InMainThread then
              Synchronize(Self,FireInMainThread)
            else
              FActiveJob.WorkerProc(FActiveJob);
          except
          end;
          FActiveJobProc:=nil;
          if not (FActiveJob.Runonce or FActiveJob.IsTerminated) then
            begin
            FActiveJob.AfterRun(GetTimeStamp-FActiveJob.StartTime);
            FActiveJob.Worker:=nil;
            FOwner.FRepeatJobs.Push(FActiveJob);//重新加入队列
            end
          else
            begin
            if FActiveJob.IsSignalWakeup then
              FOwner.SignalWorkDone(FActiveJob,GetTimeStamp-FActiveJob.StartTime)
            else if FActiveJob.IsLongtimeJob then
              AtomicDecrement(FOwner.FLongTimeWorkers);
            FActiveJob.Worker:=nil;
            FOwner.FreeJob(FActiveJob);
            end;
          end;
      until (FActiveJob=nil) or FOwner.FTerminating or Terminated or (not FOwner.Enabled);
      SetIsBusy(False);
      FOwner.WorkerIdle(Self,irNoJob);
      end
    else if not IsReserved then
      begin
      SetIsBusy(False);
      FOwner.WorkerIdle(Self,irTimeout);
      end;
    end;
finally
  FOwner.WorkerTerminate(Self);
end;
end;

procedure TQWorker.FireInMainThread;
begin
FActiveJob.WorkerProc(FActiveJob);
end;

function TQWorker.GetInLongtimeJob: Boolean;
begin
Result:=((FFlags and WORKER_PROCESSLONG)<>0);
end;

function TQWorker.GetIsBusy: Boolean;
begin
Result:=((FFlags and WORKER_ISBUSY)<>0);
end;

function TQWorker.GetIsIdle: Boolean;
begin
Result:=((FFlags and WORKER_ISBUSY)=0);
end;

function TQWorker.GetIsReserved: Boolean;
begin
Result:=((FFlags and WORKER_RESERVED)<>0);
end;

procedure TQWorker.SetIsBusy(const Value: Boolean);
begin
if Value then
  FFlags:=FFlags or WORKER_ISBUSY
else
  FFlags:=FFlags and (not WORKER_ISBUSY);
end;

procedure TQWorker.SetIsReserved(const Value: Boolean);
begin
if Value then
  FFlags:=FFlags or WORKER_RESERVED
else
  FFlags:=FFlags and (not WORKER_RESERVED);
end;

{ TQWorkers }

function TQWorkers.Post(AJob: PQJob):Boolean;
begin
if (not FTerminating) and Assigned(AJob.WorkerProc) then
  begin
  if AJob.Runonce and (AJob.FirstDelay=0) then
    Result:=FSimpleJobs.Push(AJob)
  else
    Result:=FRepeatJobs.Push(AJob);
  if Result then
    LookupIdleWorker;
  end
else
  begin
  AJob.Next:=nil;
  FreeJob(AJob);
  Result:=False;
  end;
end;

function TQWorkers.Post(AProc: TQJobProc; AData: Pointer;ARunInMainThread:Boolean):Boolean;
var
  AJob:PQJob;
begin
AJob:=JobPool.Pop;
AJob.WorkerProc:=AProc;
AJob.Data:=AData;
AJob.SetRunonce(True);
AJob.SetInMainThread(ARunInMainThread);
Result:=Post(AJob);
end;

function TQWorkers.Post(AProc: TQJobProc; AInterval: Integer; AData: Pointer;ARunInMainThread:Boolean):Boolean;
var
  AJob:PQJob;
begin
AJob:=JobPool.Pop;
AJob.WorkerProc:=AProc;
AJob.Data:=AData;
AJob.Interval:=AInterval;
AJob.SetInMainThread(ARunInMainThread);
if AInterval=0 then
  AJob.SetRunonce(True);
Result:=Post(AJob);
end;

procedure TQWorkers.Clear(AObject: Pointer);
  procedure ClearSignalJobs;
  var
    I:Integer;
    AJob,ANext,APrior:PQJob;
    AList:PQHashList;
    ASignal:PQSignal;
  begin
  FLocker.Enter;
  try
    for I := 0 to FSignalJobs.BucketCount-1 do
      begin
      AList:=FSignalJobs.Buckets[I];
      if AList<>nil then
        begin
        ASignal:=AList.Data;
        if ASignal.First<>nil then
          begin
          AJob:=ASignal.First;
          APrior:=nil;
          while AJob<>nil do
            begin
            ANext:=AJob.Next;
            if TMethod(AJob.WorkerProc).Data=AObject then
              begin
              if ASignal.First=AJob then
                ASignal.First:=ANext;
              if Assigned(APrior) then
                APrior.Next:=ANext;
              AJob.Next:=nil;
              FreeJob(AJob);
              end
            else
              APrior:=AJob;
            AJob:=ANext;
            end;
          end;
        end;
      end;
  finally
    FLocker.Leave;
  end;
  end;
  function HasJobRunning:Boolean;
  var
    I:Integer;
  begin
  Result:=False;
  FLocker.Enter;
  try
    for I := 0 to FWorkerCount-1 do
      begin
      if FWorkers[I].IsBusy then
        begin
        if TMethod(FWorkers[I].FActiveJobProc).Data=AObject then
          begin
          Result:=True;
          Break;
          end;
        end;
      end;
  finally
    FLocker.Leave;
  end;
  end;
  //等待正在运行中的关联作业完成
  procedure WaitRunningDone;
  var
    I:Integer;
  begin
  repeat
    if HasJobRunning then
      begin
      {$IFDEF QDAC_UNICODE}
      TThread.Yield;
      {$ELSE}
      SwitchToThread;
      {$ENDIF}
      end
    else//没找到，为保险起见多次放弃时间片，经其它工作者机会
      begin
      I:=FWorkerCount shl 1;
      while I>=0 do
        begin
        {$IFDEF QDAC_UNICODE}
        TThread.Yield;
        {$ELSE}
        SwitchToThread;
        {$ENDIF}
        Dec(I);
        end;
      Break;
      end;
  until 1>2;
  end;
begin
if Self<>nil then
  begin
  FSimpleJobs.Clear(AObject);
  FRepeatJobs.Clear(AObject);
  ClearSignalJobs;
  WaitRunningDone;
  end;
end;

function TQWorkers.At(AProc: TQJobProc; const ADelay, AInterval: Integer;
  AData: Pointer;ARunInMainThread:Boolean): Boolean;
var
  AJob:PQJob;
begin
AJob:=JobPool.Pop;
AJob.WorkerProc:=AProc;
AJob.Interval:=AInterval;
AJob.FirstDelay:=ADelay;
AJob.Data:=AData;
AJob.SetInMainThread(ARunInMainThread);
Result:=Post(AJob);
end;

function TQWorkers.At(AProc: TQJobProc; const ATime: TDateTime;
  const AInterval: Integer; AData: Pointer;ARunInMainThread:Boolean): Boolean;
var
  AJob:PQJob;
  ADelay:Integer;
  ANow,ATemp:TDateTime;
begin
AJob:=JobPool.Pop;
AJob.WorkerProc:=AProc;
AJob.Interval:=AInterval;
AJob.SetInMainThread(ARunInMainThread);
//ATime我们只要时间部分，日期忽略
ANow:=Now;
ANow:=ANow-Trunc(ANow);
ATemp:=ATime-Trunc(ATime);
if ANow>ATemp then //好吧，今天的点已经过了，算明天
  ADelay:=Trunc(((1+ANow)-ATemp)*864000000)//延迟的时间，单位为0.1ms
else
  ADelay:=Trunc((ATemp-ANow)*864000000);
AJob.FirstDelay:=ADelay;
AJob.Data:=AData;
Result:=Post(AJob);
end;

procedure TQWorkers.Clear(AProc: TQJobProc);
begin
raise Exception.CreateFmt(SNotSupportNow,['Clear(AJobProc)']);
end;

procedure TQWorkers.ClearWorkers;
var
  I: Integer;
begin
FTerminating:=True;
FLocker.Enter;
try
  FRepeatJobs.FFirstFireTime:=0;
  for I := 0 to FWorkerCount-1 do
    FWorkers[I].FEvent.SetEvent;
finally
  FLocker.Leave;
end;
while FWorkerCount>0 do
  {$IFDEF QDAC_UNICODE}
  TThread.Yield;
  {$ELSE}
  SwitchToThread;
  {$ENDIF}
end;

constructor TQWorkers.Create;
var
  ACpuCount:Integer;
begin
FEnabled:=True;
FSimpleJobs:=TQSimpleJobs.Create(Self);
FRepeatJobs:=TQRepeatJobs.Create(Self);
FSignalJobs:=TQHashTable.Create();
FSignalJobs.OnDelete:=DoJobFree;
FSignalJobs.AutoSize:=True;
ACpuCount:=GetCPUCount;
FMinWorkers:=1;//最少工作者为1个
FMaxWorkers:=ACpuCount*2+1;//默认每CPU最多20个线程
FLocker:=TCriticalSection.Create;
FTerminating:=False;
//创建默认工作者
FWorkerCount:=1;
SetLength(FWorkers,FMaxWorkers);
FWorkers[0]:=TQWorker.Create(Self);
FWorkers[0].SetIsReserved(True);//保留，不需要空闲检查
FWorkers[0].Suspended:=False;
//FWorkers[1]:=TQWorker.Create(Self);
//FWorkers[1].SetIsReserved(True);//保留，不需要空闲检查
//FWorkers[1].Suspended:=False;
{$IFDEF MSWINDOWS}
if ACpuCount>1 then
  begin
  SetThreadCpu(FWorkers[0].Handle,0);
  SetThreadCpu(FWorkers[0].Handle,1);
  end;
{$ENDIF}
FMaxLongtimeWorkers:=(FMaxWorkers shr 1);
end;

function TQWorkers.Delay(AProc: TQJobProc; ADelay: Integer; AData: Pointer;ARunInMainThread:Boolean):Boolean;
var
  AJob:PQJob;
begin
AJob:=JobPool.Pop;
AJob.WorkerProc:=AProc;
AJob.SetRunonce(True);
AJob.FirstDelay:=ADelay;
AJob.Data:=AData;
AJob.SetInMainThread(ARunInMainThread);
Result:=Post(AJob);
end;

destructor TQWorkers.Destroy;
begin
ClearWorkers;
FLocker.Enter;
try
  FreeObject(FSimpleJobs);
  FreeObject(FRepeatJobs);
  FreeObject(FSignalJobs);
finally
  FreeObject(FLocker);
end;
inherited;
end;

procedure TQWorkers.DoJobFree(ATable: TQHashTable; AHash: Cardinal;
  AData: Pointer);
var
  ASignal:PQSignal;
begin
ASignal:=AData;
if ASignal.First<>nil then
  FreeJob(ASignal.First);
Dispose(ASignal);
end;

procedure TQWorkers.FireSignalJob(ASignal: PQSignal);
var
  AJob,ACopy:PQJob;
begin
Inc(ASignal.Fired);
AJob:=ASignal.First;
while AJob<>nil do
  begin
  ACopy:=JobPool.Pop;
  ACopy.Assign(AJob);
  ACopy.SetRunonce(True);
  ACopy.Source:=AJob;
  FSimpleJobs.Push(ACopy);
  AJob:=AJob.Next;
  end;
end;

procedure TQWorkers.FreeJob(AJob: PQJob);
var
  ANext:PQJob;
begin
while AJob<>nil do
  begin
  ANext:=AJob.Next;
  JobPool.Push(AJob);
  AJob:=ANext;
  end;
end;

function TQWorkers.LongtimeJob(AProc: TQJobProc; AData: Pointer): Boolean;
var
  AJob:PQJob;
begin
if AtomicIncrement(FLongTimeWorkers)<=FMaxLongTimeWorkers then
  begin
  Result:=True;
  AJob:=JobPool.Pop;
  AJob.WorkerProc:=AProc;
  AJob.Data:=AData;
  AJob.SetIsLongtimeJob(True);
  AJob.SetRunonce(True);
  Post(AJob);
  end
else
  Result:=False;
end;

function TQWorkers.LookupIdleWorker: TQWorker;
var
  I:Integer;
  AWorker:TQWorker;
begin
if not Enabled then
  begin
  Result:=nil;
  Exit;
  end;
Result:=nil;
FLocker.Enter;
try
  if not FTerminating then
    begin
    for I := 0 to FWorkerCount-1 do
      begin
      AWorker:=FWorkers[I];
      if (AWorker<>nil) and (AWorker.IsIdle) then
        begin
        Result:=AWorker;
        Break;
        end;
      end;
    if (Result=nil) and (FWorkerCount<MaxWorkers) then
      begin
      Result:=TQWorker.Create(Self);
      FWorkers[FWorkerCount]:=Result;
      {$IFDEF MSWINDOWS}
      SetThreadCpu(Result.Handle,FWorkerCount mod GetCpuCount);
      {$ENDIF}
      Inc(FWorkerCount);
      end;
    end;
finally
  FLocker.Leave;
end;
if Result<>nil then
  begin
  Result.Suspended:=False;
  Result.FEvent.SetEvent;
  end;
end;

function TQWorkers.Popup: PQJob;
begin
Result:=FSimpleJobs.Pop;
if Result=nil then
  Result:=FRepeatJobs.Pop;
end;

function TQWorkers.RegisterSignal(const AName: QStringW): Integer;
var
  ASignal:PQSignal;
begin
FLocker.Enter;
try
  Result:=SignalIdByName(AName);
  if Result<0 then
    begin
    Inc(FMaxSignalId);
    New(ASignal);
    ASignal.Id:=FMaxSignalId;
    ASignal.Fired:=0;
    ASignal.Name:=AName;
    ASignal.First:=nil;
    FSignalJobs.Add(ASignal,ASignal.Id);
    Result:=ASignal.Id;
//    OutputDebugString(PWideChar('Signal '+IntToStr(ASignal.Id)+' Allocate '+IntToHex(NativeInt(ASignal),8)));
    end;
finally
  FLocker.Leave;
end;
end;

procedure TQWorkers.SetEnabled(const Value: Boolean);
begin
if FEnabled<>Value then
  begin
  FEnabled := Value;
  if Enabled then
    begin
    if (FSimpleJobs.Count>0) or (FRepeatJobs.Count>0) then
      LookupIdleWorker;
    end;
  end;
end;

procedure TQWorkers.SetMaxLongtimeWorkers(const Value: Integer);
begin
if FMaxLongtimeWorkers <> Value then
  begin
  if Value>(MaxWorkers shr 1) then
    raise Exception.Create(STooManyLongtimeWorker);
  FMaxLongtimeWorkers:=Value;
  end;
end;

procedure TQWorkers.SetMaxWorkers(const Value: Integer);
var
  ATemp,AMaxLong:Integer;
begin
if (Value>=2) and (FMaxWorkers <> Value) then
  begin
  AtomicExchange(ATemp,FLongtimeWorkers);
  AtomicExchange(FLongTimeWorkers,0);//强制置0，防止有新入的长时间作业
  FLocker.Enter;
  try
    AMaxLong:=Value shr 1;
    if FLongtimeWorkers<AMaxLong then//已经进行的长时间作业数小于一半的工作者
      begin
      if ATemp<AMaxLong then
        AMaxLong:=ATemp;
      if FMaxWorkers>Value then
        begin
        while Value<FWorkerCount do
          WorkerTerminate(FWorkers[FWorkerCount-1]);
        FMaxWorkers:=Value;
        SetLength(FWorkers,Value);
        end
      else
        begin
        FMaxWorkers:=Value;
        SetLength(FWorkers,Value);
        end;
      end;
  finally
    FLocker.Leave;
    AtomicExchange(FLongtimeWorkers,AMaxLong);
  end;
  end;
end;

procedure TQWorkers.SetMinWorkers(const Value: Integer);
begin
if FMinWorkers<>Value then
  begin
  if Value<2 then
    raise Exception.Create(STooFewWorkers);
  FMinWorkers := Value;
  end;
end;

procedure TQWorkers.Signal(AId: Integer);
var
  AFound:Boolean;
  ASignal:PQSignal;
begin
AFound:=False;
FLocker.Enter;
try
  ASignal:=FSignalJobs.FindFirstData(AId);
  if ASignal<>nil then
    begin
    AFound:=True;
    FireSignalJob(ASignal);
    end;
finally
  FLocker.Leave;
end;
if AFound then
  LookupIdleWorker;
end;

procedure TQWorkers.Signal(const AName: QStringW);
var
  I:Integer;
  ASignal:PQSignal;
  AFound:Boolean;
begin
AFound:=False;
FLocker.Enter;
try
  for I := 0 to FSignalJobs.BucketCount-1 do
    begin
    if FSignalJobs.Buckets[I]<>nil then
      begin
      ASignal:=FSignalJobs.Buckets[I].Data;
      if (Length(ASignal.Name)=Length(AName)) and (ASignal.Name=AName) then
        begin
        AFound:=True;
        FireSignalJob(ASignal);
        Break;
        end;
      end;
    end;
finally
  FLocker.Leave;
end;
if AFound then
  LookupIdleWorker;
end;

function TQWorkers.SignalIdByName(const AName: QStringW): Integer;
var
  I:Integer;
  ASignal:PQSignal;
begin
Result:=-1;
for I := 0 to FSignalJobs.BucketCount-1 do
  begin
  if FSignalJobs.Buckets[I]<>nil then
    begin
    ASignal:=FSignalJobs.Buckets[I].Data;
    if (Length(ASignal.Name)=Length(AName)) and (ASignal.Name=AName) then
      begin
      Result:=ASignal.Id;
      Exit;
      end;
    end;
  end;
end;

procedure TQWorkers.SignalWorkDone(AJob: PQJob;AUsedTime:Int64);
var
  ASignal:PQSignal;
  ATemp:PQJob;
begin
FLocker.Enter;
try
  ASignal:=FSignalJobs.FindFirstData(AJob.SignalId);
  ATemp:=ASignal.First;
  while ATemp<>nil do
    begin
    if ATemp=AJob.Source then
      begin
      //更新信号作业的统计信息
      Inc(ATemp.Runs);
      if AUsedTime>0 then
        begin
        if ATemp.MinUsedTime=0 then
          ATemp.MinUsedTime:=AUsedTime
        else if AUsedTime<ATemp.MinUsedTime then
          ATemp.MinUsedTime:=AUsedTime;
        if ATemp.MaxUsedTime=0 then
          ATemp.MaxUsedTime:=AUsedTime
        else if AUsedTime>ATemp.MaxUsedTime then
          ATemp.MaxUsedTime:=AUsedTime;
        Break;
        end;
      end;
    ATemp:=ATemp.Next;
    end;
finally
  FLocker.Leave;
end;
end;

procedure TQWorkers.WorkerBusy(AWorker: TQWorker);
begin
end;

procedure TQWorkers.WorkerIdle(AWorker:TQWorker;AReason:TWorkerIdleReason);
var
  I,J:Integer;
begin
FLocker.Enter;
try
  if (AWorker<>FWorkers[0]) and (AWorker<>FWorkers[1]) and (AReason=irTimeout) then
    begin
    for I := FMinWorkers to FWorkerCount-1 do
      begin
      if AWorker=FWorkers[I] then
        begin
        AWorker.Terminate;
        for J := I+1 to FWorkerCount-1 do
          FWorkers[J-1]:=FWorkers[J];
        FWorkers[FWorkerCount-1]:=nil;
        Dec(FWorkerCount);
        Break;
        end;
      end;
    end;
finally
  FLocker.Leave;
end;
end;

procedure TQWorkers.WorkerTerminate(AWorker: TObject);
var
  I,J:Integer;
begin
FLocker.Enter;
for I := 0 to FWorkerCount-1 do
  begin
  if FWorkers[I]=AWorker then
    begin
    for J := I to FWorkerCount-2 do
      FWorkers[J]:=FWorkers[J+1];
    FWorkers[FWorkerCount-1]:=nil;
    Dec(FWorkerCount);
    Break;
    end;
  end;
FLocker.Leave;
//PostLog(llHint,'工作者 %d 结束，新数量 %d',[TQWorker(AWorker).ThreadID,FWorkerCount]);
end;

function TQWorkers.Wait(AProc: TQJobProc; ASignalId: Integer; AData: Pointer;ARunInMainThread:Boolean):Boolean;
var
  AJob:PQJob;
  ASignal:PQSignal;
begin
if not FTerminating then
  begin
  AJob:=JobPool.Pop;
  AJob.WorkerProc:=AProc;
  AJob.Data:=AData;
  AJob.SignalId:=ASignalId;
  AJob.SetIsSignalWakeup(True);
  AJob.PushTime:=GetTimeStamp;
  AJob.SetInMainThread(ARunInMainThread);
  Result:=False;
  FLocker.Enter;
  try
    ASignal:=FSignalJobs.FindFirstData(ASignalId);
    if ASignal<>nil then
      begin
      AJob.Next:=ASignal.First;
      ASignal.First:=AJob;
      Result:=True;
      end;
  finally
    FLocker.Leave;
    if not Result then
      JobPool.Push(AJob);
  end;
  end
else
  Result:=False;
end;

{ TJobPool }

constructor TJobPool.Create(AMaxSize: Integer);
begin
inherited Create;
FSize:=AMaxSize;
FLocker:=TQSimpleLock.Create;
end;

destructor TJobPool.Destroy;
var
  AJob:PQJob;
begin
FLocker.Enter;
while FFirst<>nil do
  begin
  AJob:=FFirst.Next;
  Dispose(FFirst);
  FFirst:=AJob;
  end;
FreeObject(FLocker);
inherited;
end;

function TJobPool.Pop: PQJob;
begin
FLocker.Enter;
Result:=FFirst;
if Result<>nil then
  begin
  FFirst:=Result.Next;
  Dec(FCount);
  end;
FLocker.Leave;
if Result=nil then
  GetMem(Result,SizeOf(TQJob));
Result.Reset;
end;

procedure TJobPool.Push(AJob: PQJob);
var
  ADoFree:Boolean;
begin
FLocker.Enter;
ADoFree:=(FCount=FSize);
if not ADoFree then
  begin
  AJob.Next:=FFirst;
  FFirst:=AJob;
  Inc(FCount);
  end;
FLocker.Leave;
if ADoFree then
  begin
  FreeMem(AJob);
  end;
end;

{ TQSimpleLock }
{$IFDEF QWORKER_SIMPLE_LOCK}

constructor TQSimpleLock.Create;
begin
inherited;
FFlags:=0;
end;

procedure TQSimpleLock.Enter;
begin
while (AtomicOr(FFlags,$01) and $01)<>0 do
  begin
  {$IFDEF QDAC_UNICODE}
  TThread.Yield;
  {$ELSE}
  SwitchToThread;
  {$ENDIF}
  end;
end;

procedure TQSimpleLock.Leave;
begin
AtomicAnd(FFlags,Integer($FFFFFFFE));
end;
{$ENDIF QWORKER_SIMPLE_JOB}
initialization
  {$IFNDEF QDAC_UNICODE}
  GetTickCount64:=GetProcAddress(GetModuleHandle(kernel32),'GetTickCount64');
  if not QueryPerformanceFrequency(_PerfFreq) then
    _PerfFreq:=-1;
  {$ELSE}
  _Watch:=TStopWatch.Create;
  _Watch.Start;
  {$ENDIF}
  JobPool:=TJobPool.Create(1024);
  Workers:=TQWorkers.Create;
finalization
  FreeObject(Workers);
  FreeObject(JobPool);
end.
