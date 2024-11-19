codeunit 10827 "Create ES General Ledger Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGeneralLedgerSetup();
    end;

    local procedure UpdateGeneralLedgerSetup()
    var
        Currency: Record Currency;
        CreateCurrency: Codeunit "Create Currency";
    begin
        Currency.Get(CreateCurrency.EUR());
        ValidateRecordFields(CreateCurrency.EUR(), LocalCurrencySymbolLbl, Currency.Description, 0.001, '2:5');
    end;

    local procedure ValidateRecordFields(LCYCode: Code[10]; LocalCurrencySymbol: Text[10]; LocalCurrencyDescription: Text[60]; UnitAmountRoundingPrecision: Decimal; UnitAmountDecimalPlaces: Text[5])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CreateESNoSeries: Codeunit "Create ES No. Series";
    begin
        GeneralLedgerSetup.Get();

        GeneralLedgerSetup.Validate("LCY Code", LCYCode);
        GeneralLedgerSetup.Validate("Local Currency Symbol", LocalCurrencySymbol);
        GeneralLedgerSetup.Validate("Local Currency Description", LocalCurrencyDescription);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := UnitAmountRoundingPrecision;
        GeneralLedgerSetup.Validate("Show Amounts", GeneralLedgerSetup."Show Amounts"::"Debit/Credit Only");
        GeneralLedgerSetup.Validate("Autoinvoice Nos.", CreateESNoSeries.AutoInvoice());
        GeneralLedgerSetup.Validate("Autocredit Memo Nos.", CreateESNoSeries.AutoCreditMemo());
        GeneralLedgerSetup.Validate("Unit-Amount Decimal Places", UnitAmountDecimalPlaces);
        GeneralLedgerSetup.Validate("EMU Currency", true);
        GeneralLedgerSetup.Modify(true);
    end;

    var
        LocalCurrencySymbolLbl: Label '€', Locked = true;
}