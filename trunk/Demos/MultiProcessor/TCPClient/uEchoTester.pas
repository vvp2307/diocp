unit uEchoTester;

interface

uses
  Classes, sockets, SysUtils,
  superobject,
  Windows, FileLogger, uTcpClientJSonStreamCoder,
  JSonStream, SyncObjs;

type
  TEchoTester = class(TThread)
  private
    FCrc:Cardinal;
    FEchoCode: string;
    FClient: TTcpClient;
    function createObject: TJSonStream;
    procedure echoWork(pvObject: TJSonStream);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Execute;override;

    property Client: TTcpClient read FClient;

    property EchoCode: string read FEchoCode write FEchoCode;   

    
  end;

var
  __threadCount:Integer;
  __sendCount:Integer;
  __recvCount:Integer;
  __recvAllCount:Integer;
  __recvErrCount:Integer;
  __errCount:Integer;

  __maxTime:Integer;

  __cs:TCriticalSection;

  __tester_terminate:Byte;



implementation

uses
  ComObj, uJSonStreamTools;

procedure setEchoTime(pvTime:Integer);
begin
  __cs.Enter;
  try
    if pvTime > __maxTime then
    begin
      __maxTime := pvTime;
    end;
  finally
    __cs.Leave;
  end;
  
end;

constructor TEchoTester.Create;
begin
  inherited Create(true);
  FClient := TTCPClient.Create(nil);
  FClient.BlockMode := bmBlocking;
  FEchoCode := CreateClassID;
  InterlockedIncrement(__threadCount);
end;

destructor TEchoTester.Destroy;
begin
  FClient.Free;
  InterlockedDecrement(__threadCount);
  inherited Destroy;
end;

function TEchoTester.createObject: TJSonStream;
var
  lvStream:TMemoryStream;
  lvData:String;
begin
  Result := TJSonStream.Create;
  
  Result.JSon := SO();
  Result.JSon.I['cmdIndex'] := 1000;   //echo 数据测试
  Result.JSon.S['data'] := '测试发送打包数据';
  Result.JSon.S['EchoCode'] := FEchoCode;
  Result.Json.B['config.stream.zip'] := false;
  
  SetLength(lvData, 1024);
  FillChar(lvData[1], 1024, Ord('1'));
  Result.Stream.WriteBuffer(lvData[1], Length(lvData));
end;

procedure TEchoTester.echoWork(pvObject: TJSonStream);
var
  lvKey:String;
  lvTickCount:Cardinal;
begin
  lvKey := CreateClassID;
  pvObject.Json.S['key'] := lvKey;
  lvTickCount := GetTickCount;
  pvObject.Json.I['sendTime'] := lvTickCount;
  TTcpClientJSonStreamCoder.Encode(FClient, pvObject);
  InterlockedIncrement(__sendCount);

  TTcpClientJSonStreamCoder.Decode(FClient, pvObject);

  if pvObject.Json.I['sendTime'] <> 0 then
  begin
    lvTickCount := pvObject.Json.I['sendTime'];
  end;

  setEchoTime(GetTickCount - lvTickCount);


  if (pvObject.Json.S['key'] <> lvKey) then
  begin
    InterlockedIncrement(__recvErrCount);
  end else
  begin
    InterlockedIncrement(__recvCount);
  end;
end;

{ TEchoTester }

procedure TEchoTester.Execute;
var
  lvJSonObject:TJsonStream;
  i:Integer;
begin
  i:= 0;
  lvJSonObject := createObject;
  try
    while (not self.Terminated) and (__tester_terminate = 0) do
    begin
      try
        if not FClient.Connected then
        begin
          FClient.Connect;
        end;

        if FClient.Connected then
        begin
          echoWork(lvJSonObject);
          Inc(i);
        end;

        Sleep(1000);

      except
        on E:Exception do
        begin
          TFileLogger.instance.logErrMessage(FEchoCode + E.Message);
        end;
      end;
    end;
    TFileLogger.instance.logDebugMessage(FEchoCode + '线程已经停止[' + IntToStr(i) + ']');
    FClient.Disconnect;
  finally
    lvJSonObject.Free;
  end;

end;

initialization
  __cs := TCriticalSection.Create;
  __maxTime := 0;

finalization
  __cs.Free;

end.
