unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, JSonStream;

type
  TForm1 = class(TForm)
    btnTester: TButton;
    procedure btnTesterClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  uJSonStreamTools;

{$R *.dfm}

procedure TForm1.btnTesterClick(Sender: TObject);
var
  lvJStream1, lvJStream2:TJsonStream;
  lvstream:TMemoryStream;
  s:AnsiString;
begin
  lvJStream1 := TJsonStream.Create;
  lvJStream2 := TJsonStream.Create;
  lvstream := TMemoryStream.Create;
  try
    lvJStream1.Json.S['key'] := '{47733CEA-57A3-46EB-85D8-B63C54C2489B}';
    lvJStream1.Json.s['caption'] := 'ddd,中国人';
    s := 'abccdd中国';
    lvJStream1.Stream.WriteBuffer(s[1], Length(s));

    TJSonStreamTools.pack2Stream(lvJStream1, lvstream);

    lvstream.Position := 0;
    TJSonStreamTools.unPackFromStream(lvJStream2, lvstream);

    if TJSonStreamTools.crcObject(lvJStream1) <> TJSonStreamTools.crcObject(lvJStream2) then
    begin
      raise Exception.Create('有误!');
    end else
    begin
      ShowMessage(lvJStream2.Json.AsJSon(true, False));
    end;


  finally
    lvJStream1.Free;
    lvJStream2.Free;
    lvstream.Free;
  end;

end;

end.
