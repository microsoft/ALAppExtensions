#pragma warning disable AA0247
codeunit 31344 "Adv. Pmt. Contoso Module CZZ" implements "Contoso Demo Data Module"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure RunConfigurationPage()
    begin
    end;

    procedure GetDependencies() Dependencies: List of [enum "Contoso Demo Data Module"]
    begin
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Foundation);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Finance);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Bank);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Sales);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Purchase);
    end;

    procedure CreateSetupData()
    begin
        Codeunit.Run(Codeunit::"Create Adv. Letter Temp. CZZ");
    end;

    procedure CreateMasterData()
    begin
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Adv. Letter CZZ");
    end;

    procedure CreateHistoricalData()
    begin
        Codeunit.Run(Codeunit::"Create Posted Adv.Let.Data CZZ");
    end;
}
