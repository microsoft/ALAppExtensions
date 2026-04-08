// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;

table 4353 "Agent Import Buffer"
{
    Caption = 'Agent Import Buffer';
    Access = Internal;
    TableType = Temporary;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            ToolTip = 'Specifies the entry number for the import buffer record.';
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the agent to be imported.';
        }
        field(3; "Display Name"; Text[80])
        {
            Caption = 'Display Name';
            ToolTip = 'Specifies the display name of the agent to be imported.';
        }
        field(4; Initials; Text[4])
        {
            Caption = 'Initials';
            ToolTip = 'Specifies the initials of the agent to be imported.';
        }
        field(5; Instructions; Blob)
        {
            Caption = 'Instructions';
            ToolTip = 'Specifies the instructions that will be assigned to the agent.';
        }
        field(6; Selected; Boolean)
        {
            Caption = 'Import this agent';
            InitValue = true;
            ToolTip = 'Specifies whether this agent should be imported.';
            DataClassification = SystemMetadata;
        }
        field(7; Exists; Boolean)
        {
            Caption = 'Exists';
            FieldClass = FlowField;
            CalcFormula = exist(Agent where("User Name" = field(Name)));
            ToolTip = 'Specifies whether this agent exists in the system.';
        }
        field(8; Action; Enum "Agent Import Action")
        {
            Caption = 'Action';
            InitValue = Add;
            ToolTip = 'Specifies the action to take for this agent.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                CalcFields(Exists);
                if (Action = Action::Replace) and not Exists then
                    Error(CannotReplaceNonExistingAgentErr, Name);
            end;
        }
        field(9; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the agent to be imported';
        }
        field(10; "User Security ID After Import"; Guid)
        {
            Caption = 'User Security ID After Import';
            ToolTip = 'Specifies the agent user security for the agent after import.';
        }
        field(11; "State After Import"; Option)
        {
            Caption = 'State After Import';
            OptionCaption = 'Active,Inactive';
            OptionMembers = Enabled,Disabled;
            ToolTip = 'Specifies the state of the user that is associated with the agent after import.';
            DataClassification = SystemMetadata;
        }
        field(12; "Profile ID"; Code[30])
        {
            Caption = 'Profile ID';
            ToolTip = 'Specifies the profile ID assigned to the agent.';
            DataClassification = SystemMetadata;
        }
        field(13; "Profile App ID"; Guid)
        {
            Caption = 'Profile App ID';
            ToolTip = 'Specifies the app ID of the profile assigned to the agent.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure SetInstructions(InstructionsText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Instructions);
        Instructions.CreateOutStream(OutStream, CustomAgentExport.GetEncoding());
        OutStream.WriteText(InstructionsText);
    end;

    procedure GetInstructions(): Text
    var
        InstructionsBuilder: TextBuilder;
        InStream: InStream;
        InstructionsLine: Text;
    begin
        Rec.CalcFields(Instructions);
        Instructions.CreateInStream(InStream, CustomAgentExport.GetEncoding());
        while not InStream.EOS do begin
            InStream.ReadText(InstructionsLine);
            InstructionsBuilder.AppendLine(InstructionsLine);
        end;
        exit(InstructionsBuilder.ToText().Trim());
    end;

    var
        CustomAgentExport: Codeunit "Custom Agent Export";
        CannotReplaceNonExistingAgentErr: Label 'Cannot replace agent %1 because it does not exist in the system. Only Add action is allowed for new agents.', Comment = '%1 - the agent name';
}