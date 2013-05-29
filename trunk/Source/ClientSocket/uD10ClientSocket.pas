unit uD10ClientSocket;
///
//加入编码和解码器
///

interface

uses
  Windows, WinSock, uClientSocket, uSocketTools, SysUtils;

type
  TSocketObjectCoder = class;
  TSocketObjectCoderClass = class of TSocketObjectCoder;

  TD10ClientSocket = class(TClientSocket)
  private
    FInnerCoder: TSocketObjectCoder;

    FCoder:TSocketObjectCoder;
    
    procedure checkFreeOwnerCoder;
  public

    procedure registerCoder(pvCoder:TSocketObjectCoder; pvOwner:Boolean);

    constructor Create;

    procedure sendObject(pvObject:TObject);

    function recvObject(pvObject:TObject): Boolean;
    
    destructor Destroy; override;

  end;

  //解码器基类
  TSocketObjectCoder = class(TObject)
  public
    procedure Encode(pvSocket: TClientSocket; pvObject: TObject); virtual; abstract;
    function Decode(pvSocket: TClientSocket; pvObject: TObject): Boolean; virtual;
        abstract;
  end;  



implementation




constructor TD10ClientSocket.Create;
begin
  inherited Create;
  FCoder := nil;
end;

destructor TD10ClientSocket.Destroy;
begin
  checkFreeOwnerCoder;
  inherited Destroy;
end;

procedure TD10ClientSocket.checkFreeOwnerCoder;
begin
  if FInnerCoder <> nil then
  begin
    FInnerCoder.Free;
    FInnerCoder := nil;
  end;
end;

function TD10ClientSocket.recvObject(pvObject:TObject): Boolean;
begin
  Result := false;
  if FCoder = nil then raise Exception.Create('没有注册对象编码和解码器(registerCoder)!');
  
  if not Active then Exit;
  
  Result := FCoder.Decode(Self, pvObject);
end;

procedure TD10ClientSocket.registerCoder(pvCoder:TSocketObjectCoder;
    pvOwner:Boolean);
begin
  FCoder := pvCoder;
  if pvOwner then
  begin
    checkFreeOwnerCoder;
    FInnerCoder := FCoder;    
  end;
end;

procedure TD10ClientSocket.sendObject(pvObject:TObject);
begin
  if FCoder = nil then raise Exception.Create('没有注册对象编码和解码器(registerCoder)!');

  if not Active then Exit;

  FCoder.Encode(Self, pvObject);
end;

end.
