unit uICSSocketWrapper;

interface

uses
  OverbyteIcsWSocket, SysUtils, Classes, superobject, Windows, SyncObjs;

type
  TICSSocketWrapper = class(TObject)
  private
    FEvent:TEvent;
    
    FActive: Boolean;
    FHost: string;
    FPort: string;
    FSocket: TWSocket;
    procedure WaitForConnect;
  protected
    procedure OnSocketDataAvailable(Sender: TObject; ErrCode: Word);
    procedure OnSocketSessionClosed(Sender: TObject; ErrCode: Word);
    procedure OnSocketSessionConnected(Sender: TObject; ErrCode: Word);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Open;

    property Active: Boolean read FActive;
    property Host: string read FHost write FHost;
    property Port: string read FPort write FPort;
    property Socket: TWSocket read FSocket;

  end;

implementation

uses
  Dialogs, Forms;

constructor TICSSocketWrapper.Create;
begin
  inherited Create;
  FSocket := TWSocket.Create(nil);
  FSocket.OnDataAvailable := self.OnSocketDataAvailable;
  FSocket.OnSessionConnected := self.OnSocketSessionConnected;
  FSocket.OnSessionClosed := self.OnSocketSessionClosed;
  FActive := false;

  //初始为无信号
  FEvent := TEvent.Create(nil, true, False, '');
end;

destructor TICSSocketWrapper.Destroy;
begin
  FEvent.Free;
  FreeAndNil(FSocket);
  inherited Destroy;
end;

procedure TICSSocketWrapper.OnSocketDataAvailable(Sender: TObject; ErrCode:
    Word);
var
  lvRecv            : ISuperObject;
  lvStream          : TMemoryStream;
  lvSize, lvRecvSize: Integer;
  lvBuffer, lvTempBuffer: string;
  lvRecvBuffer      : PChar;
  lvIsTimeOut       : Boolean;
begin
  lvSize := FSocket.RcvdCount;
  SetLength(lvTempBuffer, lvSize);
  lvSize := FSocket.Receive(PChar(lvTempBuffer), lvSize);

//  if lvSize > 0 then
//  begin
//    //写入Buffer方便拆包
//    FReceivedBuffer.WriteBuffer(PChar(lvTempBuffer), lvSize);
//    DoProcessCommand;
//  end;
end;

procedure TICSSocketWrapper.OnSocketSessionClosed(Sender: TObject; ErrCode:
    Word);
begin
  FActive := false;
  //if Assigned(FOnConnectedChanged) then FOnConnectedChanged(Self, 0);
end;

procedure TICSSocketWrapper.OnSocketSessionConnected(Sender: TObject; ErrCode:
    Word);
begin
  FActive := true;
  FEvent.SetEvent;
//  if Assigned(FOnConnectedChanged) then FOnConnectedChanged(Self, 1);
//  if FConnectedAfterExecute then
//  begin
//    FConnectedAfterExecute := false;
//    self.Execute;
//  end;
end;

procedure TICSSocketWrapper.Open;
begin
  FActive := false;
  FEvent.ResetEvent;
  
  FSocket.Port := self.Port;
  FSocket.Addr := self.Host;
  FSocket.Connect;

  self.WaitForConnect;

  //FEvent.WaitFor(5 * 1000);
  if FActive then showMessage('打开成功!')
  else ShowMessage('打开失败!');

end;

procedure TICSSocketWrapper.WaitForConnect;
begin
  while not FActive do
  begin
    Application.ProcessMessages;
  end;
end;

end.
