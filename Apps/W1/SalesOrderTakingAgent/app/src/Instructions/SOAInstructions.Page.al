// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

page 4317 "SOA Instructions"
{
    PageType = Document;
    ApplicationArea = All;
    SourceTable = "SOA Instruction Template";
    Caption = 'Sales Order Taking Agent Instructions';

    layout
    {
        area(Content)
        {
            group(Template)
            {
                field(Name; Rec.Name)
                {
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the instruction template.';
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the instruction template.';
                }
                field(Enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                    ToolTip = 'Specifies if the instruction template is enabled.';
                    ValuesAllowed = No, Yes;
                }
                field("Meta Prompt Code"; Rec."Meta Prompt Code")
                {
                    Caption = 'Metaprompt Code';
                    ToolTip = 'Specifies the code of the metaprompt.';
                }
                field("Prompt Code"; Rec."Prompt Code")
                {
                    Caption = 'Prompt Code';
                    ToolTip = 'Specifies the code of the prompt.';
                }
            }
            part("Phases"; "SOA Instruction Phases")
            {
                SubPageLink = "Template Name" = field(Name);
                Editable = Rec.Name <> '';
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Show Metaprompt")
            {
                Caption = 'Show Metaprompt';
                Image = Action;
                ToolTip = 'Show the metaprompt for the selected template';

                trigger OnAction()
                begin
                    Rec.ShowMetaPrompt();
                end;
            }
            action("Show Prompt")
            {
                Caption = 'Show Prompt';
                Image = Action;
                ToolTip = 'Show the prompt for the selected template';

                trigger OnAction()
                begin
                    Rec.ShowPrompt();
                end;
            }
        }
        area(Navigation)
        {
            action("All tasks and policies")
            {
                Caption = 'All tasks and policies';
                Image = TaskList;
                ToolTip = 'Show all tasks and policies.';
                RunObject = page "SOA Instruct. Tasks/Policies";
            }
            action("All prompts")
            {
                Caption = 'All prompts';
                Image = Action;
                ToolTip = 'Show all prompts.';
                RunObject = page "SOA Instruction Prompt List";
            }
        }
        area(Promoted)
        {
            group(Prompts)
            {
                actionref("Show Metaprompt_Promoted"; "Show Metaprompt") { }
                actionref("Show Prompt_Promoted"; "Show Prompt") { }
            }
            group(Navigate)
            {
                actionref("All tasks and policies_Promoted"; "All tasks and policies") { }
                actionref("All prompts_Promoted"; "All prompts") { }
            }
        }
    }
}