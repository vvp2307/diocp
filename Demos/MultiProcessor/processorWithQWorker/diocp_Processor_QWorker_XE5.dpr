program diocp_Processor_QWorker_XE5;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  Classes,
  zmq in 'zmq\zmq.pas',
  zmqapi in 'zmq\zmqapi.pas',
  JSonStream in '..\..\Common\JSonStream.pas',
  uJSonStreamTools in '..\..\Common\uJSonStreamTools.pas',
  superobject in '..\..\Common\superobject.pas',
  uCRCTools in '..\..\Common\uCRCTools.pas',
  uNetworkTools in '..\..\IOCPCoder\uNetworkTools.pas',
  uMyTypes in '..\..\..\Source\IOCP\uMyTypes.pas',
  qrbtree in 'QWorkers\qrbtree.pas',
  qstring in 'QWorkers\qstring.pas',
  qworker in 'QWorkers\qworker.pas',
  qxml in 'QWorkers\qxml.pas',
  DIOCPProcessor in 'DIOCPProcessor.pas';


var
  lvProcessor:TDIOCPProcessor;
begin
  lvProcessor := TDIOCPProcessor.Create;
  try
    try
      lvProcessor.start;
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  finally
    lvProcessor.Free;
  end;
end.
