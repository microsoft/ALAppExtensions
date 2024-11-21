codeunit 17143 "Create NZ General Ledger Setup"
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

        GeneralLedgerSetup.Validate("Local Address Format", GeneralLedgerSetup."Local Address Format"::"City+County+Post Code (no comma)");
        GeneralLedgerSetup.Validate("Enable IRD No.", true);
        GeneralLedgerSetup.Validate("Enable VAT Registration No.", true);
        GeneralLedgerSetup.Validate("LCY Code", LCYCodeLbl);
        GeneralLedgerSetup.Validate("Local Currency Description", LCYDescriptionLbl);
        GeneralLedgerSetup.Validate("Local Currency Symbol", '$');
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup.Modify(true);
    end;

    var
        LCYDescriptionLbl: Label 'New Zealand dollar', MaxLength = 60;
        LCYCodeLbl: Label 'NZD', MaxLength = 10;
}