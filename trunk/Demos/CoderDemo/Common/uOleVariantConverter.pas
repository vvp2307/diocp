unit uOleVariantConverter;

interface

uses
  SysUtils, Classes, Windows, Variants, ActiveX, ComObj;

type
  PIntArray = ^TIntArray;
  TIntArray = array [0 .. 0] of Integer;

  TVarFlag = (vfByRef, vfVariant);
  TVarFlags = set of TVarFlag;

const
  EasyArrayTypes = [varSmallInt, varInteger, varSingle, varDouble, varCurrency,
    varDate, varBoolean, varByte];

  VariantSize: array [0 .. varByte] of Word = (0, 0, SizeOf(SmallInt),
    SizeOf(Integer), SizeOf(Single), SizeOf(Double), SizeOf(Currency),
    SizeOf(TDateTime), 0, 0, SizeOf(Integer), SizeOf(WordBool), 0, 0, 0, 0, 0,
    SizeOf(Byte));

resourcestring
  SBadVariantType = 'Unsupported variant type: %s';

procedure WriteOleVariant(const Value: OleVariant; Stream: TStream);

function ReadOleVariant(Stream: TStream): OleVariant;

implementation

procedure WriteOleVariant(const Value: OleVariant; Stream: TStream);

  procedure WriteArray(const Value: OleVariant; Stream: TStream);
  var
    LVarData: TVarData;
    VType: Integer;
    VSize, i, DimCount, ElemSize: Integer;
    LSafeArray: PSafeArray;
    LoDim, HiDim, Indices: PIntArray;
    V: OleVariant;
    P: Pointer;
{$IFDEF VER140}
    function FindVarData(const V: Variant): PVarData;
    begin
      Result := @TVarData(V);
      while Result.VType = varByRef or varVariant do
        Result := PVarData(Result.VPointer);
    end;
{$ENDIF}

  begin
    LVarData := FindVarData(Value)^;
    VType := LVarData.VType;
    LSafeArray := PSafeArray(LVarData.VPointer);

    Stream.Write(VType, SizeOf(Integer));
    // if FGetHeader then Inc(FHeaderSize, SizeOf(Integer));
    DimCount := VarArrayDimCount(Value);
    Stream.Write(DimCount, SizeOf(DimCount));
    // if FGetHeader then Inc(FHeaderSize, SizeOf(Integer));
    VSize := SizeOf(Integer) * DimCount;
    GetMem(LoDim, VSize);
    try
      GetMem(HiDim, VSize);
      try
        for i := 1 to DimCount do
        begin
          LoDim[i - 1] := VarArrayLowBound(Value, i);
          HiDim[i - 1] := VarArrayHighBound(Value, i);
        end;
        Stream.Write(LoDim^, VSize);
        Stream.Write(HiDim^, VSize);
        // if FGetHeader then Inc(FHeaderSize, SizeOf(Integer) * 2);
        if VType and varTypeMask in EasyArrayTypes then
        begin
          ElemSize := SafeArrayGetElemSize(LSafeArray);
          VSize := 1;
          for i := 0 to DimCount - 1 do
            VSize := (HiDim[i] - LoDim[i] + 1) * VSize;
          VSize := VSize * ElemSize;
          P := VarArrayLock(Value);
          try
            Stream.Write(VSize, SizeOf(VSize));
            // if FGetHeader then Inc(FHeaderSize, SizeOf(Integer));
            Stream.Write(P^, VSize);
          finally
            VarArrayUnlock(Value);
          end;
        end
        else
        begin
          // FGetHeader := False;
          GetMem(Indices, VSize);
          try
            for i := 0 to DimCount - 1 do
              Indices[i] := LoDim[i];
            while True do
            begin
              if VType and varTypeMask <> varVariant then
              begin
                OleCheck(SafeArrayGetElement(LSafeArray, Indices^,
                  TVarData(V).VPointer));
                TVarData(V).VType := VType and varTypeMask;
              end
              else
                OleCheck(SafeArrayGetElement(LSafeArray, Indices^, V));
              WriteOleVariant(V, Stream);
              Inc(Indices[DimCount - 1]);
              if Indices[DimCount - 1] > HiDim[DimCount - 1] then
                for i := DimCount - 1 downto 0 do
                  if Indices[i] > HiDim[i] then
                  begin
                    if i = 0 then
                      Exit;
                    Inc(Indices[i - 1]);
                    Indices[i] := LoDim[i];
                  end;
            end;
          finally
            FreeMem(Indices);
          end;
        end;
      finally
        FreeMem(HiDim);
      end;
    finally
      FreeMem(LoDim);
    end;
  end;

var
  i, VType: Integer;
  W: WideString;
  V: Currency;
  lvBytes:Array[1..255] of Byte;
