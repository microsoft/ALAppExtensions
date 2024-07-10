// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4316 "Agent List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Agent";
    Caption = 'Agents';
    CardPageId = "Agent Card";
    AdditionalSearchTerms = 'Agent, Agents, Copilot, Automation, AI';
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Main)
            {
                Editable = false;

                field(UserName; Rec."User Name")
                {
                    Caption = 'User Name';
                }
                field(DisplayName; Rec."Display Name")
                {
                    Caption = 'Display Name';
                }
                field(State; Rec.State)
                {
                    Caption = 'State';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(AgentTasks)
            {
                ApplicationArea = All;
                Caption = 'Agent Tasks';
                ToolTip = 'View agent tasks';
                Image = Log;

                trigger OnAction()
                var
                    AgentTask: Record "Agent Task";
                begin
                    AgentTask.SetRange("Agent User Security ID", Rec."User Security ID");
                    Page.Run(Page::"Agent Task List", AgentTask);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(AgentTasks_Promoted; AgentTasks)
                {
                }
            }
        }
    }
}