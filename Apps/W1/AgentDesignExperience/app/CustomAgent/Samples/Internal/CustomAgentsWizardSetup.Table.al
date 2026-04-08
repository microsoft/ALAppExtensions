// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

/// <summary>
/// Tracks agents that were created from sample agent templates.
/// </summary>
table 4359 "Custom Agents Wizard Setup"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    Caption = 'Custom Agents Wizard Setup';
    ReplicateData = false;
    DataPerCompany = false;

    fields
    {
        field(1; "Agent User Security ID"; Guid)
        {
            Caption = 'Agent User Security ID';
            ToolTip = 'Specifies the user security ID of the agent that was created from a sample.';
        }
        field(2; "Sample Agent Code"; Code[10])
        {
            Caption = 'Sample Agent Code';
            ToolTip = 'Specifies the code of the sample agent that was used to create this agent.';
        }
        field(3; "Task Template Code"; Code[20])
        {
            Caption = 'Task Template Code';
            ToolTip = 'Specifies the code of the task template associated with the sample agent.';
        }
    }

    keys
    {
        key(Key1; "Agent User Security ID")
        {
            Clustered = true;
        }
        key(Key2; "Sample Agent Code")
        {
        }
    }
}