begin
  VType := VarType(Value);
  if VType and varArray <> 0 then
    WriteArray(Value, Stream)
  else
    case (VType and varTypeMask) of
      varEmpty, varNull:
        Stream.Write(VType, SizeOf(Integer));
      varOleStr:
        begin
          W := WideString(Value);
          i := Length(W);
          Stream.Write(VType, SizeOf(Integer));
          Stream.Write(i, SizeOf(Integer));
          Stream.Write(W[1], i * 2);
          // if FGetHeader then Inc(FHeaderSize, SizeOf(Integer) * 2);
        end;
      varSmallint, varInteger, varInt64, varWord, varLongWord,
        varDate, varSingle, varDouble, varCurrency,
        varBoolean:
        begin
          Stream.Write(VType, SizeOf(Integer));

          ZeroMemory(@lvBytes[1], 255);

          windows.CopyMemory(@lvBytes[1], @TVarData(Value).VPointer, SizeOf(V));

          Stream.Write(lvBytes[1],
            VariantSize[VType and varTypeMask]);
        end;
      varDispatch:
        begin
          raise Exception.CreateResFmt(@SBadVariantType, [IntToHex(VType, 4)]);
        end;
      varVariant:
        begin
          if VType and varByRef <> varByRef then
            raise Exception.CreateResFmt(@SBadVariantType,
              [IntToHex(VType, 4)]);
          i := varByRef;
          Stream.Write(i, SizeOf(Integer));
          // if FGetHeader then Inc(FHeaderSize, SizeOf(Integer));
          WriteOleVariant(Variant(TVarData(Value).VPointer^), Stream);
        end;
      varUnknown:
        raise Exception.CreateResFmt(@SBadVariantType, [IntToHex(VType, 4)]);
    else
      Stream.Write(VType, SizeOf(Integer));
      // if FGetHeader then Inc(FHeaderSize, SizeOf(Integer));
      if VType and varByRef = varByRef then
        Stream.Write(TVarData(Value).VPointer^,
          VariantSize[VType and varTypeMask])
      else
        Stream.Write(TVarData(Value).VPointer,
          VariantSize[VType and varTypeMask]);
    end;
end;

function ReadOleVariant(Stream: TStream): OleVariant;

  function ReadArray(VType: Integer; Stream: TStream): OleVariant;
  var
    // Flags: TVarFlags;
    LoDim, HiDim, Indices, Bounds: PIntArray;
    DimCount, VSize, i: Integer;
    { P: Pointer; }
    V: OleVariant;
    LSafeArray: PSafeArray;
    P: Pointer;
  begin
    VarClear(Result);
    Stream.Read(DimCount, SizeOf(DimCount));
    VSize := DimCount * SizeOf(Integer);
    GetMem(LoDim, VSize);
    try
      GetMem(HiDim, VSize);
      try
        Stream.Read(LoDim^, VSize);
        Stream.Read(HiDim^, VSize);
        GetMem(Bounds, VSize * 2);
        try
          for i := 0 to DimCount - 1 do
          begin
            Bounds[i * 2] := LoDim[i];
            Bounds[i * 2 + 1] := HiDim[i];
          end;
          Result := VarArrayCreate(Slice(Bounds^, DimCount * 2),
            VType and varTypeMask);
        finally
          FreeMem(Bounds);
        end;
        if VType and varTypeMask in EasyArrayTypes then
        begin
          Stream.Read(VSize, SizeOf(VSize));
          P := VarArrayLock(Result);
          try
            Stream.Read(P^, VSize);
          finally
            VarArrayUnlock(Result);
          end;
        end
        else
        begin
          LSafeArray := PSafeArray(TVarData(Result).VArray);
          GetMem(Indices, VSize);
          try
            FillChar(Indices^, VSize, 0);
            for i := 0 to DimCount - 1 do
              Indices[i] := LoDim[i];
            while True do
            begin
              V := ReadOleVariant(Stream);
              if VType and varTypeMask = varVariant then
                OleCheck(SafeArrayPutElement(LSafeArray, Indices^, V))
              else
                OleCheck(SafeArrayPutElement(LSafeArray, Indices^,
                  TVarData(V).VPointer^));
              Inc(Indices[DimCount - 1]);
              if Indices[DimCount - 1] > HiDim[DimCount - 1] then
                for i := DimCount - 1 downto 0 do
                  if Indices[i] > HiDim[i] then
                  begin
                    if i = 0 then
                      Exit;
                    Inc(Indices[i - 1]);
                    Indices[i] := LoDim[i];
                  end;
            end;
          finally
            FreeMem(Indices);
          end;
        end;
      finally
        FreeMem(HiDim);
      end;
    finally
      FreeMem(LoDim);
    end;
  end;

