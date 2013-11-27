unit uIOCPCentre;


{$IF CompilerVersion>= 23}
  {$define NEED_NativeUInt}
{$IFEND}


interface

uses
  JwaWinsock2, Windows, SysUtils, uIOCPTools,
  uMemPool,
  uIOCPProtocol, uBuffer, SyncObjs, Classes;

type
  TIOCPClientContext = class;
  TIOCPClientContextClass = class of TIOCPClientContext;

  TIOCPDecoder = class(TObject)
  public
    /// <summary>
    ///   解码收到的数据,如果有接收到数据,调用该方法,进行解码
    /// </summary>
    /// <returns>
    ///   返回解码好的对象
    /// </returns>
    /// <param name="inBuf"> 接收到的流数据 </param>
    function Decode(const inBuf: TBufferLink): TObject; virtual; abstract;
  end;

  TIOCPEncoder = class(TObject)
  public
    /// <summary>
    ///   编码要发送的对象
    /// </summary>
    /// <param name="pvDataObject"> 要进行编码的对象 </param>
    /// <param name="ouBuf"> 编码好的数据 </param>
    procedure Encode(pvDataObject:TObject; const ouBuf: TBufferLink); virtual;
        abstract;
  end;

  TIOCPContextPool = class(TObject)
  private
    FBusyCount:Integer;
    FCS:TCriticalSection;
    FContextClass:TIOCPClientContextClass;
    FList: TList;
    FUsingList:TList;
    function DoInnerCreateContext: TIOCPClientContext;
    procedure clear;
    function GetCount: Integer;
  public
    constructor Create;

    destructor Destroy; override;

    function createContext(ASocket: TSocket): TIOCPClientContext;

    procedure getUsingList(pvList:TList);

    procedure freeContext(context: TIOCPClientContext);

    property BusyCount: Integer read FBusyCount;



    property count: Integer read Getcount;
  end;
  



  TIOCPObject = class(TObject)
  private
    FDebug_Locker:TCriticalSection;
    FCS: TCriticalSection;

    //在线的列表
    FContextOnLineList: TList;

    //服务端套接字
    FSSocket:Cardinal;

    //IOCP内核端口
    FIOCoreHandle:Cardinal;

    //侦听端口
    FPort: Integer;
    FsystemSocketHeartState: Boolean;

    //添加到在线列表
    procedure Add(pvContext:TIOCPClientContext);

    //从在线列表中移除
    function Remove(pvContext:TIOCPClientContext): Boolean;

    function PostWSASendBlock(pvSocket: TSocket; pvIOData: POVERLAPPEDEx): Boolean;

    procedure interlockIncDebugVar(var v:Cardinal; incValue:Cardinal);
    procedure interlockDecDebugVar(var v:Cardinal; decValue:Cardinal);
  public
    constructor Create;

    destructor Destroy; override;
    // <summary>
    //   创建IOCP端口
    // </summary>
    function createIOCPCoreHandle: Boolean;

    //接收一个客户端连接
    procedure acceptClient;

    //创建服务端端口
    function createSSocket: Boolean;



    //关闭服务端端口
    procedure closeSSocket;

    /// <summary>
    ///   关闭所有连接
    /// </summary>
    procedure DisconnectAllClientContext;


    //1 等待资源的回归
    procedure WaiteForResGiveBack;


    /// <summary>
    ///   投递一个退出请求
    /// </summary>
    procedure PostExitIO;


    /// <summary>
    ///   处理一个IO队列
    /// </summary>
    function processIOQueued: Integer;


    /// <summary>
    ///    向队列中投递发送数据请求
    /// </summary>
    /// <param name="pvSocket"> (TSocket) </param>
    /// <param name="ouBuf"> (TBufferLink) </param>
    procedure PostWSASend(pvSocket: TSocket; const ouBuf: TBufferLink);

    /// <summary>
    ///   向IOCP队列中投递关闭客户端请求
    /// </summary>
    /// <param name="pvClientContext"> (TIOCPClientContext) </param>
    function PostWSAClose(pvClientContext:TIOCPClientContext): Boolean;

    /// <summary>
    ///    向队列中投递一个接收数据请求
    /// </summary>
    procedure PostWSARecv(const pvClientContext: TIOCPClientContext);

    //开启侦听端口
    function ListenerBind: Boolean;

    //侦听端口
    property Port: Integer read FPort write FPort;

    //是否处理默认的socket心跳
    property systemSocketHeartState: Boolean read FsystemSocketHeartState write
        FsystemSocketHeartState default true;



  end;


  TIOCPClientContext = class(TObject)
  private
    //正常释放
    FNormalFree:Boolean;
    
    FRemoteAddr:String;
    FRemotePort:Integer;

    //正在忙....
    //是否正在忙
    FIsBusying:Boolean;

    //等待回收标记,等忙完进行回收
    FWaitingGiveBack:Boolean;

    //正在使用
    FUsing:Boolean;

    //已经投递了关闭请求
    FPostedCloseQuest:Boolean;

    FCS:TCriticalSection;

    FIOCPObject:TIOCPObject;

    FSocket: TSocket;

    FBuffers: TBufferLink;
    FStateINfo: String;

    //关闭客户端连接
    procedure closeClientSocket;
    function GetStateINfo: String;

    //投递一个关闭请求
    function PostWSAClose: Boolean;

    procedure getPeerINfo;

    procedure invokeConnect;
    procedure invokeDisconnect;
    procedure Lock;
    procedure unLock;

    procedure RecvBuffer(buf:PAnsiChar; len:Cardinal);

    function AppendBuffer(buf:PAnsiChar; len:Cardinal): Cardinal;

    function readBuffer(buf:PAnsiChar; len:Cardinal): Cardinal;
  protected
    //复位<回收时进行复位>
    procedure Reset; virtual;

    //借到，调用该函数
    procedure Initialize4Use; virtual;


    procedure DoConnect; virtual;
    procedure DoDisconnect; virtual;
    procedure DoOnWriteBack; virtual;
  public

    procedure notifyStopWork; virtual;

    constructor Create(ASocket: TSocket = 0);


    /// <summary>
    ///   数据处理
    /// </summary>
    /// <param name="pvDataObject"> (TObject) </param>
    procedure dataReceived(const pvDataObject:TObject); virtual;

    procedure close;


    /// <summary>
    ///   将数据返回给客户端
    /// </summary>
    /// <param name="pvDataObject"> (TObject) </param>
    procedure writeObject(const pvDataObject:TObject);



    destructor Destroy; override;

    property Buffers: TBufferLink read FBuffers;
    property RemoteAddr: String read FRemoteAddr;
    property RemotePort: Integer read FRemotePort;

    //状态信息
    property StateINfo: String read GetStateINfo write FStateINfo;

    
    
    //property Socket: TSocket read FSocket;
  end;




  TIOCPContextFactory = class(TObject)
  private
    FIOCPContextPool: TIOCPContextPool;
    FDecoder:TIOCPDecoder;
    FEncoder:TIOCPEncoder;
  public
    class function instance: TIOCPContextFactory;
  public
    constructor Create;
    destructor Destroy; override;

    function createContext(ASocket: TSocket): TIOCPClientContext;

    procedure freeContext(context: TIOCPClientContext);

    //尝试进行关闭客户端，并进行回收
    procedure tryExecuteCloseContext(context: TIOCPClientContext);

    /// <summary>
    ///   注册客户端处理类
    /// </summary>
    /// <param name="pvClass"> (TIOCPClientContextClass) </param>
    procedure registerClientContextClass(pvClass:TIOCPClientContextClass);
    
    /// <summary>
    ///   注册解码器
    /// </summary>
    /// <param name="pvDecoder"> (TIOCPDecoder) </param>
    procedure registerDecoder(pvDecoder:TIOCPDecoder);

    /// <summary>
    ///   注册编码器
    /// </summary>
    /// <param name="pvEncoder"> (TIOCPEncoder) </param>
    procedure registerEncoder(pvEncoder:TIOCPEncoder);
    
    property IOCPContextPool: TIOCPContextPool read FIOCPContextPool;
  end;

