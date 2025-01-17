namespace Microsoft.CRM.EmailLoggin;

using System.Upgrade;
using Microsoft.CRM.Setup;

codeunit 1688 "Email Logging Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeEmailLogging();
    end;

    local procedure UpgradeEmailLogging()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetEmailLoggingUpgradeTag()) then
            exit;

        DisableEmailLoggingUsingEWS();

        UpgradeTag.SetUpgradeTag(GetEmailLoggingUpgradeTag());
    end;

    internal procedure DisableEmailLoggingUsingEWS()
    var
        MarketingSetup: Record "Marketing Setup";
        EmailLoggingManagement: Codeunit "Email Logging Management";
    begin
        if MarketingSetup.Get() then
            if MarketingSetup."Email Logging Enabled" then
                MarketingSetup.Validate("Email Logging Enabled", false);

        EmailLoggingManagement.RegisterAssistedSetup();
    end;

    internal procedure GetEmailLoggingUpgradeTag(): Code[250]
    begin
        exit('MS-461765-GetEmailLoggingUpgradeTag-20230201');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetEmailLoggingUpgradeTag()) then
            PerCompanyUpgradeTags.Add(GetEmailLoggingUpgradeTag());
    end;
}