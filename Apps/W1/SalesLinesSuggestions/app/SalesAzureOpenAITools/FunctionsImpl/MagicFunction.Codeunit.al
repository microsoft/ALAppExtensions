// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System.Telemetry;

codeunit 7284 "Magic Function" implements SalesAzureOpenAITools
{
    Access = Internal;

    [NonDebuggable]
    procedure GetToolPrompt(): JsonObject
    var
        Prompt: Codeunit "SLS Prompts";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(Prompt.GetSLSMagicFunctionPrompt());
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure ToolCall(Arguments: JsonObject; CustomDimension: Dictionary of [Text, Text]): Variant
    var
        TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        NotificationManager: Codeunit "Notification Manager";
    begin
        FeatureTelemetry.LogUsage('0000ME3', SalesLineAISuggestionImpl.GetFeatureName(), 'function_call: magic_function');
        NotificationManager.SendNotification(SalesLineAISuggestionImpl.GetNoSalesLinesSuggestionsMsg());
        exit(TempSalesLineAiSuggestion);
    end;

}