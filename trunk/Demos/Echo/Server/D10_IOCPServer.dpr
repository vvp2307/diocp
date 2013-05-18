program D10_IOCPServer;

uses
  FastMM4,
  FastMM4Messages,
  Forms,
  ufrmMain in 'ufrmMain.pas' {frmMain},
  uClientContext in 'Handler\uClientContext.pas',
  TesterINfo in 'Handler\TesterINfo.pas',
  uIOCPJSonStreamDecoder in '..\..\IOCPCoder\uIOCPJSonStreamDecoder.pas',
  uIOCPJSonStreamEncoder in '..\..\IOCPCoder\uIOCPJSonStreamEncoder.pas',
  JSonStream in '..\..\Common\JSonStream.pas',
  superobject in '..\..\Common\superobject.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
