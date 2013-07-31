program IOCPClientTester;

uses
  Forms,
  ufrmMain in 'ufrmMain.pas' {frmMain},
  uSocketTools in '..\..\..\Source\Utils\uSocketTools.pas',
  uMemoLogger in '..\..\..\Source\Utils\uMemoLogger.pas',
  uEchoTester in 'uEchoTester.pas',
  uJSonStreamClientCoder in '..\..\IOCPCoder\uJSonStreamClientCoder.pas',
  JSonStream in '..\..\Common\JSonStream.pas',
  uNetworkTools in '..\..\IOCPCoder\uNetworkTools.pas',
  uClientSocket in '..\..\..\Source\ClientSocket\uClientSocket.pas',
  uD10ClientSocket in '..\..\..\Source\ClientSocket\uD10ClientSocket.pas',
  uJSonStreamTools in '..\..\Common\uJSonStreamTools.pas',
  uCRCTools in '..\..\Common\uCRCTools.pas',
  superobject in '..\..\Common\superobject.pas',
  JwaWinsock2 in '..\..\..\Source\WinSock2\JwaWinsock2.pas',
  JwaMSWSock in '..\..\..\Source\WinSock2\JwaMSWSock.pas',
  JwaQos in '..\..\..\Source\WinSock2\JwaQos.pas',
  FileLogger in '..\..\..\Source\IOCP\FileLogger.pas',
  uTesterTools in '..\..\IOCPCoder\uTesterTools.pas',
  uIOCPProtocol in '..\..\..\Source\IOCP\uIOCPProtocol.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
