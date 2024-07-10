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

    [NonDebuggable]
    internal procedure GetAzureKeyVaultSecret(var SecretValue: Text; SecretName: Text)
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

    [NonDebuggable]
    internal procedure GetSLSSystemPrompt(): SecretText
    var
        BCSLSMetaPrompt: Text;
        BCSLSTaskPrompt: Text;
    begin
        GetAzureKeyVaultSecret(BCSLSMetaPrompt, 'BCSLSMetaPrompt');
        GetAzureKeyVaultSecret(BCSLSTaskPrompt, 'BCSLSTaskPrompt-V250');

        exit(BCSLSMetaPrompt + StrSubstNo(BCSLSTaskPrompt, Format(Today, 0, 4)));
    end;

    [NonDebuggable]
    internal procedure GetSLSDocumentLookupPrompt(): Text
    var
        BCSLSDocumentLookupPrompt: Text;
    begin
        GetAzureKeyVaultSecret(BCSLSDocumentLookupPrompt, 'BCSLSDocumentLookupPrompt');

        exit(BCSLSDocumentLookupPrompt);
    end;

    [NonDebuggable]
    internal procedure GetSLSSearchItemsWithFiltersPrompt(): Text
    var
        BCSLSSearchItemsWithFiltersPrompt: Text;
    begin
        GetAzureKeyVaultSecret(BCSLSSearchItemsWithFiltersPrompt, 'BCSLSSearchItemsWithFiltersPrompt');

        exit(BCSLSSearchItemsWithFiltersPrompt);
    end;

    [NonDebuggable]
    internal procedure GetSLSSearchItemPrompt(): Text
    var
        BCSLSSearchItemPrompt: Text;
    begin
        GetAzureKeyVaultSecret(BCSLSSearchItemPrompt, 'BCSLSSearchItemPrompt');

        exit(BCSLSSearchItemPrompt);
    end;

    [NonDebuggable]
    internal procedure GetSLSMagicFunctionPrompt(): Text
    var
        BCSLSMagicFunctionPrompt: Text;
    begin
        GetAzureKeyVaultSecret(BCSLSMagicFunctionPrompt, 'BCSLSMagicFunctionPrompt');

        exit(BCSLSMagicFunctionPrompt);
    end;

    [NonDebuggable]
    internal procedure GetAttachmentSystemPrompt(): Text
    var
        BCSLSMetaPrompt: Text;
        BCSLSAttachmentTaskPrompt: Text;
    begin
        GetAzureKeyVaultSecret(BCSLSMetaPrompt, 'BCSLSMetaPrompt');
        GetAzureKeyVaultSecret(BCSLSAttachmentTaskPrompt, 'BCSLSAttachmentTaskPrompt');

        exit(BCSLSMetaPrompt + BCSLSAttachmentTaskPrompt);
    end;

    [NonDebuggable]
    internal procedure GetParsingCsvPrompt(): Text
    var
        BCSLSParseCsvPrompt: Text;
    begin
        GetAzureKeyVaultSecret(BCSLSParseCsvPrompt, 'BCSLSParseCsvPrompt');

        exit(BCSLSParseCsvPrompt);
    end;

    [NonDebuggable]
    internal procedure GetParsingCsvTemplateUserInputPrompt(): Text
    var
        BCSLSParseCsvTemplateUserInputPrompt: Text;
    begin
        GetAzureKeyVaultSecret(BCSLSParseCsvTemplateUserInputPrompt, 'BCSLSParseCsvTemplateUserInputPrompt');

        exit(BCSLSParseCsvTemplateUserInputPrompt);
    end;

    [NonDebuggable]
    internal procedure GetProductFromCsvTemplateUserInputPrompt(): Text
    var
        BCSLSGetProductFromCsvTemplateUserInputPrompt: Text;
    begin
        GetAzureKeyVaultSecret(BCSLSGetProductFromCsvTemplateUserInputPrompt, 'BCSLSGetProductFromCsvTemplateUserInputPrompt');

        exit(BCSLSGetProductFromCsvTemplateUserInputPrompt);
    end;

    var
        ConstructingPromptFailedErr: label 'There was an error with sending the call to Copilot. Log a Business Central support request about this.', Comment = 'Copilot is a Microsoft service name and must not be translated';
        TelemetryConstructingPromptFailedErr: label 'There was an error with constructing the chat completion prompt from the Key Vault.', Locked = true;
}