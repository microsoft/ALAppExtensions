// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Email;
using System.Agents;

table 4585 "SOA Email"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;

    fields
    {
        field(1; "Email Inbox ID"; BigInteger)
        {
            TableRelation = "Email Inbox".Id;
        }
        field(2; Processed; Boolean)
        {
        }
        field(9; "Sender Name"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Sender Address"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "Received DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Sent DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(100; "Task ID"; BigInteger)
        {
            TableRelation = "Agent Task".ID;
        }
        field(101; "Task Message ID"; Guid)
        {
        }
        field(102; "Attachment Transferred"; Boolean)
        {
        }
        field(120; "Agent Task Message Exist"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Agent Task Message" where(ID = field("Task Message ID"), "Task ID" = field("Task ID")));
        }
    }

    keys
    {
        key(Key1; "Email Inbox ID")
        {
            Clustered = true;
        }
    }

    internal procedure SetAgentMessageFields(var AgentTaskMessage: Record "Agent Task Message")
    begin
        Rec."Task ID" := AgentTaskMessage."Task ID";
        Rec."Task Message ID" := AgentTaskMessage.ID;
    end;
}