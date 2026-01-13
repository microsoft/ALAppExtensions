// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using System.AI;
using System.Globalization;
using System.Azure.KeyVault;
using System.Telemetry;

codeunit 4302 "SOA Validation Function" implements "AOAI Function"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        IrrelevantReason: Text;
        Irrelevant: Boolean;
        LoadToolErr: Label 'Failed to parse the validate tool. Expected a valid JSON object from Azure Key Vault.';
        AKVRetrievalErr: Label 'Unable to retrieve SOA Irrelevant Prompt from Azure Key Vault.', Locked = true;

    procedure GetPrompt(): JsonObject
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        SOASetupCU: Codeunit "SOA Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Tool: JsonObject;
        ToolText: Text;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret('BCSOAIrrelevanceValidateToolV27', ToolText) then begin
            FeatureTelemetry.LogError('0000PPJ', SOASetupCU.GetFeatureName(), 'Get AKV Secret', AKVRetrievalErr, GetLastErrorCallStack(), TelemetryDimensions);
            Error(AKVRetrievalErr);
        end;
        ReplaceAgentLanguageInPrompt(ToolText);
        if not Tool.ReadFrom(ToolText) then
            Error(LoadToolErr);
        exit(Tool);
    end;

    procedure Execute(Arguments: JsonObject): Variant
    var
        DetailedReason: Text;
        SupportedRequest: Boolean;
        NotSupportedRequest: Boolean;
        IsReactionToPreviousMessage: Boolean;
    begin
        if Arguments.Contains('detailedReason') then // Just for CoT
            DetailedReason := Arguments.GetText('detailedReason');
        if Arguments.Contains('reason') then // Shown in UI
            IrrelevantReason := Arguments.GetText('reason');
        if Arguments.Contains('hasSupportedRequest') then
            SupportedRequest := Arguments.GetBoolean('hasSupportedRequest');
        if Arguments.Contains('hasNotSupportedRequest') then
            NotSupportedRequest := Arguments.GetBoolean('hasNotSupportedRequest');
        if Arguments.Contains('isReactionToPreviousMessage') then
            IsReactionToPreviousMessage := Arguments.GetBoolean('isReactionToPreviousMessage');

        Irrelevant := NotSupportedRequest or ((not SupportedRequest) and (not IsReactionToPreviousMessage));
    end;

    procedure GetName(): Text
    begin
        exit('Validate');
    end;

    internal procedure IsIrrelevant(): Boolean
    begin
        exit(Irrelevant);
    end;

    internal procedure GetIrrelevantReason(): Text
    begin
        exit(IrrelevantReason);
    end;

    local procedure GetAgentLanguage(): Text
    var
        WindowsLanguage: Record "Windows Language";
        Language: Codeunit Language;
        LanguageId: Integer;
    begin
        LanguageId := Language.GetLanguageId(Language.GetUserLanguageCode());
        if WindowsLanguage.Get(LanguageId) then
            exit(WindowsLanguage.Name);
    end;

    local procedure ReplaceAgentLanguageInPrompt(var ToolText: Text)
    var
        LanguageTok: Label '{{LANGUAGE}}', Locked = true;
    begin
        ToolText := ToolText.Replace(LanguageTok, GetAgentLanguage());
    end;

}