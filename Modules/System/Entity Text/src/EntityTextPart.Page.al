// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A reusable component to modify entity texts with a rich text editor.
/// See the "Entity Text" page for an example implementation.
/// </summary>
page 2012 "Entity Text Part"
{
    ApplicationArea = All;
    Caption = 'Entity Text Part';
    DelayedInsert = true;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    Extensible = false;

    layout
    {
        area(content)
        {
            group(EntityTextGroup)
            {
                ShowCaption = false;

                field("Entity Text Editor"; EntityTextContent)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    CaptionClass = ContentCaption;
                    ToolTip = 'Specifies the rich text content of the text.';
                    Style = Attention;
                    StyleExpr = CanCreate;

                    trigger OnValidate()
                    begin
                        PushHistory();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Create)
            {
                ShowAs = SplitButton;
                Image = SparkleFilled;
                Caption = 'Create';

                action(CreateDraft)
                {
                    ApplicationArea = All;
                    Caption = 'Create draft';
                    Image = SparkleFilled;
                    ToolTip = 'Let Copilot create a new draft that replaces the current text';
                    Visible = CanCreate;

                    trigger OnAction()
                    var
                        EntityTextImpl: Codeunit "Entity Text Impl.";
                    begin
                        EntityTextContent := EntityTextImpl.GenerateSuggestion(Facts, TextTone, TextFormat, TextEmphasis, CallerModuleInfo);

                        PushHistory();
                    end;
                }

                action(AppendDraft)
                {
                    ApplicationArea = All;
                    Caption = 'Create and append draft';
                    Image = SparkleFilled;
                    ToolTip = 'Let Copilot create and append a draft to the current text';
                    Visible = CanCreate;

                    trigger OnAction()
                    var
                        EntityTextImpl: Codeunit "Entity Text Impl.";
                        TextPrefix: Text;
                    begin
                        if EntityTextContent <> '' then
                            TextPrefix := '<br /><br />';

                        EntityTextContent += TextPrefix + EntityTextImpl.GenerateSuggestion(Facts, TextTone, TextFormat, TextEmphasis, CallerModuleInfo);

                        PushHistory();
                    end;
                }
            }

            group(ToggleAdvancedOptions)
            {
                ShowAs = SplitButton;
                Image = SetupFluent;
                Caption = 'Settings';

                action(ShowOptions)
                {
                    ApplicationArea = All;
                    Caption = 'More settings';
                    Image = SetupFluent;
                    ToolTip = 'Show extra settings related to how Copilot creates text';
                    Visible = HasAdvancedOptions and (not AdvancedOptionsVisible);

                    trigger OnAction()
                    begin
                        AdvancedOptionsVisible := true;
                        CurrPage.Update();
                    end;
                }

                action(HideOptions)
                {
                    ApplicationArea = All;
                    Caption = 'Hide settings';
                    Image = SetupFluent;
                    ToolTip = 'Hide the extra settings related to how Copilot creates text';
                    Visible = HasAdvancedOptions and AdvancedOptionsVisible;

                    trigger OnAction()
                    begin
                        AdvancedOptionsVisible := false;
                        CurrPage.Update();
                    end;
                }
            }

            action(Undo)
            {
                ApplicationArea = All;
                Caption = 'Undo';
                Image = UndoFluent;
                Enabled = HasHistory;
                ToolTip = 'Undo the latest creation or clearing of the text';
                Visible = CanCreate;

                trigger OnAction()
                begin
                    HistoryIndex += 1;
                    EntityTextContent := TextHistory.Get(HistoryIndex);

                    if HistoryIndex >= TextHistory.Count() then
                        HasHistory := false;
                end;
            }

            action(Redo)
            {
                ApplicationArea = All;
                Caption = 'Redo';
                Image = RedoFluent;
                Enabled = HistoryIndex > 1;
                ToolTip = 'Redo the latest creation or clearing of the text';
                Visible = CanCreate;

                trigger OnAction()
                begin
                    HistoryIndex -= 1;
                    EntityTextContent := TextHistory.Get(HistoryIndex);
                    HasHistory := true;
                end;
            }

            action(ClearText)
            {
                ApplicationArea = All;
                Caption = 'Clear text';
                Image = RejectFluent;
                ToolTip = 'Clears the text';
                Visible = CanCreate;

                trigger OnAction()
                begin
                    Clear(EntityTextContent);

                    PushHistory();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        if ContentCaption = '' then
            ContentCaption := ContentLbl;
    end;

    /// <summary>
    /// Sets the context for the Entity Text Page Part.
    /// </summary>
    /// <param name="InitialText">The initial text to set in the rich text editor.</param>
    /// <param name="InitialFacts">The initial facts to use for suggesting text.</param>
    /// <param name="InitialTextTone">The initial tone of text to use for suggesting text.</param>
    /// <param name="InitialTextFormat">The initial text format to use for suggesting text.</param>
    /// <remarks>Text cannot be suggested without calling SetContext.</remarks>
    procedure SetContext(InitialText: Text; var InitialFacts: Dictionary of [Text, Text]; var InitialTextTone: Enum "Entity Text Tone"; var InitialTextFormat: Enum "Entity Text Format")
    var
        EntityTextImpl: Codeunit "Entity Text Impl.";
        CurrentModuleInfo: ModuleInfo;
        EntityTextModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CurrentModuleInfo);
        NavApp.GetCurrentModuleInfo(EntityTextModuleInfo);

        if CurrentModuleInfo.Id() <> EntityTextModuleInfo.Id() then
            CallerModuleInfo := CurrentModuleInfo;

        Session.LogMessage('0000JVK', StrSubstNo(TelemetrySetContextTxt, Format(CallerModuleInfo.Id()), CallerModuleInfo.Publisher()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);

        Facts := InitialFacts;
        TextTone := InitialTextTone;
        TextFormat := InitialTextFormat;

        EntityTextContent := InitialText;

        HistoryIndex := 1;
        HasHistory := false;
        Clear(TextHistory);
        PushHistory();

        CanCreate := (Facts.Count() > 1) and EntityTextImpl.CanSuggest();
    end;

    /// <summary>
    /// Sets the facts used for text suggestion.
    /// </summary>
    /// <param name="NewFacts">The new facts to use.</param>
    procedure SetFacts(NewFacts: Dictionary of [Text, Text])
    begin
        Facts := NewFacts;
    end;

    /// <summary>
    /// Sets the text tone used for text suggestion.
    /// </summary>
    /// <param name="NewTextTone">The new text tone to use.</param>
    procedure SetTextTone(NewTextTone: Enum "Entity Text Tone")
    begin
        TextTone := NewTextTone;
    end;

    /// <summary>
    /// Sets the text format used for text suggestion.
    /// </summary>
    /// <param name="NewTextFormat">The new text format to use.</param>
    procedure SetTextFormat(NewTextFormat: Enum "Entity Text Format")
    begin
        TextFormat := NewTextFormat;
    end;

    /// <summary>
    /// Sets the text emphasis used for text suggestion.
    /// </summary>
    /// <param name="NewTextEmphasis">The new text emphasis to use.</param>
    procedure SetTextEmphasis(NewTextEmphasis: Enum "Entity Text Emphasis")
    begin
        TextEmphasis := NewTextEmphasis;
    end;

    /// <summary>
    /// Sets whether the parent page has advanced options used for text suggestion.
    /// </summary>
    /// <param name="NewHasAdvancedOptions">If the parent page has advanced options to use.</param>
    procedure SetHasAdvancedOptions(NewHasAdvancedOptions: Boolean)
    begin
        HasAdvancedOptions := NewHasAdvancedOptions;
    end;

    /// <summary>
    /// Gets whether the advanced options should be visible.
    /// </summary>
    /// <returns>True if the advanced options should be shown.</returns>
    /// <remarks>
    /// If the parent page has advanced options, it is recommended to check this OnAfterGetCurrRecord.
    /// Additionally, UpdatePropagation should be set to Both on the part.
    /// This way, the part can notify the parent when the state changes.
    /// </remarks>
    procedure ShowAdvancedOptions(): Boolean
    begin
        exit(AdvancedOptionsVisible);
    end;

    /// <summary>
    /// Updates the Entity Text record with the current text.
    /// </summary>
    /// <param name="EntityText">The entity text record to update.</param>
    procedure UpdateRecord(var EntityText: Record "Entity Text")
    var
        EntityTextImpl: Codeunit "Entity Text Impl.";
    begin
        Session.LogMessage('0000JVL', StrSubstNo(TelemetryUpdateRecordTxt, Format(EntityText."Source Table Id"), Format(EntityText.Scenario)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
        EntityTextImpl.SetText(EntityText, EntityTextContent);
    end;

    /// <summary>
    /// Sets the field caption on the rich text editor.
    /// </summary>
    /// <param name="NewCaption">The caption to use.</param>
    /// <remarks>The caption specified here will also be used for the placeholder text in the editor if it is empty.</remarks>
    procedure SetContentCaption(NewCaption: Text)
    begin
        ContentCaption := NewCaption;
    end;

    internal procedure SetModuleInfo(NewModuleInfo: ModuleInfo)
    var
        CurrentModuleInfo: ModuleInfo;
        EntityTextModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(EntityTextModuleInfo);
        NavApp.GetCallerModuleInfo(CurrentModuleInfo);

        Session.LogMessage('0000JVM', StrSubstNo(TelemetrySetModuleTxt, Format(NewModuleInfo.Id()), NewModuleInfo.Publisher(), Format(CurrentModuleInfo.Id()), CurrentModuleInfo.Publisher()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);

        if CurrentModuleInfo.Id() <> EntityTextModuleInfo.Id() then
            exit;

        CallerModuleInfo := NewModuleInfo;
    end;

    local procedure PushHistory()
    begin
        // Reset the future
        if HistoryIndex > 1 then
            TextHistory.RemoveRange(1, HistoryIndex - 1);

        HistoryIndex := 1;
        if HasCreatedHistory() then
            TextHistory.Insert(HistoryIndex, EntityTextContent);

        HasHistory := TextHistory.Count() > HistoryIndex;
    end;

    local procedure HasCreatedHistory(): Boolean
    var
        CandidateEntityTextContent: Text;
        HistoryTextContent: Text;
    begin
        if TextHistory.Count() < 1 then
            exit(true);

        // handle "empty" placeholder text from the RTE
        CandidateEntityTextContent := EntityTextContent;
        if EntityTextContent = '<div><br></div>' then
            CandidateEntityTextContent := '';

        HistoryTextContent := TextHistory.Get(HistoryIndex);
        if HistoryTextContent = '<div><br></div>' then
            HistoryTextContent := '';

        exit(CandidateEntityTextContent <> HistoryTextContent);
    end;

    var
        Facts: Dictionary of [Text, Text];
        TextTone: Enum "Entity Text Tone";
        TextFormat: Enum "Entity Text Format";
        TextEmphasis: Enum "Entity Text Emphasis";
        EntityTextContent: Text;
        HistoryIndex: Integer;
        TextHistory: List of [Text];
        HasHistory: Boolean;
        CanCreate: Boolean;
        CallerModuleInfo: ModuleInfo;
        AdvancedOptionsVisible: Boolean;
        HasAdvancedOptions: Boolean;
        ContentCaption: Text;
        ContentLbl: Label 'Content';
        TelemetryCategoryLbl: Label 'Entity Text', Locked = true;
        TelemetrySetContextTxt: Label 'Context set for the entity text edit page. Calling module %1 (%2).', Locked = true, Comment = '%1 = the app id, %2 = the publisher name';
        TelemetrySetModuleTxt: Label 'Attempting to update the calling module to %1 (%2). This was requested by %3 (%4).', Locked = true, Comment = '%1 the new app id, %2 the new publisher, %3 the calling app id, %4 the calling publisher';
        TelemetryUpdateRecordTxt: Label 'Updating text on record for table %1 and scenario %2.', Locked = true, Comment = '%1 the table id, %2 the scenario id';
}