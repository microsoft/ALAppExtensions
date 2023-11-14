// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using System.Utilities;

table 31106 "VAT Ctrl. Report Header CZL"
{
    Caption = 'VAT Control Report Header';
    DataCaptionFields = "No.", Description;
    DrillDownPageId = "VAT Ctrl. Report List CZL";
    LookupPageId = "VAT Ctrl. Report List CZL";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    NoSeriesManagement.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestModifyAllowed();
            end;
        }
        field(3; "Report Period"; Option)
        {
            Caption = 'Report Period';
            OptionCaption = 'Month,Quarter';
            OptionMembers = Month,Quarter;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestModifyAllowed();
                CheckPeriodNo();
            end;
        }
        field(4; "Period No."; Integer)
        {
            Caption = 'Period No.';
            MaxValue = 12;
            MinValue = 1;
            BlankZero = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestModifyAllowed();
                if "Period No." <> xRec."Period No." then begin
                    if LineExists() then
                        Error(ChangeNotPosibleLineExistErr, FieldCaption("Period No."));
                    SetPeriod();
                end;
            end;
        }
        field(5; Year; Integer)
        {
            Caption = 'Year';
            MinValue = 0;
            BlankZero = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestModifyAllowed();
                if Year <> xRec.Year then begin
                    if LineExists() then
                        Error(ChangeNotPosibleLineExistErr, FieldCaption(Year));
                    SetPeriod();
                end;
            end;
        }
        field(6; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestModifyAllowed();

                if "Start Date" <> xRec."Start Date" then
                    if LineExists() then
                        Error(ChangeNotPosibleLineExistErr, FieldCaption("Start Date"));
            end;
        }
        field(7; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestModifyAllowed();

                if "End Date" <> xRec."End Date" then
                    if LineExists() then
                        Error(ChangeNotPosibleLineExistErr, FieldCaption("End Date"));
            end;
        }
        field(8; "Created Date"; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(10; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Released';
            OptionMembers = Open,Released;
            DataClassification = CustomerContent;
        }
        field(20; "VAT Statement Template Name"; Code[10])
        {
            Caption = 'VAT Statement Template Name';
            TableRelation = "VAT Statement Template";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestModifyAllowed();

                if "VAT Statement Template Name" <> xRec."VAT Statement Template Name" then begin
                    "VAT Statement Name" := '';
                    if LineExists() then
                        Error(ChangeNotPosibleLineExistErr, FieldCaption("VAT Statement Template Name"));
                end;
            end;
        }
        field(21; "VAT Statement Name"; Code[10])
        {
            Caption = 'VAT Statement Name';
            TableRelation = "VAT Statement Name".Name where("Statement Template Name" = field("VAT Statement Template Name"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestModifyAllowed();

                if "VAT Statement Name" <> xRec."VAT Statement Name" then
                    if LineExists() then
                        Error(ChangeNotPosibleLineExistErr, FieldCaption("VAT Statement Name"));
            end;
        }
        field(25; "VAT Control Report XML Format"; Enum "VAT Ctrl. Report Format CZL")
        {
            Caption = 'VAT Control Report XML Format';
            DataClassification = CustomerContent;
        }
        field(51; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(100; "Closed by Document No. Filter"; Code[20])
        {
            Caption = 'Closed by Document No. Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    begin
        TestModifyAllowed();
        TestDeleteAllowed();

        VATCtrlReportLineCZL.Reset();
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", "No.");
        VATCtrlReportLineCZL.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        if "No." = '' then
            NoSeriesManagement.InitSeries(GetNoSeriesCode(), xRec."No. Series", WorkDate(), "No.", "No. Series");
        InitRecord();
    end;

    trigger OnRename()
    begin
        Error(RecordRenameErr, TableCaption);
    end;

    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        VATCtrlReportMgtCZL: Codeunit "VAT Ctrl. Report Mgt. CZL";
        VATCtrlRepExpRunnerCZL: Codeunit "VAT Ctrl. Rep. Exp. Runner CZL";
        RecordRenameErr: Label 'You cannot rename a %1.', Comment = '%1 = Header No.';
        DateMustBeErr: Label '%1 should be earlier than %2.', Comment = '%1 = fieldcaption.startingdate; %2 = fieldcaption.enddate';
        ChangeNotPosibleLineExistErr: Label 'You cannot change %1 because you already have declaration lines.', Comment = '%1 = Header No.';
        AllowedValuesAreErr: Label 'The permitted values for %1 are from 1 to %2.', Comment = '%1 = fieldcaption.periodnumber; %2 = maxperiodnumber';

    procedure InitRecord()
    begin
        "Created Date" := WorkDate();
    end;

    procedure AssistEdit(OldVATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"): Boolean
    begin
        if NoSeriesManagement.SelectSeries(GetNoSeriesCode(), OldVATCtrlReportHeaderCZL."No. Series", "No. Series") then begin
            NoSeriesManagement.SetSeries("No.");
            exit(true);
        end;
    end;

    local procedure GetNoSeriesCode(): Code[20]
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL.TestField("VAT Control Report Nos.");
        exit(StatutoryReportingSetupCZL."VAT Control Report Nos.");
    end;

    local procedure CheckPeriodNo()
    var
        MaxPeriodNo: Integer;
    begin
        if "Report Period" = "Report Period"::Month then
            MaxPeriodNo := 12
        else
            MaxPeriodNo := 4;
        if not ("Period No." in [1 .. MaxPeriodNo]) then
            Error(AllowedValuesAreErr, FieldCaption("Period No."), MaxPeriodNo);
    end;

    local procedure SetPeriod()
    begin
        if "Period No." <> 0 then
            CheckPeriodNo();
        if ("Period No." = 0) or (Year = 0) then begin
            "Start Date" := 0D;
            "End Date" := 0D;
        end else
            if "Report Period" = "Report Period"::Month then begin
                "Start Date" := DMY2Date(1, "Period No.", Year);
                "End Date" := CalcDate('<CM>', "Start Date");
            end else begin
                "Start Date" := DMY2Date(1, "Period No." * 3 - 2, Year);
                "End Date" := CalcDate('<CQ>', "Start Date");
            end;
        CheckPeriod();
    end;

    local procedure CheckPeriod()
    begin
        if ("Start Date" = 0D) or ("End Date" = 0D) then
            exit;

        if "Start Date" >= "End Date" then
            Error(DateMustBeErr, FieldCaption("Start Date"), FieldCaption("End Date"));
    end;

    procedure PrintTestReport()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
    begin
        VATCtrlReportHeaderCZL := Rec;
        VATCtrlReportHeaderCZL.SetRecFilter();
        Report.Run(Report::"VAT Ctrl. Report - Test CZL", true, false, VATCtrlReportHeaderCZL);
    end;

    procedure PrintToDocumentAttachment()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        ReportOutStream: OutStream;
        DocumentInStream: InStream;
        FileName: Text[250];
        DocumentAttachmentFileNameLbl: Label 'Test VAT Control Report %1', Comment = '%1 = VAT Control Report No.';
    begin
        VATCtrlReportHeaderCZL := Rec;
        VATCtrlReportHeaderCZL.SetRecFilter();
        RecordRef.GetTable(VATCtrlReportHeaderCZL);
        if not RecordRef.FindFirst() then
            exit;

        TempBlob.CreateOutStream(ReportOutStream);
        Report.SaveAs(Report::"VAT Ctrl. Report - Test CZL", '',
                      ReportFormat::Pdf, ReportOutStream, RecordRef);

        DocumentAttachment.InitFieldsFromRecRef(RecordRef);
        FileName := DocumentAttachment.FindUniqueFileName(
                    StrSubstNo(DocumentAttachmentFileNameLbl, VATCtrlReportHeaderCZL."No."), 'pdf');
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, FileName);
        DocumentAttachmentMgmt.ShowNotification(RecordRef, 1, true);
    end;

    procedure CloseLines()
    begin
        VATCtrlReportMgtCZL.CloseVATCtrlReportLine(Rec, '', 0D);
    end;

    local procedure LineExists(): Boolean
    begin
        VATCtrlReportLineCZL.Reset();
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", "No.");
        exit(VATCtrlReportLineCZL.FindFirst());
    end;

    local procedure TestModifyAllowed()
    begin
        TestField(Status, Status::Open);
    end;

    local procedure TestDeleteAllowed()
    begin
        VATCtrlReportLineCZL.Reset();
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", "No.");
        VATCtrlReportLineCZL.SetFilter("Closed by Document No.", '<>%1', '');
        if VATCtrlReportLineCZL.FindFirst() then
            VATCtrlReportLineCZL.TestField("Closed by Document No.", '');
    end;

    procedure SuggestLines()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportGetEntCZL: Report "VAT Ctrl. Report Get Ent. CZL";
    begin
        TestField(Status, Status::Open);
        VATCtrlReportHeaderCZL.Get("No.");
        VATCtrlReportHeaderCZL.SetRange("No.", "No.");
        VATCtrlReportGetEntCZL.UseRequestPage(true);
        VATCtrlReportGetEntCZL.SetTableView(VATCtrlReportHeaderCZL);
        VATCtrlReportGetEntCZL.SetVATCtrlReportHeader(VATCtrlReportHeaderCZL);
        VATCtrlReportGetEntCZL.RunModal();
        Clear(VATCtrlReportGetEntCZL);
    end;

    procedure ExportToFileCZL()
    begin
        TestField(Status, Status::Released);
        VATCtrlRepExpRunnerCZL.Run(Rec);
    end;

    procedure ExportToXMLBlobCZL(var TempBlob: Codeunit "Temp Blob")
    begin
        TestField(Status, Status::Released);
        VATCtrlRepExpRunnerCZL.ExportToXMLBlob(Rec, TempBlob);
    end;
}
