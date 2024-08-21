// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4306 Tasks
{
    PageType = ListPlus;
    ApplicationArea = All;
    SourceTable = "Agent Task";
    Caption = 'Agent Tasks';
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;
    SourceTableView = sorting("Last Step Timestamp") order(descending);

    layout
    {
        area(Content)
        {
            repeater(AgentTasks)
            {
                Editable = false;
                field(TaskId; Rec.ID)
                {
                }
                field(TaskIndicator; Rec.Status)
                {
                }
                field(TaskStatus; TaskStatus)
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the task.';
                }
                field(TaskHeader; Rec.Title)
                {
                    Caption = 'Header';
                    ToolTip = 'Specifies the header of the task.';
                }
                field(TaskSummary; TaskSummary)
                {
                    Caption = 'Summary';
                    ToolTip = 'Specifies the summary of the task.';
                }
                field(TaskStartedOn; Rec.SystemCreatedAt)
                {
                    Caption = 'Started On';
                    ToolTip = 'Specifies the date and time when the task was started.';
                }
                field(TaskLastStepCompletedOn; Rec."Last Step Timestamp")
                {
                }
                field(TaskStepType; TaskStepType)
                {
                    Caption = 'Step Type';
                    ToolTip = 'Specifies the type of the last step.';
                    OptionCaption = 'Default,Message';
                }
            }
        }

        area(FactBoxes)
        {
            part(Timeline; "TaskTimeline")
            {
                SubPageLink = "Task ID" = field(ID);
                UpdatePropagation = Both;
                Editable = false;
            }

            part(Details; "TaskDetails")
            {
                Provider = Timeline;
                SubPageLink = "Task ID" = field("Task ID"), "Timeline Entry ID" = field(ID);
                Editable = true;
            }
        }
    }
    actions
    {
        area(Processing)
        {
#pragma warning disable AW0005
            action(StopTask)
#pragma warning restore AW0005
            {
                Caption = 'Stop task';
                ToolTip = 'Stops the task.';
                Enabled = true;
                Scope = Repeater;
                trigger OnAction()
                var
                    AgentMonitoringImpl: Codeunit "Agent Monitoring Impl.";
                begin
                    AgentMonitoringImpl.StopTask(Rec, Rec."Status"::"Stopped by User", false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetTaskDetails();
    end;

    procedure SetTaskDetails()
    var
        TaskTimelineEntry: Record "Agent Task Timeline Entry";
        InStream: InStream;
    begin
        TaskTimelineEntry.SetLoadFields("Primary Page Summary", Status, Title, Type, "Last Step Number");
        TaskTimelineEntry.SetRange("Task ID", Rec.ID);
        TaskTimelineEntry.SetFilter(Category, '%1|%2', TaskTimelineEntry.Category::Present, TaskTimelineEntry.Category::Past);
        if TaskTimelineEntry.FindLast() then begin
            if Rec."Last Step Number" = TaskTimelineEntry."Last Step Number" then
                TaskStatus := TaskTimelineEntry.Status
            else
                TaskStatus := Format(Rec.Status);
            TaskStepType := TaskTimelineEntry.Type;
            TaskTimelineEntry.CalcFields("Primary Page Summary");
            if TaskTimelineEntry."Primary Page Summary".HasValue() then begin
                TaskTimelineEntry."Primary Page Summary".CreateInStream(InStream);
                TaskSummary.Read(InStream);
            end;
        end;
    end;

    var
        TaskSummary: BigText;
        TaskStatus: Text[100];
        TaskStepType: Option;
}

