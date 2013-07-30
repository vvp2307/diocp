unit uObjectPool;

interface

uses
  Classes, SyncObjs, Windows, SysUtils;


type
  TObjectPool = class(TObject)
  private
    FObjectClass:TClass;
    
    //全部归还的信号灯
    FGiveBackSingle: THandle;
    
    FErrCode:Integer;

    FErrMsg:string;
    
    //
    FWaitTimeOut:Integer;
    
    //使用时等待信号<如果没有信号时没有信号>
    FWaitSingle:THandle;

    //
    FCS: TCriticalSection;

    //当前数量
    FCount:Integer;

    //最大数量
    FMaxCount: Integer;

    //已经使用的个数
    FUsingCount:Integer;

    FUsableList: TList;
    procedure lock();
    procedure unLock();
    procedure checkSingle;
    procedure SetMaxCount(const Value: Integer);
    procedure clearUsableList;
  protected
    function createObject:TObject;virtual;
  public
    //停止时使用
    procedure clearObjects;

    constructor Create(pvObjectClass: TClass = nil);

    destructor Destroy; override;
    
    function beginUseObject: TObject;

    procedure endUseObject(const pvObj:TObject);
    
    property Count: Integer read FCount;

    property MaxCount: Integer read FMaxCount write SetMaxCount;

    //等待全部还回
    function waitForGiveBack: Boolean;

    property ErrMsg: string read FErrMsg;
    
    //正在使用的个数
    property UsingCount: Integer read FUsingCount;

    //等待超时
    property WaitTimeOut: Integer read FWaitTimeOut write FWaitTimeOut;
  end;

implementation

procedure TObjectPool.checkSingle;
begin
  if (FCount < FMaxCount)      //还可以创建
     or (FUsingCount < FCount)  //还有可使用的
     then
  begin
    //设置有信号
    SetEvent(FWaitSingle);
  end else
  begin
    //没有信号
    ResetEvent(FWaitSingle);
  end;

  if FUsingCount > 0 then
  begin
    //没有信号
    ResetEvent(FGiveBackSingle);
  end else
  begin
    //全部归还有信号
    SetEvent(FGiveBackSingle)
  end;
end;

constructor TObjectPool.Create(pvObjectClass: TClass = nil);
begin
  inherited Create;
  FObjectClass := pvObjectClass;

  //30秒超时
  FWaitTimeOut := 1000 * 30;

  FWaitSingle := CreateEvent(nil, True, True, nil);

  //创建信号灯,手动控制
  FGiveBackSingle := CreateEvent(nil, True, True, nil);
  
  FMaxCount := 2;
  FCount := 0;
  FUsingCount := 0;
  FUsableList := TList.Create;
  FCS := TCriticalSection.Create();
  checkSingle;
end;

function TObjectPool.createObject: TObject;
begin
  Result := nil;
  if FObjectClass <> nil then
  begin
    Result := FObjectClass.Create;
  end;          
end;

destructor TObjectPool.Destroy;
begin
  //等待全部归还
  waitForGiveBack;

  //释放
  clearUsableList;
  
  FUsableList.Free;
  FCS.Free;
  CloseHandle(FWaitSingle);
  CloseHandle(FGiveBackSingle);
  
  inherited Destroy;
end;

function TObjectPool.beginUseObject: TObject;
var
  i:Integer;
  lvRet:DWORD;
begin
  //等待超时
  lvRet := WaitForSingleObject(FWaitSingle, FWaitTimeOut);
  if lvRet = WAIT_TIMEOUT then
  begin
    Result := nil;
    FErrMsg := '等待超时';
  end else if lvRet = WAIT_OBJECT_0 then
  begin
    lock;
    try
      i := FUsableList.Count;
      if i > 0 then
      begin
        Result := TObject(FUsableList[i-1]);
        FUsableList.Delete(i-1);
      end else
      begin
        Result := createObject;
        if Result <> nil then
        begin
          Inc(FCount);
        end;
      end;  
      if Result <> nil then Inc(FUsingCount);

      checkSingle;
    finally
      unLock;
    end;
  end else
  begin
    Result := nil;
    FErrMsg := '等待异常[' + intToStr(lvRet) + ']';
  end;
end;

procedure TObjectPool.clearObjects;
begin
  waitForGiveBack;
  clearUsableList;
end;

procedure TObjectPool.clearUsableList;
var
  i:Integer;
begin
  lock;
  try
    while FUsableList.Count > 0 do
    begin
      i:= FUsableList.Count - 1;
      TObject(FUsableList[i]).Free;
      FUsableList.Delete(i);
      Dec(FCount);
    end;

    checkSingle;
  finally
    unLock;
  end;
end;

procedure TObjectPool.endUseObject(const pvObj:TObject);
var
  i:Integer;
begin
  lock;
  try
    FUsableList.Add(pvObj);
    Dec(FUsingCount);
    checkSingle;
  finally
    unLock;
  end;
end;

procedure TObjectPool.lock;
begin
  FCS.Enter;
end;

procedure TObjectPool.SetMaxCount(const Value: Integer);
begin
  FMaxCount := Value;
  checkSingle;
end;

procedure TObjectPool.unLock;
begin
  FCS.Leave;
end;

function TObjectPool.waitForGiveBack: Boolean;
var
  lvRet:DWORD;
begin
  Result := false;
  lvRet := WaitForSingleObject(FGiveBackSingle, INFINITE);
  if lvRet = WAIT_OBJECT_0 then
  begin
    Result := true;
  end;
end;

end.
