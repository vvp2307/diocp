unit uCDSProvider;

interface

uses
  DBClient, ADODB, Provider, SysUtils, ActiveX;

type
  TCDSProvider = class(TObject)
  private
    FADOQuery: TADOQuery;
    FCDSTemp:TClientDataSet;
    FConnection: TADOConnection;
    FProvider: TDataSetProvider;
    procedure SetConnection(const AValue: TADOConnection);
  public
    constructor Create;
    
    destructor Destroy; override;
    
    //获取一个CDS.DATA数据包
    function QueryData(pvCmdText: string; pvOperaMsg: string = ''): OleVariant;

    //获取一个CDS.XMLDATA数据包
    function QueryXMLData(pvCmdText: string): string;

    procedure ExecuteScript(pvCmdText:String; pvOperaMsg: string = '');
    
    property Connection: TADOConnection read FConnection write SetConnection;
  end;

implementation

uses
  Windows, FileLogger;

constructor TCDSProvider.Create;
begin
  inherited Create;
  CoInitialize(nil);
  FCDSTemp := TClientDataSet.Create(nil);
  FProvider := TDataSetProvider.Create(nil);
  FProvider.Options := FProvider.Options + [poIncFieldProps];

  FADOQuery := TADOQuery.Create(nil);
  FADOQuery.DisableControls;
  FADOQuery.ParamCheck := false;
  FProvider.DataSet := FADOQuery;
end;

destructor TCDSProvider.Destroy;
begin
  FreeAndNil(FCDSTemp);
  FreeAndNil(FADOQuery);
  FreeAndNil(FProvider);
  inherited Destroy;
end;

procedure TCDSProvider.ExecuteScript(pvCmdText, pvOperaMsg: string);
begin
  try
    FADOQuery.Close;
    FADOQuery.SQL.Clear;
    FADOQuery.SQL.Add(pvCmdText);
    FADOQuery.ExecSQL;
  except on e: Exception do
    begin
       raise;
    end;
  end;
end;

function TCDSProvider.QueryData(pvCmdText: string; pvOperaMsg: string = ''):
    OleVariant;
var
  i: Integer;
begin
  try
    FADOQuery.Close;
    FADOQuery.SQL.Clear;
    FADOQuery.SQL.Add(pvCmdText);
    FADOQuery.Open;
    for i := 0 to FADOQuery.FieldCount - 1 do
    begin
      FADOQuery.Fields[i].ReadOnly := false;
    end;
    Result := FProvider.Data;
  except on e: Exception do
    begin
       raise;
    end;
  end;

end;

function TCDSProvider.QueryXMLData(pvCmdText: string): string;
var
  i: Integer;
  lvTickCount, lvTimeCount_01, lvTimeCount_02, lvTimeCount_03, lvTimeCount_04:Integer;
  lvTime_01, lvTime_02, lvTime_03, lvTime_04, lvTime_05:TDateTime;
  lvPreSQL:String;
begin
  lvTickCount := GetTickCount;
  lvTime_01 := Now();
  try
    lvTimeCount_01 := 0;
    lvTimeCount_02 := 0;
    lvTimeCount_03 := 0;

    lvPreSQL := FADOQuery.SQL.Text;
    FADOQuery.Close;
    lvTime_02 := Now();
    FADOQuery.SQL.Clear;
    lvTime_03 := Now();
    FADOQuery.SQL.Add(pvCmdText);
    lvTime_04 := Now();
    FADOQuery.Open;
    lvTime_05 := Now();
    lvTimeCount_01 := GetTickCount - lvTickCount;


    try
      for i := 0 to FADOQuery.FieldCount - 1 do
      begin
        FADOQuery.Fields[i].ReadOnly := false;
      end;
    except
      on E:Exception do
      begin
        raise Exception.Create('设置字段只读时出现了异常:' + e.Message);
      end;
    end;
    lvTimeCount_02 := GetTickCount - lvTickCount;

    FProvider.DataSet := FADOQuery;
    FCDSTemp.Data := FProvider.Data;
    Result := FCDSTemp.XMLData;

    lvTimeCount_03 := GetTickCount - lvTickCount;
    FADOQuery.Close;
  finally
    lvTimeCount_04 := GetTickCount - lvTickCount;
    if (lvTimeCount_04 > 1000 * 60 * 2) then
    begin
      TFileLogger.instance.logMessage(Format('执行了时间断点:%s, %s, %s, %s, %s',
         [FormatDateTime('MM-dd hh:nn:ss.zzz', lvTime_01),
         FormatDateTime('hh:nn:ss.zzz', lvTime_02),
         FormatDateTime('hh:nn:ss.zzz', lvTime_03),
         FormatDateTime('hh:nn:ss.zzz', lvTime_04),
         FormatDateTime('hh:nn:ss.zzz', lvTime_05)
         ]), 'cdsProvider');

      TFileLogger.instance.logMessage(lvPreSQL, 'cdsProvider');

      TFileLogger.instance.logMessage(Format('执行了实际超出理解范围:%d, %d, %d, %d',
         [lvTimeCount_01, lvTimeCount_02, lvTimeCount_03, lvTimeCount_04]) + sLineBreak + pvCmdText, 'cdsProvider');
    end;
  end;
end;

procedure TCDSProvider.SetConnection(const AValue: TADOConnection);
begin
  FConnection := AValue;
  FADOQuery.Connection := FConnection;
  if FConnection <> nil then  
    FADOQuery.CommandTimeout := FADOQuery.Connection.CommandTimeout;
end;

end.
