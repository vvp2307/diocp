unit CDSOperatorWrapper;


///2013年5月27日 15:41:59
///  添加CDSGetErrorCode,CDSGetErrorDesc函数

///2013年5月27日 15:41:39
///  修正XE下不能加载的bug
///



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
    class function CDSGetErrorCode: Integer;
    class function CDSGetErrorDesc: AnsiString;
  end;

implementation

var
  __Handle:THandle=0;

  __passString:AnsiString;



class function TCDSOperatorWrapper.CDSGetErrorCode: Integer;
var
  lvInvoke:function():Integer; stdcall;
begin
  checkInitialize;
  @lvInvoke := nil;
  @lvInvoke := GetProcAddress(__Handle, 'CDSGetErrorCode');
  if @lvInvoke = nil then
  begin
    raise Exception.Create('找不到对应的CDSGetErrorCode函数,非法的CDSOperator动态库文件');
  end;
  Result := lvInvoke();
end;

class function TCDSOperatorWrapper.CDSGetErrorDesc: AnsiString;
var
  lvInvoke:function():PAnsiChar; stdcall;
begin
  checkInitialize;
  @lvInvoke := nil;
  @lvInvoke := GetProcAddress(__Handle, 'CDSGetErrorDesc');
  if @lvInvoke = nil then
  begin
    raise Exception.Create('找不到对应的CDSGetErrorDesc函数,非法的CDSOperator动态库文件');
  end;
  __passString := lvInvoke();
  Result := __passString;
end;

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
  lvPath:String;
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
