codeunit 31261 "Upgrade Tag Definitions CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetDataVersion180PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion182PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion183PerDatabaseUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetDataVersion180PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion182PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion183PerCompanyUpgradeTag());
    end;

    procedure GetDataVersion180PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerDatabase-18.0');
    end;

    procedure GetDataVersion182PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerDatabase-18.2');
    end;

    procedure GetDataVersion183PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerDatabase-18.3');
    end;

    procedure GetDataVersion180PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerCompany-18.0');
    end;

    procedure GetDataVersion182PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerCompany-18.2');
    end;

    procedure GetDataVersion183PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZA-UpgradeAdvancedLocalizationPackForCzech-PerCompany-18.3');
    end;
}
