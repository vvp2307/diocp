program DIOCP_DBClient_Tester;

uses
  Forms,
  ufrmMain in 'ufrmMain.pas' {frmMain},
  uSocketTools in '..\..\..\Source\Utils\uSocketTools.pas',
  uMemoLogger in '..\..\..\Source\Utils\uMemoLogger.pas',
  uJSonStreamClientCoder in '..\..\IOCPCoder\uJSonStreamClientCoder.pas',
  JSonStream in '..\..\Common\JSonStream.pas',
  uNetworkTools in '..\..\IOCPCoder\uNetworkTools.pas',
  uClientSocket in '..\..\..\Source\ClientSocket\uClientSocket.pas',
  uD10ClientSocket in '..\..\..\Source\ClientSocket\uD10ClientSocket.pas',
  uJSonStreamTools in '..\..\Common\uJSonStreamTools.pas',
  uCRCTools in '..\..\Common\uCRCTools.pas',
  FileLogger in '..\..\..\Source\IOCP\FileLogger.pas',
  CDSOperatorWrapper in '..\Common\CDSOperatorWrapper.pas',
  uICDSOperator in '..\Common\uICDSOperator.pas',
  uTester in 'uTester.pas',
  uRDBOperator in '..\..\Common\uRDBOperator.pas',
  ScktComp in 'ScktComp.pas',
  uZipTools in '..\..\..\Source\Utils\uZipTools.pas',
  uTesterTools in '..\..\IOCPCoder\uTesterTools.pas',
  uAppTools in '..\..\..\Source\Utils\uAppTools.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
