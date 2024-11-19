codeunit 5296 "EService Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        Page.Run(Page::"EService Demo Data Setup");
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Finance);
    end;

    procedure CreateSetupData()
    var
        EServiceDemoDataSetup: Record "EService Demo Data Setup";
    begin
        EServiceDemoDataSetup.InitRecord();
        Codeunit.Run(codeunit::"Create Incoming Document Setup");
        Codeunit.Run(Codeunit::"Create Online Map Para. Setup");
        Codeunit.Run(Codeunit::"Create Online Map Setup");
    end;

    procedure CreateMasterData()
    begin
        exit;
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(codeunit::"Create Incoming Document");
    end;

    procedure CreateHistoricalData()
    begin
        exit;
    end;
}
