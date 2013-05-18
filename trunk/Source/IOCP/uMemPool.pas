unit uMemPool;

interface

uses
  JwaWinsock2, Windows, SyncObjs, uIOCPProtocol;


type
  TIODataMemPool = class(TObject)
  private
    FCs: TCriticalSection;

    //第一个可用的内存块
    FHead: POVERLAPPEDEx;

    //最后一个可用的内存卡
    FTail: POVERLAPPEDEx;

    //可用的内存个数
    FUseableCount:Integer;

    //正在使用的个数
    FUsingCount:Integer;

    /// <summary>
    ///   将一个内存块添加到尾部
    /// </summary>
    /// <param name="pvIOData"> (POVERLAPPEDEx) </param>
    procedure AddData2Pool(pvIOData:POVERLAPPEDEx);

    /// <summary>
    ///   得到一块可以使用的内存
    /// </summary>
    /// <returns> POVERLAPPEDEx
    /// </returns>
    function getUsableData: POVERLAPPEDEx;

    /// <summary>
    ///   创建一块内存空间
    /// </summary>
    /// <returns> POVERLAPPEDEx
    /// </returns>
    function InnerCreateIOData: POVERLAPPEDEx;

    procedure clearMemBlock(pvIOData:POVERLAPPEDEx);

    //释放所有的内存块
    procedure FreeAllBlock;
  public
    class function instance: TIODataMemPool;
    constructor Create;
    destructor Destroy; override;

    //借一块内存
    function borrowIOData: POVERLAPPEDEx;

    //换会一块内存
    procedure giveBackIOData(const pvIOData: POVERLAPPEDEx);

    function getCount: Cardinal;
    function getUseableCount: Cardinal;
    function getUsingCount:Cardinal;

  end;

implementation

uses
  uIOCPFileLogger;

var
  __IODATA_instance:TIODataMemPool;

constructor TIODataMemPool.Create;
begin
  inherited Create;
  FCs := TCriticalSection.Create();
  FUseableCount := 0;
  FUsingCount := 0;
end;

destructor TIODataMemPool.Destroy;
begin
  FreeAllBlock;
  FCs.Free;
  inherited Destroy;
end;

{ TIODataMemPool }

procedure TIODataMemPool.AddData2Pool(pvIOData:POVERLAPPEDEx);
begin
  if FHead = nil then
  begin
    FHead := pvIOData;
    FHead.next := nil;
    FHead.pre := nil;
    FTail := pvIOData;
  end else
  begin
    FTail.next := pvIOData;
    pvIOData.pre := FTail;
    FTail := pvIOData;
  end;
  Inc(FUseableCount);
end;

function TIODataMemPool.InnerCreateIOData: POVERLAPPEDEx;
begin
  Result := POVERLAPPEDEx(GlobalAlloc(GPTR, sizeof(OVERLAPPEDEx)));

  GetMem(Result.DataBuf.buf, MAX_OVERLAPPEDEx_BUFFER_SIZE);

  Result.DataBuf.len := MAX_OVERLAPPEDEx_BUFFER_SIZE;

  //清理一块内存
  clearMemBlock(Result);
end;

function TIODataMemPool.borrowIOData: POVERLAPPEDEx;
begin
  FCs.Enter;
  try
    Result := getUsableData;
    if Result = nil then
    begin
      //生产一个内存块
      Result := InnerCreateIOData;

      //直接借走<增加使用计数器>
      Inc(FUsingCount);
    end;
  finally
    FCs.Leave;
  end;
end;

procedure TIODataMemPool.clearMemBlock(pvIOData: POVERLAPPEDEx);
begin
  //清理一块内存
  pvIOData.IO_TYPE := 0;

  pvIOData.WorkBytes := 0;
  pvIOData.WorkFlag := 0;

  //ZeroMemory(@pvIOData.Overlapped, sizeof(OVERLAPPED));

  //还原大小<分配时的大小>
  pvIOData.DataBuf.len := MAX_OVERLAPPEDEx_BUFFER_SIZE;

  //ZeroMemory(pvIOData.DataBuf.buf, pvIOData.DataBuf.len);
end;

procedure TIODataMemPool.FreeAllBlock;
var
  lvNext, lvData:POVERLAPPEDEx;
begin
  lvData := FHead;
  while lvData <> nil do
  begin
    //记录下一个
    lvNext := lvData.next;

    //释放当前Data
    FreeMem(lvData.DataBuf.buf, lvData.DataBuf.len);
    GlobalFree(Cardinal(lvData));

    //准备释放下一个
    lvData := lvNext;
  end;

  FHead := nil;
  FTail := nil;

  FUsingCount := 0;
  FUseableCount := 0; 

end;

function TIODataMemPool.getCount: Cardinal;
begin
  Result := FUseableCount + FUsingCount;
end;

procedure TIODataMemPool.giveBackIOData(const pvIOData:
    POVERLAPPEDEx);
begin
  FCs.Enter;
  try
    if (pvIOData.pre <> nil) or (pvIOData.next <> nil) or (pvIOData = FHead) then
    begin
      TIOCPFileLogger.logErrMessage('回收内存块是出现了异常,该内存块已经回收!');

    end else
    begin
      //清理内存块
      clearMemBlock(pvIOData);

      //加入到可以使用的内存空间
      AddData2Pool(pvIOData);

      //减少使用计数器
      Dec(FUsingCount);
    end;
  finally
    FCs.Leave;
  end;
end;

function TIODataMemPool.getUsableData: POVERLAPPEDEx;
var
  lvPre:POVERLAPPEDEx;
begin
  if FTail = nil then
  begin
    Result := nil;
  end else  
  begin   
    Result := FTail;

    lvPre := FTail.pre;
    if lvPre <> nil then
    begin
      lvPre.next := nil;
      FTail := lvPre;
    end else  //FTail是第一个也是最后一个,只有一个
    begin
      FHead := nil;
      FTail := nil;
    end;  

    Result.next := nil;
    Result.pre := nil;

    Dec(FUseableCount);
    Inc(FUsingCount);
  end;
end;

function TIODataMemPool.getUseableCount: Cardinal;
begin
  Result := FUseableCount;
end;

function TIODataMemPool.getUsingCount: Cardinal;
begin
  Result := FUsingCount;
end;

class function TIODataMemPool.instance: TIODataMemPool;
begin
  Result := __IODATA_instance;
end;


initialization
  __IODATA_instance := TIODataMemPool.Create;

finalization
  if __IODATA_instance <> nil then
  begin
    __IODATA_instance.Free;
    __IODATA_instance := nil;
  end;

end.
