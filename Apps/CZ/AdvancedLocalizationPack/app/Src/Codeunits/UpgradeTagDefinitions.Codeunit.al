codeunit 31261 "Upgrade Tag Definitions CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetDataVersion180PerDatabaseUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetDataVersion180PerCompanyUpgradeTag());
    end;

    procedure GetDataVersion180PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerDatabase-18.0');
    end;

    procedure GetDataVersion180PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerCompany-18.0');
    end;
}
