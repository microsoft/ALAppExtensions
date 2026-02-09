#if not CLEAN27
/// <summary>
/// Reports GB Feature will be moved to a separate app.
/// </summary>
namespace Microsoft.Finance.VAT.Setup;

using System.Environment.Configuration;
using System.Upgrade;

codeunit 10580 "Feature - Reports GB" implements "Feature Data Update"
{
    Access = Internal;
    Permissions = TableData "Feature Data Update Status" = rm;
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

    var
        UpgTagReportsGB: Codeunit "Upg. Tag Reports GB";
        DescriptionTxt: Label 'Report layouts will be updated to contain GB localization functionality';

    procedure IsDataUpdateRequired(): Boolean
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagReportsGB.GetReportsGBUpgradeTag()) then
            exit(false);
        exit(true);
    end;

    procedure ReviewData()
    begin

    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        FeatureDataUpdateMgt: Codeunit "Feature Data Update Mgt.";
        ReportsGBHelperProcedures: Codeunit "Reports GB Helper Procedures";
        StartDateTime: DateTime;
        EndDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'Upgrade Reports GB', StartDateTime);
        ReportsGBHelperProcedures.SetDefaultReportLayouts();
        EndDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'Upgrade Reports GB', EndDateTime);
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        UpdateFeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        UpdateFeatureDataUpdateStatus.SetRange("Feature Key", FeatureDataUpdateStatus."Feature Key");
        UpdateFeatureDataUpdateStatus.SetFilter("Company Name", '<>%1', FeatureDataUpdateStatus."Company Name");
        UpdateFeatureDataUpdateStatus.ModifyAll("Feature Status", FeatureDataUpdateStatus."Feature Status");

        SetUpgradeTag(true);
    end;

    procedure GetTaskDescription() TaskDescription: Text
    begin
        TaskDescription := DescriptionTxt;
    end;

    local procedure SetUpgradeTag(DataUpgradeExecuted: Boolean)
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        // Set the upgrade tag to indicate that the data update is executed/skipped and the feature is enabled.
        // This is needed when the feature is enabled by default in a future version, to skip the data upgrade.
        if UpgradeTag.HasUpgradeTag(UpgTagReportsGB.GetReportsGBUpgradeTag()) then
            exit;

        UpgradeTag.SetUpgradeTag(UpgTagReportsGB.GetReportsGBUpgradeTag());
        if not DataUpgradeExecuted then
            UpgradeTag.SetSkippedUpgrade(UpgTagReportsGB.GetReportsGBUpgradeTag(), true);
    end;
}
#endif