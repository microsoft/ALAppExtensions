// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8885 "Email Activities"
{
    Access = Internal;

    trigger OnRun()
    var
        EmailImpl: Codeunit "Email Impl";
        Result: Dictionary of [Text, Text];
        SentEmails: Integer;
        DraftOutboxEmails: Integer;
        FailedOutboxEmails: Integer;
        PastDate: DateTime;
        IsAdmin: Boolean;
    begin
        if not Evaluate(PastDate, Page.GetBackgroundParameters().Get('PastDate')) then
            Error(ParsePastDateErr);

        if not Evaluate(IsAdmin, Page.GetBackgroundParameters().Get('Admin')) then
            Error(ParseAdminErr);

        SentEmails := EmailImpl.CountSentEmails(PastDate, IsAdmin);
        DraftOutboxEmails := EmailImpl.CountEmailsInOutbox(Enum::"Email Status"::Draft, IsAdmin);
        FailedOutboxEmails := EmailImpl.CountEmailsInOutbox(Enum::"Email Status"::Failed, IsAdmin);

        Result.Add(GetSentEmailsKey(), Format(SentEmails));
        Result.Add(GetDraftEmailsKey(), Format(DraftOutboxEmails));
        Result.Add(GetFailedEmailsKey(), Format(FailedOutboxEmails));

        Page.SetBackgroundTaskResult(Result);
    end;

    internal procedure GetSentEmailsKey(): Text
    begin
        exit('sent');
    end;

    internal procedure GetDraftEmailsKey(): Text
    begin
        exit('drafts');
    end;

    internal procedure GetFailedEmailsKey(): Text
    begin
        exit('failed');
    end;

    var
        ParsePastDateErr: Label 'Could not parse parameter PastDate.';
        ParseAdminErr: Label 'Could not parse parameter Admin.';
}