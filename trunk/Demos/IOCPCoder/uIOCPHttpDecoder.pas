unit uIOCPHttpDecoder;

interface

uses
  uIOCPCentre, uBuffer, Classes, uIOCPFileLogger, SysUtils;

type
  TIOCPHttpDecoder = class(TIOCPDecoder)
  protected
    /// <summary>
    ///   解码收到的数据,如果有接收到数据,调用该方法,进行解码
    /// </summary>
    /// <returns>
    ///   返回解码好的对象
    /// </returns>
    /// <param name="inBuf"> 接收到的流数据 </param>
    function Decode(const inBuf: TBufferLink): TObject; override;
  end;


implementation

uses
  Windows, uNetworkTools, superobject, uZipTools, FileLogger;

function TIOCPHttpDecoder.Decode(const inBuf: TBufferLink): TObject;
var
  lvData:AnsiString;
  lvBytes:TBytes;
  lvValidCount:Integer;
  l, j, r:Integer;
begin
  Result := nil;

  //如果缓存中的数据长度不够包头长度，解码失败<json字符串长度,流长度>
  lvValidCount := inBuf.validCount;
  if (lvValidCount < 4) then   //#13#10#13#10
  begin
    Exit;
  end;

  
  //记录读取位置
  inBuf.markReaderIndex;


//  l := inBuf.readBuffer(@lvData[1], lvValidCount);
//
//  if lvData <> '' then
//  begin
//    if StrPos(lvData, #13#10#13#10) <> nil then
//    begin
//       Result := TStringList.Create;
//       TStrings(Result).Add(lvData);
//    end else
//    begin
//
//    end;
//  end;

  SetLength(lvBytes, 1);
  SetLength(lvData, lvValidCount);
  j := 0;
  r := 1;
  while True do
  begin
    l := inBuf.readBuffer(@lvBytes[0], 1);
    if l = 0 then
    begin
      Exit;
    end;
    Inc(j);
    lvData[j] := AnsiChar(lvBytes[0]);
    case lvBytes[0] of
      13:
        begin
          if r in [1,3] then
          begin
            Inc(r);
          end;
        end;
      10:
        begin
          if r in [2] then inc(r)
          else if r = 4 then
          begin
            Result := TStringList.Create;
            SetLength(lvData, j);
            TStrings(Result).Add(lvData);
            Break;
          end;
        end;
      else
        r:=1;
    end;
  end;

  if Result = nil then
  begin
     inBuf.restoreReaderIndex;
  end;
end;

end.
