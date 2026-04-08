// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;

enumextension 4351 "Custom Agent Metadata Provider" extends "Agent Metadata Provider"
{
    value(4377; "Custom Agent")
    {
        Caption = 'Agent';
        Implementation = IAgentFactory = "Custom Agent Metadata Provider", IAgentMetadata = "Custom Agent Metadata Provider";
    }
}