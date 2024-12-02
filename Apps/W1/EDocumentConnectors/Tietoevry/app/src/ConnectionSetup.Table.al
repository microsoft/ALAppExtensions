// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using Microsoft.EServices.EDocumentConnector;

table 6392 "Connection Setup"
{
    Access = Internal;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Id; Code[10])
        {
            Caption = 'Id';
            ToolTip = 'Specifies the connection setup id.';
        }
        field(2; "Client Id - Key"; Guid)
        {
            Caption = 'Client Id';
            ToolTip = 'Specifies the client id key.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Client Secret - Key"; Guid)
        {
            Caption = 'Client Secret';
            ToolTip = 'Specifies the client secret key.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Authentication URL"; Text[250])
        {
            Caption = 'Authentication URL';
            ToolTip = 'Specifies the URL to connect to Tietoevry.';
            Editable = false;
        }
        field(5; "API URL"; Text[250])
        {
            Caption = 'API URL';
            ToolTip = 'Specifies the URL to connect to Tietoevry''s api.';
            Editable = false;
        }
        field(6; "Sandbox Authentication URL"; Text[250])
        {
            Caption = 'Sandbox Authentication URL';
            ToolTip = 'Specifies the URL to connect to Tietoevry''s sandbox.';
            Editable = false;
        }
        field(7; "Sandbox API URL"; Text[250])
        {
            Caption = 'Sandbox Authentication URL';
            ToolTip = 'Specifies the URL to connect to Tietoevry sandbox api.';
            Editable = false;
        }
        field(8; "Token - Key"; Guid)
        {
            Caption = 'Token';
            ToolTip = 'Specifies the token key.';
        }
        field(9; "Token Expiry"; DateTime)
        {
            Caption = 'Token Expiry';
            ToolTip = 'Specifies the token expiry date.';
        }
        field(10; "Company Id"; Text[250])
        {
            Caption = 'Company ID';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the company ID.';

            trigger OnValidate()
            var
                TietoevryProcessing: Codeunit Processing;
            begin
                if not TietoevryProcessing.IsValidSchemeId(Rec."Company Id") then
                    Error(this.NotAValidCompanyIdErr, Rec."Company Id", Rec.FieldCaption("Company Id"));
            end;
        }
        field(13; "Send Mode"; Enum "Send Mode")
        {
            Caption = 'Send Mode';
            ToolTip = 'Specifies the send mode.';
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }

    var
        NotAValidCompanyIdErr: Label '%1 is not a valid %2', Comment = '%1 = Company Id, %2 = fieldname';

}