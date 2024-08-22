// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4308 "Agent Task Message Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Agent Task Message";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Agent Task Message';
    DataCaptionExpression = '';
    Extensible = false;
    SourceTableView = sorting(SystemModifiedAt) order(descending);

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(LastModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'Last modified at';
                    ToolTip = 'Specifies the date and time when the message was last modified.';
                }
                field(CreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Created at';
                    ToolTip = 'Specifies the date and time when the message was created.';
                }
                field(TaskID; Rec."Task Id")
                {
                    Caption = 'Task ID';
                    Visible = false;
                }
                field(MessageID; Rec."ID")
                {
                    Caption = 'ID';
                    Visible = false;
                }
                field(MessageType; Rec.Type)
                {
                    Caption = 'Type';
                }
                field(Status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(AttachmentsCount; AttachmentsCount)
                {
                    Caption = 'Attachments';
                    ToolTip = 'Specifies the number of attachments that are associated with the message.';
                    Editable = false;
                }
            }

            group(Message)
            {
                Caption = 'Message';
                Editable = IsMessageEditable;
                field(MessageText; GlobalMessageText)
                {
                    ShowCaption = false;
                    Caption = 'Message';
                    ToolTip = 'Specifies the message text.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    Editable = true;
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(DownloadAttachment)
            {
                ApplicationArea = All;
                Caption = 'Download attachments';
                ToolTip = 'Download the attachment.';
                Image = Download;
                Enabled = AttachmentsCount > 0;

                trigger OnAction()
                begin
                    DownloadAttachments();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(DownloadAttachment_Promoted; DownloadAttachment)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
    end;

    local procedure UpdateControls()
    var
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
    begin
        GlobalMessageText := AgentMonitoringImpl.GetMessageText(Rec);
        IsMessageEditable := AgentMonitoringImpl.IsMessageEditable(Rec);

        AgentTaskMessageAttachment.SetRange("Task ID", Rec."Task ID");
        AgentTaskMessageAttachment.SetRange("Message ID", Rec.ID);

        AttachmentsCount := AgentTaskMessageAttachment.Count();
    end;

    local procedure DownloadAttachments()
    var
        AgentTaskFile: Record "Agent Task File";
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
        InStream: InStream;
        FileName: Text;
        DownloadDialogTitleLbl: Label 'Download Email Attachment';
    begin
        AgentTaskMessageAttachment.SetRange("Task ID", Rec."Task ID");
        AgentTaskMessageAttachment.SetRange("Message ID", Rec.ID);
        if not AgentTaskMessageAttachment.FindSet() then
            exit;

        repeat
            if not AgentTaskFile.Get(AgentTaskMessageAttachment."File ID") then
                exit;
            FileName := AgentTaskFile."File Name";
            AgentTaskFile.CalcFields(Content);
            AgentTaskFile.Content.CreateInStream(InStream, AgentMonitoringImpl.GetDefaultEncoding());
            File.DownloadFromStream(InStream, DownloadDialogTitleLbl, '', '', FileName);
        until AgentTaskMessageAttachment.Next() = 0;
    end;

    var
        GlobalMessageText: Text;
        IsMessageEditable: Boolean;
        AttachmentsCount: Integer;
}