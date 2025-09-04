// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.AI;
using Microsoft.Sustainability.Journal;
using System.Environment;
using System.Telemetry;
using System.Azure.KeyVault;

codeunit 6290 "Sust. Emis. Suggestion Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Telemetry: Codeunit "Telemetry";
        NoSuggestionsMsg: Label 'There are no suggestions for this description. Please rephrase it.';


    procedure GetFeatureName(): Text
    begin
        exit('Sustainability Emission Suggestions');
    end;

    procedure GetNoSustEmissionSuggestionsMsg(): Text
    begin
        exit(NoSuggestionsMsg);
    end;

    procedure CalculateEmissionByCopilot(var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainEmissionSuggestion: Record "Sustain. Emission Suggestion";
        SustainEmissionSuggestionPage: Page "Sustain. Emission Suggestion";
    begin
        if SustainabilityJnlLine.IsEmpty() then
            exit;

        SustainEmissionSuggestionPage.SetData(SustainabilityJnlLine, SustainEmissionSuggestion);
        SustainEmissionSuggestionPage.SetPromptMode(PromptMode::Generate);
        SustainEmissionSuggestionPage.LookupMode(true);
        SustainEmissionSuggestionPage.RunModal();
    end;

    procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        DocUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2261665', Locked = true;
    begin
        if not IsFeatureAvailable() then begin
            Telemetry.LogMessage('0000PXG', 'Sustainability Emission Suggestion feature is not available', Verbosity::Normal, DataClassification::SystemMetadata);
            if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sustainability Emission Suggestion") then
                CopilotCapability.UnregisterCapability(Enum::"Copilot Capability"::"Sustainability Emission Suggestion");
            exit;
        end;
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sustainability Emission Suggestion") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Sustainability Emission Suggestion", DocUrlLbl);
    end;

    [NonDebuggable]
    procedure IsFeatureAvailable(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureKeyVault: Codeunit "Azure Key Vault";
        SecretValue: SecretText;
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit(true);
        if not AzureKeyVault.GetAzureKeyVaultSecret('BCSustCopilotEnabled', SecretValue) then begin
            FeatureTelemetry.LogError('0000PXF', GetFeatureName(), 'Azure KeyVault secret', 'Cannot get BCSustCopilotEnabled key value');
            exit(false);
        end;
        exit(SecretValue.Unwrap().ToUpper() = 'TRUE');
    end;

    procedure IsReadyToUse(): Boolean
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        if not IsFeatureAvailable() then
            exit(false);
        exit(CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sustainability Emission Suggestion"));
    end;

    [EventSubscriber(ObjectType::Page, Page::"Copilot AI Capabilities", 'OnRegisterCopilotCapability', '', false, false)]
    local procedure OnRegisterCopilotCapability()
    begin
        RegisterCapability();
    end;
}