implementation

uses
  uIOCPFileLogger, uIOCPDebugger;


var
  __factoryInstance:TIOCPContextFactory;

constructor TIOCPObject.Create;
begin
  inherited Create;
  FsystemSocketHeartState := true;
  FContextOnLineList := TList.Create();
  FCS := TCriticalSection.Create();
  FDebug_Locker := TCriticalSection.Create();
end;

destructor TIOCPObject.Destroy;
begin
  FDebug_Locker.Free;
  FreeAndNil(FCS);
  FreeAndNil(FContextOnLineList);
  inherited Destroy;
end;

procedure TIOCPObject.acceptClient;
var
  lvSocket: TSocket;

  lvPerIOPort:THandle;

  lvIOData:POVERLAPPEDEx;

  lvClientContext:TIOCPClientContext;

  lvErr:Integer;

  addr: Tsockaddrin;
  addrlen: integer;
begin
  //  If no error occurs, WSAAccept returns a value of type SOCKET
  //  that is a descriptor for the accepted socket.
  //  Otherwise, a value of INVALID_SOCKET is returned,
  //  and a specific error code can be retrieved by calling WSAGetLastError.

  addrlen := sizeof(addr);
  //lvSocket := Accept(FSSocket, @addr, @addrlen);
  lvSocket := WSAAccept(FSSocket, nil, nil, nil, 0);
  if (lvSocket = INVALID_SOCKET) then
  begin
    TIOCPFileLogger.logWSAError('接收新的客户端连接出现异常!');
  end else
  begin

    if FsystemSocketHeartState then
    begin
      //加入心跳
      TIOCPTools.socketInitializeHeart(lvSocket);
    end;


    ///借用一个对象
    lvClientContext := TIOCPContextFactory.instance.createContext(lvSocket);

     //将套接字、完成端口客户端对象绑定在一起。
     //2013年4月20日 13:45:10
     lvPerIOPort := CreateIoCompletionPort(lvSocket, FIOCoreHandle, Cardinal(lvClientContext), 0);
     if (lvPerIOPort = 0) then
     begin
        Exit;
     end;

    lvClientContext.Initialize4Use;
    lvClientContext.FIOCPObject := Self;
    lvClientContext.getPeerINfo;
    lvClientContext.invokeConnect;


     ////----end

     //有连接进入，投递一个接收
     PostWSARecv(lvClientContext);
  end;
