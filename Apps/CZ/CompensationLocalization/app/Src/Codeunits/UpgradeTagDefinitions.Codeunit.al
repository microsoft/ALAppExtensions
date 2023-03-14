codeunit 31264 "Upgrade Tag Definitions CZC"
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
        PerCompanyUpgradeTags.Add(GetCompensationLanguageCodeUpgradeTag());
        PerCompanyUpgradeTags.Add(GetPostedCompensationLanguageCodeUpgradeTag());
    end;

    procedure GetDataVersion180PerDatabaseUpgradeTag(): Code[250]
    begin
        exit('CZC-CompensationLocalizationForCzech-PerDatabase-18.0');
    end;

    procedure GetDataVersion180PerCompanyUpgradeTag(): Code[250]
    begin
        exit('CZC-CompensationLocalizationForCzech-PerCompany-18.0');
    end;

    internal procedure GetCompensationLanguageCodeUpgradeTag(): Code[250]
    begin
        exit('CZC-434074-CompensationLanguageCode-20220427');
    end;

    internal procedure GetPostedCompensationLanguageCodeUpgradeTag(): Code[250]
    begin
        exit('CZC-434074-PostedCompensationLanguageCode-20220427');
    end;
}
