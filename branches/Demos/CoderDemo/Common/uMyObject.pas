unit uMyObject;

interface

type
  TMyObject = class(TObject)
  private
    FDataString:String;
    FOle:OleVariant;
  public
    property DataString:String read FDataString write FDataString;
    property Ole:OleVariant read FOle write FOle;
  end;

implementation

end.