end;

procedure TIOCPObject.Add(pvContext: TIOCPClientContext);
begin
  FCS.Enter;
  try
    FContextOnLineList.Add(pvContext);
  finally
    FCS.Leave;
  end;
end;

procedure TIOCPObject.closeSSocket;
begin
  CloseSocket(FSSocket);
  FSSocket := INVALID_HANDLE_VALUE;
end;

function TIOCPObject.createIOCPCoreHandle: Boolean;
begin
  // 创建一个完成端口（内核对象）
  FIOCoreHandle := CreateIoCompletionPort(INVALID_HANDLE_VALUE, 0, 0, 0);
  Result := (FIOCoreHandle <> 0) and (FIOCoreHandle <> INVALID_HANDLE_VALUE);
  if not Result then
  begin
    TIOCPFileLogger.logErrMessage('创建IOCP内核对象出现了异常,错误代码:' + IntToStr(GetLastError));
  end;
end;

function TIOCPObject.createSSocket: Boolean;
begin    
  Result := false;
  
  FSSocket:=WSASocket(AF_INET,SOCK_STREAM,IPPROTO_IP,Nil,0,WSA_FLAG_OVERLAPPED);
  if FSSocket=SOCKET_ERROR then
  begin
    TIOCPFileLogger.logWSAError('创建服务端端口!');
    CloseSocket(FSSocket);
    FSSocket := INVALID_HANDLE_VALUE;
  end;

  if FsystemSocketHeartState then
  begin
    //假如心跳
    if TIOCPTools.socketInitializeHeart(FSSocket) then
    begin
      Result := true;
    end;
  end else
  begin
    Result := true;
  end;
end;

procedure TIOCPObject.DisconnectAllClientContext;
var
  i:Integer;
begin
  FCS.Enter;
  try
    for i := FContextOnLineList.Count - 1 downto 0 do
    begin
       //通知退出
       TIOCPClientContext(FContextOnLineList[i]).notifyStopWork;
    end;
  finally
    FCS.Leave;
  end;
end;

procedure TIOCPObject.interlockDecDebugVar(var v: Cardinal; decValue: Cardinal);
begin
  FDebug_Locker.Enter;
  try
    v := v - decValue;
  finally
    FDebug_Locker.Leave;
  end;
end;

procedure TIOCPObject.interlockIncDebugVar(var v: Cardinal; incValue: Cardinal);
begin
  FDebug_Locker.Enter;
  try
    v := v + incValue;
  finally
    FDebug_Locker.Leave;
  end;
end;

procedure TIOCPObject.PostExitIO;
begin
   //通知工作线程,有新的套接字连接<第三个参数>
   PostQueuedCompletionStatus(
      FIOCoreHandle,
      1,   ///>>>传1, 0的话会断开连接
      0,
      POverlapped(IOCP_Queued_SHUTDOWN)
    );
end;

procedure TIOCPObject.PostWSARecv(const pvClientContext: TIOCPClientContext);
var
  lvIOData:POVERLAPPEDEx;
  lvRet:Integer;
begin
  /////分配内存<可以加入内存池>
  lvIOData := TIODataMemPool.instance.borrowIOData;
  lvIOData.IO_TYPE := IO_TYPE_Recv;

  /////异步收取数据
  if (WSARecv(pvClientContext.FSocket,
     @lvIOData.DataBuf,
     1,
     lvIOData.WorkBytes,
     lvIOData.WorkFlag,
     @lvIOData^, nil) = SOCKET_ERROR) then
  begin
    //MSDN:
    //If no error occurs and the receive operation has completed immediately,
    //WSARecv returns zero. In this case,
    //the completion routine will have already been scheduled to be called once the calling thread is in the alertable state.
    //Otherwise, a value of SOCKET_ERROR is returned, and a specific error code can be retrieved by calling WSAGetLastError.
    //The error code WSA_IO_PENDING indicates that the overlapped operation has been successfully
    //initiated and that completion will be indicated at a later time. Any other error code indicates that the overlapped operation
    //was not successfully initiated and no completion indication will occur.

    lvRet := WSAGetLastError();
    //重叠IO,出现ERROR_IO_PENDING是正常的，
    //表示数据尚未接收完成，如果有数据接收，GetQueuedCompletionStatus会有返回值
    if (lvRet <> WSA_IO_PENDING) then
    begin
      TIODataMemPool.instance.giveBackIOData(lvIOData);      
      
      TIOCPFileLogger.logErrMessage('TIOCPObject.PostWSARecv,投递WSARecv出现异常,socket进行了关闭, 错误代码:' + IntToStr(lvRet));

      pvClientContext.PostWSAClose;
    end;
  end;
