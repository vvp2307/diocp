unit uTester;

interface

uses
  Classes, IdTCPClient, SysUtils,
  IdGlobal, superobject,
  Windows, uClientSocket, FileLogger, uD10ClientSocket, uJSonStreamClientCoder,
  JSonStream, uRDBOperator, DBClient;

type
  TTester = class(TThread)
  private
    FTesterCode: string;
    FRDBOperator:TRDBOperator;
    FConnection: TD10ClientSocket;
    FSQL: String;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Execute;override;

    property Connection: TD10ClientSocket read FConnection;
    
    property SQL: String read FSQL write FSQL;

    property TesterCode: string read FTesterCode write FTesterCode;


  end;

var
  __TesterCount :Integer;
  __stop:Boolean;

implementation

uses
  ComObj, uJSonStreamTools;

constructor TTester.Create;
begin
  inherited Create(true);
  FConnection := TD10ClientSocket.Create();
  FConnection.registerCoder(TJSonStreamClientCoder.Create, True);

  FRDBOperator := TRDBOperator.Create;
  FRDBOperator.Connection := FConnection;

  FTesterCode := CreateClassID;
end;

destructor TTester.Destroy;
begin
  FRDBOperator.Free;
  FConnection.Free;
  inherited Destroy;
end;

{ TTester }

procedure TTester.Execute;
var
  lvCds:TClientDataSet;
begin
  InterlockedIncrement(__TesterCount);
  lvCds := TClientDataSet.Create(nil);
  try
    FConnection.open;
    while (not self.Terminated) and (not __stop) do
    begin
      Sleep(1000);
//      try
//        FRDBOperator.clear;
//        FRDBOperator.RScript.S['sql'] := FSQL;
//        FRDBOperator.QueryCDS(lvCds);
//
//
//      except
//        on E:Exception do
//        begin
//          TFileLogger.instance.logErrMessage(FTesterCode + E.Message);
//        end;
//      end;

    end;
    TFileLogger.instance.logDebugMessage(FTesterCode + '线程已经停止[' + TesterCode + ']');
    FConnection.close;
  finally
    InterlockedDecrement(__TesterCount);
    lvCds.Free;
  end;
end;

initialization
  __TesterCount := 0;

end.
