// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;

table 6490 "B2Brouter Setup"
{
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; PK; Code[20])
        {
            Caption = 'Primary Key';
        }

        field(2; "Production Project"; Text[1024])
        {
            Caption = 'Project';
        }

        field(3; "Sandbox Project"; Text[1024])
        {
            Caption = 'Sandbox Project';
        }

        field(4; "Sandbox Mode"; Boolean)
        {
            Caption = 'Sandbox Mode';
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
        DeleteApiKeys();
    end;

    trigger OnDelete()
    begin
        DeleteApiKeys();
    end;

    procedure DeleteApiKeys()
    begin
        DeleteApiKey(true);
        DeleteApiKey(false);
    end;

    procedure DeleteApiKey(SandboxMode: Boolean)
    var
        ApiKeyIdentifier: Text;
    begin
        ApiKeyIdentifier := GetApiKeyIdentifier(SandboxMode);

        if IsolatedStorage.Contains(ApiKeyIdentifier, DataScope::Company) then
            IsolatedStorage.Delete(ApiKeyIdentifier, DataScope::Company);
    end;

    procedure StoreApiKey(SandboxMode: Boolean; APIKey: SecretText)
    var
        ApiKeyIdentifier: Text;
    begin
        ApiKeyIdentifier := GetApiKeyIdentifier(SandboxMode);

        if not EncryptionEnabled() then
            IsolatedStorage.Set(ApiKeyIdentifier, APIKey, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(ApiKeyIdentifier, APIKey, DataScope::Company);
    end;

    internal procedure SetKeysIfAvailable(var ProductionKey: Text; var SandboxKey: Text)
    begin
        if IsolatedStorage.Contains(GetApiKeyIdentifier(true), DataScope::Company) then
            SandboxKey := '*';

        if IsolatedStorage.Contains(GetApiKeyIdentifier(false), DataScope::Company) then
            ProductionKey := '*';
    end;

    local procedure GetApiKeyIdentifier(SandboxMode: Boolean): Text
    begin
        if not SandboxMode then
            exit('ProductionApiKey');
        exit('SandboxApiKey');
    end;

    internal procedure GetApiKey(SandboxMode: Boolean; var ApiKey: SecretText): Boolean
    begin
        exit(IsolatedStorage.Get(GetApiKeyIdentifier(SandboxMode), DataScope::Company, ApiKey));
    end;
}