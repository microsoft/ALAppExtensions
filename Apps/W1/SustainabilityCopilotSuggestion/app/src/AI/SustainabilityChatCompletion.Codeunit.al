// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.AI;
using System.Telemetry;

codeunit 6331 "Sustainability Chat Completion"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Telemetry: Codeunit "Telemetry";
        GetAOAIFunctionResponseForFunctionLbl: Label 'Get AOAIFunctionResponse for the function %1', Comment = '%1 = function name', Locked = true;

    [NonDebuggable]

    internal procedure GenerateRawFormulaChatCompletion(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; UserMessage: Text)
    var
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        RawFormulaFunction: Codeunit "Raw Formula Function";
        Prompts: Codeunit "Sustainability Prompts";
        TelemetryCD: Dictionary of [Text, Text];
    begin
        Telemetry.LogMessage('0000PW1', 'Generating raw formula chat completion', Verbosity::Normal, DataClassification::SystemMetadata);
        GenerateChatCompletion(AOAIOperationResponse, TelemetryCD, RawFormulaFunction, UserMessage, Prompts.GetRawFormulaSystemPrompt());
        if not IsChatCompletionSuccessfull(AOAIOperationResponse) then
            exit;

        foreach AOAIFunctionResponse in AOAIOperationResponse.GetFunctionResponses() do begin
            Telemetry.LogMessage('0000PW2', StrSubstNo(GetAOAIFunctionResponseForFunctionLbl, AOAIFunctionResponse.GetFunctionName()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryCD);
            CopyAOAIFunctionResponseToRawFormulaTempSustainEmissionSuggestion(SustainEmissionSuggestion, AOAIFunctionResponse);
        end;
        Telemetry.LogMessage('0000PW5', 'Generating raw formula chat completion finished', Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    [NonDebuggable]
    internal procedure GenerateFormulaBreakdownChatCompletion(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; UserMessage: Text)
    var
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        FormulaBreakdownFunction: Codeunit "Formula Breakdown Function";
        Prompts: Codeunit "Sustainability Prompts";
        TelemetryCD: Dictionary of [Text, Text];
    begin
        Telemetry.LogMessage('0000PW6', 'Generating formula breakdown chat completion', Verbosity::Normal, DataClassification::SystemMetadata);
        GenerateChatCompletion(AOAIOperationResponse, TelemetryCD, FormulaBreakdownFunction, UserMessage, Prompts.GetFormulaBreakdownSystemPrompt());
        if not IsChatCompletionSuccessfull(AOAIOperationResponse) then
            exit;

        foreach AOAIFunctionResponse in AOAIOperationResponse.GetFunctionResponses() do begin
            Telemetry.LogMessage('0000PW7', StrSubstNo(GetAOAIFunctionResponseForFunctionLbl, AOAIFunctionResponse.GetFunctionName()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryCD);
            CopyAOAIFunctionResponseToTempSustainEmissionSuggestion(SustainEmissionSuggestion, AOAIFunctionResponse);
        end;

        Telemetry.LogMessage('0000PW8', 'Generating formula breakdown chat completion finished', Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    [NonDebuggable]
    internal procedure GenerateMatchCategoryToInputChatCompletion(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; UserMessage: Text)
    var
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        FindMatchFunction: Codeunit "Find Match Function";
        Prompts: Codeunit "Sustainability Prompts";
        TelemetryCD: Dictionary of [Text, Text];
    begin
        Telemetry.LogMessage('0000PW9', 'Generating match category to input chat completion', Verbosity::Normal, DataClassification::SystemMetadata);
        GenerateChatCompletion(AOAIOperationResponse, TelemetryCD, FindMatchFunction, UserMessage, Prompts.GetMatchCategoryToInputSystemPrompt());
        if not IsChatCompletionSuccessfull(AOAIOperationResponse) then
            exit;

        foreach AOAIFunctionResponse in AOAIOperationResponse.GetFunctionResponses() do begin
            Telemetry.LogMessage('0000PWA', StrSubstNo(GetAOAIFunctionResponseForFunctionLbl, AOAIFunctionResponse.GetFunctionName()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryCD);
            CopyAOAIFunctionResponseToFormulaBreakdownTempSourceCO2EmissionBuffer(SourceCO2EmissionBuffer, AOAIFunctionResponse);
        end;
        Telemetry.LogMessage('0000PWB', 'Generating match category to input chat completion finished', Verbosity::Normal, DataClassification::SystemMetadata);
    end;

    [NonDebuggable]
    local procedure GenerateChatCompletion(var AOAIOperationResponse: Codeunit "AOAI Operation Response"; var TelemetryCD: Dictionary of [Text, Text]; Function: Interface "AOAI Function"; UserMessage: Text; Prompt: SecretText)
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        StartDateTime: DateTime;
        DurationAsBigInt: BigInteger;
    begin
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT41Latest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Sustainability Emission Suggestion");
        AOAIChatCompletionParams.SetMaxTokens(MaxTokens());
        AOAIChatCompletionParams.SetTemperature(0);
        AOAIChatMessages.AddTool(Function);
        AOAIChatMessages.SetToolChoice('auto');
        AOAIChatMessages.SetPrimarySystemMessage(Prompt);
        AOAIChatMessages.AddUserMessage(UserMessage);

        StartDateTime := CurrentDateTime();
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        DurationAsBigInt := CurrentDateTime() - StartDateTime;
        TelemetryCD.Add('Response time', Format(DurationAsBigInt));
    end;

    [NonDebuggable]
    local procedure IsChatCompletionSuccessfull(var AOAIOperationResponse: Codeunit "AOAI Operation Response"): Boolean
    begin
        if not AOAIOperationResponse.IsSuccess() then begin
            Telemetry.LogMessage('0000PWC', 'Chat completion is not successfull', Verbosity::Error, DataClassification::SystemMetadata);
            exit(false);
        end;
        if not AOAIOperationResponse.IsFunctionCall() then begin
            Telemetry.LogMessage('0000PWD', 'Chat completion is not a function call', Verbosity::Error, DataClassification::SystemMetadata);
            exit(false);
        end;
        exit(true);
    end;

    local procedure CopyAOAIFunctionResponseToRawFormulaTempSustainEmissionSuggestion(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var AOAIFunctionResponse: Codeunit "AOAI Function Response")
    var
        TempSustainEmissionSuggestion: Record "Sustain. Emission Suggestion" temporary;
        NoLineFoundForRawFormulaLbl: Label 'Line with number %1 found for raw formula', Comment = '%1 = line number', Locked = true;
    begin
        if not GetTempSustainEmissionSuggestionFromAOAIFunctionResponse(TempSustainEmissionSuggestion, AOAIFunctionResponse) then begin
            Telemetry.LogMessage('0000Q0M', 'GetTempSustainEmissionSuggestionFromAOAIFunctionResponse fails', Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;
        TempSustainEmissionSuggestion.Reset();
        if not TempSustainEmissionSuggestion.FindSet() then begin
            Telemetry.LogMessage('0000PW3', 'No TempSustainEmissionSuggestion record found from AOAIFunctionResponse.GetResult', Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;
        repeat
            SustainEmissionSuggestion.SetRange("Line No.", TempSustainEmissionSuggestion."Line No.");
            if SustainEmissionSuggestion.FindFirst() then begin
                SustainEmissionSuggestion."Raw Formula" := TempSustainEmissionSuggestion."Raw Formula";
                SustainEmissionSuggestion.Modify();
            end else
                Telemetry.LogMessage('0000PW4', StrSubstNo(NoLineFoundForRawFormulaLbl, TempSustainEmissionSuggestion."Line No."), Verbosity::Error, DataClassification::SystemMetadata);
        until TempSustainEmissionSuggestion.Next() = 0;
    end;

    local procedure CopyAOAIFunctionResponseToTempSustainEmissionSuggestion(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var AOAIFunctionResponse: Codeunit "AOAI Function Response")
    var
        TempSustainEmissionSuggestion: Record "Sustain. Emission Suggestion" temporary;
    begin
        if not GetTempSustainEmissionSuggestionFromAOAIFunctionResponse(TempSustainEmissionSuggestion, AOAIFunctionResponse) then begin
            Telemetry.LogMessage('0000Q0N', 'GetTempSustainEmissionSuggestionFromAOAIFunctionResponse fails', Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;
        TempSustainEmissionSuggestion.Reset();
        TempSustainEmissionSuggestion.SetAutoCalcFields("Emission Formula Json");
        if not TempSustainEmissionSuggestion.FindSet() then begin
            Telemetry.LogMessage('0000Q0O', 'No TempSustainEmissionSuggestion record found from AOAIFunctionResponse.GetResult', Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;
        repeat
            SustainEmissionSuggestion.SetRange("Line No.", TempSustainEmissionSuggestion."Line No.");
            if SustainEmissionSuggestion.FindFirst() then begin
                SustainEmissionSuggestion."Emission Formula Json" := TempSustainEmissionSuggestion."Emission Formula Json";
                SustainEmissionSuggestion.Modify();
            end;
        until TempSustainEmissionSuggestion.Next() = 0;
    end;

    local procedure CopyAOAIFunctionResponseToFormulaBreakdownTempSourceCO2EmissionBuffer(var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; var AOAIFunctionResponse: Codeunit "AOAI Function Response")
    var
        TempSourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer" temporary;
    begin
        if not GetTempSourceCO2EmissionBufferFromAOAIFunctionResponse(TempSourceCO2EmissionBuffer, AOAIFunctionResponse) then begin
            Telemetry.LogMessage('0000Q0P', 'GetTempSourceCO2EmissionBufferFromAOAIFunctionResponse fails', Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;
        TempSourceCO2EmissionBuffer.Copy(AOAIFunctionResponse.GetResult(), true);
        TempSourceCO2EmissionBuffer.Reset();
        if not TempSourceCO2EmissionBuffer.FindSet() then begin
            Telemetry.LogMessage('0000Q0Q', 'No TempSourceCO2EmissionBuffer record found from AOAIFunctionResponse.GetResult', Verbosity::Error, DataClassification::SystemMetadata);
            exit;
        end;
        repeat
            SourceCO2EmissionBuffer := TempSourceCO2EmissionBuffer;
            SourceCO2EmissionBuffer.Insert();
        until TempSourceCO2EmissionBuffer.Next() = 0;
    end;

    [TryFunction]
    local procedure GetTempSustainEmissionSuggestionFromAOAIFunctionResponse(var TempSustainEmissionSuggestion: Record "Sustain. Emission Suggestion" temporary; var AOAIFunctionResponse: Codeunit "AOAI Function Response")
    begin
        TempSustainEmissionSuggestion.Copy(AOAIFunctionResponse.GetResult(), true);
    end;

    [TryFunction]
    local procedure GetTempSourceCO2EmissionBufferFromAOAIFunctionResponse(var TempSourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer" temporary; var AOAIFunctionResponse: Codeunit "AOAI Function Response")
    begin
        TempSourceCO2EmissionBuffer.Copy(AOAIFunctionResponse.GetResult(), true);
    end;

    local procedure MaxTokens(): Integer
    begin
        exit(4096);
    end;
}