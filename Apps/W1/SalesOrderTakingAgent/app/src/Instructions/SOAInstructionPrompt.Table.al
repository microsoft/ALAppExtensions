// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

table 4309 "SOA Instruction Prompt"
{
    DataClassification = CustomerContent;
    Caption = 'Sales Order Taking Agent Instruction Prompt';
    LookupPageId = "SOA Instruction Prompt List";
    ReplicateData = false;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            NotBlank = true;
            ToolTip = 'Specifies the code of the prompt.';
        }
        field(2; Prompt; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Prompt';
            ToolTip = 'Specifies the prompt.';
        }
        field(10; Enabled; Enum "SOA Yes/No Toggle State")
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
            ToolTip = 'Specifies if the prompt is enabled.';
            InitValue = Yes;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    var
        EditingNotAllowedErr: Label 'You cannot edit this prompt.';

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
        InstructionMgt: Codeunit "SOA Instructions Mgt.";
        InstructionPromptCard: Page "SOA Instruction Prompt Card";
    begin
        InstructionPromptCard.SetRec(Rec.Code, InstructionMgt.GetPromptText(Rec), false);
        InstructionPromptCard.RunModal();
    end;
}