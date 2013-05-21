unit uIOCPCentre;


{$if CompilerVersion>= 23}
  {$define NEED_NativeUInt}
{$ifend}


interface

uses
  JwaWinsock2, Windows, SysUtils, uIOCPTools,
  uMemPool,
  uIOCPProtocol, uBuffer, SyncObjs, Classes, IdGlobal;

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
    ///   编码要发生的对象
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
    function DoInnerCreateContext: TIOCPClientContext;

    procedure clear;
    function GetCount: Integer;
  public
    constructor Create;

    destructor Destroy; override;
    
    function createContext(ASocket: TSocket): TIOCPClientContext;

    procedure freeContext(context: TIOCPClientContext);

    property BusyCount: Integer read FBusyCount;

    property count: Integer read Getcount;
  end;
  



  TIOCPObject = class(TObject)
  private
    FCS: TCriticalSection;

    //在线的列表
    FContextOnLineList: TList;

    //服务端套接字
    FSSocket:Cardinal;

    //IOCP内核端口
    FIOCoreHandle:Cardinal;

    //侦听端口
    FPort: Integer;

    //添加到在线列表
    procedure Add(pvContext:TIOCPClientContext);

    //从在线列表中移除
    procedure Remove(pvContext:TIOCPClientContext);

    function PostWSASendBlock(pvSocket: TSocket; pvIOData: POVERLAPPEDEx): Boolean;

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

  end;


  TIOCPClientContext = class(TObject)
  private
    //正在使用
    FUsing:Boolean;

    //已经投递了关闭请求
    FPostedCloseQuest:Boolean;

    FCS:TCriticalSection;

    FIOCPObject:TIOCPObject;

    FSocket: TSocket;

    FBuffers: TBufferLink;

    //关闭客户端连接
    procedure closeClientSocket;

    //投递一个关闭请求
    function PostWSAClose: Boolean;
  protected
    procedure DoConnect;virtual;
    procedure DoDisconnect;virtual;
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

    procedure RecvBuffer(buf:PAnsiChar; len:Cardinal);

    function AppendBuffer(buf:PAnsiChar; len:Cardinal): Cardinal;

    function readBuffer(buf:PAnsiChar; len:Cardinal): Cardinal;

    destructor Destroy; override;

    property Buffers: TBufferLink read FBuffers;
    
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
  uIOCPFileLogger;


var
  __factoryInstance:TIOCPContextFactory;

constructor TIOCPObject.Create;
begin
  inherited Create;
  FContextOnLineList := TList.Create();
  FCS := TCriticalSection.Create();
end;

destructor TIOCPObject.Destroy;
begin
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
begin
  //  If no error occurs, WSAAccept returns a value of type SOCKET
  //  that is a descriptor for the accepted socket.
  //  Otherwise, a value of INVALID_SOCKET is returned,
  //  and a specific error code can be retrieved by calling WSAGetLastError.
  
  lvSocket := WSAAccept(FSSocket, nil, nil, nil, 0);
  if (lvSocket = INVALID_SOCKET) then
  begin
    TIOCPFileLogger.logWSAError('接收新的客户端连接出现异常!');
  end else
  begin
    
    //加入心跳
    TIOCPTools.socketInitializeHeart(lvSocket);

    ///
    lvClientContext := TIOCPContextFactory.instance.createContext(lvSocket);
    lvClientContext.FIOCPObject := Self;
    lvClientContext.DoConnect;

     //将套接字、完成端口客户端对象绑定在一起。
     //2013年4月20日 13:45:10
     lvPerIOPort := CreateIoCompletionPort(lvSocket, FIOCoreHandle, Cardinal(lvClientContext), 0);
     if (lvPerIOPort = 0) then
     begin
        Exit;
     end;
     ////----end

     //初始化数据包
     lvIOData := TIODataMemPool.instance.borrowIOData;

     //数据包中的IO类型:有连接请求
     lvIOData.IO_TYPE := IO_TYPE_Accept;

     //通知工作线程,有新的套接字连接<第三个参数>
     if not PostQueuedCompletionStatus(
        FIOCoreHandle,
        1,   ///>>>传1, 0的话会断开连接
      {$if defined(NEED_NativeUInt)}
        NativeUInt(lvClientContext),
      {$ELSE}
        Cardinal(lvClientContext),
      {$ifend}
        POverlapped(lvIOData)) then
     begin     
       //投递失败
       lvErr := GetLastError;
       TIOCPFileLogger.logErrMessage('acceptClient>>PostQueuedCompletionStatus投递连接请求失败!');

       //关闭
       TIOCPContextFactory.instance.freeContext(lvClientContext);

       //归还
       TIODataMemPool.instance.giveBackIOData(lvIOData);
     end;
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
  
  //假如心跳
  if TIOCPTools.socketInitializeHeart(FSSocket) then
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
    lvIOData.DataBuf.len := ouBuf.readBuffer(lvIOData.DataBuf.buf, lvIOData.DataBuf.len);

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
  lvErrCode, lvRet, i:Integer;
