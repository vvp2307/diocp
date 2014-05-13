unit uAppTools;

interface

uses
  Forms, Classes, SysUtils, Windows;

type
  TAppTools = class(TObject)
  public
    class procedure HideApplication; 
    class procedure showApplication;
  end;

implementation

class procedure TAppTools.HideApplication;
begin
  if (Application.MainForm <> nil) then
  begin
    ShowWindow(Application.MainForm.Handle, sw_Hide )
  end else
  begin
    ShowWindow(Application.Handle, sw_Hide );
  end;
end;

class procedure TAppTools.showApplication;
begin
  if (Application.MainForm <> nil) then
  begin
    ShowWindow( Application.MainForm.Handle, sw_Restore );
    SetForegroundWindow( Application.MainForm.Handle );
  end else
  begin
    ShowWindow( Application.Handle, sw_Restore );
    SetForegroundWindow( Application.Handle );
  end;
end;

end.
