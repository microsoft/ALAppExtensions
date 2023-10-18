// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;

report 18603 "Gate Entry List"
{
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/rdl/GateEntryList.rdl';
    Caption = 'Gate Entry List';

    dataset
    {
        dataitem("Gate Entry Header"; "Gate Entry Header")
        {
            DataItemTableView = sorting("Entry Type", "No.") order(ascending);
            RequestFilterFields = "Entry Type", "Location Code";

            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(CompanyAddr6; CompanyAddr[6])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(GetFilters; GetFilters)
            {
            }
            column(EntryType_GateEntryHdr; "Entry Type")
            {
            }
            column(No_GateEntryHdr; "No.")
            {
            }
            column(LocCode_GateEntryHdr; "Location Code")
            {
            }
            column(DocDateFormatted_GateEntryHdr; Format("Document Date"))
            {
            }
            column(DocTimeFormatted_GateEntryHdr; Format("Document Time"))
            {
            }
            column(Desc_GateEntryHdr; Description)
            {
            }
            column(ItemDesc_GateEntryHdr; "Item Description")
            {
            }
            column(StationFromTo_GateEntryHdr; "Station From/To")
            {
            }
            column(LRRRNo_GateEntryHdr; "LR/RR No.")
            {
            }
            column(LRRRDateFormatted_GateEntryHdr; Format("LR/RR Date"))
            {
            }
            column(VehicleNo_GateEntryHdr; "Vehicle No.")
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(GateEntryListCaption; GateEntryListCaptionLbl)
            {
            }
            column(EntryTypeCaption_GateEntryHdr; FieldCaption("Entry Type"))
            {
            }
            column(NoCaption_GateEntryHdr; FieldCaption("No."))
            {
            }
            column(LocCodeCaption_GateEntryHdr; FieldCaption("Location Code"))
            {
            }
            column(GateEntryHdrDocDateCaption; GateEntryHdrDocDateCaptionLbl)
            {
            }
            column(GateEntryHdrDocTimeCaption; GateEntryHdrDocTimeCaptionLbl)
            {
            }
            column(DescCaption_GateEntryHdr; FieldCaption(Description))
            {
            }
            column(ItemDescCaption_GateEntryHdr; FieldCaption("Item Description"))
            {
            }
            column(GateEntryHdrStationFromToCaption; GateEntryHdrStationFromToCaptionLbl)
            {
            }
            column(LRRRNoCaption_GateEntryHdr; FieldCaption("LR/RR No."))
            {
            }
            column(GateEntryHdrLRRRDateCaption; GateEntryHdrLRRRDateCaptionLbl)
            {
            }
            column(VehicleNoCaption_GateEntryHdr; FieldCaption("Vehicle No."))
            {
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddr.Company(CompanyAddr, CompanyInfo);
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
        PageCaptionLbl: Label 'Page';
        GateEntryListCaptionLbl: Label 'Gate Entry List';
        GateEntryHdrDocDateCaptionLbl: Label 'Document Date';
        GateEntryHdrDocTimeCaptionLbl: Label 'Document Time';
        GateEntryHdrStationFromToCaptionLbl: Label 'Station';
        GateEntryHdrLRRRDateCaptionLbl: Label 'LR/RR Date';
}
