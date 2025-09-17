// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.AI;

using System.AI;
using System.Telemetry;

/// <summary>
/// Codeunit for processing E-Document AI tasks.
/// </summary>
codeunit 6195 "E-Doc. AI Tool Processor"
{

    Access = Public;
    InherentPermissions = X;
    InherentEntitlements = X;

    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AISystem: Interface IEDocAISystem;
        TelemetryDimensions: Dictionary of [Text, Text];


    /// <summary>
    /// Initializes the AI system for E-Document processing.
    /// This method sets up the Azure OpenAI parameters, system chat messages, and telemetry dimensions.
    /// </summary>
    /// <param name="EDocAISystem">The E-Document AI System to be configured.</param>
    /// <returns>True if setup was successful, false otherwise.</returns>
    procedure Setup(EDocAISystem: Interface IEDocAISystem): Boolean
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        Clear(TelemetryDimensions);

        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"E-Document Matching Assistance") then
            exit(false);
        if not CopilotCapability.IsCapabilityActive(Enum::"Copilot Capability"::"E-Document Matching Assistance") then
            exit(false);

        // Setup Azure OpenAI
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", GetDefaultModel());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"E-Document Matching Assistance");

        // Setup parameters
        AOAIChatCompletionParams.SetMaxTokens(GetDefaultMaxOutputTokens());
        AOAIChatCompletionParams.SetTemperature(GetDefaultTemperature());

        // Setup AI system and messages
        AISystem := EDocAISystem;
        SetupChatMessages();

        // Setup telemetry
        TelemetryDimensions.Add('Model', GetDefaultModel());
        TelemetryDimensions.Add('MaxTokens', Format(GetDefaultMaxOutputTokens()));
        TelemetryDimensions.Add('Temperature', Format(GetDefaultTemperature()));

        LogFeatureUptake();
        exit(true);
    end;

    /// <summary>
    /// Processes the input text using the configured AI system and returns the response.
    /// </summary>
    /// <param name="Input">User input text to be processed by the AI system.</param>
    /// <param name="AOAIResponse">AOAI Operation Response containing the result of the AI processing.</param>
    /// <returns>True if processing was successful, false otherwise.</returns>
    procedure Process(Input: Text; var AOAIResponse: Codeunit "AOAI Operation Response"): Boolean
    var
        AOAIToken: Codeunit "AOAI Token";
        StartTime: DateTime;
        Success: Boolean;
        EstimateTokenCount: Integer;
        EmptyInputErr: Label 'Input cannot be empty';
        TokenLimitExceededTok: Label 'Token limit exceeded. Input of %1 tokens exceeds maximum token limit of %2 tokens', Comment = '%1 = Current token count, %2 = Maximum token limit', Locked = true;
        TokenLimitEventTok: Label 'Token Limit Exceeded', Locked = true;
    begin
        if Input = '' then
            Error(EmptyInputErr);

        // Add user message
        AOAIChatMessages.AddUserMessage(Input);
        EstimateTokenCount := AOAIToken.GetGPT4TokenCount(Input);
        TelemetryDimensions.Add('Token Count', Format(EstimateTokenCount));
        if EstimateTokenCount > GetDefaultMaxInputTokens() then begin
            LogError(TokenLimitEventTok, StrSubstNo(TokenLimitExceededTok, EstimateTokenCount, GetDefaultMaxInputTokens()));
            exit(false);
        end;

        // Process with timing
        StartTime := CurrentDateTime();
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIResponse);
        TelemetryDimensions.Add('ProcessingTime', Format(CurrentDateTime() - StartTime));

        // Handle response
        Success := HandleResponse(AOAIResponse);

        LogResult(Success);
        exit(Success);
    end;

    [NonDebuggable]
    local procedure SetupChatMessages()
    var
        Tool: Interface "AOAI Function";
    begin
        // Set system prompt
        AOAIChatMessages.SetPrimarySystemMessage(AISystem.GetSystemPrompt());

        // Add tools
        foreach Tool in AISystem.GetTools() do
            AOAIChatMessages.AddTool(Tool);

        AOAIChatMessages.SetToolChoice('auto');
    end;

    local procedure HandleResponse(var AOAIResponse: Codeunit "AOAI Operation Response"): Boolean
    var
        APIErrorTok: Label 'Status: %1, Error: %2', Comment = '%1 = Status code, %2 = Error message', Locked = true;
        EmptyResponseTok: Label 'API Empty response', Locked = true;
        APIErrorEventTok: Label 'API Error', Locked = true;
    begin
        if not AOAIResponse.IsSuccess() then begin
            LogError(APIErrorEventTok, StrSubstNo(APIErrorTok, AOAIResponse.GetStatusCode(), AOAIResponse.GetError()));
            exit(false);
        end;

        if AOAIResponse.GetResult() = '' then begin
            LogError(EmptyResponseTok, 'AI returned empty result');
            exit(false);
        end;

        if AOAIResponse.IsFunctionCall() then
            exit(HandleFunctionCalls(AOAIResponse));

        TelemetryDimensions.Add('ResponseLength', Format(StrLen(AOAIResponse.GetResult())));
        exit(true);
    end;

    local procedure HandleFunctionCalls(var AOAIResponse: Codeunit "AOAI Operation Response"): Boolean
    var
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        Success: Boolean;
        ExecutedFunctions: Text;
        FunctionCallExecuteFailedTok: Label 'Function %1 failed to execute', Comment = '%1 = Function name', Locked = true;
        FailedFunctionEventTok: Label 'Function Execution Failed', Locked = true;
        FunctionCallFailedTok: Label 'Function call failed', Locked = true;
    begin
        Success := true;
        TelemetryDimensions.Add('Number of Function Calls', Format(AOAIResponse.GetFunctionResponses().Count()));

        foreach AOAIFunctionResponse in AOAIResponse.GetFunctionResponses() do
            if AOAIFunctionResponse.IsSuccess() then begin
                // Function was executed successfully by the AI model
                if ExecutedFunctions <> '' then
                    ExecutedFunctions += ', ';
                ExecutedFunctions += AOAIFunctionResponse.GetFunctionName();
            end else begin
                Success := false;
                TelemetryDimensions.Add('FailedFunction', AOAIFunctionResponse.GetFunctionName());
                LogError(FailedFunctionEventTok, StrSubstNo(FunctionCallExecuteFailedTok, AOAIFunctionResponse.GetFunctionName()));
            end;

        if Success then
            TelemetryDimensions.Add('ExecutedFunctions', ExecutedFunctions)
        else
            LogError(FunctionCallFailedTok, 'One or more function calls failed');

        exit(Success);
    end;

    local procedure LogFeatureUptake()
    begin
        FeatureTelemetry.LogUptake('0000PUJ', AISystem.GetFeatureName(), Enum::"Feature Uptake Status"::"Set up");
        FeatureTelemetry.LogUptake('0000PUK', AISystem.GetFeatureName(), Enum::"Feature Uptake Status"::Used);
    end;

    local procedure LogResult(Success: Boolean)
    begin
        if Success then
            FeatureTelemetry.LogUsage('0000PUL', AISystem.GetFeatureName(), 'AI Processing Success', TelemetryDimensions)
        else
            FeatureTelemetry.LogError('0000PUH', AISystem.GetFeatureName(), 'AI Processing Failed', 'Processing failed', '', TelemetryDimensions);
    end;

    local procedure LogError(EventName: Text; ErrorMessage: Text)
    begin
        FeatureTelemetry.LogError('0000PUI', AISystem.GetFeatureName(), EventName, ErrorMessage, '', TelemetryDimensions);
    end;

    local procedure GetDefaultMaxInputTokens(): Integer
    begin
        exit(125000); // 125k token limit
    end;

    local procedure GetDefaultMaxOutputTokens(): Integer
    begin
        exit(32000); // 32k token limit
    end;

    local procedure GetDefaultTemperature(): Decimal
    begin
        exit(0);
    end;

    local procedure GetDefaultModel(): Text
    var
        AOAIDeployments: Codeunit "AOAI Deployments";
    begin
        exit(AOAIDeployments.GetGPT41Latest());
    end;

    procedure GetEDocumentMatchingAssistanceName(): Text
    begin
        exit('E-Document Matching Assistance');
    end;

}