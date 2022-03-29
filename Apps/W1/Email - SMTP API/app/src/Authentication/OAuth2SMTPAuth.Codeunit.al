// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4616 "OAuth2 SMTP Auth" implements "SMTP Auth"
{
    Access = Internal;

    var
        NoOAuth2ProviderErr: Label 'No extension provided the OAuth 2.0 authentication.';

    [NonDebuggable]
    procedure Authenticate(SmtpClient: DotNet SmtpClient; var SMTPAuthentication: Codeunit "SMTP Authentication");
    var
        DotNetSaslMechanismOAuth2: DotNet SaslMechanismOAuth2;
        CancellationToken: DotNet CancellationToken;
        Handled: Boolean;
        AccessToken: Text;
        UserName: Text;
    begin
        // Get authentication from subscriber
        SMTPAuthentication.OnSMTPOAuth2Authenticate(Handled, SMTPAuthentication, SMTPAuthentication.GetServer());

        if not Handled then
            Error(NoOAuth2ProviderErr);

        UserName := SMTPAuthentication.GetUserName();
        AccessToken := SMTPAuthentication.GetAccessToken();

        DotNetSaslMechanismOAuth2 := DotNetSaslMechanismOAuth2.SaslMechanismOAuth2(UserName, AccessToken);
        SmtpClient.Authenticate(DotNetSaslMechanismOAuth2, CancellationToken);
    end;
}