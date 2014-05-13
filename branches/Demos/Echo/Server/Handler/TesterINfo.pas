unit TesterINfo;

interface

var
  __ClientContextCount:Integer;
  __SendTimes:Integer;
  __RecvTimes:Integer;


procedure initializeTestINfo;

implementation

procedure initializeTestINfo;
begin
  __ClientContextCount := 0;
  __SendTimes := 0;
  __RecvTimes := 0;
end;

end.
