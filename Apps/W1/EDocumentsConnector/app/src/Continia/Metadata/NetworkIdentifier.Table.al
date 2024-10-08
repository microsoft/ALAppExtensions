// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

table 6393 "Network Identifier"
{
    DataClassification = SystemMetadata;

    Caption = 'Network Identifier';
    DrillDownPageId = "Network Id. List";

    fields
    {
        field(1; "CDN GUID"; Guid)
        {
            Caption = 'CDN GUID';
            DataClassification = SystemMetadata;
        }
        field(2; Network; Enum "Network")
        {
            Caption = 'Network';
            DataClassification = SystemMetadata;
        }
        field(3; "Identifier Type ID"; Text[4])
        {
            Caption = 'Identifier Type ID';
            DataClassification = SystemMetadata;
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(5; "Scheme ID"; Text[50])
        {
            Caption = 'Scheme ID';
            DataClassification = SystemMetadata;
        }
        field(10; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = SystemMetadata;
        }
        field(11; "Default in Country"; Code[10])
        {
            Caption = 'Default in Country';
            DataClassification = SystemMetadata;
        }
        field(12; "VAT in Country"; Code[10])
        {
            Caption = 'VAT Identification in Country';
            DataClassification = SystemMetadata;
        }
        field(13; "ICD Code"; Boolean)
        {
            Caption = 'ICD Code';
            DataClassification = SystemMetadata;
        }
        field(14; "Validation Rule"; Text[50])
        {
            Caption = 'Validation Rule';
            DataClassification = SystemMetadata;
        }
        field(21; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "CDN GUID")
        {
            Clustered = true;
        }
        key(Key2; "Scheme ID")
        {
        }
    }
}