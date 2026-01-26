// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

table 6440 "SignUp Connection Setup"
{
    Access = Internal;
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key', Locked = true;
        }
        field(2; "Authentication URL"; Text[2048])
        {
            Caption = 'Authentication URL';
            ToolTip = 'Specifies the URL to connect Microsoft Entra.';
        }
        field(3; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            ToolTip = 'Specifies the client ID.';
        }
        field(4; "Client Secret"; Guid)
        {
            Caption = 'Client Secret';
            ToolTip = 'Specifies the client secret.';
        }
        field(5; "Environment Type"; Enum "SignUp Environment Type")
        {
            Caption = 'Environment Type';
            ToolTip = 'Specifies the environment type.';
        }
        field(6; "Service URL"; Text[2048])
        {
            Caption = 'Service URL';
            ToolTip = 'Specifies the service URL.';

            trigger OnValidate()
            begin
                if Rec."Service URL" <> '' then
                    Rec."Service URL" := CopyStr(Rec."Service URL".TrimEnd('/'), 1, MaxStrLen(Rec."Service URL"));
            end;
        }
        field(7; "Marketplace App ID"; Guid)
        {
            Caption = 'Marketplace App ID';
            ToolTip = 'Specifies the Marketplace app ID.';
        }
        field(8; "Marketplace Secret"; Guid)
        {
            Caption = 'Marketplace App Secret';
            ToolTip = 'Specifies the Marketplace application secret.';
        }
        field(9; "Marketplace Tenant"; Guid)
        {
            Caption = 'Marketplace App Tenant';
            ToolTip = 'Specifies the Marketplace application tenant.';
        }
        field(10; "Marketplace URL"; Text[2048])
        {
            Caption = 'Marketplace URL';
            ToolTip = 'Specifies the Marketplace URL.';

            trigger OnValidate()
            begin
                if Rec."Marketplace URL" <> '' then
                    Rec."Marketplace URL" := CopyStr(Rec."Marketplace URL".TrimEnd('/'), 1, MaxStrLen("Marketplace URL"));
            end;
        }
        field(11; "Client Tenant"; Guid)
        {
            Caption = 'Client App Tenant';
            ToolTip = 'Specifies the client application tenant.';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}