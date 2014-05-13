unit uIOCPTools;

interface

uses
  winsock2, Windows, SysUtils, Classes;

const
  SIO_KEEPALIVE_VALS = IOC_IN or IOC_VENDOR or 4;

type
  TKeepAlive = record
    OnOff: Integer;
    KeepAliveTime: Integer;
    KeepAliveInterval: Integer;
  end;
  TTCP_KEEPALIVE = TKeepAlive;
  PTCP_KEEPALIVE = ^TKeepAlive;

  TIOCPTools = class(TObject)
  public
  
    /// <summary>
    ///   socket处理心跳
    ///   如果处理心跳，系统会每３秒中加入一次的心跳。并且如果客户端断线以后（网线断），函数GetQueuedCompletionStatus会返回FALSE。
    /// if (GetQueuedCompletionStatus(CompletionPort, BytesTransferred,DWORD(
    /// PerHandleData), POverlapped(PerIoData), INFINITE) = False) then
    /// begin
    ///    //在这里处理客户端断线信息。
    /// 　continue;
    /// end;
    /// </summary>
    /// <param name="socket"> (TSocket) </param>
    class function socketInitializeHeart(const socket:TSocket): Boolean;

    
    class procedure checkSocketInitialize;

    class function getCPUNumbers: Integer;
  end;

implementation

uses
  uIOCPFileLogger;


var
  __initialized:Boolean;

class function TIOCPTools.socketInitializeHeart(const socket:TSocket): Boolean;
var
  Opt, insize, outsize: integer;
  outByte: DWORD;
  inKeepAlive, outKeepAlive: TTCP_KEEPALIVE;
begin
  Result := false;
  Opt := 1;
  if SetSockopt(socket, SOL_SOCKET, SO_KEEPALIVE,
     @Opt, sizeof(Opt)) = SOCKET_ERROR then
    CloseSocket(socket);

  inKeepAlive.OnOff := 1;

  //设置３秒钟时间间隔
  inKeepAlive.KeepAliveTime := 3000;

  //设置每３秒中发送１次的心跳
  inKeepAlive.KeepAliveInterval := 1;
  insize := sizeof(TTCP_KEEPALIVE);
  outsize := sizeof(TTCP_KEEPALIVE);

  if WSAIoctl(socket,
     SIO_KEEPALIVE_VALS,
     @inKeepAlive, insize,
     @outKeepAlive,
    outsize, outByte, nil, nil) = SOCKET_ERROR then
  begin
    TIOCPFileLogger.logWSAError('加入心跳检测');
    closeSocket(socket);
  end else
  begin
    Result := true;
  end;

end;

class procedure TIOCPTools.checkSocketInitialize;
var
  lvRET: Integer;
  WSData: TWSAData;
begin
  if __initialized then exit;  
  //在WSAStartup()中对Windows Sockets DLL进行初始化，协商Winsock的版本支持，
  //并分配必要的资源。在应用程序关闭Sockets后，还必须要调用WSACleanup()终止对Windows Sockets DLL的使用，并释放资源，以备下一次使用。
  lvRET := WSAStartup($0202, WSData);
  
  if lvRET <> 0 then
    raise Exception.Create(SysErrorMessage(GetLastError));
    
  __initialized := true;
end;

class function TIOCPTools.getCPUNumbers: Integer;
var
  lvSystemInfo: TSystemInfo;
begin
  GetSystemInfo(lvSystemInfo);
  Result := lvSystemInfo.dwNumberOfProcessors;
end;

end.
