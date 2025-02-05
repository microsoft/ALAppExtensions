codeunit 12168 "Create General Ledger Setup IT"
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
        GeneralLedgerSetup.Validate("Show Amounts", GeneralLedgerSetup."Show Amounts"::"Debit/Credit Only");
        GeneralLedgerSetup.Validate("Use Document Date in Currency", true);
        GeneralLedgerSetup.Validate("Local Currency Symbol", '€');
        GeneralLedgerSetup.Validate("Local Currency Description", EuroLbl);
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup.Modify(true);
    end;

    var
        EuroLbl: Label 'Euro', MaxLength = 60;
}