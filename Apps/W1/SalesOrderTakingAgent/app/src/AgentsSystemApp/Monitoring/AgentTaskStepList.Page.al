// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

page 4303 "Agent Task Step List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Agent Task Step";
    Caption = 'Agent Task Steps';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    SourceTableView = sorting("Step Number") order(descending);
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(AgentConversationActionLog)
            {
                field(StepNumber; Rec."Step Number")
                {
                    Caption = 'Step Number';
                }
                field(TaskID; Rec."Task ID")
                {
                    Visible = false;
                    Caption = 'Task ID';
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(Details; DetailsTxt)
                {
                    Caption = 'Details';
                    ToolTip = 'Specifies the step details.';

                    trigger OnDrillDown()
                    begin
                        Message(DetailsTxt);
                    end;
                }
                field("User Full Name"; Rec."User Full Name")
                {
                    Caption = 'User Full Name';
                    Tooltip = 'Specifies the full name of the user that was involved in performing the step..';
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
        DetailsTxt := AgentMonitoringImpl.GetDetailsForAgentTaskStep(Rec);
    end;

    var
        DetailsTxt: Text;
}