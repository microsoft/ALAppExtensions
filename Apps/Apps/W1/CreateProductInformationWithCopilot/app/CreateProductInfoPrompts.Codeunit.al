// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item.Substitution;

using System.Azure.KeyVault;
using System.Telemetry;

codeunit 7340 "Create Product Info. Prompts"
{
    Access = Internal;

    [NonDebuggable]
    internal procedure GetAzureKeyVaultSecret(var SecretValue: Text; SecretName: Text)
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ItemSubstSuggestUtility: Codeunit "Create Product Info. Utility";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(SecretName, SecretValue) then begin
            FeatureTelemetry.LogError('0000MJE', ItemSubstSuggestUtility.GetFeatureName(), 'Get prompt from Key Vault', TelemetryConstructingPromptFailedErr);
            Error(ConstructingPromptFailedErr);
        end;
    end;

    [NonDebuggable]
    internal procedure GetSuggestSubstitutionsSystemPrompt(): SecretText
    var
        MetaPrompt: Text;
        TaskPrompt: Text;
    begin
        GetAzureKeyVaultSecret(MetaPrompt, 'BCCPIMetaPrompt');
        GetAzureKeyVaultSecret(TaskPrompt, 'BCCPISuggestSubstTaskPrompt');

        exit(MetaPrompt + StrSubstNo(TaskPrompt, Format(Today, 0, 4)));
    end;

    [NonDebuggable]
    internal procedure GetSuggestSubstitutionsPrompt(): Text
    var
        SuggestSubstitutionsPrompt: Text;
    begin
        GetAzureKeyVaultSecret(SuggestSubstitutionsPrompt, 'BCCPISuggestSubstPrompt');

        exit(SuggestSubstitutionsPrompt);
    end;

    [NonDebuggable]
    internal procedure GetMagicFunctionPrompt(): Text
    var
        MagicFunctionPrompt: Text;
    begin
        GetAzureKeyVaultSecret(MagicFunctionPrompt, 'BCCPIMagicFunctionPrompt');

        exit(MagicFunctionPrompt);
    end;

    var
        ConstructingPromptFailedErr: label 'There was an error with sending the call to Copilot. Log a Business Central support request about this.', Comment = 'Copilot is a Microsoft service name and must not be translated';
        TelemetryConstructingPromptFailedErr: label 'There was an error with constructing the chat completion prompt from the Key Vault.', Locked = true;
}