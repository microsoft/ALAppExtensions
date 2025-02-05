codeunit 10889 "Create General Ledger Setup FR"
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
        GeneralLedgerSetup.Validate("Local Currency Symbol", LocalCurrencySymbolLbl);
        GeneralLedgerSetup.Validate("Local Currency Description", LocalCurrecyEuroLbl);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup.Validate("Show Amounts", GeneralLedgerSetup."Show Amounts"::"Debit/Credit Only");
        GeneralLedgerSetup.Validate("Local Currency", GeneralLedgerSetup."Local Currency"::Euro);
        GeneralLedgerSetup.Modify(true);
    end;

    var
        LocalCurrecyEuroLbl: Label 'Euro', MaxLength = 60;
        LocalCurrencySymbolLbl: Label '€', MaxLength = 10;
}