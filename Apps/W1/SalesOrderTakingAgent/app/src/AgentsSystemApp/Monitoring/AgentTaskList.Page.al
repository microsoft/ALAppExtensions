// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4300 "Agent Task List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Agent Task";
    Caption = 'Agent Tasks';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    AdditionalSearchTerms = 'Agent Tasks, Agent Task, Agent, Agent Log, Agent Logs';
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(AgentConversations)
            {
                field(Title; Rec.Title)
                {
                    Caption = 'Title';
                }
                field(LastStepTimestamp; Rec."Last Step Timestamp")
                {
                    Caption = 'Last Updated';
                }
                field(LastStepNumber; Rec."Last Step Number")
                {
                }
                field(Status; Rec.Status)
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the agent task.';
                }
                field(CreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Created at';
                    ToolTip = 'Specifies the date and time when the agent task was created.';
                }
                field(ID; Rec.ID)
                {
                    Caption = 'ID';
                    trigger OnDrillDown()
                    begin
                        ShowTaskMessages();
                    end;
                }
                field(NumberOfStepsDone; NumberOfStepsDone)
                {
                    Caption = 'Steps Done';
                    ToolTip = 'Specifies the number of steps that have been done for the specific task.';

                    trigger OnDrillDown()
                    var
                        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
                    begin
                        AgentMonitoringImpl.ShowTaskSteps(Rec);
                    end;
                }
                field("Created By"; Rec."Created By Full Name")
                {
                    Caption = 'Created by';
                    Tooltip = 'Specifies the full name of the user that created the agent task.';
                }
                field("Agent Display Name"; Rec."Agent Display Name")
                {
                    Caption = 'Agent';
                    ToolTip = 'Specifies the agent that is associated with the task.';
                }
                field(CreatedByID; Rec."Created By")
                {
                    Visible = false;
                }
                field(AgentUserSecurityID; Rec."Agent User Security ID")
                {
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CreateTask)
            {
                ApplicationArea = All;
                Caption = 'Create task';
                ToolTip = 'Create a new task.';
                Image = New;

                trigger OnAction()
                var
                    Agent: Record Agent;
                    NewAgentTask: Record "Agent Task";
                    AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
                    AgentNewTask: Page "Agent New Task Message";
                begin
                    if Rec.GetFilter("Agent User Security ID") <> '' then begin
                        Agent.SetRange("User Security ID", Rec.GetFilter("Agent User Security ID"));
                        Agent.FindFirst();
                    end else
                        AgentMonitoringImpl.SelectAgent(Agent);

                    NewAgentTask."Agent User Security ID" := Agent."User Security ID";
                    AgentNewTask.SetAgentTask(NewAgentTask);
                    AgentNewTask.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(ViewTaskMessage)
            {
                ApplicationArea = All;
                Caption = 'View messages';
                ToolTip = 'Show messages for the selected task.';
                Image = ShowList;

                trigger OnAction()
                begin
                    ShowTaskMessages();
                end;
            }
            action(ViewTaskSteps)
            {
                ApplicationArea = All;
                Caption = 'View steps';
                ToolTip = 'Show steps for the selected task.';
                Image = TaskList;

                trigger OnAction()
                var
                    AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
                begin
                    AgentMonitoringImpl.ShowTaskSteps(Rec);
                end;
            }
            action(Stop)
            {
                ApplicationArea = All;
                Caption = 'Stop';
                ToolTip = 'Stop the selected task.';
                Image = Stop;

                trigger OnAction()
                var
                    AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
                begin
                    AgentMonitoringImpl.StopTask(Rec, Rec."Status"::"Stopped by User", true);
                    CurrPage.Update(false);
                end;
            }
            action(Restart)
            {
                ApplicationArea = All;
                Caption = 'Restart';
                ToolTip = 'Restart the selected task.';
                Image = Restore;

                trigger OnAction()
                var
                    AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
                begin
                    AgentMonitoringImpl.RestartTask(Rec, true);
                    CurrPage.Update(false);
                end;
            }
            action(UserIntervention)
            {
                ApplicationArea = All;
                Caption = 'User Intervention';
                ToolTip = 'Provide the required user intervention.';
                Image = Restore;
                Enabled = UserInterventionEnabled;

                trigger OnAction()
                var
                    UserInterventionRequestStep: Record "Agent Task Step";
                    AgentUserIntervention: Page "Agent User Intervention";
                begin
                    UserInterventionRequestStep.Get(Rec.ID, Rec."Last Step Number");
                    AgentUserIntervention.SetUserInterventionRequestStep(UserInterventionRequestStep);
                    AgentUserIntervention.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ViewTaskMessage_Promoted; ViewTaskMessage)
                {
                }
                actionref(ViewTaskSteps_Promoted; ViewTaskSteps)
                {
                }
                actionref(CreateTask_Promoted; CreateTask)
                {
                }
                actionref(UserIntervention_Promoted; UserIntervention)
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
        AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
    begin
        NumberOfStepsDone := AgentMonitoringImpl.GetStepsDoneCount(Rec);
        UserInterventionEnabled := Rec.Status = Rec.Status::"Pending User Intervention";
    end;

    local procedure ShowTaskMessages()
    var
        AgentTaskMessage: Record "Agent Task Message";
    begin
        AgentTaskMessage.SetRange("Task ID", Rec.ID);
        Page.Run(Page::"Agent Task Message List", AgentTaskMessage);
    end;

    var
        NumberOfStepsDone: Integer;
        UserInterventionEnabled: Boolean;
}