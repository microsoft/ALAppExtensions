// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;

report 18605 "Posted Gate Entry List"
{
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/rdl/PostedGateEntryList.rdl';
    Caption = 'Posted Gate Entry List';

    dataset
    {
        dataitem("Posted Gate Entry Header"; "Posted Gate Entry Header")
        {
            DataItemTableView = sorting("Entry Type", "No.") order(ascending);
            RequestFilterFields = "Entry Type", "Location Code", "Posting Date";

            column(CompanyAddr_5_; CompanyAddr[5])
            {
            }
            column(CompanyAddr_6_; CompanyAddr[6])
            {
            }
            column(CompanyAddr_4_; CompanyAddr[4])
            {
            }
            column(CompanyAddr_3_; CompanyAddr[3])
            {
            }
            column(CompanyAddr_2_; CompanyAddr[2])
            {
            }
            column(CompanyAddr_1_; CompanyAddr[1])
            {
            }
            column(USERID; UserID)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(GETFILTERS; GetFilters)
            {
            }
            column(Posted_Gate_Entry_Header__Entry_Type_; "Entry Type")
            {
            }
            column(Posted_Gate_Entry_Header__No__; "No.")
            {
            }
            column(Posted_Gate_Entry_Header__Location_Code_; "Location Code")
            {
            }
            column(Posted_Gate_Entry_Header__Document_Date_; Format("Document Date"))
            {
            }
            column(Posted_Gate_Entry_Header__Document_Time_; Format("Document Time"))
            {
            }
            column(Posted_Gate_Entry_Header_Description; Description)
            {
            }
            column(Posted_Gate_Entry_Header__Item_Description_; "Item Description")
            {
            }
            column(Posted_Gate_Entry_Header__Station_From_To_; "Station From/To")
            {
            }
            column(Posted_Gate_Entry_Header__LR_RR_No__; "LR/RR No.")
            {
            }
            column(Posted_Gate_Entry_Header__LR_RR_Date_; Format("LR/RR Date"))
            {
            }
            column(Posted_Gate_Entry_Header__Vehicle_No__; "Vehicle No.")
            {
            }
            column(Posted_Gate_Entry_Header__Posting_Date_; Format("Posting Date"))
            {
            }
            column(Posted_Gate_Entry_Header__Posting_Time_; Format("Posting Time"))
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Posted_Gate_Entry_ListCaption; Posted_Gate_Entry_ListCaptionLbl)
            {
            }
            column(Posted_Gate_Entry_Header__Entry_Type_Caption; FieldCaption("Entry Type"))
            {
            }
            column(Posted_Gate_Entry_Header__No__Caption; FieldCaption("No."))
            {
            }
            column(Posted_Gate_Entry_Header__Location_Code_Caption; FieldCaption("Location Code"))
            {
            }
            column(Posted_Gate_Entry_Header__Document_Date_Caption; Posted_Gate_Entry_Header__Document_Date_CaptionLbl)
            {
            }
            column(Posted_Gate_Entry_Header__Document_Time_Caption; Posted_Gate_Entry_Header__Document_Time_CaptionLbl)
            {
            }
            column(Posted_Gate_Entry_Header_DescriptionCaption; FieldCaption(Description))
            {
            }
            column(Posted_Gate_Entry_Header__Item_Description_Caption; FieldCaption("Item Description"))
            {
            }
            column(Posted_Gate_Entry_Header__Station_From_To_Caption; Posted_Gate_Entry_Header__Station_From_To_CaptionLbl)
            {
            }
            column(Posted_Gate_Entry_Header__LR_RR_No__Caption; FieldCaption("LR/RR No."))
            {
            }
            column(Posted_Gate_Entry_Header__LR_RR_Date_Caption; Posted_Gate_Entry_Header__LR_RR_Date_CaptionLbl)
            {
            }
            column(Posted_Gate_Entry_Header__Vehicle_No__Caption; FieldCaption("Vehicle No."))
            {
            }
            column(Posted_Gate_Entry_Header__Posting_Date_Caption; Posted_Gate_Entry_Header__Posting_Date_CaptionLbl)
            {
            }
            column(Posted_Gate_Entry_Header__Posting_Time_Caption; Posted_Gate_Entry_Header__Posting_Time_CaptionLbl)
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
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Posted_Gate_Entry_ListCaptionLbl: Label 'Posted Gate Entry List';
        Posted_Gate_Entry_Header__Document_Date_CaptionLbl: Label 'Document Date';
        Posted_Gate_Entry_Header__Document_Time_CaptionLbl: Label '"Document Time';
        Posted_Gate_Entry_Header__Station_From_To_CaptionLbl: Label 'Station';
        Posted_Gate_Entry_Header__LR_RR_Date_CaptionLbl: Label 'LR/RR Date';
        Posted_Gate_Entry_Header__Posting_Date_CaptionLbl: Label 'Posting Date';
        Posted_Gate_Entry_Header__Posting_Time_CaptionLbl: Label 'Posting Time';
}
