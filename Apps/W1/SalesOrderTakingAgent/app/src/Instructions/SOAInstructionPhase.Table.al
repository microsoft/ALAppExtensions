// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

table 4306 "SOA Instruction Phase"
{
    DataClassification = CustomerContent;
    Caption = 'Sales Order Taking Agent Instruction Phase';
    ReplicateData = false;
    
    fields
    {
        field(1; "Template Name"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Template Name';
            NotBlank = true;
            ToolTip = 'Specifies the name of the instruction template.';
            TableRelation = "SOA Instruction Template".Name;
        }
        field(2; "Phase Order No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Phase Order No.';
            NotBlank = true;
            ToolTip = 'Specifies the order number of the instruction phase.';
        }
        field(3; Phase; Enum "SOA Phases")
        {
            DataClassification = CustomerContent;
            Caption = 'Phase';
            ToolTip = 'Specifies the phase of the instruction.';
        }
        field(4; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
            ToolTip = 'Specifies the description of the instruction phase.';
        }
        field(10; Enabled; Enum "SOA Yes/No Toggle State")
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
            ToolTip = 'Specifies if the instruction phase is enabled.';
            InitValue = Yes;
        }
        field(20; "Prompt Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Prompt Code';
            ToolTip = 'Specifies the code of the prompt.';
            TableRelation = "SOA Instruction Prompt".Code;
        }
    }

    keys
    {
        key(PK; "Template Name", "Phase Order No.")
        {
            Clustered = true;
        }
    }

    var
        EditingNotAllowedErr: Label 'You cannot edit this instruction phase.';

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin
        if not CanEdit() then
            Error(EditingNotAllowedErr);
    end;

    trigger OnDelete()
    var
        InstructionPhaseStep: Record "SOA Instruction Phase Step";
    begin
        InstructionPhaseStep.SetRange(Phase, Rec.Phase);
        InstructionPhaseStep.DeleteAll(true);
    end;

    local procedure CanEdit(): Boolean
    begin
        exit(Rec.Enabled <> Rec.Enabled::"Yes (Read-only)");
    end;

    procedure ShowPrompt()
    var
        InstructionMgt: Codeunit "SOA Instructions Mgt.";
        InstructionPromptCard: Page "SOA Instruction Prompt Card";
    begin
        InstructionPromptCard.SetRec(Rec."Prompt Code", InstructionMgt.GetPromptText(Rec), true);
        InstructionPromptCard.RunModal();
    end;
}