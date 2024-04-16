codeunit 5218 "Sustainability Module" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
        exit;
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Common Module");
    end;

    procedure CreateSetupData()
    begin
        Codeunit.Run(Codeunit::"Create Sustainability Setup");
        Codeunit.Run(Codeunit::"Create Sustain. No Series");
        Codeunit.Run(Codeunit::"Create Sustainability Category");
        Codeunit.Run(Codeunit::"Create Sustain. Subcategory");
        Codeunit.Run(Codeunit::"Create Sustainability Account");
        Codeunit.Run(Codeunit::"Create Sustain. Jnl. Setup");
    end;

    procedure CreateMasterData()
    begin
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Sustainability Journal");
    end;

    procedure CreateHistoricalData()
    begin
        Codeunit.Run(Codeunit::"Create Sustainability Entry");
    end;
}