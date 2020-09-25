// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
                ShowCaption = false;
                field("Failed Emails"; FailedOutboxEmails)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = OutboxCueStyle;
                    Caption = 'Failed Emails in Outbox';
                    ToolTip = 'View all emails that were not successfully sent by users in the current company.';


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
                    ToolTip = 'View all emails that are saved as drafts by users in the current company.';


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

    trigger OnOpenPage();
    begin
        PastDate := CreateDateTime(CalcDate('<CD-30D>', Today()), Time());
        SentEmails := EmailImpl.CountSentEmails(PastDate);

        DraftOutboxEmails := EmailImpl.CountEmailsInOutbox(Enum::"Email Status"::Draft);
        FailedOutboxEmails := EmailImpl.CountEmailsInOutbox(Enum::"Email Status"::Failed);

        if FailedOutboxEmails = 0 then
            OutboxCueStyle := 'Favorable'
        else
            OutboxCueStyle := 'Unfavorable';
    end;

    var
        EmailImpl: Codeunit "Email Impl";
        FailedOutboxEmails: Integer;
        DraftOutboxEmails: Integer;
        SentEmails: Integer;
        PastDate: DateTime;
        OutboxCueStyle: Text;
}