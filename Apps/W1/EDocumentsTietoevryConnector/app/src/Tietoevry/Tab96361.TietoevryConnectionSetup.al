// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

table 96361 "Tietoevry Connection Setup"
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
        field(7; "Outbound API URL"; Text[250])
        {
            Caption = 'Outbound API URL';
            DataClassification = CustomerContent;
        }
        field(8; "Inbound API URL"; Text[250])
        {
            Caption = 'Inbound API URL';
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
        field(12; "Send Mode"; Enum "E-Doc. Tietoevry Send Mode")
        {
            Caption = 'Send Mode';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                TietoevryAuth: Codeunit "Tietoevry Auth.";
            begin
                TietoevryAuth.SetDefaultEndpoints(Rec, "Send Mode");
            end;
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