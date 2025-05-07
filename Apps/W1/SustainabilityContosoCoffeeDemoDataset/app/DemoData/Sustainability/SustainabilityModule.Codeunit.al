#pragma warning disable AA0247
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
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Foundation);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Finance");
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Purchase);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Sales);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::"Statistical Module");
    end;

    procedure CreateSetupData()
    begin
        Codeunit.Run(Codeunit::"Create Sustainability Setup");
        Codeunit.Run(Codeunit::"Create Sustain. No Series");
        Codeunit.Run(Codeunit::"Create Sustainability Category");
        Codeunit.Run(Codeunit::"Create Sustain. Subcategory");
        Codeunit.Run(Codeunit::"Create Sustainability Account");
        Codeunit.Run(Codeunit::"Create Sustain. Jnl. Setup");
        Codeunit.Run(Codeunit::"Create Emission Fee");
        Codeunit.Run(Codeunit::"Create Sust. Scorecard");
        Codeunit.Run(Codeunit::"Create Sust. Goal");
        Codeunit.Run(Codeunit::"Create Sust. Acc. Sch. Name");
        Codeunit.Run(Codeunit::"Create Sust. Acc. Sch. Line");
        Codeunit.Run(Codeunit::"Create Sust. Column Layout");
        Codeunit.Run(Codeunit::"Create Sust. Financial Report");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create Sust. Vendor");
        Codeunit.Run(Codeunit::"Create Sust Item Category");
        Codeunit.Run(Codeunit::"Create Sust. Item");
        Codeunit.Run(Codeunit::"Create Sust. Responsibility");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Sustainability Journal");
        Codeunit.Run(Codeunit::"Create Sust. Purchase");
    end;

    procedure CreateHistoricalData()
    begin
        Codeunit.Run(Codeunit::"Create Sustainability Entry");
    end;
}
