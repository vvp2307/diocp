unit uClientSocket;

interface

uses
  Windows, WinSock, uSocketTools;

type

  TClientSocket = class(TObject)
  private
    FTimeOut:Cardinal;

    FActive:Boolean;
    
    FHost: String;

    FPort: Integer;

    FSocketHandle: TSocket;

    procedure closeSocketHandle;

    function createSocket: Boolean;


    procedure DoHandleError;

    function socketErrorCheck(rc: Integer): Integer;

  public
    function WaitForData: Boolean;

    //检测一次端口是否可以操作,如果不可以操作进行异常打开。
    procedure checkOpen;

  public

    constructor Create;

    property Active: Boolean read FActive;
    
    property Host: String read FHost write FHost;
       
    property Port: Integer read FPort write FPort;

    property SocketHandle: TSocket read FSocketHandle;
    property TimeOut: Cardinal read FTimeOut;

    destructor Destroy; override;

    procedure open;

    procedure close;
    
    function recvBuffer(buf: PAnsiChar; len: Cardinal): Integer;
    
    function sendBuffer(buf: PAnsiChar; len: Cardinal): Integer;
  end;




implementation

uses
  SysUtils;


procedure TClientSocket.closeSocketHandle;
begin
  if FSocketHandle <> INVALID_SOCKET then closesocket(FSocketHandle);
  FSocketHandle := INVALID_SOCKET;
end;

constructor TClientSocket.Create;
begin
  inherited Create;
  FTimeOut := 30 * 1000;
  FSocketHandle := INVALID_SOCKET;
end;

destructor TClientSocket.Destroy;
begin
  inherited Destroy;
end;

procedure TClientSocket.checkOpen;
var
  lvIsActive, lvReadReady, lvWriteReady, lvExceptFlag: Boolean;
  lvRet:Integer;
  Sockin,Add : TSockAddrIn;
  l:Integer;
  lvTmpBuffer:array[0..1] of Byte;

begin
  if not FActive then
  begin
    //直接进行打开
    open;
  end else
  begin
     //都不行貌似..
     lvRet := TSocketTools.selectSocket(FSocketHandle,
       @lvReadReady, @lvWriteReady, @lvExceptFlag, FTimeOut);
     if lvRet = SOCKET_ERROR then
     begin
       lvIsActive := false;
     end else
     begin
       lvIsActive := lvWriteReady and (not lvExceptFlag);
     end;

     if not lvIsActive then
     begin
       //进行一次关闭
       close;

       //重新打开
       Open;
     end;
  end;
end;

procedure TClientSocket.close;
begin
  if FActive then
  begin
    shutdown(FSocketHandle, SD_BOTH);
    closesocket(FSocketHandle);
    FActive := false;
  end;
  closeSocketHandle;
end;

function TClientSocket.createSocket: Boolean;
begin
  FSocketHandle := socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  if FSocketHandle <> INVALID_SOCKET then
  begin
    Result := true;
  end else
  begin
    Result := false;
  end;
end;

procedure TClientSocket.DoHandleError;
var
  lvErrCode: Integer;
  lvMsg:String;
begin
  lvErrCode := WSAGetLastError;
  case lvErrCode of
    WSAECONNREFUSED:
      begin      //10061
        lvMsg :='与服务器连接错误!';
      end;
    WSAECONNRESET:
      begin      //10054
        //Connection reset by peer.
        //  An existing connection was forcibly closed by the remote host.
        lvMsg :='服务器强制断开[10054]!';
        close();
      end;
    WSAECONNABORTED:
      //10053
      //  Software caused connection abort.
      //    An established connection was aborted by the software in your host computer,
      //    possibly due to a data transmission time-out or protocol error.
      begin
        lvMsg :='连接中断[10053]!';
        close(); 
      end;
    WSAENOTSOCK:
      begin      //10038
        // Socket operation on nonsocket.
        // An operation was attempted on something that is not a socket.
        // Either the socket handle parameter did not reference a valid socket, or for select,
        // a member of an fd_set was not valid.
        lvMsg :='操作的是一个无效的socket!';
      end;
  else
    lvMsg := '';
  end;
  if lvMsg <> '' then
  begin
    lvMsg := lvMsg + sLineBreak + Format('错误代码:%d', [lvErrCode]);
  end else
  begin
    lvMsg := lvMsg + sLineBreak + Format('Socket错误,错误代码:%d', [lvErrCode]);
  end;
  raise Exception.Create(lvMsg);
end;

procedure TClientSocket.open;
var
  lvAddr: TSockAddr;
begin
  TSocketTools.checkSocketInitialize;
  if createSocket then
  begin
    lvAddr := TSocketTools.getSocketAddr(FHost, FPort);
    try
      TSocketTools.socketErrorCheck(WinSock.connect(FSocketHandle, lvAddr, sizeof(TSockAddr)));
      FActive := true;
    except
      FActive := false;
      close;
      raise;
    end;
  end;
end;

function TClientSocket.recvBuffer(buf: PAnsiChar; len: Cardinal): Integer;
begin
  Result :=socketErrorCheck(recv(FSocketHandle, buf^, len, 0));
end;

function TClientSocket.sendBuffer(buf: PAnsiChar; len: Cardinal): Integer;
begin
  Result := socketErrorCheck(send(FSocketHandle, buf^, len, 0));
end;

function TClientSocket.socketErrorCheck(rc: Integer): Integer;
begin
  Result := rc;
  if rc = SOCKET_ERROR then
  begin
    DoHandleError;
  end;
end;

function TClientSocket.WaitForData: Boolean;
var
  ReadReady, ExceptFlag: Boolean;
  c: Char;
  lvTimeOut, lvRet:Integer;
begin
  Result := False;
  // Select also returns True when connection is broken.

  lvRet :=socketErrorCheck(
     TSocketTools.selectSocket(FSocketHandle,
     @ReadReady, nil, @ExceptFlag, FTimeOut)
     );
  if lvRet <> SOCKET_ERROR  then
  begin
    Result := ReadReady and not ExceptFlag;
  end else if lvRet = 0 then
  begin
    Result := false;
    raise Exception.Create('等待接收超时!');
  end;

end;

end.
