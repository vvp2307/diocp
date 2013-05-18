program IOCPClientTester;

uses
  FastMM4,
  FastMM4Messages,
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
  superobject in '..\..\Common\superobject.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
