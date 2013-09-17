program IOCP_DBServer;

uses
  FastMM4 in '..\..\..\Source\Utils\FastMM4.pas',
  FastMM4Messages in '..\..\..\Source\Utils\FastMM4Messages.pas',
  Forms,
  ufrmMain in 'ufrmMain.pas' {frmMain},
  uClientContext in 'Handler\uClientContext.pas',
  uIOCPJSonStreamDecoder in '..\..\IOCPCoder\uIOCPJSonStreamDecoder.pas',
  uIOCPJSonStreamEncoder in '..\..\IOCPCoder\uIOCPJSonStreamEncoder.pas',
  JSonStream in '..\..\Common\JSonStream.pas',
  superobject in '..\..\Common\superobject.pas',
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
  JwaMSWSock in '..\..\..\Source\WinSock2\JwaMSWSock.pas',
  JwaQos in '..\..\..\Source\WinSock2\JwaQos.pas',
  JwaWinsock2 in '..\..\..\Source\WinSock2\JwaWinsock2.pas',
  uZipTools in '..\..\..\Source\Utils\uZipTools.pas',
  uIOCPDebugger in '..\..\..\Source\IOCP\uIOCPDebugger.pas',
  uFMIOCPDebugINfo in '..\..\Common\uFMIOCPDebugINfo.pas' {FMIOCPDebugINfo: TFrame},
  uCRCTools in '..\..\Common\uCRCTools.pas',
  uUniOperator in '..\..\UniDACPool\uUniOperator.pas',
  UntCobblerUniPool in '..\..\UniDACPool\UntCobblerUniPool.pas',
  UntThreadTimer in '..\..\UniDACPool\UntThreadTimer.pas',
  uCDSProvider in '..\..\UniDACPool\uCDSProvider.pas',
  uDBAccessOperator in '..\..\UniDACPool\uDBAccessOperator.pas',
  uICDSOperator in '..\..\UniDACPool\uICDSOperator.pas',
  uUniConfigTools in '..\..\UniDACPool\uUniConfigTools.pas',
  uUniPool in '..\..\UniDACPool\uUniPool.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
