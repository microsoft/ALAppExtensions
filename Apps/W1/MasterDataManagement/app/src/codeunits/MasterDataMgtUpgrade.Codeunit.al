namespace Microsoft.Integration.MDM;

using Microsoft.Integration.SyncEngine;
using System.Upgrade;

/// <summary>
/// Codeunit Master Data Mgt. Upgrade (ID 7238).
/// </summary>
codeunit 7238 "Master Data Mgt. Upgrade"
{
    Access = Internal;
    Permissions = tabledata "Integration Field Mapping" = rimd,
                  tabledata "Integration Table Mapping" = rimd;

    internal procedure UpgradeSynchTableCaptions()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataMgtSetupDefault: Codeunit "Master Data Mgt. Setup Default";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetSynchTableCaptionUpgradeTag()) then
            exit;

        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        if IntegrationTableMapping.FindSet() then
            repeat
                if IntegrationTableMapping."Table Caption" = '' then begin
                    IntegrationTableMapping."Table Caption" := MasterDataMgtSetupDefault.GetTableCaption(IntegrationTableMapping."Table ID");
                    IntegrationTableMapping.Modify();
                end
            until IntegrationTableMapping.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetSynchTableCaptionUpgradeTag());
    end;


    local procedure GetSynchTableCaptionUpgradeTag(): Code[250]
    begin
        exit('MS-490934-MDMSynchTableCaption-20231125');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetSynchTableCaptionUpgradeTag());
    end;
}