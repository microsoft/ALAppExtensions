// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Text;

/// <summary>
/// Exposes the public functionality for handling entity text.
/// </summary>
codeunit 2010 "Entity Text"
{
    Access = Public;

    var
        EntityTextImpl: Codeunit "Entity Text Impl.";

    /// <summary>
    /// Gets if Entity Text functionality is enabled.
    /// </summary>
    /// <param name="Silent">If this should be evaluated silently.</param>
    /// <returns>True if the functionality is enabled.</returns>
    procedure IsEnabled(Silent: Boolean): Boolean
    begin
        exit(EntityTextImpl.IsEnabled(Silent));
    end;

    /// <summary>
    /// Gets if Entity Text functionality is enabled.
    /// </summary>
    /// <returns>True if the functionality is enabled.</returns>
    procedure IsEnabled(): Boolean
    begin
        exit(IsEnabled(true));
    end;

    /// <summary>
    /// Gets if the Entity Text Suggest functionality is enabled
    /// </summary>
    /// <returns>True if the functionality is enabled.</returns>
    procedure CanSuggest(): Boolean
    begin
        exit(EntityTextImpl.CanSuggest());
    end;

    /// <summary>
    /// Gets the rich text for a given Entity Text.
    /// </summary>
    /// <param name="TableId">The ID of the table for which to retrieve the entity text.</param>
    /// <param name="SystemId">The ID of the entity for which to retrieve the entity text.</param>
    /// <param name="EntityTextScenario">The entity text scenario to retrieve the text for.</param>
    /// <returns>The rich text content of the entity text (or an empty string if it is not found).</returns>
    procedure GetText(TableId: Integer; SystemId: Guid; EntityTextScenario: Enum "Entity Text Scenario"): Text
    begin
        exit(EntityTextImpl.GetText(TableId, SystemId, EntityTextScenario));
    end;

    /// <summary>
    /// Gets the rich text for a given Entity Text.
    /// </summary>
    /// <param name="EntityText">The entity text record to read the text from.</param>
    /// <returns>The rich text content of the entity text.</returns>
    procedure GetText(var EntityText: Record "Entity Text"): Text
    begin
        exit(EntityTextImpl.GetText(EntityText));
    end;

    /// <summary>
    /// Generate Entity Text using AI capabilities.
    /// </summary>
    /// <param name="Facts">The Facts of the Entity used for generation.</param>
    /// <param name="Tone">The tone of the generated text.</param>
    /// <param name="TextFormat">The length and format of the generated text.</param>
    /// <param name="TextEmphasis">Feature to emphasize.</param>
    /// <returns>Generated entity text.</returns>
    procedure GenerateText(Facts: Dictionary of [Text, Text]; Tone: Enum "Entity Text Tone"; TextFormat: Enum "Entity Text Format"; TextEmphasis: Enum "Entity Text Emphasis"): Text
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CurrentModuleInfo);
        exit(EntityTextImpl.GenerateSuggestion(Facts, Tone, TextFormat, TextEmphasis, CurrentModuleInfo));
    end;


    /// <summary>
    /// Updates the Entity Text record with the current text.
    /// </summary>
    /// <param name="EntityText">The entity text record to update.</param>
    /// <param name="EntityTextContent">The new entity text content.</param>
    procedure UpdateText(var EntityText: Record "Entity Text"; EntityTextContent: Text)
    var
        TelemetryCategoryLbl: Label 'Entity Text', Locked = true;
        TelemetryUpdateRecordTxt: Label 'Updating text on record for table %1 and scenario %2.', Locked = true, Comment = '%1 the table id, %2 the scenario id';
    begin
        Session.LogMessage('0000JVL', StrSubstNo(TelemetryUpdateRecordTxt, Format(EntityText."Source Table Id"), Format(EntityText.Scenario)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryLbl);
        EntityTextImpl.SetText(EntityText, EntityTextContent);
    end;

    /// <summary>
    /// Sets AI authorization for the current Entity Text scope.
    /// </summary>
    /// <param name="Endpoint">The endpoint to use.</param>
    /// <param name="Deployment">The deployment to use for the endpoint.</param>
    /// <param name="ApiKey">The API key to use for the endpoint.</param>
    /// <remarks>Endpoint would look like: https://resource-name.openai.azure.com/ 
    /// Deployment would look like: gpt-35-turbo-16k
    /// </remarks>
    procedure SetEntityTextAuthorization(Endpoint: Text; Deployment: Text; ApiKey: SecretText)
    begin
        EntityTextImpl.SetEntityTextAuthorization(Endpoint, Deployment, ApiKey);
    end;

    /// <summary>
    /// Event that is raised to build context for the given entity.
    /// </summary>
    /// <param name="SourceTableId">The ID of the table of the entity.</param>
    /// <param name="SourceSystemId">The ID of the entity.</param>
    /// <param name="SourceScenario">The scenario for which to get context for.</param>
    /// <param name="Facts">A dictionary of facts to provide about the entity. Only the first 20 facts will be used for text generation.</param>
    /// <param name="TextTone">The default tone of text to apply to this entity.</param>
    /// <param name="TextFormat">The default text format to apply to this entity.</param>
    /// <param name="Handled">Set if this scenario was handled.</param>
    /// <remarks>
    /// Subscribers should check against the table id, system id, and scenario before setting the facts, tone, and format. A runtime error will occur if Handled is false.
    /// </remarks>
    [IntegrationEvent(false, false)]
    procedure OnRequestEntityContext(SourceTableId: Integer; SourceSystemId: Guid; SourceScenario: Enum "Entity Text Scenario"; var Facts: Dictionary of [Text, Text]; var TextTone: Enum "Entity Text Tone"; var TextFormat: Enum "Entity Text Format"; var Handled: Boolean)
    begin
    end;

#if not CLEAN24
    /// <summary>
    /// Event that is raised to override the default Edit behavior.
    /// </summary>
    /// <param name="TempEntityText">The Entity Text record to be modified.</param>
    /// <param name="Action">Must be set to the resulting action from the edit page (if handled).</param>
    /// <param name="Handled">If the edit event was handled (set to true even if the action was cancelled).</param>
    /// <remarks>
    /// Subscribers should check the Entity Text primary keys (table id, source id, scenario) if you should handle this record before opening a page.
    /// </remarks>
    [Obsolete('The OnEditEntityText event is now raised with additional parameter, see OnEditEntityTextWithTriggerAction', '24.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnEditEntityText(var TempEntityText: Record "Entity Text" temporary; var Action: Action; var Handled: Boolean)
    begin
    end;
#endif

    /// <summary>
    /// Event that is raised to override the default Edit behavior.
    /// </summary>
    /// <param name="TempEntityText">The Entity Text record to be modified.</param>
    /// <param name="Action">Must be set to the resulting action from the edit page (if handled).</param>
    /// <param name="Handled">If the edit event was handled (set to true even if the action was cancelled).</param>
    /// <param name="TriggerAction">The action that triggered the event.</param>
    /// <remarks>
    /// Subscribers should check the Entity Text primary keys (table id, source id, scenario) if you should handle this record before opening a page.
    /// </remarks>
    [IntegrationEvent(false, false)]
    internal procedure OnEditEntityTextWithTriggerAction(var TempEntityText: Record "Entity Text" temporary; var Action: Action; var Handled: Boolean; TriggerAction: Enum "Entity Text Actions")
    begin
    end;
}