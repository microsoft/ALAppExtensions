// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.EServices.EDocumentConnector;

table 6392 "Connection Setup"
{
    fields
    {
        field(1; Id; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Client Id - Key"; Guid)
        {
            Caption = 'Client Id';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Client Secret - Key"; Guid)
        {
            Caption = 'Client Secret';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Authentication URL"; Text[250])
        {
            Caption = 'Authentication URL';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "API URL"; Text[250])
        {
            Caption = 'API URL';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Sandbox Authentication URL"; Text[250])
        {
            Caption = 'Sandbox Authentication URL';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Sandbox API URL"; Text[250])
        {
            Caption = 'Sandbox Authentication URL';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Token - Key"; Guid)
        {
            Caption = 'Token';
            DataClassification = SystemMetadata;
        }
        field(9; "Token Expiry"; DateTime)
        {
            Caption = 'Token Expiry';
            DataClassification = SystemMetadata;
        }
        field(10; "Company Id"; Text[250])
        {
            Caption = 'Company ID';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                TietoevryProcessing: Codeunit Processing;
            begin
                if not TietoevryProcessing.IsValidSchemeId(Rec."Company Id") then
                    Rec.FieldError(Rec."Company Id");
            end;
        }
        field(13; "Send Mode"; Enum "E-Doc. Ext. Send Mode")
        {
            Caption = 'Send Mode';
            DataClassification = CustomerContent;
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