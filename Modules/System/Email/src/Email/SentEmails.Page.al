// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides an overview of all e-mail that were sent out.
/// </summary>
page 8883 "Sent Emails"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Sent Email For User";
    Permissions = tabledata "Sent Email" = r;
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(SentEmails)
            {
                field(Desc; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a short description of the email that was sent.';

                    trigger OnDrillDown()
                    var
                        EmailMessage: Codeunit "Email Message";
                    begin
                        EmailMessage.Find(Rec."Message Id");
                        EmailMessage.OpenInEditor(Rec."Account Id", Rec.Connector);
                    end;
                }

                field(ConnectorType; Rec.Connector)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the type email connector used to send the email.';
                }

                field(DateTimeSent; Rec."Date Time Sent")
                {
                    Caption = 'Sent';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time the email was sent.';
                }

                field(Sender; Rec.Sender)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central user who sent this email.';
                }

                field(SentFrom; Rec."Sent From")
                {
                    ApplicationArea = All;
                    Caption = 'Sent From';
                    ToolTip = 'Specifies the email address that this email was sent from.';

                    trigger OnDrillDown()
                    begin
                        ShowAccountInformation();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(Resend)
            {
                ApplicationArea = All;
                Caption = 'Resend';
                ToolTip = 'Resend the email.';
                Image = Email;
                Enabled = not NoSentEmails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    SentEmail: Record "Sent Email";
                begin
                    SentEmail.Get(Rec.Id);
                    EmailImpl.QueueEmail(SentEmail);
                    Message(EmailWasQueuedForSendingMsg);
                end;
            }

            action(EditAndSend)
            {
                ApplicationArea = All;
                Caption = 'Edit and Send';
                ToolTip = 'Edit and send the email.';
                Image = Email;
                Enabled = not NoSentEmails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    EmailMessageImpl: Codeunit "Email Message Impl.";
                begin
                    EmailMessageImpl.Find(Rec."Message Id");
                    EmailMessageImpl.OpenNewEditableCopyInEditor(Rec."Account Id", Rec.Connector);
                end;
            }

            action(Refresh)
            {
                ApplicationArea = All;
                ToolTip = 'Refresh';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    EmailImpl.RefreshSentMailForUser(EmailAccountId, NewerThanDate, Rec);
                    CurrPage.Update(false);
                    NoSentEmails := Rec.IsEmpty();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        EmailImpl.RefreshSentMailForUser(EmailAccountId, NewerThanDate, Rec);
        Rec.SetCurrentKey("Date Time Sent");
        NoSentEmails := Rec.IsEmpty();
        Rec.Ascending(false);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        SentEmail: Record "Sent Email";
    begin
        if SentEmail.Get(Rec.Id) then
            SentEmail.Delete(true);
    end;

    local procedure ShowAccountInformation()
    var
        EmailConnector: Interface "Email Connector";
    begin
        EmailConnector := Rec.Connector;
        EmailConnector.ShowAccountInformation(Rec."Account Id");
    end;

    internal procedure SetNewerThan(NewDate: DateTime)
    begin
        NewerThanDate := NewDate;
    end;

    internal procedure SetEmailAccountId(AccountId: Guid)
    begin
        EmailAccountId := AccountId;
    end;

    var
        EmailImpl: Codeunit "Email Impl";
        NewerThanDate: DateTime;
        EmailAccountId: Guid;
        NoSentEmails: Boolean;
        EmailWasQueuedForSendingMsg: Label 'The message was queued for sending.';
}