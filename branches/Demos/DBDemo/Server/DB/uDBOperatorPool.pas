unit uDBOperatorPool;

interface

uses
  uMyObjectPool, uADOOperator;

type
  TDBOperatorPool = class(TMyObjectPool)
  protected
    function createObject: TObject; override;
  end;

implementation

function TDBOperatorPool.createObject: TObject;
begin
  Result := TADOOperator.Create;
end;

end.
