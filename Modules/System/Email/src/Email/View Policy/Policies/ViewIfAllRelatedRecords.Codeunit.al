// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Email policy that show emails to a given user, 
/// if that user has access to all of the related records on the email.
/// </summary>
codeunit 8933 "View If All Related Records" implements "Email View Policy"
{
    Access = Internal;
    Permissions = tabledata "Email Related Record" = r,
                  tabledata "Sent Email" = r,
                  tabledata "Email Outbox" = r;

    var
        EmailViewPolicy: Codeunit "Email View Policy";

    procedure GetSentEmails(var SentEmails: Record "Sent Email" temporary)
    var
        SentEmailsQuery: Query "Sent Emails";
    begin
        SentEmailsQuery.GetSentEmailsIfAccessToAllRelatedRecords(SentEmails);
    end;

    procedure GetOutboxEmails(var EmailOutbox: Record "Email Outbox" temporary)
    var
        OutboxEmailsQuery: Query "Outbox Emails";
    begin
        OutboxEmailsQuery.GetOutboxEmailsIfAccessToAllRelatedRecords(EmailOutbox);
    end;

    procedure GetSentEmails(SourceTableId: Integer; var SentEmails: Record "Sent Email" temporary)
    var
        TempAccessibleSentEmailsRecord: Record "Sent Email" temporary;
        EmailRelatedRecord: Record "Email Related Record";
        SentEmailsQuery: Query "Sent Emails";
    begin
        SentEmailsQuery.GetSentEmailsIfAccessToAllRelatedRecords(TempAccessibleSentEmailsRecord);
        EmailRelatedRecord.SetRange("Table Id", SourceTableId);
        EmailViewPolicy.GetFilteredSentEmails(EmailRelatedRecord, TempAccessibleSentEmailsRecord, SentEmails);
    end;

    procedure GetOutboxEmails(SourceTableId: Integer; var EmailOutbox: Record "Email Outbox" temporary)
    var
        TempAccessibleEmailOutboxRecord: Record "Email Outbox" temporary;
        EmailRelatedRecord: Record "Email Related Record";
        OutboxEmailsQuery: Query "Outbox Emails";
    begin
        OutboxEmailsQuery.GetOutboxEmailsIfAccessToAllRelatedRecords(TempAccessibleEmailOutboxRecord);
        EmailRelatedRecord.SetRange("Table Id", SourceTableId);
        EmailViewPolicy.GetFilteredOutboxEmails(EmailRelatedRecord, TempAccessibleEmailOutboxRecord, EmailOutbox);
    end;

    procedure GetSentEmails(SourceTableId: Integer; SourceSystemId: Guid; var SentEmails: Record "Sent Email" temporary)
    var
        TempAccessibleSentEmailsRecord: Record "Sent Email" temporary;
        EmailRelatedRecord: Record "Email Related Record";
        SentEmailsQuery: Query "Sent Emails";
    begin
        SentEmailsQuery.GetSentEmailsIfAccessToAllRelatedRecords(TempAccessibleSentEmailsRecord);
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
        OutboxEmailsQuery.GetOutboxEmailsIfAccessToAllRelatedRecords(TempAccessibleEmailOutboxRecord);
        EmailRelatedRecord.SetRange("Table Id", SourceTableId);
        EmailRelatedRecord.SetRange("System Id", SourceSystemId);
        EmailViewPolicy.GetFilteredOutboxEmails(EmailRelatedRecord, TempAccessibleEmailOutboxRecord, EmailOutbox);
    end;

    procedure HasAccess(SentEmail: Record "Sent Email"): Boolean;
    begin
        exit(HasAccess(SentEmail."Message Id", SentEmail."User Security Id"));
    end;

    procedure HasAccess(EmailOutbox: Record "Email Outbox"): Boolean;
    begin
        exit(HasAccess(EmailOutbox."Message Id", EmailOutbox."User Security Id"));
    end;

    internal procedure HasAccess(MessageId: Guid; UserSecurityId: Guid): Boolean
    var
        EmailRelatedRecord: Record "Email Related Record";
        RecordRef: RecordRef;
    begin
        if UserSecurityId = UserSecurityId() then // Owner always has access
            exit(true);

        EmailRelatedRecord.SetFilter("Email Message Id", MessageId);
        if EmailRelatedRecord.FindSet() then begin
            repeat
                RecordRef.Open(EmailRelatedRecord."Table Id");
                if not RecordRef.ReadPermission() then begin
                    RecordRef.Close();
                    exit(false);
                end;
                RecordRef.Close();
            until EmailRelatedRecord.Next() = 0;
            exit(true);
        end;
        exit(false);
    end;

}