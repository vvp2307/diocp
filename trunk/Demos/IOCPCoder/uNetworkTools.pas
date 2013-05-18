unit uNetworkTools;

interface

uses
  JwaWinsock2, IdGlobal;



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

  TBytes = array of Byte;

  TNetworkTools = class(TObject)
  public
    class function htonl(v: LongWord): LongWord; overload;

    class function htonl(v:Int64): Int64; overload;

    class function ntohl(v: LongWord): LongWord;overload;

    class function htonl(v: Integer): Integer; overload;

    class function ntohl(v: Integer): Integer; overload;

    class function ansiString2UnicodeBytes(v:string): TBytes;
    class function ansiString2Utf8Bytes(v:string): TBytes;
  end;

implementation

class function TNetworkTools.ansiString2UnicodeBytes(v:string): TBytes;
var
  Wide_Str: WideString;
  WideChar_Byte_Array: Array of Byte;
  lvPointer : Pointer;
begin
  Result := TBytes(ToBytes(v, TIdTextEncoding.Unicode));
//
//  //转为Unicode
//  Wide_Str := v;
//
//
//
//  //字节数 = Unicode字数 * Unicode单字的字节数
//  SetLength(Result, Length(Wide_Str) * sizeof(WideChar));
//
//  //复制到字节数组当中
//  Move(PAnsiChar(Wide_Str)^, Result[0], Length(Wide_Str) * sizeof(WideChar));
end;

class function TNetworkTools.ansiString2Utf8Bytes(v:string): TBytes;
begin
  Result := TBytes(ToBytes(v, TIdTextEncoding.UTF8));
end;

class function TNetworkTools.htonl(v:Int64): Int64;
var
  LParts: TInt64Parts;
  L: LongWord;
begin
  LParts.QuadPart := v;
  L := JwaWinsock2.htonl(LParts.HighPart);
  LParts.HighPart := JwaWinsock2.htonl(LParts.LowPart);
  LParts.LowPart := L;
  Result := LParts.QuadPart;
end;

class function TNetworkTools.htonl(v: LongWord): LongWord;
begin
  Result := JwaWinsock2.htonl(v);
end;

class function TNetworkTools.htonl(v: Integer): Integer;
begin
  Result := Integer(htonl(LongWord(v)));
end;

class function TNetworkTools.ntohl(v: LongWord): LongWord;
begin
  Result := JwaWinsock2.ntohl(v);
end;

class function TNetworkTools.ntohl(v: Integer): Integer;
begin
  Result := Integer(ntohl(LongWord(v)));
end;

end.
