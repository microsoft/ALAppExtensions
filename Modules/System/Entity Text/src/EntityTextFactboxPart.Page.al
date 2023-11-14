// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Text;

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
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Edit)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Image = Edit;
                ToolTip = 'Open a dialog to edit the text';

                trigger OnAction()
                begin
                    OpenEditPage("Entity Text Actions"::Edit);
                end;
            }

            action(Suggest)
            {
                ApplicationArea = All;
                Caption = 'Draft with Copilot';
#pragma warning disable AL0482
                Image = Sparkle;
#pragma warning restore AL0482
                ToolTip = 'Let Copilot create a new draft';

                trigger OnAction()
                var
                    EntityTextImpl: Codeunit "Entity Text Impl.";
                begin
                    if not HasContext then
                        Error(ContextNotSetErr);

                    if not EntityTextImpl.IsEnabled(false) then
                        exit;

                    OpenEditPage("Entity Text Actions"::Create);
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

    local procedure OpenEditPage(SourceAction: Enum "Entity Text Actions")
    var
        TempEntityText: Record "Entity Text" temporary;
        EntityTextCod: Codeunit "Entity Text";
        EntityTextImpl: Codeunit "Entity Text Impl.";
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

        EntityTextCod.OnEditEntityTextWithTriggerAction(TempEntityText, EditAction, Handled, SourceAction);

        if not Handled then begin
            Session.LogMessage('0000LJ4', StrSubstNo(TelemetryNoEditPageTxt, Format(CurrentTableId), Format(CurrentScenario)), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
            Error(NoHandlerErr);
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
        NoHandlerErr: Label 'There was no handler to provide an edit page for this entity. Contact your partner.';
        TelemetryNoEditPageTxt: Label 'No custom page was specified for edit by partner: table %1, scenario %2.', Locked = true;
        TelemetryEditHandledTxt: Label 'Edit result was handled: %1, with action %2.', Locked = true;
        TelemetrySetContextTxt: Label 'Context set for entity text factbox. Table %1, scenario %2, calling module %3 (%4).', Locked = true;
}