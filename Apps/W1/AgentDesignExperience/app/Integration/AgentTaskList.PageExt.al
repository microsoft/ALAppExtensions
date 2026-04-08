// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;

pageextension 4351 "Agent Task List" extends "Agent Task List"
{
    actions
    {
        addlast(Processing)
        {
            group(CreateTaskGroup)
            {
                ShowAs = SplitButton;

                action(CreateTask)
                {
                    ApplicationArea = All;
                    Caption = 'Run task';
                    ToolTip = 'Run a new task.';
                    Image = Start;

                    trigger OnAction()
                    var
                        NewAgentTask: Record "Agent Task";
                        AgentNewTask: Page "Agent New Task Message";
                    begin
                        NewAgentTask."Agent User Security ID" := GetAgentSecurityID();

                        AgentNewTask.SetAgentTask(NewAgentTask, true);
                        AgentNewTask.LookupMode(true);
                        AgentNewTask.RunModal();
                        CurrPage.Update(false);
                    end;
                }
                action(CreateTaskFromTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Run task from template';
                    ToolTip = 'Run a new task from a template.';
                    Image = ApplyTemplate;

                    trigger OnAction()
                    var
                        AgentTaskTemplate: Codeunit "Agent Task Template";
                    begin
                        AgentTaskTemplate.CreateTaskFromTemplate(GetAgentSecurityID());
                        CurrPage.Update(false);
                    end;
                }
            }
            group(NewMessageGroup)
            {
                ShowAs = SplitButton;
                action(AddMessage)
                {
                    ApplicationArea = All;
                    Caption = 'Add new message';
                    ToolTip = 'Adds a new message to the task.';
                    Image = Task;
                    Enabled = TaskSelected;

                    trigger OnAction()
                    var
                        CurrentAgentTask: Record "Agent Task";
                        AgentNewTaskMessage: Page "Agent New Task Message";
                    begin
                        CurrentAgentTask.Get(Rec.ID);
                        AgentNewTaskMessage.SetAgentTask(CurrentAgentTask);
                        AgentNewTaskMessage.LookupMode(true);
                        AgentNewTaskMessage.RunModal();
                        CurrPage.Update(false);
                    end;
                }
                action(CreateMessageFromTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Add message from template';
                    ToolTip = 'Adds a new message from a template.';
                    Image = ApplyTemplate;
                    Enabled = TaskSelected;

                    trigger OnAction()
                    var
                        AgentTaskTemplate: Codeunit "Agent Task Template";
                    begin
                        AgentTaskTemplate.CreateMessageFromTemplate(Rec.ID);
                        CurrPage.Update(false);
                    end;
                }
            }
            action(Resume)
            {
                ApplicationArea = All;
                Caption = 'Resume';
                ToolTip = 'Resume the selected task.';
                Image = Restore;
                Enabled = TaskSelected;
                Scope = Repeater;

                trigger OnAction()
                var
                    AgentTask: Codeunit "Agent Task";
                begin
                    AgentTask.RestartTask(Rec, true);
                    CurrPage.Update(false);
                end;
            }
            action(RepeatTask)
            {
                ApplicationArea = All;
                Caption = 'Repeat task';
                ToolTip = 'Create a new task with the same title and properties. Only the first message and its attachments will be included.';
                Image = Copy;
                Enabled = TaskSelected;
                Scope = Repeater;

                trigger OnAction()
                var
                    AgentTaskTemplate: Codeunit "Agent Task Template";
                begin
                    AgentTaskTemplate.RepeatTask(Rec.ID);
                    CurrPage.Update(false);
                end;
            }
            action(CopyToTemplate)
            {
                ApplicationArea = All;
                Caption = 'Save task to template';
                ToolTip = 'Create a new template from the selected task.';
                Image = Copy;
                Enabled = TaskSelected;
                Scope = Repeater;

                trigger OnAction()
                var
                    TempAgentTaskTemplateBuffer: Record "Agent Task Template Buffer";
                    AgentTaskTemplate: Codeunit "Agent Task Template";
                    AgentTaskTemplateID: Integer;
                begin
                    AgentTaskTemplateID := AgentTaskTemplate.CreateTemplateFromTask(Rec.ID);

                    if AgentTaskTemplateID = 0 then
                        exit;

                    if Confirm(EditTemplateQst, true) then begin
                        TempAgentTaskTemplateBuffer.LoadRecords(Enum::"Agent Template Type"::"Agent Task Template");
                        TempAgentTaskTemplateBuffer.Get(AgentTaskTemplateID);
                        Page.Run(Page::"Agent Task Template Card", TempAgentTaskTemplateBuffer);
                    end;
                end;
            }
            action(AgentTemplateList)
            {
                ApplicationArea = All;
                Caption = 'Task templates';
                ToolTip = 'Configure agent task templates.';
                RunObject = page "Agent Task Templates";
                Image = Template;
            }
        }
        addlast(Category_Process)
        {
            group(Design)
            {
                Caption = 'Design';
                group(CreateTask_PromotedGroup)
                {
                    ShowAs = SplitButton;
                    actionref(CreateTask_Promoted; CreateTask)
                    {
                    }
                    actionref(CreateTaskFromTemplate_Promoted; CreateTaskFromTemplate)
                    {
                    }
                }
                group(CreateMessage_PromotedGroup)
                {
                    ShowAs = SplitButton;
                    actionref(AddMessage_Promoted; AddMessage)
                    {
                    }
                    actionref(CreateMessageFromTemplate_Promoted; CreateMessageFromTemplate)
                    {
                    }
                }
                actionref(Resume_Promoted; Resume)
                {
                }
                actionref(Stop_Promoted; Stop)
                {
                }
                actionref(CopyToTemplate_Promoted; CopyToTemplate)
                {
                }
                actionref(RepeatTask_Promoted; RepeatTask)
                {
                }
                actionref(AgentTemplateList_Promoted; AgentTemplateList)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
    begin
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        TaskSelected := Rec."ID" <> 0;
    end;

    local procedure GetAgentSecurityID(): Guid
    var
        AgentRecord: Record Agent;
        AgentSetup: Codeunit "Agent Setup";
        AgentUserSecurityId: Guid;
    begin
        if Rec.GetFilter("Agent User Security ID") <> '' then
            AgentUserSecurityId := Rec.GetFilter("Agent User Security ID")
        else
            AgentSetup.OpenAgentLookup(AgentUserSecurityId);

        AgentRecord.SetRange("User Security ID", AgentUserSecurityId);
        AgentRecord.FindFirst();

        if IsNullGuid(AgentRecord."User Security ID") then
            Error(NoAgentSelectedErr);

        if AgentRecord.State <> AgentRecord.State::Enabled then
            Error(AgentIsNotEnabledErr);

        exit(AgentRecord."User Security ID");
    end;

    var
        TaskSelected: Boolean;
        NoAgentSelectedErr: Label 'No agent is selected. Please select or activate an agent before creating a task.';
        AgentIsNotEnabledErr: Label 'The agent is not enabled. Please enable the agent before creating a task.';
        EditTemplateQst: Label 'Template was created. Do you want to edit the template now?';
}