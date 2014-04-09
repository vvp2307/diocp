program DBServer_MyUniPool;

uses
  FastMM4 in '..\..\..\Source\Utils\FastMM4.pas',
  FastMM4Messages in '..\..\..\Source\Utils\FastMM4Messages.pas',
  Forms,
  ufrmMain in 'ufrmMain.pas' {frmMain},
  uClientContext in 'Handler\uClientContext.pas',
  uIOCPJSonStreamDecoder in '..\..\IOCPCoder\uIOCPJSonStreamDecoder.pas',
  uIOCPJSonStreamEncoder in '..\..\IOCPCoder\uIOCPJSonStreamEncoder.pas',
  JSonStream in '..\..\Common\JSonStream.pas',
  uNetworkTools in '..\..\IOCPCoder\uNetworkTools.pas',
  FileLogger in '..\..\..\Source\IOCP\FileLogger.pas',
  uBuffer in '..\..\..\Source\IOCP\uBuffer.pas',
  uIOCPCentre in '..\..\..\Source\IOCP\uIOCPCentre.pas',
  uIOCPConsole in '..\..\..\Source\IOCP\uIOCPConsole.pas',
  uIOCPFileLogger in '..\..\..\Source\IOCP\uIOCPFileLogger.pas',
  uIOCPProtocol in '..\..\..\Source\IOCP\uIOCPProtocol.pas',
  uIOCPTools in '..\..\..\Source\IOCP\uIOCPTools.pas',
  uIOCPWorker in '..\..\..\Source\IOCP\uIOCPWorker.pas',
  uMemPool in '..\..\..\Source\IOCP\uMemPool.pas',
  uSocketListener in '..\..\..\Source\IOCP\uSocketListener.pas',
  uZipTools in '..\..\..\Source\Utils\uZipTools.pas',
  uIOCPDebugger in '..\..\..\Source\IOCP\uIOCPDebugger.pas',
  uFMIOCPDebugINfo in '..\..\Common\uFMIOCPDebugINfo.pas' {FMIOCPDebugINfo: TFrame},
  uCRCTools in '..\..\Common\uCRCTools.pas',
  uRunTimeINfoTools in '..\..\Common\uRunTimeINfoTools.pas',
  superobject in '..\..\Common\superobject.pas',
  uMyTypes in '..\..\..\Source\IOCP\uMyTypes.pas',
  Qos in '..\..\..\Source\WinSock2\Qos.pas',
  Winsock2 in '..\..\..\Source\WinSock2\Winsock2.pas',
  uUniConnectionPool in '..\..\MyUniPool\uUniConnectionPool.pas',
  uUniConnectionPoolGroup in '..\..\MyUniPool\uUniConnectionPoolGroup.pas',
  uUniPoolGroupTools in '..\..\MyUniPool\uUniPoolGroupTools.pas',
  uUniDACTools in '..\..\MyUniPool\uUniDACTools.pas',
  uCDSProvider in '..\..\MyUniPool\uCDSProvider.pas',
  uDBAccessOperator in '..\..\MyUniPool\uDBAccessOperator.pas',
  uMyObjectPool in '..\..\MyUniPool\uMyObjectPool.pas',
  uUniConfigTools in '..\..\MyUniPool\uUniConfigTools.pas',
  uUniOperator in '..\..\MyUniPool\uUniOperator.pas',
  uICDSOperator in '..\..\MyUniPool\uICDSOperator.pas',
  uIDBAccess in '..\..\MyUniPool\uIDBAccess.pas',
  uIErrorGetter in '..\..\MyUniPool\uIErrorGetter.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
