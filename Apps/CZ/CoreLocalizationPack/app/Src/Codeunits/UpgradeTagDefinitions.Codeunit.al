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
        PerDatabaseUpgradeTags.Add(GetReplaceAllowAlterPostingGroupsPermissionUpgradeTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetDataVersion174PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion180PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion183PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion189PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetDataVersion200PerCompanyUpgradeTag());
        PerCompanyUpgradeTags.Add(GetReportBlanketPurchaseOrderCZUpgradeTag());
        PerCompanyUpgradeTags.Add(GetReplaceVATDateCZLVATEntriesUpgradeTag());
        PerCompanyUpgradeTags.Add(GetReplaceVATDateCZLGLEntriesUpgradeTag());
        PerCompanyUpgradeTags.Add(GetReplaceVATDateCZLSalesUpgradeTag());
        PerCompanyUpgradeTags.Add(GetReplaceVATDateCZLPurchaseUpgradeTag());
        PerCompanyUpgradeTags.Add(GetReplaceVATDateCZLServiceUpgradeTag());
        PerCompanyUpgradeTags.Add(GetReplaceVATDateCZLSetupUpgradeTag());
        PerCompanyUpgradeTags.Add(GetReplaceAllowAlterPostingGroupsUpgradeTag());
        PerCompanyUpgradeTags.Add(GetUseW1RegistrationNumberUpgradeTag());
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

    procedure GetReportBlanketPurchaseOrderCZUpgradeTag(): Code[250]
    begin
        exit('CZL-460438-ReportBlanketPurchaseOrderCZ-20230112');
    end;

    procedure GetReplaceVATDateCZLVATEntriesUpgradeTag(): Code[250]
    begin
        exit('CZL-461982-ReplaceVATDateCZLVATEntriesUpgrade-20230203');
    end;

    procedure GetReplaceVATDateCZLGLEntriesUpgradeTag(): Code[250]
    begin
        exit('CZL-461982-ReplaceVATDateCZLGLEntriesUpgrade-20230203');
    end;

    procedure GetReplaceVATDateCZLSalesUpgradeTag(): Code[250]
    begin
        exit('CZL-461982-ReplaceVATDateCZLSalesUpgrade-20230203');
    end;

    procedure GetReplaceVATDateCZLPurchaseUpgradeTag(): Code[250]
    begin
        exit('CZL-461982-ReplaceVATDateCZLPurchaseUpgrade-20230203');
    end;

    procedure GetReplaceVATDateCZLServiceUpgradeTag(): Code[250]
    begin
        exit('CZL-461982-ReplaceVATDateCZLServiceUpgrade-20230203');
    end;

    procedure GetReplaceVATDateCZLSetupUpgradeTag(): Code[250]
    begin
        exit('CZL-461982-ReplaceVATDateCZLSetupUpgrade-20230203');
    end;

    procedure GetReplaceAllowAlterPostingGroupsUpgradeTag(): Code[250]
    begin
        exit('CZL-463956-ReplaceAllowAlterPostingGroupsUpgrade-20230217');
    end;

    procedure GetReplaceAllowAlterPostingGroupsPermissionUpgradeTag(): Code[250]
    begin
        exit('CZL-463956-ReplaceAllowAlterPostingGroupsPermissionUpgrade-20230217');
    end;

    procedure GetUseW1RegistrationNumberUpgradeTag(): Code[250]
    begin
        exit('CZL-471081-UseW1RegistrationNumberUpgrade-20230217');
    end;
}
