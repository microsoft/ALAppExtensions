#if not CLEAN27
/// <summary>
/// GovTalk Feature will be moved to a separate app.
/// </summary>
namespace Microsoft.Finance.VAT.GovTalk;

using System.Environment.Configuration;
using System.Upgrade;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Navigate;
using Microsoft.Finance.VAT.Reporting;
using System.Reflection;
using Microsoft.Foundation.Reporting;

codeunit 10526 "Feature - GovTalk" implements "Feature Data Update"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteReason = 'Feature GovTalk will be enabled by default in version 30.0.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

    var
        TempDocumentEntry: Record "Document Entry" temporary;
        GovTalkApplicationAppIdTok: Label '{80672d74-d90a-4eb0-8f90-5b9bcea58dca}', Locked = true;
        DescriptionTxt: Label 'Existing records in GB BaseApp fields will be copied to GovTalk App fields';

    procedure IsDataUpdateRequired(): Boolean;
    begin
        CountRecords();
        if TempDocumentEntry.IsEmpty() then begin
            SetUpgradeTag(false);
            exit(false);
        end;
        exit(true);
    end;

    procedure ReviewData();
    var
        DataUpgradeOverview: Page "Data Upgrade Overview";
    begin
        Commit();
        Clear(DataUpgradeOverview);
        DataUpgradeOverview.Set(TempDocumentEntry);
        DataUpgradeOverview.RunModal();
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

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    var
        FeatureDataUpdateMgt: Codeunit "Feature Data Update Mgt.";
        StartDateTime: DateTime;
        EndDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'Upgrade GovTalk', StartDateTime);
        UpgradeGovTalk();
        EndDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'Upgrade GovTalk', EndDateTime);
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
        TaskDescription := DescriptionTxt;
    end;

    local procedure CountRecords()
    var
        CompanyInfo: Record "Company Information";
        ECSLVATReportLine: Record "ECSL VAT Report Line";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        VATReportHeader: Record "VAT Report Header";
    begin
        TempDocumentEntry.Reset();
        TempDocumentEntry.DeleteAll();

        InsertDocumentEntry(Database::"Company Information", CompanyInfo.TableCaption, CompanyInfo.Count());
        InsertDocumentEntry(Database::"ECSL VAT Report Line", ECSLVATReportLine.TableCaption, ECSLVATReportLine.Count());
        InsertDocumentEntry(Database::"VAT Reports Configuration", VATReportsConfiguration.TableCaption, VATReportsConfiguration.Count());
        InsertDocumentEntry(Database::"VAT Report Header", VATReportHeader.TableCaption, VATReportHeader.Count());
    end;

    local procedure InsertDocumentEntry(TableID: Integer; TableName: Text; RecordCount: Integer)
    begin
        if RecordCount = 0 then
            exit;

        TempDocumentEntry.Init();
        TempDocumentEntry."Entry No." += 1;
        TempDocumentEntry."Table ID" := TableID;
        TempDocumentEntry."Table Name" := CopyStr(TableName, 1, MaxStrLen(TempDocumentEntry."Table Name"));
        TempDocumentEntry."No. of Records" := RecordCount;
        TempDocumentEntry.Insert();
    end;

    local procedure UpgradeGovTalkMessage()
    var
        GovTalkMessageGB: Record "GovTalk Message";
#pragma warning disable AL0797
        GovTalkMessage: Record "GovTalkMessage";
#pragma warning restore AL0797
    begin
        if GovTalkMessage.FindSet() then
            repeat
                GovTalkMessageGB.TransferFields(GovTalkMessage);
                GovTalkMessageGB.Insert();
            until GovTalkMessage.Next() = 0;
    end;

    local procedure UpgradeGovTalkMsgParts()
    var
        GovTalkMsgPartsGB: Record "GovTalk Msg. Parts";
        GovTalkMsgParts: Record "GovTalk Message Parts";
    begin
        if GovTalkMsgParts.FindSet() then
            repeat
                GovTalkMsgPartsGB.TransferFields(GovTalkMsgParts);
                GovTalkMsgPartsGB.Insert();
            until GovTalkMsgParts.Next() = 0;
    end;

    local procedure UpgradeGovTalkSetup()
    var
        GovTalkSetupGB: Record "Gov Talk Setup";
#pragma warning disable AL0797
        GovTalkSetup: Record "GovTalk Setup";
#pragma warning restore AL0797
    begin
        if GovTalkSetup.FindSet() then
            repeat
                GovTalkSetupGB.TransferFields(GovTalkSetup);
                GovTalkSetupGB.Insert();
            until GovTalkSetup.Next() = 0;
    end;

    local procedure UpgradeGovTalk()
    var
        CompanyInfo: Record "Company Information";
        ECSLVATReportLine: Record "ECSL VAT Report Line";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        VATReportHeader: Record "VAT Report Header";
    begin
        UpgradeGovTalkMessage();
        UpgradeGovTalkMsgParts();
        UpgradeGovTalkSetup();
        if CompanyInfo.FindSet() then
            repeat
#pragma warning disable AL0432
                CompanyInfo."Branch Number GB" := CompanyInfo."Branch Number";
#pragma warning restore AL0432
                CompanyInfo.Modify();
            until CompanyInfo.Next() = 0;

        if ECSLVATReportLine.FindSet() then
            repeat
#pragma warning disable AL0432
                ECSLVATReportLine."Line Status GB" := ECSLVATReportLine."Line Status";
                ECSLVATReportLine."XML Part Id GB" := ECSLVATReportLine."XML Part Id";
#pragma warning restore AL0432
                ECSLVATReportLine.Modify();
            until ECSLVATReportLine.Next() = 0;

        if VATReportsConfiguration.FindSet() then
            repeat
#pragma warning disable AL0432
                VATReportsConfiguration."Content Max Lines GB" := VATReportsConfiguration."Content Max Lines";
#pragma warning restore AL0432
                VATReportsConfiguration.Modify();
            until VATReportsConfiguration.Next() = 0;

        if VATReportHeader.FindSet() then
            repeat
                if VATReportHeader.Status.AsInteger() = 7 then
                    VATReportHeader.Status := VATReportHeader.Status::"Part. Accepted";
                VATReportHeader.Modify();
            until VATReportHeader.Next() = 0;
    end;

    local procedure SetUpgradeTag(DataUpgradeExecuted: Boolean)
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagGovTalk: Codeunit "Upg. Tag GovTalk";
    begin
        // Set the upgrade tag to indicate that the data update is executed/skipped and the feature is enabled.
        // This is needed when the feature is enabled by default in a future version, to skip the data upgrade.
        if UpgradeTag.HasUpgradeTag(UpgTagGovTalk.GetGovTalkUpgradeTag()) then
            exit;

        UpgradeTag.SetUpgradeTag(UpgTagGovTalk.GetGovTalkUpgradeTag());
        if not DataUpgradeExecuted then
            UpgradeTag.SetSkippedUpgrade(UpgTagGovTalk.GetGovTalkUpgradeTag(), true);
    end;

    procedure SetDefaultReportLayouts()
    begin
        SetDefaultReportLayout(Report::"EC Sales List");
    end;

    local procedure SetDefaultReportLayout(ReportID: Integer)
    var
        SelectedReportLayoutList: Record "Report Layout List";
    begin
        SelectedReportLayoutList.SetRange("Report ID", ReportID);
        SelectedReportLayoutList.SetRange(Name, 'GBlocalizationLayout');
        SelectedReportLayoutList.SetRange("Application ID", GovTalkApplicationAppIdTok);
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