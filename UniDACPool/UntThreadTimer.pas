(*


     自己编写的线程计时器，没有采用消息机制，很有效

     Cobbler续写

     不用 TTimer 的原因:

     要说TTimer类的使用问题，先要说一下它响应用户定义的回调函数(OnTimer)的方法。
     TTimer拥有一个HWnd类型的成员变量FWindowHandle，用于捕捉系统消息。
     TTimer在Enable的情况下，每隔Interval时间，就抛一个系统消息WM_TIMER,FWindowHandle捕捉到这个消息后，
     就会执行用户的回调函数，实现用户需要的功能。就是这个消息机制引发了下面两个问题：

   问题1: 还不算严重，TTimer与系统共用一个消息队列，也就是说，在用户回调函数处理完之前，
          所有的系统消息都处于阻塞状态，包括界面的更新的消息。
          如果你的回调函数瞬间执行完毕那就一切看着还正常，如果你要执行一个复杂耗时的操作，
          比如数据库查询什么的（万一遇到数据库联接不正常，等待20秒），
          那你的界面就必死无疑，直到回调函数执行完。如果是后台系统还好，
          要是给用户使用的就没法交待了。即使你在子线程里面使用也不会解决的。

   问题2: 一般系统定义消息的优先级比用户定义消息的优先级要低。
          在子线程中使用TTimer时，如果线程间通信也大量使用自定义消息，
          并且用户定义自己的消息处理函数，那WM_TIMER经常就会被丢弃了，
          计时器就彻底失效了。

   摘抄自网络

*)

unit UntThreadTimer;

interface

uses
  Windows, Classes;

type
  TTimerStatus = (TS_ENABLE, TS_CHANGEINTERVAL, TS_DISABLE, TS_SETONTIMER);
  TThreadedTimer = class;
  TTimerThread = class;
  PTimerThread = ^TTimerThread;

  TTimerThread = class(TThread)
    OwnerTimer: TThreadedTimer;
    Interval: DWord;
    Enabled : Boolean;
    Status : TTimerStatus;
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    procedure Execute; override;
    procedure DoTimer;
  end;

  TThreadedTimer = class(TComponent)
  private
    FEnabled: Boolean;
    FInterval: DWord;
    FOnTimer: TNotifyEvent;
    FTimerThread: TTimerThread;
    FThreadPriority: TThreadPriority;
  protected
    procedure UpdateTimer;
    procedure SetEnabled(Value: Boolean);
    procedure SetInterval(Value: DWord);
    procedure SetOnTimer(Value: TNotifyEvent);
    procedure Timer; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Interval: DWord read FInterval write SetInterval default 1000;
    property OnTimer: TNotifyEvent read FOnTimer write SetOnTimer;
  end;

implementation

procedure WakeupDownThrdproc(const evenFlag: Integer); stdcall;
begin

end;
{TTimerThread}
constructor TTimerThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  Interval := 1000;
  Enabled := False;
  Status := TS_DISABLE;
end;

destructor TTimerThread.Destroy;
begin
  inherited;
end;

procedure TTimerThread.Execute;
begin
  inherited;
  while not Terminated do
  begin
    SleepEx(Interval, True);
    if (not Terminated) and (Status = TS_ENABLE) then Synchronize(DoTimer);
    if Status <> TS_ENABLE then
    begin
      case Status of
        TS_CHANGEINTERVAL:
        begin
          Status := TS_ENABLE;
          SleepEx(0,True);
        end;
        TS_DISABLE:
        begin
          Status := TS_ENABLE;
          SleepEx(0, True);
          if not Terminated then Suspend;
        end;
        TS_SETONTIMER:
        begin
          Status := TS_ENABLE;
        end else
          Status := TS_ENABLE;
      end;
    end;
  end;
end;

procedure TTimerThread.DoTimer;
begin
  OwnerTimer.Timer;
end;
{TThreadedTimer}
constructor TThreadedTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInterval := 1000;
  FThreadPriority := tpNormal;
  FTimerThread := TTimerThread.Create(true);
  FTimerThread.OwnerTimer := self;
end;

destructor TThreadedTimer.Destroy;
begin
  inherited Destroy;
  FTimerThread.Terminate;
  QueueUserAPC(@WakeupDownThrdproc, FTimerThread.Handle, DWORD(FTimerThread));
  FTimerThread.Free;
end;

procedure TThreadedTimer.UpdateTimer;
begin
   if (FEnabled = False) then
   begin
     FTimerThread.OwnerTimer := Self;
     FTimerThread.Interval := FInterval;
     FTimerThread.Priority := FThreadPriority;
     FTimerThread.Resume;
   end;
   if (FEnabled = True) then
   begin
     QueueUserAPC(@WakeupDownThrdproc, FTimerThread.Handle, DWORD(FTimerThread));
   end;
end;

procedure TThreadedTimer.SetEnabled(Value: Boolean);
begin
   if Value <> FEnabled then
   begin
     FEnabled := Value;
     if Value then
     begin
       FTimerThread.Status := TS_ENABLE;
       FTimerThread.Resume;
     end else
     begin
       FTimerThread.Status := TS_DISABLE;
       QueueUserAPC(@WakeupDownThrdproc, FTimerThread.Handle, DWORD(FTimerThread));
     end;
   end;
end;

procedure TThreadedTimer.SetInterval(Value: DWord);
begin
   if Value <> FInterval then
   begin
      if (not Enabled) then
      begin
        FInterval := Value;
        FTimerThread.Interval := FInterval;
      end else
      begin
        FInterval := Value;
        FTimerThread.Interval := FInterval;
        FTimerThread.Status := TS_CHANGEINTERVAL;
        QueueUserAPC(@WakeupDownThrdproc, FTimerThread.Handle, DWORD(FTimerThread));
      end;
   end;
end;

procedure TThreadedTimer.SetOnTimer(Value: TNotifyEvent);
begin
  FOnTimer := Value;
end;

procedure TThreadedTimer.Timer;
begin
  if Assigned(FOnTimer) then FOnTimer(Self);
end;

end.


