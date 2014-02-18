unit uIOCPProtocol;

interface

uses
  winsock2, Windows, SysUtils;

const
  //每次接收最大的字节数
  //OVERLAPPEDEx.DataBuf中每次分配空间数
  //每次发送最大的字节数
  MAX_OVERLAPPEDEx_BUFFER_SIZE = 1024 * 2;  //8K

const
  IO_TYPE_Accept = 1;
  IO_TYPE_Recv = 2;
  IO_TYPE_Send = 3;   //发送数据
  IO_TYPE_Close = 4;  //关闭socket

  {* IOCP退出标志 *}
  IOCP_Queued_SHUTDOWN = $FFFFFFFF;

  //线程退出
  IOCP_RESULT_EXIT = 1;

  //执行成功
  IOCP_RESULT_OK = 0;

type
  POVERLAPPEDEx = ^OVERLAPPEDEx;

  OVERLAPPEDEx = packed record
    Overlapped: OVERLAPPED;
    IO_TYPE: Cardinal;
    DataBuf: TWSABUF;
    WorkBytes: Cardinal;    //如果是接收，接收的字节数
    WorkFlag: Cardinal;
    pre:POVERLAPPEDEx;
    next:POVERLAPPEDEx;
  end;

  TIOCPBytes = array of Byte;

implementation

end.
