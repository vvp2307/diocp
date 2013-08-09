unit uEchoTester;

interface

uses
  Classes, IdTCPClient, SysUtils,
  IdGlobal, superobject,
  Windows, FileLogger, uIdTcpClientJSonStreamCoder,
  JSonStream;

type
  TEchoTester = class(TThread)
  private
    FCrc:Cardinal;
    FEchoCode: string;
    FClient: TIdTcpClient;
    function createObject: TJSonStream;
    procedure echoWork(pvObject: TJSonStream);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Execute;override;

    property Client: TIdTcpClient read FClient;

    property EchoCode: string read FEchoCode write FEchoCode;   

    
  end;

var
  __threadCount:Integer;
  __sendCount:Integer;
  __recvCount:Integer;
  __recvAllCount:Integer;
  __recvErrCount:Integer;
  __errCount:Integer;



implementation

uses
  ComObj, uJSonStreamTools;

constructor TEchoTester.Create;
begin
  inherited Create(true);
  FClient := TIdTCPClient.Create();
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
  
  SetLength(lvData, 1024 * 4);
  FillChar(lvData[1], 1024 * 4, Ord('1'));
  Result.Stream.WriteBuffer(lvData[1], Length(lvData));

end;

procedure TEchoTester.echoWork(pvObject: TJSonStream);
begin
  TIdTcpClientJSonStreamCoder.Encode(FClient, pvObject);
  TIdTcpClientJSonStreamCoder.Decode(FClient, pvObject);
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
    while (not self.Terminated) do
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

end.
