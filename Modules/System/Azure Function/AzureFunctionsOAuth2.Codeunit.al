// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 7802 "Azure Functions OAuth2" implements "Azure Functions Authentication"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        [NonDebuggable]
        AuthenticationCodeGlobal, EndpointGlobal : Text;
        [NonDebuggable]
        ClientIdGlobal, ClientSecretGlobal, OAuthAuthorityUrlGlobal, RedirectURLGlobal, ResourceURLGlobal, AccessToken : Text;
        FailedToGetTokenErr: Label 'Authorization failed to Azure function: %1', Locked = true;
        AzureFunctionCategoryLbl: Label 'Connect to Azure Functions', Locked = true;

    [NonDebuggable]
    procedure Authenticate(var RequestMessage: HttpRequestMessage): Boolean
    var
        Uri: Codeunit Uri;
        OAuth2: Codeunit OAuth2;
        UriBuilder: Codeunit "Uri Builder";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Headers: HttpHeaders;
        Dimensions: Dictionary of [Text, Text];
    begin
        UriBuilder.Init(EndpointGlobal);

        OAuth2.AcquireTokenWithClientCredentials(ClientIdGlobal, ClientSecretGlobal, OAuthAuthorityUrlGlobal, RedirectURLGlobal, ResourceURLGlobal, AccessToken);

        if AccessToken = '' then begin
            UriBuilder.GetUri(Uri);
            Dimensions.Add('FunctionHost', Format(Uri.GetHost()));
            FeatureTelemetry.LogError('0000I75', AzureFunctionCategoryLbl, 'Acquiring token', StrSubstNo(FailedToGetTokenErr, Uri.GetHost()), '', Dimensions);
            exit(false);
        end;

        RequestMessage.GetHeaders(Headers);
        Headers.Remove('Authorization');
        Headers.Add('Authorization', 'Bearer ' + AccessToken);


        if AuthenticationCodeGlobal <> '' then
            UriBuilder.AddQueryParameter('Code', AuthenticationCodeGlobal);

        UriBuilder.GetUri(Uri);
        RequestMessage.SetRequestUri(Uri.GetAbsoluteUri());
        exit(true);
    end;

    [NonDebuggable]
    procedure SetAuthParameters(Endpoint: Text; AuthenticationCode: Text; ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text)
    begin
        EndpointGlobal := Endpoint;
        AuthenticationCodeGlobal := AuthenticationCode;
        ClientIdGlobal := ClientId;
        ClientSecretGlobal := ClientSecret;
        OAuthAuthorityUrlGlobal := OAuthAuthorityUrl;
        RedirectURLGlobal := RedirectURL;
        ResourceURLGlobal := ResourceURL;
    end;
}