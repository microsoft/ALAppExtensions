// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 1289 "OAuth Impl."
{
    Access = Internal;
    SingleInstance = false;

    var
        TelemetrySecurityTok: Label 'AL Security', Locked = true;
        WeakHashFunctionTxt: Label 'Use of weak hash function', Locked = true;

    [TryFunction]
    [NonDebuggable]
    procedure GetRequestToken(ConsumerKey: Text; ConsumerSecret: Text; RequestTokenUrl: Text; CallbackUrl: Text; var AccessTokenKey: Text; var AccessTokenSecret: Text)
    var
        OAuthAuthorization: DotNet OAuthAuthorization;
        Consumer: DotNet Consumer;
        Token: DotNet Token;
        RequestToken: DotNet Token;
    begin
        Token := Token.Token('', '');
        Consumer := Consumer.Consumer(ConsumerKey, ConsumerSecret);
        OAuthAuthorization := OAuthAuthorization.OAuthAuthorization(Consumer, Token);

        RequestToken := OAuthAuthorization.GetRequestToken(RequestTokenUrl, CallbackUrl);

        AccessTokenKey := RequestToken.TokenKey();
        AccessTokenSecret := RequestToken.TokenSecret();

    end;


    [TryFunction]
    [NonDebuggable]
    procedure GetAccessToken(ConsumerKey: Text; ConsumerSecret: Text; RequestTokenUrl: Text; Verifier: Text; RequestTokenKey: Text; RequestTokenSecret: Text; var AccessTokenKey: Text; var AccessTokenSecret: Text)
    var
        OAuthAuthorization: DotNet OAuthAuthorization;
        Consumer: DotNet Consumer;
        RequestToken: DotNet Token;
        AccessToken: DotNet Token;
    begin
        RequestToken := RequestToken.Token(RequestTokenKey, RequestTokenSecret);
        Consumer := Consumer.Consumer(ConsumerKey, ConsumerSecret);
        OAuthAuthorization := OAuthAuthorization.OAuthAuthorization(Consumer, RequestToken);

        AccessToken := OAuthAuthorization.GetAccessToken(RequestTokenUrl, Verifier);

        AccessTokenKey := AccessToken.TokenKey();
        AccessTokenSecret := AccessToken.TokenSecret();

    end;

    [TryFunction]
    [NonDebuggable]
    procedure GetAuthorizationHeader(ConsumerKey: Text; ConsumerSecret: Text; RequestTokenKey: Text; RequestTokenSecret: Text; RequestUrl: Text; RequestMethod: Enum "Http Request Type"; var AuthorizationHeader: Text)
    var
        OAuthAuthorization: DotNet OAuthAuthorization;
        Consumer: DotNet Consumer;
        RequestToken: DotNet Token;
    begin
        RequestToken := RequestToken.Token(RequestTokenKey, RequestTokenSecret);
        Consumer := Consumer.Consumer(ConsumerKey, ConsumerSecret);
        OAuthAuthorization := OAuthAuthorization.OAuthAuthorization(Consumer, RequestToken);

        case RequestMethod of
            RequestMethod::GET:
                AuthorizationHeader := OAuthAuthorization.GetAuthorizationHeader(RequestUrl, 'GET');
            RequestMethod::POST:
                AuthorizationHeader := OAuthAuthorization.GetAuthorizationHeader(RequestUrl, 'POST');
            RequestMethod::PATCH:
                AuthorizationHeader := OAuthAuthorization.GetAuthorizationHeader(RequestUrl, 'PATCH');
            RequestMethod::PUT:
                AuthorizationHeader := OAuthAuthorization.GetAuthorizationHeader(RequestUrl, 'PUT');
            RequestMethod::DELETE:
                AuthorizationHeader := OAuthAuthorization.GetAuthorizationHeader(RequestUrl, 'DELETE');
        end;
        Session.LogMessage('0000ED2', WeakHashFunctionTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetrySecurityTok);
    end;

}

