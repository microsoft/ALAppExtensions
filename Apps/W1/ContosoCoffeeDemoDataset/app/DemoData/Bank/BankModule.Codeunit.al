codeunit 5635 "Bank Module" implements "Contoso Demo Data Module"
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
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Finance);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::CRM);
    end;

    procedure CreateSetupData()
    begin
        Codeunit.Run(Codeunit::"Create Bank Acc. Posting Grp");
        Codeunit.Run(Codeunit::"Create Bank Ex/Import Setup");
        Codeunit.Run(Codeunit::"Create Payment Method");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(Codeunit::"Create Bank Account");
        Codeunit.Run(Codeunit::"Create Bank Jnl. Batches");
        Codeunit.Run(Codeunit::"Create Payment Reg. Setup");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Gen. Journal Line");
    end;

    procedure CreateHistoricalData()
    begin
        Codeunit.Run(Codeunit::"Create Bank Acc. Rec.");
        Codeunit.Run(Codeunit::"Post Bank Payment Entry");
    end;
}