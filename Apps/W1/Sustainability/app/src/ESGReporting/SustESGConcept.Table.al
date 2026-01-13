// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Integration.Dataverse;

table 6257 "Sust. ESG Concept"
{
    Caption = 'ESG Concept';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Sust. ESG Concepts";
    DrillDownPageId = "Sust. ESG Concepts";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Guid)
        {
            Caption = 'No.';
        }
        field(2; Description; Text[400])
        {
            Caption = 'Description';
        }
        field(20; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Dataverse';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Sust. ESG Concept")));
            ToolTip = 'Specifies that the Concept is coupled to a Concept in Dataverse.';
        }
        field(30; "Concept ID"; Guid)
        {
            Caption = 'Concept ID';
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