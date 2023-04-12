// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Email policy that show emails to a given user, 
/// if that user has access to any of the related records on the email.
/// </summary>
codeunit 8934 "View If Any Related Records" implements "Email View Policy"
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions = tabledata "Email Related Record" = r,
                  tabledata "Sent Email" = r,
                  tabledata "Email Outbox" = r;

    procedure GetSentEmails(var SentEmails: Record "Sent Email" temporary)
    var
        SentEmailsQuery: Query "Sent Emails";
    begin
        SentEmailsQuery.GetSentEmailsIfAccessToAnyRelatedRecords(SentEmails);
    end;

    procedure GetOutboxEmails(var EmailOutbox: Record "Email Outbox" temporary)
    var
        OutboxEmailsQuery: Query "Outbox Emails";
    begin
        OutboxEmailsQuery.GetOutboxEmailsIfAccessToAnyRelatedRecords(EmailOutbox);
    end;

    procedure GetSentEmails(SourceTableId: Integer; var SentEmails: Record "Sent Email" temporary)
    var
        EmailViewPolicy: Codeunit "Email View Policy";
    begin
        EmailViewPolicy.GetSentEmailsBasedOnRelatedRecords(Format(SourceTableId), '', Enum::"Email View Policy"::AnyRelatedRecordEmails, SentEmails);
    end;

    procedure GetOutboxEmails(SourceTableId: Integer; var EmailOutbox: Record "Email Outbox" temporary)
    var
        EmailViewPolicy: Codeunit "Email View Policy";
    begin
        EmailViewPolicy.GetEmailOutboxBasedOnRelatedRecords(Format(SourceTableId), '', Enum::"Email View Policy"::AnyRelatedRecordEmails, EmailOutbox);
    end;

    procedure GetSentEmails(SourceTableId: Integer; SourceSystemId: Guid; var SentEmails: Record "Sent Email" temporary)
    var
        EmailViewPolicy: Codeunit "Email View Policy";
    begin
        EmailViewPolicy.GetSentEmailsBasedOnRelatedRecords(Format(SourceTableId), Format(SourceSystemId), Enum::"Email View Policy"::AnyRelatedRecordEmails, SentEmails);
    end;

    procedure GetOutboxEmails(SourceTableId: Integer; SourceSystemId: Guid; var EmailOutbox: Record "Email Outbox" temporary)
    var
        EmailViewPolicy: Codeunit "Email View Policy";
    begin
        EmailViewPolicy.GetEmailOutboxBasedOnRelatedRecords(Format(SourceTableId), Format(SourceSystemId), Enum::"Email View Policy"::AnyRelatedRecordEmails, EmailOutbox);
    end;

    procedure HasAccess(SentEmail: Record "Sent Email"): Boolean;
    begin
        exit(HasAccess(SentEmail."Message Id", SentEmail."User Security Id"))
    end;

    procedure HasAccess(EmailOutbox: Record "Email Outbox"): Boolean;
    begin
        exit(HasAccess(EmailOutbox."Message Id", EmailOutbox."User Security Id"))
    end;

    internal procedure HasAccess(MessageId: Guid; UserSecurityId: Guid): Boolean
    var
        EmailRelatedRecord: Record "Email Related Record";
        RecordRef: RecordRef;
    begin
        if UserSecurityId = UserSecurityId() then // Owner always has access
            exit(true);

        // Intentionally disregard relations to the Users table as every user has access to it
        EmailRelatedRecord.SetFilter("Table Id", '<>%1', Database::User);
        EmailRelatedRecord.SetFilter("Email Message Id", MessageId);

        if EmailRelatedRecord.FindSet() then
            repeat
                RecordRef.Open(EmailRelatedRecord."Table Id");
                if RecordRef.ReadPermission() then begin
                    RecordRef.Close();
                    exit(true);
                end;
                RecordRef.Close();
            until EmailRelatedRecord.Next() = 0;
        exit(false);
    end;

}