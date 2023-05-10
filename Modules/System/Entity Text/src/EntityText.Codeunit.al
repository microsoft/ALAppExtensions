// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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

    /// <summary>
    /// Event that is raised to override the default Edit behavior.
    /// </summary>
    /// <param name="TempEntityText">The Entity Text record to be modified.</param>
    /// <param name="Action">Must be set to the resulting action from the edit page (if handled).</param>
    /// <param name="Handled">If the edit event was handled (set to true even if the action was cancelled).</param>
    /// <remarks>
    /// Subscribers should check the Entity Text primary keys (table id, source id, scenario) if you should handle this record before opening a page.
    /// </remarks>
    [IntegrationEvent(false, false)]
    internal procedure OnEditEntityText(var TempEntityText: Record "Entity Text" temporary; var Action: Action; var Handled: Boolean)
    begin
    end;
}