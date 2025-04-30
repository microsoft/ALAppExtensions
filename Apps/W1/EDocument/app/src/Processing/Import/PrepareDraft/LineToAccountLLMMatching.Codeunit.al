// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using System.Azure.KeyVault;
using Microsoft.Finance.GeneralLedger.Account;
using System.AI;
using System.Telemetry;

codeunit 6126 "Line To Account LLM Matching" implements "AOAI Function"
{
    Access = Internal;

    var
        TelemetryChatCompletionErr: label 'Chat completion request for proposing purchase line account was unsuccessful. Response code: %1', Locked = true;
        TelemetryChatCompletionSuccessTxt: label 'Chat completion request for proposing purchase line account was successful. Response code: %1', Locked = true;
        FunctionNameLbl: Label 'match_lines_glaccounts', Locked = true;
        Result: Dictionary of [Integer, Code[20]];
        InstrPromptSNameLbl: label 'EDocMatchLineToGLAccount', Locked = true;

    procedure GetPurchaseLineAccountsWithCopilot(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Dictionary of [Integer, Code[20]]
    var
        EDocumentLineMapping: Record "E-Document Line Mapping";
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FindGLAccountsPromptSecTxt: SecretText;
        EDocumentPurchaseLinesTxt: Text;
        GLAccountsTxt: Text;
    begin
        Clear(Result);

        // Build prompt
        FindGLAccountsPromptSecTxt := BuildMostAppropriateGLAccountPromptTask();
        GLAccountsTxt := BuildGLAccounts();
        EDocumentPurchaseLinesTxt := BuildEDocumentPurchaseLines(EDocumentPurchaseLine);

        // Call AOAI
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT4oLatest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"E-Document Matching Assistance");
        AOAIChatCompletionParams.SetMaxTokens(4096);
        AOAIChatCompletionParams.SetTemperature(0);
        FeatureTelemetry.LogUptake('0000P2L', FeatureName(), Enum::"Feature Uptake Status"::"Set up");
        FeatureTelemetry.LogUptake('0000OUT', FeatureName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000P2M', FeatureName(), 'Suggect G/L account for purchase line');
        GetCompletionResponse(AOAIChatMessages, EDocumentPurchaseLinesTxt, FindGLAccountsPromptSecTxt, GLAccountsTxt, AzureOpenAI, AOAIChatCompletionParams, AOAIOperationResponse);

        if AOAIOperationResponse.IsSuccess() then
            Session.LogMessage('0000P2N', TelemetryChatCompletionSuccessTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName())
        else begin
            Session.LogMessage('0000P2O', StrSubstNo(TelemetryChatCompletionErr, AOAIOperationResponse.GetStatusCode()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
            Error(AOAIOperationResponse.GetError());
        end;

        // Grounding check on Result (filled by Execute method), saving the proposal 
        if Result.Count() > 0 then begin
            EDocumentPurchaseLine.FindSet();
            repeat
                if Result.ContainsKey(EDocumentPurchaseLine."Line No.") then
                    if EDocumentLineMapping.Get(EDocumentPurchaseLine."E-Document Entry No.", EDocumentPurchaseLine."Line No.") then
                        if SetPurchaseLineAccountFromCopilotResult(EDocumentLineMapping, Result.Get(EDocumentPurchaseLine."Line No.")) then
                            EDocumentLineMapping.Modify();
            until EDocumentPurchaseLine.Next() = 0;
        end;

        exit(Result);
    end;

    [TryFunction]
    local procedure SetPurchaseLineAccountFromCopilotResult(var EDocumentLineMapping: Record "E-Document Line Mapping"; ValueSuggested: Code[20])
    begin
        EDocumentLineMapping."Purchase Line Type" := EDocumentLineMapping."Purchase Line Type"::"G/L Account";
        EDocumentLineMapping.Validate("Purchase Type No.", ValueSuggested);
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

    procedure BuildEDocumentPurchaseLines(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Text
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
            until EDocumentPurchaseLine.Next() = 0;

        exit(LocalStatementLines);
    end;

    local procedure FeatureName(): Text
    begin
        exit('Payables Agent')
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