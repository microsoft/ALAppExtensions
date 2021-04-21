codeunit 31332 "Upgrade Application CZB"
{
    Subtype = Upgrade;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZB: Codeunit "Upgrade Tag Definitions CZB";

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion180PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion180PerDatabaseUpgradeTag());
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion180PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZB.GetDataVersion180PerCompanyUpgradeTag());
    end;
}
