unit uICDSOperator;

///  2014年1月14日 17:40:58
///    IEncode和IDecode都可以As 成IGetLastError接口
///      可以查询最后一次操作的错误
///
///  2013年5月27日 15:43:41
///    Execute
///    ExecuteUpdate
///    Decode.setData
///    修改成有返回值的函数


interface

const
  CDS_CODE_NO_ERROR = 0;
  CDS_CODE_ERROR = -1;

  DB_TYPE_MSSQL = 1;
  DB_TYPE_ORACLE = 2;
  DB_TYPE_Access = 3;

type
  IGetLastError = interface(IInterface)
    ['{FE339954-1E01-47B3-9449-F341A9FA3231}']
    function getLastErrorCode:Integer; stdcall;
    function getLastErrDesc:PAnsiChar; stdcall;
  end;

  //数据库操作接口
  IDBAccessOperator = interface(IInterface)
    ['{EBD61421-4D50-48C5-81A6-5CAC70EB6852}']
    function executeSQL(pvCmdText:PAnsiChar): Integer; stdcall;
    function getTableFields(pvTable:PAnsiChar):PAnsiChar;stdcall;
  end;

  //CDS编码接口，由DLL提供
  ICDSEncode = interface(IInterface)
    ['{770DCFA9-FF77-4DA0-B8BD-484CD0B572CF}']
    function getPackageData:PAnsiChar;stdcall;
    procedure setTableINfo(pvUpdateTable:PAnsiChar; pvKeyFields:PAnsiChar);stdcall;
    procedure setData(pvData:OleVariant; pvDelta:OleVariant);stdcall;
    function Execute: Integer; stdcall;
  end;


  //CDS解码接口, 由DLL提供
  ICDSDecode = interface(IInterface)
    ['{BD95B72B-89C4-4B8E-AC51-06A89F4E9150}']
    
    //获取解码好的SQL语句
    function getUpdateSql():PAnsiChar;stdcall;

    function setData(pvEncodeData:PAnsiChar): Integer; stdcall;

    //如果赋值了TabFields可以不进行赋值IDBAccessOperator
    procedure SetTableFields(pvValue: PAnsiChar);stdcall;

    //通过该接口获取TableFields
    procedure setDBAccessOperator(dbOpera: IDBAccessOperator);stdcall;

    //加密后的SQL不能被查询分析器跟踪
    procedure setEncryptSQL(pvValue:Boolean);stdcall;

    //进行解码
    function Execute: Integer; stdcall;

    //解码后利用 IDBAccessOperator执行更新语句
    function ExecuteUpdate: Integer; stdcall;
  end;

  //CDS解码接口, 由DLL提供
  ICDSDecodeTypeSetter = interface(IInterface)
    ['{037E41F9-8E53-478F-8574-2EE797025D32}']
    procedure setDBType(pvType:Integer);stdcall;
  end;

implementation

end.
