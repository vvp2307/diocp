unit CDSOperatorWrapper;



interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uICDSOperator;

type
  TCDSOperatorWrapper = class(TObject)
  public
    class procedure checkInitialize;
    class procedure checkFinalization;
  public
    class function createCDSEncode: ICDSEncode;
    class function createCDSDecode: ICDSDecode;
  end;

implementation

var
  __Handle:THandle=0;



class procedure TCDSOperatorWrapper.checkFinalization;
begin
  if __Handle <> 0 then
  begin
    FreeLibrary(__Handle);
    __Handle := 0;
  end;
end;

class procedure TCDSOperatorWrapper.checkInitialize;
var
  lvPath:AnsiString;
begin
  if __Handle = 0 then
  begin
    lvPath := ExtractFilePath(ParamStr(0)) + 'Libs\CDSOperator.dll';
    __Handle := LoadLibrary(PChar(lvPath));
    if __Handle = 0 then
    begin
      raise Exception.Create('加载CDSOperator出错,是否已经损坏?');
    end;
    lvPath := '';
  end;
end;

class function TCDSOperatorWrapper.createCDSDecode: ICDSDecode;
var
  lvInvoke:function():ICDSDecode; stdcall;
begin
  checkInitialize;
  @lvInvoke := nil;
  @lvInvoke := GetProcAddress(__Handle, 'createCDSDecode');
  if @lvInvoke = nil then
  begin
    raise Exception.Create('找不到对应的createCDSDecode函数,非法的CDSOperator动态库文件');
  end;
  Result := lvInvoke();
end;

class function TCDSOperatorWrapper.createCDSEncode: ICDSEncode;
var
  lvInvoke:function():ICDSEncode; stdcall;
begin
  checkInitialize;
  @lvInvoke := nil;
  @lvInvoke := GetProcAddress(__Handle, 'createCDSEncode');
  if @lvInvoke = nil then
  begin
    raise Exception.Create('找不到对应的createCDSEncode函数,非法的CDSOperator动态库文件');
  end;
  Result := lvInvoke();
end;

initialization

finalization
  TCDSOperatorWrapper.checkFinalization;


end.
