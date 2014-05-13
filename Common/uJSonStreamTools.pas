unit uJSonStreamTools;

interface

uses
  JSonStream, uCRCTools, SysUtils, Classes;

type
  TJSonStreamTools = class(TObject)
  public
    class function crcObject(pvObject: TJSonStream): Cardinal;
  end;

implementation


class function TJSonStreamTools.crcObject(pvObject: TJSonStream): Cardinal;
var
  lvPack:TStream;
  lvStream:TStream;
  lvTempBuf:PAnsiChar;
  lvBufBytes:array[0..1023] of byte;
  sData:string;
  l:Integer;
begin
  lvPack := TMemoryStream.Create;
  try
    sData := '';
    if pvObject.JSon <> nil then
    begin
      sData := pvObject.JSon.AsJSon(True);
      lvPack.WriteBuffer(sData[1], Length(sData));
    end;

    lvStream := pvObject.Stream;
    if lvStream <> nil then
    begin
      lvStream.Position := 0;
      lvPack.CopyFrom(lvStream, lvStream.Size);
    end;

    lvPack.Position := 0;
    Result := TCRCTools.crc32Stream(lvPack);
  finally
    lvPack.Free;
  end;


end;

end.
