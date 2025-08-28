// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;

enumextension 4400 "SOA Metadata Provider" extends "Agent Metadata Provider"
{
    value(4400; "SO Agent")
    {
        Caption = 'Sales Order Agent';
        Implementation = IAgentFactory = "SOA Metadata Provider", IAgentMetadata = "SOA Metadata Provider", IAgentTaskExecution = "SOA Agent Task Execution";
    }
}