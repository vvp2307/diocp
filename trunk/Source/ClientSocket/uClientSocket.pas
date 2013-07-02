unit uClientSocket;

///2013年5月28日 09:50:25
///  添加SendBufferEx不进行检测错误的发送
///2013年5月28日 10:33:02
///  抛出等待超时
///2013年5月28日 12:53:58
///  添加raiseException属性
///

{$DEFINE _D10_Debug}

interface

uses
  Windows, WinSock, uSocketTools, SysUtils, Sockets, Classes;

const
  BUF_BLOCK_SIZE = 1024;

type
  TSocketException = class(Exception);

  TClientSocket = class(TObject)
  private
    FLastExceptionMessage:String;
    
    FTimeOut:Cardinal;

    FActive:Boolean;
    
    FHost: String;

    FPort: Integer;

    FRaiseSocketException: Boolean;

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

    property RaiseSocketException: Boolean read FRaiseSocketException write
        FRaiseSocketException;

    property SocketHandle: TSocket read FSocketHandle;
    
    property TimeOut: Cardinal read FTimeOut;

    destructor Destroy; override;

    procedure open;

    procedure close;

    function sendStream(const stm: TStream): Boolean;

    function recvBuffer(buf: PAnsiChar; len: Cardinal): Integer;
    
    function sendBuffer(buf: PAnsiChar; len: Cardinal): Integer;
    
    function SendBufferEx(buf: PAnsiChar; len: Cardinal): Integer;
  end;




implementation



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
  
  FRaiseSocketException := true;
end;

destructor TClientSocket.Destroy;
begin
  inherited Destroy;
end;

procedure TClientSocket.checkOpen;
begin
  if not FActive then
  begin    
    open;
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
  lvDoClose:Boolean;
begin                         
  lvDoClose := true;
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
        lvMsg :='服务器强制断开!';
      end;
    WSAECONNABORTED:
      //10053
      //  Software caused connection abort.
      //    An established connection was aborted by the software in your host computer,
      //    possibly due to a data transmission time-out or protocol error.
      begin
        lvMsg :='连接中断!';
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
  FLastExceptionMessage := lvMsg;

  if lvDoClose then
  begin
    //关闭
    close();
  end;
  if FRaiseSocketException then raise TSocketException.Create(lvMsg);
end;

function TClientSocket.SendBufferEx(buf: PAnsiChar; len: Cardinal): Integer;
begin
  Result := send(FSocketHandle, buf^, len, 0);  
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
      socketErrorCheck(WinSock.connect(FSocketHandle, lvAddr, sizeof(TSockAddr)));
      FActive := true;
    except
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

function TClientSocket.sendStream(const stm: TStream): Boolean;
var
  lvBufBytes:array[0..BUF_BLOCK_SIZE-1] of byte;
  l, j, lvTotal:Integer;
begin
  Result := False;
  if stm = nil then Exit;
  if stm.Size = 0 then Exit;

  lvTotal :=0;
  
  stm.Position := 0;
  repeat
    l := stm.Read(lvBufBytes[0], SizeOf(lvBufBytes));
    if (l > 0) and FActive then
    begin
      j:=sendBuffer(@lvBufBytes[0], l);
      if j <> l then
      begin
        raise Exception.CreateFmt('发送Buffer错误指定发送%d,实际发送:%d', [j, l]);
      end else
      begin
        lvTotal := lvTotal + j;
      end;
    end else Break;
  until (l = 0);
  Result := lvTotal = stm.Size;  
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

  if not FActive then Exit;  

  lvRet :=socketErrorCheck(
     TSocketTools.selectSocket(FSocketHandle,
     @ReadReady, nil, @ExceptFlag, FTimeOut)
     );
  if lvRet = 0 then
  begin
    Result := false;
    raise Exception.Create('等待接收超时!');
  end else if lvRet = SOCKET_ERROR then
  begin
    close;
  end else
  begin
    Result := ReadReady and not ExceptFlag;
           
  end;

end;

end.
