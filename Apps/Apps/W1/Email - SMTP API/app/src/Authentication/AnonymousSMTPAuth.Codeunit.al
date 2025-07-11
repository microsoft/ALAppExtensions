// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System;

codeunit 4618 "Anonymous SMTP Auth" implements "SMTP Auth"
{
    Access = Internal;

    [NonDebuggable]
    procedure Authenticate(SmtpClient: DotNet SmtpClient; var SMTPAuthentication: Codeunit "SMTP Authentication");
    begin
        // do nothing
    end;
}