// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

table 4307 "SOA Instruction Phase Step"
{
    DataClassification = CustomerContent;
    Caption = 'Sales Order Taking Agent Instruction Task/Policy';
    LookupPageId = "SOA Instruction Phase Steps";
    ReplicateData = false;

    fields
    {
        field(1; Phase; Enum "SOA Phases")
        {
            DataClassification = CustomerContent;
            Caption = 'Phase';
            ToolTip = 'Specifies the phase of the instruction.';
        }
        field(2; "Step No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Step No.';
            ToolTip = 'Specifies the step number of the task or policy in the phase.';
        }
        field(3; "Step Type"; Enum "SOA Phase Step Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Step Type';
            ToolTip = 'Specifies if the step is a task or a policy.';
        }
        field(4; "Step Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Step Name';
            ToolTip = 'Specifies the name of the task or policy.';
            TableRelation = "SOA Instruction Task/Policy".Name where(Type = field("Step Type"));
        }
        field(9; Indentation; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Indentation';
            ToolTip = 'Specifies the indentation level of the task or policy.';
        }
        field(10; Enabled; Enum "SOA Yes/No Toggle State")
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
            ToolTip = 'Specifies if the instruction phase is enabled.';
            InitValue = Yes;
        }
    }

    keys
    {
        key(PK; Phase, "Step No.")
        {
            Clustered = true;
        }
    }

    var
        EditingNotAllowedErr: Label 'You cannot edit this phase step.';

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin
        if not CanEdit() then
            Error(EditingNotAllowedErr);
    end;

    trigger OnDelete()
    begin

    end;

    local procedure CanEdit(): Boolean
    begin
        exit(Rec.Enabled <> Rec.Enabled::"Yes (Read-only)");
    end;

    procedure ShowPrompt()
    var
        InstructionTaskPolicy: Record "SOA Instruction Task/Policy";
    begin
        InstructionTaskPolicy.Get(Rec."Step Type", Rec."Step Name");
        InstructionTaskPolicy.ShowPrompt();
    end;
}