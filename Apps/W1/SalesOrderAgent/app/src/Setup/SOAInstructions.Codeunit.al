// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.Azure.KeyVault;
using System.Globalization;
using System.Telemetry;

codeunit 4598 "SOA Instructions"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    local procedure GetAzureKeyVaultSecret(var SecretValue: SecretText; SecretName: Text): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        exit(AzureKeyVault.GetAzureKeyVaultSecret(SecretName, SecretValue));
    end;

    local procedure GetAzureKeyVaultSecretLogTelemetryError(var SecretValue: SecretText; SecretName: Text; TelemetryErrorCode: Text; FeatureName: Text; EventName: Text; ErrorText: Text): Boolean
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if not GetAzureKeyVaultSecret(SecretValue, SecretName) then begin
            FeatureTelemetry.LogError(TelemetryErrorCode, FeatureName, EventName, ErrorText);
            exit(false);
        end;
        exit(true);
    end;

    internal procedure GetSOAInstructions(): SecretText
    var
        InstructionsSecret: SecretText;
    begin
        if not GetAzureKeyVaultSecretLogTelemetryError(InstructionsSecret, 'BCSOAInstructionsV27',
            '0000NKG', GetFeatureName(), 'Get instructions from Key Vault', TelemetryGetInstructionsFailedErr) then
            Error(SOASetupFailedErr);
        exit(InstructionsSecret);
    end;

    internal procedure GetBroaderItemSearchPrompt(): SecretText
    var
        BroaderItemSearchPrompt: SecretText;
    begin
        if not GetAzureKeyVaultSecretLogTelemetryError(BroaderItemSearchPrompt, 'BCSOABroaderItemSearchPromptV27',
            '0000MJE', GetFeatureName(), 'Get prompt from Key Vault', TelemetryGetInstructionsFailedErr) then
            Error(ConstructingPromptFailedErr);
        exit(BroaderItemSearchPrompt);
    end;

    internal procedure GetBroaderItemSearchSystemPrompt(): SecretText
    var
        BroaderItemSearchSystemPrompt: SecretText;
    begin
        if not GetAzureKeyVaultSecretLogTelemetryError(BroaderItemSearchSystemPrompt, GetBroaderItemSearchSystemPromptLbl(),
            '0000MJE', GetFeatureName(), 'Get prompt from Key Vault', TelemetryGetInstructionsFailedErr) then
            Error(ConstructingPromptFailedErr);
        AddCultureToBroaderItemSearchSystemPrompt(BroaderItemSearchSystemPrompt);
        exit(BroaderItemSearchSystemPrompt);
    end;

    [NonDebuggable]
    local procedure AddCultureToBroaderItemSearchSystemPrompt(var Prompt: SecretText)
    var
        SOASetup: Codeunit "SOA Setup";
        AgentSession: Codeunit "Agent Session";
        Language: Codeunit "Language";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        InstructionsText: Text;
        CultureName: Text;
        LanguageCode: Code[10];
        FormatRegion: Text[80];
        LanguageID: Integer;
    begin
        InstructionsText := Prompt.Unwrap();
        SOASetup.GetCommunicationLanguageCodeAndFormat(AgentSession.GetCurrentSessionAgentTaskId(), LanguageCode, FormatRegion);
        if LanguageCode <> '' then begin
            LanguageID := Language.GetLanguageId(LanguageCode);
            CultureName := Language.GetCultureName(LanguageID);
            if not TryFormatInstructionsText(InstructionsText, CultureName) then
                FeatureTelemetry.LogError('0000PN7', GetFeatureName(), GetBroaderItemSearchSystemPromptLbl(), FailedToFormatInstructionsTextErr);
            Prompt := InstructionsText;
        end;
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryFormatInstructionsText(var InstructionsText: Text; CultureName: Text)
    begin
        InstructionsText := StrSubstNo(InstructionsText, CultureName);
    end;

    internal procedure GetBroaderItemSearchSystemPromptLbl(): Text
    begin
        exit('BCSOABroaderItemSearchTaskPromptV27');
    end;

    local procedure GetFeatureName(): Text
    begin
        exit('Sales Order Agent');
    end;

    var
        ConstructingPromptFailedErr: label 'There was an error with sending the call to Copilot. Log a Business Central support request about this.', Comment = 'Copilot is a Microsoft service name and must not be translated';
        TelemetryGetInstructionsFailedErr: label 'There was an error getting instructions from the Key Vault.', Locked = true;
        SOASetupFailedErr: label 'There was an error setting up the Sales Order Copilot. Log a Business Central support request about this.';
        FailedToFormatInstructionsTextErr: label 'Failed to format broader item search instructions text with culture name.', Locked = true;
}