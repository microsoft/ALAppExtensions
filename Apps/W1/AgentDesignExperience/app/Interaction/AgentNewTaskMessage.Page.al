// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;

page 4359 "Agent New Task Message"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Create message';
    DataCaptionExpression = '';
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            group(Task)
            {
                Visible = GlobalCreateNewTask;
                Caption = 'Task';
                field(TitleText; TitleText)
                {
                    ShowMandatory = true;
                    Caption = 'Title';
                    ToolTip = 'Specifies the title of the task.';
                    Editable = TitleEditable;
                }
                field(SaveAsTemplate; SaveAsTemplate)
                {
                    Caption = 'Save as template';
                    ToolTip = 'Specifies whether to save this task as a template when the page is closed.';
                }
                field(ExternalId; ExternalId)
                {
                    Caption = 'External ID';
                    ToolTip = 'Specifies the external ID of the task. This field is used to connect to external systems, like Message ID for emails.';
                    Importance = Additional;
                }
                field(IncludeMessage; IncludeMessage)
                {
                    Visible = GlobalCreateNewTask;
                    Caption = 'Include message';
                    ToolTip = 'Specifies if message should be included in the task. It is possible to create tasks with no messages.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
            group(Message)
            {
                Caption = 'Message';
                Visible = IncludeMessage;

                field(FromText; FromText)
                {
                    Caption = 'From';
                    ShowMandatory = IncludeMessage;
                    ToolTip = 'Specifies who the message is from.';
                }

                field(MessageExternalId; MessageExternalId)
                {
                    Caption = 'Message External ID';
                    ToolTip = 'Specifies the external ID of the message. This field is used to connect to external systems, like Message ID for emails. This value allows to track the specific message ID that can be different than the one defined for the task.';
                    Importance = Additional;
                }

                field(RequiresReview; RequiresReview)
                {
                    Caption = 'Requires review';
                    ToolTip = 'Specifies whether the message requires review.';
                    Importance = Additional;
                }

                field(SanitizeMessageText; SanitizeMessageText)
                {
                    Caption = 'Sanitize message text';
                    ToolTip = 'Specifies whether to sanitize the text of the message.';
                    Importance = Additional;
                }
                field(IgnoreAttachments; IgnoreAttachments)
                {
                    Caption = 'Ignore attachments';
                    ToolTip = 'Specifies whether to ignore processing of attachments in the message.';
                    Importance = Additional;
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
    actions
    {
        area(Processing)
        {
            group(Template)
            {
                Caption = 'Template';

                action(SaveToTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Save to template';
                    ToolTip = 'Saves the current task and message as a template for future use.';
                    Image = Save;

                    trigger OnAction()
                    var
                        TempAgentTaskFile: Record "Agent Task File" temporary;
                        AgentTaskTemplate: Record "Agent Task Template";
                        AgentTaskMessageTemplate: Record "Agent Message Template";
                        AgentTemplate: Codeunit "Agent Task Template";
                    begin
                        CurrPage.MessageAttachments.Page.GetUploadedFiles(TempAgentTaskFile);
                        if GlobalCreateNewTask then begin
                            if IncludeMessage then
                                AgentTaskMessageTemplate := AgentTemplate.CreateMessageTemplate(TitleText, FromText, MessageText, MessageExternalId, RequiresReview, SanitizeMessageText, IgnoreAttachments, TempAgentTaskFile, true);
                            AgentTaskTemplate := AgentTemplate.CreateTaskTemplate(TitleText, TitleText, ExternalId, AgentTaskMessageTemplate);
                        end else
                            AgentTaskMessageTemplate := AgentTemplate.CreateMessageTemplate(TitleText, FromText, MessageText, MessageExternalId, RequiresReview, SanitizeMessageText, IgnoreAttachments, TempAgentTaskFile, false);
                    end;
                }
                action(ApplyTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Apply template';
                    ToolTip = 'Applies a template.';
                    Image = ApplyTemplate;

                    trigger OnAction()
                    begin
                        if GlobalCreateNewTask then
                            ApplyTaskTemplate()
                        else
                            ApplyMessageTemplate();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {

                actionref(SaveToTemplate_Promoted; SaveToTemplate)
                {
                }
                actionref(ApplyTemplate_Promoted; ApplyTemplate)
                {
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        TempAgentTaskTemplateBuffer: Record "Agent Task Template Buffer";
        TempAgentTaskFile: Record "Agent Task File" temporary;
        AgentTaskTemplate: Codeunit "Agent Task Template";
        AgentTemplateID: Integer;
    begin
        if not (CloseAction in [Action::Ok, Action::LookupOK, Action::Yes]) then
            exit(true);

        if GlobalCreateNewTask then begin
            CreateNewTask();
            if SaveAsTemplate then begin
                CurrPage.MessageAttachments.Page.GetUploadedFiles(TempAgentTaskFile);
                AgentTemplateID := AgentTaskTemplate.CreateTemplateFromTask(GlobalAgentTask.ID, TempAgentTaskFile);
            end;
            Commit();
            if AgentTemplateID <> 0 then
                if Confirm(EditTemplateQst, true) then begin
                    TempAgentTaskTemplateBuffer.LoadRecords(Enum::"Agent Template Type"::"Agent Task Template");
                    TempAgentTaskTemplateBuffer.Get(AgentTemplateID);
                    Page.Run(Page::"Agent Task Template Card", TempAgentTaskTemplateBuffer);
                end;

        end else
            AddMessageToExistingTask();

        exit(true);
    end;

    local procedure ApplyTaskTemplate()
    var
        AgentTaskTemplate: Record "Agent Task Template";
        AgentTaskTemplates: Page "Agent Task Templates";
    begin
        AgentTaskTemplates.LookupMode(true);
        if not (AgentTaskTemplates.RunModal() in [Action::OK, Action::LookupOK]) then
            exit;

        if not AgentTaskTemplate.Get(AgentTaskTemplates.GetSelectedSourceID()) then
            exit;

        ApplyTaskTemplate(AgentTaskTemplate);
    end;

    local procedure ApplyTaskTemplate(AgentTaskTemplate: Record "Agent Task Template")
    var
        AgentTaskMessageTemplate: Record "Agent Message Template";
    begin
        TitleText := AgentTaskTemplate."Task Title";
        ExternalId := AgentTaskTemplate."Task External Id";
        IncludeMessage := AgentTaskTemplate."Include Message";
        if IncludeMessage then begin
            AgentTaskMessageTemplate.Get(AgentTaskTemplate."Message Template ID");
            ApplyMessageTemplate(AgentTaskMessageTemplate);
        end;

        CurrPage.Update(false);
    end;

    local procedure ApplyMessageTemplate()
    var
        AgentTaskMessageTemplate: Record "Agent Message Template";
        AgentMessageTemplates: Page "Agent Task Templates";
    begin
        AgentMessageTemplates.LookupMode(true);
        AgentMessageTemplates.SetType(Enum::"Agent Template Type"::"Agent Message Template");
        if not (AgentMessageTemplates.RunModal() in [Action::OK, Action::LookupOK]) then
            exit;

        AgentTaskMessageTemplate.Get(AgentMessageTemplates.GetSelectedSourceID());
        ApplyMessageTemplate(AgentTaskMessageTemplate);
        CurrPage.Update(false);
    end;

    local procedure ApplyMessageTemplate(AgentTaskMessageTemplate: Record "Agent Message Template")
    var
        TemporaryAgentTaskFile: Record "Agent Task File" temporary;
    begin
        MessageText := AgentTaskMessageTemplate.GetMessageText();
        FromText := AgentTaskMessageTemplate."Message From Text";
        MessageExternalId := AgentTaskMessageTemplate."Message External Id";
        RequiresReview := AgentTaskMessageTemplate."Message Requires Review";
        SanitizeMessageText := AgentTaskMessageTemplate."Sanitize Message Content";
        IgnoreAttachments := AgentTaskMessageTemplate."Ignore Attachments";

        AgentTaskMessageTemplate.LoadAttachments(AgentTaskMessageTemplate, TemporaryAgentTaskFile);
        CurrPage.MessageAttachments.Page.SetData(TemporaryAgentTaskFile);
    end;

    local procedure AddMessageToExistingTask()
    var
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
    begin
        AgentTaskMessageBuilder := CreateNewMessage();
        AgentTaskMessageBuilder.SetAgentTask(GlobalAgentTask);
        AgentTaskMessageBuilder.Create();
    end;

    local procedure CreateNewTask()
    var
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
    begin
        if TitleText = '' then
            Error(YouMustSetTaskTitleErr);

        GlobalAgentTask.Title := TitleText;

        AgentTaskBuilder.Initialize(GlobalAgentTask."Agent User Security ID", GlobalAgentTask.Title)
                       .SetExternalId(ExternalId);

        if ((MessageText = '') and (FromText = '')) then
            IncludeMessage := false;

        if IncludeMessage then begin
            AgentTaskMessageBuilder := CreateNewMessage();
            AgentTaskBuilder.AddTaskMessage(AgentTaskMessageBuilder);
        end;

        GlobalAgentTask := AgentTaskBuilder.Create(true, false);
    end;

    local procedure CreateNewMessage(): Codeunit "Agent Task Message Builder"
    var
        TempAgentTaskFile: Record "Agent Task File" temporary;
        AgentDesignerUtilities: Codeunit "Agent Designer Utilities";
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
        AttachmentsExists: Boolean;
        TaskMessageText: Text;
    begin
        if MessageText = '' then
            Error(YouMustSetMessageTextErr);

        TaskMessageText := SanitizeMessageText ? AgentDesignerUtilities.SanitizeContent(MessageText) : MessageText;
        if FromText <> '' then
            AgentTaskMessageBuilder.Initialize(FromText, TaskMessageText)
        else
            AgentTaskMessageBuilder.Initialize(TaskMessageText);

        AgentTaskMessageBuilder.SetMessageExternalID(MessageExternalId)
                                .SetRequiresReview(RequiresReview)
                                .SetIgnoreAttachment(IgnoreAttachments);

        AttachmentsExists := CurrPage.MessageAttachments.Page.GetUploadedFiles(TempAgentTaskFile);
        if AttachmentsExists then begin
            TempAgentTaskFile.FindSet();
            repeat
                AgentTaskMessageBuilder.AddAttachment(TempAgentTaskFile);
            until TempAgentTaskFile.Next() = 0;
        end;

        exit(AgentTaskMessageBuilder);
    end;

    internal procedure SetAgentTask(var NewAgentTask: Record "Agent Task")
    begin
        SetAgentTask(NewAgentTask, false);
    end;

    internal procedure SetAgentTask(var NewAgentTask: Record "Agent Task"; CreateTask: Boolean)
    begin
        GlobalAgentTask.Copy(NewAgentTask);
        TitleEditable := GlobalAgentTask.Title = '';
        TitleText := GlobalAgentTask.Title;
        IncludeMessage := true;

        if CreateTask then begin
            GlobalCreateNewTask := true;
            CurrPage.Caption(CreateNewTaskLbl);
        end;
    end;

    trigger OnOpenPage()
    var
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
    begin
        FromText := CopyStr(UserId(), 1, MaxStrLen(FromText));
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();
        SanitizeMessageText := true;
        RequiresReview := false;
        IgnoreAttachments := false;
    end;

    var
        GlobalAgentTask: Record "Agent Task";
        MessageText: Text;
        TitleText: Text[150];
        FromText: Text[250];
        TitleEditable: Boolean;
        IncludeMessage: Boolean;
        GlobalCreateNewTask: Boolean;
        SanitizeMessageText: Boolean;
        RequiresReview: Boolean;
        IgnoreAttachments: Boolean;
        SaveAsTemplate: Boolean;
        ExternalId: Text[2048];
        MessageExternalId: Text[2048];
        CreateNewTaskLbl: Label 'Create new task';
        YouMustSetMessageTextErr: Label 'You must set the message text.';
        YouMustSetTaskTitleErr: Label 'You must set the task title.';
        EditTemplateQst: Label 'Template was created. Do you want to edit the template now?';
}