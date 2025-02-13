// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;
using Microsoft.eServices.EDocument;

table 6361 "E-Doc. Ext. Connection Setup"
{
    fields
    {
        field(1; PK; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(3; "OAuth Feature GUID"; GUID)
        {
            Caption = 'OAuth 2.0 Code';
            DataClassification = CustomerContent;
        }
        field(4; "Authentication URL"; Text[250])
        {
            Caption = 'Authentication URL';
            DataClassification = CustomerContent;
        }
        field(5; "FileAPI URL"; Text[250])
        {
            Caption = 'FileAPI URL';
            DataClassification = CustomerContent;
        }
        field(6; "Fileparts URL"; Text[250])
        {
            Caption = 'Fileparts URL';
            DataClassification = CustomerContent;
        }
        field(7; "DocumentAPI URL"; Text[250])
        {
            Caption = 'DocumentAPI URL';
            DataClassification = CustomerContent;
        }
        field(8; "Redirect URL"; Text[250])
        {
            Caption = 'Redirect URL';
            DataClassification = CustomerContent;
        }
        field(9; "Company Id"; Text[100])
        {
            Caption = 'Company ID';
            DataClassification = CustomerContent;
        }
        field(10; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "Client Secret"; Guid)
        {
            Caption = 'Client Secret';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Send Mode"; Enum "E-Doc. Ext. Send Mode")
        {
            Caption = 'Send Mode';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "E-Document Service"; Code[20])
        {
            TableRelation = "E-Document Service";
            Caption = 'E-Document Service';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; PK)
        {
            Clustered = true;
        }
    }
}