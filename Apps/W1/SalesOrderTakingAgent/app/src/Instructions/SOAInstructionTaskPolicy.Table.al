// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

table 4308 "SOA Instruction Task/Policy"
{
    DataClassification = CustomerContent;
    Caption = 'Sales Order Taking Agent Instruction Task/Policy';
    LookupPageId = "SOA Instruct. Tasks/Policies";
    ReplicateData = false;

    fields
    {
        field(1; Type; Enum "SOA Phase Step Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            ToolTip = 'Specifies if this is a task or a policy.';
        }
        field(2; Name; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
            ToolTip = 'Specifies the name of the task or policy.';
        }
        field(5; "Sorting Order No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sorting Order No.';
            ToolTip = 'Specifies the sorting order number of the task or policy.';
        }
        field(10; Enabled; Enum "SOA Yes/No Toggle State")
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
            ToolTip = 'Specifies if the task or policy is enabled.';
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
        key(PK; Type, Name)
        {
            Clustered = true;
        }
        key(Key2; "Sorting Order No.")
        {

        }
    }

    var
        EditingNotAllowedErr: Label 'You cannot edit this task or policy.';

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
        InstructionPhaseStep.SetRange("Step Type", Rec.Type);
        InstructionPhaseStep.SetRange("Step Name", Rec.Name);
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
        if Rec."Prompt Code" = '' then
            exit;

        InstructionPromptCard.SetRec(Rec."Prompt Code", InstructionMgt.GetPromptText(Rec), false);
        InstructionPromptCard.RunModal();
    end;
}