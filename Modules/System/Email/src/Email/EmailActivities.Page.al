// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides information about the status of the emails.
/// </summary>
page 8885 "Email Activities"
{
    PageType = CardPart;
    Caption = 'Email Status';

    layout
    {
        area(content)
        {
            cuegroup(OutboxCueContainer)
            {
                Caption = 'Email Activities';

                field("Failed Emails"; FailedOutboxEmails)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OutboxCueStyle;
                    Caption = 'Failed Emails in Outbox';
                    ToolTip = 'View all emails that were not successfully sent.';


                    trigger OnDrillDown()
                    var
                        OutboxPage: Page "Email Outbox";
                    begin
                        OutboxPage.SetEmailStatus(Enum::"Email Status"::Failed);
                        OutboxPage.Run();
                    end;
                }

                field("Draft Emails"; DraftOutboxEmails)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Draft Emails in Outbox';
                    ToolTip = 'View all emails that are saved as drafts.';


                    trigger OnDrillDown()
                    var
                        OutboxPage: Page "Email Outbox";
                    begin
                        OutboxPage.SetEmailStatus(Enum::"Email Status"::Draft);
                        OutboxPage.Run();
                    end;
                }

                field("Sent Emails"; SentEmails)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sent Emails Last 30 Days';
                    ToolTip = 'Sent Emails Last 30 Days';

                    trigger OnDrillDown()
                    var
                        SentEmailsPage: Page "Sent Emails";
                    begin
                        SentEmailsPage.SetNewerThan(PastDate);
                        SentEmailsPage.Run();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        EmailAccountImpl: Codeunit "Email Account Impl.";
        TaskParameters: Dictionary of [Text, Text];
    begin
        PastDate := CreateDateTime(CalcDate('<-30D>', Today()), Time());
        TaskParameters.Add('PastDate', Format(PastDate));
        TaskParameters.Add('Admin', Format(EmailAccountImpl.IsUserEmailAdmin()));

        CurrPage.EnqueueBackgroundTask(EmailActivitiesTaskId, Codeunit::"Email Activities", TaskParameters, 60000, PageBackgroundTaskErrorLevel::Warning);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        EmailActivities: Codeunit "Email Activities";
    begin
        if TaskId = EmailActivitiesTaskId then begin
            Evaluate(SentEmails, Results.Get(EmailActivities.GetSentEmailsKey()));
            Evaluate(DraftOutboxEmails, Results.Get(EmailActivities.GetDraftEmailsKey()));
            Evaluate(FailedOutboxEmails, Results.Get(EmailActivities.GetFailedEmailsKey()));

            if FailedOutboxEmails = 0 then
                OutboxCueStyle := 'Favorable'
            else
                OutboxCueStyle := 'Unfavorable';
        end;
    end;

    var
        EmailActivitiesTaskId: Integer;
        FailedOutboxEmails: Integer;
        DraftOutboxEmails: Integer;
        SentEmails: Integer;
        PastDate: DateTime;
        OutboxCueStyle: Text;
}