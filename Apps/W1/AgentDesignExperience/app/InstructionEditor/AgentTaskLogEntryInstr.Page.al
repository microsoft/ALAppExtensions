// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;
using System.Agents.TaskPane;
using System.Agents.Troubleshooting;
using System.Environment.Consumption;
using System.Security.AccessControl;

page 4362 "Agent Task Log Entry Instr"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Agent Task Log Entry";
    Caption = 'Agent Task Log';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    SourceTableView = sorting("ID") order(descending);
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            repeater(LogEntries)
            {
                field(ID; Rec."ID")
                {
                    Caption = 'ID';
                    ToolTip = 'Specifies the unique identifier of the log entry.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Agent Task Log Entry", Rec);
                    end;
                }
                field(TaskID; Rec."Task ID")
                {
                    Visible = false;
                    Caption = 'Task ID';
                }
                field(Type; Rec.Type)
                {
                    Caption = 'Type';
                    StyleExpr = TypeStyle;
                }
                field(Level; Rec.Level)
                {
                    Caption = 'Level';
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';

                    trigger OnDrillDown()
                    begin
                        Message(Rec.Description);
                    end;
                }
                field(Reason; Rec.Reason)
                {
                    Caption = 'Reason';
                    ToolTip = 'Specifies the reason, provided by the agent, for the log entry.';
                    Importance = Promoted;

                    trigger OnDrillDown()
                    begin
                        Message(Rec.Reason);
                    end;
                }
                field(Details; DetailsTxt)
                {
                    Caption = 'Details';
                    ToolTip = 'Specifies the details.';

                    trigger OnDrillDown()
                    begin
                        Message(DetailsTxt);
                    end;
                }
                field(PageCaption; Rec."Page Caption")
                {
                    Caption = 'Page caption';
                }
                field(Username; UserName)
                {
                    Visible = false;
                    Caption = 'User';
                    ToolTip = 'Specifies the name of related user.';
                }
                field(CreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Timestamp';
                    ToolTip = 'Specifies the date and time when the log entry was created.';
                }
            }
            field(TaskTitle; CurrentTaskTitleTxt)
            {
                ShowCaption = true;
                Caption = 'Task';
                ToolTip = 'Specifies the title of the related task.';
                StyleExpr = 'Strong';
                Editable = false;
                trigger OnAssistEdit()
                begin
                    SelectTask();
                end;
            }
            field(Credits; ConsumedCredits)
            {
                Visible = ConsumedCreditsVisible;
                Caption = 'Copilot credits used';
                ToolTip = 'Specifies the number of Copilot credits consumed by the agent task.';
                AutoFormatType = 0;
                DecimalPlaces = 0 : 2;

                trigger OnDrillDown()
                var
                    UserAIConsumptionData: Record "User AI Consumption Data";
                begin
                    UserAIConsumptionData.SetRange("User Id", GlobalUserSecurityId);
                    UserAIConsumptionData.SetRange("Agent Task Id", GlobalAgentTask.ID);
                    Page.Run(Page::"Agent Consumption Overview", UserAIConsumptionData);
                end;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ViewDetails)
            {
                Caption = 'View details';
                ToolTip = 'View the details of the selected log entry.';
                Image = ViewDetails;

                trigger OnAction()
                begin
                    Page.Run(Page::"Agent Task Log Entry", Rec);
                end;
            }
            action(Refresh)
            {
                Caption = 'Refresh';
                ToolTip = 'Refresh the log entries.';
                Image = Refresh;

                trigger OnAction()
                begin
                    UpdateDataShown();
                end;
            }
            action(PreviousTask)
            {
                Caption = 'Previous task';
                ToolTip = 'Navigate to the previous agent task.';
                Image = PreviousRecord;

                trigger OnAction()
                begin
                    NavigateToPreviousTask();
                end;
            }
            action(NextTask)
            {
                Caption = 'Next task';
                ToolTip = 'Navigate to the next agent task.';
                Image = NextRecord;

                trigger OnAction()
                begin
                    NavigateToNextTask();
                end;
            }
            action(LastTask)
            {
                Caption = 'Last task';
                ToolTip = 'Navigate to the last (most recent) agent task.';
                Image = CalendarChanged;

                trigger OnAction()
                begin
                    ShowLastTask();
                end;
            }
            action(SelectTaskAction)
            {
                Caption = 'Select task';
                ToolTip = 'Select a task to view the log entries for.';
                Image = SelectReport;

                trigger OnAction()
                begin
                    SelectTask();
                end;
            }
            action(Disclaimer)
            {
                Caption = 'AI-generated content may be incorrect.';
                ToolTip = 'Learn more about AI-generated content.';
                Image = Info;

                trigger OnAction()
                begin
                    Hyperlink('https://go.microsoft.com/fwlink/?linkid=2349003');
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
        AgentSystemPermissions: Codeunit "Agent System Permissions";
    begin
        AgentDesignerPermissions.VerifyCurrentUserCanConfigureCustomAgent(GlobalUserSecurityId);
        ConsumedCreditsVisible := AgentSystemPermissions.CurrentUserCanSeeConsumptionData();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
        TaskSelected := HasTaskSelected();
        CalculateTaskConsumedCredits();
    end;

    internal procedure HasTaskSelected(): Boolean
    begin
        if Rec."Task ID" = 0 then
            if Rec.FindFirst() then;

        exit(Rec."Task ID" <> 0);
    end;

    internal procedure SetUserSecurityId(NewUserSecurityId: Guid)
    begin
        GlobalUserSecurityId := NewUserSecurityId;
        ShowLastTask();
    end;

    internal procedure ShowLastTask()
    var
        LastCreatedAgentTask: Record "Agent Task";
        LastModifiedAgentTask: Record "Agent Task";
    begin
        Clear(GlobalAgentTask);

        LastCreatedAgentTask.SetRange("Agent User Security ID", GlobalUserSecurityId);
        LastCreatedAgentTask.SetCurrentKey(SystemCreatedAt);
        LastCreatedAgentTask.Ascending(false);
        if LastCreatedAgentTask.FindFirst() then
            GlobalAgentTask := LastCreatedAgentTask;

        LastModifiedAgentTask.SetRange("Agent User Security ID", GlobalUserSecurityId);
        LastModifiedAgentTask.SetCurrentKey("Last Log Entry Timestamp");
        LastModifiedAgentTask.Ascending(false);

        if LastModifiedAgentTask.FindFirst() then
            if GlobalAgentTask.SystemCreatedAt < LastModifiedAgentTask."Last Log Entry Timestamp" then
                GlobalAgentTask := LastModifiedAgentTask;

        GlobalAgentTask.Reset();
        GlobalAgentTask.SetRange("Agent User Security ID", GlobalUserSecurityId);
        UpdateDataShown();
    end;

    internal procedure GetTaskID(): Integer
    begin
        exit(Rec."Task ID");
    end;

    internal procedure SelectTask()
    var
        AgentTask: Record "Agent Task";
    begin
        AgentTask.SetRange("Agent User Security ID", GlobalUserSecurityId);
        if AgentTask.Get(Rec."Task ID") then;
        if Page.RunModal(Page::"Agent Task List", AgentTask) = Action::LookupOK then begin
            GlobalAgentTask := AgentTask;
            UpdateDataShown();
        end;
    end;

    local procedure NavigateToPreviousTask()
    begin
        if GlobalAgentTask.Next(-1) = 0 then begin
            Message(NoPreviousTaskMsg);
            exit;
        end;

        UpdateDataShown();
        CurrPage.Update(false);
    end;

    local procedure NavigateToNextTask()
    begin
        if GlobalAgentTask.Next() <= 0 then begin
            Message(NoNextTaskMsg);
            exit;
        end;

        UpdateDataShown();
        CurrPage.Update(false);
    end;

    internal procedure UpdateDataShown()
    var
        TaskPane: Codeunit "Task Pane";
    begin
        if GlobalAgentTask.ID <> 0 then begin
            CurrentTaskTitleTxt := GetAgentTaskTitle(GlobalAgentTask);
            Rec.SetRange("Task ID", GlobalAgentTask.ID);
            TaskPane.ShowTask(GlobalAgentTask);
        end else begin
            Clear(CurrentTaskTitleTxt);
            Rec.SetRange("Task ID", 0);
            TaskPane.ShowAgent(GlobalUserSecurityId);
        end;
        CurrPage.Update(false);
    end;

    local procedure UpdateControls()
    var
        User: Record User;
        AgentTaskImpl: Codeunit "Agent Task Impl.";
    begin
        DetailsTxt := AgentTaskImpl.GetDetailsForAgentTaskLogEntry(Rec);
        case Rec.Level of
            Rec.Level::Error:
                TypeStyle := Format(PageStyle::Unfavorable);
            Rec.Level::Warning:
                TypeStyle := Format(PageStyle::Ambiguous);
            else
                TypeStyle := Format(PageStyle::Standard);
        end;

        User.SetRange("User Security ID", Rec.SystemCreatedBy);
        if User.FindFirst() then
            UserName := User."User Name";
    end;

    local procedure CalculateTaskConsumedCredits()
    var
        UserAIConsumptionData: Record "User AI Consumption Data";
    begin
        if not ConsumedCreditsVisible then begin
            Clear(ConsumedCredits);
            exit;
        end;

        UserAIConsumptionData.SetRange("Agent Task Id", Rec."Task ID");
        UserAIConsumptionData.SetRange("User Id", GlobalUserSecurityId);
        UserAIConsumptionData.CalcSums("Copilot Credits");
        ConsumedCredits := UserAIConsumptionData."Copilot Credits";
    end;

    local procedure GetAgentTaskTitle(AgentTask: Record "Agent Task"): Text
    var
        AgentTaskText: Text;
    begin
        AgentTaskText := Format(AgentTask.ID, 0, 9);
        AgentTaskText := PadStr('', 4 - StrLen(AgentTaskText), '0') + AgentTaskText;
        exit(StrSubstNo(TaskLbl, '#' + AgentTaskText + ' - ' + AgentTask.Title));
    end;

    var
        GlobalAgentTask: Record "Agent Task";
        DetailsTxt: Text;
        TypeStyle: Text;
        UserName: Text;
        ConsumedCreditsVisible, TaskSelected : Boolean;
        ConsumedCredits: Decimal;
        GlobalUserSecurityId: Guid;
        CurrentTaskTitleTxt: Text;
        TaskLbl: Label 'Task %1', Comment = '%1 Number and the name of the task, e.g. #0012 - Sample Task Title';
        NoPreviousTaskMsg: Label 'There is no previous task for this agent.';
        NoNextTaskMsg: Label 'There is no next task for this agent.';
}
