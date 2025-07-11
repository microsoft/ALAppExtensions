#if not CLEAN27
/// <summary>
/// Reports GB Feature will be moved to a separate app.
/// </summary>
namespace Microsoft.Finance.VAT.Setup;

using System.Environment.Configuration;
using System.Reflection;
using Microsoft.Sales.Reports;
using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Reports;
using System.Upgrade;

codeunit 10580 "Feature - Reports GB" implements "Feature Data Update"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

    var
        UpgTagReportsGB: Codeunit "Upg. Tag Reports GB";
        ReportsGBApplicationAppIdTok: Label '{a4417920-02d4-47fc-b6d2-3bcfdfe1e798}', Locked = true;
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
        StartDateTime: DateTime;
        EndDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'Upgrade Reports GB', StartDateTime);
        SetDefaultReportLayouts();
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

    procedure SetDefaultReportLayouts()
    begin
        SetDefaultReportLayout(Report::"Sales Document - Test");
        SetDefaultReportLayout(Report::"Purchase Document - Test");
    end;

    local procedure SetDefaultReportLayout(ReportID: Integer)
    var
        SelectedReportLayoutList: Record "Report Layout List";
    begin
        SelectedReportLayoutList.SetRange("Report ID", ReportID);
        SelectedReportLayoutList.SetRange(Name, 'GBlocalizationLayout');
        SelectedReportLayoutList.SetRange("Application ID", ReportsGBApplicationAppIdTok);
        if SelectedReportLayoutList.FindFirst() then
            SetDefaultReportLayoutSelection(SelectedReportLayoutList);
        SelectedReportLayoutList.Reset();
    end;

    local procedure SetDefaultReportLayoutSelection(SelectedReportLayoutList: Record "Report Layout List")
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomDimensions: Dictionary of [Text, Text];
        EmptyGuid: Guid;
        SelectedCompany: Text[30];
    begin
        SelectedCompany := CopyStr(CompanyName, 1, MaxStrLen(SelectedCompany));
        AddLayoutSelection(SelectedReportLayoutList, EmptyGuid, SelectedCompany);
        if ReportLayoutSelection.get(SelectedReportLayoutList."Report ID", SelectedCompany) then begin
            ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
            ReportLayoutSelection.Modify(true);
        end else begin
            ReportLayoutSelection."Report ID" := SelectedReportLayoutList."Report ID";
            ReportLayoutSelection."Company Name" := SelectedCompany;
            ReportLayoutSelection."Custom Report Layout Code" := '';
            ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
            ReportLayoutSelection.Insert(true);
        end;

        InitReportLayoutListDimensions(SelectedReportLayoutList, CustomDimensions);
        AddReportLayoutDimensionsAction('SetDefault', CustomDimensions);
    end;

    local procedure AddLayoutSelection(SelectedReportLayoutList: Record "Report Layout List"; UserId: Guid; SelectedCompany: Text[30]): Boolean
    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
    begin
        TenantReportLayoutSelection.Init();
        TenantReportLayoutSelection."App ID" := SelectedReportLayoutList."Application ID";
        TenantReportLayoutSelection."Company Name" := SelectedCompany;
        TenantReportLayoutSelection."Layout Name" := SelectedReportLayoutList."Name";
        TenantReportLayoutSelection."Report ID" := SelectedReportLayoutList."Report ID";
        TenantReportLayoutSelection."User ID" := UserId;

        if not TenantReportLayoutSelection.Insert(true) then
            TenantReportLayoutSelection.Modify(true);
    end;

    local procedure GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList: Record "Report Layout List"): Integer
    begin
        case SelectedReportLayoutList."Layout Format" of

            SelectedReportLayoutList."Layout Format"::RDLC:
                exit(0);
            SelectedReportLayoutList."Layout Format"::Word:
                exit(1);
            SelectedReportLayoutList."Layout Format"::Excel:
                exit(3);
            SelectedReportLayoutList."Layout Format"::Custom:
                exit(4);
        end
    end;

    local procedure InitReportLayoutListDimensions(ReportLayoutList: Record "Report Layout List"; var CustomDimensions: Dictionary of [Text, Text])
    begin
        CustomDimensions.Set('ReportId', Format(ReportLayoutList."Report ID"));
        CustomDimensions.Set('LayoutName', ReportLayoutList."Name");
    end;

    local procedure AddReportLayoutDimensionsAction(Action: Text; var CustomDimensions: Dictionary of [Text, Text])
    begin
        CustomDimensions.Add('Action', Action);
    end;
}
#endif