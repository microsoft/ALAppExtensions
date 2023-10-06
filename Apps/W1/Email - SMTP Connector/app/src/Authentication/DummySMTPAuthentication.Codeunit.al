// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System;

codeunit 4517 "Dummy SMTP Authentication" implements "SMTP Authentication"
{
    ObsoleteReason = 'Dummy codeunit';
    ObsoleteState = Pending;
    ObsoleteTag = '20.0';
    Access = Internal;

    procedure Validate(var SMTPAccount: Record "SMTP Account");
    begin
        // Do nothing
    end;

    procedure Authenticate(SmtpClient: DotNet SmtpClient; SMTPAccount: Record "SMTP Account");
    begin
        // Do nothing
    end;
}