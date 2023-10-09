// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Telemetry;

/// <summary>
/// A page to create, edit and send e-mails.
/// </summary>
page 13 "Email Editor"
{
    PageType = Document;
    SourceTable = "Email Outbox";
    Caption = 'Compose an Email';
    Permissions = tabledata "Email Outbox" = rm,
                  tabledata "Email Message Attachment" = rid;

    UsageCategory = Tasks;
    ApplicationArea = All;
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    Extensible = true;

    layout
    {
        area(Content)
        {
            group("Email Details")
            {
                Caption = 'Email details';

                grid("Email Details Grid")
                {
                    group("Email Inner Details")
                    {
                        ShowCaption = false;

                        field(Account; FromDisplayName)
                        {
                            ShowMandatory = true;
                            ApplicationArea = All;
                            Caption = 'From';
                            ToolTip = 'Specifies the account to send the email from.';
                            Editable = false;
                            Enabled = not EmailScheduled;

                            trigger OnAssistEdit()
                            begin
                                EmailEditor.ChangeEmailAccount(Rec, TempEmailAccount);

                                UpdateFromField(TempEmailAccount);
                                CurrPage.Update();
                            end;
                        }

                        field(ToField; ToRecipient)
                        {
                            ShowMandatory = true;
                            Caption = 'To';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the email addresses to send the email to.';
                            Editable = not EmailScheduled;
                            Importance = Promoted;
                            Lookup = true;

                            trigger OnValidate()
                            begin
                                EmailMessageImpl.SetRecipients(Enum::"Email Recipient Type"::"To", ToRecipient);
                                EmailEditor.VerifyRelatedRecords(Rec."Message Id");
                            end;

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                exit(LookupRecipients(Text));
                            end;

                        }

                        field(CcField; CcRecipient)
                        {
                            Caption = 'Cc';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the email addresses of people who should receive a copy of the email.';
                            Editable = not EmailScheduled;
                            Importance = Additional;
                            Lookup = true;

                            trigger OnValidate()
                            begin
                                EmailMessageImpl.SetRecipients(Enum::"Email Recipient Type"::Cc, CcRecipient);
                                EmailEditor.VerifyRelatedRecords(Rec."Message Id");
                            end;

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                exit(LookupRecipients(Text));
                            end;
                        }

                        field(BccField; BccRecipient)
                        {
                            Caption = 'Bcc';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the email addresses of people who should receive a blind carbon copy (Bcc) of the email. These addresses are not shown to other recipients.';
                            Editable = not EmailScheduled;
                            Importance = Additional;
                            Lookup = true;

                            trigger OnValidate()
                            begin
                                EmailMessageImpl.SetRecipients(Enum::"Email Recipient Type"::Bcc, BccRecipient);
                                EmailEditor.VerifyRelatedRecords(Rec."Message Id");
                            end;

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                exit(LookupRecipients(Text));
                            end;
                        }

                        field(SubjectField; EmailSubject)
                        {
                            Caption = 'Subject';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the subject of the email.';
                            Editable = not EmailScheduled;
                            Importance = Promoted;

                            trigger OnValidate()
                            begin
                                EmailMessageImpl.SetSubject(EmailSubject);
                                EmailMessageImpl.Modify();

                                Rec.Description := CopyStr(EmailSubject, 1, MaxStrLen(Rec.Description));
                                Rec.Modify();

                                CurrPage.Caption(EmailSubject);
                                CurrPage.Update();
                            end;
                        }
                    }
                }
            }

            group(HTMLFormattedBody)
            {
                ShowCaption = false;
                Caption = ' ';
                Visible = IsHTMLFormatted;

                field("Email Editor"; EmailBody)
                {
                    Caption = 'Message';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the content of the email.';
                    MultiLine = true;
                    ExtendedDataType = RichContent;
                    Editable = not EmailScheduled;

                    trigger OnValidate()
                    begin
                        EmailMessageImpl.SetBody(EmailBody);
                        EmailMessageImpl.Modify();
                    end;
                }
            }

            group(RawTextBody)
            {
                ShowCaption = false;
                Caption = ' ';
                Visible = not IsHTMLFormatted;

                field(BodyField; EmailBody)
                {
                    Caption = 'Message';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the content of the email.';
                    MultiLine = true;
                    Editable = not EmailScheduled;

                    trigger OnValidate()
                    begin
                        EmailMessageImpl.SetBody(EmailBody);
                        EmailMessageImpl.Modify();
                    end;
                }
            }

            part(Attachments; "Email Attachments")
            {
                ApplicationArea = All;
                SubPageLink = "Email Message Id" = field("Message Id");
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
                Caption = 'Send email';
                ToolTip = 'Send the email.';
                ApplicationArea = All;
                Enabled = not EmailScheduled;
                Image = SendMail;

                trigger OnAction()
                begin
                    ValidateAndSendEmailData();
                end;
            }
            action(Discard)
            {
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Caption = 'Discard draft';
                ToolTip = 'Discard the draft email and close the page.';
                ApplicationArea = All;
                Enabled = not EmailScheduled;
                Image = Delete;

                trigger OnAction()
                begin
                    if EmailEditor.DiscardEmail(Rec, true) then begin
                        IsNewOutbox := false;
                        EmailAction := Enum::"Email Action"::Discarded;
                        CurrPage.Close();
                    end;
                end;
            }
            action(WordTemplate)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Word;
                Caption = 'Use Word template';
                ToolTip = 'Use a Word template with data from the entity to fill the email body.';
                Enabled = HasSourceRecord;

                trigger OnAction()
                var
                begin
                    EmailEditor.LoadWordTemplate(EmailMessageImpl, Rec."Message Id");
                end;
            }
            action(ShowSourceRecord)
            {
                ApplicationArea = All;
                Image = GetSourceDoc;
                Caption = 'Show source document';
                ToolTip = 'Open the page from where the email was sent.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Enabled = HasSourceRecord;

                trigger OnAction()
                begin
                    EmailImpl.ShowSourceRecord(Rec."Message Id");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EmailEditor.CheckPermissions(Rec);

        EmailEditor.GetEmailAccount(Rec, TempEmailAccount);
        EmailEditor.GetEmailMessage(Rec, EmailMessageImpl);

        UpdateFromField(TempEmailAccount);
        ToRecipient := EmailMessageImpl.GetRecipientsAsText(Enum::"Email Recipient Type"::"To");
        CcRecipient := EmailMessageImpl.GetRecipientsAsText(Enum::"Email Recipient Type"::Cc);
        BccRecipient := EmailMessageImpl.GetRecipientsAsText(Enum::"Email Recipient Type"::Bcc);
        EmailBody := EmailMessageImpl.GetBody();
        EmailSubject := EmailMessageImpl.GetSubject();

        if EmailSubject <> '' then
            CurrPage.Caption(EmailSubject)
        else
            CurrPage.Caption(PageCaptionTxt); // fallback to default caption

        EmailScheduled := Rec.Status in [Enum::"Email Status"::Queued, Enum::"Email Status"::Processing];
        HasSourceRecord := EmailImpl.HasSourceRecord(Rec."Message Id");
        IsHTMLFormatted := EmailMessageImpl.IsBodyHTMLFormatted();
        CurrPage.Attachments.Page.UpdateValues(EmailMessageImpl, not EmailScheduled);
        CurrPage.Attachments.Page.UpdateEmailScenario(EmailScenario);
    end;

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        // Do not check permissions on compose
        if Rec.Id <> 0 then
            EmailEditor.CheckPermissions(Rec);

        FeatureTelemetry.LogUptake('0000CTQ', 'Emailing', Enum::"Feature Uptake Status"::Discovered);
        CurrPage.SetTableView(Rec);

        if not IsNewOutbox then begin // if the outbox is set as new, do not create new outbox
            IsNewOutbox := Rec.Id = 0;
            if IsNewOutbox then
                EmailEditor.CreateOutbox(Rec);
        end;

        if IsNewOutbox then begin  // Disable arrows if it's a new record
            Rec.SetRange(Id, Rec.Id);
            CurrPage.SetTableView(Rec);
        end;

        EmailEditor.PopulateRelatedRecordCache(Rec."Message Id");

        DefaultExitOption := 1;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if IsNewOutbox then
            exit(ShowCloseOptionsMenu());
    end;

    protected procedure GetEmailMessage() EmailMessage: Codeunit "Email Message"
    begin
        EmailMessage.Get(Rec."Message Id");
    end;

    local procedure UpdateFromField(EmailAccount: Record "Email Account" temporary)
    begin
        if EmailAccount."Email Address" = '' then
            FromDisplayName := ''
        else
            FromDisplayName := StrSubstNo(FromDisplayNameLbl, EmailAccount.Name, EmailAccount."Email Address");
    end;

    local procedure ShowCloseOptionsMenu(): Boolean
    var
        CloseOptions: Text;
        SelectedCloseOption: Integer;
    begin
        CloseOptions := OptionsOnClosePageNewEmailLbl;
        SelectedCloseOption := Dialog.StrMenu(CloseOptions, DefaultExitOption, CloseThePageQst);

        case SelectedCloseOption of
            1:
                EmailAction := Enum::"Email Action"::"Saved As Draft";
            2:
                begin
                    EmailEditor.DiscardEmail(Rec, false);
                    EmailAction := Enum::"Email Action"::Discarded;
                end;
            else
                exit(false) // Cancel
        end;

        exit(true);
    end;

    internal procedure LookupRecipients(var Text: Text): Boolean
    var
        IsSuccess: Boolean;
    begin
        IsSuccess := EmailEditor.LookupRecipients(Rec."Message Id", Text);
        HasSourceRecord := EmailImpl.HasSourceRecord(Rec."Message Id");
        exit(IsSuccess);
    end;

    internal procedure GetAction(): Enum "Email Action"
    begin
        exit(EmailAction);
    end;

    internal procedure SetAsNew()
    begin
        IsNewOutbox := true;
    end;

    internal procedure SetEmailScenario(Scenario: Enum "Email Scenario")
    begin
        EmailScenario := Scenario;
    end;

    protected procedure ValidateAndSendEmailData()
    var
        IsEmailDataValid: Boolean;
    begin
        IsEmailDataValid := EmailEditor.ValidateEmailData(TempEmailAccount."Email Address", EmailMessageImpl);

        if IsEmailDataValid then begin
            IsNewOutbox := false;
            EmailEditor.SendOutbox(Rec);
            EmailAction := Enum::"Email Action"::Sent;

            CurrPage.Close();
        end;
    end;

    var
        TempEmailAccount: Record "Email Account" temporary;
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditor: Codeunit "Email Editor";
        EmailImpl: Codeunit "Email Impl";
        EmailAction: Enum "Email Action";
        FromDisplayName: Text;
        EmailScheduled: Boolean;
        HasSourceRecord: Boolean;
        EmailBody, EmailSubject : Text;
        EmailScenario: Enum "Email Scenario";
        IsHTMLFormatted: Boolean;
        FromDisplayNameLbl: Label '%1 (%2)', Comment = '%1 - Account Name, %2 - Email address', Locked = true;
        CloseThePageQst: Label 'The email has not been sent.';
        OptionsOnClosePageNewEmailLbl: Label 'Keep as draft in Email Outbox,Discard email';
        PageCaptionTxt: Label 'Compose an Email';

    protected var
        IsNewOutbox: Boolean;
        ToRecipient, CcRecipient, BccRecipient : Text;
        DefaultExitOption: Integer;
}
