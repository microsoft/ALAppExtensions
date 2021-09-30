codeunit 31241 "Upgrade Application CZF"
{
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZF: Codeunit "Upgrade Tag Definitions CZF";
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";

    trigger OnUpgradePerDatabase()
    var
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        SetCompanyUpgradeTags();
    end;

    local procedure SetDatabaseUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZF.GetDataVersion180PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZF.GetDataVersion180PerDatabaseUpgradeTag());
    end;

    local procedure SetCompanyUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZF.GetDataVersion180PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZF.GetDataVersion180PerCompanyUpgradeTag());
    end;
}
