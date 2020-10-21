// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays information about email that are queued for sending.
/// </summary>
page 8882 "Email Outbox"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Email Outbox";
    SourceTableTemporary = true;
    AdditionalSearchTerms = 'draft email';
    Permissions = tabledata "Email Outbox" = rd;
    RefreshOnActivate = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    Extensible = true;

    layout
    {
        area(Content)
        {
            repeater(Outbox)
            {
                field(Desc; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of email.';

                    trigger OnDrillDown()
                    var
                        EmailEditor: Codeunit "Email Editor";
                    begin
                        RefreshOutbox := true;

                        EmailEditor.Open(Rec, false);
                    end;
                }

                field(Connector; Rec.Connector)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the extension that will be used to send the email.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email job status.';
                }

                field(Error; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email error message.';
                }

                field(Sender; Rec.Sender)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who triggered this email to be sent.';
                }

                field(SentFrom; Rec."Send From")
                {
                    ApplicationArea = All;
                    Caption = 'Sent From';
                    ToolTip = 'Specifies the email address that this email was sent from.';

                    trigger OnDrillDown()
                    begin
                        ShowAccountInformation();
                    end;
                }

                field("Date Queued"; "Date Queued")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when this email was queued up to be sent.';
                }

                field("Date Failed"; "Date Failed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when this email failed to send.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ShowError)
            {
                ApplicationArea = All;
                Image = Error;
                Caption = 'Show Error';
                ToolTip = 'Show Error.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Enabled = FailedStatus;

                trigger OnAction()
                begin
                    Message(Rec."Error Message");
                end;
            }

            action(ShowErrorCallStack)
            {
                ApplicationArea = All;
                Image = ShowList;
                Caption = 'Investigate Error';
                ToolTip = 'View technical details about the error callstack to troubleshoot email errors.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Enabled = FailedStatus;

                trigger OnAction()
                begin
                    Message(EmailImpl.FindLastErrorCallStack(Rec.Id));
                end;
            }
        }

        area(Processing)
        {
            action(SendEmail)
            {
                ApplicationArea = All;
                Caption = 'Send';
                ToolTip = 'Send the email for processing. The status will change to Pending until it''s processed. If the email is successfully sent, it will no longer display in your Outbox.';
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Enabled = not NoEmailsInOutbox;

                trigger OnAction()
                var
                    EmailMessage: Codeunit "Email Message";
                begin
                    EmailMessage.Get(Rec."Message Id");
                    EmailImpl.Enqueue(EmailMessage, Rec."Account Id", Rec.Connector);

                    LoadEmailOutboxForUser();
                    CurrPage.Update(false);
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
                    LoadEmailOutboxForUser();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        LoadEmailOutboxForUser();
    end;

    trigger OnAfterGetRecord()
    begin
        // Updating the outbox for user is done via OnAfterGetRecord in the cases when an Email Message was changed from the Email Editor page.
        if RefreshOutbox then begin
            RefreshOutbox := false;
            LoadEmailOutboxForUser();
        end;

        FailedStatus := Rec.Status = Rec.Status::Failed;
        NoEmailsInOutbox := false;
    end;

    trigger OnDeleteRecord(): Boolean
    var
        EmailOutbox: Record "Email Outbox";
    begin
        if EmailOutbox.Get(Rec.Id) then
            EmailOutbox.Delete(true);

        FailedStatus := false;
        NoEmailsInOutbox := true;
    end;

    local procedure LoadEmailOutboxForUser()
    begin
        EmailImpl.RefreshEmailOutboxForUser(EmailAccountId, EmailStatus, Rec);

        Rec.SetCurrentKey("Date Queued");
        NoEmailsInOutbox := Rec.IsEmpty();
        Rec.Ascending(false);
    end;

    local procedure ShowAccountInformation()
    var
        EmailAccountImpl: Codeunit "Email Account Impl.";
        EmailConnector: Interface "Email Connector";
    begin
        if not EmailAccountImpl.IsValidConnector(Rec.Connector) then
            Error(EmailConnectorHasBeenUninstalledMsg);

        EmailConnector := Rec.Connector;
        EmailConnector.ShowAccountInformation(Rec."Account Id");
    end;

    internal procedure SetEmailStatus(Status: Enum "Email Status")
    begin
        EmailStatus := Status;
    end;

    internal procedure SetEmailAccountId(AccountId: Guid)
    begin
        EmailAccountId := AccountId;
    end;

    var
        EmailImpl: Codeunit "Email Impl";
        EmailStatus: Enum "Email Status";
        EmailAccountId: Guid;
        RefreshOutbox: Boolean;
        NoEmailsInOutbox: Boolean;
        [InDataSet]
        FailedStatus: Boolean;
        EmailConnectorHasBeenUninstalledMsg: Label 'The email extension that was used to send this email has been uninstalled. To view information about the email account, you must reinstall the extension.';
}