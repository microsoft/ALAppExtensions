// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.AI;

table 4586 "SOA Billing Log"
{
    DataClassification = SystemMetadata;
    Access = Internal;
    InherentEntitlements = rimX;
    InherentPermissions = rimX;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            ToolTip = 'Specifies the unique identifier for the log entry';
        }
        field(2; Operation; Enum "SOA Billing Operation")
        {
            Caption = 'Operation';
            ToolTip = 'Specifies the type of operation that was performed';
        }
        field(3; "Agent Task ID"; BigInteger)
        {
            Caption = 'Agent Task ID';
            ToolTip = 'Specifies the unique identifier for the agent task';
        }
        field(4; "Agent Message ID"; Guid)
        {
            Caption = 'Agent Message ID';
            ToolTip = 'Specifies the unique identifier for the agent message';
        }
        field(10; "Record System ID"; Guid)
        {
            Caption = 'Record System ID';
            ToolTip = 'Specifies the unique identifier for the record connected to the operation.';
        }
        field(11; "Record Table"; Integer)
        {
            Caption = 'Record Table';
            ToolTip = 'Specifies the table number for the record connected to the operation.';
        }
        field(30; Details; Blob)
        {
            Caption = 'Details';
            ToolTip = 'Specifies additional details about the operation';
        }
#pragma warning disable AS0125
#pragma warning disable AS0005
        field(31; "Copilot Quota Usage Type"; Enum "Copilot Quota Usage Type")
        {
            Caption = 'Cost Type';
            ToolTip = 'Specifies the type of cost associated with the operation';
        }
#pragma warning restore AS0125
#pragma warning restore AS0005
        field(50; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            ToolTip = 'Specifies the name of the company where the operation was performed';
        }
        field(51; Charged; Boolean)
        {
            Caption = 'Charged';
            ToolTip = 'Specifies if the operation has been charged';
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
        key(Key2; Charged)
        {
        }
    }
}