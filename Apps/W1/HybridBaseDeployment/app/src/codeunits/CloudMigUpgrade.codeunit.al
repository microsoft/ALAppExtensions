namespace Microsoft.DataMigration;

using System.Upgrade;

codeunit 40010 "Cloud Mig. Upgrade"
{
    Subtype = Upgrade;
    trigger OnRun()
    begin

    end;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if UpgradeTag.HasUpgradeTag(GetSendCloudMigrationUpgradeTelemetryTag()) then
            exit;

        HybridCloudManagement.SendCloudMigrationTelemetry();

        UpgradeTag.SetUpgradeTag(GetSendCloudMigrationUpgradeTelemetryTag());
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetSendCloudMigrationUpgradeTelemetryTag());
    end;

    local procedure GetSendCloudMigrationUpgradeTelemetryTag(): Text[250]
    begin
        exit('MS-456494-CloudMigrationUptake-20230425');
    end;
}