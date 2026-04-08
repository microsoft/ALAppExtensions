// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;

page 4360 "Agent Task Template Card"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Agent Task Template';
    DataCaptionExpression = '';
    InherentEntitlements = X;
    InherentPermissions = X;
    SourceTable = "Agent Task Template Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(Template)
            {
                Caption = 'Template';
                field(Name; Rec.Name)
                {
                    Caption = 'Name';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the agent task template.';
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the agent task template.';
                    MultiLine = true;
                }
            }
            group(Task)
            {
                Visible = AgentTaskProvided;
                Caption = 'Task';
                field(TitleText; AgentTaskTemplate."Task Title")
                {
                    Caption = 'Task title';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the title of the agent task.';
                }
                field(ExternalId; AgentTaskTemplate."Task External Id")
                {
                    Caption = 'Task external ID';
                    ToolTip = 'Specifies the external ID of the agent task.';
                }
                field(IncludeMessage; IncludeMessage)
                {
                    Caption = 'Include message';
                    ToolTip = 'Specifies whether to include a message in the agent task template.';
                }
            }
            group(Message)
            {
                Caption = 'Message';
                Visible = IncludeMessage;
                field(FromText; AgentMessageTemplate."Message From Text")
                {
                    Caption = 'From';
                    ShowMandatory = true;
                    ToolTip = 'Specifies who the message is from. If this field is empty, the message will be created without a sender.';
                }

                field(MessageExternalId; AgentMessageTemplate."Message External Id")
                {
                    Caption = 'Message External ID';
                    ToolTip = 'Specifies the external ID of the message. This field is used to connect to external systems, like Message ID for emails. This value allows to track the specific message ID that can be different than the one defined for the task.';
                }

                field(RequiresReview; AgentMessageTemplate."Message Requires Review")
                {
                    Caption = 'Requires review';
                    ToolTip = 'Specifies whether the message requires review.';
                }

                field(SanitizeMessageText; AgentMessageTemplate."Sanitize Message Content")
                {
                    Caption = 'Sanitize message text';
                    ToolTip = 'Specifies whether to sanitize the text of the message.';
                }

                field(IgnoreAttachments; AgentMessageTemplate."Ignore Attachments")
                {
                    Caption = 'Ignore attachments';
                    ToolTip = 'Specifies whether to ignore processing of attachments in the message.';
                }
            }
            group(MessageTextGroup)
            {
                ShowCaption = false;
                Visible = IncludeMessage;

                field(MessageText; MessageText)
                {
                    Caption = 'Message text';
                    ToolTip = 'Specifies the text of the message. The message is optional, it is possible to create tasks without a message.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    ShowMandatory = IncludeMessage;
                }
            }
            part(MessageAttachments; "Agent Message Attachments")
            {
                ApplicationArea = All;
                Visible = IncludeMessage;
                Caption = 'Attachments';
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        exit(SaveData(CloseAction));
    end;

    trigger OnOpenPage()
    var
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
    begin
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();
    end;

    trigger OnAfterGetRecord()
    begin
        if ((Rec.ID <> xRec.ID) or (Rec.Id = 0)) then
            GetTemplateRecords();
        if Rec.Type = Enum::"Agent Template Type"::"Agent Message Template" then
            CurrPage.Caption(AgentMessageTemplateTxt);
    end;

    local procedure GetTemplateRecords(): Boolean
    var
        TempAgentTaskFile: Record "Agent Task File" temporary;
    begin
        if Rec.Type = Enum::"Agent Template Type"::"Agent Task Template" then begin
            if Rec.ID <> 0 then begin
                Rec.GetAgentTaskTemplate(AgentTaskTemplate, AgentMessageTemplate);
                IncludeMessage := AgentTaskTemplate."Include Message";
            end else
                IncludeMessage := true;

            AgentTaskProvided := true;
        end;

        if Rec.Type = Enum::"Agent Template Type"::"Agent Message Template" then begin
            Rec.GetAgentMessageTemplate(AgentMessageTemplate);
            IncludeMessage := true;
        end;

        if AgentMessageTemplate.ID <> 0 then begin
            MessageText := AgentMessageTemplate.GetMessageText();
            AgentMessageTemplate.LoadAttachments(AgentMessageTemplate, TempAgentTaskFile);
            CurrPage.MessageAttachments.Page.SetData(TempAgentTaskFile);
        end;
    end;

    local procedure SaveData(CloseAction: Action): Boolean
    begin
        if not (CloseAction in [Action::Ok, Action::LookupOK, Action::Yes]) then
            exit(true);

        if IncludeMessage and (MessageText = '') then
            Error(YouMustSetMessageTextErr);

        if Rec.Type = Enum::"Agent Template Type"::"Agent Task Template" then begin
            AgentTaskTemplate."Include Message" := IncludeMessage;
            AgentTaskTemplate.Name := Rec.Name;
            if AgentTaskTemplate.ID = 0 then
                AgentTaskTemplate.Insert(true)
            else
                AgentTaskTemplate.Modify(true);

            if AgentTaskTemplate."Include Message" then
                SaveMessageTemplate();

            AgentTaskTemplate."Message Template ID" := AgentMessageTemplate.ID;
            AgentTaskTemplate.Modify(true);
        end;

        if Rec.Type = Enum::"Agent Template Type"::"Agent Message Template" then
            SaveMessageTemplate();

        exit(true);
    end;

    local procedure SaveMessageTemplate()
    var
        TempAgentTaskFile: Record "Agent Task File" temporary;
    begin
        if Rec.Type = Enum::"Agent Template Type"::"Agent Message Template" then
            AgentMessageTemplate.Name := Rec.Name;

        if AgentMessageTemplate.ID = 0 then begin
            AgentMessageTemplate.Name := Rec.Name;
            AgentMessageTemplate."Created with task" := AgentTaskTemplate.ID <> 0;
            AgentMessageTemplate.Insert(true);
        end else
            AgentMessageTemplate.Modify(true);

        AgentMessageTemplate.SetMessageText(MessageText);
        CurrPage.MessageAttachments.Page.GetUploadedFiles(TempAgentTaskFile);
        AgentMessageTemplate.SaveAttachments(AgentMessageTemplate, TempAgentTaskFile);
    end;

    var
        AgentTaskTemplate: Record "Agent Task Template";
        AgentMessageTemplate: Record "Agent Message Template";
        MessageText: Text;
        IncludeMessage: Boolean;
        AgentTaskProvided: Boolean;
        YouMustSetMessageTextErr: Label 'You must set the message text.';
        AgentMessageTemplateTxt: Label 'Agent Message Template', Locked = true;
}