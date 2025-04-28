#pragma warning disable AA0247
codeunit 5275 "Statistical Account Module" implements "Contoso Demo Data Module"
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
        Codeunit.Run(Codeunit::"Create Statistical Account");
        Codeunit.Run(Codeunit::"Create Statistical Jnl. Setup");
    end;

    procedure CreateMasterData()
    begin
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Statistical Journal");
    end;

    procedure CreateHistoricalData()
    begin
        Codeunit.Run(Codeunit::"Create Statistical Entry");
    end;
}
