// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;

/// <summary>
/// A temporary table containing info about the custom agents.
/// </summary>
table 4355 "Custom Agent Info"
{
    TableType = Temporary;
    Extensible = false;
    InherentPermissions = RIMDX;
    InherentEntitlements = RIMDX;
    Caption = 'Custom Agent Information';

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'User Security ID';
            ToolTip = 'Specifies the user ID of the agent.';
        }

        field(2; "User Name"; Code[50])
        {
            DataClassification = SystemMetadata;
            Caption = 'User Name';
            ToolTip = 'Specifies the user name of the agent.';
        }

        field(3; State; Option)
        {
            FieldClass = FlowField;
            Caption = 'State';
            OptionMembers = Enabled,Disabled;
            OptionCaption = 'Active,Inactive';
            ToolTip = 'Specifies the state of the agent.';
            CalcFormula = lookup(Agent.State where("User Security ID" = field("User Security ID")));
        }
    }

    keys
    {
        key(PK; "User Security ID")
        {
            Clustered = true;
        }
    }
}