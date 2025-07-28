// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

table 6430 "Logiq Connection Setup"
{
    Caption = 'Logiq Connection Setup';
    DataClassification = CustomerContent;
    ReplicateData = false;
    Access = Internal;

    fields
    {
        field(1; PK; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(21; "Authentication URL"; Text[100])
        {
            Caption = 'Authorization URL';
            ToolTip = 'Specifies the Authorization URL.';
            Editable = false;
        }
        field(22; "Base URL"; Text[100])
        {
            Caption = 'Base URL';
            ToolTip = 'Specifies the Base URL.';
            Editable = false;
        }
        field(25; "File List Endpoint"; Text[100])
        {
            Caption = 'File List Endpoint';
            ToolTip = 'Specifies the Endpoint to list available files.';
        }
        field(26; Environment; Enum "Logiq Environment")
        {
            Caption = 'Environment';
            ToolTip = 'Specifies the environment to connect.';

            trigger OnValidate()
            begin
                case Rec.Environment of
                    Environment::Pilot:
                        begin
                            Rec."Authentication URL" := this.PilotAuthenticationUrlTok;
                            Rec."Base URL" := this.PilotBaseUrlTok;
                        end;
                    Environment::Production:
                        begin
                            Rec."Authentication URL" := this.ProdAuthenticationUrlTok;
                            Rec."Base URL" := this.ProdBaseUrlTok;
                        end;
                end;
            end;
        }
        field(31; "Client ID"; Text[100])
        {
            Caption = 'Client ID';
            ToolTip = 'Specifies the client ID token.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        Rec."Authentication URL" := this.PilotAuthenticationUrlTok;
        Rec."File List Endpoint" := this.FileListTok;
        Rec."Base URL" := this.PilotBaseUrlTok;
    end;

    var
        PilotAuthenticationUrlTok: Label 'https://pilot-sso.logiq.no/auth/realms/connect-api/protocol/openid-connect/token', Locked = true;
        PilotBaseUrlTok: Label 'https://pilot-api.logiq.no/edi/connect/', Locked = true;
        ProdAuthenticationUrlTok: Label 'https://sso.logiq.no/auth/realms/connect-api/protocol/openid-connect/token', Locked = true;
        ProdBaseUrlTok: Label 'https://api.logiq.no/edi/connect/', Locked = true;
        FileListTok: Label '1.0/listfiles', Locked = true;


}
