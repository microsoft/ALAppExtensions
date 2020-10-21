// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A page to view sent emails.
/// </summary>
page 12 "Email Viewer"
{
    PageType = Document;
    SourceTable = "Sent Email";
    Caption = 'Sent Email';
    Permissions = tabledata "Sent Email" = rd,
                  tabledata "Email Message Attachment" = r;
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Extensible = true;

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
                            ShowMandatory = true;
                            ApplicationArea = All;
                            Caption = 'From';
                            ToolTip = 'Specifies the account from which the email was sent.';
                            Editable = false;
                        }

                        field(ToField; ToRecipient)
                        {
                            ShowMandatory = true;
                            Caption = 'To';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the email recipients.';
                            Editable = false;
                            Importance = Promoted;
                        }

                        field(CcField; CcRecipient)
                        {
                            Caption = 'Cc';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the email CC recipients.';
                            Editable = false;
                            Importance = Additional;
                        }

                        field(BccField; BccRecipient)
                        {
                            Caption = 'Bcc';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the email BCC recipients.';
                            Editable = false;
                            Importance = Additional;
                        }

                        field(SubjectField; EmailSubject)
                        {
                            Caption = 'Subject';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the subject of the sent email.';
                            Editable = false;
                            Importance = Promoted;
                        }
                    }
                }
            }

            field("Email Editor"; EmailBody)
            {
                Caption = 'Message';
                ApplicationArea = All;
                ToolTip = 'Specifies the content of the email.';
                MultiLine = true;
                Editable = false;
                Visible = IsHTMLFormatted;
            }

            field(BodyField; EmailBody)
            {
                ApplicationArea = All;
                ShowCaption = false;
                Caption = 'Message';
                ToolTip = 'Specifies the content of the email.';
                MultiLine = true;
                Editable = false;
                Visible = not IsHTMLFormatted;
            }


            part(Attachments; "Email Attachments")
            {
                ApplicationArea = All;
                SubPageLink = "Email Message Id" = field("Message Id");
                UpdatePropagation = SubPart;
                Caption = 'Attachments';
                Visible = HasAttachements;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Resend)
            {
                ApplicationArea = All;
                Caption = 'Resend';
                ToolTip = 'Resend the email.';
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    EmailViewer.Resend(Rec);
                end;
            }

            action(EditAndSend)
            {
                ApplicationArea = All;
                Caption = 'Edit and Send';
                ToolTip = 'Edit and send the email.';
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    EmailViewer.EditAndSend(Rec)
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.Id = 0 then
            exit;

        EmailViewer.CheckPermissions(Rec);

        // Disable next and previous records arrows
        Rec.SetRange(Id, Rec.Id);
        CurrPage.SetTableView(Rec);

        EmailViewer.GetEmailAccount(Rec, EmailAccount);
        EmailViewer.GetEmailMessage(Rec, EmailMessage);

        UpdateFromField(EmailAccount);
        EmailSubject := EmailMessage.GetSubject();
        ToRecipient := EmailMessage.GetRecipientsAsText(Enum::"Email Recipient Type"::"To");
        CcRecipient := EmailMessage.GetRecipientsAsText(Enum::"Email Recipient Type"::Cc);
        BccRecipient := EmailMessage.GetRecipientsAsText(Enum::"Email Recipient Type"::Bcc);
        EmailBody := EmailMessage.GetBody();

        IsHTMLFormatted := EmailMessage.IsBodyHTMLFormatted();
        HasAttachements := EmailMessage.Attachments_First();
        CurrPage.Attachments.Page.SetEmailMessageId(EmailMessage.GetId());
    end;

    local procedure UpdateFromField(EmailAccount: Record "Email Account" temporary)
    begin
        if EmailAccount."Email Address" = '' then
            FromDisplayName := ''
        else
            FromDisplayName := StrSubstNo(FromDisplayNameLbl, EmailAccount.Name, EmailAccount."Email Address");
    end;

    var
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message Impl.";
        EmailViewer: Codeunit "Email Viewer";
        FromDisplayName: Text;
        ToRecipient, CcRecipient, BccRecipient : Text;
        EmailSubject: Text;
        EmailBody: Text;
        [InDataSet]
        IsHTMLFormatted, HasAttachements : Boolean;
        FromDisplayNameLbl: Label '%1 (%2)', Comment = '%1 - Account Name, %2 - Email address', Locked = true;
}
