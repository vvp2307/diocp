unit TesterINfo;

interface

uses
  Classes, SysUtils,DateUtils;


var
  __ClientContextCount:Integer;
  __SendTimes:Integer;
  __RecvTimes:Integer;
  __startTime:TDateTime;


procedure initializeTestINfo;
function calcRunINfo: String;

implementation

uses
  Windows;

procedure initializeTestINfo;
begin
  __ClientContextCount := 0;
  __SendTimes := 0;
  __RecvTimes := 0;
end;

function calcRunINfo: String;
var
  lvMSec, lvRemain:Int64;
  lvDay, lvHour, lvMin, lvSec:Integer;
begin
  lvMSec := MilliSecondsBetween(Now(), __startTime);
  lvDay := Trunc(lvMSec / MSecsPerDay);
  lvRemain := lvMSec mod MSecsPerDay;

  lvHour := Trunc(lvRemain / (MSecsPerSec * 60 * 60));
  lvRemain := lvRemain mod (MSecsPerSec * 60 * 60);

  lvMin := Trunc(lvRemain / (MSecsPerSec * 60));
  lvRemain := lvRemain mod (MSecsPerSec * 60);

  lvSec := Trunc(lvRemain / (MSecsPerSec));

  if lvDay > 0 then
    Result := Result + IntToStr(lvDay) + '天 ';

  if lvHour > 0 then
    Result := Result + IntToStr(lvHour) + '小时 ';

  if lvMin > 0 then
    Result := Result + IntToStr(lvMin) + '分钟 ';

  if lvSec > 0 then
    Result := Result + IntToStr(lvSec) + '秒 ';

end;

initialization
  __startTime :=  Now();

end.
