// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Email policy that show emails to a given user, 
/// if that user is author of the email.
/// </summary>
codeunit 8931 "View Only Own Emails Policy" implements "Email View Policy"
{
    Access = Internal;
    Permissions = tabledata "Sent Email" = r,
                  tabledata "Email Outbox" = r;

    var
        EmailViewPolicy: Codeunit "Email View Policy";

    procedure GetSentEmails(var SentEmails: Record "Sent Email" temporary)
    var
        SentEmailsQuery: Query "Sent Emails";
    begin
        SentEmails.SetFilter("User Security Id", UserSecurityId());
        SentEmailsQuery.GetSentEmails(SentEmails);
    end;

    procedure GetOutboxEmails(var EmailOutbox: Record "Email Outbox" temporary)
    var
        OutboxEmailsQuery: Query "Outbox Emails";
    begin
        EmailOutbox.SetFilter("User Security Id", UserSecurityId());
        OutboxEmailsQuery.GetOutboxEmails(EmailOutbox);
    end;

    procedure GetSentEmails(SourceTableId: Integer; var SentEmails: Record "Sent Email" temporary)
    var
        TempAccessibleSentEmailsRecord: Record "Sent Email" temporary;
        EmailRelatedRecord: Record "Email Related Record";
        SentEmailsQuery: Query "Sent Emails";
    begin
        TempAccessibleSentEmailsRecord.SetFilter("User Security Id", UserSecurityId());
        SentEmailsQuery.GetSentEmails(TempAccessibleSentEmailsRecord);
        EmailRelatedRecord.SetRange("Table Id", SourceTableId);
        EmailViewPolicy.GetFilteredSentEmails(EmailRelatedRecord, TempAccessibleSentEmailsRecord, SentEmails);
    end;

    procedure GetOutboxEmails(SourceTableId: Integer; var EmailOutbox: Record "Email Outbox" temporary)
    var
        TempAccessibleEmailOutboxRecord: Record "Email Outbox" temporary;
        EmailRelatedRecord: Record "Email Related Record";
        OutboxEmailsQuery: Query "Outbox Emails";
    begin
        TempAccessibleEmailOutboxRecord.SetFilter("User Security Id", UserSecurityId());
        OutboxEmailsQuery.GetOutboxEmails(TempAccessibleEmailOutboxRecord);
        EmailRelatedRecord.SetRange("Table Id", SourceTableId);
        EmailViewPolicy.GetFilteredOutboxEmails(EmailRelatedRecord, TempAccessibleEmailOutboxRecord, EmailOutbox);
    end;

    procedure GetSentEmails(SourceTableId: Integer; SourceSystemId: Guid; var SentEmails: Record "Sent Email" temporary)
    var
        TempAccessibleSentEmailsRecord: Record "Sent Email" temporary;
        EmailRelatedRecord: Record "Email Related Record";
        SentEmailsQuery: Query "Sent Emails";
    begin
        TempAccessibleSentEmailsRecord.SetFilter("User Security Id", UserSecurityId());
        SentEmailsQuery.GetSentEmails(TempAccessibleSentEmailsRecord);
        EmailRelatedRecord.SetRange("Table Id", SourceTableId);
        EmailRelatedRecord.SetRange("System Id", SourceSystemId);
        EmailViewPolicy.GetFilteredSentEmails(EmailRelatedRecord, TempAccessibleSentEmailsRecord, SentEmails);
    end;

    procedure GetOutboxEmails(SourceTableId: Integer; SourceSystemId: Guid; var EmailOutbox: Record "Email Outbox" temporary)
    var
        TempAccessibleEmailOutboxRecord: Record "Email Outbox" temporary;
        EmailRelatedRecord: Record "Email Related Record";
        OutboxEmailsQuery: Query "Outbox Emails";
    begin
        TempAccessibleEmailOutboxRecord.SetFilter("User Security Id", UserSecurityId());
        OutboxEmailsQuery.GetOutboxEmails(TempAccessibleEmailOutboxRecord);
        EmailRelatedRecord.SetRange("Table Id", SourceTableId);
        EmailRelatedRecord.SetRange("System Id", SourceSystemId);
        EmailViewPolicy.GetFilteredOutboxEmails(EmailRelatedRecord, TempAccessibleEmailOutboxRecord, EmailOutbox);
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