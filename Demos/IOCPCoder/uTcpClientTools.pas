unit uTcpClientTools;

interface

uses
  Sockets, Classes,  Windows, SysUtils, winsock;


type
  TTcpClientTools = class(TObject)
  public
    class function recvBuffer(pvSocket: TTcpClient; buf: Pointer; len: Cardinal):
        Integer;
    class function sendBuffer(pvSocket: TTcpClient; buf: Pointer; len: Cardinal):
        Integer;
    class function sendStream(pvSocket: TTcpClient; pvStream: TStream): Integer;
  end;

implementation

const
  BUF_BLOCK_SIZE = 1024 * 50;

class function TTcpClientTools.recvBuffer(pvSocket: TTcpClient; buf: Pointer;
    len: Cardinal): Integer;
begin
  Result := pvSocket.ReceiveBuf(buf^, len);
  if Result = SOCKET_ERROR then
  begin
    raise Exception.CreateFmt('recv error:%d', [WSAGetLastError]);
  end;
  


end;

class function TTcpClientTools.sendBuffer(pvSocket: TTcpClient; buf: Pointer;
    len: Cardinal): Integer;
begin
  Result :=pvSocket.SendBuf(buf^, len);
end;

class function TTcpClientTools.sendStream(pvSocket: TTcpClient; pvStream:
    TStream): Integer;
var
  lvBufBytes:array[0..BUF_BLOCK_SIZE-1] of byte;
  l, j, lvTotal:Integer;
begin
  Result := 0;
  if pvStream = nil then Exit;
  if pvStream.Size = 0 then Exit;

  lvTotal :=0;
  
  pvStream.Position := 0;
  repeat
    FillMemory(@lvBufBytes[0], SizeOf(lvBufBytes), 0);
    l := pvStream.Read(lvBufBytes[0], SizeOf(lvBufBytes));
    if (l > 0) and pvSocket.Connected then
    begin
      j := sendBuffer(pvSocket, @lvBufBytes[0], l);
      if j = SOCKET_ERROR then
      begin
        raise Exception.CreateFmt('send buffer error:[%d]', [j]);
      end;

      if j <> l then
      begin
        raise Exception.CreateFmt('发送Buffer错误指定发送%d,实际发送:%d', [j, l]);
      end else
      begin
        lvTotal := lvTotal + j;
      end;
    end else Break;
  until (l = 0);
  Result := lvTotal;
end;

end.
