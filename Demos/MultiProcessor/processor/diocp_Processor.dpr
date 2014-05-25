program diocp_Processor;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  Classes,
  zmq in 'zmq\zmq.pas',
  zmqapi in 'zmq\zmqapi.pas';


procedure dowork(data:TStream);
begin


end;

procedure dolisten;
var
  lvZMQContext:TZMQContext;
  lvSocket:TZMQSocket;
  lvStream:TMemoryStream;
  lvMsg:UTF8String;
  l:Integer;
begin

//  context := TZMQContext.create;
//  server := context.socket( stRep );
//  server.bind( 'tcp://*:5555' );

  lvZMQContext := TZMQContext.create;
  lvSocket := lvZMQContext.Socket(stRep);
  lvSocket.bind('tcp://*:5555');

  lvStream := TMemoryStream.Create;
  try
    while not lvZMQContext.Terminated do
    begin
      try
        lvStream.Clear;
        l := lvSocket.recv(lvMsg);
        if l > 0 then
        begin
          Writeln(lvMsg);
          lvSocket.send(lvMsg);
          //dowork(lvStream);
        end;
      except
        on E: Exception do
          Writeln(E.ClassName, ': ', E.Message);
      end;
    end;
    lvZMQContext.Free;
  finally
    lvStream.Free;
  end;
end;

begin
  try
    dolisten;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
