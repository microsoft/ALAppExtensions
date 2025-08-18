// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using System.Reflection;

table 6228 "Sust. ESG Reporting Template"
{
    Caption = 'ESG Reporting Template';
    LookupPageID = "Sust. ESG Reporting Tmpl. List";
    ReplicateData = true;
    DataClassification = CustomerContent;

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
        }
        field(6; "Page ID"; Integer)
        {
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));

            trigger OnValidate()
            begin
                if "Page ID" = 0 then
                    "Page ID" := Page::"Sust. ESG Report. Aggregation";
            end;
        }
        field(7; "ESG Reporting Report ID"; Integer)
        {
            Caption = 'ESG Reporting Report ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
        }
        field(16; "Page Caption"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Page),
                                                                           "Object ID" = field("Page ID")));
            Caption = 'Page Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "ESG Reporting Report Caption"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Report),
                                                                           "Object ID" = field("ESG Reporting Report ID")));
            Caption = 'ESG Reporting Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
    begin
        ESGReportingLine.SetRange("ESG Reporting Template Name", Name);
        ESGReportingLine.DeleteAll();

        ESGReportingName.SetRange("ESG Reporting Template Name", Name);
        ESGReportingName.DeleteAll();
    end;

    trigger OnInsert()
    begin
        Validate("Page ID");
    end;
}