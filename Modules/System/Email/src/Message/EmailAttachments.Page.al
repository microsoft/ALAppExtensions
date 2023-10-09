// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Telemetry;
using System.Integration;

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
                    Caption = 'File Name';
                    ToolTip = 'Specifies the name of the attachment';

                    trigger OnDrillDown()
                    var
                        EmailEditor: Codeunit "Email Editor";
                    begin
                        EmailEditor.DownloadAttachment(Rec.Data.MediaId(), Rec."Attachment Name");
                        CurrPage.Update(false);
                    end;
                }
                field(FileSize; AttachmentFileSize)
                {
                    ApplicationArea = All;
                    Width = 10;
                    Caption = 'File Size';
                    ToolTip = 'Specifies the size of the attachment';
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
                Image = Attach;
                Caption = 'Add file';
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

            action(UploadFromScenario)
            {
                ApplicationArea = All;
                Image = Attach;
                Caption = 'Add files from default selection';
                ToolTip = 'Add additional attachments from default email attachments. These files are not attached by default.';
                Scope = Page;
                Visible = IsEmailEditable;

                trigger OnAction()
                var
                    EmailAttachments: Record "Email Attachments";
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                    EmailChooseScenarioAttachments: Page "Email Choose Scenario Attach";
                begin
                    EmailChooseScenarioAttachments.SetEmailScenario(EmailScenario);

                    EmailChooseScenarioAttachments.LookupMode(true);
                    if EmailChooseScenarioAttachments.RunModal() = Action::LookupOK then begin
                        FeatureTelemetry.LogUptake('0000I8R', 'Email Default Attachments', Enum::"Feature Uptake Status"::"Used");

                        EmailChooseScenarioAttachments.GetSelectedAttachments(EmailAttachments);
                        EmailMessageImpl.Get(EmailMessageId);
                        EmailMessageImpl.AddAttachmentsFromScenario(EmailAttachments);

                        FeatureTelemetry.LogUsage('0000I8T', 'Email Default Attachments', 'Upload attachments from scenarios');
                    end;
                    UpdateDeleteActionEnablement();
                end;

            }

            action(SourceAttachments)
            {
                ApplicationArea = All;
                Image = Attach;
                Caption = 'Add file from source document';
                ToolTip = 'Attach a file that was originally attached to the source document, such as a Customer Record, Sales Invoice, etc.';
                Scope = Page;
                Visible = IsEmailEditable;

                trigger OnAction()
                var
                    EmailEditor: Codeunit "Email Editor";
                begin
                    EmailEditor.AttachFromRelatedRecords(EmailMessageId);
                    EmailMessageImpl.Get(EmailMessageId); // refresh the record on the email message implementation
                    UpdateDeleteActionEnablement();
                end;
            }

            action(WordTemplate)
            {
                ApplicationArea = All;
                Image = Word;
                Caption = 'Add file from Word template';
                ToolTip = 'Create and attach a document using a Word Template.';
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

            action(EditInOneDrive)
            {
                ApplicationArea = All;
                Image = Cloud;
                Caption = 'Edit in OneDrive';
                ToolTip = 'Copy the file to your Business Central folder in OneDrive and open it in a new window so you can edit the file.', Comment = 'OneDrive should not be translated';
                Scope = Repeater;
                Visible = EditOptionVisible;

                trigger OnAction()
                var
                    TempDocumentSharing: Record "Document Sharing" temporary;
                    DocumentSharingCodeunit: Codeunit "Document Sharing";
                    TextSplit: List of [Text];
                    Value: Text;
                    PreviousLength: Integer;
                    InStream: InStream;
                    OutStream: OutStream;
                begin
                    TempDocumentSharing.Name := Rec."Attachment Name";
                    TextSplit := Rec."Attachment Name".Split('.');
                    TextSplit.Get(TextSplit.Count(), Value);
                    TempDocumentSharing.Extension := CopyStr('.' + Value, 1, MaxStrLen(TempDocumentSharing.Extension));

                    TempDocumentSharing."Document Sharing Intent" := Enum::"Document Sharing Intent"::Edit;

                    TempDocumentSharing.Data.CreateOutStream(OutStream);
                    Rec.Data.ExportStream(OutStream);
                    PreviousLength := TempDocumentSharing.Data.Length;

                    TempDocumentSharing.Insert();
                    DocumentSharingCodeunit.Share(TempDocumentSharing);

                    if TempDocumentSharing.Data.Length <> PreviousLength then begin
                        TempDocumentSharing.Data.CreateInStream(InStream);
                        Rec.Data.ImportStream(InStream, '', Rec."Content Type");
                        Rec.Modify();
                    end;
                end;
            }

            action(Delete)
            {
                ApplicationArea = All;
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

    trigger OnAfterGetRecord()
    begin
        AttachmentFileSize := EmailMessageImpl.FormatFileSize(Rec.Length);
    end;

    trigger OnAfterGetCurrRecord()
    var
        DocumentSharing: Codeunit "Document Sharing";
    begin
        EditOptionVisible := DocumentSharing.ShareEnabled(Enum::"Document Sharing Source"::System) and DocumentSharing.EditEnabledForFile(Rec."Attachment Name");
    end;

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

    internal procedure UpdateValues(SourceEmailMessageImpl: Codeunit "Email Message Impl."; EmailEditable: Boolean)
    begin
        EmailMessageId := SourceEmailMessageImpl.GetId();
        EmailMessageImpl := SourceEmailMessageImpl;

        UpdateDeleteActionEnablement();
        IsEmailEditable := EmailEditable;
    end;

    internal procedure UpdateEmailScenario(Scenario: Enum "Email Scenario")
    begin
        EmailScenario := Scenario;
    end;

    protected var
        DeleteActionEnabled: Boolean;
        EditOptionVisible: Boolean;
        IsEmailEditable: Boolean;
        AttachmentFileSize: Text;
        EmailMessageId: Guid;
        EmailScenario: Enum "Email Scenario";

    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
        DeleteQst: Label 'Go ahead and delete?';
}
