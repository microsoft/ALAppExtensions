codeunit 5151 "Service Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        Page.Run(Page::"Service Module Setup");
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Common Module");
    end;

    procedure CreateSetupData()
    var
        ServiceModuleSetup: Record "Service Module Setup";
    begin
        ServiceModuleSetup.InitRecord();
        Codeunit.Run(Codeunit::"Create Svc GL Account");
        Codeunit.Run(Codeunit::"Create Svc No Series");
        Codeunit.Run(Codeunit::"Create Svc Location");
        Codeunit.Run(Codeunit::"Create Svc Setup");
        Codeunit.Run(Codeunit::"Create Svc Item Category");
        Codeunit.Run(Codeunit::"Create Svc Item Journal");
    end;

    procedure CreateMasterData()
    var
        ServiceModuleSetup: Record "Service Module Setup";
    begin
        ServiceModuleSetup.InitServiceDemoDataSetup();
        Codeunit.Run(Codeunit::"Create Svc Contract Template");
        Codeunit.Run(Codeunit::"Create Svc Loaner");
        Codeunit.Run(Codeunit::"Create Svc Item");
        Codeunit.Run(Codeunit::"Create Svc Resource");
        Codeunit.Run(Codeunit::"Create Svc Fault");
        Codeunit.Run(Codeunit::"Create Svc Status");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Svc Item Jnl Lines");
        Codeunit.Run(Codeunit::"Create Svc Sales Orders");
    end;

    procedure CreateHistoricalData()
    begin
        exit;
    end;
}