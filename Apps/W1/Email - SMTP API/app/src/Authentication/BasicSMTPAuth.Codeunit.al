// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4617 "Basic SMTP Auth" implements "SMTP Auth"
{
    Access = Internal;

    [NonDebuggable]
    procedure Authenticate(SmtpClient: DotNet SmtpClient; var SMTPAuthentication: Codeunit "SMTP Authentication");
    var
        CancellationToken: DotNet CancellationToken;
    begin
        SmtpClient.Authenticate(SMTPAuthentication.GetUserName(), SMTPAuthentication.GetPassword(), CancellationToken);
    end;
}