// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

page 4310 "SOA Instruct. Tasks/Policies"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "SOA Instruction Task/Policy";
    SourceTableView = sorting("Sorting Order No.");
    Caption = 'Instruction Tasks and Policies';
    PopulateAllFields = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(TasksPolicies)
            {
                field(Type; Rec.Type)
                {
                    Caption = 'Type';
                    ToolTip = 'Specifies if the step is a task or a policy.';
                }
                field(Name; Rec.Name)
                {
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the task or policy.';
                }
                field("Sorting Order No."; Rec."Sorting Order No.")
                {
                    Caption = 'Sorting Order No.';
                    ToolTip = 'Specifies the order number of the task or policy.';
                    Visible = false;
                }
                field(Enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                    ToolTip = 'Specifies if the task or policy is enabled.';
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
            action("Show Prompt")
            {
                Caption = 'Show Prompt';
                ToolTip = 'Show the prompt for the selected task or policy';
                Image = ViewDescription;

                trigger OnAction()
                begin
                    Rec.ShowPrompt();
                end;
            }
        }
        area(Promoted)
        {
            actionref("Show Prompt_Promoted"; "Show Prompt") { }
        }
    }
}