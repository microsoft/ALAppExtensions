// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;

report 18602 "Gate Entry Inward Status"
{
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/rdl/GateEntryInwardStatus.rdl';
    Caption = 'Gate Entry - Inward Status';

    dataset
    {
        dataitem(DataItem2147; "Posted Gate Entry Line")
        {
            DataItemTableView = sorting("Entry Type", "Source Type", "Source No.", Status) order(ascending) where("Entry Type" = filter(Inward));

            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(LocationText; LocationText)
            {
            }
            column(LocationCode; LocationCode)
            {
            }
            column(SourceType_PostedGateEntryLine; "Source Type")
            {
            }
            column(PreSourceType; PreSourceType)
            {
            }
            column(SourceTypeNo; SourceTypeNO)
            {
            }
            column(SourceNo_PostedGateEntryLine; "Source No.")
            {
            }
            column(PreSourceNo; PreSourceNo)
            {
            }
            column(GateEntryNo_PostedGateEntryLine; "Gate Entry No.")
            {
            }
            column(Status_PostedGateEntryLine; Status)
            {
            }
            column(ChallanNo_PostedGateEntryLine; "Challan No.")
            {
            }
            column(ChallanDate_PostedGateEntryLine; Format("Challan Date"))
            {
            }
            column(RcptNo; RcptNo)
            {
            }
            column(EntryType_PostedGateEntryLine; "Entry Type")
            {
            }
            column(LineNo_PostedGateEntryLine; "Line No.")
            {
            }
            column(GateEntryInwardStatusCaption; GateEntryInwardStatusCaptionLbl)
            {
            }
            column(PageNoCaption; PageNoCaptionLbl)
            {
            }
            column(GateEntryNoCaption_PostedGateEntryLine; FieldCaption("Gate Entry No."))
            {
            }
            column(StatusCaption_PostedGateEntryLine; FieldCaption(Status))
            {
            }
            column(ChallanNoCaption_PostedGateEntryLine; FieldCaption("Challan No."))
            {
            }
            column(PostedGateEntryLineChallanDateCaption; PostedGateEntryLineChallanDateCaptionLbl)
            {
            }
            column(ReceiptNoCaption; ReceiptNoCaptionLbl)
            {
            }
            column(SourceTypeCaption_PostedGateEntryLine; FieldCaption("Source Type"))
            {
            }
            column(SourceNoCaption_PostedGateEntryLine; FieldCaption("Source No."))
            {
            }

            trigger OnAfterGetRecord()
            begin
                if LocationCode <> '' then begin
                    PstdGateEntryHeader.Get(PstdGateEntryHeader."Entry Type"::Inward, "Gate Entry No.");
                    if PstdGateEntryHeader."Location Code" <> LocationCode then
                        CurrReport.Skip();
                end;
                PstdGateEntryAttachment.Reset();
                PstdGateEntryAttachment.SetRange("Source Type", "Source Type");
                PstdGateEntryAttachment.SetRange("Source No.", "Source No.");
                PstdGateEntryAttachment.SetRange("Entry Type", "Entry Type");
                PstdGateEntryAttachment.SetRange("Gate Entry No.", "Gate Entry No.");
                PstdGateEntryAttachment.SetRange("Line No.", "Line No.");
                if PstdGateEntryAttachment.FindFirst() then
                    RcptNo := PstdGateEntryAttachment."Receipt No."
                else
                    RcptNo := '';

                PreSourceType := PostedGateEntryLineSourceType.AsInteger();
                PostedGateEntryLineSourceType := GateEntryLib.GetGateEntrySourcetype("Source Type");
                SourceTypeNO := "Source Type".AsInteger();
                PreSourceNo := PostedGateEntryLineSourceNo;
                PostedGateEntryLineSourceNo := Format(CopyStr("Source No.", MaxStrLen(PostedGateEntryLineSourceNo)));
            end;

            trigger OnPreDataItem()
            begin
                if SourceType <> SourceType::" " then
                    SetRange("Source Type", SourceType);
                PostedGateEntryLineSourceType := PostedGateEntryLineSourceType::"For Option";
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(Source; SourceType)
                    {
                        Caption = 'Source Type';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the type of source document for which the report is run';
                    }
                    field(Location; LocationCode)
                    {
                        Caption = 'Location Code';
                        TableRelation = Location;
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the location code for which the report is run';
                    }
                }
            }
        }
    }


    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        if LocationCode <> '' then
            LocationText := 'For Location..'
    end;

    var
        PstdGateEntryAttachment: Record "Posted Gate Entry Attachment";
        PstdGateEntryHeader: Record "Posted Gate Entry Header";
        CompanyInfo: Record "Company Information";
        GateEntryLib: Codeunit "Gate Entry Handler";
        RcptNo: Code[20];
        SourceType: Enum "Gate Entry Source Type";
        LocationCode: Code[20];
        LocationText: Text[30];
        PostedGateEntryLineSourceType: Enum "Posted Gate Entry Source Type";
        PostedGateEntryLineSourceNo: Code[10];
        PreSourceNo: Code[10];
        PreSourceType: Integer;
        SourceTypeNO: Integer;
        GateEntryInwardStatusCaptionLbl: Label 'Gate Entry - Inward Status';
        PageNoCaptionLbl: Label 'Page';
        PostedGateEntryLineChallanDateCaptionLbl: Label 'Challan Date';
        ReceiptNoCaptionLbl: Label 'Receipt No.';
}
