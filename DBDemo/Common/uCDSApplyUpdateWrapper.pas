unit uCDSApplyUpdateWrapper;

interface

uses
  DBClient, uICDSOperator, DB, SysUtils;

type
  TCDSApplyUpdateWrapper = class(TObject)
  public
    class procedure ExecuteApplyUpdate(pvCDS: TClientDataSet; const pvUpdateTable,
        pvUpdateKeyFields: String; const pvEncode: ICDSEncode; const pvDecode:
        ICDSDecode; const pvDBAccess: IDBAccessOperator);
  end;

implementation

class procedure TCDSApplyUpdateWrapper.ExecuteApplyUpdate(pvCDS:
    TClientDataSet; const pvUpdateTable, pvUpdateKeyFields: String; const
    pvEncode: ICDSEncode; const pvDecode: ICDSDecode; const pvDBAccess:
    IDBAccessOperator);
var
  lvUpdateKeyFields, lvUpdateTableName, lvPackDATA:AnsiString;

begin
  if pvCDS.State in [dsInsert, dsEdit] then
  begin
    pvCDS.Post;
  end;

  lvUpdateKeyFields := pvUpdateKeyFields;
  lvUpdateTableName := pvUpdateTable;

  if pvCDS.ChangeCount = 0 then exit;

  if pvEncode = nil then
    raise Exception.Create('缺少CDS编码接口!');

  if pvDecode = nil then
    raise Exception.Create('缺少解码接口!');

  pvEncode.setTableINfo(
     PAnsiChar(AnsiString(lvUpdateTableName)),
     PAnsiChar(AnsiString(lvUpdateKeyFields))
     );

  pvEncode.setData(pvCDs.Data, pvCDS.Delta);

  if pvEncode.Execute <> CDS_CODE_NO_ERROR then
  begin
    raise Exception.Create('CDS数据编码时出现异常:' + sLineBreak + (pvEncode as IGetLastError).getLastErrDesc);
  end;

  //获取编码数据字符串
  lvPackDATA := pvEncode.getPackageData;

  //设置需要解码的数据字符串
  if pvDecode.setData(PAnsiChar(AnsiString(lvPackDATA))) <> CDS_CODE_NO_ERROR then
  begin
    raise Exception.Create('CDS设置解码数据时出现异常:' + sLineBreak + (pvDecode as IGetLastError).getLastErrDesc);
  end;

  //设置数据库操作接口
  pvDecode.setDBAccessOperator(pvDBAccess);
  if pvDecode.Execute <> CDS_CODE_NO_ERROR then
  begin
    raise Exception.Create('CDS解码时出现异常:' + sLineBreak + (pvDecode as IGetLastError).getLastErrDesc);
  end;

  //利用数据接口执行更新语句
  if pvDecode.ExecuteUpdate <> CDS_CODE_NO_ERROR then
  begin
    raise Exception.Create('CDS执行保存SQL语句异常:' + sLineBreak + (pvDecode as IGetLastError).getLastErrDesc);
  end;                                  

  lvUpdateKeyFields := '';
  lvUpdateTableName := '';
  lvPackDATA := '';
end;

end.
