// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///
/// </summary>
codeunit 3711 Translation
{
    Access = Public;

    var
        TranslationImplementation: Codeunit "Translation Implementation";

        /// <summary>
        /// Checks if there any translations present at all.
        /// </summary>
        /// <returns>True if there is at least one translation; false, otherwise.</returns>
    procedure Any(): Boolean
    begin
        exit(TranslationImplementation.Any());
    end;

    /// <summary>
    /// Gets the value of a field in the global language for the record.
    /// </summary>
    /// <param name="Record">The record to get the translated value for.</param>
    /// <param name="FieldId">The ID of the field for which the translation is stored.</param>
    /// <returns>The translated value.</returns>
    /// <example>
    /// To get the value of the description field for an item record, call GetValue(Item, Item.FIELDNO(Description)).
    /// </example>
    /// <remarks>
    /// In case, a translated record for the global language cannot be found, the first translation is returned.
    /// </remarks>
    procedure Get("Record": Variant; FieldId: Integer): Text
    begin
        exit(TranslationImplementation.GetForLanguageOrFirst(Record, FieldId, GlobalLanguage(), true));
    end;

    /// <summary>
    /// Gets the value of a field in the language that is specified for the record.
    /// </summary>
    /// <param name="Record">The record to get the translated value for.</param>
    /// <param name="FieldId">The ID of the field to store the translation for.</param>
    /// <param name="LanguageId">The ID of the language in which to get the field value.</param>
    /// <returns>The translated value.</returns>
    /// <example>
    /// To get the value of the Description field for an item record in Danish, call GetValue(Item, Item.FIELDNO(Description), 1030).
    /// </example>
    procedure GetForLanguage("Record": Variant; FieldId: Integer; LanguageId: Integer): Text
    begin
        exit(TranslationImplementation.GetForLanguage(Record, FieldId, LanguageId));
    end;

    /// <summary>
    /// Sets the value of a field to the global language for the record.
    /// </summary>
    /// <param name="Record">The record to store the translated value for.</param>
    /// <param name="FieldId">The ID of the field to store the translation for.</param>
    /// <param name="Value">The translated value to set.</param>
    procedure Set("Record": Variant; FieldId: Integer; Value: Text[2048])
    begin
        TranslationImplementation.Set(Record, FieldId, Value);
    end;

    /// <summary>
    /// Sets the value of a field to the language specified for the record.
    /// </summary>
    /// <param name="Record">The record to store the translated value for.</param>
    /// <param name="FieldId">The ID of the field to store the translation for.</param>
    /// <param name="LanguageId">The language id to set the value for.</param>
    /// <param name="Value">The translated value to set.</param>
    procedure SetForLanguage("Record": Variant; FieldId: Integer; LanguageId: Integer; Value: Text[2048])
    begin
        TranslationImplementation.SetForLanguage(Record, FieldId, LanguageId, Value);
    end;

    /// <summary>
    /// Deletes all translations for a persisted (non temporary) record.
    /// </summary>
    /// <param name="Record">The record for which the translations are to be deleted.</param>
    procedure Delete("Record": Variant)
    begin
        TranslationImplementation.Delete(Record);
    end;

    /// <summary>
    /// Moves the translations from the old record ID to the new RecordID for a persisted (non temporary) record.
    /// </summary>
    /// <param name="Record">The record which has a new record ID.</param>
    /// <param name="OldRecordID">The old record ID of the record.</param>
    procedure Rename("Record": Variant; OldRecordID: RecordID)
    begin
        TranslationImplementation.Rename(Record, OldRecordID);
    end;

    /// <summary>
    /// Shows all language translations that are available for a field in a new page.
    /// </summary>
    /// <param name="Record">The record to get the translated value for.</param>
    /// <param name="FieldId">The ID of the field to get translations for.</param>
    procedure Show("Record": Variant; FieldId: Integer)
    begin
        TranslationImplementation.Show(Record, FieldId);
    end;

    /// <summary>
    /// Shows all language translations available for a given field for all the records in that table in a new page.
    /// </summary>
    /// <param name="TableId">The table ID to get translations for.</param>
    /// <param name="FieldId">The ID of the field to get translations for.</param>
    procedure ShowForAllRecords(TableId: Integer; FieldId: Integer)
    begin
        TranslationImplementation.ShowForAllRecords(TableId, FieldId);
    end;
}

