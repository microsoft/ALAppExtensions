// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

page 4311 "SOA Instruction Prompt List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "SOA Instruction Prompt";
    Caption = 'Instruction Prompts';
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Prompts)
            {
                field(Code; Rec.Code)
                {
                    Caption = 'Code';
                    ToolTip = 'Specifies the code of the prompt.';
                }
                field("Prompt Text"; PromptText)
                {
                    Caption = 'Prompt';
                    ToolTip = 'Specifies the prompt.';
                    Editable = false;
                }
                field(Enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                    ToolTip = 'Specifies if the prompt is enabled.';
                    ValuesAllowed = No, Yes;
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
                Caption = 'Edit Prompt';
                Image = Action;
                ToolTip = 'Edit the current prompt';

                trigger OnAction()
                begin
                    Rec.ShowPrompt();
                end;
            }
        }
    }

    var
        InstructionsMgt: Codeunit "SOA Instructions Mgt.";
        PromptText: Text;

    trigger OnAfterGetRecord()
    begin
        PromptText := InstructionsMgt.GetPromptText(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        PromptText := '';
    end;
}