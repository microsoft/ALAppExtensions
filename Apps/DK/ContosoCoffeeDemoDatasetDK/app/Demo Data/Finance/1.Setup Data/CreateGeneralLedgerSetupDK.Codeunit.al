codeunit 13739 "Create General Ledger Setup DK"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGeneralLedgerSetup();
    end;

    local procedure UpdateGeneralLedgerSetup()
    var
        CreateCurrency: Codeunit "Create Currency";
    begin
        ValidateRecordFields(CreateCurrency.DKK(), 0.001, true);
    end;

    local procedure ValidateRecordFields(LCYCode: Code[10]; UnitAmountRoundingPrecision: Decimal; DataCheck: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Local Currency Symbol", '');
        GeneralLedgerSetup.Validate("Local Currency Description", '');
        GeneralLedgerSetup.Validate("LCY Code", LCYCode);
        GeneralLedgerSetup.Validate("Enable Data Check", DataCheck);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := UnitAmountRoundingPrecision;
        GeneralLedgerSetup.Modify(true);
    end;
}
