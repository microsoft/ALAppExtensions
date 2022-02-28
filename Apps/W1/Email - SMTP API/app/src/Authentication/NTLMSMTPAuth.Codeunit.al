// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4619 "NTLM SMTP Auth" implements "SMTP Auth"
{
    Access = Internal;

    [NonDebuggable]
    procedure Authenticate(SmtpClient: DotNet SmtpClient; var SMTPAuthentication: Codeunit "SMTP Authentication");
    var
        CancellationToken: DotNet CancellationToken;
        SaslMechanismNtlm: DotNet SaslMechanismNtlm;
    begin
        SaslMechanismNtlm := SaslMechanismNtlm.SaslMechanismNtlm(SMTPAuthentication.GetUserName(), SMTPAuthentication.GetPassword());
        SmtpClient.Authenticate(SaslMechanismNtlm, CancellationToken);
    end;
}