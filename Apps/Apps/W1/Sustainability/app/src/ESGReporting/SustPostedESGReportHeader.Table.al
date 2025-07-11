// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Foundation.Address;

table 6231 "Sust. Posted ESG Report Header"
{
    Caption = 'Posted ESG Report Header';
    LookupPageID = "Sust. Posted ESG Reports";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "ESG Reporting Template Name"; Code[10])
        {
            Caption = 'ESG Reporting Template Name';
            NotBlank = true;
            TableRelation = "Sust. ESG Reporting Template";
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            OptimizeForTextSearch = true;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(6; "Standard Type"; Enum "Sust ESG Reporting Std. Type")
        {
            Caption = 'Standard Type';
        }
        field(7; Period; Integer)
        {
            Caption = 'Period';
        }
        field(8; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
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
    var
        PostedESGReportLine: Record "Sust. Posted ESG Report Line";
    begin
        PostedESGReportLine.SetRange("Document No.", Rec."No.");
        PostedESGReportLine.DeleteAll();
    end;
}