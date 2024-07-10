// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

page 4304 "SOA Instruction Templates"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "SOA Instruction Template";
    Caption = 'Sales Order Taking Agent Instruction Templates';

    layout
    {
        area(Content)
        {
            repeater(Templates)
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
            action("Edit Template")
            {
                Caption = 'Edit Template';
                ToolTip = 'Edit the selected template.';
                Image = Edit;
                RunObject = page "SOA Instructions";
                RunPageOnRec = true;
            }
            action("Show Prompt")
            {
                Caption = 'Show Prompt';
                ToolTip = 'Show the prompt for the selected template';
                Image = ViewDescription;

                trigger OnAction()
                begin
                    Rec.ShowPrompt();
                end;
            }
            action("Initial Setup")
            {
                Caption = 'Initial Setup';
                Image = Setup;
                ToolTip = 'Setup the sales order taking agent instructions.';
                Visible = false;

                trigger OnAction()
                var
                    SOADemoPrompt: Codeunit "SOA Demo Prompt";
                begin
                    SOADemoPrompt.Run();
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            actionref("Edit Template_Promoted"; "Edit Template") { }
            actionref("Show Prompt_Promoted"; "Show Prompt") { }
        }
    }
}