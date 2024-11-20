codeunit 11485 "Create General Ledger Setup US"
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
        // Currency: Record Currency;
        CreateCurrency: Codeunit "Create Currency";
    begin
        GeneralLedgerSetup.Get();

        GeneralLedgerSetup.Validate("Adjust for Payment Disc.", true);
        GeneralLedgerSetup.Validate("Local Address Format", GeneralLedgerSetup."Local Address Format"::"City+County+Post Code");
        GeneralLedgerSetup.Validate("Local Currency Symbol", '');
        GeneralLedgerSetup.Validate("Local Currency Description", '');
        GeneralLedgerSetup.Validate("LCY Code", CreateCurrency.USD());
        GeneralLedgerSetup.Validate("Max. VAT Difference Allowed", 10);
        GeneralLedgerSetup.Validate("Payment Tolerance %", 0.1);
        GeneralLedgerSetup.Validate("Max. Payment Tolerance Amount", 1);
        // Currency.Get(GeneralLedgerSetup."LCY Code");
        // GeneralLedgerSetup.Validate("Enable Data Check", true);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        // GeneralLedgerSetup.Validate("VAT in Use", false);
        // GeneralLedgerSetup.Validate("Send PDF Report", false);
        GeneralLedgerSetup.Modify(true);
    end;
}