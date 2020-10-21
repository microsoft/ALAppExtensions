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
                        Instream: Instream;
                        Filename: Text;
                    begin
                        Rec.CalcFields(Attachment);
                        Rec.Attachment.CreateInStream(Instream);
                        Filename := Rec."Attachment Name";
                        DownloadFromStream(Instream, '', '', '', Filename);
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
                Caption = 'Attach File';
                ToolTip = 'Attach files, such as documents or images, to the email.';
                Scope = Page;
                Visible = not IsMessageReadOnly;

                trigger OnAction()
                var
                    EmailEditor: Codeunit "Email Editor";
                begin
                    EmailEditor.UploadAttachment(EmailMessage);
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
                Visible = not IsMessageReadOnly;

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

    trigger OnOpenPage()
    begin
        EmailMessage.Get(EmailMessageId);
        UpdateDeleteEnablement();
        IsMessageReadOnly := EmailMessage.IsReadOnly();
    end;

    internal procedure SetEmailMessageId(MessageId: Guid)
    begin
        EmailMessageId := MessageId;
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
        IsMessageReadOnly: Boolean;
        EmailMessageId: Guid;
        DeleteQst: Label 'Go ahead and delete?';
}
