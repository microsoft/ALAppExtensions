codeunit 10518 "Create GB General Ledger Setup"
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
    begin
        GeneralLedgerSetup.Get();

        GeneralLedgerSetup.Validate("Local Address Format", GeneralLedgerSetup."Local Address Format"::"City+County+Post Code");
        GeneralLedgerSetup.Validate("Hide Payment Method Code", true);
        GeneralLedgerSetup.Validate("Max. VAT Difference Allowed", 10);
        GeneralLedgerSetup.Validate("Payment Tolerance %", 0.1);
        GeneralLedgerSetup.Validate("Max. Payment Tolerance Amount", 1);
        GeneralLedgerSetup.Modify(true);
    end;
}