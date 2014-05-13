program CXNetServer;

uses
  FastMM4 in '..\..\..\Source\Utils\FastMM4.pas',
  FastMM4Messages in '..\..\..\Source\Utils\FastMM4Messages.pas',
  EMemLeaks,
  EResLeaks,
  EDebugExports,
  EAppVCL,
  ExceptionLog7,
  Forms,
  ufrmMain in 'ufrmMain.pas' {frmMain},
  uClientContext in 'Handler\uClientContext.pas',
  TesterINfo in 'Handler\TesterINfo.pas',
  uIOCPJSonStreamDecoder in '..\..\IOCPCoder\uIOCPJSonStreamDecoder.pas',
  uIOCPJSonStreamEncoder in '..\..\IOCPCoder\uIOCPJSonStreamEncoder.pas',
  JSonStream in '..\..\Common\JSonStream.pas',
  uNetworkTools in '..\..\IOCPCoder\uNetworkTools.pas',
  FileLogger in '..\..\..\Source\IOCP\FileLogger.pas',
  uIOCPCentre in '..\..\..\Source\IOCP\uIOCPCentre.pas',
  uIOCPConsole in '..\..\..\Source\IOCP\uIOCPConsole.pas',
  uIOCPFileLogger in '..\..\..\Source\IOCP\uIOCPFileLogger.pas',
  uIOCPProtocol in '..\..\..\Source\IOCP\uIOCPProtocol.pas',
  uIOCPTools in '..\..\..\Source\IOCP\uIOCPTools.pas',
  uIOCPWorker in '..\..\..\Source\IOCP\uIOCPWorker.pas',
  uMemPool in '..\..\..\Source\IOCP\uMemPool.pas',
  uSocketListener in '..\..\..\Source\IOCP\uSocketListener.pas',
  udmMain in 'DB\udmMain.pas' {dmMain: TDataModule},
  uCDSProvider in 'DB\uCDSProvider.pas',
  ADOConnConfig in 'DB\ADOConnConfig.pas',
  uDBAccessOperator in '..\Common\uDBAccessOperator.pas',
  uICDSOperator in '..\Common\uICDSOperator.pas',
  uADOPoolGroupTools in 'DB\uADOPoolGroupTools.pas',
  uADOConnectionPool in '..\..\ADOPool\uADOConnectionPool.pas',
  uADOConnectionPoolGroup in '..\..\ADOPool\uADOConnectionPoolGroup.pas',
  uADOOperator in 'DB\uADOOperator.pas',
  uDBOperatorPool in 'DB\uDBOperatorPool.pas',
  uScriptMgr in 'DB\uScriptMgr.pas',
  MyScriptLoader in 'DB\MyScriptLoader.pas',
  scriptParser in 'DB\scriptParser.pas',
  uWinService in 'WinService\uWinService.pas',
  uAppJSonConfig in 'Utils\uAppJSonConfig.pas',
  uZipTools in '..\..\..\Source\Utils\uZipTools.pas',
  uAppTools in '..\..\..\Source\Utils\uAppTools.pas',
  uIOCPDebugger in '..\..\..\Source\IOCP\uIOCPDebugger.pas',
  uADOConnectionTools in '..\..\..\..\..\..\..\01.ERP开发平台\Source\FrameUtils\uADOConnectionTools.pas',
  uFMIOCPDebugINfo in '..\..\Common\uFMIOCPDebugINfo.pas' {FMIOCPDebugINfo: TFrame},
  uRunTimeINfoTools in '..\..\Common\uRunTimeINfoTools.pas',
  CDSOperatorWrapper in '..\Common\CDSOperatorWrapper.pas',
  uMyTypes in '..\..\..\Source\IOCP\uMyTypes.pas',
  Qos in '..\..\..\Source\WinSock2\Qos.pas',
  Winsock2 in '..\..\..\Source\WinSock2\Winsock2.pas',
  uMyObjectPool in '..\..\ADOPool\uMyObjectPool.pas',
  uBuffer in 'uBuffer.pas',
  uBufferTools in '..\..\..\Source\IOCP\uBufferTools.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
