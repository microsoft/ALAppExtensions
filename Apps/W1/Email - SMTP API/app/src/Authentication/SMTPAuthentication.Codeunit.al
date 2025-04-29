// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

/// <summary>
/// Authentication details for authentication to SMTP server.
/// </summary>
codeunit 4620 "SMTP Authentication"
{
    Access = Public;

    var
        [NonDebuggable]
        Username: Text[250];
        Password: SecretText;
        AccessToken: SecretText;
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
    procedure SetBasicAuthInfo(User: Text; Pass: SecretText)
    begin
        Username := CopyStr(User, 1, MaxStrLen(Username));
        Password := Pass;
    end;

    /// <summary>
    /// Set the OAuth information for authentication
    /// </summary>
    /// <param name="User">User</param>
    /// <param name="Token">Token</param>
    procedure SetOAuth2AuthInfo(User: Text[250]; Token: SecretText)
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
    internal procedure GetPassword(): SecretText
    begin
        exit(Password);
    end;

    [NonDebuggable]
    internal procedure GetAccessToken(): SecretText
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