// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides an interface to define custom fields for Word Templates
/// </summary>
codeunit 9981 "Word Template Custom Field"
{
    Access = Public;

    var
        WordTemplateCustFieldImpl: Codeunit "Word Template Cust. Field Impl";

    /// <summary>
    /// Get the current table id. This is the table that you want to add fields for.
    /// </summary>
    /// <returns>The current table id.</returns>
    procedure GetTableID(): Integer
    begin
        exit(WordTemplateCustFieldImpl.GetTableID());
    end;

    /// <summary>
    /// Add this custom field to word templates using the given table id.
    /// </summary>
    /// <param name="CustomFieldName">Name of the custom field.</param>
    procedure AddField(CustomFieldName: Text[20])
    begin
        WordTemplateCustFieldImpl.AddField(CustomFieldName);
    end;

    /// <summary>
    /// Set the context that users are supposed to add tables to. Ex. Customer table.
    /// </summary>
    /// <param name="TableId">Table id, Ex. Database::Customer</param>
    /// <param name="RelatedTableCode">The code that is being used for this table.</param>
    internal procedure SetCurrentTableId(TableId: Integer; RelatedTableCode: Code[5])
    begin
        WordTemplateCustFieldImpl.SetCurrentTableId(TableId, RelatedTableCode);
    end;

    /// <summary>
    /// Set the context that users are supposed to add tables to. Ex. Customer table.
    /// </summary>
    /// <param name="TableId">Table id, Ex. Database::Customer</param>
    internal procedure SetCurrentTableId(TableId: Integer)
    begin
        WordTemplateCustFieldImpl.SetCurrentTableId(TableId, '');
    end;

    /// <summary>
    /// Get the table containing all custom field names that has been added above.
    /// </summary>
    /// <param name="TempWordTemplateCustomField">Table containing all custom field names.</param>
    internal procedure GetCustomFields(var TempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    begin
        WordTemplateCustFieldImpl.GetCustomFields(TempWordTemplateCustomField);
    end;
}