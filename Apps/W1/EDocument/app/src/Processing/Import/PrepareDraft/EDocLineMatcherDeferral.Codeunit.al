// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using System.AI;
using System.Telemetry;
using Microsoft.Finance.Deferral;
using System.Azure.KeyVault;
using System.Log;

codeunit 6129 "E-Doc Line Matcher - Deferral" implements "AOAI Function"
{
    Access = Internal;

    var
        TempGlobalEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocumentNo: Integer;
        FunctionNameLbl: Label 'match_lines_deferral', Locked = true;
        CallChatCompletionTok: Label 'Call Chat Completion API', Locked = true;
        ProcessFunctionCallTok: Label 'Process function call', Locked = true;
        ResponseErr: Label 'Response error code: %1. Error message: %2', Comment = '%1 = Error code, %2 = Error message', Locked = true;
        TelemetryCustomDimensions: Dictionary of [Text, Text];

    internal procedure ApplyPurchaseLineMatchingProposals(var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        if GetPurchaseLineMatchingProposals(EDocumentPurchaseLine) then
            SetMatchedEDocumentPurchaseLines();
    end;

    internal procedure GetPurchaseLineMatchingProposals(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Boolean
    var
        DeferralTemplate: Record "Deferral Template";
        CopilotCapability: Codeunit "Copilot Capability";
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
    begin
        if DeferralTemplate.IsEmpty() then
            exit(false);

        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"E-Document Matching Assistance") then
            exit(false);
        if not CopilotCapability.IsCapabilityActive(Enum::"Copilot Capability"::"E-Document Matching Assistance") then
            exit(false);

        ConfigureAzureOpenAIParameters(AzureOpenAI, AOAIChatCompletionParams);
        BuildPrompt(AOAIChatMessages, EDocumentPurchaseLine);
        PrepareEDocLineMatchBuffer(EDocumentPurchaseLine);
        this.TelemetryCustomDimensions.Add('Lines considered', Format(EDocumentPurchaseLine.Count()));

        ProcessAzureOpenAICompletion(AzureOpenAI, AOAIChatCompletionParams, AOAIChatMessages);
        exit(true);
    end;

    local procedure PrepareEDocLineMatchBuffer(var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        Clear(this.TempGlobalEDocLineMatchBuffer);
        this.TempGlobalEDocLineMatchBuffer.DeleteAll();
        this.EDocumentNo := EDocumentPurchaseLine."E-Document Entry No.";
    end;

    local procedure ProcessAzureOpenAICompletion(var AzureOpenAI: Codeunit "Azure OpenAI"; var AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params"; var AOAIChatMessages: Codeunit "AOAI Chat Messages"): Boolean
    var
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        StartDateTime: DateTime;
        DurationAsBigInt: BigInteger;
    begin
        StartDateTime := CurrentDateTime();
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        DurationAsBigInt := CurrentDateTime() - StartDateTime;
        this.TelemetryCustomDimensions.Add('Response time (ms)', Format(DurationAsBigInt));

        if not AOAIOperationResponse.IsSuccess() then begin
            FeatureTelemetry.LogError('0000PK3', FeatureName(), CallChatCompletionTok, StrSubstNo(ResponseErr, AOAIOperationResponse.GetStatusCode(), AOAIOperationResponse.GetError()), '', this.TelemetryCustomDimensions);
            exit(false);
        end;

        if AOAIOperationResponse.IsFunctionCall() then begin
            LogFunctionUsage(AOAIOperationResponse);
            exit(true);
        end;

        if AOAIOperationResponse.GetResult() = '' then
            FeatureTelemetry.LogError('0000PK1', FeatureName(), CallChatCompletionTok, 'Completion answer is empty', '', this.TelemetryCustomDimensions)
        else begin
            this.TelemetryCustomDimensions.Add('Completion response', AOAIOperationResponse.GetResult());
            FeatureTelemetry.LogError('0000PK2', FeatureName(), CallChatCompletionTok, 'Function call not found in the completion answer', '', this.TelemetryCustomDimensions);
        end;

        exit(false);
    end;

    local procedure LogFunctionUsage(AOAIOperationResponse: Codeunit "AOAI Operation Response")
    var
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
    begin
        this.TelemetryCustomDimensions.Add('Number of function calls', Format(AOAIOperationResponse.GetFunctionResponses().Count()));
        FeatureTelemetry.LogUsage('0000PK6', FeatureName(), CallChatCompletionTok, this.TelemetryCustomDimensions);
        foreach AOAIFunctionResponse in AOAIOperationResponse.GetFunctionResponses() do
            if not AOAIFunctionResponse.IsSuccess() then
                if AOAIFunctionResponse.GetFunctionName() <> GetName() then begin
                    this.TelemetryCustomDimensions.Add('Unexpected function', AOAIFunctionResponse.GetFunctionName());
                    FeatureTelemetry.LogError('0000PJZ', FeatureName(), ProcessFunctionCallTok, 'Function not supported', '', this.TelemetryCustomDimensions);
                end
                else
                    FeatureTelemetry.LogError('0000PK0', FeatureName(), ProcessFunctionCallTok, 'Function failure', '', this.TelemetryCustomDimensions);
    end;

    local procedure SetMatchedEDocumentPurchaseLines()
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocActivityLogBuilder: Codeunit "Activity Log Builder";
        CountMatchedDeferral, CountMistakes : Integer;
        Reasoning: Text;
        ActivityLogTitleTxt: Label 'Copilot identified deferral account';
        ApplyLineMatchingProposalsTok: Label 'Apply line matching proposals - Deferral', Locked = true;
    begin
        Clear(this.TempGlobalEDocLineMatchBuffer);
        if this.TempGlobalEDocLineMatchBuffer.FindSet() then
            repeat
                if not EDocumentPurchaseLine.Get(this.TempGlobalEDocLineMatchBuffer."E-Document Entry No.", this.TempGlobalEDocLineMatchBuffer."Line No.") then begin
                    CountMistakes += 1;
                    continue;
                end;

                if TryValidateDeferralCode(TempGlobalEDocLineMatchBuffer, EDocumentPurchaseLine) then begin
                    CountMatchedDeferral += 1;

                    Reasoning := TempGlobalEDocLineMatchBuffer."Deferral Reason";
                    EDocActivityLogBuilder
                        .Init(Database::"E-Document Purchase Line", EDocumentPurchaseLine.FieldNo("[BC] Deferral Code"), EDocumentPurchaseLine.SystemId)
                        .SetExplanation(Reasoning)
                        .SetType(Enum::"Activity Log Type"::"AI")
                        .SetReferenceSource('')
                        .SetReferenceTitle(ActivityLogTitleTxt)
                        .Log();

                end;

                EDocumentPurchaseLine.Modify(true);
            until this.TempGlobalEDocLineMatchBuffer.Next() = 0;

        this.TelemetryCustomDimensions.Add('Proposed deferrals', Format(this.TempGlobalEDocLineMatchBuffer.Count()));
        this.TelemetryCustomDimensions.Add('Matched deferrals', Format(CountMatchedDeferral));
        this.TelemetryCustomDimensions.Add('Processing mistakes', Format(CountMistakes));

        FeatureTelemetry.LogUsage('0000PK7', FeatureName(), ApplyLineMatchingProposalsTok, this.TelemetryCustomDimensions);
    end;

    [TryFunction]
    local procedure TryValidateDeferralCode(TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary; var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        EDocumentPurchaseLine.Validate("[BC] Deferral Code", TempEDocLineMatchBuffer."Deferral Code");
    end;

    local procedure ConfigureAzureOpenAIParameters(var AzureOpenAI: Codeunit "Azure OpenAi"; var AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params")
    var
        AOAIDeployments: Codeunit "AOAI Deployments";
        SuggestMatchingForPurchaseLineLbl: label 'Suggest matching for purchase line - Deferral', Locked = true;
    begin
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT41Latest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"E-Document Matching Assistance");
        AOAIChatCompletionParams.SetMaxTokens(4096);
        AOAIChatCompletionParams.SetTemperature(0);
        FeatureTelemetry.LogUptake('0000PK4', FeatureName(), Enum::"Feature Uptake Status"::"Set up");
        FeatureTelemetry.LogUptake('0000PK5', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000PK8', FeatureName(), SuggestMatchingForPurchaseLineLbl);
    end;

    local procedure BuildPrompt(var AOAIChatMessages: Codeunit "AOAI Chat Messages"; var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    var
        AOAIToken: Codeunit "AOAI Token";
        UserMessage: JsonArray;
        UserMessageTxt: Text;
        EstimateTokenCount: Integer;
        TokenThresholdExceededLbl: label 'Token threshold exceeded for line matching suggestion', Locked = true;
    begin
        // Get invoice and company data for prompt
        UserMessage.Add(BuildEDocumentPurchaseLines(EDocumentPurchaseLine));
        UserMessage.Add(BuildDeferralTemplates());
        UserMessage.WriteTo(UserMessageTxt);

        EstimateTokenCount := AOAIToken.GetGPT4TokenCount(UserMessageTxt);
        if EstimateTokenCount > PromptInputThreshold() then begin
            this.TelemetryCustomDimensions.Add('Token Count', Format(EstimateTokenCount));
            FeatureTelemetry.LogUsage('0000PK9', FeatureName(), TokenThresholdExceededLbl, this.TelemetryCustomDimensions);
            Error(TokenThresholdExceededLbl);
        end;

        AOAIChatMessages.SetPrimarySystemMessage(BuildLineMatchingSystemPrompt());
        AOAIChatMessages.AddUserMessage(UserMessageTxt);
        AOAIChatMessages.AddTool(this);
        AOAIChatMessages.SetToolChoice('auto');
    end;

    local procedure BuildLineMatchingSystemPrompt() PromptSecretText: SecretText
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        PromptSecretNameTok: Label 'DeferralMatching-SystemPrompt', Locked = true;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(PromptSecretNameTok, PromptSecretText) then
            PromptSecretText := SecretStrSubstNo('');
        exit(PromptSecretText);
    end;

    local procedure BuildEDocumentPurchaseLines(var EDocumentPurchaseLine: Record "E-Document Purchase Line") EDocumentPurchaseLinesJson: JsonObject
    var
        JsonObject: JsonObject;
        EDocumentPurchaseLineArray: JsonArray;
    begin
        EDocumentPurchaseLine.Ascending(true);
        if EDocumentPurchaseLine.FindSet() then
            repeat
                Clear(JsonObject);
                JsonObject.Add('id', EDocumentPurchaseLine."Line No.");
                JsonObject.Add('description', EDocumentPurchaseLine.Description);
                EDocumentPurchaseLineArray.Add(JsonObject);
            until EDocumentPurchaseLine.Next() = 0;

        EDocumentPurchaseLinesJson.Add('purchaseLines', EDocumentPurchaseLineArray);
    end;

    local procedure BuildDeferralTemplates() DeferralTemplatesJson: JsonObject
    var
        DeferralTemplate: Record "Deferral Template";
        JsonObject: JsonObject;
        DeferralTemplateArray: JsonArray;
    begin
        if DeferralTemplate.FindSet() then
            repeat
                Clear(JsonObject);
                JsonObject.Add('deferralCode', DeferralTemplate."Deferral Code");
                JsonObject.Add('numberOfPeriods', DeferralTemplate."No. of Periods");
                JsonObject.Add('description', DeferralTemplate.Description);
                DeferralTemplateArray.Add(JsonObject);
            until DeferralTemplate.Next() = 0;

        DeferralTemplatesJson.Add('deferralTemplates', DeferralTemplateArray);
    end;

    procedure GetPrompt(): JsonObject
    var
        ToolDefinition: JsonObject;
        FunctionDefinition: JsonObject;
        ParametersDefinition: JsonObject;
        FunctionDescriptionLbl: Label 'Matches invoice lines with Deferral Templates.', Locked = true;
    begin
        ParametersDefinition.ReadFrom(NavApp.GetResourceAsText('DeferralMatching-FunctionParameters.json'));

        FunctionDefinition.Add('name', FunctionNameLbl);
        FunctionDefinition.Add('description', FunctionDescriptionLbl);
        FunctionDefinition.Add('parameters', ParametersDefinition);

        ToolDefinition.Add('type', 'function');
        ToolDefinition.Add('function', FunctionDefinition);

        exit(ToolDefinition);
    end;

    internal procedure Execute(Arguments: JsonObject): Variant
    var
        ProposedDeferralCode: Text;
    begin
        ProposedDeferralCode := Arguments.GetText('deferralCode');
        if ProposedDeferralCode = '' then
            exit;

        Clear(this.TempGlobalEDocLineMatchBuffer);
        this.TempGlobalEDocLineMatchBuffer."E-Document Entry No." := this.EDocumentNo;
        this.TempGlobalEDocLineMatchBuffer."Line No." := Arguments.GetInteger('lineId');
        this.TempGlobalEDocLineMatchBuffer."Deferral Code" := CopyStr(ProposedDeferralCode, 1, MaxStrLen(TempGlobalEDocLineMatchBuffer."Deferral Code"));

        if Arguments.Contains('deferralReasoning') then
            this.TempGlobalEDocLineMatchBuffer."Deferral Reason" := CopyStr(Arguments.GetText('deferralReasoning'), 1, 250);

        // Guarding insert as LLM result could be contain duplicate line numbers.
        if this.TempGlobalEDocLineMatchBuffer.Insert() then;
        exit('Completed');
    end;

    internal procedure LoadEDocLineMatchBuffer(var TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary)
    begin
        Clear(this.TempGlobalEDocLineMatchBuffer);
        if this.TempGlobalEDocLineMatchBuffer.FindSet() then
            repeat
                TempEDocLineMatchBuffer := this.TempGlobalEDocLineMatchBuffer;
                if TempEDocLineMatchBuffer.Insert() then;
            until this.TempGlobalEDocLineMatchBuffer.Next() = 0;
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;

    local procedure FeatureName(): Text
    begin
        exit('EDocument Line Matching - Deferral')
    end;

    local procedure PromptInputThreshold(): Integer
    begin
        exit(10000)
    end;
}