var
  i, VType: Integer;
  W: WideString;
  // TmpFlags: TVarFlags;
  Flags: TVarFlags;
  lvBytes:Array[1..255] of Byte;
begin
  VarClear(Result);
  Flags := [];
  Stream.Read(VType, SizeOf(VType));
  if VType and varByRef = varByRef then
    Include(Flags, vfByRef);
  if VType = varByRef then
  begin
    Include(Flags, vfVariant);
    Result := ReadOleVariant(Stream); // TmpFlags, Data);
    Exit;
  end;
  if vfByRef in Flags then
    VType := VType xor varByRef;
  if (VType and varArray) = varArray then
    Result := ReadArray(VType, Stream)
  else
    case VType and varTypeMask of
      varEmpty:
        VarClear(Result);
      varNull:
        Result := NULL;
      varOleStr:
        begin
          Stream.Read(i, SizeOf(Integer));
          SetLength(W, i);
          Stream.Read(W[1], i * 2);
          Result := W;
        end;
      varCurrency:
        begin
          i := VariantSize[VType and varTypeMask];
          TVarData(Result).VType := VType;
          Stream.Read(TVarData(Result).VCurrency, i);
//          Stream.Read(lvBytes[1], i);
//          Windows.CopyMemory(@TVarData(Result).VCurrency, @lvBytes[1], i);
        end;
      varDouble:
        begin
          i := VariantSize[VType and varTypeMask];
          TVarData(Result).VType := VType;
          Stream.Read(TVarData(Result).VDouble, i);
//          Stream.Read(lvBytes[1], i);
//          Windows.CopyMemory(@TVarData(Result).VCurrency, @lvBytes[1], i);
        end;
      varSmallInt:
        begin
          i := VariantSize[VType and varTypeMask];
          TVarData(Result).VType := VType;
          Stream.Read(TVarData(Result).VSmallInt, i);
//          Stream.Read(lvBytes[1], i);
//          Windows.CopyMemory(@TVarData(Result).VCurrency, @lvBytes[1], i);
        end;
      varInteger:
        begin
          i := VariantSize[VType and varTypeMask];
          TVarData(Result).VType := VType;
          Stream.Read(TVarData(Result).VInteger, i);
//          Stream.Read(lvBytes[1], i);
//          Windows.CopyMemory(@TVarData(Result).VCurrency, @lvBytes[1], i);
        end;
      varInt64:
        begin
          i := VariantSize[VType and varTypeMask];
          TVarData(Result).VType := VType;
          Stream.Read(TVarData(Result).VInt64, i);
//          Stream.Read(lvBytes[1], i);
//          Windows.CopyMemory(@TVarData(Result).VCurrency, @lvBytes[1], i);
        end;
      varSingle:
        begin
          i := VariantSize[VType and varTypeMask];
          TVarData(Result).VType := VType;
          Stream.Read(TVarData(Result).VSingle, i);
//          Stream.Read(lvBytes[1], i);
//          Windows.CopyMemory(@TVarData(Result).VCurrency, @lvBytes[1], i);
        end;
      varWord:
        begin
          i := VariantSize[VType and varTypeMask];
          TVarData(Result).VType := VType;
          Stream.Read(TVarData(Result).VWord, i);
//          Stream.Read(lvBytes[1], i);
//          Windows.CopyMemory(@TVarData(Result).VCurrency, @lvBytes[1], i);
        end;
      varLongWord:
        begin
          i := VariantSize[VType and varTypeMask];
          TVarData(Result).VType := VType;
          Stream.Read(TVarData(Result).VLongWord, i);
//          Stream.Read(lvBytes[1], i);
//          Windows.CopyMemory(@TVarData(Result).VCurrency, @lvBytes[1], i);
        end;

      varBoolean:
        begin
          i := VariantSize[VType and varTypeMask];
          TVarData(Result).VType := VType;
          Stream.Read(TVarData(Result).VBoolean, i);
//          Stream.Read(lvBytes[1], i);
//          Windows.CopyMemory(@TVarData(Result).VCurrency, @lvBytes[1], i);
        end;

      varDate:
        begin
          i := VariantSize[VType and varTypeMask];
          TVarData(Result).VType := VType;
          Stream.Read(TVarData(Result).VDate, i);
//          Stream.Read(lvBytes[1], i);
//          Windows.CopyMemory(@TVarData(Result).VCurrency, @lvBytes[1], i);
        end;


      varDispatch:
        raise Exception.CreateResFmt(@SBadVariantType, [IntToHex(VType, 4)]);
      varUnknown:
        raise Exception.CreateResFmt(@SBadVariantType, [IntToHex(VType, 4)]);
    else
      TVarData(Result).VType := VType;
      Stream.Read(TVarData(Result).VPointer^,
        VariantSize[VType and varTypeMask]);
    end;
end;

end.
