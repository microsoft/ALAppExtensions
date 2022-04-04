table 1680 "Email Logging Setup"
{
    Access = Internal;

    Caption = 'Email Logging using Graph API';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Email Address"; Text[250])
        {
            Caption = 'Email Address';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Clear("Consent Given");
            end;
        }
        field(3; "Email Batch Size"; Integer)
        {
            Caption = 'Email Batch Size';
            DataClassification = CustomerContent;
            MinValue = 1;
            MaxValue = 1000;
        }
        field(4; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(5; "Client Id"; Text[250])
        {
            Caption = 'Client Id';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                Clear("Consent Given");
            end;
        }
        field(6; "Client Secret Key"; Guid)
        {
            Caption = 'Client Secret Key';
            DataClassification = EndUserPseudonymousIdentifiers;

            trigger OnValidate()
            begin
                Clear("Consent Given");
            end;
        }
        field(7; "Redirect URL"; Text[2048])
        {
            Caption = 'Redirect URL';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                Clear("Consent Given");
            end;
        }
        field(8; "Consent Given"; Boolean)
        {
            Caption = 'Consent Given';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        IsolatedStorageManagement: Codeunit "Isolated Storage Management";
        CategoryTok: Label 'Email Logging', Locked = true;
        ClientSecretClearedTxt: Label 'Client secret is cleared.', Locked = true;
        ClientSecretSetTxt: Label 'Client secret is set.', Locked = true;
        ClientSecretNotSetTxt: Label 'Client secret is not set.', Locked = true;
        [NonDebuggable]
        TempClientSecret: Text;

    [NonDebuggable]
    internal procedure SetClientSecret(ClientSecret: Text)
    var
        DummyEmailLoggingSetup: Record "Email Logging Setup";
    begin
        if IsTemporary() then begin
            TempClientSecret := ClientSecret;
            exit;
        end;

        if ClientSecret = '' then
            if not IsNullGuid("Client Secret Key") then begin
                IsolatedStorageManagement.Delete("Client Secret Key", DataScope::Company);
                Session.LogMessage('0000G11', ClientSecretClearedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit;
            end;

        if IsNullGuid("Client Secret Key") then begin
            "Client Secret Key" := CreateGuid();
            if DummyEmailLoggingSetup.Get() then
                Rec.Modify()
            else
                Rec.Insert();
        end;

        IsolatedStorageManagement.Set("Client Secret Key", ClientSecret, DataScope::Company);
        Session.LogMessage('0000G12', ClientSecretSetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [NonDebuggable]
    internal procedure GetClientSecret(): Text
    var
        ClientSecret: Text;
    begin
        if IsTemporary() then
            exit(TempClientSecret);

        if IsNullGuid("Client Secret Key") then begin
            Session.LogMessage('0000G13', ClientSecretNotSetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit('');
        end;

        if not IsolatedStorageManagement.Get("Client Secret Key", DataScope::Company, ClientSecret) then begin
            Session.LogMessage('0000G14', ClientSecretNotSetTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit('');
        end;

        exit(ClientSecret);
    end;

    internal procedure GetRedirectUrl(): Text
    begin
        if "Redirect URL" <> '' then
            exit("Redirect URL");
        exit(GetDefaultRedirectUrl());
    end;

    internal procedure GetEmailBatchSize(): Integer
    begin
        if "Email Batch Size" > 0 then
            exit("Email Batch Size");
        exit(GetDefaultEmailBatchSize());
    end;

    internal procedure GetDefaultRedirectUrl(): Text[2048]
    var
        OAuth2: Codeunit OAuth2;
        RedirectUrlLocal: Text;
    begin
        OAuth2.GetDefaultRedirectUrl(RedirectUrlLocal);
        exit(CopyStr(RedirectUrlLocal, 1, 2048));
    end;

    internal procedure GetDefaultEmailBatchSize(): Integer
    begin
        exit(50);
    end;
}