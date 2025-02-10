codeunit 17148 "Create AU General Ledger Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGeneralLedgerSetup();
    end;

    local procedure UpdateGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CreateCurrency: Codeunit "Create Currency";
    begin
        GeneralLedgerSetup.Get();

        GeneralLedgerSetup.Validate("Adjustment Mandatory", true);
        GeneralLedgerSetup.Validate("Enable GST (Australia)", true);
        GeneralLedgerSetup.Validate("Full GST on Prepayment", true);
        GeneralLedgerSetup.Validate("Min. WHT Calc only on Inv. Amt", true);
        GeneralLedgerSetup.Validate("GST Report", true);
        GeneralLedgerSetup.Validate("LCY Code", CreateCurrency.AUD());
        GeneralLedgerSetup.Validate("Local Currency Symbol", '$');
        GeneralLedgerSetup.Validate("Local Currency Description", AustraliandollarLbl);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup.Validate("BAS GST Division Factor", 11);
        GeneralLedgerSetup.Validate("Enable WHT", true);
        GeneralLedgerSetup.Modify(true);
    end;

    var
        AustraliandollarLbl: Label 'Australian dollar', MaxLength = 60;
}