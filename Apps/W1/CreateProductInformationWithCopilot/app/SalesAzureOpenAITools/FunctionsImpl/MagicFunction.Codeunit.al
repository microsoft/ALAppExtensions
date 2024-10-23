// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

using System.AI;
using System.Telemetry;

codeunit 7341 "Magic Function" implements "AOAI Function"
{
    Access = Internal;

    var
        FunctionNameLbl: Label 'magic_function', Locked = true;
        MagicFunctionLbl: Label 'function_call: magic_function', Locked = true;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        CreateProductInfoPrompts: Codeunit "Create Product Info. Prompts";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(CreateProductInfoPrompts.GetMagicFunctionPrompt());
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure Execute(Arguments: JsonObject): Variant
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CreateProductInfoUtility: Codeunit "Create Product Info. Utility";
        NotificationManager: Codeunit "Notification Manager";
    begin
        FeatureTelemetry.LogUsage('0000N30', CreateProductInfoUtility.GetFeatureName(), MagicFunctionLbl);
        NotificationManager.SendNotification(CreateProductInfoUtility.GetChatCompletionResponseErr());
        exit(FunctionNameLbl);
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;
}