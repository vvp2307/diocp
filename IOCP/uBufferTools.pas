unit uBufferTools;

interface

uses
  uBuffer, Classes, Windows;

type
  TBufferTools = class(TObject)
  public
    /// <summary>
    ///  Œ¥Ω¯––≤‚ ‘
    /// </summary>
    class procedure inBufferSave2File(pvInBuffer:TBufferLink; pvFile:string);
  end;

implementation

{ TBufferTools }

class procedure TBufferTools.inBufferSave2File(pvInBuffer: TBufferLink;
  pvFile: string);
var
  lvFileStream:TFileStream;
  lvBuffer:array[1..1024] of Byte;
  lvCount:Cardinal;
begin
  lvFileStream := TFileStream.Create(pvFile, fmCreate);
  try
    lvFileStream.Position := 0;
    lvFileStream.Size := 0;
    while not pvInBuffer.validCount > 0 do
    begin
      lvCount := pvInBuffer.readBuffer(@lvBuffer[1], SizeOf(lvBuffer));
      if lvCount = 0 then
      begin
        break;
      end;

      lvFileStream.Write(lvBuffer, lvCount);
    end; 

  finally
    lvFileStream.Free;
  end;

end;

end.