end;

procedure TIOCPObject.PostWSASend(pvSocket: TSocket; const ouBuf: TBufferLink);
var
  lvIOData:POVERLAPPEDEx;
  lvErrCode, lvRet:Integer;
begin
  while ouBuf.validCount > 0 do
  begin
    lvIOData := TIODataMemPool.instance.borrowIOData;
    lvIOData.IO_TYPE := IO_TYPE_Send;
    lvIOData.DataBuf.len :=
      ouBuf.readBuffer(lvIOData.DataBuf.buf, lvIOData.DataBuf.len);

    //发送一个内存块
    if not PostWSASendBlock(pvSocket, lvIOData) then
    begin
      //发送不成功
      TIODataMemPool.instance.giveBackIOData(lvIOData);
      closesocket(pvSocket);
      Break;
    end;
  end;
end;

function TIOCPObject.PostWSASendBlock(pvSocket: TSocket; pvIOData:
    POVERLAPPEDEx): Boolean;
var
  lvErrCode, lvRet, i, l:Integer;
begin
  i := 1;
  Result := False;
  l := pvIOData.DataBuf.len;
  while i<=10 do    //尝试10次,如果还不成功就返回false
  begin
    //如果立刻发送成功  0也会触发队列
    lvRet :=WSASend(pvSocket,
       @pvIOData.DataBuf,
       1,
       pvIOData.WorkBytes,
       pvIOData.WorkFlag,
       @pvIOData^, nil);
    if (lvRet = SOCKET_ERROR) then
    begin
      lvErrCode := GetLastError();
      case lvErrCode of
        ERROR_IO_PENDING:
         begin     //出现ERROR_IO_PENDING是正常的，表示数据尚未发送完成，
                   //如果数据发送成功，GetQueuedCompletionStatus会有返回值
            TIOCPDebugger.incWSASendbytesSize(l);
            Result := true;
            Break;
         end;

        //首先，Winsock 异常 10035 WSAEWOULDBLOCK (WSAGetLastError) 的意识是 Output Buffer 已经满了，无法再写入数据。
        //确切的说它其实不算是个错误，出现这种异常的绝大部分时候其实都不存在 Output Buffer 已满情况，而是处于一种“忙”的状态，
        //而这种“忙”的状态还很大程度上是由于接收方造成的。
        //意思就是你要发送的对象，对方收的没你发的快或者对方的接受缓冲区已被填满，所以就返回你一个“忙”的标志，而这时你再发多少数据都没任何意义，
        //所以你的系统就抛出个 WSAEWOULDBLOCK 异常通知你，叫你别再瞎忙活了。
        WSAEWOULDBLOCK:
          begin
             //休息100，等待再次发送
             TIOCPFileLogger.logErrMessage(Format('投递发送数据时发生了错误错误代码:%d', [lvErrCode]));
             Sleep(100);
          end;
        WSAECONNRESET:
          begin       //An existing connection was forcibly closed by the remote host
            TIOCPFileLogger.logErrMessage(Format('投递发送数据时发生了错误错误代码:%d', [lvErrCode]));
            Result := false;
            Break;
          end;
        WSAENETRESET:  //Network dropped connection on reset.
          begin //The connection has been broken due to keep-alive
                //activity detecting a failure while the operation was in progress.
            TIOCPFileLogger.logErrMessage(Format('投递发送数据时发生了错误错误代码:%d', [lvErrCode]));
            Result := false;
            Break;
          end;
      else
        begin     //退出循环
          TIOCPFileLogger.logErrMessage(Format('投递发送数据时发生了错误错误代码:%d', [lvErrCode]));
          Result := false;
          Break;
        end;
      end;
    end else if lvRet = 0 then
    begin    //没有错误,发送完成
      //成功投递
      //l := pvIOData.DataBuf.len;
      TIOCPDebugger.incWSASendbytesSize(l);
      Result := true;
      Break;
    end else
    begin
      TIOCPFileLogger.logErrMessage(Format('投递发送数据时发生了错误错误代码:%d', [lvErrCode]));
      Result := false;
      Break;
    end;
  end;
