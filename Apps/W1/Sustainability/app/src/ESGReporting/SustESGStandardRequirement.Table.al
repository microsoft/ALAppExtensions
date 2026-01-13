// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Integration.Dataverse;

table 6256 "Sust. ESG Standard Requirement"
{
    Caption = 'ESG Standard Requirement';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Sust. ESG Std. Requirements";
    DrillDownPageId = "Sust. ESG Std. Requirements";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Guid)
        {
            Caption = 'No.';
        }
        field(2; Description; Text[500])
        {
            Caption = 'Description';
        }
        field(3; "Name"; Text[830])
        {
            Caption = 'Name';
        }
        field(10; "Parent Std. Requirement ID"; Guid)
        {
            Caption = 'Parent Standard Requirement ID';
        }
        field(20; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Dataverse';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Sust. ESG Standard Requirement")));
            ToolTip = 'Specifies that the Standard Requirement is coupled to an Std Requirement in Dataverse.';
        }
        field(30; "Standard Requirement ID"; Guid)
        {
            Caption = 'Standard Requirement ID';
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