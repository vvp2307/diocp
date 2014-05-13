unit uD10ClientSocket4Recv;

interface

uses
  uD10ClientSocket, Classes;

type
  TD10ClientSocket4Recv = class(TD10ClientSocket)
  public

  end;

  TD10RecvThread = class(TThread)
  public
    procedure Execute;override;
  end;

implementation

{ TD10RecvThread }

procedure TD10RecvThread.Execute;
begin
  inherited;

end;

end.
