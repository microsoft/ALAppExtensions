// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;

report 18604 "Posted Gate Entry"
{
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/rdl/PostedGateEntry.rdl';
    Caption = 'Posted Gate Entry';

    dataset
    {
        dataitem("Posted Gate Entry Header"; "Posted Gate Entry Header")
        {
            DataItemTableView = sorting("Entry Type", "No.") order(ascending);
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Entry Type", "No.", "Location Code", "Posting Date";

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
            column(GetFilters; GetFilters)
            {
            }
            column(EntryType_PostedGateEntryHdr; "Entry Type")
            {
            }
            column(No_PostedGateEntryHdr; "No.")
            {
            }
            column(PostedGateEntryCaption; PostedGateEntryCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            dataitem("Posted Gate Entry Line"; "Posted Gate Entry Line")
            {
                DataItemLink = "Entry Type" = field("Entry Type"), "Gate Entry No." = field("No.");
                DataItemTableView = sorting("Entry Type", "Gate Entry No.", "Line No.") order(ascending);
                RequestFilterFields = "Source Type", Status;

                column(PostedGateEntryHdrLocCode; "Posted Gate Entry Header"."Location Code")
                {
                }
                column(PostedGateEntryHdrItemDesc; "Posted Gate Entry Header"."Item Description")
                {
                }
                column(PostedGateEntryHdrDesc; "Posted Gate Entry Header".Description)
                {
                }
                column(PostedGateEntryHdrStationFromTo; "Posted Gate Entry Header"."Station From/To")
                {
                }
                column(PostedGateEntryHdrLRRRNo; "Posted Gate Entry Header"."LR/RR No.")
                {
                }
                column(PostedGateEntryHdrLRRRDateFormatted; Format("Posted Gate Entry Header"."LR/RR Date"))
                {
                }
                column(PostedGateEntryHdrPostingDateFormatted; Format("Posted Gate Entry Header"."Posting Date"))
                {
                }
                column(PostedGateEntryHdrVehicleNo; "Posted Gate Entry Header"."Vehicle No.")
                {
                }
                column(PostedGateEntryHdrDocDateFormatted; Format("Posted Gate Entry Header"."Document Date"))
                {
                }
                column(PostedGateEntryHdrDocTime; Format("Posted Gate Entry Header"."Document Time"))
                {
                }
                column(PostedGateEntryHdrPostingTime; Format("Posted Gate Entry Header"."Posting Time"))
                {
                }
                column(SourceType_PostedGateEntryLine; "Source Type")
                {
                }
                column(SourceNo_PostedGateEntryLine; "Source No.")
                {
                }
                column(SourceName_PostedGateEntryLine; "Source Name")
                {
                }
                column(Desc_PostedGateEntryLine; Description)
                {
                }
                column(ChallanNo_PostedGateEntryLine; "Challan No.")
                {
                }
                column(ChallanDateFormatted_PostedGateEntryLine; Format("Challan Date"))
                {
                }
                column(StatusText; StatusText)
                {
                }
                column(PostedGateEntryHdrEntryTypeCaption; "Posted Gate Entry Header".FieldCaption("Entry Type"))
                {
                }
                column(PostedGateEntryHdrNoCaption; "Posted Gate Entry Header".FieldCaption("No."))
                {
                }
                column(PostedGateEntryHdrLocCodeCaption; "Posted Gate Entry Header".FieldCaption("Location Code"))
                {
                }
                column(PostedGateEntryHdrStationFromCaption; PostedGateEntryHdrStationFromCaptionLbl)
                {
                }
                column(PostedGateEntryHdrDescCaption; "Posted Gate Entry Header".FieldCaption(Description))
                {
                }
                column(PostedGateEntryHdrItemDescCaption; "Posted Gate Entry Header".FieldCaption("Item Description"))
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
                column(PostedGateEntryHdrLRRRNoCaption; "Posted Gate Entry Header".FieldCaption("LR/RR No."))
                {
                }
                column(PostedGateEntryHdrLRRRDateCaption; PostedGateEntryHdrLRRRDateCaptionLbl)
                {
                }
                column(PostedGateEntryHdrPostingDateCaption; PostedGateEntryHdrPostingDateCaptionLbl)
                {
                }
                column(PostedGateEntryHdrVehicleNoCaption; "Posted Gate Entry Header".FieldCaption("Vehicle No."))
                {
                }
                column(ChallanNoCaption; ChallanNoCaptionLbl)
                {
                }
                column(PostedGateEntryHdrDocDateCaption; PostedGateEntryHdrDocDateCaptionLbl)
                {
                }
                column(PostedGateEntryHdrDocTimeCaption; PostedGateEntryHdrDocTimeCaptionLbl)
                {
                }
                column(PostedGateEntryHdrPostingTimeCaption; PostedGateEntryHdrPostingTimeCaptionLbl)
                {
                }
                column(ChallanDateCaption; ChallanDateCaptionLbl)
                {
                }
                column(StatusCaption; StatusCaptionLbl)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if "Entry Type" = "Entry Type"::Inward then
                        StatusText := Format("Posted Gate Entry Line".Status)
                    else
                        Clear(StatusText);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddr.Company(CompanyAddr, CompanyInfo);
                Clear(StatusText);
            end;
        }
    }


    trigger OnPreReport()
    begin
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        FormatAddr: Codeunit "Format Address";
        CompanyAddr: array[8] of Text[50];
        StatusText: Text[30];
        PostedGateEntryCaptionLbl: Label 'Posted Gate Entry';
        PageCaptionLbl: Label 'Page';
        PostedGateEntryHdrStationFromCaptionLbl: Label 'Station From';
        SourceTypeCaptionLbl: Label 'Source Type';
        SourceNoCaptionLbl: Label 'Source No.';
        SourceNameCaptionLbl: Label 'Source Name';
        DescriptionCaptionLbl: Label 'Description';
        PostedGateEntryHdrLRRRDateCaptionLbl: Label 'LR/RR Date';
        PostedGateEntryHdrPostingDateCaptionLbl: Label 'Posting Date';
        ChallanNoCaptionLbl: Label 'Challan No.';
        PostedGateEntryHdrDocDateCaptionLbl: Label 'Document Date';
        PostedGateEntryHdrDocTimeCaptionLbl: Label 'Document Time';
        PostedGateEntryHdrPostingTimeCaptionLbl: Label 'Posting Time';
        ChallanDateCaptionLbl: Label 'Challan Date';
        StatusCaptionLbl: Label 'Status';
}
