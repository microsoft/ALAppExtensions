// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

table 6390 "Continia Connection Setup"
{
    Access = Internal;
    DataClassification = CustomerContent;
    DataPerCompany = false;
    Extensible = false;

    fields
    {
        field(1; PK; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(3; "Client Id"; Guid)
        {
            Caption = 'Client Id';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Client Secret"; Guid)
        {
            Caption = 'Client Secret';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Local Client Identifier"; Code[50])
        {
            Caption = 'Local Client Identifier';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(6; "Access Token"; Guid)
        {
            Caption = 'Access Token';
        }
        field(7; "Token Timestamp"; DateTime)
        {
            Caption = 'Token Timestamp';
        }
        field(8; "Expires In (ms)"; Integer)
        {
            Caption = 'Expires In (ms)';
        }
        field(9; "Subscription Status"; Enum "Continia Subscription Status")
        {
            Caption = 'Subscription Status';
            ToolTip = 'Specifies the status of the Continia subscription.';
        }
        field(10; "No. Of Participations"; Integer)
        {
            CalcFormula = count("Continia Participation");
            Caption = 'No. Of Participations';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of participations for the current company in the Continia Delivery Network.';
        }
    }

    keys
    {
        key(Key1; PK)
        {
            Clustered = true;
        }
    }

    internal procedure GetClientId(): SecretText
    var
        CredentialManagement: Codeunit "Continia Credential Management";
    begin
        exit(CredentialManagement.GetIsolatedStorageValue("Client Id", DataScope::Module));
    end;

    internal procedure GetClientSecret(): SecretText
    var
        CredentialManagement: Codeunit "Continia Credential Management";
    begin
        exit(CredentialManagement.GetIsolatedStorageValue("Client Secret", DataScope::Module));
    end;

    internal procedure SetClientId(Value: SecretText) UsedNewKey: Boolean
    var
        CredentialManagement: Codeunit "Continia Credential Management";
    begin
        exit(CredentialManagement.SetIsolatedStorageValue("Client Id", Value, DataScope::Module));
    end;

    internal procedure SetClientSecret(Value: SecretText) UsedNewKey: Boolean
    var
        CredentialManagement: Codeunit "Continia Credential Management";
    begin
        exit(CredentialManagement.SetIsolatedStorageValue("Client Secret", Value, DataScope::Module));
    end;

    internal procedure GetAccessTokenValue(): SecretText
    var
        CredentialManagement: Codeunit "Continia Credential Management";
    begin
        exit(CredentialManagement.GetIsolatedStorageValue("Access Token", DataScope::Module));
    end;

    local procedure AccessTokenHasValue(): Boolean
    var
        CredentialManagement: Codeunit "Continia Credential Management";
    begin
        exit(CredentialManagement.HasIsolatedStorageValue("Access Token", DataScope::Module));
    end;

    internal procedure SetAccessTokenValue(Value: SecretText) UsedNewKey: Boolean
    var
        CredentialManagement: Codeunit "Continia Credential Management";
    begin
        exit(CredentialManagement.SetIsolatedStorageValue("Access Token", Value, DataScope::Module));
    end;

    internal procedure DeleteAccessTokenValue(): Boolean
    var
        CredentialManagement: Codeunit "Continia Credential Management";
    begin
        "Token Timestamp" := 0DT;
        "Expires In (ms)" := 0;
        Modify();
        exit(CredentialManagement.DeleteIsolatedStorageValue("Access Token", DataScope::Module));
    end;

    internal procedure ClearToken()
    begin
        if Get() then
            DeleteAccessTokenValue();
    end;

    internal procedure AcquireTokenFromCache(var NewAccessTokenValue: SecretText; var NewTokenTimestamp: DateTime; var NewExpiresIn: Integer; var NewNextUpdateInMs: Integer; Refresh: Boolean): Boolean
    var
        TokenExpiresIn: Integer;
    begin
        Clear(NewTokenTimestamp);
        Clear(NewAccessTokenValue);

        if Get() then
            if AccessTokenHasValue() then
                if "Token Timestamp" <> 0DT then begin
                    if Refresh then
                        TokenExpiresIn := GetTokenRefreshRateInMs("Expires In (ms)")
                    else
                        TokenExpiresIn := GetTokenExpiresInMs("Expires In (ms)");

                    if ((CurrentDateTime - "Token Timestamp") < TokenExpiresIn) then begin
                        NewAccessTokenValue := GetAccessTokenValue();
                        NewTokenTimestamp := "Token Timestamp";
                        NewExpiresIn := "Expires In (ms)";
                        NewNextUpdateInMs := GetTokenRefreshRateInMs("Expires In (ms)");
                        exit(true);
                    end;
                end;
    end;

    internal procedure SetAccessToken(Token: SecretText; ExpiresIn: Integer)
    var
        HasData: Boolean;
    begin
        ReadIsolation := IsolationLevel::UpdLock;
        HasData := Get();

        "Token Timestamp" := CurrentDateTime;
        "Expires In (ms)" := GetTokenExpiresInMs(ExpiresIn);
        SetAccessTokenValue(Token);

        if HasData then
            Modify()
        else
            Insert();
    end;

    local procedure GetTokenRefreshRateInMs(ExpiresIn: Integer): Integer
    var
        RefreshRate: Decimal;
    begin
        RefreshRate := 0.25;
        exit(Round((ExpiresIn * RefreshRate), 100, '='));
    end;

    internal procedure GetTokenExpiresInMs(ExpiresIn: Integer): Integer
    var
        RefreshRate: Decimal;
    begin
        RefreshRate := 0.95;
        exit(Round((ExpiresIn * RefreshRate), 100, '='));
    end;
}