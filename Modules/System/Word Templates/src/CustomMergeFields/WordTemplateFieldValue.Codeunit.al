// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Word;

/// <summary>
/// Provides an interface to define custom field values for Word Templates
/// </summary>
codeunit 9983 "Word Template Field Value"
{
    Access = Public;

    var
        WordTemplateFieldValueImpl: Codeunit "Word Template Field Value Impl";

    /// <summary>
    /// Get the record that we are currently merging into the word document.
    /// </summary>
    /// <returns>RecordRef to the current record.</returns>
    procedure GetRecord(): RecordRef
    begin
        exit(WordTemplateFieldValueImpl.GetRecord());
    end;

    /// <summary>
    /// Set the value of a specific field. The field must already have been added in the Word Template Custom Fields codeunit.
    /// </summary>
    /// <param name="CustomFieldName">Name of the custom field, which was already specified in the Word Template Custom Fields codeunit.</param>
    /// <param name="CustomFieldValue">Value of this field for the current record.</param>
    procedure AddFieldValue(CustomFieldName: Text; CustomFieldValue: Text[2048])
    begin
        WordTemplateFieldValueImpl.AddField(CustomFieldName, CustomFieldValue);
    end;

    /// <summary>
    /// Set the valid fields users can add values for.
    /// This table includes fields for all related tables as well, with appropriate RelatedTableCode.
    /// </summary>
    /// <param name="NewTempWordTemplateCustomField">Table containing fields the customer can add values for.</param>
    internal procedure Initialize(var NewTempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    begin
        WordTemplateFieldValueImpl.Initialize(NewTempWordTemplateCustomField);
    end;

    /// <summary>
    /// Sets the record that users can add field values for (the valid fields themselves are defined in Initialize).
    /// Also clears out all current values for the record.
    /// </summary>
    /// <param name="RecordRef">Record that is being merged.</param>
    /// <param name="RelatedTableCode">The code for the table that is being merged, used to filter valid fields.</param>
    internal procedure SetCurrentRecord(RecordRef: RecordRef; RelatedTableCode: Code[5])
    begin
        WordTemplateFieldValueImpl.SetCurrentRecord(RecordRef, RelatedTableCode);
    end;

    /// <summary>
    /// Get the table containing all custom field names and values that has been added above.
    /// </summary>
    /// <param name="CurrentTempWordTemplateCustomField">Table containing all custom field names and values.</param>
    internal procedure GetCurrentCustomValues(var CurrentTempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    begin
        WordTemplateFieldValueImpl.GetCurrentCustomValues(CurrentTempWordTemplateCustomField);
    end;
}