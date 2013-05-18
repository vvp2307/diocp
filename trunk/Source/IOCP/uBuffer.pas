unit uBuffer;
{
   套接字对应的接收缓存，使用链条模式。
}

interface

uses
  Windows;

type
  PBufRecord = ^_BufRecord;
  _BufRecord = packed record
    len: Cardinal; // the length of the buffer
    buf: PAnsiChar; // the pointer to the buffer

    preBuf:PBufRecord;   //前一个buffer
    nextBuf:PBufRecord;  //后一个buffer
  end;

  TBufferLink = class(TObject)
  private
    FHead: PBufRecord;
    FTail:PBufRecord;

    //当前读到的Buffer
    FRead:PBufRecord;
    
    //当前读到的Buffer位置
    FReadPosition: Cardinal;

    FMark:PBufRecord;
    FMarkPosition: Cardinal;

    function InnerReadBuf(const pvBufRecord: PBufRecord; pvStartIndex: Cardinal;
        buf: PAnsiChar; len: Cardinal): Cardinal;
  public
    constructor Create;

    destructor Destroy; override;

    procedure markReaderIndex;

    procedure restoreReaderIndex;

    procedure AddBuffer(buf:PAnsiChar; len:Cardinal);

    function readBuffer(const buf: PAnsiChar; len: Cardinal): Cardinal;

    procedure clearBuffer;
    
    /// <summary>
    ///   有效的可读取的数量
    /// </summary>
    /// <returns> Integer
    /// </returns>
    function validCount: Integer;
  end;


implementation

procedure TBufferLink.clearBuffer;
var
  lvBuf, lvFreeBuf:PBufRecord;
begin
  lvBuf := FTail;
  while lvBuf <> nil do
  begin
    lvFreeBuf :=lvBuf;
    lvBuf := lvBuf.preBuf;
    FreeMem(lvFreeBuf.buf, lvFreeBuf.len);
    FreeMem(lvFreeBuf, SizeOf(_BufRecord));
  end;

  FHead := nil;
  FTail := nil;
  
  FRead := nil;
  FReadPosition := 0;
  
  FMark := nil;
  FMarkPosition := 0;
end;

constructor TBufferLink.Create;
begin
  inherited Create;
  FReadPosition := 0;
end;


destructor TBufferLink.Destroy;
begin
  clearBuffer;
  inherited Destroy;
end;

{ TBufferLink }

procedure TBufferLink.AddBuffer(buf: PAnsiChar; len: Cardinal);
var
  lvBuf:PBufRecord;
begin
  getMem(lvBuf, SizeOf(_BufRecord));
  lvBuf.preBuf := nil;
  lvBuf.nextBuf := nil;
  getMem(lvBuf.buf,len);
  lvBuf.len := len;
  CopyMemory(lvBuf.buf, Pointer(LongInt(buf)), len);
  if FHead = nil then
  begin
    FHead := lvBuf;
  end;
  
  if FTail = nil then
  begin
    FTail := lvBuf;
  end else
  begin
    FTail.nextBuf := lvBuf;
    lvBuf.preBuf := FTail;
    
    FTail := lvBuf;
  end;
end;

function TBufferLink.InnerReadBuf(const pvBufRecord: PBufRecord; pvStartIndex:
    Cardinal; buf: PAnsiChar; len: Cardinal): Cardinal;
var
  lvValidCount:Cardinal;
begin
  Result := 0;
  if pvBufRecord <> nil then
  begin
    lvValidCount := pvBufRecord.len-pvStartIndex;
    if lvValidCount <= 0 then
    begin
      Result := 0;
    end else
    begin
      if len <= lvValidCount then
      begin
        CopyMemory(buf, Pointer(Cardinal(pvBufRecord.buf) + pvStartIndex), len);
        Result := len;
      end else
      begin
        CopyMemory(buf, Pointer(Cardinal(pvBufRecord.buf) + pvStartIndex), lvValidCount);
        Result := lvValidCount;
      end;
    end;

  end;
end;

procedure TBufferLink.markReaderIndex;
begin
  FMark := FRead;
  FMarkPosition := FReadPosition;
end;

function TBufferLink.readBuffer(const buf: PAnsiChar; len: Cardinal): Cardinal;
var
  lvBuf:PBufRecord;
  lvPosition, l, lvReadCount, lvRemain:Cardinal;
begin
  lvReadCount := 0;
  lvBuf := FRead;
  lvPosition := FReadPosition;
  if lvBuf = nil then
  begin
    lvBuf := FHead;
    lvPosition := 0;
  end;

  if lvBuf <> nil then
  begin
    lvRemain := len;
    while lvBuf <> nil do
    begin
      l := InnerReadBuf(lvBuf, lvPosition, Pointer(Cardinal(buf) + lvReadCount), lvRemain);
      if l = lvRemain then
      begin
        //读完
        inc(lvReadCount, l);
        Inc(lvPosition, l);
        FReadPosition := lvPosition;
        FRead := lvBuf;
        lvRemain := 0;
        Break;
      end else if l < lvRemain then  //读取的比需要读的长度小
      begin
        lvRemain := lvRemain - l;
        inc(lvReadCount, l);
        Inc(lvPosition, l);
        FReadPosition := lvPosition;
        FRead := lvBuf;
        lvBuf := lvBuf.nextBuf;
        if lvBuf <> nil then   //读下一个
        begin
          FRead := lvBuf;
          FReadPosition := 0;
          lvPosition := 0;
        end;
      end;
    end;
    Result := lvReadCount;
  end else
  begin
    Result := 0;
  end;

end;


procedure TBufferLink.restoreReaderIndex;
begin
  FRead := FMark;
  FReadPosition := FMarkPosition;
end;

function TBufferLink.validCount: Integer;
var
  lvNext:PBufRecord;
begin
  Result := 0;
  if FRead = nil then
  begin
    lvNext:= FHead;
  end else
  begin
    Result := FRead.len-FReadPosition;
    lvNext := FRead.nextBuf;
  end;
  while lvNext <> nil do
  begin
    Inc(Result, lvNext.len);
    lvNext := lvNext.nextBuf;
  end;
end;

end.
