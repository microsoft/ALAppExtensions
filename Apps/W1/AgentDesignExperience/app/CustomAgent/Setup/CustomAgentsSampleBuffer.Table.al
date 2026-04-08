// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

table 4351 "Custom Agents Sample Buffer"
{
    DataClassification = SystemMetadata;
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    TableType = Temporary;
    Caption = 'Custom Agents Buffer';
    ReplicateData = false;

    fields
    {
        field(1; "ID"; Integer)
        {
            Caption = 'ID';
            ToolTip = 'Specifies the ID.';
        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
            ToolTip = 'Specifies the code of the agent.';
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[30])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the agent.';
            DataClassification = CustomerContent;
        }
        field(4; "Description"; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the agent.';
            DataClassification = CustomerContent;
        }
        field(5; LearnMoreUrl; Text[2048])
        {
            Caption = 'Learn More Link';
            ToolTip = 'Specifies the link to learn more about the agent.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "ID")
        {
            Clustered = true;
        }
        key(Key2; Code)
        {
            Unique = true;
        }
    }
}