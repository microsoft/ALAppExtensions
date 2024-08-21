// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using System.Agents;
using System.Email;

table 4325 "SOA Setup"
{
    Access = Internal;
    Extensible = false;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Agent User Security ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Email Account ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Email Connector"; Enum "Email Connector")
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Incoming Monitoring"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Email Monitoring"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(7; Exists; Boolean)
        {
            Caption = 'Exists';
            FieldClass = FlowField;
            CalcFormula = exist(Agent where("User Security ID" = field("Agent User Security Id")));
        }
        field(8; State; Option)
        {
            InitValue = Disabled;
            Caption = 'State';
            OptionCaption = 'Enabled,Disabled';
            OptionMembers = Enabled,Disabled;
            FieldClass = FlowField;
            CalcFormula = lookup(Agent.State where("User Security ID" = field("Agent User Security Id")));
        }
        field(9; "Agent Scheduled Task ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(10; "Recovery Scheduled Task ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
        key(Key2; "Agent User Security ID")
        {
        }
    }
}