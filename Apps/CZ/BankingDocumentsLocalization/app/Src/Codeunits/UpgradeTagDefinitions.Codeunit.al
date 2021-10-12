codeunit 31333 "Upgrade Tag Definitions CZB"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetDataVersion190PerDatabaseUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetDataVersion190PerCompanyUpgradeTag());
    end;

    procedure GetDataVersion190PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZB-UpgradeBankingDocumentsLocalizationForCzech-PerDatabase-19.0');
    end;

    procedure GetDataVersion190PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZB-UpgradeBankingDocumentsLocalizationForCzech-PerCompany-19.0');
    end;
}
