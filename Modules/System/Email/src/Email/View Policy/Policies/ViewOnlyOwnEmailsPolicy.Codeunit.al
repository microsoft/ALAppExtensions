// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

/// <summary>
/// Email policy that show emails to a given user, 
/// if that user is author of the email.
/// </summary>
codeunit 8931 "View Only Own Emails Policy" implements "Email View Policy"
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions = tabledata "Sent Email" = r,
                  tabledata "Email Outbox" = r;

    procedure GetSentEmails(var SentEmails: Record "Sent Email" temporary)
    var
        EmailViewPolicy: Codeunit "Email View Policy";
    begin
        SentEmails.SetRange("User Security Id", UserSecurityId());
        EmailViewPolicy.GetSentEmails(SentEmails);
    end;

    procedure GetOutboxEmails(var EmailOutbox: Record "Email Outbox" temporary)
    var
        EmailViewPolicy: Codeunit "Email View Policy";
    begin
        EmailOutbox.SetRange("User Security Id", UserSecurityId());
        EmailViewPolicy.GetOutboxEmails(EmailOutbox);
    end;

    procedure GetSentEmails(SourceTableId: Integer; var SentEmails: Record "Sent Email" temporary)
    var
        SentEmailsQuery: Query "Sent Emails";
    begin
        SentEmails.SetRange("User Security Id", UserSecurityId());
        SentEmailsQuery.SetRange(SentEmailsQuery.Table_Id, SourceTableId);
        SentEmailsQuery.GetSentEmails(SentEmails);
    end;

    procedure GetOutboxEmails(SourceTableId: Integer; var EmailOutbox: Record "Email Outbox" temporary)
    var
        OutboxEmailsQuery: Query "Outbox Emails";
    begin
        EmailOutbox.SetRange("User Security Id", UserSecurityId());
        OutboxEmailsQuery.SetRange(OutboxEmailsQuery.Table_Id, SourceTableId);
        OutboxEmailsQuery.GetOutboxEmails(EmailOutbox);
    end;

    procedure GetSentEmails(SourceTableId: Integer; SourceSystemId: Guid; var SentEmails: Record "Sent Email" temporary)
    var
        SentEmailsQuery: Query "Sent Emails";
    begin
        SentEmails.SetRange("User Security Id", UserSecurityId());
        SentEmailsQuery.SetRange(SentEmailsQuery.Table_Id, SourceTableId);
        SentEmailsQuery.SetRange(SentEmailsQuery.System_Id, SourceSystemId);
        SentEmailsQuery.GetSentEmails(SentEmails);
    end;

    procedure GetOutboxEmails(SourceTableId: Integer; SourceSystemId: Guid; var EmailOutbox: Record "Email Outbox" temporary)
    var
        OutboxEmailsQuery: Query "Outbox Emails";
    begin
        EmailOutbox.SetRange("User Security Id", UserSecurityId());
        OutboxEmailsQuery.SetRange(OutboxEmailsQuery.Table_Id, SourceTableId);
        OutboxEmailsQuery.SetRange(OutboxEmailsQuery.System_Id, SourceSystemId);
        OutboxEmailsQuery.GetOutboxEmails(EmailOutbox);
    end;

    procedure HasAccess(SentEmail: Record "Sent Email"): Boolean;
    begin
        exit(SentEmail."User Security Id" = UserSecurityId());
    end;

    procedure HasAccess(EmailOutbox: Record "Email Outbox"): Boolean;
    begin
        exit(EmailOutbox."User Security Id" = UserSecurityId());
    end;

}