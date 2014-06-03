unit BaseQueue;

interface

uses
  SyncObjs;

{$DEFINE __debug}

type
  PQueueData = ^TQueueData;
  TQueueData = record
    Data: Pointer;
    Next: PQueueData;
  end;

  TBaseQueue = class(TObject)
  private
    FLocker: TCriticalSection;
    FCount: Integer;
    FHead: PQueueData;
    FTail: PQueueData;
    /// <summary>
    ///   清空所有数据
    /// </summary>
    procedure clear;
    function innerPop: PQueueData;
    procedure innerPush(AData: PQueueData);
  public
    constructor Create;
    destructor Destroy; override;
    function IsEmpty: Boolean;

    function size:Integer;

    function Pop: Pointer;
    procedure Push(AData: Pointer);
  end;

implementation

constructor TBaseQueue.Create;
begin
  inherited Create;
  FLocker := TCriticalSection.Create();
  New(FHead);
  FHead.next := nil;
  FTail := FHead;
  FCount := 0;
end;

destructor TBaseQueue.Destroy;
begin
  Clear;
  FLocker.Free;
  Dispose(FHead);
  inherited Destroy;
end;

{ TBaseQueue }

procedure TBaseQueue.clear;
var
  ANext: PQueueData;
begin
  FLocker.Enter;
  try
    while FHead.Next <> nil do
    begin
      ANext := FHead.Next;
      Dispose(FHead);
      FHead := ANext;
    end;
  finally
    FLocker.Leave;
  end;
end;

function TBaseQueue.IsEmpty: Boolean;
begin
  Result := (FHead.next = nil);
end;

function TBaseQueue.Pop: Pointer;
var
  lvTemp:PQueueData;
begin
  Result := nil;
  lvTemp := innerPop;
  if lvTemp <> nil then
  begin
    Result := lvTemp.Data;
    Dispose(lvTemp);
  end;
end;

procedure TBaseQueue.Push(AData: Pointer);
var
  lvTemp:PQueueData;
begin
  New(lvTemp);
  lvTemp.Data := AData;
  innerPush(lvTemp);
end;

function TBaseQueue.size: Integer;
begin
  Result := FCount;
end;

function TBaseQueue.innerPop: PQueueData;
var
  AFirst: PQueueData;
begin
  ///为了方便 队列中始终保留一个FHead数据块
  ///  也就是说FHead指向的下一个数据块才是第一个数据块
  FLocker.Enter;
  try
    Result := FHead.Next;
    if Result <> nil then
    begin
      FHead.Next := Result.Next;
      if Result = FTail then
        FTail := FHead;

    end;
    Dec(FCount);
  finally
    FLocker.Leave;
  end;
end;

procedure TBaseQueue.innerPush(AData: PQueueData);
begin
  AData.Next := nil;
  FLocker.Enter;
  try
    FTail.Next := AData;
    FTail := AData;
    Inc(FCount);
  finally
    FLocker.Leave;
  end;
end;

end.
