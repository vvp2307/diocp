unit uMemoLogger;

interface

uses
  Classes, SysUtils;

type
  TMemoLogger = class(TObject)
  private
    FDatas: TStrings;
  public
    constructor Create(ADatas: TStrings);

    procedure info(pvMsg:String);
    class procedure infoMsg(pvMsg: String; pvLines: TStrings);

    
  end;

implementation

constructor TMemoLogger.Create(ADatas: TStrings);
begin
  inherited Create;
  FDatas := ADatas;
end;

procedure TMemoLogger.info(pvMsg:String);
begin
  infoMsg(pvMsg, FDatas);
end;

class procedure TMemoLogger.infoMsg(pvMsg: String; pvLines: TStrings);
begin
  pvLines.Insert(0, FormatDateTime('hh:nn:ss', Now()) + ':' + pvMsg);
end;

end.
