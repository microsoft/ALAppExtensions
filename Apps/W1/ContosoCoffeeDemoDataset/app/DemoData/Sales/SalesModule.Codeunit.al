codeunit 5181 "Sales Module" implements "Contoso Demo Data Module"
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
        Dependencies.Add(Enum::"Contoso Demo Data Module"::CRM);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Bank);
        Dependencies.Add(Enum::"Contoso Demo Data Module"::Inventory);
    end;

    procedure CreateSetupData()
    begin
        Codeunit.Run(codeunit::"Create Customer Posting Group");
        Codeunit.Run(codeunit::"Create Finance Charge Terms");
        Codeunit.Run(codeunit::"Create Reminder Terms");
        Codeunit.Run(codeunit::"Create Reminder Level");
        Codeunit.Run(codeunit::"Create Reminder Text");
        Codeunit.Run(codeunit::"Create Sales Receivable Setup");
    end;

    procedure CreateMasterData()
    begin
        Codeunit.Run(codeunit::"Create Customer");
        Codeunit.Run(codeunit::"Create Customer Bank Account");
        Codeunit.Run(codeunit::"Create Customer Discount Group");
        Codeunit.Run(codeunit::"Create Customer Template");
        Codeunit.Run(codeunit::"Create Ship-to Address");
        Codeunit.Run(codeunit::"Create Sales Dimension Value");
    end;

    procedure CreateTransactionalData()
    begin
        Codeunit.Run(Codeunit::"Create Sales Document");
    end;

    procedure CreateHistoricalData()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        Codeunit.Run(Codeunit::"Create Posted Sales Data");
        Codeunit.Run(Codeunit::"Post Late Payment Entry");

        BankAccReconciliation.SetRange("Statement Type", Enum::"Bank Acc. Rec. Stmt. Type"::"Payment Application");
        if BankAccReconciliation.FindFirst() then
            Codeunit.Run(Codeunit::"Match Bank Pmt. Appl.", BankAccReconciliation);
    end;
}