end;

function TIOCPObject.processIOQueued: Integer;
var
  lvBytesTransferred:Cardinal;
  lvResultStatus:BOOL;
  lvRet:Integer;
  lvIOData:POVERLAPPEDEx;

  lvDataObject:TObject;

  lvClientContext:TIOCPClientContext;
begin
  Result := IOCP_RESULT_OK;

  //工作者线程会停止到GetQueuedCompletionStatus函数处，直到接受到数据为止
  lvResultStatus := GetQueuedCompletionStatus(FIOCoreHandle,
    lvBytesTransferred,
    {$if defined(NEED_NativeUInt)}
      NativeUInt(lvClientContext),
    {$ELSE}
      Cardinal(lvClientContext),
    {$ifend}

    POverlapped(lvIOData),
    INFINITE);

  if DWORD(lvIOData) = IOCP_Queued_SHUTDOWN then
  begin
    TIOCPFileLogger.logDebugMessage('工作线程被通知退出!');
    Result := IOCP_RESULT_EXIT;     //通知工作现在退出
  end else if (lvResultStatus = False) then
  begin
    //当客户端连接断开或者客户端调用closesocket函数的时候,函数GetQueuedCompletionStatus会返回错误。如果我们加入心跳后，在这里就可以来判断套接字是否依然在连接。
    lvRet := GetLastError;

    //{ The specified network name is no longer available. }
    if lvRet = ERROR_NETNAME_DELETED then  //64
    begin

    end;

    TIOCPFileLogger.logDebugMessage('GetQueuedCompletionStatus返回False,错误代码:' + IntToStr(lvRet));

    if (lvClientContext<>nil) then
    begin
      //2013年10月24日 14:56:33
      //如果逻辑正在处理，或者卡死，会导致工作线程被卡死
      //尝试关闭并归还ClientContext
      TIOCPContextFactory.instance.tryExecuteCloseContext(lvClientContext);
      lvClientContext := nil;
    end;
    if lvIOData<>nil then
    begin
      TIODataMemPool.instance.giveBackIOData(lvIOData);
    end;
  end else if lvBytesTransferred = 0 then  //客户端断开连接
  begin
    if (lvClientContext <> nil) then
    begin                       //已经关闭
      //尝试关闭并归还ClientContext
      TIOCPContextFactory.instance.tryExecuteCloseContext(lvClientContext);

      lvClientContext := nil;
    end;
    if lvIOData<>nil then
    begin
      TIODataMemPool.instance.giveBackIOData(lvIOData);
    end;
  end else if (lvIOData<>nil) then
  begin
    if lvIOData.IO_TYPE = IO_TYPE_Accept then  //连接请求
    begin
      TIODataMemPool.instance.giveBackIOData(lvIOData);
      PostWSARecv(lvClientContext);
    end else if lvIOData.IO_TYPE = IO_TYPE_Recv then
    begin
      try
        try
          //已经接收字节数
          TIOCPDebugger.incRecvBytesSize(lvBytesTransferred);
          TIOCPDebugger.incRecvBlockCount;

          lvClientContext.Lock;
          try
            lvClientContext.FIsBusying := true;
            //加入到套接字对应的缓存中，处理逻辑
            lvClientContext.RecvBuffer(lvIOData.DataBuf.buf,
              lvIOData.Overlapped.InternalHigh);
          finally
            lvClientContext.FIsBusying := false;
            lvClientContext.unLock;
          end;

          //需要进行回收
          if lvClientContext.FWaitingGiveBack then
          begin
            TIOCPContextFactory.instance.tryExecuteCloseContext(lvClientContext);
          end else
          begin   //不再进行逻辑的处理
            //继续投递接收请求
            PostWSARecv(lvClientContext);
          end;
        except
          ON E:Exception do
          begin
             TIOCPFileLogger.logErrMessage(
               'TIOCPObject.processIOQueued.IO_TYPE_Recv, 出现异常:' + e.Message);
          end;
        end;
      finally
        //内存块的回收是必须的
        TIODataMemPool.instance.giveBackIOData(lvIOData);
      end;  
    end else if lvIOData.IO_TYPE = IO_TYPE_Send then
    begin    //发送完成数据<WSASend>完成

      if lvIOData.DataBuf.len <> lvBytesTransferred then
      begin
        TIOCPFileLogger.logDebugMessage('发送字节不一致.');
      end;

      //已经发送字节数
      TIOCPDebugger.incSendbytesSize(lvBytesTransferred);
      TIOCPDebugger.incSendBlockCount;

      //回收数据块
      TIODataMemPool.instance.giveBackIOData(lvIOData);
      //不必要投递接收请求
      
    end else if lvIOData.IO_TYPE = IO_TYPE_Close then
    begin    //关闭请求

      //回收数据块
      TIODataMemPool.instance.giveBackIOData(lvIOData);

      //尝试关闭并归还ClientContext
      TIOCPContextFactory.instance.tryExecuteCloseContext(lvClientContext);
    end;
  end;
