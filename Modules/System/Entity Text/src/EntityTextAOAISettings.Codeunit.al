// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Text;

using System.Globalization;
using System.AI;
using System.Azure.KeyVault;
using System.Environment;


/// <summary>
/// Implements functionality to call Azure OpenAI.
/// </summary>
codeunit 2011 "Entity Text AOAI Settings"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure IsEnabled(Silent: Boolean): Boolean
    var
        EntityText: Record "Entity Text";
        AzureOpenAI: Codeunit "Azure OpenAI";
    begin
        if not GuiAllowed() then begin
            Session.LogMessage('0000LJA', TelemetryGuiNotAllowedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(false);
        end;

        if not IsSupportedLanguage() then begin
            Session.LogMessage('0000JXG', TelemetryUnsupportedLanguageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(false);
        end;

        if not EntityText.WritePermission() then begin
            Session.LogMessage('0000JY0', TelemetryMissingPermissionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(false);
        end;

        if (not Silent) and (not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Entity Text", Silent)) then begin
            Session.LogMessage('0000JVN', TelemetryAOAIDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(false);
        end;

        Session.LogMessage('0000JVP', TelemetryPrivacyResultTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
        exit(true);
    end;

    [NonDebuggable]
    procedure ContainsWordsInDenyList(Completion: Text): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureKeyVault: Codeunit "Azure Key Vault";
        DenyPhrasesText: Text;
        DenyPhrase: Text;
        DenyPhrases: List of [Text];
        DenyPhrasesKeyTok: Label 'AOAI-DenyPhrases', Locked = true;
        TelemetryCompletionDeniedTxt: Label 'The completion was rejected because it contained the phrase ''%1''', Locked = true;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit(false);

        if not AzureKeyVault.GetAzureKeyVaultSecret(DenyPhrasesKeyTok, DenyPhrasesText) then
            exit(false);

        if DenyPhrasesText = '' then
            exit(false);

        DenyPhrases := DenyPhrasesText.Split('|');

        Completion := Completion.ToLower();
        foreach DenyPhrase in DenyPhrases do begin
            DenyPhrase := DenyPhrase.Trim().ToLower();
            if (DenyPhrase <> '') and Completion.Contains(DenyPhrase) then begin
                Session.LogMessage('0000JYH', StrSubstNo(TelemetryCompletionDeniedTxt, DenyPhrase), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure IsSupportedLanguage(): Boolean
    var
        SupportedLanguages: Enum "Entity Text Languages";
        LanguageName: Text;
    begin
        LanguageName := LowerCase(GetLanguageName()).Split(' ').Get(1);

        exit(SupportedLanguages.Names.Contains(LanguageName));
    end;

    procedure GetLanguageName(): Text
    var
        Language: Codeunit Language;
        LanguageValue: Text;
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(1033); // Get the language name in english
        LanguageValue := Language.GetWindowsLanguageName(CurrentLanguage);
        GlobalLanguage(CurrentLanguage);

        exit(LanguageValue);
    end;

    var
        TelemetryCategoryLbl: Label 'AOAI', Locked = true;
        TelemetryAOAIDisabledTxt: Label 'AOAI is disabled for Entity Text.', Locked = true;
        TelemetryPrivacyResultTxt: Label 'AOAI is enabled for Entity Text', Locked = true;
        TelemetryMissingPermissionTxt: Label 'Feature is disabled due to missing write permissions.', Locked = true;
        TelemetryUnsupportedLanguageTxt: Label 'The user is not using a supported language.', Locked = true;
        TelemetryGuiNotAllowedTxt: Label 'Entity Text called in a non-interactive session.', Locked = true;
}