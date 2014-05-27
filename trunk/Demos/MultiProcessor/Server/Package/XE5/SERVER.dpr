program SERVER;

uses
  FastMM4 in '..\..\..\..\..\Source\Utils\FastMM4.pas',
  FastMM4Messages in '..\..\..\..\..\Source\Utils\FastMM4Messages.pas',
  Forms,
  ufrmMain in '..\..\ufrmMain.pas' {frmMain},
  uClientContext in '..\..\Handler\uClientContext.pas',
  uIOCPJSonStreamDecoder in '..\..\..\..\IOCPCoder\uIOCPJSonStreamDecoder.pas',
  uIOCPJSonStreamEncoder in '..\..\..\..\IOCPCoder\uIOCPJSonStreamEncoder.pas',
  JSonStream in '..\..\..\..\Common\JSonStream.pas',
  uNetworkTools in '..\..\..\..\IOCPCoder\uNetworkTools.pas',
  FileLogger in '..\..\..\..\..\Source\IOCP\FileLogger.pas',
  uIOCPCentre in '..\..\..\..\..\Source\IOCP\uIOCPCentre.pas',
  uIOCPConsole in '..\..\..\..\..\Source\IOCP\uIOCPConsole.pas',
  uIOCPFileLogger in '..\..\..\..\..\Source\IOCP\uIOCPFileLogger.pas',
  uIOCPProtocol in '..\..\..\..\..\Source\IOCP\uIOCPProtocol.pas',
  uIOCPTools in '..\..\..\..\..\Source\IOCP\uIOCPTools.pas',
  uIOCPWorker in '..\..\..\..\..\Source\IOCP\uIOCPWorker.pas',
  uMemPool in '..\..\..\..\..\Source\IOCP\uMemPool.pas',
  uSocketListener in '..\..\..\..\..\Source\IOCP\uSocketListener.pas',
  uZipTools in '..\..\..\..\..\Source\Utils\uZipTools.pas',
  uAppTools in '..\..\..\..\..\Source\Utils\uAppTools.pas',
  uIOCPDebugger in '..\..\..\..\..\Source\IOCP\uIOCPDebugger.pas',
  uFMIOCPDebugINfo in '..\..\..\..\Common\uFMIOCPDebugINfo.pas' {FMIOCPDebugINfo: TFrame},
  uRunTimeINfoTools in '..\..\..\..\Common\uRunTimeINfoTools.pas',
  Qos in '..\..\..\..\..\Source\WinSock2\Qos.pas',
  Winsock2 in '..\..\..\..\..\Source\WinSock2\Winsock2.pas',
  uMyTypes in '..\..\..\..\..\Source\IOCP\uMyTypes.pas',
  uAppJSonConfig in '..\..\Utils\uAppJSonConfig.pas',
  superobject in '..\..\..\..\Common\superobject.pas',
  uBuffer in '..\..\..\..\..\Source\IOCP\uBuffer.pas',
  GpLockFreeQueue in '..\..\..\..\Queue\GpLockFreeQueue.pas',
  OTLObjectQueue in '..\..\..\..\Queue\OTLObjectQueue.pas',
  uWorkDispatcher in '..\..\Handler\uWorkDispatcher.pas',
  zmq in '..\..\zmq\zmq.pas',
  zmqapi in '..\..\zmq\zmqapi.pas',
  uJSonStreamTools in '..\..\..\..\Common\uJSonStreamTools.pas',
  uCRCTools in '..\..\..\..\Common\uCRCTools.pas',
  uJobPushWorker in '..\..\Handler\uJobPushWorker.pas',
  uJobReceiver in '..\..\Handler\uJobReceiver.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
