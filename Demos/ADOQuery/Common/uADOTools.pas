unit uADOTools;

interface

uses
  ADODB, DB, classes, SysUtils, AdoInt, Variants;

type
  TADOTools = class(TObject)
  public
    class function saveToStream(pvDataSet:TCustomADODataSet):TMemoryStream;
    class procedure loadFromStream(pvDataSet:TCustomADODataSet; pvStream:TMemoryStream);
  end;

implementation

{ TADOTools }

class procedure TADOTools.loadFromStream(pvDataSet: TCustomADODataSet;
  pvStream: TMemoryStream);
var
   V:OLEVariant;
   AR:_Recordset;
   AStream:_Stream;
   P:Pointer;
begin
   V:=VarArrayCreate([0,pvStream.Size-1], varByte);
   P:=VarArrayLock(V);
   try
     Move(pvStream.Memory^,P^, pvStream.Size);
   finally
     VarArrayUnLock(V);
   end;

   AStream:=CoStream.Create;
   AStream.Open(EmptyParam,adModeUnknown,adOpenStreamUnspecified,'','');
   AStream.Type_:=adTypeBinary;
   AStream.Write(V);

   AR:=_Recordset(CoRecordset.Create);
   AStream.Position:=0;
   AR.Open(AStream,EmptyParam,adOpenUnspecified, adLockUnspecified, -1);
   pvDataSet.Recordset:=ADOInt._Recordset(AR);
end;

class function TADOTools.saveToStream(pvDataSet: TCustomADODataSet):TMemoryStream;
var
   AStream:_Stream;
   V:OLEVariant;
   P:Pointer;
begin
   AStream:=CoStream.Create;
   OLEVariant(pvDataSet.Recordset).Save(AStream,adPersistADTG);
   AStream.Position:=0;
   V:=AStream.Read(AStream.Size);
   result:=TMemoryStream.Create;
   try
     P:=VarArrayLock(V);
     try
       result.Size:=VarArrayHighBound(V,1)+1;
       Move(P^,result.Memory^, result.Size);
     finally
       VarArrayUnLock(V);
     end;
   except
     result.Free();
     result := nil;
     raise;
   end;
end;

end.
