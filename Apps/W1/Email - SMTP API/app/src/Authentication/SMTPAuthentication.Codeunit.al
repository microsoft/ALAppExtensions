// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Authentication details for authentication to SMTP server.
/// </summary>
codeunit 4620 "SMTP Authentication"
{
    Access = Public;

    var
        [NonDebuggable]
        Username: Text[250];
        [NonDebuggable]
        Password: Text[250];
        [NonDebuggable]
        AccessToken: Text;
        [NonDebuggable]
        Server: Text[250];

    /// <summary>
    /// Set the server url.
    /// </summary>
    /// <param name="Url">Server url or ip</param>
    [NonDebuggable]
    procedure SetServer(Url: Text)
    begin
        Server := CopyStr(Url, 1, MaxStrLen(Server));
    end;

    /// <summary>
    /// Set the username and password for authentication
    /// </summary>
    /// <param name="User">Username</param>
    /// <param name="Pass">Password</param>
    [NonDebuggable]
    procedure SetBasicAuthInfo(User: Text; Pass: Text)
    begin
        // Telemetry
        Username := CopyStr(User, 1, MaxStrLen(Username));
        Password := CopyStr(Pass, 1, MaxStrLen(Password));
    end;

    /// <summary>
    /// Set the OAuth information for authentication
    /// </summary>
    /// <param name="User">User</param>
    /// <param name="Token">Token</param>
    [NonDebuggable]
    procedure SetOAuth2AuthInfo(User: Text[250]; Token: Text)
    begin
        // Telemetry
        Username := CopyStr(User, 1, MaxStrLen(Username));
        AccessToken := Token;
    end;

    [NonDebuggable]
    internal procedure GetServer(): Text[250]
    begin
        exit(Server);
    end;

    [NonDebuggable]
    internal procedure GetUserName(): Text[250]
    begin
        exit(Username);
    end;

    [NonDebuggable]
    internal procedure GetPassword(): Text[250]
    begin
        exit(Password);
    end;

    [NonDebuggable]
    internal procedure GetAccessToken(): Text
    begin
        exit(AccessToken);
    end;

    /// <summary>
    /// Provide the credentials for SMTP Setup to authenticate using OAuth 2.0.
    /// </summary>
    /// <param name="Handled">To be set true if credentials are provided for OAuth 2.0</param>
    /// <param name="UserName">Authentication user name for SMTP client. Email address of the user who is attempting to authenticate.</param>
    /// <param name="AccessToken">Acquired access token for SMTP client.</param>
    /// <param name="SMTPServer">The SMTP server of the SMTP setup.</param>
    [IntegrationEvent(false, false)]
    [NonDebuggable]
    internal procedure OnSMTPOAuth2Authenticate(var Handled: Boolean; var SMTPAuthentication: Codeunit "SMTP Authentication"; SMTPServer: Text)
    begin
    end;
}