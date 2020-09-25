// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A page to create, edit and send e-mails.
/// </summary>
page 13 "Email Editor"
{
    PageType = Document;
    SourceTable = "Email Message";
    SourceTableTemporary = true;
    Caption = 'Compose an Email';
    Permissions = tabledata "Email Outbox" = r,
                  tabledata "Sent Email" = r,
                  tabledata "Email Recipient" = r;
    UsageCategory = Tasks;
    ApplicationArea = All;
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group("Email Details")
            {
                grid("Email Details Grid")
                {
                    group("Email Inner Details")
                    {
                        ShowCaption = false;

                        field(Account; FromDisplayName)
                        {
                            ApplicationArea = All;
                            Caption = 'From';
                            ToolTip = 'Specifies the account to send the email from.';
                            Editable = not EmailScheduledOrSent;
                            Importance = Additional;

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                EmailAccounts: Page "Email Accounts";
                            begin
                                EmailAccounts.EnableLookupMode();
                                if EmailAccounts.RunModal() = Action::LookupOK then begin
                                    EmailEdited := true;
                                    EmailAccounts.GetAccount(TempEmailAccountRec);
                                    FromDisplayName := StrSubstNo(FromDisplayNameLbl, TempEmailAccountRec.Name, TempEmailAccountRec."Email Address");
                                end;
                                CurrPage.Update();
                            end;
                        }

                        field(ToField; ToRecipient)
                        {
                            Caption = 'To';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the email addresses to send the email to.';
                            Editable = not EmailScheduledOrSent;
                            Importance = Promoted;

                            trigger OnValidate()
                            begin
                                EmailEdited := true;
                            end;
                        }

                        field(CcField; CcRecipient)
                        {
                            Caption = 'Cc';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the email addresses of people who should receive a copy of the email.';
                            Editable = not EmailScheduledOrSent;
                            Importance = Additional;

                            trigger OnValidate()
                            begin
                                EmailEdited := true;
                            end;
                        }

                        field(BccField; BccRecipient)
                        {
                            Caption = 'Bcc';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the email addresses of people who should receive a blind carbon copy (Bcc) of the email. These addresses are not shown to other recipients.';
                            Editable = not EmailScheduledOrSent;
                            Importance = Additional;

                            trigger OnValidate()
                            begin
                                EmailEdited := true;
                            end;
                        }

                        field(SubjectField; Subject)
                        {
                            Caption = 'Subject';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the subject of the email.';
                            Editable = not EmailScheduledOrSent;
                            Importance = Promoted;

                            trigger OnValidate()
                            begin
                                EmailEdited := true;
                            end;
                        }
                    }
                }
            }

            field("Email Editor"; EmailBody)
            {
                Caption = 'Body';
                ApplicationArea = All;
                ToolTip = 'Specifies the content of the email.';
                MultiLine = true;
                Editable = not EmailScheduledOrSent;
                Visible = IsHTMLFormatted;

                trigger OnValidate()
                begin
                    EmailEdited := true;
                end;
            }

            field(BodyField; EmailBody)
            {
                Caption = 'Body';
                ApplicationArea = All;
                ToolTip = 'Specifies the content of the email.';
                MultiLine = true;
                Editable = not EmailScheduledOrSent;
                Visible = not IsHTMLFormatted;

                trigger OnValidate()
                begin
                    EmailEdited := true;
                end;
            }
            part(Attachments; "Email Attachments")
            {
                ApplicationArea = All;
                SubPageLink = "Email Message Id" = field(Id);
                UpdatePropagation = SubPart;
                Caption = 'Attachments';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Send)
            {
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Caption = 'Send Email';
                ToolTip = 'Send the email.';
                ApplicationArea = All;
                Enabled = not EmailScheduledOrSent;
                Image = SendMail;

                trigger OnAction()
                var
                    EmailMessageImpl: Codeunit "Email Message Impl.";
                    EmailImpl: Codeunit "Email Impl";
                begin
                    if EmailEdited then
                        SendTelemetryForMessageEdits();

                    if EmailMessageImpl.Find(Rec.Id) then;
                    EmailMessageImpl.CreateOrUpdateMessageFromEditor(ToRecipient, CcRecipient, BccRecipient, Rec.Subject, EmailBody, Rec."HTML Formatted Body", Rec.Id);

                    if not EmailImpl.Send(EmailMessageImpl.GetId(), TempEmailAccountRec."Account Id", TempEmailAccountRec.Connector) then
                        Error(SendingFailedErr, GetLastErrorText());

                    IsSent := true;
                    CurrPage.Close();
                end;
            }
            action(Draft)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Save as Draft';
                ToolTip = 'Save the email as a draft.';
                Image = Save;
                Enabled = not EmailScheduledOrSent;
                Visible = IsNew;

                trigger OnAction()
                begin
                    SaveDraftEmail();
                    CurrPage.Close();
                end;
            }
            action(Upload)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Attach;
                Enabled = not EmailScheduledOrSent;
                Caption = 'Attach File';
                ToolTip = 'Attach files, such as documents or images, to the email.';

                trigger OnAction()
                var
                    EmailMessageImpl: Codeunit "Email Message Impl.";
                begin
                    EmailMessageImpl.UploadAttachmentEditorAction(Rec.Id);
                    CurrPage.Attachments.Page.Update();
                end;
            }
        }
    }

    var
        TempEmailAccountRec: Record "Email Account" temporary;
        EmailOutbox: Record "Email Outbox";
        FromDisplayName: Text;
        ToRecipient, CcRecipient, BccRecipient : Text;
        EmailScheduledOrSent: Boolean;
        IsNew: Boolean;
        IsSent: Boolean;
        IsDraft: Boolean;
        EmailBody: Text;
        EmailEdited: Boolean;
        [InDataSet]
        IsHTMLFormatted: Boolean;
        FromDisplayNameLbl: Label '%1 (%2)', Comment = '%1 - Account Name, %2 - Email address', Locked = true;
        EmailCategoryLbl: Label 'Email', Locked = true;
        EmailMessageEditedMsg: Label 'Email message id: %1 has been edited.', Comment = '%1 - Email Message Id', Locked = true;
        ConcatRecipientMsg: Label '%1;%2', Comment = '%1 - Email addresses, %2 - Email address to be concatenated', Locked = true;
        CloseThePageQst: Label 'The email has not been sent. Do you want to save a draft?';
        OptionsOnClosePageNewEmailLbl: Label 'Yes,No';
        SendingFailedErr: Label 'The email was not sent because of the following error: "%1" \\Depending on the error, you might need to contact your administrator.', Comment = '%1 - the error that occurred.';

    trigger OnOpenPage()
    var
        Outbox: Record "Email Outbox";
    begin
        if IsNullGuid(Rec.Id) then begin
            Rec.Id := CreateGuid();
            Rec.Insert();
            IsNew := true;
        end else begin
            UpdateRecipients();
            UpdateBody();

            // Check if sent
            Outbox.SetRange("Message Id", Rec.Id);
            Outbox.SetFilter(Status, '%1|%2', Outbox.Status::Queued, Outbox.Status::Processing);
            EmailScheduledOrSent := not (Outbox.IsEmpty() and Rec.Editable);
        end;

        if TempEmailAccountRec."Email Address" = '' then
            FromDisplayName := ''
        else
            FromDisplayName := StrSubstNo(FromDisplayNameLbl, TempEmailAccountRec.Name, TempEmailAccountRec."Email Address");
        IsSent := false;
        IsHTMLFormatted := Rec."HTML Formatted Body";
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Outbox: Record "Email Outbox";
        SentEmail: Record "Sent Email";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        CloseOptions: Text[50];
        SelectedCloseOption: Integer;
    begin
        if not (IsDraft or IsSent or EmailScheduledOrSent) then begin
            CloseOptions := OptionsOnClosePageNewEmailLbl;
            SelectedCloseOption := Dialog.StrMenu(CloseOptions, 1, CloseThePageQst);
            case SelectedCloseOption of
                1:
                    SaveDraftEmail();
                2:
                    exit(true); // Discard email
                else
                    exit(false) // Cancel
            end;
        end;

        if not EmailEdited then
            exit(true);

        SentEmail.SetRange("Message Id", Rec.Id);
        if not SentEmail.IsEmpty() then
            exit(true);

        if not (IsDraft or IsSent) then begin
            if EmailMessageImpl.Find(Rec.Id) then;
            EmailMessageImpl.CreateOrUpdateMessageFromEditor(ToRecipient, CcRecipient, BccRecipient, Rec.Subject, EmailBody, Rec."HTML Formatted Body", Rec.Id);

            Outbox.SetRange("Message Id", Rec.Id);
            if Outbox.IsEmpty() then
                EmailMessageImpl.InsertOutboxFromEditor(TempEmailAccountRec)
            else begin
                Outbox.FindSet();
                repeat
                    EmailMessageImpl.UpdateOutboxFromEditor(Outbox, TempEmailAccountRec);
                until Outbox.Next() = 0;
                SendTelemetryForMessageEdits();
            end;
        end;

        exit(true);
    end;

    local procedure SaveDraftEmail()
    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailImpl: Codeunit "Email Impl";
    begin
        if EmailEdited then
            SendTelemetryForMessageEdits();

        if EmailMessageImpl.Find(Rec.Id) then;
        EmailMessageImpl.CreateOrUpdateMessageFromEditor(ToRecipient, CcRecipient, BccRecipient, Rec.Subject, EmailBody, Rec."HTML Formatted Body", Rec.Id);

        EmailImpl.Enqueue(EmailMessageImpl.GetId(), TempEmailAccountRec."Account Id", TempEmailAccountRec.Connector, false);
        IsDraft := true;
    end;

    local procedure SendTelemetryForMessageEdits()
    begin
        Session.LogMessage('0000CTV', StrSubstNo(EmailMessageEditedMsg, Rec.Id), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
    end;

    procedure SetEmailAccount(EmailAccount: Record "Email Account")
    begin
        if EmailAccount."Email Address" = '' then
            exit;

        TempEmailAccountRec.Copy(EmailAccount);
    end;

    procedure SetHtmlFormattedBody(HtmlFormatted: Boolean)
    begin
        Rec."HTML Formatted Body" := HtmlFormatted;
    end;

    internal procedure WasEmailSent(): Boolean
    begin
        exit(IsSent);
    end;

    internal procedure SetOutbox(var Outbox: Record "Email Outbox")
    begin
        EmailOutbox := Outbox;
    end;

    local procedure UpdateRecipients()
    var
        EmailRecipientsRec: Record "Email Recipient";
    begin
        EmailRecipientsRec.SetFilter("Email Message Id", Rec.Id);
        if not EmailRecipientsRec.FindSet() then
            exit;

        repeat
            if EmailRecipientsRec."Email Recipient Type" = EmailRecipientsRec."Email Recipient Type"::"To" then
                ConcateEmailAddresses(ToRecipient, EmailRecipientsRec."Email Address");

            if EmailRecipientsRec."Email Recipient Type" = EmailRecipientsRec."Email Recipient Type"::"Cc" then
                ConcateEmailAddresses(CcRecipient, EmailRecipientsRec."Email Address");

            if EmailRecipientsRec."Email Recipient Type" = EmailRecipientsRec."Email Recipient Type"::"Bcc" then
                ConcateEmailAddresses(BccRecipient, EmailRecipientsRec."Email Address");
        until EmailRecipientsRec.Next() = 0;

        CurrPage.Update();
    end;

    local procedure UpdateBody()
    var
        InStream: InStream;
    begin
        Rec.Body.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(EmailBody);
    end;

    local procedure ConcateEmailAddresses(var Addresses: Text; NewAddress: Text)
    begin
        if Addresses = '' then
            Addresses := NewAddress
        else
            Addresses := StrSubstNo(ConcatRecipientMsg, Addresses, NewAddress);
    end;
}
