unit uICDSOperator;

interface

type                                                           
  IDBAccessOperator = interface(IInterface)
    ['{EBD61421-4D50-48C5-81A6-5CAC70EB6852}']
    function executeSQL(pvCmdText:PAnsiChar): Integer; stdcall;
    function getTableFields(pvTable:PAnsiChar):PAnsiChar;stdcall;
  end;

  ICDSEncode = interface(IInterface)
    ['{770DCFA9-FF77-4DA0-B8BD-484CD0B572CF}']
    function getPackageData:PAnsiChar;stdcall;
    procedure setTableINfo(pvUpdateTable:PAnsiChar; pvKeyFields:PAnsiChar);stdcall;
    procedure setData(pvData:OleVariant;pvDelta:OleVariant);stdcall;
    procedure Execute;stdcall;
  end;


  ICDSDecode = interface(IInterface)
    ['{BD95B72B-89C4-4B8E-AC51-06A89F4E9150}']
    
    //获取解码好的SQL语句
    function getUpdateSql():PAnsiChar;stdcall;

    procedure setData(pvEncodeData:PAnsiChar);stdcall;

    //如果赋值了TabFields可以不进行赋值IDBAccessOperator
    procedure SetTableFields(pvValue: PAnsiChar);stdcall;

    //通过该接口获取TableFields
    procedure setDBAccessOperator(dbOpera: IDBAccessOperator);stdcall;

    //加密后的SQL不能被查询分析器跟踪
    procedure setEncryptSQL(pvValue:Boolean);stdcall;

    //进行解码
    procedure Execute;stdcall;

    //解码后利用 IDBAccessOperator执行更新语句
    procedure ExecuteUpdate; stdcall;
  end;

implementation

end.
