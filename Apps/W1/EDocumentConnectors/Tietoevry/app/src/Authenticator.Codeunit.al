// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using System.Security.Authentication;
codeunit 6394 "Authenticator"
{
    Access = Internal;
    Permissions = tabledata "OAuth 2.0 Setup" = im,
        tabledata "Connection Setup" = rim;

    procedure CreateConnectionSetupRecord()
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        if not ConnectionSetup.Get() then begin
            ConnectionSetup."Authentication URL" := this.AuthURLTxt;
            ConnectionSetup."API URL" := this.APIURLTxt;
            ConnectionSetup."Sandbox Authentication URL" := this.SandboxAuthURLTxt;
            ConnectionSetup."Sandbox API URL" := this.SandboxAPIURLTxt;
            ConnectionSetup."Send Mode" := ConnectionSetup."Send Mode"::Test; //Sandbox
            ConnectionSetup.Insert();
        end;
    end;

    procedure SetClientId(var ClientIdKey: Guid; ClientID: SecretText)
    begin
        this.SetIsolatedStorageValue(ClientIdKey, ClientID, DataScope::Company);
    end;

    procedure SetClientSecret(var ClienSecretKey: Guid; ClientSecret: SecretText)
    begin
        this.SetIsolatedStorageValue(ClienSecretKey, ClientSecret, DataScope::Company);
    end;

    procedure GetAccessToken() Token: SecretText
    var
        ConnectionSetup: Record "Connection Setup";
        Requests: Codeunit Requests;
        ExpiresIn: Integer;
        ClientId, ClientSecret, TokenTxt, Response : SecretText;
        TokenKey: Guid;
    begin
        ConnectionSetup.Get();

        // Reuse token if it lives longer than 1 min in future
        if (ConnectionSetup."Token Expiry" > CurrentDateTime() + 60 * 1000) and (not IsNullGuid(ConnectionSetup."Token - Key")) then
            if this.GetTokenValue(ConnectionSetup."Token - Key", Token, DataScope::Company) then
                exit;

        if not this.GetTokenValue(ConnectionSetup."Client ID - Key", ClientId, DataScope::Company) then
            Error(this.TietoevryClientIdErr, ConnectionSetup.TableCaption);

        if not this.GetTokenValue(ConnectionSetup."Client Secret - Key", ClientSecret, DataScope::Company) then
            Error(this.TietoevryClientSecretErr, ConnectionSetup.TableCaption);

        Requests.Init();
        Requests.CreateAuthenticateRequest(ClientId, ClientSecret);
        this.ExecuteResponse(Requests, Response);
        if not this.ParseResponse(Response, TokenTxt, ExpiresIn) then
            Error(this.TietoevryParseTokenErr);

        // Save token for reuse
        this.SetIsolatedStorageValue(TokenKey, TokenTxt, DataScope::Company);
        // Read again as we want fresh record to modify
        ConnectionSetup.Get();
        ConnectionSetup."Token - Key" := TokenKey;
        ConnectionSetup."Token Expiry" := CurrentDateTime() + ExpiresIn * 1000;
        ConnectionSetup.Modify();
        Commit();
        exit(TokenTxt);
    end;

    [NonDebuggable]
    local procedure ExecuteResponse(var Request: Codeunit Requests; var Response: SecretText)
    var
        HttpExecutor: Codeunit "Http Executor";
    begin
        Response := HttpExecutor.ExecuteHttpRequest(Request);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure ParseResponse(Response: SecretText; var Token: SecretText; var ExpiresIn: Integer)
    var
        ResponseJson: JsonObject;
        TokenJson, ExpiryJson : JsonToken;
    begin
        ResponseJson.ReadFrom(Response.Unwrap());
        ResponseJson.Get('access_token', TokenJson);
        Token := TokenJson.AsValue().AsText();
        ResponseJson.Get('expires_in', ExpiryJson);
        ExpiresIn := ExpiryJson.AsValue().AsInteger();
    end;

    procedure IsClientCredsSet(var ClientId: Text; var ClientSecret: Text): Boolean
    var
        ConnectionSetup: Record "Connection Setup";
    begin
        ConnectionSetup.Get();

        if this.HasToken(ConnectionSetup."Client ID - Key", DataScope::Company) then
            ClientId := '*';
        if this.HasToken(ConnectionSetup."Client Secret - Key", DataScope::Company) then
            ClientSecret := '*';
    end;

    procedure SetIsolatedStorageValue(var ValueKey: Guid; Value: SecretText; TokenDataScope: DataScope)
    begin
        if IsNullGuid(ValueKey) then
            ValueKey := CreateGuid();

        IsolatedStorage.Set(ValueKey, Value, TokenDataScope);
    end;

    local procedure GetTokenValue(TokenKey: Text; var TokenValueAsSecret: SecretText; TokenDataScope: DataScope): Boolean
    begin
        if not this.HasToken(TokenKey, TokenDataScope) then
            exit(false);

        exit(IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValueAsSecret));
    end;

    local procedure HasToken(TokenKey: Text; TokenDataScope: DataScope): Boolean
    begin
        exit(IsolatedStorage.Contains(TokenKey, TokenDataScope));
    end;

    var
        AuthURLTxt: Label 'https://auth.infotorg.no/auth/realms/fms-realm/protocol/openid-connect', Locked = true;
        APIURLTxt: Label 'https://accesspoint-api.dataplatfor.ms', Locked = true;
        SandboxAuthURLTxt: Label 'https://auth-qa.infotorg.no/auth/realms/fms-realm/protocol/openid-connect', Locked = true;
        SandboxAPIURLTxt: Label 'https://accesspoint-api.qa.dataplatfor.ms', Locked = true;
        TietoevryClientIdErr: Label 'Tietoevry Client Id is not set in %1', Comment = '%1 - Client id';
        TietoevryClientSecretErr: Label 'Tietoevry Client Secret is not set in %1', Comment = '%1 - Client secret';
        TietoevryParseTokenErr: Label 'Failed to parse response for Tietoevry Access token request';
}