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
                Visible = not IsMessageRead;

                trigger OnAction()
                var
                    EmailEditor: Codeunit "Email Editor";
                begin
                    EmailEditor.UploadAttachment(EmailMessage);
                    UpdateDeleteEnablement();
                    CurrPage.Update();
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
                Visible = not IsMessageRead;

                trigger OnAction()
                var
                    EmailEditor: Codeunit "Email Editor";
                begin
                    EmailEditor.AttachFromRelatedRecords(EmailMessageId);
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
                Visible = not IsMessageRead;

                trigger OnAction()
                var
                    EmailEditor: Codeunit "Email Editor";
                begin
                    EmailEditor.AttachFromWordTemplate(EmailMessage, EmailMessageId);
                    UpdateDeleteEnablement();
                    CurrPage.Update();
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
                Visible = not IsMessageRead;

                trigger OnAction()
                var
                    EmailMessageAttachment: Record "Email Message Attachment";
                begin
                    if Confirm(DeleteQst) then begin
                        CurrPage.SetSelectionFilter(EmailMessageAttachment);
                        EmailMessageAttachment.DeleteAll();
                        UpdateDeleteEnablement();
                        CurrPage.Update();
                    end;
                end;
            }
        }
    }

    internal procedure UpdateValues(MessageId: Guid)
    begin
        EmailMessageId := MessageId;

        EmailMessage.Get(EmailMessageId);
        UpdateDeleteEnablement();
        IsMessageRead := EmailMessage.IsRead();
    end;

    internal procedure UpdateDeleteEnablement()
    var
        EmailMessageAttachment: Record "Email Message Attachment";
    begin
        EmailMessageAttachment.SetFilter("Email Message Id", EmailMessageId);
        DeleteActionEnabled := not EmailMessageAttachment.IsEmpty();
    end;

    var
        EmailMessage: Codeunit "Email Message Impl.";
        [InDataSet]
        DeleteActionEnabled: Boolean;
        IsMessageRead: Boolean;
        EmailMessageId: Guid;
        DeleteQst: Label 'Go ahead and delete?';
}
