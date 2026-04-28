// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

codeunit 139776 "Test Outlook Email Connector" implements "Email Connector"
{
    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
    begin
    end;

    procedure GetAccounts(var Accounts: Record "Email Account")
    begin
    end;

    procedure ShowAccountInformation(AccountId: Guid)
    begin
    end;

    procedure RegisterAccount(var EmailAccount: Record "Email Account"): Boolean
    begin
    end;

    procedure DeleteAccount(AccountId: Guid): Boolean
    begin
    end;

    procedure GetLogoAsBase64(): Text
    begin
    end;

    procedure GetDescription(): Text[250]
    begin
    end;
}
