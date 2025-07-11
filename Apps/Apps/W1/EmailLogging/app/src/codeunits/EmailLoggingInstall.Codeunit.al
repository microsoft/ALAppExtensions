namespace Microsoft.CRM.EmailLoggin;

using System.Upgrade;

codeunit 1689 "Email Logging Install"
{
    SubType = Install;

    trigger OnInstallAppPerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        EmailLoggingUpgrade: Codeunit "Email Logging Upgrade";
    begin
        if UpgradeTag.HasUpgradeTag(EmailLoggingUpgrade.GetEmailLoggingUpgradeTag()) then
            exit;

        EmailLoggingUpgrade.DisableEmailLoggingUsingEWS();

        UpgradeTag.SetUpgradeTag(EmailLoggingUpgrade.GetEmailLoggingUpgradeTag());
    end;
}