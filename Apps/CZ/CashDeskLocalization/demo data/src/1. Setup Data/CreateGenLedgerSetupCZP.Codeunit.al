#pragma warning disable AA0247
codeunit 31343 "Create Gen. Ledger Setup CZP"
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
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Cash Desk Nos. CZP", CreateNoSeriesCZ.CashDesk());
        GeneralLedgerSetup.Modify(true);
    end;
}
