// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Implements functionality to handle text suggestions.
/// </summary>
codeunit 2012 "Entity Text Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure IsEnabled(Silent: Boolean): Boolean
    var
        FeatureKey: Record "Feature Key";
        EntityText: Record "Entity Text";
    begin
        if not FeatureKey.Get('EntityText') then begin
            Session.LogMessage('0000JVD', TelemetryMissingFeatureKeyTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(EntityText.ReadPermission());
        end;

        if FeatureKey.Enabled = FeatureKey.Enabled::"All Users" then begin
            Session.LogMessage('0000JVE', TelemetryFeatureKeyEnabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(EntityText.ReadPermission());
        end;

        Session.LogMessage('0000JVF', TelemetryFeatureKeyDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
        exit(false);
    end;

    procedure CanSuggest(): Boolean
    var
        AzureOpenAiImpl: Codeunit "Azure OpenAi Impl.";
    begin
        if not IsEnabled(true) then
            exit(false);

        if (not AzureOpenAiImpl.IsEnabled(true)) and (not AzureOpenAiImpl.IsPendingPrivacyApproval()) then
            exit(false);

        exit(HasPromptInfo());
    end;

    [NonDebuggable]
    procedure GenerateSuggestion(SourceTableId: Integer; SourceSystemId: Guid; SourceScenario: Enum "Entity Text Scenario"; TextEmphasis: Enum "Entity Text Emphasis"; CallerModuleInfo: ModuleInfo): Text
    var
        EntityText: Codeunit "Entity Text";
        Facts: Dictionary of [Text, Text];
        Tone: Enum "Entity Text Tone";
        TextFormat: Enum "Entity Text Format";
        Prompt: Text;
        Suggestion: Text;
        Handled: Boolean;
    begin
        EntityText.OnRequestEntityContext(SourceTableId, SourceSystemId, SourceScenario, Facts, Tone, TextFormat, Handled);

        if not Handled then
            Error(NoHandlerErr);

        Prompt := BuildPrompt(Facts, Tone, TextFormat, TextEmphasis);
        Suggestion := GenerateAndReviewCompletion(Prompt, TextFormat, Facts, CallerModuleInfo);

        exit(Suggestion);
    end;

    [NonDebuggable]
    procedure GenerateSuggestion(Facts: Dictionary of [Text, Text]; Tone: Enum "Entity Text Tone"; TextFormat: Enum "Entity Text Format"; TextEmphasis: Enum "Entity Text Emphasis"; CallerModuleInfo: ModuleInfo): Text
    var
        Prompt: Text;
        Suggestion: Text;
    begin
        Prompt := BuildPrompt(Facts, Tone, TextFormat, TextEmphasis);

        Suggestion := GenerateAndReviewCompletion(Prompt, TextFormat, Facts, CallerModuleInfo);

        exit(Suggestion);
    end;

    procedure InsertSuggestion(SourceTableId: Integer; SourceSystemId: Guid; SourceScenario: Enum "Entity Text Scenario"; SuggestedText: Text)
    var
        EntityText: Record "Entity Text";
    begin
        InsertSuggestion(SourceTableId, SourceSystemId, SourceScenario, SuggestedText, EntityText);
    end;

    procedure InsertSuggestion(SourceTableId: Integer; SourceSystemId: Guid; SourceScenario: Enum "Entity Text Scenario"; SuggestedText: Text; var EntityText: Record "Entity Text")
    begin
        EntityText.Init();
        EntityText.Company := CopyStr(CompanyName(), 1, MaxStrLen(EntityText.Company));
        EntityText."Source Table Id" := SourceTableId;
        EntityText."Source System Id" := SourceSystemId;
        EntityText.Scenario := SourceScenario;
        SetText(EntityText, SuggestedText);

        if not EntityText.Insert() then
            EntityText.Modify();

        Session.LogMessage('0000JVH', StrSubstNo(TelemetrySuggestionCreatedTxt, Format(SourceTableId), Format(SourceScenario)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
    end;

    procedure SetText(var EntityText: Record "Entity Text"; Content: Text)
    var
        Regex: Codeunit Regex;
        HttpUtility: DotNet HttpUtility;
        OutStr: OutStream;
        ContentNoTags: Text;
        ContentLines: List of [Text];
        ContentLine: Text;
    begin
        Clear(EntityText.Text);
        EntityText.Text.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(Content);

        // naively remove tags
        ContentLines := Regex.Replace(Content, '<br */?>', '\').Split('\');
        foreach ContentLine in ContentLines do begin
            ContentLine := Regex.Replace(ContentLine, '<[^>]+>', '');
            ContentLine := HttpUtility.HtmlDecode(ContentLine);

            if ContentLine <> '' then
                ContentNoTags += ContentLine + '\';
        end;

        ContentNoTags := DelChr(ContentNoTags, '>', ' \');

        EntityText."Preview Text" := CopyStr(ContentNoTags, 1, MaxStrLen(EntityText."Preview Text"));
    end;

    procedure GetText(var EntityText: Record "Entity Text"): Text
    var
        InStr: InStream;
        Result: Text;
    begin
        EntityText.CalcFields(Text);
        EntityText.Text.CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(Result);

        exit(Result);
    end;

    procedure GetText(TableId: Integer; SystemId: Guid; EntityTextScenario: Enum "Entity Text Scenario"): Text
    var
        EntityText: Record "Entity Text";
        Result: Text;
    begin
        if EntityText.Get(CompanyName(), TableId, SystemId, EntityTextScenario) then
            Result := GetText(EntityText);

        exit(Result);
    end;

    [NonDebuggable]
    local procedure BuildPrompt(var Facts: Dictionary of [Text, Text]; Tone: Enum "Entity Text Tone"; TextFormat: Enum "Entity Text Format"; TextEmphasis: Enum "Entity Text Emphasis"): Text
    var
        AzureOpenAiImpl: Codeunit "Azure OpenAi Impl.";
        PromptInfo: JsonObject;
        PromptHints: JsonToken;
        PromptOrder: JsonToken;
        PromptHint: JsonToken;
        HintName: Text;
        Prompt: Text;
        FactsList: Text;
        LanguageName: Text;
        Category: Text;
        NewLineChar: Char;
        PromptIndex: Integer;
    begin
        NewLineChar := 10;
        FactsList := BuildFacts(Facts, Category, TextFormat);
        LanguageName := AzureOpenAiImpl.GetLanguageName();

        PromptInfo := GetPromptInfo();
        PromptInfo.Get('prompt', PromptHints);
        PromptInfo.Get('order', PromptOrder);

        // generate prompt components
        foreach PromptHint in PromptOrder.AsArray() do begin
            HintName := PromptHint.AsValue().AsText();
            if PromptHints.AsObject().Get(HintName, PromptHint) then begin
                // found the hint
                if PromptHint.IsArray() then begin
                    PromptIndex := 0; // default value
                    case HintName of
                        'tone':
                            PromptIndex := Tone.AsInteger();
                        'format':
                            PromptIndex := TextFormat.AsInteger();
                        'emphasis':
                            PromptIndex := TextEmphasis.AsInteger();
                    end;

                    if not PromptHint.AsArray().Get(PromptIndex, PromptHint) then
                        PromptHint.AsArray().Get(0, PromptHint);
                end;

                Prompt += StrSubstNo(PromptHint.AsValue().AsText(), NewLineChar, LanguageName, FactsList, Category);
            end;
        end;

        Session.LogMessage('0000JVG', StrSubstNo(TelemetryPromptSummaryTxt, Format(Facts.Count()), Format(Tone), Format(TextFormat), Format(TextEmphasis), LanguageName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
        exit(Prompt);
    end;

    [NonDebuggable]
    local procedure GetPromptInfo(): JsonObject
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        PromptObject: JsonObject;
        PromptObjectText: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(PromptObjectKeyTxt, PromptObjectText) then
            Error(PromptNotFoundErr);

        if not PromptObject.ReadFrom(PromptObjectText) then
            Error(PromptFormatInvalidErr);

        if (not PromptObject.Contains('prompt')) or (not PromptObject.Contains('order')) then
            Error(PromptFormatMissingPropsErr);

        exit(PromptObject);
    end;

    [TryFunction]
    [NonDebuggable]
    procedure HasPromptInfo()
    begin
        GetPromptInfo();
    end;

    [NonDebuggable]
    local procedure BuildFacts(var Facts: Dictionary of [Text, Text]; var Category: Text; TextFormat: Enum "Entity Text Format"): Text
    var
        FactKey: Text;
        FactValue: Text;
        FactsList: Text;
        NewLineChar: Char;
        MaxFacts: Integer;
        TotalFacts: Integer;
        MaxFactLength: Integer;
    begin
        NewLineChar := 10;
        TotalFacts := Facts.Count();
        if TotalFacts = 0 then
            Error(NoFactsErr);

        if TotalFacts < 2 then
            Error(MinFactsErr);

        if (TotalFacts < 4) and (TextFormat <> TextFormat::Tagline) then
            Error(NotEnoughFactsForFormatErr);

        MaxFacts := 20;
        MaxFactLength := 250;
        if TotalFacts > MaxFacts then
            Session.LogMessage('0000JWA', StrSubstNo(TelemetryPromptManyFactsTxt, Format(Facts.Count()), MaxFacts), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);

        TotalFacts := 0;
        foreach FactKey in Facts.Keys() do begin
            if TotalFacts < MaxFacts then begin
                Facts.Get(FactKey, FactValue);
                FactKey := FactKey.Replace(NewLineChar, '').Trim();
                FactValue := FactValue.Replace(NewLineChar, '').Trim();
                if (Category = '') and FactKey.Contains('Category') then
                    Category := FactValue
                else
                    FactsList += StrSubstNo(FactTemplateTxt, CopyStr(FactKey, 1, MaxFactLength), CopyStr(FactValue, 1, MaxFactLength), NewLineChar);
            end;

            TotalFacts += 1;
        end;

        exit(FactsList);
    end;

    [NonDebuggable]
    local procedure GenerateAndReviewCompletion(Prompt: Text; TextFormat: enum "Entity Text Format"; Facts: Dictionary of [Text, Text]; CallerModuleInfo: ModuleInfo): Text
    var
        Completion: Text;
        MaxAttempts: Integer;
        Attempt: Integer;
    begin
        MaxAttempts := 5;
        for Attempt := 0 to MaxAttempts do begin
            Completion := GenerateCompletion(Prompt, CallerModuleInfo);

            if (not CompletionContainsPrompt(Completion, Prompt)) and IsGoodCompletion(Completion, TextFormat, Facts) then
                exit(Completion);

            Sleep(500);
        end;

        // this completion is of low quality
        Session.LogMessage('0000JYB', TelemetryLowQualityCompletionTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
        if CompletionContainsPrompt(Completion, Prompt) then
            exit('');

        exit('');
    end;

    [NonDebuggable]
    local procedure CompletionContainsPrompt(Completion: Text; Prompt: Text): Boolean
    var
        PromptSentences: List of [Text];
        PromptSentence: Text;
        PromptEnd: Integer;
    begin
        PromptEnd := StrPos(Prompt, ':');

        Prompt := CopyStr(Prompt, 1, PromptEnd); // remove facts
        PromptSentences := Prompt.Split('.');

        Completion := Completion.ToLower();
        foreach PromptSentence in PromptSentences do begin
            PromptSentence := PromptSentence.Trim().ToLower();

            if Completion.Contains(PromptSentence) then begin
                Session.LogMessage('0000JZG', StrSubstNo(TelemetryCompletionHasPromptTxt, PromptSentence), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
                exit(true);
            end;
        end;

        exit(false);
    end;

    [NonDebuggable]
    local procedure IsGoodCompletion(var Completion: Text; TextFormat: enum "Entity Text Format"; Facts: Dictionary of [Text, Text]): Boolean
    var
        TempMatches: Record Matches temporary;
        Regex: Codeunit Regex;
        SplitCompletion: List of [Text];
        FactKey: Text;
        FactValue: Text;
        CandidateNumber: Text;
        MinParagraphWords: Integer;
        FoundNumber: Boolean;
        FormatValid: Boolean;
    begin
        if Completion = '' then begin
            Session.LogMessage('0000JWJ', TelemetryCompletionEmptyTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(false);
        end;

        if Completion.ToLower().StartsWith('tagline:') then begin
            Session.LogMessage('0000JYD', TelemetryTaglineCleanedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            Completion := CopyStr(Completion, 9).Trim();
        end;

        MinParagraphWords := 50;

        FormatValid := true;
        case TextFormat of
            TextFormat::TaglineParagraph:
                begin
                    SplitCompletion := Completion.Split('<br /><br />');
                    FormatValid := SplitCompletion.Count() = 2; // a tagline + paragraph must contain an empty line
                    if FormatValid then
                        FormatValid := SplitCompletion.Get(2).Split(' ').Count() >= MinParagraphWords; // the paragraph must be more than MinParagraphWords words
                end;
            TextFormat::Paragraph:
                FormatValid := (not Completion.Contains('<br /><br />')) and (Completion.Split(' ').Count() >= MinParagraphWords); // multiple paragraphs should be avoided, and must have more than MinParagraphWords words
            TextFormat::Tagline:
                FormatValid := not Completion.Contains('<br />'); // a tagline should not have any newline
            TextFormat::Brief:
                FormatValid := Completion.Contains('<br /><br />') and (Completion.Contains('<br />-') or Completion.Contains('<br />•')); // the brief should contain a pargraph and a list
        end;

        if not FormatValid then begin
            Session.LogMessage('0000JYC', StrSubstNo(TelemetryCompletionInvalidFormatTxt, TextFormat), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            exit(false);
        end;

        // check the facts
        Regex.Match(Completion, '(?<!\S)(\d*\.?\d+)(?!\S)', TempMatches); // extract numbers
        if not TempMatches.FindSet() then
            exit(true); // no numbers to validate

        repeat
            CandidateNumber := TempMatches.ReadValue();
            FoundNumber := false;
            foreach FactKey in Facts.Keys() do
                if not FoundNumber then
                    if FactKey.Contains(CandidateNumber) then
                        FoundNumber := true
                    else begin
                        FactValue := Facts.Get(FactKey);
                        if FactValue.Contains(CandidateNumber) then
                            FoundNumber := true;
                    end;

            if not FoundNumber then begin
                Session.LogMessage('0000JYE', StrSubstNo(TelemetryCompletionInvalidNumberTxt, CandidateNumber), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
                exit(false); // made up number
            end;
        until TempMatches.Next() = 0;

        exit(true);
    end;

    [NonDebuggable]
    local procedure GenerateCompletion(Prompt: Text; CallerModuleInfo: ModuleInfo): Text
    var
        AzureOpenAiImpl: Codeunit "Azure OpenAi Impl.";
        HttpUtility: DotNet HttpUtility;
        Result: Text;
        NewLineChar: Char;
    begin
        NewLineChar := 10;

        Result := AzureOpenAiImpl.GenerateCompletion(Prompt, 250, 0.7, CallerModuleInfo);
        Result := HttpUtility.HtmlEncode(Result);
        Result := Result.Replace(NewLineChar, '<br />');

        exit(Result);
    end;

    var
        PromptObjectKeyTxt: Label 'AOAI-Prompt-22', Locked = true;
        FactTemplateTxt: Label '- %1: %2%3', Locked = true;
        NoFactsErr: Label 'No facts were provided. The entity must have some facts.';
        MinFactsErr: Label 'Not enough facts were provided. At least two facts must be provided.';
        NotEnoughFactsForFormatErr: Label 'Not enough facts were provided for the requested format. At least four facts must be provided.';
        NoHandlerErr: Label 'There was no handler to provide information for this entity. Contact your partner.';
        PromptNotFoundErr: Label 'The prompt definition could not be found.';
        PromptFormatInvalidErr: Label 'The prompt definition is in an invalid format.';
        PromptFormatMissingPropsErr: Label 'Required properties are missing from the prompt definition.';
        TelemetryCategoryLbl: Label 'Entity Text', Locked = true;
        TelemetryMissingFeatureKeyTxt: Label 'Feature key is not defined, Entity Text is enabled.', Locked = true;
        TelemetryFeatureKeyEnabledTxt: Label 'Feature key is enabled, Entity Text is enabled.', Locked = true;
        TelemetryFeatureKeyDisabledTxt: Label 'Feature key is disabled, Entity Text is disabled.', Locked = true;
        TelemetryPromptSummaryTxt: Label 'Prompt has %1 facts, tone: %2, format: %3, emphasis: %4, language: %5.', Locked = true;
        TelemetrySuggestionCreatedTxt: Label 'A new suggestion was generated for table %1, scenario %2', Locked = true;
        TelemetryCompletionEmptyTxt: Label 'The returned completion was empty.', Locked = true;
        TelemetryLowQualityCompletionTxt: Label 'Failed to generate a good quality completion, returning a low quality one.', Locked = true;
        TelemetryCompletionInvalidFormatTxt: Label 'The format %1 was requested, but the completion format did not pass validation.', Locked = true;
        TelemetryCompletionHasPromptTxt: Label 'The completion contains this sentence from the prompt: %1', Locked = true;
        TelemetryTaglineCleanedTxt: Label 'Trimmed a completion', Locked = true;
        TelemetryCompletionInvalidNumberTxt: Label 'A number was found in the completion (%1) that did not exist in the facts.', Locked = true;
        TelemetryPromptManyFactsTxt: Label 'There are %1 facts defined, they will be limited to %2.', Locked = true;
}