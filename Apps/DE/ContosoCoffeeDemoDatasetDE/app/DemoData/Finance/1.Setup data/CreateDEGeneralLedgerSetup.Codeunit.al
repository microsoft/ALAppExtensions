codeunit 11383 "Create DE General Ledger Setup"
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
        GeneralLedgerSetup.Validate("EMU Currency", true);
        GeneralLedgerSetup.Validate("Local Currency Symbol", '');
        GeneralLedgerSetup.Validate("Local Currency Description", '');
        GeneralLedgerSetup.Validate("LCY Code", CreateCurrency.EUR());
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup.Validate("Currency Code For EURO", CreateCurrency.EUR());
        GeneralLedgerSetup."Adjust for Payment Disc." := false;
        GeneralLedgerSetup.Validate("Prepayment Unrealized VAT", false);
        GeneralLedgerSetup.Modify(true);
    end;
}