unit OTLObjectQueue;

interface


uses
  GpLockFreeQueue;

type
  TOtlObjectQueue = class(TGpLockFreeQueue)
  public
    procedure Push(const pvObject: TObject);

    function Pop: TObject;
  end;

implementation

function TOtlObjectQueue.Pop: TObject;
var
  v:Int64;
begin
  if Dequeue(v) then
  begin
    Result := TObject(v);
  end else
  begin
    Result := nil;
  end;
end;

{ TOtlObjectQueue }

procedure TOtlObjectQueue.Push(const pvObject: TObject);
var
  v:Int64;
begin
  if pvObject = nil then exit;
  v := Int64(pvObject);
  self.Enqueue(v);
end;

end.
