unit uUniConnectionPoolGroup;

interface

uses
  uUniConnectionPool, Classes, SysUtils;

type
  TUniConnectionPoolGroup = class(TObject)
  private
    FList: TList;
    procedure FreeAll();
  public
    procedure clear;
    constructor Create;
    destructor Destroy; override;
    procedure Add(pvKey: string; pvPool: TUniConnectionPool);
    function getPool(pvKey:string): TUniConnectionPool;
    procedure waitForGiveBack;
    function getPoolINfo():String;
  end;

implementation

type
  PPoolItem = ^__PoolItem;
  
  __PoolItem = packed record
    key:string[80];
    obj:TUniConnectionPool;
  end;


procedure TUniConnectionPoolGroup.clear;
begin
  FreeAll;
end;

constructor TUniConnectionPoolGroup.Create;
begin
  inherited Create;
  FList := TList.Create();
end;

destructor TUniConnectionPoolGroup.Destroy;
begin
  FreeAll;
  FList.Free;
  inherited Destroy;
end;

procedure TUniConnectionPoolGroup.Add(pvKey: string; pvPool:
    TUniConnectionPool);
var
  lvItem:PPoolItem;
begin
  if Length(pvKey) = 0 then raise Exception.Create('需要给ADOConnectionPool进行命名！');
  if Length(pvKey) > 80 then raise Exception.Create('ADOConnectionPool命名长度不能超过50！');

  if getPool(pvKey) <> nil then
  begin
    raise Exception.Create('已经存在[' + pvKey + ']的ADOConnectionPool！');
  end;

  GetMem(lvItem, SizeOf(__PoolItem));
  lvItem.key := pvKey;
  lvItem.obj := pvPool;
  FList.Add(lvItem); 
end;

procedure TUniConnectionPoolGroup.FreeAll;
var
  i:Integer;
  lvItem:PPoolItem;
begin
  while FList.Count > 0 do
  begin
    i:=FList.Count -1;

    lvItem := PPoolItem(FList[i]);
    lvItem.obj.waitForReleaseSingle;
    lvItem.obj.Free;
    FreeMem(lvItem, SizeOf(__PoolItem));
    FList.Delete(i);
  end;
end;

function TUniConnectionPoolGroup.getPool(pvKey:string): TUniConnectionPool;
var
  i:Integer;
  lvItem:PPoolItem;
begin
  Result := nil;
  for I := 0 to FList.Count - 1 do
  begin
    lvItem := PPoolItem(FList[i]);
    if SameText(lvItem.key, pvKey) then
    begin
      Result := lvItem.obj;
      break;
    end;
  end;
end;

function TUniConnectionPoolGroup.getPoolINfo: String;
var
  i:Integer;
  lvItem:PPoolItem;
begin
  Result := '';
  for I := 0 to FList.Count - 1 do
  begin
    lvItem := PPoolItem(FList[i]);
    Result := Result +
      Format('%s(总数:%d,使用:%d)',
        [lvItem.key, lvItem.obj.Count,
        lvItem.obj.getBusyCount]) + sLineBreak;
  end;
end;

procedure TUniConnectionPoolGroup.waitForGiveBack;
var
  i:Integer;
  lvItem:PPoolItem;
begin
  for I := 0 to FList.Count - 1 do
  begin
    lvItem := PPoolItem(FList[i]);
    lvItem.obj.waitForReleaseSingle;
  end;
end;

end.