end;

function TIOCPObject.Remove(pvContext:TIOCPClientContext): Boolean;
begin
  FCS.Enter;
  try
    Result := FContextOnLineList.Remove(pvContext) <> -1;
  finally
    FCS.Leave;
  end;                                   
end;

function TIOCPObject.ListenerBind: Boolean;
var
  lvAddr:TSockAddr;
  lvAddrSize:Integer;
begin
  result := false;
  lvAddr.sin_family:=AF_INET;
  lvAddr.sin_port:=htons(FPort);
  lvAddr.sin_addr.s_addr:=htonl(INADDR_ANY);
  if bind(FSSocket,@lvAddr,sizeof(lvAddr))=SOCKET_ERROR then
  begin
    TIOCPFileLogger.logWSAError('绑定(bind,FSSocket)出现异常!');
    Closesocket(FSSocket);
    exit;
  end;

  //If no error occurs, listen returns zero. Otherwise,
  //a value of SOCKET_ERROR is returned, and a specific error code
  // can be retrieved by calling WSAGetLastError.
  if listen(FSSocket,20) = SOCKET_ERROR then
  begin
    TIOCPFileLogger.logWSAError('绑定(bind,FSSocket)出现异常!');
    Closesocket(FSSocket);
    exit;
  end;

  Result := true;
end;

function TIOCPObject.PostWSAClose(pvClientContext:TIOCPClientContext): Boolean;
var
   lvIOData:POVERLAPPEDEx;
   lvErr:Integer;
begin
   if pvClientContext.FPostedCloseQuest then Exit;


   //  不进行互斥，只是投递到工作IO队列中
   //    2013年11月27日 19:25:55
   //
   //  启用互斥（避免在处理命令的时候投递关闭消息，并在工作线程中进行了处理)
   //pvClientContext.Lock;
   try
     //初始化数据包
     lvIOData := TIODataMemPool.instance.borrowIOData;
     //数据包中的IO类型:关闭请求
     lvIOData.IO_TYPE := IO_TYPE_Close;

     //通知工作线程,有新的套接字连接<第三个参数>
     if not PostQueuedCompletionStatus(
        FIOCoreHandle,
        1,   ///>>>传1, 0的话会断开连接
        Cardinal(pvClientContext),
        POverlapped(lvIOData)) then
     begin
       lvErr := GetLastError;
       TIOCPFileLogger.logErrMessage('PostWSAClose>>PostQueuedCompletionStatus投递关闭请求失败!');
     end else
     begin
      pvClientContext.FPostedCloseQuest := true;
      Result := true;
     end;
   finally
      // pvClientContext.unLock;
   end;
end;

procedure TIOCPObject.WaiteForResGiveBack;
begin
  TIODataMemPool.instance.waiteForGiveBack;
end;

procedure TIOCPClientContext.close;
begin
  PostWSAClose;
end;

procedure TIOCPClientContext.closeClientSocket;
begin
  if (FSocket <> INVALID_SOCKET) and (FSocket <> 0) then
  begin
    invokeDisconnect;
    closesocket(FSocket);
    FSocket := INVALID_SOCKET;
    FBuffers.clearBuffer;
  end;
end;

constructor TIOCPClientContext.Create(ASocket: TSocket = 0);
begin
  inherited Create;
  FUsing := false;
  FCS := TCriticalSection.Create;
  FSocket := ASocket;
  FBuffers := TBufferLink.Create();
end;

destructor TIOCPClientContext.Destroy;
begin
  if not FNormalFree then
  begin
    //非正常Free,记录日志
    TIOCPFileLogger.logErrMessage('TIOCPClientContext.Destroy,被非正常释放,请检测代码');
  end;
  
  closeClientSocket;
  FBuffers.Free;
  FBuffers := nil;
  FCS.Free;
  FCS := nil;
  inherited Destroy;
end;

procedure TIOCPClientContext.DoConnect;
begin

end;

procedure TIOCPClientContext.DoDisconnect;
begin

end;

function TIOCPClientContext.AppendBuffer(buf:PAnsiChar; len:Cardinal): Cardinal;
begin
  FBuffers.AddBuffer(buf, len);
end;

procedure TIOCPClientContext.notifyStopWork;
begin
  //禁止进出
  shutdown(FSocket, SD_BOTH);

  //投递关闭事件
  postWSAClose;
  //shutdown(FSocket, SD_BOTH);
  //CancelIo(FSocket);
end;

procedure TIOCPClientContext.dataReceived(const pvDataObject:TObject);
begin
  
end;

procedure TIOCPClientContext.DoOnWriteBack;
begin
  
