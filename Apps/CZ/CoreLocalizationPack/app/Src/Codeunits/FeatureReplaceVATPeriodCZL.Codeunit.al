#if not CLEAN28
namespace System.Environment.Configuration;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.Navigate;
using System.Upgrade;

codeunit 11722 "Feature Replace VAT Period CZL" implements "Feature Data Update"
{
    Access = Internal;
    Permissions = TableData "Feature Data Update Status" = rm;
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';
    ObsoleteReason = 'The VAT Period CZL will be replaced by VAT Return Period by default.';

    var
        TempDocumentEntry: Record "Document Entry" temporary;
        FeatureDataUpdateMgt: Codeunit "Feature Data Update Mgt.";
        ReplaceVATPeriodTxt: Label 'Replace VAT Period with VAT Return Period';
        DescriptionTxt: Label 'If you enable this feature, VAT Periods will be migrated to VAT Return Periods.';

    procedure IsDataUpdateRequired(): Boolean;
    begin
        CountRecords();
        exit(not TempDocumentEntry.IsEmpty());
    end;

    procedure ReviewData()
    var
        DataUpgradeOverview: Page "Data Upgrade Overview";
    begin
        Commit();
        Clear(DataUpgradeOverview);
        DataUpgradeOverview.Set(TempDocumentEntry);
        DataUpgradeOverview.RunModal();
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime;
        UpdateVATPeriodToVATReturnPeriod();
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, ReplaceVATPeriodTxt, StartDateTime);
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    begin
        SetUpgradeTag();
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
        TaskDescription := DescriptionTxt;
    end;

    local procedure CountRecords(): Integer
    var
        VATPeriod: Record "VAT Period CZL";
    begin
        TempDocumentEntry.Reset();
        TempDocumentEntry.DeleteAll();

        InsertDocumentEntry(Database::"VAT Period CZL", VATPeriod.TableCaption(), VATPeriod.CountApprox());
    end;

    local procedure UpdateVATPeriodToVATReturnPeriod()
    var
        VATPeriodCZL: Record "VAT Period CZL";
        VATReturnPeriod: Record "VAT Return Period";
    begin
        if VATPeriodCZL.FindSet() then
            repeat
                VATReturnPeriod.SetRange("Start Date", VATPeriodCZL."Starting Date");
                if not VATReturnPeriod.FindLast() then begin
                    VATReturnPeriod.Init();
                    VATReturnPeriod."No." := BuildVATReturnPeriodNo(VATPeriodCZL."Starting Date");
                    VATReturnPeriod."Start Date" := VATPeriodCZL."Starting Date";
                    VATReturnPeriod."End Date" := CalcEndDate(VATPeriodCZL);
                    VATReturnPeriod."Due Date" := CalcDueDate(VATReturnPeriod."End Date");
                    if VATReturnPeriod.Insert(true) then;
                end;
                if VATPeriodCZL.Closed then begin
                    VATReturnPeriod.Status := VATReturnPeriod.Status::Closed;
                    VATReturnPeriod.Modify();
                end;
            until VATPeriodCZL.Next() = 0;
    end;

    local procedure BuildVATReturnPeriodNo(StartDate: Date): Code[20]
    begin
        exit(Format(StartDate, 0, '.<Year><Month,2><Day,2>'));
    end;

    local procedure CalcEndDate(VATPeriodCZL: Record "VAT Period CZL"): Date
    var
        StartingDate: Date;
    begin
        if VATPeriodCZL.Next() > 0 then
            exit(VATPeriodCZL."Starting Date" - 1);
        StartingDate := VATPeriodCZL."Starting Date";
        if VATPeriodCZL.Next(-1) < 0 then
            case StartingDate of
                CalcDate('<+1M>', VATPeriodCZL."Starting Date"):
                    exit(CalcDate('<CM>', StartingDate));
                CalcDate('<+1Q>', VATPeriodCZL."Starting Date"):
                    exit(CalcDate('<CQ>', StartingDate));
                else
                    exit(StartingDate + (StartingDate - VATPeriodCZL."Starting Date") - 1);
            end;
        exit(0D);
    end;

    local procedure CalcDueDate(EndDate: Date): Date
    begin
        if EndDate = 0D then
            exit(0D);
        exit(CalcDate('<+25D>', EndDate));
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

    local procedure SetUpgradeTag()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZL: Codeunit "Upgrade Tag Definitions CZL";
    begin
        // Set the upgrade tag to indicate that the data update is executed/skipped and the feature is enabled.
        // This is needed when the feature is enabled by default in a future version, to skip the data upgrade.
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetUseVATReturnPeriodInsteadOfVATPeriodUpgradeTag()) then
            exit;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetUseVATReturnPeriodInsteadOfVATPeriodUpgradeTag());
    end;
}
#endif