// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Foundation.Address;
using Microsoft.Integration.Dataverse;

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
        field(6; Standard; Code[20])
        {
            Caption = 'Standard';
            TableRelation = "Sust. ESG Standard"."No.";
        }
        field(7; "Period Name"; Text[100])
        {
            Caption = 'Period Name';

            trigger OnValidate()
            begin
                if Rec."Period Name" <> xRec."Period Name" then
                    Rec.Validate(Posted, false);
            end;
        }
        field(8; "Period Starting Date"; Date)
        {
            Caption = 'Period Starting Date';

            trigger OnValidate()
            begin
                if ("Period Starting Date" > "Period Ending Date") and ("Period Ending Date" <> 0D) then
                    Error(StartingDateCannotBeAfterEndingDateErr, FieldCaption("Period Starting Date"), FieldCaption("Period Ending Date"));

                if Rec."Period Starting Date" <> xRec."Period Starting Date" then
                    Rec.Validate(Posted, false);
            end;
        }
        field(9; "Period Ending Date"; Date)
        {
            Caption = 'Period Ending Date';

            trigger OnValidate()
            begin
                Validate("Period Starting Date");

                if Rec."Period Ending Date" <> xRec."Period Ending Date" then
                    Rec.Validate(Posted, false);
            end;
        }
        field(10; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(15; Posted; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
        }
        field(20; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Dataverse';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Sust. ESG Reporting Name")));
            ToolTip = 'Specifies that the reporting name is coupled to an assessment in Dataverse.';
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

    var
        StartingDateCannotBeAfterEndingDateErr: Label '%1 cannot be after %2', Comment = '%1 = Starting Date, %2 = Ending Date';
}