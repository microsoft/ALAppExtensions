codeunit 10712 "Create General Ledger Setup NO"
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
        Currency.Get(CreateCurrency.NOK());
        ValidateRecordFields(CreateCurrency.NOK(), LocalCurrencySymbolLbl, Currency.Description, 0.001);
    end;

    local procedure ValidateRecordFields(LCYCode: Code[10]; LocalCurrencySymbol: Text[10]; LocalCurrencyDescription: Text[60]; UnitAmountRoundingPrecision: Decimal)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("LCY Code", LCYCode);
        GeneralLedgerSetup.Validate("Local Currency Symbol", LocalCurrencySymbol);
        GeneralLedgerSetup.Validate("Local Currency Description", LocalCurrencyDescription);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := UnitAmountRoundingPrecision;
        GeneralLedgerSetup.Modify(true);
    end;

    var
        LocalCurrencySymbolLbl: Label 'kr', Locked = true;
}