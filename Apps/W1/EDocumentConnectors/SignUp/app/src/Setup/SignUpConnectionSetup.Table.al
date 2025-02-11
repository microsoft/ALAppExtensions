// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

table 6381 SignUpConnectionSetup
{
    Access = Internal;
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; PK; Code[10])
        {
            Caption = 'PK', Locked = true;
            ToolTip = 'PK', Locked = true;
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
        field(5; "Environment Type"; Enum SignUpEnvironmentType)
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
        field(7; "Root App ID"; Guid)
        {
            Caption = 'Root App ID';
            ToolTip = 'Specifies the root app ID.';
        }
        field(8; "Root Secret"; Guid)
        {
            Caption = 'Root App Secret';
            ToolTip = 'Specifies the root application secret.';
        }
        field(9; "Root Tenant"; Guid)
        {
            Caption = 'Root App Tenant';
            ToolTip = 'Specifies the root application tenant.';
        }
        field(10; "Root Market URL"; Text[2048])
        {
            Caption = 'Root Market URL';
            ToolTip = 'Specifies the root market URL.';

            trigger OnValidate()
            begin
                if Rec."Root Market URL" <> '' then
                    Rec."Root Market URL" := CopyStr(Rec."Root Market URL".TrimEnd('/'), 1, MaxStrLen("Root Market URL"));
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