end;

procedure TIOCPClientContext.getPeerINfo;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
  HostEnt: PHostEnt;
begin
  Size := SizeOf(SockAddrIn);
  getpeername(FSocket, @SockAddrIn, Size);
  FRemoteAddr := inet_ntoa(SockAddrIn.sin_addr);
  FRemotePort := ntohs(SockAddrIn.sin_port);
end;

function TIOCPClientContext.GetStateINfo: String;
begin
  Result := FStateINfo;
end;

procedure TIOCPClientContext.Initialize4Use;
begin
  FPostedCloseQuest := false;
  FWaitingGiveBack := false;
  FBuffers.clearBuffer;
end;

procedure TIOCPClientContext.invokeConnect;
begin
  FIOCPObject.Add(Self);
  TIOCPDebugger.incClientCount;  
  DoConnect;
end;

procedure TIOCPClientContext.invokeDisconnect;
begin
  if FIOCPObject.Remove(Self) then
  begin
    TIOCPDebugger.decClientCount;
    DoDisconnect;
  end else
  begin
    TIOCPFileLogger.logErrMessage('procedure TIOCPClientContext.invokeDisconnect已经断开!');
  end;                                                                                        
end;

procedure TIOCPClientContext.Lock;
begin
  FCS.Enter;
end;

function TIOCPClientContext.PostWSAClose: Boolean;
begin
  //已经回收
  if self.FUsing = false then Exit;
  Result :=FIOCPObject.PostWSAClose(Self);
end;

function TIOCPClientContext.readBuffer(buf:PAnsiChar; len:Cardinal): Cardinal;
begin
  Result := FBuffers.readBuffer(buf, len);
end;

procedure TIOCPClientContext.RecvBuffer(buf:PAnsiChar; len:Cardinal);
var
  lvObject:TObject;
begin
  //加入到套接字对应的缓存
  FBuffers.AddBuffer(buf, len);

  self.StateINfo := '接收到数据,准备进行解码';

  ////避免一次收到多个包时导致只调用了一次逻辑的处理(dataReceived);
  ///  2013年9月26日 08:57:20
  ///    感谢群内JOE找到bug。
  while True do
  begin
    lvObject := nil;
    //调用注册的解码器<进行解码>
    lvObject := TIOCPContextFactory.instance.FDecoder.Decode(FBuffers);
    if lvObject <> nil then
    begin
      try
        try
          self.StateINfo := '解码成功,准备调用dataReceived进行逻辑处理';

          TIOCPDebugger.incRecvObjectCount;

          //解码成功，调用业务逻辑的处理方法
          dataReceived(lvObject);

          self.StateINfo := 'dataReceived逻辑处理完成!';
        except
          on E:Exception do
          begin
            TIOCPFileLogger.logErrMessage('截获处理逻辑异常!' + e.Message);
          end;
        end;
      finally
        lvObject.Free;
      end;
    end else
    begin
      //缓存中没有可以使用的完整数据包,跳出循环
      Break;
    end;
  end;

  //清理缓存<如果没有可用的内存块>清理
  if FBuffers.validCount = 0 then
  begin
    FBuffers.clearBuffer;
  end else
  begin
    FBuffers.clearHaveReadBuffer;
  end;

end;

procedure TIOCPClientContext.Reset;
begin
  FUsing := false;
  FPostedCloseQuest := false;
  FWaitingGiveBack := false;
  FBuffers.clearBuffer;
end;

procedure TIOCPClientContext.unLock;
begin
  FCS.Leave;
end;

procedure TIOCPClientContext.writeObject(const pvDataObject:TObject);
var
  lvOutBuffer:TBufferLink;
begin
  lvOutBuffer := TBufferLink.Create;
  try
    self.StateINfo := 'TIOCPClientContext.writeObject,准备编码对象到lvOutBuffer';
    TIOCPContextFactory.instance.FEncoder.Encode(pvDataObject, lvOutBuffer);
    FIOCPObject.PostWSASend(self.FSocket, lvOutBuffer);
    
    TIOCPDebugger.incSendObjectCount;
    
    self.StateINfo := 'TIOCPClientContext.writeObject,投递完成';
    DoOnWriteBack;

  finally
    lvOutBuffer.Free;
  end;
end;

procedure TIOCPContextFactory.tryExecuteCloseContext(context:
    TIOCPClientContext);
begin
    //如果正在忙则不进行回收,等待忙完后在进行回收
    if context.FIsBusying then
    begin
      context.FWaitingGiveBack := true;
    end else
    begin
      //如果连接正在处理逻辑,会导致阻塞
      context.Lock;
      try
        //关闭回收lvClientContext,iocp队列中还存在对应socket的接收需求
        freeContext(context);
        //不必要投递接收请求
      finally
        context.unLock;
      end;
    end;
end;

