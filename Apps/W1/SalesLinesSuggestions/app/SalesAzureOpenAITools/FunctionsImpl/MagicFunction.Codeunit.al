// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System.AI;
using System.Telemetry;

#pragma warning disable AS0130
#pragma warning disable PTE0025
codeunit 7284 "Magic Function" implements "AOAI Function"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    Access = Internal;

    var
        FunctionNameLbl: Label 'magic_function', Locked = true;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        Prompt: Codeunit "SLS Prompts";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(Prompt.GetSLSMagicFunctionPrompt().Unwrap());
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure Execute(Arguments: JsonObject): Variant
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

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;
}