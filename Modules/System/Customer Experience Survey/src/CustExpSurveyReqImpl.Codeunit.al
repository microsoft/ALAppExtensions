// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9263 "Cust. Exp. Survey Req. Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        GraphScopesLbl: Label 'https://graph.microsoft.com/.default', Locked = true;
        GraphPPEScopesLbl: Label 'https://graph.microsoft-ppe.com/.default', Locked = true;
        AuthorityLbl: Label 'https://login.microsoftonline.com/microsoft.onmicrosoft.com', Locked = true;
        CouldNotGetAccessTokenErr: Label 'Could not get access token.', Locked = true;
        CouldNotGetGraphAccessTokenErr: Label 'Could not get graph access token. ', Locked = true;
        BearerLbl: Label 'Bearer %1', Locked = true, Comment = '%1 - Bearer token';
        CategoryTok: Label 'Customer Experience Survey', Locked = true;
        FailedGetRequestErr: Label 'GET %1 request failed with status code %2. Error message: %3', Locked = true, Comment = '%1 - Request, %2 - HTTP status code, %3 - Error message';
        FailedPostRequestErr: Label 'POST %1 request failed with status code %2. Error message: %3', Locked = true, Comment = '%1 - Request, %2 - HTTP status code, %3 - Error message';
        GetRequestSuccessfulLbl: Label 'GET %1 request was successful.', Locked = true, Comment = '%1 - Request';
        PostRequestSuccessfulLbl: Label 'POST %1 request was successful.', Locked = true, Comment = '%1 - Request';
        MissingClientIdOrCertificateTelemetryTxt: Label 'The client id or certificate have not been initialized.', Locked = true;
        MissingScopeTelemetryTxt: Label 'The scope have not been initialized.', Locked = true;
        ClientIdAKVSecretNameLbl: Label 'bctocesappid', Locked = true;
        ClientCertificateAKVSecretNameLbl: Label 'bctocesappcertificatename', Locked = true;
        ScopeAKVSecretNameLbl: Label 'bctocesappscope', Locked = true;
        AcquiredCESTokenLbl: Label 'AcquireTokensWithCertificate call was successful.', Locked = true;
        AcquiredGraphTokenLbl: Label 'AcquireOnBehalfOfToken call was successful.', Locked = true;

    [TryFunction]
    internal procedure TryGet(RequestUri: Text; var ResponseJsonObject: JsonObject; var ErrorMessage: Text; IsGraph: Boolean)
    var
        IsHandled: Boolean;
    begin
        OnGetRequest(RequestUri, ResponseJsonObject, ErrorMessage, IsGraph, IsHandled);
        if IsHandled then
            exit(true);

        if not Get(RequestUri, ResponseJsonObject, ErrorMessage, IsGraph) then
            Error('');
    end;

    [TryFunction]
    internal procedure TryPost(RequestUri: Text; var ResponseJsonObject: JsonObject; var ErrorMessage: Text)
    var
        IsHandled: Boolean;
    begin
        OnPostRequest(RequestUri, ResponseJsonObject, ErrorMessage, IsHandled);
        if IsHandled then
            exit(true);

        if not Post(RequestUri, ResponseJsonObject, ErrorMessage) then
            Error('');
    end;

    [NonDebuggable]
    local procedure Get(RequestUri: Text; var ResponseJsonObject: JsonObject; var ErrorMessage: Text; IsGraph: Boolean): Boolean
    var
        CustomerExpSurveyImpl: Codeunit "Customer Exp. Survey Impl.";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpResponseMessage: HttpResponseMessage;
        JsonContent: Text;
        StatusCode: Integer;
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Accept', 'application/json');
        if not Authorize(HttpHeaders, ErrorMessage, IsGraph) then
            exit(false);

        if not HttpClient.Get(RequestUri, HttpResponseMessage) then begin
            ErrorMessage := StrSubstNo(FailedGetRequestErr, RequestUri, '-', '-');
            exit(false);
        end;

        StatusCode := HttpResponseMessage.HttpStatusCode();
        if StatusCode <> 200 then begin
            ErrorMessage := StrSubstNo(FailedGetRequestErr, RequestUri, StatusCode, GetHttpErrorMessageAsText(HttpResponseMessage, IsGraph));
            exit(false);
        end;

        if HttpResponseMessage.Content.ReadAs(JsonContent) then
            if ResponseJsonObject.ReadFrom(JsonContent) then begin
                Session.LogMessage('0000J98', CustomerExpSurveyImpl.RemoveUserIdFromMessage(StrSubstNo(GetRequestSuccessfulLbl, RequestUri)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(true);
            end;

        ErrorMessage := StrSubstNo(FailedGetRequestErr, RequestUri, StatusCode, '-');
    end;

    [NonDebuggable]
    local procedure Post(RequestUri: Text; var ResponseJsonObject: JsonObject; var ErrorMessage: Text): Boolean
    var
        CustomerExpSurveyImpl: Codeunit "Customer Exp. Survey Impl.";
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        RequestHttpHeaders: HttpHeaders;
        ContentHttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        JsonContent: Text;
        StatusCode: Integer;
    begin
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(RequestUri);
        HttpRequestMessage.GetHeaders(RequestHttpHeaders);
        if not Authorize(RequestHttpHeaders, ErrorMessage, false) then
            exit(false);

        HttpContent.WriteFrom(JsonContent);
        HttpContent.GetHeaders(ContentHttpHeaders);
        ContentHttpHeaders.Clear();
        ContentHttpHeaders.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            ErrorMessage := StrSubstNo(FailedPostRequestErr, RequestUri, '-', '-');
            exit(false);
        end;

        StatusCode := HttpResponseMessage.HttpStatusCode();
        if (StatusCode <> 200) and (StatusCode <> 201) then begin
            ErrorMessage := StrSubstNo(FailedPostRequestErr, RequestUri, StatusCode, GetHttpErrorMessageAsText(HttpResponseMessage, false));
            exit(false);
        end;

        if HttpResponseMessage.Content.ReadAs(JsonContent) then
            if ResponseJsonObject.ReadFrom(JsonContent) then begin
                Session.LogMessage('0000J99', CustomerExpSurveyImpl.RemoveUserIdFromMessage(StrSubstNo(PostRequestSuccessfulLbl, RequestUri)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(true);
            end;

        ErrorMessage := StrSubstNo(FailedPostRequestErr, RequestUri, StatusCode, '-');
    end;

    [NonDebuggable]
    local procedure GetHttpErrorMessageAsText(var HttpResponseMessage: HttpResponseMessage; IsGraph: Boolean): Text
    var
        ErrorMessage: Text;
    begin
        if TryGetErrorMessage(HttpResponseMessage, ErrorMessage, IsGraph) then
            exit(ErrorMessage);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetErrorMessage(var HttpResponseMessage: HttpResponseMessage; var ErrorMessage: Text; IsGraph: Boolean)
    var
        ResponseJsonText: Text;
        JToken: JsonToken;
        ResponseJsonObject: JsonObject;
    begin
        HttpResponseMessage.Content.ReadAs(ResponseJsonText);
        ResponseJsonObject.ReadFrom(ResponseJsonText);
        if IsGraph then begin
            ResponseJsonObject.Get('error', JToken);
            JToken.AsObject().Get('message', JToken);
        end else
            ResponseJsonObject.Get('Message', JToken);

        ErrorMessage := JToken.AsValue().AsText();
    end;

    [NonDebuggable]
    local procedure Authorize(var HttpHeaders: HttpHeaders; var ErrorMessage: Text; IsGraph: Boolean): Boolean
    var
        AccessToken: Text;
    begin
        if IsGraph then
            AccessToken := AcquireGraphToken(ErrorMessage)
        else
            AccessToken := AcquireToken(ErrorMessage);

        if AccessToken <> '' then begin
            HttpHeaders.Add('Authorization', StrSubstNo(BearerLbl, AccessToken));
            exit(true);
        end;

        if IsGraph then
            Session.LogMessage('0000JC5', CouldNotGetGraphAccessTokenErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            Session.LogMessage('0000J9A', CouldNotGetAccessTokenErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    [NonDebuggable]
    local procedure AcquireToken(var ErrorMessage: Text): Text
    var
        OAuth2: Codeunit OAuth2;
        Scopes: List of [Text];
        ClientId: Text;
        ClientCertificate: Text;
        AccessToken: Text;
        IdToken: Text;
    begin
        ClientId := GetClientId();
        ClientCertificate := GetClientCertificate();
        Scopes.Add(GetScope());

        if (ClientId <> '') and (ClientCertificate <> '') then
            if OAuth2.AcquireTokensWithCertificate(ClientId, ClientCertificate, GetRedirectURL(), AuthorityLbl, Scopes, AccessToken, IdToken) then begin
                Session.LogMessage('0000J9B', AcquiredCESTokenLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(AccessToken);
            end;

        ErrorMessage := GetLastErrorText();
    end;

    [NonDebuggable]
    local procedure AcquireGraphToken(var ErrorMessage: Text): Text
    var
        OAuth2: Codeunit OAuth2;
        CustomerExpSurveyImpl: Codeunit "Customer Exp. Survey Impl.";
        Scopes: List of [Text];
        AccessToken: Text;
    begin
        if not CustomerExpSurveyImpl.IsPPE() then
            Scopes.Add(GraphScopesLbl)
        else
            Scopes.Add(GraphPPEScopesLbl);

        if OAuth2.AcquireOnBehalfOfToken(GetRedirectURL(), Scopes, AccessToken) then begin
            Session.LogMessage('0000J9C', AcquiredGraphTokenLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(AccessToken);
        end else
            ErrorMessage := GetLastErrorText();
    end;

    [NonDebuggable]
    local procedure GetRedirectURL(): Text
    var
        OAuth2: Codeunit OAuth2;
        RedirectURL: Text;
    begin
        OAuth2.GetDefaultRedirectUrl(RedirectUrl);
        exit(RedirectURL)
    end;

    [NonDebuggable]
    local procedure GetClientId(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        ClientId: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(ClientIdAKVSecretNameLbl, ClientId) then
            Session.LogMessage('0000J9D', MissingClientIdOrCertificateTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            exit(ClientId);
    end;

    [NonDebuggable]
    local procedure GetClientCertificate(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        Certificate: Text;
        CertificateName: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(ClientCertificateAKVSecretNameLbl, CertificateName) then begin
            Session.LogMessage('0000J9E', MissingClientIdOrCertificateTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(Certificate);
        end;

        if not AzureKeyVault.GetAzureKeyVaultCertificate(CertificateName, Certificate) then
            Session.LogMessage('0000J9F', MissingClientIdOrCertificateTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        exit(Certificate);
    end;

    [NonDebuggable]
    local procedure GetScope(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        Scope: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(ScopeAKVSecretNameLbl, Scope) then
            Session.LogMessage('0000JRJ', MissingScopeTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok)
        else
            exit(Scope);
    end;

    [InternalEvent(false)]
    local procedure OnGetRequest(RequestUri: Text; var ResponseJsonObject: JsonObject; var ErrorMessage: Text; IsGraph: Boolean; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    local procedure OnPostRequest(RequestUri: Text; var ResponseJsonObject: JsonObject; var ErrorMessage: Text; var IsHandled: Boolean)
    begin
    end;
}