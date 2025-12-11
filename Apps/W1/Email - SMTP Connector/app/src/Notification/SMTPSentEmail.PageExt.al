#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

pageextension 4512 "SMTP Sent Email" extends "Sent Emails"
{
    ObsoleteReason = 'This notification is no longer needed after Exchange Basic OAuth deprecation date.';
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';

    trigger OnOpenPage()
    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
    begin
        if not SMTPConnectorImpl.SMTPBasicOAuthIsUsed() then exit;

        SMTPConnectorImpl.SendSMTPBasicOAuthObsoletionNotification();
    end;
}
#endif