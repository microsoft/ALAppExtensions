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
        field(6; Standard; Code[20])
        {
            Caption = 'Standard';
            TableRelation = "Sust. ESG Standard"."No.";
        }
        field(7; "Period Name"; Text[100])
        {
            Caption = 'Period Name';
        }
        field(8; "Period Starting Date"; Date)
        {
            Caption = 'Period Starting Date';
        }
        field(9; "Period Ending Date"; Date)
        {
            Caption = 'Period Ending Date';
        }
        field(10; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(30; "Standard ID"; Guid)
        {
            Caption = 'Standard ID';
        }
        field(31; "Range Period ID"; Guid)
        {
            Caption = 'Range Period ID';
        }
        field(32; "Assessment ID"; Guid)
        {
            Caption = 'Assessment ID';
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", "ESG Reporting Template Name", Name)
        {
        }
        fieldgroup(Brick; "No.", "ESG Reporting Template Name", Name)
        {
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