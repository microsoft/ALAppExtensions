codeunit 31016 "Upgrade Tag Definitions CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetDataVersion174PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion180PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion183PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion189PerDatabaseUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetDataVersion200PerDatabaseUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetDataVersion174PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion180PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion183PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion189PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion200PerCompanyUpgradeTag());
    end;

    procedure GetDataVersion174PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZL-UpgradeCoreLocalizationPackForCzech-PerDatabase-17.4');
    end;

    procedure GetDataVersion180PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZL-UpgradeCoreLocalizationPackForCzech-PerDatabase-18.0');
    end;

    procedure GetDataVersion183PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZL-UpgradeCoreLocalizationPackForCzech-PerDatabase-18.3');
    end;

    procedure GetDataVersion189PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZL-UpgradeCoreLocalizationPackForCzech-PerDatabase-18.9');
    end;

    procedure GetDataVersion200PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZL-UpgradeCoreLocalizationPackForCzech-PerDatabase-20.0');
    end;

    procedure GetDataVersion174PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZL-UpgradeCoreLocalizationPackForCzech-PerCompany-17.4');
    end;

    procedure GetDataVersion180PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZL-UpgradeCoreLocalizationPackForCzech-PerCompany-18.0');
    end;

    procedure GetDataVersion183PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZL-UpgradeCoreLocalizationPackForCzech-PerCompany-18.3');
    end;

    procedure GetDataVersion189PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZL-UpgradeCoreLocalizationPackForCzech-PerCompany-18.9');
    end;

    procedure GetDataVersion200PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZL-UpgradeCoreLocalizationPackForCzech-PerCompany-20.0');
    end;
}
