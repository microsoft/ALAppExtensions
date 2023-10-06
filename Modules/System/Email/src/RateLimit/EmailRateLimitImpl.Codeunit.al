// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

codeunit 8999 "Email Rate Limit Impl."
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions = tabledata "Email Rate Limit" = rimd,
                    tabledata "Email Account" = r,
                    tabledata "Email Outbox" = r,
                    tabledata "Sent Email" = r;

    procedure RegisterRateLimit(var EmailRateLimit: Record "Email Rate Limit"; RegisteredAccount: Record "Email Account"; RateLimit: Integer)
    var
        NewRateLimit: Record "Email Rate Limit";
    begin
        if NewRateLimit.Get(RegisteredAccount."Account Id", RegisteredAccount.Connector) then begin
            NewRateLimit."Rate Limit" := RateLimit;
            NewRateLimit.Modify();
        end else begin
            NewRateLimit."Account Id" := RegisteredAccount."Account Id";
            NewRateLimit.Connector := RegisteredAccount.Connector;
            NewRateLimit."Email Address" := RegisteredAccount."Email Address";
            NewRateLimit."Rate Limit" := RateLimit;
            NewRateLimit.Insert();
        end;

        EmailRateLimit."Account Id" := NewRateLimit."Account Id";
        EmailRateLimit.Connector := NewRateLimit.Connector;
        EmailRateLimit."Email Address" := NewRateLimit."Email Address";
        EmailRateLimit."Rate Limit" := NewRateLimit."Rate Limit";
    end;

    procedure UpdateRateLimit(RegisteredAccount: Record "Email Account")
    var
        EmailRateLimit: Record "Email Rate Limit";
        EmailRateLimitWizard: Page "Email Rate Limit Wizard";
    begin
        EmailRateLimit.Get(RegisteredAccount."Account Id", RegisteredAccount.Connector);
        EmailRateLimitWizard.SetRecord(EmailRateLimit);
        EmailRateLimitWizard.SetEmailAccountName(RegisteredAccount.Name);
        EmailRateLimitWizard.RunModal();
    end;

    procedure IsRateLimitExceeded(AccountId: Guid; Connector: Enum "Email Connector"; EmailAddress: Text[250]; var RateLimitDuration: Duration): Boolean
    var
        SentEmail: Record "Sent Email";
        EmailOutboxCurrent: Record "Email Outbox";
        EmailImpl: Codeunit "Email Impl";
        RateLimit: Integer;
    begin
        RateLimit := GetRateLimit(AccountId, Connector, EmailAddress);
        if RateLimit = 0 then
            exit(false);

        RateLimitDuration := EmailImpl.GetEmailOutboxSentEmailWithinRateLimit(SentEmail, EmailOutboxCurrent, AccountId);
        exit((EmailOutboxCurrent.Count() + SentEmail.Count()) >= RateLimit);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"Email Rate Limit", 'ri')]
    procedure GetRateLimit(AccountId: Guid; Connector: Enum "Email Connector"; EmailAddress: Text[250]): Integer
    var
        EmailRateLimit: Record "Email Rate Limit";
    begin
        if EmailRateLimit.Get(AccountId, Connector) then
            exit(EmailRateLimit."Rate Limit");

        EmailRateLimit."Account Id" := AccountId;
        EmailRateLimit.Connector := Connector;
        EmailRateLimit."Email Address" := EmailAddress;
        EmailRateLimit."Rate Limit" := 0;
        EmailRateLimit.Insert();
        exit(EmailRateLimit."Rate Limit");
    end;
}