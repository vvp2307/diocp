unit uIOCPHttpEncoder;

interface

uses
  uIOCPCentre, uBuffer, JSonStream, Classes, uNetworkTools, uZipTools, SysUtils;

type
  TIOCPHttpEncoder = class(TIOCPEncoder)
  public
    /// <summary>
    ///   编码要发生的对象
    /// </summary>
    /// <param name="pvDataObject"> 要进行编码的对象 </param>
    /// <param name="ouBuf"> 编码好的数据 </param>
    procedure Encode(pvDataObject:TObject; const ouBuf: TBufferLink); override;
  end;

implementation

procedure TIOCPHttpEncoder.Encode(pvDataObject:TObject; const ouBuf:
    TBufferLink);
var
  sData, sHead:AnsiString;
begin
  if pvDataObject = nil then exit;
  
  sData := TStrings(pvDataObject).Text;

  sHead := 'HTTP/1.1 200 OK' + sLineBreak +
           'Content-Type: text/plain'  + sLineBreak +
           'Content-Length:' + IntToStr(Length(sData)) + sLineBreak + sLineBreak;

  ouBuf.AddBuffer(@sHead[1], Length(sHead));



  ouBuf.AddBuffer(@sData[1], Length(sData));
end;

end.
