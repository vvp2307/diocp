unit uSocketTools;

interface

uses
  Windows, WinSock, Sockets, SysUtils;

type
  TSocketTools = class(TObject)
  private
    class procedure DoHandleError;
  protected
  public
    class procedure checkSocketInitialize;
    class function getSocketAddr(pvHost: string; pvPort: Integer): TSockAddr;
    class function sendBuffer(pvSocket:TSocket; buf:PAnsiChar; len:Cardinal):
        Integer;
    class function recvBuffer(pvSocket:TSocket; buf:PAnsiChar; len:Cardinal):
        Integer;
    //zero if the time limit expired, or SOCKET_ERROR if an error occurred.
    class function selectSocket(pvSocket: TSocket; vReadReady, vWriteReady,
        vExceptFlag: PBoolean; pvTimeOut: Integer = 0): Integer;
        
    class function socketErrorCheck(rc: Integer): Integer; virtual;
  end;

implementation


var
  __initialized :Boolean;


class procedure TSocketTools.checkSocketInitialize;
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

class procedure TSocketTools.DoHandleError;
var
  lvErrCode: Integer;
  lvMsg:String;
begin
  lvErrCode := WSAGetLastError;
  case lvErrCode of
    10061:
      begin
        lvMsg :='与服务器连接错误!';
      end;
    WSAECONNRESET:
      begin      //10054
        //Connection reset by peer.
        //  An existing connection was forcibly closed by the remote host.
        lvMsg :='服务器强制断开!';
      end
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

class function TSocketTools.socketErrorCheck(rc: Integer): Integer;
begin
  Result := rc;
  if rc = SOCKET_ERROR then
  begin
     DoHandleError;
  end;
end;

class function TSocketTools.getSocketAddr(pvHost: string; pvPort: Integer):
    TSockAddr;
begin
  Result.sin_family := AF_INET;
  Result.sin_addr.s_addr := inet_addr(pchar(pvHost));
  Result.sin_port := htons(pvPort);
end;

class function TSocketTools.recvBuffer(pvSocket:TSocket; buf:PAnsiChar;
    len:Cardinal): Integer;
begin
  Result :=socketErrorCheck(recv(pvSocket, buf^, len, 0));
end;

class function TSocketTools.selectSocket(pvSocket: TSocket; vReadReady,
    vWriteReady, vExceptFlag: PBoolean; pvTimeOut: Integer = 0): Integer;
var
  ReadFds: TFDset;
  ReadFdsptr: PFDset;
  WriteFds: TFDset;
  WriteFdsptr: PFDset;
  ExceptFds: TFDset;
  ExceptFdsptr: PFDset;
  tv: timeval;
  Timeptr: PTimeval;
  lvRet:Integer;
begin
  if Assigned(vReadReady) then
  begin
    ReadFdsptr := @ReadFds;
    FD_ZERO(ReadFds);
    FD_SET(pvSocket, ReadFds);
  end
  else
    ReadFdsptr := nil;
  if Assigned(vWriteReady) then
  begin
    WriteFdsptr := @WriteFds;
    FD_ZERO(WriteFds);
    FD_SET(pvSocket, WriteFds);
  end
  else
    WriteFdsptr := nil;
  if Assigned(vExceptFlag) then
  begin
    ExceptFdsptr := @ExceptFds;
    FD_ZERO(ExceptFds);
    FD_SET(pvSocket, ExceptFds);
  end
  else
    ExceptFdsptr := nil;
  if pvTimeOut >= 0 then
  begin
    tv.tv_sec := pvTimeOut div 1000;
    tv.tv_usec :=  1000 * (pvTimeOut mod 1000);
    Timeptr := @tv;
  end
  else
    Timeptr := nil;

  //The select function determines the status of one or more sockets, waiting if necessary,
  //to perform synchronous I/O.
  //  The select function returns the total number of socket handles that are ready
  //  and contained in the fd_set structures,
  //  zero if the time limit expired, or SOCKET_ERROR if an error occurred.
  //  If the return value is SOCKET_ERROR,
  //  WSAGetLastError can be used to retrieve a specific error code.
  
  Result := select(pvSocket + 1, ReadFdsptr, WriteFdsptr, ExceptFdsptr, Timeptr);
  
  if Assigned(vReadReady) then
    vReadReady^ := FD_ISSET(pvSocket, ReadFds);
  if Assigned(vWriteReady) then
    vWriteReady^ := FD_ISSET(pvSocket, WriteFds);
  if Assigned(vExceptFlag) then
    vExceptFlag^ := FD_ISSET(pvSocket, ExceptFds);
end;

class function TSocketTools.sendBuffer(pvSocket:TSocket; buf:PAnsiChar;
    len:Cardinal): Integer;
begin
  Result := socketErrorCheck(send(pvSocket, buf^, len, 0));  
end;

initialization
  __initialized := false;

finalization
  if __initialized then
  begin
    WSACleanup;
  end;

end.
