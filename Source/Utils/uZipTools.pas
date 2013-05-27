unit uZipTools;

///2013ƒÍ5‘¬27»’ 09:35:03
///  º”»Î∂‘¡˜µƒ—πÀı∫Ø ˝

interface

uses
  ZLib, Windows, Types, Classes, SysUtils;

type
  TZipTools = class(TObject)
  public
    //—πÀı◊÷∑˚¥Æ(”ÎJAVAºÊ»›)
    class function compressStr(pvData: string): TByteDynArray;

    //Ω‚—π◊÷∑˚¥Æ(”ÎJAVAºÊ»›)
    class function unCompressStr(pvData: TByteDynArray; pvDataSize: Integer = 0):
        string;

    //—πÀı(”ÎJAVAºÊ»›)
    class procedure compressStreamEX(const pvStream:TStream);

    //Ω‚—π(”ÎJAVAºÊ»›)
    class procedure unCompressStreamEX(const pvStream:TStream);

    //—πÀı(”ÎJAVAºÊ»›)
    class function compressStream(const pvStream, pvZipStream:TStream): Boolean;

    //Ω‚—π(”ÎJAVAºÊ»›)
    class function unCompressStream(const pvZipStream, pvStream:TStream): Boolean;


    //—πÀı(”ÎJAVAºÊ»›)
    class function compressBuf(const Buffer; Count: Longint): TByteDynArray;

    //Ω‚—π(”ÎJAVAºÊ»›)
    class function unCompressBuf(const zipBuffer; Count: Longint): TByteDynArray;
  end;

implementation

class function TZipTools.compressBuf(const Buffer; Count: Longint):
    TByteDynArray;
var
  lvTmp: string;
  lvBytes: TByteDynArray;
  OutBuf: Pointer;
  OutBytes: Integer;
begin
  ZLib.CompressBuf(@Buffer, Count, OutBuf, OutBytes);
  try
    SetLength(lvBytes, OutBytes);
    CopyMemory(@lvBytes[0], OutBuf, OutBytes);
  finally
    FreeMem(OutBuf, OutBytes);
  end;
  Result:=lvBytes;
end;

class function TZipTools.unCompressBuf(const zipBuffer; Count: Longint):
    TByteDynArray;
var
  lvSize:Cardinal;
  OutBuf: Pointer;
  OutBytes: Integer;
  s:string;
begin
  lvSize := Count;
  Zlib.DecompressBuf(@zipBuffer, lvSize, 0, OutBuf, OutBytes);
  try
    SetLength(Result, OutBytes);
    CopyMemory(@Result[0], OutBuf, OutBytes);
  finally
    FreeMem(OutBuf, OutBytes);
  end;
end;

class function TZipTools.compressStr(pvData: string): TByteDynArray;
var
  lvTmp: string;
  lvBytes: TByteDynArray;
  OutBuf: Pointer;
  OutBytes: Integer;
  l: Integer;
begin
  lvTmp := pvData;
  l := Length(lvTmp);
  ZLib.CompressBuf(PAnsiChar(lvTmp), l, OutBuf, OutBytes);
  try
    SetLength(lvBytes, OutBytes);
    CopyMemory(@lvBytes[0], OutBuf, OutBytes);
  finally
    FreeMem(OutBuf, OutBytes);
  end;
  Result:=lvBytes;
end;

class procedure TZipTools.compressStreamEX(const pvStream:TStream);
begin
  compressStream(pvStream, pvStream);
end;


class function TZipTools.compressStream(const pvStream, pvZipStream:TStream):
    Boolean;
var
  lvTmp: string;
  lvBytes: TBytes;
  OutBuf: Pointer;
  OutBytes, l: Integer;
begin
  Result := False;
  if pvStream= nil then exit;

  l := pvStream.Size;

  if l = 0 then Exit;

  setLength(lvBytes, l);
  pvStream.Position := 0;
  pvStream.ReadBuffer(lvBytes[0], l);

  ZLib.CompressBuf(@lvBytes[0], l, OutBuf, OutBytes);
  try
    pvZipStream.Size := OutBytes;
    pvZipStream.Position := 0;
    pvZipStream.WriteBuffer(OutBuf^, OutBytes);
    Result := true;
  finally
    FreeMem(OutBuf, OutBytes);
  end;
end;

class procedure TZipTools.unCompressStreamEX(const pvStream:TStream);
begin
  unCompressStream(pvStream, pvStream)
end;



class function TZipTools.unCompressStream(const pvZipStream, pvStream:TStream):
    Boolean;
var
  l:Integer;
  lvBytes: TBytes;
  OutBuf: Pointer;
  OutBytes: Integer;
  s:string;
begin
  Result := false;
  if pvZipStream= nil then exit;
  l := pvZipStream.Size;
  if l = 0 then Exit;

  setLength(lvBytes, l);
  pvZipStream.Position := 0;
  pvZipStream.ReadBuffer(lvBytes[0], l);

  Zlib.DecompressBuf(@lvBytes[0], l, 0, OutBuf, OutBytes);
  try
    pvStream.Size := OutBytes;
    pvStream.Position := 0;
    pvStream.WriteBuffer(OutBuf^, OutBytes);
    Result := true;
  finally
    FreeMem(OutBuf, OutBytes);
  end;
end;

class function TZipTools.unCompressStr(pvData: TByteDynArray; pvDataSize:
    Integer = 0): string;
var
  lvSize:Cardinal;
  OutBuf: Pointer;
  OutBytes: Integer;
  s:string;
begin
  lvSize := pvDataSize;
  if lvSize = 0 then lvSize := Length(pvData);
  Zlib.DecompressBuf(@pvData[0], lvSize, 0, OutBuf, OutBytes);
  try
    SetLength(s, OutBytes + 1);
    ZeroMemory(@s[1], OutBytes);
    CopyMemory(@s[1], OutBuf, OutBytes);
    S[OutBytes + 1] := #0;
  finally
    FreeMem(OutBuf, OutBytes);
  end;     
  Result := s;
end;


end.
