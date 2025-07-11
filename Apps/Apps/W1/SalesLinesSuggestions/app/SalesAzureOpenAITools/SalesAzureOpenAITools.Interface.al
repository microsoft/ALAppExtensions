// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

interface SalesAzureOpenAITools
{
    Access = Internal;

    /// <summary>
    /// Get the prompt for the Tool. Tool prompt object describes the Tool and the should contain the following fields:
    ///     - Type: The name of the Tool, currently only function type is supported. For functions following fields are allowed:
    ///     -- Name: The name of the Tool. (Required)
    ///     -- Description: The description of the Tool. (Optional)
    ///     -- Parameters: The parameters of the Tool. (Required)
    /// More details can be found here: https://go.microsoft.com/fwlink/?linkid=2254538
    /// </summary>
    procedure GetToolPrompt(): JsonObject;

    /// <summary>
    /// This function is invoked as a response from Azure Open AI.
    ///  -Arguments: The expected parameters of the Tool defined.
    ///  -CustomDimension: This can be used to pass any context information to the function.
    /// The function returns a variant, and it's up to the implementation to decide what to return.
    /// </summary>
    procedure ToolCall(Arguments: JsonObject; CustomDimension: Dictionary of [Text, Text]): Variant;
}