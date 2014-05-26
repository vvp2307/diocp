unit uJSonStreamPacker;

interface


type
  TPackerHead = packed record
    signature : string[4];   //4个字符的签名
    headCRC: Cardinal;       //头文件的crc
    jsonLength: Cardinal;    //json包长度
    streamLength: Cardinal;  //流长度
  end;

  TJSonStreamPacker = class(TObject)
  private
    
  public

  end;

implementation

end.
