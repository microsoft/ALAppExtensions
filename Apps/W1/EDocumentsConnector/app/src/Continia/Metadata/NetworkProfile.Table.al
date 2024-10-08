// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

table 6394 "Network Profile"
{
    Caption = 'Network Profile';
    DataClassification = SystemMetadata;
    DrillDownPageId = "Network Profile List";

    fields
    {
        field(1; "CDN GUID"; Guid)
        {
            Caption = 'CDN GUID';
            DataClassification = SystemMetadata;
        }
        field(2; Network; Enum "Network")
        {
            Caption = 'Network Name';
            DataClassification = SystemMetadata;
        }
        field(3; "Process Identifier"; Text[250])
        {
            Caption = 'Process Identifier';
            DataClassification = SystemMetadata;
        }
        field(4; "Document Identifier"; Text[250])
        {
            Caption = 'Document Identifier';
            DataClassification = SystemMetadata;
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(6; "Customization ID"; Text[250])
        {
            Caption = 'Customization ID';
            DataClassification = SystemMetadata;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
        }

        field(13; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
            DataClassification = SystemMetadata;
        }
        field(14; "Mandatory for Country"; Code[50])
        {
            Caption = 'Mandatory for Country';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "CDN GUID")
        {
            Clustered = true;
        }
        key(Key2; Description)
        {
        }
    }
}