codeunit 11147 "Create General Ledger Setup AT"
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
        GeneralLedgerSetup.Validate("LCY Code", CreateCurrency.EUR());
        GeneralLedgerSetup.Validate("Currency Code For EURO", '');
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup.Validate("Local Currency Symbol", LocalCurrencySymbolLbl);
        GeneralLedgerSetup.Validate("Local Currency Description", LocalCurrecyEuroLbl);
        GeneralLedgerSetup."Adjust for Payment Disc." := false;
        GeneralLedgerSetup."Prepayment Unrealized VAT" := false;
        GeneralLedgerSetup.Modify(true);
    end;

    var
        LocalCurrecyEuroLbl: Label 'Euro', MaxLength = 60;
        LocalCurrencySymbolLbl: Label '€', MaxLength = 10;
}