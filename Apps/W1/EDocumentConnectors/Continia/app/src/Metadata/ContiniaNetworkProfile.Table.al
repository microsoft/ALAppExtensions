// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

table 6394 "Continia Network Profile"
{
    Access = Internal;
    Caption = 'Network Profile';
    DataClassification = SystemMetadata;
    DrillDownPageId = "Continia Network Profile List";

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'ID';
        }
        field(2; Network; Enum "Continia E-Delivery Network")
        {
            Caption = 'Network Name';
            ToolTip = 'Specifies the network name of the profile.';
        }
        field(3; "Process Identifier"; Text[250])
        {
            Caption = 'Process Identifier';
            ToolTip = 'Specifies the process identifier value of the profile.';
        }
        field(4; "Document Identifier"; Text[250])
        {
            Caption = 'Document Identifier';
            ToolTip = 'Specifies the document identifier value of the profile.';
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the network profile.';
        }
        field(6; "Customization Id"; Text[250])
        {
            Caption = 'Customization Id';
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(13; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
        }
        field(14; "Mandatory for Country"; Code[50])
        {
            Caption = 'Mandatory for Country';
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}