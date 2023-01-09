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

            action(UploadFromScenario)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Attach;
                Caption = 'Add Files from Default Selection';
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
                Caption = 'Add File from Source';
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
                Caption = 'Add File from Word Template';
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

    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
        [InDataSet]
        DeleteActionEnabled: Boolean;
        IsEmailEditable: Boolean;
        EmailMessageId: Guid;
        EmailScenario: Enum "Email Scenario";
        DeleteQst: Label 'Go ahead and delete?';
}
