unit uNetworkTools;
///
///  2013年5月29日 17:20:35
///     添加Utf8AnsiString2AnsiString(pvData:AnsiString)函数

interface


uses
  windows, WinSock, SysUtils;

type
  //from indy
  TInt64Parts = packed record
    case Integer of
    0: (
       {$IFDEF ENDIAN_BIG}
      HighPart: LongWord;
      LowPart: LongWord);
       {$ELSE}
      LowPart: LongWord;
      HighPart: LongWord);
      {$ENDIF}
    1: (
      QuadPart: Int64);
  end;

  TNetworkTools = class(TObject)
  public
    class function htonl(v: LongWord): LongWord; overload;

    class function htonl(v:Int64): Int64; overload;

    class function ntohl(v: LongWord): LongWord;overload;

    class function htonl(v: Integer): Integer; overload;

    class function ntohl(v: Integer): Integer; overload;

    class function ansiString2Utf8Bytes(v:AnsiString): TBytes;

    class function Utf8Bytes2AnsiString(pvData:TBytes): AnsiString;

    class function Utf8AnsiString2AnsiString(pvData:AnsiString): AnsiString;
  end;

implementation


class function TNetworkTools.ansiString2Utf8Bytes(v:AnsiString): TBytes;
var
  lvTemp:AnsiString;
begin
  lvTemp := AnsiToUtf8(v);
  SetLength(Result, Length(lvTemp));
  Move(lvTemp[1], Result[0],  Length(lvTemp));
end;

class function TNetworkTools.Utf8Bytes2AnsiString(pvData:TBytes): AnsiString;
var
  lvTemp:AnsiString;
begin
  SetLength(lvTemp, Length(pvData));
  Move(pvData[0], lvTemp[1],  Length(pvData));
  Result := Utf8ToAnsi(lvTemp);
end;

class function TNetworkTools.Utf8AnsiString2AnsiString(pvData:AnsiString): AnsiString;
begin
  Result := Utf8ToAnsi(pvData);
end;

class function TNetworkTools.htonl(v:Int64): Int64;
var
  LParts: TInt64Parts;
  L: LongWord;
begin
  LParts.QuadPart := v;
  L := WinSock.htonl(LParts.HighPart);
  LParts.HighPart := htonl(LParts.LowPart);
  LParts.LowPart := L;
  Result := LParts.QuadPart;
end;

class function TNetworkTools.htonl(v: LongWord): LongWord;
begin
  Result := WinSock.htonl(v);
end;

class function TNetworkTools.htonl(v: Integer): Integer;
begin
  Result := Integer(htonl(LongWord(v)));
end;

class function TNetworkTools.ntohl(v: LongWord): LongWord;
begin
  Result := WinSock.ntohl(v);
end;

class function TNetworkTools.ntohl(v: Integer): Integer;
begin
  Result := Integer(ntohl(LongWord(v)));
end;



end.
