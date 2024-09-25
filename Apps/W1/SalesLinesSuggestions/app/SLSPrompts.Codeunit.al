// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using System.Azure.KeyVault;
using System.Telemetry;

codeunit 7276 "SLS Prompts"
{
    Access = Internal;

    internal procedure GetAzureKeyVaultSecret(var SecretValue: SecretText; SecretName: Text)
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(SecretName, SecretValue) then begin
            FeatureTelemetry.LogError('0000MJE', SalesLineAISuggestionImpl.GetFeatureName(), 'Get prompt from Key Vault', TelemetryConstructingPromptFailedErr);
            Error(ConstructingPromptFailedErr);
        end;
    end;

    internal procedure GetSLSSystemPrompt(): SecretText
    var
        BCSLSMetaPrompt: SecretText;
        BCSLSTaskPrompt: SecretText;
    begin
        GetAzureKeyVaultSecret(BCSLSMetaPrompt, 'BCSLSMetaPrompt-V250');
        GetAzureKeyVaultSecret(BCSLSTaskPrompt, 'BCSLSTaskPrompt-V250');

        exit(SecretStrSubstNo('%1%2', BCSLSMetaPrompt, AddDateToTaskPrompt(BCSLSTaskPrompt)));
    end;

    internal procedure GetSLSSearchItemsWithFiltersPrompt(): SecretText
    var
        BCSLSSearchItemsWithFiltersPrompt: SecretText;
    begin
        GetAzureKeyVaultSecret(BCSLSSearchItemsWithFiltersPrompt, 'BCSLSSearchItemsWithFiltersPrompt');

        exit(BCSLSSearchItemsWithFiltersPrompt);
    end;

    internal procedure GetSLSMagicFunctionPrompt(): SecretText
    var
        BCSLSMagicFunctionPrompt: SecretText;
    begin
        GetAzureKeyVaultSecret(BCSLSMagicFunctionPrompt, 'BCSLSMagicFunctionPrompt');

        exit(BCSLSMagicFunctionPrompt);
    end;

    internal procedure GetAttachmentSystemPrompt(): SecretText
    var
        BCSLSAttachmentMetaPrompt: SecretText;
        BCSLSAttachmentTaskPrompt: SecretText;
    begin
        GetAzureKeyVaultSecret(BCSLSAttachmentMetaPrompt, 'BCSLSAttachmentMetaPrompt');
        GetAzureKeyVaultSecret(BCSLSAttachmentTaskPrompt, 'BCSLSAttachmentTaskPrompt');

        exit(SecretStrSubstNo('%1%2', BCSLSAttachmentMetaPrompt, BCSLSAttachmentTaskPrompt));
    end;

    internal procedure GetParsingCsvPrompt(): SecretText
    var
        BCSLSParseCsvPrompt: SecretText;
    begin
        GetAzureKeyVaultSecret(BCSLSParseCsvPrompt, 'BCSLSParseCsvPrompt');

        exit(BCSLSParseCsvPrompt);
    end;

    internal procedure GetProductFromCsvTemplateUserInputPrompt(): SecretText
    var
        BCSLSGetProductFromCsvTemplateUserInputPrompt: SecretText;
    begin
        GetAzureKeyVaultSecret(BCSLSGetProductFromCsvTemplateUserInputPrompt, 'BCSLSGetProductFromCsvTemplateUserInputPrompt');

        exit(BCSLSGetProductFromCsvTemplateUserInputPrompt);
    end;

    [NonDebuggable]
    local procedure AddDateToTaskPrompt(BCSLSTaskPrompt: SecretText): SecretText
    begin
        exit(StrSubstNo(BCSLSTaskPrompt.Unwrap(), Format(Today, 0, 4)));
    end;

    var
        ConstructingPromptFailedErr: label 'There was an error with sending the call to Copilot. Log a Business Central support request about this.', Comment = 'Copilot is a Microsoft service name and must not be translated';
        TelemetryConstructingPromptFailedErr: label 'There was an error with constructing the chat completion prompt from the Key Vault.', Locked = true;
}