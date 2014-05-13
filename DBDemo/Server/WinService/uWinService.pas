unit uWinService;

interface

uses
   SysUtils, Classes, Windows, SvcMgr, WinSvc, Forms, OSUtils, Messages;


type
  TWinService = class(TService)
  protected
    procedure Start(Sender: TService; var Started: boolean);
    procedure Stop(Sender: TService; var Stopped: boolean);
    procedure Execute(Sender: TService);
  public
    function GetServiceController: TServiceController; override;
    constructor CreateNew(AOwner: TComponent; Dummy: integer = 0); override;
    procedure CreateForm(InstanceClass: TComponentClass; var Reference);
    procedure Run;

    procedure DoTerminate;
  end;

var
  __ServiceInstance:TWinService;
  __ServiceName:String;
  __ServiceDisplayName:String;

procedure DoCreateServiceInstance;

implementation

uses
  ufrmMain; 

procedure ServiceController(CtrlCode: dword); stdcall;
begin
   __ServiceInstance.Controller(CtrlCode);
end;

procedure DoCreateServiceInstance;
begin
  __ServiceInstance := TWinService.CreateNew(SvcMgr.Application, 0);
end;


//------------------------------------------------------------------------------
function TWinService.GetServiceController: TServiceController;
begin
   result := ServiceController;
end;

//------------------------------------------------------------------------------
procedure TWinService.CreateForm(InstanceClass: TComponentClass; var Reference);
begin
   SvcMgr.Application.CreateForm(InstanceClass, Reference);
end;

//------------------------------------------------------------------------------
procedure TWinService.Run;
begin
   SvcMgr.Application.Run;
end;

//------------------------------------------------------------------------------
constructor TWinService.CreateNew(AOwner: TComponent; Dummy: integer);
begin
   inherited;
   AllowPause  := False;
   Interactive := True;
   DisplayName := __ServiceDisplayName;
   Name        := __ServiceName;
   OnStart     := Start;
   OnStop      := Stop;
end;

//------------------------------------------------------------------------------
procedure TWinService.Start(Sender: TService; var Started: boolean);
begin
  Started := True;
end;

//------------------------------------------------------------------------------
procedure TWinService.Execute(Sender: TService);
begin
  while not Terminated do ServiceThread.ProcessRequests(True);
end;

//------------------------------------------------------------------------------
procedure TWinService.Stop(Sender: TService; var Stopped: boolean);
begin
   Stopped := True;
end;

procedure TWinService.DoTerminate;
begin
  PostThreadMessage(ServiceThread.ThreadID, WM_QUIT, 0, 0)
end;

end.
