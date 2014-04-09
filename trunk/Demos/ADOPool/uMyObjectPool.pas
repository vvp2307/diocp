unit uMyObjectPool;
///
///
/// 2014年3月10日 10:47:26
///    移除等待, 借用对象时，等待

interface

uses
  SyncObjs, Classes, Windows, SysUtils;

type
  TObjectBlock = record
    FObject:TObject;
    FUsingCounter: Integer;     //连接计数器 <原则上要么是0，要么是1>,如果大于1则表示对象池有缺陷
    FBorrowTime:Cardinal;       //借出时间
    FRelaseTime:Cardinal;       //归还时间
    FMarkWillFreeFlag:Boolean;  //归还是如果标记为true,在归还时释放这对象
    FThreadID:Cardinal;         //线程ID   
  end;

  PObjectBlock = ^TObjectBlock;

  TMyObjectPool = class(TObject)
  private
    FObjectClass:TClass;

    FCurrentThreadID:Cardinal;

    FLocker: TCriticalSection;

    FBusyCount: Integer;

    //全部归还信号
    FReleaseSingle: THandle;

    FMaxNum: Integer;

    /// <summary>
    ///   连接池中的对象列表
    /// </summary>
    FObjectList: TList;

    FName: String;


    /// <summary>
    ///  根据当前状态重新设置信号
    /// </summary>
    procedure makeSingle;


    function GetCount: Integer;

    /// <summary>
    ///  加锁
    /// </summary>
    procedure lock;

    procedure SetMaxNum(const Value: Integer);

    /// <summary>
    ///  解锁
    /// </summary>
    procedure unLock;

  private
    procedure DoGiveBackObject(pvObjBlock:PObjectBlock);
    
  protected
    /// <summary>
    ///   清理空闲的对象
    /// </summary>
    procedure clear;

    /// <summary>
    ///  创建一个对象
    /// </summary>
    function createObject: TObject; virtual;

    /// <summary>
    ///   归还一个对象
    /// </summary>
    procedure onGiveBackObject(pvObject:TObject); virtual;
  public
    constructor Create(pvObjectClass: TClass = nil);
    destructor Destroy; override;

    /// <summary>
    ///   重置对象池
    /// </summary>
    procedure resetPool;

    /// <summary>
    ///  借用一个对象
    /// </summary>
    function borrowObject: TObject;


    /// <summary>
    ///   标志对象需要释放
    /// </summary>
    procedure makeObjectWillFree(pvObject:TObject);


    /// <summary>
    ///   是否空闲的对象
    /// </summary>
    procedure clearFreeObjects;


    /// <summary>
    ///   清理已经长时间锁定的对象(默认30秒)
    /// </summary>
    function killDeadLockObjects(pvTimeOut: Integer = 30 * 1000): Integer;


    /// <summary>
    ///   归还一个对象
    /// </summary>
    procedure releaseObject(pvObject:TObject);

    /// <summary>
    ///  获取正在使用的个数
    /// </summary>
    function getBusyCount:Integer;



    //等待全部还回
    function waitForReleaseSingle: Boolean;

    /// <summary>
    ///  当前总的个数
    /// </summary>
    property Count: Integer read GetCount;

    /// <summary>
    ///  最大对象个数
    /// </summary>
    property MaxNum: Integer read FMaxNum write SetMaxNum;



    /// <summary>
    ///  对象池名称
    /// </summary>
    property Name: String read FName write FName;

  end;

implementation

uses
  FileLogger;

procedure TMyObjectPool.clear;
var
  lvObj:PObjectBlock;
  i:Integer;
begin
  lock;
  try
    for i := 0 to FObjectList.Count -1 do
    begin
      lvObj := PObjectBlock(FObjectList[i]);
      lvObj.FObject.Free;
      FreeMem(lvObj, SizeOf(TObjectBlock));
    end;

    FObjectList.Clear;
  finally
    unLock;
  end;
end;

procedure TMyObjectPool.clearFreeObjects;
var
  lvObj:PObjectBlock;
  i:Integer;
begin
  lock;
  try
    for i := FObjectList.Count -1  downto 0 do
    begin
      lvObj := PObjectBlock(FObjectList[i]);
      if lvObj.FUsingCounter = 0 then
      begin
        lvObj.FObject.Free;
        FreeMem(lvObj, SizeOf(TObjectBlock));
        FObjectList.Delete(i);
      end;
    end;

    //重置信号
    makeSingle;
  finally
    unLock;
  end;
end;

constructor TMyObjectPool.Create(pvObjectClass: TClass = nil);
begin
  inherited Create;
  FObjectClass := pvObjectClass;
  
  FLocker := TCriticalSection.Create();

  FObjectList := TList.Create;

  //默认可以使用5个
  FMaxNum := 5;

  //创建信号灯,手动控制
  FReleaseSingle := CreateEvent(nil, True, True, nil);

  makeSingle;
