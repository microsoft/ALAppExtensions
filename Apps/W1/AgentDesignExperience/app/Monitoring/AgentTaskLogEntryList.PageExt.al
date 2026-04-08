// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Troubleshooting;

using System.Agents;

pageextension 4355 "Agent Task Log Entry List" extends "Agent Task Log Entry List"
{
    actions
    {
        addlast(Promoted)
        {
            group(Design)
            {
                Caption = 'Design';

                actionref(AgentSetup_Promoted; AgentSetup) { }
                actionref(Resume_Promoted; Resume) { }
                actionref(Stop_Promoted; Stop) { }
            }
        }
        addlast(Processing)
        {
            action(Stop)
            {
                ApplicationArea = All;
                Caption = 'Stop';
                ToolTip = 'Stop the selected task.';
                Image = Stop;

                trigger OnAction()
                var
                    AgentTaskRecord: Record "Agent Task";
                    AgentTask: Codeunit "Agent Task";
                begin
                    AgentTaskRecord.Get(Rec."Task ID");
                    AgentTask.StopTask(AgentTaskRecord, true);
                end;
            }
            action(Resume)
            {
                ApplicationArea = All;
                Caption = 'Resume';
                ToolTip = 'Resume the selected task.';
                Image = Restore;

                trigger OnAction()
                var
                    AgentTaskRecord: Record "Agent Task";
                    AgentTask: Codeunit "Agent Task";
                begin
                    AgentTaskRecord.Get(Rec."Task ID");
                    AgentTask.RestartTask(AgentTaskRecord, true);
                end;
            }
            action(AgentSetup)
            {
                ApplicationArea = All;
                Caption = 'Agent setup';
                ToolTip = 'Opens the agent card page for the agent who has been assigned the selected task.';
                Image = Setup;

                trigger OnAction()
                var
                    Agent: Record Agent;
                    AgentTask: Record "Agent Task";
                begin
                    AgentTask.Get(Rec."Task ID");
                    Agent.Get(AgentTask."Agent User Security ID");
                    Page.RunModal(Page::"Agent Card", Agent);
                end;
            }
        }
    }
}