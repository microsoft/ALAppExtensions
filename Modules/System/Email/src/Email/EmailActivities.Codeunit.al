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
    begin
        if not Evaluate(PastDate, Page.GetBackgroundParameters().Get('PastDate')) then
            Error(ParsePastDateErr);

        SentEmails := EmailImpl.CountSentEmails(PastDate);
        DraftOutboxEmails := EmailImpl.CountEmailsInOutbox(Enum::"Email Status"::Draft);
        FailedOutboxEmails := EmailImpl.CountEmailsInOutbox(Enum::"Email Status"::Failed);

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
}