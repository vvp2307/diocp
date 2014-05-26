program JSonStreamTester;

uses
  Forms,
  ufrmMain in 'ufrmMain.pas' {Form1},
  JSonStream in '..\Common\JSonStream.pas',
  superobject in '..\Common\superobject.pas',
  uJSonStreamTools in '..\Common\uJSonStreamTools.pas',
  uCRCTools in '..\Common\uCRCTools.pas',
  uNetworkTools in '..\..\iocp-Projects\MyEmail\Source\DIOCP\Tools\IOCPCoder\uNetworkTools.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
