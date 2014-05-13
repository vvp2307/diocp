unit udmMain;

interface

uses
  SysUtils, Classes, DB, ADODB, ADOConnConfig;

type
  TdmMain = class(TDataModule)
    conMain: TADOConnection;
    qryMain: TADOQuery;
    adsMain: TADODataSet;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoConnnectionConfig;
  end;

var
  dmMain: TdmMain;

implementation

{$R *.dfm}

constructor TdmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  TADOConnConfig.Instance.ADOConnection := conMain;
  TADOConnConfig.Instance.ReloadConfig;

  if conMain.ConnectionString = '' then
  begin
    conMain.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=.\cnzzz.mdb;Persist Security Info=False;'
  end;
end;

destructor TdmMain.Destroy;
begin
  TADOConnConfig.ReleaseInstance;
  inherited Destroy;
end;

procedure TdmMain.DoConnnectionConfig;
begin
  if TADOConnConfig.Instance.ConfigConnection then
  begin
    ;
  end;
end;



end.
