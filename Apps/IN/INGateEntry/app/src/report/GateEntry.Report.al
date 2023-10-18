// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;

report 18601 "Gate Entry"
{
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/rdl/GateEntry.rdl';
    Caption = 'Gate Entry';

    dataset
    {
        dataitem("Gate Entry Header"; "Gate Entry Header")
        {
            DataItemTableView = sorting("Entry Type", "No.") order(ascending);
            RequestFilterfields = "Entry Type", "No.", "Location Code";

            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(CompanyAddr6; CompanyAddr[6])
            {
            }
            column(GetFilters_GateEntryHdr; "Gate Entry Header".GetFilters)
            {
            }
            column(LocationCode_GateEntryHdr; "Gate Entry Header"."Location Code")
            {
            }
            column(ItemDesc_GateEntryHdr; "Gate Entry Header"."Item Description")
            {
            }
            column(Desc_GateEntryHdr; "Gate Entry Header".Description)
            {
            }
            column(StnFromTo_GateEntryHdr; "Gate Entry Header"."Station From/To")
            {
            }
            column(LRRRNo_GateEntryHdr; "Gate Entry Header"."LR/RR No.")
            {
            }
            column(LRRRDateFormatted_GateEntryHdr; Format("Gate Entry Header"."LR/RR Date"))
            {
            }
            column(PostingDateFormatted_GateEntryHdr; Format("Gate Entry Header"."Posting Date"))
            {
            }
            column(VehicleNo_GateEntryHdr; "Gate Entry Header"."Vehicle No.")
            {
            }
            column(PostingTimeFormatted_GateEntryHdr; Format("Gate Entry Header"."Posting Time"))
            {
            }
            column(DocDateFormatted_GateEntryHdr; Format("Gate Entry Header"."Document Date"))
            {
            }
            column(DocTimeFormatted_GateEntryHdr; Format("Gate Entry Header"."Document Time"))
            {
            }
            column(No_GateEntryHdr; "Gate Entry Header"."No.")
            {
            }
            column(EntryType_GateEntryHdr; "Gate Entry Header"."Entry Type")
            {
            }
            column(GateEntryCaption; Gate_EntryCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(LocationCodeCaption_GateEntryHdr; FieldCaption("Location Code"))
            {
            }
            column(GateEntryHdrStnFromToCaption; GateEntryHdrStnFromToCaptionLbl)
            {
            }
            column(DescCaption_GateEntryHdr; FieldCaption(Description))
            {
            }
            column(ItemDescCaption_GateEntryHdr; FieldCaption("Item Description"))
            {
            }
            column(SourceTypeCaption; SourceTypeCaptionLbl)
            {
            }
            column(SourceNoCaption; SourceNoCaptionLbl)
            {
            }
            column(SourceNameCaption; SourceNameCaptionLbl)
            {
            }
            column(DescCaption; DescriptionCaptionLbl)
            {
            }
            column(LRRRNoCaption_GateEntryHdr; FieldCaption("LR/RR No."))
            {
            }
            column(GateEntryHdrLRRRDateCaption; GateEntryHdrLRRRDateCaptionLbl)
            {
            }
            column(GateEntryHdrPostingDateCaption; GateEntryHdrPostingDateCaptionLbl)
            {
            }
            column(VehicleNoCaption_GateEntryHdr; FieldCaption("Vehicle No."))
            {
            }
            column(ChallanNoCaption; ChallanNoCaptionLbl)
            {
            }
            column(GateEntryHdrPostingTimeCaption; GateEntryHdrPostingTimeCaptionLbl)
            {
            }
            column(ChallanDateCaption; ChallanDateCaptionLbl)
            {
            }
            column(GateEntryHdrDocDateCaption; GateEntryHdrDocDateCaptionLbl)
            {
            }
            column(GateEntryHdrDocTimeCaption; GateEntryHdrDocTimeCaptionLbl)
            {
            }
            column(EntryTypeCaption_GateEntryHdr; FieldCaption("Entry Type"))
            {
            }
            column(NoCaption_GateEntryHdr; FieldCaption("No."))
            {
            }
            dataitem(DataItem5423; "Gate Entry Line")
            {
                DataItemLink = "Entry Type" = field("Entry Type"), "Gate Entry No." = field("No.");
                DataItemTableView = sorting("Entry Type", "Gate Entry No.", "Line No.") order(ascending);

                column(SourceType_GateEntryLine; "Source Type")
                {
                }
                column(SourceNo_GateEntryLine; "Source No.")
                {
                }
                column(SourceName_GateEntryLine; "Source Name")
                {
                }
                column(Desc_GateEntryLine; Description)
                {
                }
                column(ChallanNo_GateEntryLine; "Challan No.")
                {
                }
                column(ChallanDateFormatted_GateEntryLine; Format("Challan Date"))
                {
                }
                column(EntryType_GateEntryLine; "Entry Type")
                {
                }
                column(GateEntryNo_GateEntryLine; "Gate Entry No.")
                {
                }
                column(LineNo_GateEntryLine; "Line No.")
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddr.Company(CompanyAddr, CompanyInfo);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }


    trigger OnPreReport()
    begin
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        FormatAddr: Codeunit "Format Address";
        CompanyAddr: array[8] of Text[50];
        Gate_EntryCaptionLbl: Label 'Gate Entry';
        PageCaptionLbl: Label 'Page';
        SourceTypeCaptionLbl: Label 'Source Type';
        SourceNoCaptionLbl: Label 'Source No.';
        SourceNameCaptionLbl: Label 'Source Name';
        DescriptionCaptionLbl: Label 'Description';
        GateEntryHdrPostingDateCaptionLbl: Label 'Posting Date';
        ChallanNoCaptionLbl: Label 'Challan No.';
        GateEntryHdrPostingTimeCaptionLbl: Label 'Posting Time';
        ChallanDateCaptionLbl: Label 'Challan Date';
        GateEntryHdrStnFromToCaptionLbl: Label 'Station From';
        GateEntryHdrLRRRDateCaptionLbl: Label 'LR/RR Date';
        GateEntryHdrDocDateCaptionLbl: Label 'Document Date';
        GateEntryHdrDocTimeCaptionLbl: Label 'Document Time';
}
