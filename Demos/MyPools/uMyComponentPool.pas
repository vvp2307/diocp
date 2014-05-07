unit uMyComponentPool;

interface

uses
  uMyObjectPool, Classes, SysUtils;

type
  TMyComponentPool = class(TMyObjectPool)
  private
    FComponentClass:TComponentClass;
  protected
    /// <summary>
    ///  创建一个对象
    /// </summary>
    function createObject: TObject; override;
  public
    constructor Create(pvComponentClass: TComponentClass);
  end;

implementation

constructor TMyComponentPool.Create(pvComponentClass: TComponentClass);
begin
  inherited Create();
  FComponentClass := pvComponentClass;
end;

function TMyComponentPool.createObject: TObject;
begin
  if FComponentClass = nil then
  begin
    raise MyPoolException.Create('没有设置组件类,创建池对象失败!');
  end;
  Result := FComponentClass.Create(nil);
end;

end.
