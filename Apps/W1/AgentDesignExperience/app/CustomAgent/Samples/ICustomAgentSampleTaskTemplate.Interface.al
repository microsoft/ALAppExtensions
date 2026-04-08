// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

/// <summary>
/// Defines the optional contract for providing task templates associated with a sample agent.
/// </summary>
interface ICustomAgentSampleTaskTemplate
{
    // TODO(agent) change accessibility when opening up.
    Access = Internal;

    /// <summary>
    /// Gets the code that identifies the task template associated with this agent.
    /// </summary>
    /// <returns>A unique code for the agent's task template.</returns>
    procedure GetTaskTemplateCode(): Code[20];

    /// <summary>
    /// Writes the task template definition JSON to the provided stream.
    /// The JSON defines sample tasks that demonstrate the agent's capabilities.
    /// </summary>
    /// <param name="TaskTemplateOutStream">The stream to write the task template JSON to.</param>
    procedure GetTaskTemplateDefinition(var TaskTemplateOutStream: OutStream);

    /// <summary>
    /// Gets a map of placeholder tokens and their replacement values for the task template.
    /// Use placeholders to support localization of template names and descriptions.
    /// </summary>
    /// <returns>A dictionary where keys are placeholder tokens and values are the localized text.</returns>
    procedure GetTaskTemplatePlaceholdersMap(): Dictionary of [Text, Text];
}
