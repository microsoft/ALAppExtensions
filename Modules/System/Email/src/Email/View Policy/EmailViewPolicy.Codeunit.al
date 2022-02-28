// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8930 "Email View Policy"
{
    Access = Internal;
    Permissions = tabledata "Email View Policy" = ri,
                  tabledata "Email Outbox" = ri,
                  tabledata "Email Related Record" = r,
                  tabledata "Sent Email" = ri;

    var
        DefaultRecordCannotDeleteMsg: Label 'The default user email policy cannot be deleted.';

    procedure CheckForDefaultEntry()
    var
        EmailViewPolicyRecord: Record "Email View Policy";
    begin
        EmailViewPolicyRecord.SetRange("User ID", GetDefaultUserId());
        If EmailViewPolicyRecord.IsEmpty() then
            InsertDefault();
    end;

    procedure CheckIfCanDeleteRecord(EmailViewPolicyRecord: Record "Email View Policy"): Boolean
    begin
        if EmailViewPolicyRecord."User ID" <> GetDefaultUserId() then
            exit(true);

        Message(DefaultRecordCannotDeleteMsg);
        exit(false);
    end;

    procedure GetFilteredSentEmails(EmailRelatedRecord: Record "Email Related Record"; var AccessibleSentEmail: Record "Sent Email" temporary; var SentEmails: Record "Sent Email" temporary)
    begin
        if EmailRelatedRecord.FindSet() then
            repeat
                AccessibleSentEmail.SetCurrentKey("Message Id");
                AccessibleSentEmail.SetRange("Message Id", EmailRelatedRecord."Email Message Id");
                if AccessibleSentEmail.FindFirst() then begin
                    SentEmails := AccessibleSentEmail;
                    if SentEmails.Insert() then;
                end;
            until EmailRelatedRecord.Next() = 0;
    end;

    procedure GetFilteredOutboxEmails(EmailRelatedRecord: Record "Email Related Record"; var AccessibleEmailOutbox: Record "Email Outbox" temporary; var EmailOutbox: Record "Email Outbox" temporary)
    begin
        if EmailRelatedRecord.FindSet() then
            repeat
                AccessibleEmailOutbox.SetCurrentKey("Message Id");
                AccessibleEmailOutbox.SetRange("Message Id", EmailRelatedRecord."Email Message Id");
                if AccessibleEmailOutbox.FindFirst() then begin
                    EmailOutbox := AccessibleEmailOutbox;
                    if EmailOutbox.Insert() then;
                end;
            until EmailRelatedRecord.Next() = 0;
    end;

    local procedure InsertDefault()
    var
        EmailViewPolicyRecord: Record "Email View Policy";
        NullGuid: Guid;
    begin
        EmailViewPolicyRecord."User ID" := CopyStr(GetDefaultUserId(), 1, 50);
        EmailViewPolicyRecord."User Security ID" := NullGuid;
        EmailViewPolicyRecord."Email View Policy" := Enum::"Email View Policy"::AllRelatedRecordsEmails;
        EmailViewPolicyRecord.Insert();
    end;

    procedure GetDefaultUserId(): Text
    begin
        exit('');
    end;
}