begin
  i := 1;
  Result := False;
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
    end else
    begin    //没有错误,发送完成
      Result := true;
      Break;
    end;
  end;
end;

function TIOCPObject.processIOQueued: Integer;
var
  BytesTransferred:Cardinal;
  lvResultStatus:BOOL;
  lvRet:Integer;
  lvIOData:POVERLAPPEDEx;

  lvDataObject:TObject;

  lvClientContext:TIOCPClientContext;
begin
  Result := IOCP_RESULT_OK;

  //工作者线程会停止到GetQueuedCompletionStatus函数处，直到接受到数据为止
  lvResultStatus := GetQueuedCompletionStatus(FIOCoreHandle,
    BytesTransferred,
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
    if lvRet = ERROR_NETNAME_DELETED then
    begin

    end;
    
    TIOCPFileLogger.logErrMessage('GetQueuedCompletionStatus返回False,错误代码:' + IntToStr(lvRet));

    if (lvClientContext<>nil) then
    begin
      TIOCPContextFactory.instance.freeContext(lvClientContext);
    end;
    if lvIOData<>nil then
    begin
      TIODataMemPool.instance.giveBackIOData(lvIOData);
    end;
  end else if BytesTransferred = 0 then  //客户端断开连接
  begin
    TIOCPFileLogger.logDebugMessage('客户端断开!');
    if (lvClientContext <> nil) then
    begin                       //已经关闭
      TIOCPContextFactory.instance.freeContext(lvClientContext);
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
      //加入到套接字对应的缓存中，处理逻辑
      lvClientContext.RecvBuffer(lvIOData.DataBuf.buf,
        lvIOData.Overlapped.InternalHigh);

      TIODataMemPool.instance.giveBackIOData(lvIOData);

      //继续投递接收请求
      PostWSARecv(lvClientContext);
    end else if lvIOData.IO_TYPE = IO_TYPE_Send then
    begin    //发送完成数据<WSASend>完成
      //回收数据块
      TIODataMemPool.instance.giveBackIOData(lvIOData);
      //不必要投递接收请求
      
    end else if lvIOData.IO_TYPE = IO_TYPE_Close then
    begin    //关闭请求

      //回收数据块
      TIODataMemPool.instance.giveBackIOData(lvIOData);

      //关闭回收lvClientContext,iocp队列中还存在对应socket的接收需求
      TIOCPContextFactory.instance.freeContext(lvClientContext);
      //不必要投递接收请求
    end;    
  end;
end;

procedure TIOCPObject.Remove(pvContext: TIOCPClientContext);
begin
  FCS.Enter;
  try
    FContextOnLineList.Remove(pvContext);
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
    DoDisconnect;
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
  FBuffers.Free;
  FBuffers := nil;
  closeClientSocket;
  FCS.Free;
  FCS := nil;
  inherited Destroy;
end;

procedure TIOCPClientContext.DoConnect;
begin
  FIOCPObject.Add(Self);  
end;

procedure TIOCPClientContext.DoDisconnect;
begin
  FIOCPObject.Remove(Self);
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
  FCS.Enter;
  try
    //加入到套接字对应的缓存
    FBuffers.AddBuffer(buf, len);

    //调用注册的解码器<进行解码>
    lvObject := TIOCPContextFactory.instance.FDecoder.Decode(FBuffers);
    if lvObject <> nil then
    try
      //解码成功，调用业务逻辑的处理方法
      dataReceived(lvObject);

      //清理掉这一次分配的内存
      FBuffers.clearBuffer;
    finally
      lvObject.Free;
    end;
  finally
    FCS.Leave;
  end;
end;

procedure TIOCPClientContext.writeObject(const pvDataObject:TObject);
var
  lvOutBuffer:TBufferLink;
begin
  lvOutBuffer := TBufferLink.Create;
  try
    TIOCPContextFactory.instance.FEncoder.Encode(pvDataObject, lvOutBuffer);
    FIOCPObject.PostWSASend(self.FSocket, lvOutBuffer);
    DoOnWriteBack;
  finally
    lvOutBuffer.Free;
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
end;

function TIOCPContextPool.createContext(ASocket: TSocket): TIOCPClientContext;
begin
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
  finally
    FCS.Leave;
  end;
end;

destructor TIOCPContextPool.Destroy;
begin
  clear;
  FCS.Free;
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TIOCPContextPool.clear;
begin
  FCS.Enter;
  try
    while FList.Count > 0 do
    begin
      TIOCPClientContext(FList[0]).Free;
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
  FCS.Enter;
  try
    if not context.FUsing then exit;  //已经回收

    try
      //关闭
      context.CloseClientSocket;
    except
      on E:Exception do
      begin
        TIOCPFileLogger.logErrMessage('回收context时执行CloseClientSocket出现了异常!' + e.Message);
      end;                                                                                                  
    end;
    
    //可以使用
    context.FUsing := False;
    
    FList.Add(context);

    Dec(FBusyCount);
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

initialization
  __factoryInstance := TIOCPContextFactory.Create;

finalization
  __factoryInstance.Free;
  __factoryInstance := nil;

end.
