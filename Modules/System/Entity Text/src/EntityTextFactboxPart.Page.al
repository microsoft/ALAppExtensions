// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A card part to use on a factbox to display the entity text.
/// Ensure the SetContext procedure is called OnAfterGetCurrentRecord on the parent page.
/// </summary>
page 2011 "Entity Text Factbox Part"
{
    ApplicationArea = All;
    Caption = 'Entity Text';
    DelayedInsert = true;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    Extensible = false;
    SourceTable = "Entity Text";
    SourceTableTemporary = true;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(EntityTextGroup)
            {
                Caption = 'Entity Text';
                ShowCaption = false;

                field(EntityText; Rec."Preview Text")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Attention;
                    StyleExpr = CanCreate;
                }

                field(EmptyCaption; ComputedEmptyCaption)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                }

                group(SuggestionFeedback)
                {
                    ShowCaption = false;
                    Visible = HasSuggestion;

                    field(ApproveSuggestion; ReviewSuggestionTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            OpenEditPage();
                        end;
                    }

                    field(DismissSuggestion; DismissSuggestionTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            HasSuggestion := false;
                            Rec.DeleteAll();

                            ReloadLatestContext();
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Suggest)
            {
                ApplicationArea = All;
                Caption = 'Create with Copilot';
                Visible = CanCreate;
                Image = Sparkle;
                ToolTip = 'Let Copilot create a new draft';

                trigger OnAction()
                var
                    EntityTextImpl: Codeunit "Entity Text Impl.";
                    AzureOpenAiImpl: Codeunit "Azure OpenAi Impl.";
                    Suggestion: Text;
                begin
                    if not HasContext then
                        Error(ContextNotSetErr);

                    if not AzureOpenAiImpl.IsEnabled(false) then // validates privacy flow
                        exit;

                    Suggestion := EntityTextImpl.GenerateSuggestion(CurrentTableId, CurrentSystemId, CurrentScenario, Enum::"Entity Text Emphasis"::None, CallerModuleInfo);
                    EntityTextImpl.SetText(Rec, Suggestion);
                    Rec.Modify();

                    HasSuggestion := true;
                end;
            }

            action(Edit)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Image = Edit;
                ToolTip = 'Open a dialog to edit the text';

                trigger OnAction()
                begin
                    OpenEditPage();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        UpdateEnabledProperties();

        HasContext := false;
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateEnabledProperties();

        if not HasContext then
            exit;

        ReloadLatestContext();
    end;

    /// <summary>
    /// Sets the context for the Entity Text Factbox Part.
    /// </summary>
    /// <param name="SourceTableId">The ID of the table for which to retrieve the entity text.</param>
    /// <param name="SourceSystemId">The ID of the entity for which to retrieve the entity text.</param>
    /// <param name="SourceScenario">The entity text scenario to retrieve the entity text.</param>
    /// <param name="PlaceholderText">The placeholder text to display if no entity text exists.</param>
    /// <remarks>This must be called when including the part or no entity text will be rendered.</remarks>
    procedure SetContext(SourceTableId: Integer; SourceSystemId: Guid; SourceScenario: Enum "Entity Text Scenario"; PlaceholderText: Text)
    var
        EntityTextRec: Record "Entity Text";
    begin
        HasContext := false;

        CurrentTableId := SourceTableId;
        CurrentSystemId := SourceSystemId;
        CurrentScenario := SourceScenario;

        // Ensure this temp record set only has this entity text
        if not Rec.Get(CompanyName(), SourceTableId, SourceSystemId, SourceScenario) then begin
            HasSuggestion := false;

            Rec.DeleteAll();
            Clear(Rec);
            Rec.Init();
            Rec.Company := CopyStr(CompanyName(), 1, MaxStrLen(Rec.Company));
            Rec."Source Table Id" := SourceTableId;
            Rec."Source System Id" := SourceSystemId;
            Rec.Scenario := SourceScenario;
            Rec.Insert();
        end;

        // No suggestion, load the current value
        if not HasSuggestion then begin
            EntityTextRec.SetRange(Company, CompanyName());
            EntityTextRec.SetRange("Source Table Id", SourceTableId);
            EntityTextRec.SetRange("Source System Id", SourceSystemId);
            EntityTextRec.SetRange(Scenario, SourceScenario);
            if EntityTextRec.FindFirst() then begin
                EntityTextRec.CalcFields(Text);
                Rec.TransferFields(EntityTextRec);
                Rec.Modify();
            end;
        end;

        EmptyCaption := PlaceholderText;
        if EmptyCaption = '' then
            EmptyCaption := DefaultPlaceholderTxt;

        HasContext := true;

        CurrPage.Update(false);

        Session.LogMessage('0000JVC', StrSubstNo(TelemetrySetContextTxt, Format(SourceTableId), Format(SourceScenario), Format(CallerModuleInfo.Id()), CallerModuleInfo.Publisher()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
    end;

    local procedure OpenEditPage()
    var
        TempEntityText: Record "Entity Text" temporary;
        EntityTextCod: Codeunit "Entity Text";
        EntityTextImpl: Codeunit "Entity Text Impl.";
        EntityTextPage: Page "Entity Text";
        Handled: Boolean;
        EditAction: Action;
    begin
        if not HasContext then
            Error(ContextNotSetErr);

        Rec.CalcFields(Text);
        if Rec.IsEmpty() then
            EntityTextImpl.InsertSuggestion(CurrentTableId, CurrentSystemId, CurrentScenario, '', TempEntityText)
        else begin
            TempEntityText.TransferFields(Rec, true);
            TempEntityText.Insert();
        end;

        EntityTextCod.OnEditEntityText(TempEntityText, EditAction, Handled);

        if not Handled then begin
            Session.LogMessage('0000JVA', StrSubstNo(TelemetryFallbackPageTxt, Format(CurrentTableId), Format(CurrentScenario)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            EntityTextPage.SetRecord(TempEntityText);
            EntityTextPage.SetModuleInfo(CallerModuleInfo);
            EntityTextPage.SaveRecord();
            EditAction := EntityTextPage.RunModal();
        end;

        Session.LogMessage('0000JVB', StrSubstNo(TelemetryEditHandledTxt, Format(Handled), Format(EditAction)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);

        if EditAction in [Action::LookupOK, Action::OK] then begin
            EntityTextImpl.InsertSuggestion(CurrentTableId, CurrentSystemId, CurrentScenario, EntityTextImpl.GetText(TempEntityText));
            HasSuggestion := false;
        end;

        ReloadLatestContext();
    end;

    local procedure ReloadLatestContext()
    begin
        if not HasContext then
            Error(ContextNotSetErr);

        SetContext(CurrentTableId, CurrentSystemId, CurrentScenario, EmptyCaption);
    end;

    local procedure UpdateEnabledProperties()
    var
        EntityTextImpl: Codeunit "Entity Text Impl.";
    begin
        CanCreate := EntityTextImpl.CanSuggest();

        if CanCreate then
            ComputedEmptyCaption := EmptyCaption
        else
            ComputedEmptyCaption := NotEnabledPlaceholderTxt;
    end;

    var
        CurrentTableId: Integer;
        CurrentSystemId: Guid;
        CurrentScenario: Enum "Entity Text Scenario";
        HasContext: Boolean;
        EmptyCaption: Text;
        ComputedEmptyCaption: Text;
        CanCreate: Boolean;
        HasSuggestion: Boolean;
        CallerModuleInfo: ModuleInfo;
        NotEnabledPlaceholderTxt: Label 'Select Edit to add text', Comment = 'Edit refers to an action on this part with the same name';
        DefaultPlaceholderTxt: Label '[Create text](). Then review and edit based on your needs.', Comment = 'Text contained in [here]() will be clickable to invoke the suggest action';
        ContextNotSetErr: Label 'The context has not been set on the part. Ensure SetContext has been called from the parent page, contact your partner to fix this.';
        TelemetryCategoryLbl: Label 'Entity Text', Locked = true;
        TelemetryFallbackPageTxt: Label 'No custom page was specified for edit, using the fallback page for table %1 and scneario %2.', Locked = true;
        TelemetryEditHandledTxt: Label 'Edit result was handled: %1, with action %2.', Locked = true;
        TelemetrySetContextTxt: Label 'Context set for entity text factbox. Table %1, scenario %2, calling module %3 (%4).', Locked = true;
        ReviewSuggestionTxt: Label 'Review and save this suggestion';
        DismissSuggestionTxt: Label 'Dismiss';
}