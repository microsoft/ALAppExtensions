// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Integration.Dataverse;

table 6258 "Sust. ESG Requirement Concept"
{
    Caption = 'ESG Requirement Concept';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Sust. ESG Requirement Concepts";
    DrillDownPageId = "Sust. ESG Requirement Concepts";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Guid)
        {
            Caption = 'No.';
        }
        field(2; Description; Text[840])
        {
            Caption = 'Description';
        }
        field(10; "Standard Requirement ID"; Guid)
        {
            Caption = 'Standard Requirement ID';
        }
        field(11; "Concept ID"; Guid)
        {
            Caption = 'Concept ID';
        }
        field(20; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Dataverse';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Sust. ESG Requirement Concept")));
            ToolTip = 'Specifies that the Requirement Concept is coupled to a Requirement Concept in Dataverse.';
        }
        field(30; "Requirement Concept ID"; Guid)
        {
            Caption = 'Requirement Concept ID';
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}