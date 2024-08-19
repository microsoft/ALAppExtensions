// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using System.Agents;

enumextension 4400 "SOA Agent Metadata Provider" extends "Agent Metadata Provider"
{
    value(4400; "SOA Agent")
    {
        Caption = 'Sales Order Taker';
        Implementation = IAgentFactory = "SOA Agent Metadata Provider", IAgentMetadata = "SOA Agent Metadata Provider";
    }
}