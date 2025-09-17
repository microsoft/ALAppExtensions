// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.Telemetry;
using System.Azure.KeyVault;

codeunit 6297 "Sustainability Prompts"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetRawFormulaSystemPrompt() PromptSecretText: SecretText
    begin
        GetAzureKeyVaultSecret(PromptSecretText, 'BCSustCopilotRawFormulaSystemPrompt');
    end;

    procedure GetRawFormulaFunction() PromptSecretText: SecretText
    begin
        GetAzureKeyVaultSecret(PromptSecretText, 'BCSustCopilotRawFormulaFunction');
    end;

    procedure GetFormulaBreakdownSystemPrompt() PromptSecretText: SecretText
    begin
        GetAzureKeyVaultSecret(PromptSecretText, 'BCSustCopilotFormulaBreakdownSystemPrompt');
    end;

    procedure GetFormulaBreakdownFunction() PromptSecretText: SecretText
    begin
        GetAzureKeyVaultSecret(PromptSecretText, 'BCSustCopilotFormulaBreakdownFunction');
    end;

    procedure GetMatchCategoryToInputSystemPrompt() PromptSecretText: SecretText
    begin
        GetAzureKeyVaultSecret(PromptSecretText, 'BCSustCopilotMatchCategoryToInputSystemPrompt');
    end;

    procedure GetMatchCategoryToInputFunction() PromptSecretText: SecretText
    begin
        GetAzureKeyVaultSecret(PromptSecretText, 'BCSustCopilotMatchCategoryToInputFunction');
    end;

    internal procedure GetAzureKeyVaultSecret(var SecretValue: SecretText; SecretName: Text)
    var
        SustEmisSuggestionImpl: Codeunit "Sust. Emis. Suggestion Impl.";
        AzureKeyVault: Codeunit "Azure Key Vault";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ErrorMessage: Text;
        CannotGetSecretMsg: Label 'Cannot get secret %1 from Azure Key Vault', Locked = true;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(SecretName, SecretValue) then begin
            ErrorMessage := StrSubstNo(CannotGetSecretMsg, SecretName);
            FeatureTelemetry.LogError('0000PXE', SustEmisSuggestionImpl.GetFeatureName(), 'Get prompt from Key Vault', ErrorMessage);
            Error(ErrorMessage);
        end;
    end;
}