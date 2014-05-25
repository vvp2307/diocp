unit uClientContext;
                               
interface

uses
  Windows, uBuffer, SyncObjs, Classes, SysUtils,
  uIOCPCentre, JSonStream, uIOCPFileLogger;

type
  TClientContext = class(TIOCPClientContext)
  protected
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    procedure DoOnWriteBack; override;

    procedure recvBuffer(buf:PAnsiChar; len:Cardinal); override;

  public


    

  end;

implementation

uses
  uIOCPDebugger, uWorkDispatcher;

procedure TClientContext.DoConnect;
begin
  inherited;
end;

procedure TClientContext.DoDisconnect;
begin
  
  inherited;
end;



procedure TClientContext.DoOnWriteBack;
begin
  inherited;
end;

procedure TClientContext.recvBuffer(buf:PAnsiChar; len:Cardinal);
var
  lvObject:TObject;
begin
  add2Buffer(buf, len);

  self.StateINfo := '接收到数据,准备进行解码';

  while True do
  begin
    //调用注册的解码器<进行解码>
    lvObject := decodeObject;
    if lvObject <> nil then
    begin
      try
        self.StateINfo := '解码成功,准备投递到任务队列';

        TIOCPDebugger.incRecvObjectCount;

        //解码成功，投递到队列
        workDispatcher.push(lvObject, self);
      except
        on E:Exception do
        begin
          TIOCPFileLogger.logErrMessage('截获处理逻辑异常!' + e.Message);
        end;
      end;
    end else
    begin
      //缓存中没有可以使用的完整数据包,跳出循环
      Break;
    end;
  end;

  //清理缓存<如果没有可用的内存块>清理
  clearRecvedBuffer;
end;

end.
