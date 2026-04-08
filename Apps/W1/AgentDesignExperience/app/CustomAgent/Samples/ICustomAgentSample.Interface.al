// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

/// <summary>
/// Defines the contract for implementing a sample agent.
/// Implement this interface to provide sample agents that can be loaded into the <see cref="Custom Agents Wizard Setup"/> for demonstration or testing purposes.
/// </summary>
interface ICustomAgentSample
{
    // TODO(agent) change accessibility when opening up.
    Access = Internal;

    /// <summary>
    /// Gets the unique code that identifies this sample agent.
    /// </summary>
    /// <returns>A unique code for this agent.</returns>
    procedure GetAgentCode(): Code[10];

    /// <summary>
    /// Writes the sample agent definition XML to the provided stream.
    /// The XML must conform to the agent import format and include agent metadata, profile, access controls, and instructions.
    /// The XML must contain exactly one agent definition. If the XML contains multiple agent definitions, an error will be thrown during import.
    /// </summary>
    /// <param name="AgentOutStream">The stream to write the agent definition XML to.</param>
    procedure GetAgentDefinition(var AgentOutStream: OutStream);

    /// <summary>
    /// Gets the URL for documentation or learning resources about this agent.
    /// </summary>
    /// <returns>A URL pointing to agent documentation or an empty string if not available.</returns>
    procedure GetAgentLearnMoreUrl(): Text[2048];
}