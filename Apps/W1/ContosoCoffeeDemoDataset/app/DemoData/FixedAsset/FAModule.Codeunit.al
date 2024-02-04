codeunit 4774 "FA Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        Page.Run(Page::"FA Module Setup");
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Common Module");
    end;

    procedure CreateSetupData()
    var
        FAModuleSetup: Record "FA Module Setup";
    begin
        FAModuleSetup.InitRecord();
        Codeunit.Run(Codeunit::"Create FA GL Account");
        Codeunit.Run(Codeunit::"Create FA Posting Group");
        Codeunit.Run(Codeunit::"Create FA Class");
        Codeunit.Run(Codeunit::"Create FA Location");
        Codeunit.Run(Codeunit::"Create FA No Series");
        Codeunit.Run(Codeunit::"Create FA Depreciation Book");
        Codeunit.Run(Codeunit::"Create FA Setup");
        Codeunit.Run(Codeunit::"Create FA Jnl. Template");
        Codeunit.Run(Codeunit::"Create FA Ins Jnl. Template");
        Codeunit.Run(Codeunit::"Create FA Jnl. Setup");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create FA Maintenance");
        Codeunit.Run(Codeunit::"Create Fixed Asset");
        Codeunit.Run(Codeunit::"Create FA Insurance Type");
        Codeunit.Run(Codeunit::"Create FA Insurance");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create FA Maint. Registration");
    end;

    procedure CreateHistoricalData()
    begin
        exit;
    end;
}