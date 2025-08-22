// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.AI;

using System.AI;

/// <summary>
/// Interface for E-Document AI system implementations that provide AI-powered processing capabilities.
/// This interface defines the contract for different AI systems used in E-Document processing scenarios,
/// such as PDF classification, deferral line matching, and GL account matching.
/// Implementations are registered in the "E-Doc. AI System" enum and used by the E-Document AI Processor.
/// </summary>
interface IEDocAISystem
{
    Access = Public;

    /// <summary>
    /// Gets the system prompt used to configure the AI model for this specific processing scenario.
    /// The system prompt provides context and instructions to the AI model about its role and expected behavior.
    /// </summary>
    /// <returns>The system prompt as SecretText, typically retrieved from Azure Key Vault or resource files.</returns>
    procedure GetSystemPrompt(): SecretText

    /// <summary>
    /// Gets the list of AOAI Function tools that define what functions the AI model can call during processing.
    /// These tools enable the AI to perform specific actions like matching GL accounts, classifying documents, or processing deferrals.
    /// </summary>
    /// <returns>A list of AOAI Function interfaces that the AI can use to perform specific tasks.</returns>
    procedure GetTools(): List of [Interface "AOAI Function"];

    /// <summary>
    /// Gets the feature name used for telemetry tracking and logging purposes.
    /// This name is used to track feature usage, success rates, and error reporting in telemetry.
    /// </summary>
    /// <returns>A descriptive name for the AI feature being implemented.</returns>
    procedure GetFeatureName(): Text

}