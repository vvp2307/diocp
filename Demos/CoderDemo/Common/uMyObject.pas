unit uMyObject;

interface

type
  TMyObject = class(TObject)
  private
    FDataString:String;
    FOle:Variant;
  public
    property DataString:String read FDataString write FDataString;
    property Ole:Variant read FOle write FOle;
  end;

implementation

end.
