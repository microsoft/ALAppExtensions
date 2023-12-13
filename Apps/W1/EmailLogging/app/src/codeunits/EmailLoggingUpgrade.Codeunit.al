namespace Microsoft.CRM.EmailLoggin;

using System.Upgrade;
#if not CLEAN22
using Microsoft.CRM.Outlook;
using System.Threading;
#endif
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
#if not CLEAN22
        JobQueueEntry: Record "Job Queue Entry";
#endif
        EmailLoggingManagement: Codeunit "Email Logging Management";
    begin
        if MarketingSetup.Get() then
            if MarketingSetup."Email Logging Enabled" then
                MarketingSetup.Validate("Email Logging Enabled", false);

#if not CLEAN22
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Email Logging Context Adapter");
        JobQueueEntry.DeleteTasks();
#endif

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