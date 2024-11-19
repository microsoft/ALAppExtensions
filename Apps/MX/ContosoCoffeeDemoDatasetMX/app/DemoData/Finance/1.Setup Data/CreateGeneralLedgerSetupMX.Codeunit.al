codeunit 14106 "Create General Ledger Setup MX"
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

        GeneralLedgerSetup.Validate("Unrealized VAT", true);
        GeneralLedgerSetup.Validate("Local Address Format", GeneralLedgerSetup."Local Address Format"::"Post Code+City+County");
        GeneralLedgerSetup.Validate("LCY Code", CreateCurrency.MXN());
        GeneralLedgerSetup.Validate("Local Currency Symbol", '$');
        GeneralLedgerSetup.Validate("Local Currency Description", MexicanPesoLbl);
        GeneralLedgerSetup.Validate("VAT in Use", true);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup.Modify(true);
    end;

    var
        MexicanPesoLbl: Label 'Mexican peso', MaxLength = 60;
}