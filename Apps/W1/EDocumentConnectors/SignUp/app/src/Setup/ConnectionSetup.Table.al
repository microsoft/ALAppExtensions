// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

table 6381 ConnectionSetup
{
    Access = Internal;
    DataPerCompany = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; PK; Code[10])
        {
            Caption = 'PK', Locked = true;
            ToolTip = 'PK', Locked = true;
        }
        field(4; "Authentication URL"; Text[250])
        {
            Caption = 'Authentication URL';
            ToolTip = 'Specifies the URL to connect Microsoft Entra.';
        }
        field(9; "Company Id"; Text[100])
        {
            Caption = 'Company ID';
            ToolTip = 'Specifies the company ID.';
        }
        field(10; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            ToolTip = 'Specifies the client ID.';
        }
        field(11; "Client Secret"; Guid)
        {
            Caption = 'Client Secret';
            ToolTip = 'Specifies the client secret.';
        }
        field(12; "Environment Type"; Enum EnvironmentType)
        {
            Caption = 'Environment Type';
            ToolTip = 'Specifies the environment type.';
        }
        field(13; ServiceURL; Text[250])
        {
            Caption = 'Service URL';
            ToolTip = 'Specifies the service URL.';
        }
        field(20; "Root App ID"; Guid)
        {
            Caption = 'Root App ID';
            ToolTip = 'Specifies the root app ID.';
        }
        field(21; "Root Secret"; Guid)
        {
            Caption = 'Root App Secret';
            ToolTip = 'Specifies the root application secret.';
        }
        field(22; "Root Tenant"; Guid)
        {
            Caption = 'Root App Tenant';
            ToolTip = 'Specifies the root application tenant.';
        }
        field(23; "Root Market URL"; Guid)
        {
            Caption = 'Root Market URL';
            ToolTip = 'Specifies the root market URL.';
        }
        field(24; "Client Tenant"; Guid)
        {
            Caption = 'Client App Tenant';
            ToolTip = 'Specifies the client application tenant.';
        }
    }

    keys
    {
        key(Key1; PK)
        {
            Clustered = true;
        }
    }

    procedure GetSetup(): Boolean
    begin
        if not IsNullGuid(Rec.SystemId) then
            exit(true);

        exit(Rec.Get());
    end;
}