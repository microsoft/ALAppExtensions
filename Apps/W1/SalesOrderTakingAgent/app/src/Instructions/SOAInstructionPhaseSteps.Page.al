// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

page 4309 "SOA Instruction Phase Steps"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "SOA Instruction Phase Step";
    Caption = 'Instruction Phase Steps';
    PopulateAllFields = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(PhaseSteps)
            {
                IndentationColumn = Indent;
                IndentationControls = "Step Name";

                field(Phase; Rec.Phase)
                {
                    Caption = 'Phase';
                    ToolTip = 'Specifies the phase of the instruction.';
                }
                field("Step No."; Rec."Step No.")
                {
                    Caption = 'Step No.';
                    ToolTip = 'Specifies the step number of the task or policy in the phase.';
                }
                field(Step; Step)
                {
                    Caption = 'Step';
                    ToolTip = 'Specifies the task or policy in the phase.';
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        LookUpPhaseStep();
                        CurrPage.Update();
                    end;
                }
                field("Step Type"; Rec."Step Type")
                {
                    Caption = 'Step Type';
                    ToolTip = 'Specifies if the step is a task or a policy.';
                    Visible = false;
                }
                field("Step Name"; Rec."Step Name")
                {
                    Caption = 'Step Name';
                    ToolTip = 'Specifies the name of the task or policy.';
                    Visible = false;
                }
                field(Indentation; Rec.Indentation)
                {
                    Caption = 'Indentation';
                    ToolTip = 'Specifies the indentation level of the task or policy.';
                    Visible = false;
                }
                field(Enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                    ToolTip = 'Specifies if the instruction phase is enabled.';
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
                Caption = 'Show Prompt';
                Image = Action;
                ToolTip = 'Show the prompt for the selected task or policy.';

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

    var
        Indent: Integer;
        Step: Text;

    trigger OnAfterGetRecord()
    var
        InstructionTaskPolicy: Record "SOA Instruction Task/Policy";
    begin
        if InstructionTaskPolicy.Get(Rec."Step Type", Rec."Step Name") then
            Step := StrSubstNo('%1: %2', InstructionTaskPolicy.Type, InstructionTaskPolicy.Name);

        Indent := Rec.Indentation;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Indent := 0;
        Step := '';
    end;

    local procedure LookUpPhaseStep()
    var
        InstructionTaskPolicy: Record "SOA Instruction Task/Policy";
    begin
        if Page.RunModal(0, InstructionTaskPolicy) = Action::LookupOK then begin
            Rec.Validate("Step Type", InstructionTaskPolicy.Type);
            Rec.Validate("Step Name", InstructionTaskPolicy.Name);
        end;
    end;
}