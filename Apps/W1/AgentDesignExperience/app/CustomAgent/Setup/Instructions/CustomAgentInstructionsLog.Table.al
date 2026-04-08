// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

table 4352 "Custom Agent Instructions Log"
{
    Caption = 'Custom Agent Instructions Log';
    DataClassification = SystemMetadata;
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    AllowInCustomizations = Never;
    ReplicateData = false;
    DataPerCompany = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the unique entry number for this log entry.';
            AutoIncrement = true;
        }
        field(2; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            ToolTip = 'Specifies the user ID of the agent.';
        }
        field(3; Instructions; Blob)
        {
            Caption = 'Instructions';
            ToolTip = 'Specifies the instructions for the agent.';
        }
        field(4; "Instruction Version"; Text[100])
        {
            Caption = 'Version';
            ToolTip = 'Specifies the version description of the instructions.';
        }
        field(5000; "Current Instructions"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Current Instructions';
            ToolTip = 'Specifies whether these instructions are the current instructions for the agent.';
            CalcFormula = exist("Custom Agent Setup" where("User Security ID" = field("User Security ID"), "Instructions Version" = field("Instruction Version")));
        }
        field(5001; "Read-Only Instructions"; Boolean)
        {
            Caption = 'Read-only Instructions';
            ToolTip = 'Specifies whether the instructions are read-only.';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "User Security ID", "Instruction Version")
        {
            Unique = true;
        }
    }

    procedure GetInstructions(): Text
    var
        CustomAgentInstructions: Codeunit "Custom Agent Instructions";
        InstructionsBuilder: TextBuilder;
        InstructionsInstream: InStream;
        InstructionsLine: Text;
    begin
        Rec.CalcFields(Instructions);
        Instructions.CreateInStream(InstructionsInstream, CustomAgentInstructions.GetDefaultEncoding());
        while not InstructionsInstream.EOS() do begin
            InstructionsInstream.ReadText(InstructionsLine);
            InstructionsBuilder.AppendLine(InstructionsLine);
        end;
        exit(InstructionsBuilder.ToText().Trim());
    end;

    procedure SetInstructions(NewInstructions: Text)
    var
        CustomAgentInstructions: Codeunit "Custom Agent Instructions";
        InstructionsOutstream: OutStream;
    begin
        TestField("Read-Only Instructions", false);
        Clear(Rec.Instructions);
        Rec.Instructions.CreateOutStream(InstructionsOutstream, CustomAgentInstructions.GetDefaultEncoding());
        InstructionsOutstream.WriteText(NewInstructions.Trim());
    end;
}
