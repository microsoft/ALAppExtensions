// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

table 6393 "Continia Network Identifier"
{
    Access = Internal;
    Caption = 'Network Identifier';
    DataClassification = SystemMetadata;
    DrillDownPageId = "Continia Network Id. List";

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'ID';
        }
        field(2; Network; Enum "Continia E-Delivery Network")
        {
            Caption = 'Network';
            ToolTip = 'Specifies the Network Name of the Network Identifier.';
        }
        field(3; "Identifier Type Id"; Text[4])
        {
            Caption = 'Identifier Type Id';
            ToolTip = 'Specifies the EAS code of the identifier type.';
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the identifier type.';
        }
        field(5; "Scheme Id"; Text[50])
        {
            Caption = 'Scheme Id';
            ToolTip = 'Specifies the scheme Id of the identifier type.';
        }
        field(10; Default; Boolean)
        {
            Caption = 'Default';
        }
        field(11; "Default in Country"; Code[10])
        {
            Caption = 'Default in Country';
        }
        field(12; "VAT in Country"; Code[10])
        {
            Caption = 'VAT Identification in Country';
        }
        field(13; "ICD Code"; Boolean)
        {
            Caption = 'ICD Code';
        }
        field(14; "Validation Rule"; Text[50])
        {
            Caption = 'Validation Rule';
        }
        field(21; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
        key(Key2; "Scheme Id") { }
    }
}