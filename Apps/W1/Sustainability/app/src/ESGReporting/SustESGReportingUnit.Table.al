// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Integration.Dataverse;

table 6252 "Sust. ESG Reporting Unit"
{
    Caption = 'ESG Reporting Unit';
    DataCaptionFields = "Code", Description;
    LookupPageID = "Sust. ESG Reporting Units";
    DrillDownPageId = "Sust. ESG Reporting Units";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Conversion Factor"; Decimal)
        {
            Caption = 'Conversion Factor';
        }
        field(4; "Base Reporting Unit Code"; Code[20])
        {
            Caption = 'Base Reporting Unit Code';
            TableRelation = "Sust. ESG Reporting Unit".Code;
        }
        field(20; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Dataverse';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Sust. ESG Reporting Unit")));
            ToolTip = 'Specifies that the reporting unit is coupled to an unit in Dataverse.';
        }
        field(30; "Unit ID"; Guid)
        {
            Caption = 'Unit ID';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }
}