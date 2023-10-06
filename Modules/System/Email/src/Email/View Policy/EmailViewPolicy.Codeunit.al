// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

codeunit 8930 "Email View Policy"
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions = tabledata "Email View Policy" = ri,
                  tabledata "Email Outbox" = ri,
                  tabledata "Email Related Record" = r,
                  tabledata "Sent Email" = ri;

    var
        DefaultRecordCannotDeleteMsg: Label 'The default user email policy cannot be deleted.';
        InvalidPolicyErr: Label 'The provided Enail View Policy is not valid.';
        NotATempRecordErr: Label 'Expected a temporary record.';

    procedure CheckForDefaultEntry(EmailViewPolicy: Enum "Email View Policy")
    var
        EmailViewPolicyRecord: Record "Email View Policy";
        NullGuid: Guid;
    begin
        EmailViewPolicyRecord.SetRange("User Security ID", NullGuid);
        if EmailViewPolicyRecord.IsEmpty() then
            InsertDefault(EmailViewPolicy)
    end;

    procedure CheckIfCanDeleteRecord(EmailViewPolicyRecord: Record "Email View Policy"): Boolean
    begin
        if not IsNullGuid(EmailViewPolicyRecord."User Security ID") then
            exit(true);

        Message(DefaultRecordCannotDeleteMsg);
        exit(false);
    end;

    procedure GetSentEmails(var TempSentEmails: Record "Sent Email" temporary)
    var
        AllSentEmails: Record "Sent Email";
    begin
        if not TempSentEmails.IsTemporary() then
            Error(NotATempRecordErr);

        TempSentEmails.CopyFilter("Account Id", AllSentEmails."Account Id");
        TempSentEmails.CopyFilter("Date Time Sent", AllSentEmails."Date Time Sent");
        TempSentEmails.CopyFilter("User Security Id", AllSentEmails."User Security Id");
        TempSentEmails.Reset();

        if not TempSentEmails.IsEmpty() then
            TempSentEmails.DeleteAll();

        if AllSentEmails.FindSet() then
            repeat
                TempSentEmails.TransferFields(AllSentEmails);
                TempSentEmails.Insert();
            until AllSentEmails.Next() = 0;
    end;

    procedure GetOutboxEmails(var TempEmailOutbox: Record "Email Outbox" temporary)
    var
        AllEmailOutbox: Record "Email Outbox";
    begin
        if not TempEmailOutbox.IsTemporary() then
            Error(NotATempRecordErr);

        TempEmailOutbox.CopyFilter("Account Id", AllEmailOutbox."Account Id");
        TempEmailOutbox.CopyFilter(Status, AllEmailOutbox.Status);
        TempEmailOutbox.CopyFilter("User Security Id", AllEmailOutbox."User Security Id");
        TempEmailOutbox.Reset();

        if not TempEmailOutbox.IsEmpty() then
            TempEmailOutbox.DeleteAll();

        if AllEmailOutbox.FindSet() then
            repeat
                TempEmailOutbox.TransferFields(AllEmailOutbox);
                TempEmailOutbox.Insert();
            until AllEmailOutbox.Next() = 0;
    end;

    procedure GetSentEmailsBasedOnRelatedRecords(SourceTableIdFilter: Text; SourceSystemIdFilter: Text; EmailViewPolicy: Enum "Email View Policy"; var TempSentEmails: Record "Sent Email" temporary)
    var
        SentEmailsQuery: Query "Sent Emails";
        EmailMessageIdsFilter: Text;
    begin
        if not (EmailViewPolicy in [EmailViewPolicy::AllRelatedRecordsEmails, EmailViewPolicy::AnyRelatedRecordEmails]) then
            Error(InvalidPolicyErr);

        if not TempSentEmails.IsTemporary() then
            Error(NotATempRecordErr);

        TempSentEmails.DeleteAll();
        foreach EmailMessageIdsFilter in GetEmailMessageIdsFilters(SourceTableIdFilter, SourceSystemIdFilter) do begin
            SentEmailsQuery.SetFilter(SentEmailsQuery.Message_Id, EmailMessageIdsFilter);
            if EmailViewPolicy = EmailViewPolicy::AllRelatedRecordsEmails then
                SentEmailsQuery.GetSentEmailsIfAccessToAllRelatedRecords(TempSentEmails, true)
            else
                SentEmailsQuery.GetSentEmailsIfAccessToAnyRelatedRecords(TempSentEmails, true);
            SentEmailsQuery.Close();
        end;
    end;

    procedure GetEmailOutboxBasedOnRelatedRecords(SourceTableIdFilter: Text; SourceSystemIdFilter: Text; EmailViewPolicy: Enum "Email View Policy"; var TempEmailOutbox: Record "Email Outbox" temporary)
    var
        OutboxEmailsQuery: Query "Outbox Emails";
        EmailMessageIdsFilter: Text;
    begin
        if not (EmailViewPolicy in [EmailViewPolicy::AllRelatedRecordsEmails, EmailViewPolicy::AnyRelatedRecordEmails]) then
            Error(InvalidPolicyErr);

        if not TempEmailOutbox.IsTemporary() then
            Error(NotATempRecordErr);

        TempEmailOutbox.DeleteAll();
        foreach EmailMessageIdsFilter in GetEmailMessageIdsFilters(SourceTableIdFilter, SourceSystemIdFilter) do begin
            OutboxEmailsQuery.SetFilter(OutboxEmailsQuery.Message_Id, EmailMessageIdsFilter);
            if EmailViewPolicy = EmailViewPolicy::AllRelatedRecordsEmails then
                OutboxEmailsQuery.GetOutboxEmailsIfAccessToAllRelatedRecords(TempEmailOutbox, true)
            else
                OutboxEmailsQuery.GetOutboxEmailsIfAccessToAnyRelatedRecords(TempEmailOutbox, true);
            OutboxEmailsQuery.Close();
        end;
    end;

    local procedure GetEmailMessageIdsFilters(SourceTableIdFilter: Text; SourceSystemIdFilter: Text): List of [Text];
    var
        EmailRelatedRecord: Query "Email Related Record";
    begin
        EmailRelatedRecord.SetFilter(EmailRelatedRecord.Table_Id, SourceTableIdFilter);
        EmailRelatedRecord.SetFilter(EmailRelatedRecord.System_Id, SourceSystemIdFilter);
        exit(EmailRelatedRecord.GetEmailMessageIdFilters());
    end;

    local procedure InsertDefault(EmailViewPolicy: Enum "Email View Policy")
    var
        EmailViewPolicyRecord: Record "Email View Policy";
        NullGuid: Guid;
    begin
        EmailViewPolicyRecord."User ID" := CopyStr(GetDefaultUserId(), 1, 50);
        EmailViewPolicyRecord."User Security ID" := NullGuid;
        EmailViewPolicyRecord."Email View Policy" := EmailViewPolicy;
        EmailViewPolicyRecord.Insert();
    end;

    procedure GetDefaultUserId(): Text
    begin
        exit('_');
    end;
}