#pragma warning disable AL0432
codeunit 31107 "Upgrade Application CZP"
{
    Subtype = Upgrade;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZP: Codeunit "Upgrade Tag Definitions CZP";

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerDatabaseUpgradeTag());
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();

        UpdateCashDocumentLine();

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag());
    end;

    [Obsolete('Moved to Cash Desk Localization for Czech.', '18.0')]
    local procedure UpdateCashDocumentLine();
    var
        CashDocumentLine: Record "Cash Document Line";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZP.GetDataVersion173PerCompanyUpgradeTag()) then
            exit;

        GeneralLedgerSetup.Get();
        if CashDocumentLine.FindSet() then
            repeat
                if CashDocumentLineCZP.Get(CashDocumentLine."Cash Desk No.", CashDocumentLine."Cash Document No.", CashDocumentLine."Line No.") then begin
                    if GeneralLedgerSetup."Prepayment Type" = GeneralLedgerSetup."Prepayment Type"::Advances then
                        if CashDocumentLine.Prepayment then
                            CashDocumentLineCZP."Advance Letter Link Code" := CashDocumentLine."Advance Letter Link Code";
                    CashDocumentLineCZP.Modify(false);
                end;
            until CashDocumentLine.Next() = 0;
    end;
}
