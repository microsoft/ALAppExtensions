// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 8889 "Email Attachments"
{
    PageType = ListPart;
    SourceTable = "Email Message Attachment";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;
    Permissions = tabledata "Email Message Attachment" = rmd;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(FileName; Rec."Attachment Name")
                {
                    ApplicationArea = All;
                    Caption = 'Filename';
                    ToolTip = 'Specifies the name of the attachment';

                    trigger OnDrillDown()
                    var
                        EmailEditor: Codeunit "Email Editor";
                    begin
                        EmailEditor.DownloadAttachment(Rec.Data.MediaId(), Rec."Attachment Name");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(Upload)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Attach;
                Caption = 'Add File';
                ToolTip = 'Attach files, such as documents or images, to the email.';
                Scope = Page;
                Visible = IsEmailEditable;

                trigger OnAction()
                var
                    EmailEditor: Codeunit "Email Editor";
                begin
                    EmailEditor.UploadAttachment(EmailMessageImpl);
                    UpdateDeleteActionEnablement();
                end;
            }

            action(SourceAttachments)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Attach;
                Caption = 'Add File from Source';
                ToolTip = 'Attach a file that was originally attached to the source document, such as a Customer Record, Sales Invoice, etc.';
                Scope = Page;
                Visible = IsEmailEditable;

                trigger OnAction()
                var
                    EmailEditor: Codeunit "Email Editor";
                begin
                    EmailEditor.AttachFromRelatedRecords(EmailMessageId);
                    UpdateDeleteActionEnablement();
                end;
            }

            action(WordTemplate)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Word;
                Caption = 'Add File from Word Template';
                ToolTip = 'Create and Attach a document using a Word Template.';
                Scope = Page;
                Visible = IsEmailEditable;

                trigger OnAction()
                var
                    EmailEditor: Codeunit "Email Editor";
                begin
                    EmailEditor.AttachFromWordTemplate(EmailMessageImpl, EmailMessageId);
                    UpdateDeleteActionEnablement();
                end;
            }

            action(Delete)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Enabled = DeleteActionEnabled;
                Image = Delete;
                Caption = 'Delete';
                ToolTip = 'Delete the selected row.';
                Scope = Repeater;
                Visible = IsEmailEditable;

                trigger OnAction()
                var
                    EmailMessageAttachment: Record "Email Message Attachment";
                begin
                    if Confirm(DeleteQst) then begin
                        CurrPage.SetSelectionFilter(EmailMessageAttachment);
                        EmailMessageAttachment.DeleteAll();
                        UpdateDeleteActionEnablement();
                    end;
                end;
            }
        }
    }

    protected procedure GetEmailMessage() EmailMessage: Codeunit "Email Message"
    begin
        EmailMessage.Get(EmailMessageId);
    end;

    protected procedure UpdateDeleteActionEnablement()
    var
        EmailMessageAttachment: Record "Email Message Attachment";
    begin
        EmailMessageAttachment.SetFilter("Email Message Id", EmailMessageId);
        DeleteActionEnabled := not EmailMessageAttachment.IsEmpty();
        CurrPage.Update();
    end;

#if not CLEAN20
    internal procedure UpdateDeleteEnablement()
    begin
        UpdateDeleteActionEnablement();
    end;
#endif

    internal procedure UpdateValues(MessageId: Guid; EmailEditable: Boolean)
    begin
        EmailMessageId := MessageId;

        EmailMessageImpl.Get(EmailMessageId);
        UpdateDeleteActionEnablement();
        IsEmailEditable := EmailEditable;
    end;

    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
        [InDataSet]
        DeleteActionEnabled: Boolean;
        IsEmailEditable: Boolean;
        EmailMessageId: Guid;
        DeleteQst: Label 'Go ahead and delete?';
}
