// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Foundation.Address;

table 6229 "Sust. ESG Reporting Name"
{
    Caption = 'ESG Reporting Name';
    LookupPageID = "Sust. ESG Reporting Names";
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

            trigger OnValidate()
            begin
                if Rec.Period <> xRec.Period then
                    Rec.Validate(Posted, false);
            end;
        }
        field(8; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(9; Posted; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "ESG Reporting Template Name", Name)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
    begin
        ESGReportingLine.SetRange("ESG Reporting Template Name", "ESG Reporting Template Name");
        ESGReportingLine.SetRange("ESG Reporting Name", Name);
        if not ESGReportingLine.IsEmpty() then
            ESGReportingLine.DeleteAll();
    end;

    trigger OnRename()
    var
        ESGReportingLine: Record "Sust. ESG Reporting Line";
    begin
        ESGReportingLine.SetRange("ESG Reporting Template Name", xRec."ESG Reporting Template Name");
        ESGReportingLine.SetRange("ESG Reporting Name", xRec.Name);
        while ESGReportingLine.FindFirst() do
            ESGReportingLine.Rename("ESG Reporting Template Name", Name, ESGReportingLine."Line No.");
    end;
}