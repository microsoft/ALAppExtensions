// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

page 4312 "SOA Instruction Phases"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "SOA Instruction Phase";
    Caption = 'Instruction Phases';

    layout
    {
        area(Content)
        {
            repeater(PhaseSteps)
            {
                ShowCaption = false;

                field("Phase Order No."; Rec."Phase Order No.")
                {
                    Caption = 'Phase Order No.';
                    ToolTip = 'Specifies the order number of the phase.';
                }
                field(Phase; Rec.Phase)
                {
                    Caption = 'Phase';
                    ToolTip = 'Specifies the phase of the instruction.';
                }
                field(Enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                    ToolTip = 'Specifies if the instruction phase is enabled.';
                    ValuesAllowed = No, Yes;
                }
                field("Prompt Code"; Rec."Prompt Code")
                {
                    Caption = 'Prompt Code';
                    ToolTip = 'Specifies the code of the prompt.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Tasks and policies")
            {
                Caption = 'Tasks and policies';
                Image = Task;
                ToolTip = 'Show the tasks and policies for the selected phase.';
                RunObject = page "SOA Instruction Phase Steps";
                RunPageLink = Phase = field(Phase);
            }
            action("Show Prompt")
            {
                Caption = 'Show Prompt';
                Image = Action;
                ToolTip = 'Show the prompt for the selected phase.';

                trigger OnAction()
                begin
                    Rec.ShowPrompt();
                end;
            }
        }
    }
}