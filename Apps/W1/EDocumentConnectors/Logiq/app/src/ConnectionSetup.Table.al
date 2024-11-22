namespace Microsoft.EServices.EDocumentConnector.Logiq;

table 6380 "Connection Setup"
{
    Caption = 'Logiq Connection Setup';
    DataClassification = CustomerContent;
    fields
    {
        field(1; PK; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(21; "Authentication URL"; Text[100])
        {
            Caption = 'Authorization URL';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Authorization URL.';
        }
        field(22; "Base URL"; Text[100])
        {
            Caption = 'Base URL';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Base URL.';
        }
        field(25; "File List Endpoint"; Text[100])
        {
            Caption = 'File List Endpoint';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Endpoint to list available files.';
        }
        field(31; "Client ID"; Text[100])
        {
            Caption = 'Client ID';
            ToolTip = 'Specifies the client ID token.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(32; "Client Secret"; Guid)
        {
            Caption = 'Client Secret';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }

    var
        LogiqAuth: Codeunit Auth;

    trigger OnInsert()
    begin
        Rec."Authentication URL" := this.AuthenticationUrlTok;
        Rec."File List Endpoint" := this.FileListTok;
        Rec."Base URL" := this.BaseUrlTok;
    end;

    internal procedure GetClientSecret(): SecretText
    var
        ClientSecret: SecretText;
    begin
        this.LogiqAuth.GetIsolatedStorageValue(Rec."Client Secret", ClientSecret);
        exit(ClientSecret);
    end;

    var
        AuthenticationUrlTok: Label 'https://pilot-sso.logiq.no/auth/realms/connect-api/protocol/openid-connect/token', Locked = true;
        BaseUrlTok: Label 'https://pilot-api.logiq.no/edi/connect/', Locked = true;
        FileListTok: Label '1.0/listfiles', Locked = true;

}
