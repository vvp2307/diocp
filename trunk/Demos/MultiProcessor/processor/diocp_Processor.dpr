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
  lvSender:TZMQSocket;
  lvStream:TMemoryStream;
  lvMsg:UTF8String;
  l:Integer;
begin
  lvZMQContext := TZMQContext.create;
  lvSocket := lvZMQContext.Socket(stPull);
  lvSocket.connect( 'tcp://localhost:5557' );

  lvSender := lvZMQContext.Socket( stPush );
  lvSender.connect( 'tcp://localhost:5558' );

  lvStream := TMemoryStream.Create;
  try
    while not lvZMQContext.Terminated do
    begin
      try
        lvStream.Clear;
        lvSocket.recv(lvStream);

        lvStream.Position := 0;
        lvSender.send(lvStream, lvStream.Size);

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
