unit uIErrorGetter;

//// 2014年2月14日 08:27:23
///    添加ErrorGetter接口

interface  

type
  IErrorGetter = interface(IInterface)
    ['{FC7D500F-4C5F-4862-AC47-F62D2C66FAA8}']
    function getLastErrorCode: Integer; stdcall;
    function getLastErrorDesc: PAnsiChar; stdcall;
  end;

implementation

end.
