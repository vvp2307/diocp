unit CDSOperatorWrapper;


//// 添加 checkRaiseLastError 函数
///
///
//// 去掉CDSGetErrorCode,CDSGetErrorDesc函数
///  杨茂丰 - 2014年2月14日 10:32:22
///


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

    class procedure checkRaiseLastError(const pvCDSInterface:IInterface);


  end;

implementation

var
  __Handle:THandle=0;
  __CDSDecodeProc:function():ICDSDecode;stdcall;
  __CDSEncodeProc:function():ICDSEncode;stdcall;

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

    @__CDSDecodeProc := GetProcAddress(__Handle, 'createCDSDecode');
    if @__CDSDecodeProc = nil then
    begin
      raise Exception.Create('找不到对应的createCDSDecode函数,非法的CDSOperator动态库文件');
    end;


    @__CDSEncodeProc := GetProcAddress(__Handle, 'createCDSEncode');
    if @__CDSEncodeProc = nil then
    begin
      raise Exception.Create('找不到对应的createCDSEncode函数,非法的CDSOperator动态库文件');
    end;

  end;
end;

class procedure TCDSOperatorWrapper.checkRaiseLastError(const pvCDSInterface: IInterface);
var
  lvErrorGetter:IGetLastError;
  lvErrorCode:Integer;
begin
  if pvCDSInterface.QueryInterface(IGetLastError, lvErrorGetter) = S_OK then
  begin
    lvErrorCode := lvErrorGetter.getLastErrorCode;
    if lvErrorCode <> 0 then
    begin
      if lvErrorCode <> -1 then
      begin
        raise Exception.Create('(' + inttoStr(lvErrorCode) + ')' + lvErrorGetter.getLastErrDesc);
      end else
      begin
        raise Exception.Create('CDSOperator异常:' + lvErrorGetter.getLastErrDesc);
      end;
    end;
  end;
  
end;

class function TCDSOperatorWrapper.createCDSDecode: ICDSDecode;
begin
  checkInitialize;
  Result := __CDSDecodeProc();
  if Result = nil then raise exception.Create('创建CDSDecode接口失败!');
end;

class function TCDSOperatorWrapper.createCDSEncode: ICDSEncode;
var
  lvInvoke:function():ICDSEncode; stdcall;
begin
  checkInitialize;
  Result := __CDSEncodeProc();
  if Result = nil then raise exception.Create('创建CDSEncode接口失败!');
  
end;

initialization
  @__CDSDecodeProc := nil;
  @__CDSEncodeProc := nil;

finalization
  TCDSOperatorWrapper.checkFinalization;


end.
