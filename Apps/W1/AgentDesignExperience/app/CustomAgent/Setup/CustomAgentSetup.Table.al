// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents.Designer;

table 4350 "Custom Agent Setup"
{
    DataClassification = SystemMetadata;
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    Caption = 'Custom Agent Setup';
    ReplicateData = false;
    DataPerCompany = false;

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            ToolTip = 'Specifies the user ID of the agent.';
        }
        field(2; Instructions; Blob)
        {
            ToolTip = 'Specifies the instructions of the agent.';
            Caption = 'Instructions';
        }
        field(3; "Initials"; Code[4])
        {
            Caption = 'Initials';
            ToolTip = 'Specifies the initials of the agent.';
            DataClassification = CustomerContent;
        }
        field(4; "Description"; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the agent.';
            DataClassification = CustomerContent;
        }
        field(5; "Instructions Version"; Text[100])
        {
            Caption = 'Instructions Version';
            ToolTip = 'Specifies the version of the instructions for the agent.';
            DataClassification = CustomerContent;
        }
        field(5000; "Instruction has Tasks"; Boolean)
        {
            Caption = 'Instruction has Tasks';
            ToolTip = 'Specifies whether the instructions are used in any agent tasks.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "User Security ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        AgentDesignerPermissions.VerifyCurrentUserCanCreateCustomAgents();
    end;

    trigger OnModify()
    begin
        AgentDesignerPermissions.VerifyCurrentUserCanConfigureCustomAgent(Rec."User Security ID");
    end;

    trigger OnDelete()
    begin
        AgentDesignerPermissions.VerifyCurrentUserCanDeleteCustomAgents();
    end;

    trigger OnRename()
    begin
        AgentDesignerPermissions.VerifyCurrentUserCanConfigureCustomAgent(Rec."User Security ID");
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    internal procedure GetInstructions(AgentUserSecurityID: Guid): Text
    var
        CustomAgentInstructions: Codeunit "Custom Agent Instructions";
    begin
        exit(CustomAgentInstructions.GetInstructions(AgentUserSecurityID));
    end;

    [Scope('OnPrem')]
    internal procedure TryGetInstructions(AgentUserSecurityID: Guid; var AgentInstructions: Text): Boolean
    var
        CustomAgentInstructions: Codeunit "Custom Agent Instructions";
    begin
        exit(CustomAgentInstructions.TryGetInstructions(AgentUserSecurityID, AgentInstructions));
    end;

    [Scope('OnPrem')]
    internal procedure SetInstructions(NewInstructions: Text)
    var
        CustomAgentInstructions: Codeunit "Custom Agent Instructions";
    begin
        CustomAgentInstructions.SetInstructions(Rec, NewInstructions, Rec."Instructions Version", false);
    end;

    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
}