end;

function TMyObjectPool.createObject: TObject;
begin
  Result := nil;
  if FObjectClass <> nil then
  begin
    Result := FObjectClass.Create;
  end;      
end;

destructor TMyObjectPool.Destroy;
begin
  waitForReleaseSingle;  
  clear;
  FLocker.Free;
  FObjectList.Free;
  CloseHandle(FReleaseSingle);
  inherited Destroy;
end;

procedure TMyObjectPool.DoGiveBackObject(pvObjBlock: PObjectBlock);
begin
  try
    onGiveBackObject(pvObjBlock.FObject);
  except
    on e:Exception do
    begin
      TFileLogger.instance.logMessage('归还对象时(onGiveBackObject)出现了异常:' + e.Message, 'POOL_ERROR_');
    end;
  end;
end;

function TMyObjectPool.getBusyCount: Integer;
begin
  Result := FBusyCount;
end;

{ TMyObjectPool }

procedure TMyObjectPool.releaseObject(pvObject:TObject);
var
  i:Integer;
  lvObj:PObjectBlock;
  lvMsg:String;
begin
  lock;
  try
    for i := 0 to FObjectList.Count - 1 do
    begin
      lvObj := PObjectBlock(FObjectList[i]);
      if lvObj.FObject = pvObject then
      begin
        if lvObj.FMarkWillFreeFlag then
        begin          //需要释放对象
          try
            //释放该对象
            pvObject.Free;
          except
            on E:Exception do
            begin
              try
                lvMsg := FName + '释放池对象出现了异常, 连接池使用计数器:'
                  + IntToStr(lvObj.FUsingCounter) + ',' + e.Message;
                TFileLogger.instance.logMessage(lvMsg,
                  'POOL_ERROR_');
              except
              end;
            end;
          end;
          lvObj.FObject := nil;
          FreeMem(lvObj, SizeOf(TObjectBlock));
          FObjectList.Delete(i);
        end else
        begin
          lvObj.FRelaseTime := GetTickCount;

          //归还时执行
          DoGiveBackObject(lvObj);

          //置使用标记
          Dec(lvObj.FUsingCounter);
        end;

        //减少正在忙的个数
        Dec(FBusyCount);
        
        Break;
      end;
    end;
  finally
    unLock;
  end;
  makeSingle;
end;

procedure TMyObjectPool.resetPool;
begin
  waitForReleaseSingle;

  clear;
end;

procedure TMyObjectPool.unLock;
begin
  if FCurrentThreadID <> GetCurrentThreadId then
  begin
    raise Exception.Create('有大问题');
  end;
  FLocker.Leave;
end;

function TMyObjectPool.borrowObject: TObject;
var
  i:Integer;
  lvObj:PObjectBlock;
  lvObject:TObject;
  lvType:Integer;
  lvThreadID:Cardinal;
begin
  lock;
  try
    lvObject := nil;
    
    ///是否还有可以直接使用的
    if (FObjectList.Count - FBusyCount) > 0 then
    begin
      for i := 0 to FObjectList.Count - 1 do
      begin
        lvObj := PObjectBlock(FObjectList[i]);
        if (lvObj.FUsingCounter = 0)
          and (not lvObj.FMarkWillFreeFlag)
          then
        begin    // 空闲，标志使用
          lvObject := lvObj.FObject;
          break;
        end;
      end;

      if (lvObject = nil) or (lvObj.FUsingCounter > 0) then
      begin
         raise Exception.CreateFmt('创建借用,连接池(%s-%s)出现了不应该出现的问题!', [self.ClassName, self.FName]);
      end;

      lvType := 0;
    end;

    if lvObject = nil then    //尝试创建对象
    begin

      if GetCount >= FMaxNum then
      begin
        raise exception.CreateFmt('超出对象池[%s]允许的范围[%d],不能再创建新的对象', [self.ClassName, FMaxNum]);
      end;

      lvObj := nil;
      lvObject := createObject;
      if lvObject = nil then raise exception.CreateFmt('不能得到对象,对象池[%s]未继承处理createObject函数', [self.ClassName]);
      try
        GetMem(lvObj, SizeOf(TObjectBlock));
        ZeroMemory(lvObj, SizeOf(TObjectBlock));
        lvObj.FObject := lvObject;
        FObjectList.Add(lvObj);
      except
        try
          lvObject.Free;
        except
        end;
        if lvObj <> nil then FreeMem(lvObj, SizeOf(TObjectBlock));
        raise;
      end;

      lvType := 1;
    end;

    if lvObject = nil then
    begin
      raise Exception.CreateFmt('创建借用判断对象,连接池(%s-%s)出现了不应该出现的问题!', [self.ClassName, self.FName]);
    end;

    if lvObj.FUsingCounter > 0 then
    begin
      raise Exception.CreateFmt('创建借用判断,连接池(%s-%s)出现了不应该出现的问题(lvObj.FUsingCounter> 0)!', [self.ClassName, self.FName]);
    end;  

    //累计计数器
    Inc(lvObj.FUsingCounter);

    lvObj.FThreadID := GetCurrentThreadId;
    lvObj.FMarkWillFreeFlag := False;
    lvObj.FBorrowTime := GetTickCount;
    lvObj.FRelaseTime := 0;

    Inc(FBusyCount);

    Result := lvObject;
  finally
    unLock;
  end;

