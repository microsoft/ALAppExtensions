// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Finance.GeneralLedger.Account;
using System.AI;
using System.Azure.KeyVault;
using System.Telemetry;

codeunit 6126 "Line To Account LLM Matching" implements "AOAI Function"
{
    Access = Internal;

    var
        TelemetryChatCompletionErr: label 'Chat completion request for proposing purchase line account was unsuccessful. Response code: %1', Locked = true;
        TelemetryChatCompletionSuccessTxt: label 'Chat completion request for proposing purchase line account was successful. Response code: %1', Locked = true;
        MatchStatisticsTxt: label 'Purchase Document Draft line match proposal created.', Locked = true;
        FunctionNameLbl: Label 'match_lines_glaccounts', Locked = true;
        Result: Dictionary of [Integer, Code[20]];
        InstrPromptSNameLbl: label 'EDocMatchLineToGLAccount', Locked = true;
        ExceededTokenThresholdTxt: label 'Not calling LLM, token count too high.', Locked = true;
        ExceededTokenThresholdGLAccErr: label 'The list of direct-posting income statement general ledger accounts in your database is too long to send to Copilot with the purpose of matching with invoice lines.';
        FeatureNameTxt: label 'E-Document Matching Assistance', Locked = true;

    procedure GetPurchaseLineAccountsWithCopilot(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Dictionary of [Integer, Code[20]]
    var
        EDocument: Record "E-Document";
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AOAIToken: Codeunit "AOAI Token";
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        TelemetryCustomDimensions: Dictionary of [Text, Text];
        FindGLAccountsPromptSecTxt: SecretText;
        EDocumentPurchaseLinesTxt: Text;
        SuccessfulAssignment: Boolean;
        GLAccountsTxt: Text;
        LinesMatched: Integer;
        EstimateTokenCount, EstimateGLAccInstrTokenCount : Integer;
        LineDictionary: Dictionary of [Integer, Text[100]];
    begin
        if EDocumentPurchaseLine.IsEmpty() then
            exit(Result);
        Clear(Result);
        if not EDocument.Get(EDocumentPurchaseLine."E-Document Entry No.") then
            exit(Result);

        // Build prompt
        FindGLAccountsPromptSecTxt := BuildMostAppropriateGLAccountPromptTask();
        GLAccountsTxt := BuildGLAccounts();
        EDocumentPurchaseLinesTxt := BuildEDocumentPurchaseLines(EDocumentPurchaseLine, LineDictionary);
        EstimateGLAccInstrTokenCount := AOAIToken.GetGPT4TokenCount(FindGLAccountsPromptSecTxt) + AOAIToken.GetGPT4TokenCount(GLAccountsTxt);

        // if GL Account list and instructional part of the prompt are too big, over token limit, we log a warning
        if EstimateGLAccInstrTokenCount > PromptInputThreshold() then begin
            Session.LogMessage('0000PCS', ExceededTokenThresholdTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName(), 'EstimateTokenCount', Format(EstimateTokenCount));
            FeatureTelemetry.LogUsage('0000PCT', FeatureName(), 'Token threshold exceeded for suggest G/L account');
            if EDocument.Get(EDocumentPurchaseLine."E-Document Entry No.") then
                EDocErrorHelper.LogWarningMessage(EDocument, EDocumentPurchaseLine, EDocumentPurchaseLine.FieldNo("[BC] Purchase Type No."), ExceededTokenThresholdGLAccErr);
            exit(Result);
        end;

        // Call AOAI
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT4oLatest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"E-Document Matching Assistance");
        AOAIChatCompletionParams.SetMaxTokens(4096);
        AOAIChatCompletionParams.SetTemperature(0);
        FeatureTelemetry.LogUptake('0000P2L', FeatureName(), Enum::"Feature Uptake Status"::"Set up");
        FeatureTelemetry.LogUptake('0000OUT', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000P2M', FeatureName(), 'Suggest G/L account for purchase line');
        EstimateTokenCount := AOAIToken.GetGPT4TokenCount(FindGLAccountsPromptSecTxt) + AOAIToken.GetGPT4TokenCount(EDocumentPurchaseLinesTxt + GLAccountsTxt);

        // if adding the full line list made the prompt too big, do multiple requests with subsets of lines
        if EstimateTokenCount <= PromptInputThreshold() then begin
            GetCompletionResponse(AOAIChatMessages, EDocumentPurchaseLinesTxt, FindGLAccountsPromptSecTxt, GLAccountsTxt, AzureOpenAI, AOAIChatCompletionParams, AOAIOperationResponse);

            if AOAIOperationResponse.IsSuccess() then
                Session.LogMessage('0000P2N', TelemetryChatCompletionSuccessTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName())
            else begin
                Session.LogMessage('0000P2O', StrSubstNo(TelemetryChatCompletionErr, AOAIOperationResponse.GetStatusCode()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
                if EDocument.Get(EDocumentPurchaseLine."E-Document Entry No.") then
                    EDocErrorHelper.LogWarningMessage(EDocument, EDocumentPurchaseLine, EDocumentPurchaseLine.FieldNo("[BC] Purchase Type No."), AOAIOperationResponse.GetError());
                exit(Result)
            end
        end else
            while LineDictionary.Count() > 0 do begin
                // build the smaller list of lines with the remaining lines (LineDictionary keeps shrinking in BuildSubsetEDocumentPurchaseLines)
                FeatureTelemetry.LogUsage('0000PGS', FeatureName(), 'Suggest G/L account request chunking');
                EDocumentPurchaseLinesTxt := BuildSubsetEDocumentPurchaseLines(EDocumentPurchaseLine, LineDictionary, EstimateGLAccInstrTokenCount);
                GetCompletionResponse(AOAIChatMessages, EDocumentPurchaseLinesTxt, FindGLAccountsPromptSecTxt, GLAccountsTxt, AzureOpenAI, AOAIChatCompletionParams, AOAIOperationResponse);

                if AOAIOperationResponse.IsSuccess() then
                    Session.LogMessage('0000P2N', TelemetryChatCompletionSuccessTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName())
                else begin
                    Session.LogMessage('0000P2O', StrSubstNo(TelemetryChatCompletionErr, AOAIOperationResponse.GetStatusCode()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
                    if EDocument.Get(EDocumentPurchaseLine."E-Document Entry No.") then
                        EDocErrorHelper.LogWarningMessage(EDocument, EDocumentPurchaseLine, EDocumentPurchaseLine.FieldNo("[BC] Purchase Type No."), AOAIOperationResponse.GetError());
                    exit(Result);
                end;
            end;

        // Grounding check on Result (filled by Execute method), saving the proposal 
        if Result.Count() > 0 then
            if EDocumentPurchaseLine.FindSet() then
                repeat
                    EDocImpSessionTelemetry.SetLineBool(EDocumentPurchaseLine.SystemId, 'GL Acc. CM', Result.ContainsKey(EDocumentPurchaseLine."Line No."));
                    if Result.ContainsKey(EDocumentPurchaseLine."Line No.") then begin
                        SuccessfulAssignment := SetPurchaseLineAccountFromCopilotResult(EDocumentPurchaseLine, Result.Get(EDocumentPurchaseLine."Line No."));
                        if SuccessfulAssignment then begin
                            EDocumentPurchaseLine.Modify();
                            LinesMatched += 1;
                        end;
                        EDocImpSessionTelemetry.SetLineBool(EDocumentPurchaseLine.SystemId, 'GL Acc. CM Assigned', SuccessfulAssignment);
                    end;
                until EDocumentPurchaseLine.Next() = 0;

        TelemetryCustomDimensions.Add('Category', FeatureName());
        TelemetryCustomDimensions.Add('LinesConsidered', Format(EDocumentPurchaseLine.Count()));
        TelemetryCustomDimensions.Add('LInesMatched', Format(LinesMatched));
        Session.LogMessage('0000PCN', MatchStatisticsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryCustomDimensions);

        exit(Result);
    end;

    local procedure PromptInputThreshold(): Integer
    begin
        exit(20000)
    end;

    [TryFunction]
    local procedure SetPurchaseLineAccountFromCopilotResult(var EDocumentPurchaseLine: Record "E-Document Purchase Line"; ValueSuggested: Code[20])
    begin
        EDocumentPurchaseLine."[BC] Purchase Line Type" := EDocumentPurchaseLine."[BC] Purchase Line Type"::"G/L Account";
        EDocumentPurchaseLine.Validate("[BC] Purchase Type No.", ValueSuggested);
    end;

    [NonDebuggable]
    local procedure GetCompletionResponse(var AOAIChatMessages: Codeunit "AOAI Chat Messages"; EDocumentPurchaseLinesTxt: Text; var FindGLAccountsPromptSecTxt: SecretText; GLAccountsTxt: Text; var AzureOpenAI: Codeunit "Azure OpenAi"; var AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params"; var AOAIOperationResponse: Codeunit "AOAI Operation Response")
    var
        SysMsg: Text;
        UserMsg: Text;
    begin
        SysMsg := FindGLAccountsPromptSecTxt.Unwrap();
        UserMsg := BuildBankRecPromptUserMessage(EDocumentPurchaseLinesTxt, GLAccountsTxt).Unwrap();
        AOAIChatMessages.AddSystemMessage(SysMsg);
        AOAIChatMessages.AddUserMessage(UserMsg);
        AOAIChatMessages.AddTool(this);
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
    end;

    local procedure BuildBankRecPromptUserMessage(StatementLine: Text; GLAccounts: Text): SecretText
    var
        UserMessagePrompt: SecretText;
        EmptyText: SecretText;
        ConcatSubstrTok: Label '%1%2', Locked = true;
    begin
        GLAccounts += '"""\n';
        StatementLine += '"""\n';
        UserMessagePrompt := SecretStrSubstNo(ConcatSubstrTok, EmptyText, StatementLine);
        UserMessagePrompt := SecretStrSubstNo(ConcatSubstrTok, UserMessagePrompt, GLAccounts);
        exit(UserMessagePrompt);
    end;

    procedure BuildMostAppropriateGLAccountPromptTask(): SecretText
    var
        CompletionTaskTxt: SecretText;
    begin
        if not GetAzureKeyVaultSecret(CompletionTaskTxt, InstrPromptSNameLbl) then
            CompletionTaskTxt := SecretStrSubstNo('');

        exit(CompletionTaskTxt)
    end;

    local procedure GetAzureKeyVaultSecret(var SecretValue: SecretText; SecretName: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(SecretName, SecretValue) then
            exit(false);

        if SecretValue.IsEmpty() then
            exit(false);

        exit(true);
    end;

    procedure BuildGLAccounts(): Text
    var
        GLAccount: Record "G/L Account";
        GLAccountsTxt: Text;
    begin
        GLAccount.SetRange("Direct Posting", true);
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Income Statement");

        if (GLAccountsTxt = '') then
            GLAccountsTxt := '**G/L Accounts**:\n"""\n';

        if not GLAccount.FindSet() then
            exit(GLAccountsTxt);

        repeat
            GLAccountsTxt += '#Id: ' + GLAccount."No.";
            GLAccountsTxt += ', Name: ' + GLAccount.Name;
            GLAccountsTxt += '\n'
        until (GLAccount.Next() = 0);
        exit(GLAccountsTxt);
    end;

    procedure BuildEDocumentPurchaseLines(var EDocumentPurchaseLine: Record "E-Document Purchase Line"; var LineDictionary: Dictionary of [Integer, Text[100]]): Text
    var
        LocalStatementLines: Text;
    begin
        if (LocalStatementLines = '') then
            LocalStatementLines := '**Statement Lines**:\n"""\n';

        EDocumentPurchaseLine.Ascending(true);
        if EDocumentPurchaseLine.FindSet() then
            repeat
                LocalStatementLines += '#Id: ' + Format(EDocumentPurchaseLine."Line No.");
                LocalStatementLines += ', Description: ' + EDocumentPurchaseLine.Description;
                LocalStatementLines += '\n';
                LineDictionary.Add(EDocumentPurchaseLine."Line No.", EDocumentPurchaseLine.Description);
            until EDocumentPurchaseLine.Next() = 0;

        exit(LocalStatementLines);
    end;

    local procedure BuildSubsetEDocumentPurchaseLines(var EDocumentPurchaseLine: Record "E-Document Purchase Line"; var LineDictionary: Dictionary of [Integer, Text[100]]; EstimateGLAccInstrTokenCount: Integer): Text
    var
        EDocument: Record "E-Document";
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        AOAIToken: Codeunit "AOAI Token";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        KeysToRemove: List of [Integer];
        LocalStatementLines, LineAddition : Text;
        LineNo: Integer;
        LineDescription: Text[100];
    begin
        LocalStatementLines := '**Statement Lines**:\n"""\n';

        // keep adding line descriptions until token threshold is reached
        foreach LineNo in LineDictionary.Keys() do begin
            LineDescription := LineDictionary.Get(LineNo);
            LineAddition := '#Id: ' + Format(EDocumentPurchaseLine."Line No.");
            LineAddition += ', Description: ' + EDocumentPurchaseLine.Description;
            LineAddition += '\n';
            if (EstimateGLAccInstrTokenCount + AOAIToken.GetGPT4TokenCount(LocalStatementLines + LineAddition)) < PromptInputThreshold() then begin
                LocalStatementLines += LineAddition;
                KeysToRemove.Add(LineNo);
            end else
                break;
        end;

        // if we couldn't add even one line without exceeding threshold, throw an error as well
        if KeysToRemove.Count() = 0 then begin
            Session.LogMessage('0000PGT', ExceededTokenThresholdTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName(), 'EstimateTokenCount', Format(EstimateGLAccInstrTokenCount));
            FeatureTelemetry.LogUsage('0000PCT', FeatureName(), 'Token threshold exceeded for suggest G/L account');
            if EDocument.Get(EDocumentPurchaseLine."E-Document Entry No.") then
                EDocErrorHelper.LogWarningMessage(EDocument, EDocumentPurchaseLine, EDocumentPurchaseLine.FieldNo("[BC] Purchase Type No."), ExceededTokenThresholdGLAccErr);
        end;

        // remove all lines that have been added to the prompt input
        foreach LineNo in KeysToRemove do
            LineDictionary.Remove(LineNo);

        exit(LocalStatementLines);
    end;

    local procedure FeatureName(): Text
    begin
        exit(FeatureNameTxt)
    end;

    procedure GetPrompt(): JsonObject
    var
        ToolDefinition: JsonObject;
        FunctionDefinition: JsonObject;
        ParametersDefinition: JsonObject;
        ParDefTxt: Text;
    begin
        ParDefTxt := '{"type": "object","properties": {"reasoning": {"type": "string","description": "reason for the match"},"lineId": {"type": "number","description": "Line number."},"accountId": {"type": "string","description": "G/L Account number."}},"required": ["reasoning","lineId","accountId"]}';
        ParametersDefinition.ReadFrom(ParDefTxt);

        FunctionDefinition.Add('name', FunctionNameLbl);
        FunctionDefinition.Add('description', 'Matches invoice lines with G/L Accounts.');
        FunctionDefinition.Add('parameters', ParametersDefinition);

        ToolDefinition.Add('type', 'function');
        ToolDefinition.Add('function', FunctionDefinition);

        exit(ToolDefinition);
    end;

    procedure Execute(Arguments: JsonObject): Variant
    var
        LineNo: Integer;
        GLAccountNo: Code[20];
    begin
        LineNo := Arguments.GetInteger('lineId');
        GLAccountNo := CopyStr(Arguments.GetText('accountId'), 1, MaxStrLen(GLACcountNo));
        Result.Add(LineNo, GLAccountNo);
        exit('');
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;
}