constructor TIOCPContextFactory.Create;
begin
  inherited Create;
  FIOCPContextPool := TIOCPContextPool.Create();
end;

destructor TIOCPContextFactory.Destroy;
begin
  FreeAndNil(FIOCPContextPool);
  inherited Destroy;
end;

function TIOCPContextFactory.createContext(ASocket: TSocket):
    TIOCPClientContext;
begin
  Result := FIOCPContextPool.createContext(ASocket);
end;

procedure TIOCPContextFactory.freeContext(context: TIOCPClientContext);
begin
  FIOCPContextPool.freeContext(context);
end;

class function TIOCPContextFactory.instance: TIOCPContextFactory;
begin
  Result := __factoryInstance;
end;

procedure TIOCPContextFactory.registerClientContextClass(
    pvClass:TIOCPClientContextClass);
begin
  FIOCPContextPool.FContextClass := pvClass;
end;

procedure TIOCPContextFactory.registerDecoder(pvDecoder:TIOCPDecoder);
begin
  FDecoder := pvDecoder;
end;

procedure TIOCPContextFactory.registerEncoder(pvEncoder:TIOCPEncoder);
begin
  FEncoder := pvEncoder;
end;

constructor TIOCPContextPool.Create;
begin
  inherited Create;
  FBusyCount := 0;
  FCS := TCriticalSection.Create;
  FList := TList.Create();
  FUsingList := TList.Create();
end;

function TIOCPContextPool.createContext(ASocket: TSocket): TIOCPClientContext;
begin
//  Result := DoInnerCreateContext;
//  Result.FSocket := ASocket;
//  Result.FUsing := true;

  FCS.Enter;
  try
    if FList.Count = 0 then
    begin
      Result := DoInnerCreateContext;
    end else
    begin
      Result := TIOCPClientContext(FList[0]);
      FList.Delete(0);
    end;
    
    Result.FSocket := ASocket;

    Result.FUsing := true;

    Inc(FBusyCount);
    
    FUsingList.Add(Result);
  finally
    FCS.Leave;
  end;
end;

destructor TIOCPContextPool.Destroy;
begin
  clear;
  FCS.Free;
  FreeAndNil(FList);
  FUsingList.Free;
  inherited Destroy;
end;

procedure TIOCPContextPool.clear;
begin
  FCS.Enter;
  try
    while FList.Count > 0 do
    begin
      try
        TIOCPClientContext(FList[0]).FNormalFree := true;
        TIOCPClientContext(FList[0]).Free;
      except    //屏蔽非法错误
        on E:Exception do
        begin
          TIOCPFileLogger.logDebugMessage('TIOCPContextPool.clear,您的代码存在BUG(非法操作一个TIOCPClientContext对象进行手动释放),释放一个TIOCPClientContext对象时出错,' + e.Message);
        end;
      end;
      FList.Delete(0);
    end;
  finally
    FCS.Leave;
  end;
end;

function TIOCPContextPool.DoInnerCreateContext: TIOCPClientContext;
begin
  if FContextClass = nil then raise Exception.Create('没有注册FContextClass');
  Result := FContextClass.Create();
end;


procedure TIOCPContextPool.freeContext(context: TIOCPClientContext);
begin
  //  context.Free;
  //  context := nil;
  FCS.Enter;
  try
    try
      if not context.FUsing then exit;  //已经回收

      //关闭
      context.CloseClientSocket;
      context.StateINfo := '关闭连接';


      //重置<复位>
      context.Reset;

      FList.Add(context);
      context.StateINfo := '已经回归到池!';

      FUsingList.Remove(context);

      Dec(FBusyCount);
    except
      on E:Exception do
      begin
        TIOCPFileLogger.logErrMessage(
          '回收context时执行TIOCPContextPool.freeContext出现了异常,对象可能已经被损坏(进行对象的释放)!' + e.Message);

        try
           if FUsingList.Remove(context) > 0 then Dec(FBusyCount);
           FList.Remove(context);            
           TIOCPClientContext(FList[0]).FNormalFree := true;
           TIOCPClientContext(FList[0]).Free;
        except
        end;  
      end;
    end;
  finally
    FCS.Leave;
  end;
end;

function TIOCPContextPool.GetCount: Integer;
begin
  FCS.Enter;
  try
    Result := FBusyCount + FList.Count;
  finally
    FCS.Leave;
  end;
end;

procedure TIOCPContextPool.getUsingList(pvList: TList);
var
  i:Integer;
begin
  FCS.Enter;
  try
    for I := 0 to FUsingList.Count - 1 do
    begin
      pvList.Add(FUsingList[i]);
    end;                            
  finally
    FCS.Leave;
  end;
end;

initialization
  __factoryInstance := TIOCPContextFactory.Create;

finalization
  __factoryInstance.Free;
  __factoryInstance := nil;

end.