end;

procedure TMyObjectPool.makeObjectWillFree(pvObject: TObject);
var
  i:Integer;
  lvObj:PObjectBlock;
  lvMsg :String;
begin
  lock;
  try
    for i := 0 to FObjectList.Count - 1 do
    begin
      lvObj := PObjectBlock(FObjectList[i]);
      if (lvObj.FObject = pvObject) then
      begin
        try
          lvMsg := FName + '池对象被标志释放, 对象使用计数器:'
            + IntToStr(lvObj.FUsingCounter);
            
          if lvObj.FUsingCounter > 1 then
          begin
            TFileLogger.instance.logMessage(lvMsg,
              'POOL_ERROR_');
          end else
          begin
            TFileLogger.instance.logMessage(lvMsg,
              'POOL_DEBUG_');
          end;
        except
        end;
        
        lvObj.FMarkWillFreeFlag := true;
        Break;
      end;    
    end;
  finally
    unLock;
  end;
end;

procedure TMyObjectPool.makeSingle;
begin
  if FBusyCount > 0 then
  begin
    //没有信号
    ResetEvent(FReleaseSingle);
  end else
  begin
    //全部归还有信号
    SetEvent(FReleaseSingle)
  end;
end;

procedure TMyObjectPool.onGiveBackObject(pvObject: TObject);
begin
  ;
end;

function TMyObjectPool.GetCount: Integer;
begin
  Result := FObjectList.Count;
end;

procedure TMyObjectPool.lock;
begin
  FLocker.Enter;
  FCurrentThreadID := GetCurrentThreadId;
end;

function TMyObjectPool.waitForReleaseSingle: Boolean;
var
  lvRet:DWORD;
begin
  Result := false;
  lvRet := WaitForSingleObject(FReleaseSingle, INFINITE);
  if lvRet = WAIT_OBJECT_0 then
  begin
    Result := true;
  end;
end;

function TMyObjectPool.killDeadLockObjects(pvTimeOut: Integer = 30 * 1000):
    Integer;
var
  i:Integer;
  lvTimeCounter, lvCounter:Cardinal;
  lvObj:PObjectBlock;
  lvMsg:string;

begin
  Result := 0;
  lock;
  try
    lvCounter := GetTickCount;
    for i := FObjectList.Count - 1 downto 0 do
    begin
      lvObj := PObjectBlock(FObjectList[i]);
      if lvObj.FUsingCounter > 0 then   //正在使用的对象
      begin
        lvTimeCounter := (lvCounter - lvObj.FBorrowTime);
        if (lvTimeCounter >= pvTimeOut) or (lvObj.FMarkWillFreeFlag) then
        begin      //超时
          if lvObj.FUsingCounter > 0 then
          begin
            Dec(FBusyCount);
          end;

          try
            lvObj.FObject.Free;
          except
            on E:Exception do
            begin
              try
                lvMsg := FName + '释放池对象出现了异常, 连接池使用计数器:'
                  + IntToStr(lvObj.FUsingCounter) + ',' + e.Message;
                TFileLogger.instance.logMessage(lvMsg,
                  'POOL_ERROR_');
              except
              end;
            end;
          end;

          try
            lvMsg :=
              Format('池(%s) 对象超时检测释放, 对象使用计数器:%d, 允许超时TimeOut:%d, 借出计时:%d',
                [FName, lvObj.FUsingCounter, pvTimeOut, lvTimeCounter]);
            TFileLogger.instance.logMessage(lvMsg,
              'POOL_KILL_');
          except
          end;
        
          FreeMem(lvObj, SizeOf(TObjectBlock));
          FObjectList.Delete(i); 
          Inc(Result);
        end;
      end;
    end;
    makeSingle;
  finally
    unLock;
  end;
end;

procedure TMyObjectPool.SetMaxNum(const Value: Integer);
begin
  FMaxNum := Value;
  makeSingle;
end;

end.
