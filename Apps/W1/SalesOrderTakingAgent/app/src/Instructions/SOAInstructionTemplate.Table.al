// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

table 4305 "SOA Instruction Template"
{
    DataClassification = CustomerContent;
    Caption = 'Sales Order Taking Agent Instruction Template';
    LookupPageId = "SOA Instruction Templates";
    ReplicateData = false;

    fields
    {
        field(1; Name; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
            NotBlank = true;
            ToolTip = 'Specifies the name of the instruction template.';
        }
        field(2; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
            ToolTip = 'Specifies the description of the instruction template.';
        }
        field(10; Enabled; Enum "SOA Yes/No Toggle State")
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
            ToolTip = 'Specifies if the instruction template is enabled.';
            InitValue = Yes;

            trigger OnValidate()
            var
                InstructionTemplate: Record "SOA Instruction Template";
            begin
                InstructionTemplate.SetFilter(Name, '<>%1', Name);
                InstructionTemplate.SetFilter(Enabled, '%1|%2', InstructionTemplate.Enabled::Yes, InstructionTemplate.Enabled::"Yes (Read-only)");
                if not InstructionTemplate.IsEmpty() then
                    Error(OnlyOneEnabledErr);
            end;
        }
        field(20; "Prompt Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Prompt Code';
            ToolTip = 'Specifies the code of the prompt.';
            TableRelation = "SOA Instruction Prompt".Code;
        }
        field(21; "Meta Prompt Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Meta Prompt Code';
            ToolTip = 'Specifies the code of the meta prompt.';
            TableRelation = "SOA Instruction Prompt".Code;
        }
    }

    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }

    var
        EditingNotAllowedErr: Label 'You cannot edit this instruction template.';
        OnlyOneEnabledErr: Label 'Only one instruction template can be enabled.';

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
        InstructionPhase: Record "SOA Instruction Phase";
    begin
        InstructionPhase.SetRange("Template Name", Rec.Name);
        InstructionPhase.DeleteAll(true);
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

    procedure ShowMetaPrompt()
    var
        InstructionMgt: Codeunit "SOA Instructions Mgt.";
        InstructionPromptCard: Page "SOA Instruction Prompt Card";
    begin
        InstructionPromptCard.SetRec(Rec."Meta Prompt Code", InstructionMgt.GetMetaPromptText(Rec), true);
        InstructionPromptCard.RunModal();
    end;
}