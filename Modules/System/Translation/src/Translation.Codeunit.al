// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes function\alitys to add and retrieve translated texts for table fields.
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
    /// <param name="RecVariant">The record to get the translated value for.</param>
    /// <param name="FieldId">The ID of the field for which the translation is stored.</param>
    /// <returns>The translated value.</returns>
    /// <error>If the RecVariant parameter is the type Record, and it is temporary.</error>
    /// <error>If the RecVariant parameter is the type Record, and the table number is 0.</error>
    /// <example>
    /// To get the value of the description field for an item record, call GetValue(Item, Item.FIELDNO(Description)).
    /// </example>
    /// <remarks>
    /// If a translated record for the global language cannot be found it finds the Windows language translation.
    /// If a Windows language translation cannot be found, return an empty string.
    /// </remarks>
    procedure Get(RecVariant: Variant; FieldId: Integer): Text
    begin
        exit(TranslationImplementation.Get(RecVariant, FieldId, GlobalLanguage(), true));
    end;

    /// <summary>
    /// Gets the value of a field in the language that is specified for the record.
    /// </summary>
    /// <param name="RecVariant">The record to get the translated value for.</param>
    /// <param name="FieldId">The ID of the field to store the translation for.</param>
    /// <param name="LanguageId">The ID of the language in which to get the field value.</param>
    /// <returns>The translated value.</returns>
    /// <error>If the RecVariant parameter is the type Record, and it is temporary.</error>
    /// <error>If the RecVariant parameter is the type Record, and the table number is 0.</error>
    /// <example>
    /// To get the value of the Description field for an item record in Danish, call GetValue(Item, Item.FIELDNO(Description), 1030).
    /// </example>
    procedure Get(RecVariant: Variant; FieldId: Integer; LanguageId: Integer): Text
    begin
        exit(TranslationImplementation.Get(RecVariant, FieldId, LanguageId));
    end;

    /// <summary>
    /// Sets the value of a field to the global language for the record.
    /// </summary>
    /// <param name="RecVariant">The record to store the translated value for.</param>
    /// <param name="FieldId">The ID of the field to store the translation for.</param>
    /// <param name="Value">The translated value to set.</param>
    /// <error>If the RecVariant parameter is the type Record, and it is temporary.</error>
    /// <error>If the RecVariant parameter is the type Record, and the table number is 0.</error>
    procedure Set(RecVariant: Variant; FieldId: Integer; Value: Text[2048])
    begin
        TranslationImplementation.Set(RecVariant, FieldId, Value);
    end;

    /// <summary>
    /// Sets the value of a field to the language specified for the record.
    /// </summary>
    /// <param name="RecVariant">The record to store the translated value for.</param>
    /// <param name="FieldId">The ID of the field to store the translation for.</param>
    /// <param name="LanguageId">The language id to set the value for.</param>
    /// <param name="Value">The translated value to set.</param>
    /// <error>If the RecVariant parameter is the type Record, and it is temporary.</error>
    /// <error>If the RecVariant parameter is the type Record, and the table number is 0.</error>
    procedure Set(RecVariant: Variant; FieldId: Integer; LanguageId: Integer; Value: Text[2048])
    begin
        TranslationImplementation.Set(RecVariant, FieldId, LanguageId, Value);
    end;

    /// <summary>
    /// Deletes all translations for a persisted (non temporary) record.
    /// </summary>
    /// <param name="RecVariant">The record for which the translations will be deleted.</param>
    /// <error>If the RecVariant parameter is the type Record, and it is temporary.</error>
    /// <error>If the RecVariant parameter is the type Record, and the table number is 0.</error>
    procedure Delete(RecVariant: Variant)
    begin
        TranslationImplementation.Delete(RecVariant);
    end;

    /// <summary>
    /// Deletes the translation for a field on a persisted (non temporary) record.
    /// </summary>
    /// <param name="RecVariant">The record with a field for which the translation will be deleted.</param>
    /// <param name="FieldId">Id of the field for which the translation will be deleted.</param>
    /// <error>If the RecVariant parameter is the type Record, and it is temporary.</error>
    /// <error>If the RecVariant parameter is the type Record, and the table number is 0.</error>
    procedure Delete(RecVariant: Variant; FieldId: Integer)
    begin
        TranslationImplementation.Delete(RecVariant, FieldId);
    end;

    /// <summary>
    /// Deletes all the translation for a table ID.
    /// </summary>
    /// <param name="TableID">The table that the translations will be deleted for.</param>
    procedure Delete(TableID: Integer)
    begin
        TranslationImplementation.Delete(TableID);
    end;

    /// <summary>
    /// Copies the translation for a field from one record to another record on a persisted (non-temporary) record.
    /// </summary>
    /// <param name="FromRecVariant">The record from which the translations are copied.</param>
    /// <param name="ToRecVariant">The record to which the translations are copied.</param>
    /// <error>If the RecVariant parameter is of type Record, and it is temporary.</error>
    /// <error>If the RecVariant parameter is of type Record, and the table number is 0.</error>
    /// <error>If the FromRecVariant parameter is of type Record, the ToRecVariant parameter is of type Record and they are different.</error> 
    procedure Copy(FromRecVariant: Variant; ToRecVariant: Variant)
    begin
        TranslationImplementation.Copy(FromRecVariant, ToRecVariant, 0);
    end;

    /// <summary>
    /// Copies the translation for a field from one record to another record on a persisted (non-temporary) record.
    /// </summary>
    /// <param name="FromRecVariant">The record from which the translations are copied.</param>
    /// <param name="ToRecVariant">The record to which the translations are copied.</param>
    /// <param name="FieldId">Id of the field for which the translation will be copied.</param>
    /// <error>If the RecVariant parameter is of type Record, and it is temporary.</error>
    /// <error>If the RecVariant parameter is of type Record, and the table number is 0.</error>
    /// <error>If the FromRecVariant parameter is of type Record, the ToRecVariant parameter is of type Record and they are different.</error> 
    /// <error>If RecVariant passed is not of type Record.</error>
    /// <error>If the FieldId is 0.</error>
    procedure Copy(FromRecVariant: Variant; ToRecVariant: Variant; FieldId: Integer)
    begin
        TranslationImplementation.Copy(FromRecVariant, ToRecVariant, FieldId);
    end;

    /// <summary>
    /// Copies the translation from one record's field to another record's field on a persisted (non-temporary) record.
    /// </summary>
    /// <param name="FromRecVariant">The record from which the translations are copied.</param>
    /// <param name="FromFieldId">The id of the field from which the translations are copied.</param>
    /// <param name="ToRecVariant">The record to which the translations are copied.</param>
    /// <param name="ToFieldId">The id of the field to which the translations are copied.</param>
    procedure Copy(FromRecVariant: Variant; FromFieldId: Integer; ToRecVariant: Variant; ToFieldId: Integer)
    begin
        TranslationImplementation.Copy(FromRecVariant, FromFieldId, ToRecVariant, ToFieldId);
    end;

    /// <summary>
    /// Shows all language translations that are available for a field in a new page.
    /// </summary>
    /// <param name="RecVariant">The record to get the translated value for.</param>
    /// <param name="FieldId">The ID of the field to get translations for.</param>
    /// <error>If the RecVariant parameter is the type Record, and it is temporary.</error>
    /// <error>If the RecVariant parameter is the type Record, and the table number is 0.</error>
    procedure Show(RecVariant: Variant; FieldId: Integer)
    begin
        TranslationImplementation.Show(RecVariant, FieldId);
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
