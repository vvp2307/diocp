program IOCPIdTcpClientTester;

uses
  Forms,
  ufrmMain in 'ufrmMain.pas' {frmMain},
  uSocketTools in '..\..\..\Source\Utils\uSocketTools.pas',
  uMemoLogger in '..\..\..\Source\Utils\uMemoLogger.pas',
  uEchoTester in 'uEchoTester.pas',
  JSonStream in '..\..\Common\JSonStream.pas',
  uNetworkTools in '..\..\IOCPCoder\uNetworkTools.pas',
  uJSonStreamTools in '..\..\Common\uJSonStreamTools.pas',
  uCRCTools in '..\..\Common\uCRCTools.pas',
  superobject in '..\..\Common\superobject.pas',
  FileLogger in '..\..\..\Source\IOCP\FileLogger.pas',
  uIdTcpClientJSonStreamCoder in '..\..\IOCPCoder\uIdTcpClientJSonStreamCoder.pas',
  uTesterTools in '..\..\IOCPCoder\uTesterTools.pas',
  uMyTypes in '..\..\..\Source\IOCP\uMyTypes.pas',
  uZipTools in '..\..\..\Source\Utils\uZipTools.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
