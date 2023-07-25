// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to create and consume Word templates.
/// </summary>
codeunit 9987 "Word Template"
{
    Access = Public;

    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";

    /// <summary>
    /// Downloads the set template.
    /// </summary>
    procedure DownloadTemplate()
    begin
        WordTemplateImpl.DownloadTemplate();
    end;

    /// <summary>
    /// Downloads the resulting document.
    /// </summary>
    procedure DownloadDocument()
    begin
        WordTemplateImpl.DownloadDocument();
    end;

    /// <summary>
    /// Gets an InStream for the template.
    /// </summary>
    /// <param name="InStream">Out parameter, the InStream to set.</param>
    procedure GetTemplate(var InStream: InStream)
    begin
        WordTemplateImpl.GetTemplate(InStream);
    end;

    /// <summary>
    /// Gets an InStream for the resulting document.
    /// </summary>
    /// <param name="DocumentInStream">Out parameter, the InStream to set.</param> 
    procedure GetDocument(var DocumentInStream: InStream)
    begin
        WordTemplateImpl.GetDocument(DocumentInStream);
    end;

    /// <summary>
    /// Gets size for the resulting document.
    /// </summary>
    /// <returns>The size for the resulting document in bytes.</returns>
    procedure GetDocumentSize(): Integer
    begin
        exit(WordTemplateImpl.GetDocumentSize());
    end;

    /// <summary>
    /// Creates a template with the fields of a table. The table is selected by the user via a popup window.
    /// </summary>
    procedure Create()
    begin
        WordTemplateImpl.Create();
    end;

    /// <summary>
    /// Creates a template with the fields of the given table.
    /// </summary>
    /// <param name="TableId">Specifies the ID of the table whose fields will be used to populate the template.</param> 
    procedure Create(TableId: Integer)
    var
        TempWordTemplateFields: Record "Word Template Field" temporary;
    begin
        WordTemplateImpl.Create(TableId, TempWordTemplateFields);
    end;

    /// <summary>
    /// Creates a template with the fields from a selected table and a list of related table IDs.
    /// </summary>
    /// <param name="TableId">Specifies the ID of the table from which fields will be used to insert data in the template.</param> 
    /// <param name="RelatedTableIds">Specifies the IDs of tables that are related to the selected table. Fields from these tables will also be used to insert data in the template.</param>
    /// <param name="RelatedTableCodes">Specifies the IDs for each related table. The IDs must be the same length as the RelatedTableIds, and be between 1 and 5 characters.</param> 
    procedure Create(TableId: Integer; RelatedTableIds: List of [Integer]; RelatedTableCodes: List of [Code[5]])
    var
        TempWordTemplateFields: Record "Word Template Field" temporary;
    begin
        WordTemplateImpl.Create(TableId, RelatedTableIds, RelatedTableCodes, TempWordTemplateFields);
    end;

    /// <summary>
    /// Creates a template with given merge fields.
    /// </summary>
    /// <param name="MergeFields">Names of mail merge fields to be available in the template.</param>
    procedure Create(MergeFields: List of [Text])
    begin
        WordTemplateImpl.Create(MergeFields);
    end;

    /// <summary>
    /// Loads the template to be used for merging.
    /// </summary>
    /// <param name="WordTemplateCode">The code of the Word template to use.</param>
    /// <error>The document format is not recognized or not supported.</error>
    /// <error>The document appears to be corrupted and cannot be loaded.</error> 
    /// <error>There is an input/output exception.</error>
    /// <error>The document is encrypted.</error>
    procedure Load(WordTemplateCode: Code[30])
    begin
        WordTemplateImpl.Load(WordTemplateCode);
    end;

    /// <summary>
    /// Loads the template to be used for merging.
    /// </summary>
    /// <param name="WordTemplateStream">InStream of the Word template to use.</param>
    /// <error>The document format is not recognized or not supported.</error>
    /// <error>The document appears to be corrupted and cannot be loaded.</error> 
    /// <error>There is an input/output exception.</error>
    /// <error>The document is encrypted.</error>
    procedure Load(WordTemplateStream: InStream)
    begin
        WordTemplateImpl.Load(WordTemplateStream);
    end;

    /// <summary>
    /// Loads the template to be used for merging from the stream and additional related fields from the WordTemplateCode which is used as the base.
    /// </summary>
    /// <param name="WordTemplateStream">InStream of the Word template to use.</param>
    /// <param name="WordTemplateCode">The Word template which contains the related tables and fields.</param>
    /// <error>The document format is not recognized or not supported.</error>
    /// <error>The document appears to be corrupted and cannot be loaded.</error> 
    /// <error>There is an input/output exception.</error>
    /// <error>The document is encrypted.</error>
    procedure Load(WordTemplateStream: InStream; WordTemplateCode: Code[30])
    begin
        WordTemplateImpl.Load(WordTemplateStream, WordTemplateCode);
    end;

    /// <summary>
    /// Performs mail merge on set template and given data. Output document is of type .docx.
    /// </summary>
    /// <param name="Data">Input data to be merged into the document. The key is the merge field name and value is the replacement value.</param>
    procedure Merge(Data: Dictionary of [Text, Text])
    begin
        WordTemplateImpl.Merge(Data, false, Enum::"Word Templates Save Format"::Docx);
    end;

    /// <summary>
    /// Performs mail merge on set template and given data. Output document type is of specified save format.
    /// </summary>
    /// <param name="Data">Input data to be merged into the document. The key is the merge field name and value is the replacement value.</param>
    /// <param name="SaveFormat">Format of the document to generate.</param>
    procedure Merge(Data: Dictionary of [Text, Text]; SaveFormat: Enum "Word Templates Save Format")
    begin
        WordTemplateImpl.Merge(Data, false, SaveFormat);
    end;

    /// <summary>
    /// Performs mail merge on set template and given data. Output document type is of specified save format.
    /// </summary>
    /// <param name="Data">Input data to be merged into the document. The key is the merge field name and value is the replacement value.</param>
    /// <param name="SaveFormat">Format of the document to generate.</param>
    /// <param name="EditDoc">Edit document in Word after merging. Only available if OneDrive has been enabled. If true, the default value for conflict behaviors is to replace the existing file in OneDrive.</param>
    procedure Merge(Data: Dictionary of [Text, Text]; SaveFormat: Enum "Word Templates Save Format"; EditDoc: Boolean)
    begin
        WordTemplateImpl.Merge(Data, false, SaveFormat, EditDoc, Enum::"Doc. Sharing Conflict Behavior"::Ask);
    end;

    /// <summary>
    /// Performs mail merge on set template and given data. Output document type is of specified save format.
    /// </summary>
    /// <param name="Data">Input data to be merged into the document. The key is the merge field name and value is the replacement value.</param>
    /// <param name="SaveFormat">Format of the document to generate.</param>
    /// <param name="EditDoc">Edit document in Word after merging. Only available if OneDrive has been enabled.</param>
    /// <param name="DocSharingConflictBehavior">The behavior when the file being uploaded has a conflict. Only used if EditDoc is true.</param>
    procedure Merge(Data: Dictionary of [Text, Text]; SaveFormat: Enum "Word Templates Save Format"; EditDoc: Boolean; DocSharingConflictBehavior: Enum "Doc. Sharing Conflict Behavior")
    begin
        WordTemplateImpl.Merge(Data, false, SaveFormat, EditDoc, DocSharingConflictBehavior);
    end;


    /// <summary>
    /// Performs mail merge on set template and data taken from the Record associated with the Document. Output document is of type .docx.
    /// </summary>
    /// <param name="SplitDocument">Specifies whether a separate document per record should be created.</param>
    procedure Merge(SplitDocument: Boolean)
    begin
        WordTemplateImpl.Merge(SplitDocument, Enum::"Word Templates Save Format"::Docx);
    end;

    /// <summary>
    /// Performs mail merge on set template and data taken from the Record associated with the Document. Output document type is of specified save format.
    /// </summary>
    /// <param name="SplitDocument">Specifies whether a separate document per record should be created.</param>
    /// <param name="SaveFormat">Format of the document to generate.</param>
    procedure Merge(SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
    begin
        WordTemplateImpl.Merge(SplitDocument, SaveFormat);
    end;

    /// <summary>
    /// Performs mail merge on set template and data taken from the given Record. Output document is of type .docx.
    /// </summary>
    /// <param name="RecordVariant">The Record to take data from, any filters on the Record will be respected.</param>
    /// <param name="SplitDocument">Specifies whether a separate document per record should be created.</param>
    procedure Merge(RecordVariant: Variant; SplitDocument: Boolean)
    begin
        WordTemplateImpl.Merge(RecordVariant, SplitDocument, Enum::"Word Templates Save Format"::Docx, false);
    end;

    /// <summary>
    /// Performs mail merge on set template and data taken from the given Record. Output document type is of specified save format.
    /// </summary>
    /// <param name="RecordVariant">The Record to take data from, any filters on the Record will be respected.</param>
    /// <param name="SplitDocument">Specifies whether a separate document per record should be created.</param>
    /// <param name="SaveFormat">Format of the document to generate.</param>
    procedure Merge(RecordVariant: Variant; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
    begin
        WordTemplateImpl.Merge(RecordVariant, SplitDocument, SaveFormat, false);
    end;

    /// <summary>
    /// Performs mail merge on set template and data taken from the given Record. Output document type is of specified save format.
    /// </summary>
    /// <param name="RecordVariant">The Record to take data from, any filters on the Record will be respected.</param>
    /// <param name="SplitDocument">Specifies whether a separate document per record should be created.</param>
    /// <param name="SaveFormat">Format of the document to generate.</param>
    /// <param name="EditDoc">Edit document in Word after merging. Only available if OneDrive has been enabled.</param>
    procedure Merge(RecordVariant: Variant; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format"; EditDoc: Boolean)
    begin
        WordTemplateImpl.Merge(RecordVariant, SplitDocument, SaveFormat, EditDoc);
    end;

    /// <summary>
    /// Performs mail merge on set template and data taken from the given Record. Output document type is of specified save format.
    /// </summary>
    /// <param name="RecordVariant">The Record to take data from, any filters on the Record will be respected.</param>
    /// <param name="SplitDocument">Specifies whether a separate document per record should be created.</param>
    /// <param name="SaveFormat">Format of the document to generate.</param>
    /// <param name="EditDoc">Edit document in Word after merging. Only available if OneDrive has been enabled.</param>
    /// <param name="DocSharingConflictBehavior">The behavior when the file being uploaded has a conflict. Only used if EditDoc is true.</param>
    procedure Merge(RecordVariant: Variant; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format"; EditDoc: Boolean; DocSharingConflictBehavior: Enum "Doc. Sharing Conflict Behavior")
    begin
        WordTemplateImpl.Merge(RecordVariant, SplitDocument, SaveFormat, EditDoc, DocSharingConflictBehavior);
    end;

    /// <summary>
    /// Add a table to the list of available tables for Word templates.
    /// </summary>
    /// <param name="TableID">The ID of the table to add.</param>
    procedure AddTable(TableID: Integer)
    begin
        WordTemplateImpl.AddTable(TableID);
    end;

    /// <summary>
    /// Get the table ID for this Template.
    /// </summary>
    /// <remarks>The function Load needs to be called before this function.</remarks>
    procedure GetTableId(): Integer
    begin
        exit(WordTemplateImpl.GetTableId());
    end;

    /// <summary>
    /// Add related table.
    /// </summary>
    /// <param name="WordTemplateCode">The code of an existing parent Word template.</param>
    /// <param name="RelatedCode">The code of the related table to add.</param>
    /// <param name="TableID">The ID of the parent Word template.</param>
    /// <param name="RelatedTableID">The ID of the related table to add.</param>
    /// <param name="FieldNo">The field no. of the parent table that references the related table.</param>
    /// <remarks>The function shows a message if the related code or table ID is already used for the parent table</remarks>
    /// <returns>True if the related table was added, false otherwise.</returns> 
    procedure AddRelatedTable(WordTemplateCode: Code[30]; RelatedCode: Code[5]; TableId: Integer; RelatedTableId: Integer; FieldNo: Integer): Boolean
    begin
        WordTemplateImpl.AddRelatedTable(WordTemplateCode, RelatedCode, TableId, RelatedTableId, FieldNo);
    end;

    /// <summary>
    /// Set the default fields for the table.
    /// </summary>
    /// <param name="WordTemplateCode">The code of an existing parent Word template.</param>
    /// <param name="RelatedTableID">The ID of the table.</param>
    procedure SetDefaultFields(WordTemplateCode: Code[30]; TableId: Integer)
    var
        WordTemplateField: Record "Word Template Field";
    begin
        WordTemplateFieldSelection.SelectDefaultFieldsForTable(WordTemplateCode, TableId, WordTemplateField);
    end;

    /// <summary>
    /// Add unrelated table.
    /// </summary>
    /// <param name="WordTemplateCode">The code of an existing parent Word template.</param>
    /// <param name="PrefixCode">The code of the unrelated table to add.</param>
    /// <param name="UnrelatedTableId">The ID of the unrelated table to add.</param>
    /// <param name="RecordSystemId">The system id of the record to add.</param>
    /// <returns>True if the unrelated table was added, false otherwise.</returns>
    procedure AddUnrelatedTable(WordTemplateCode: Code[30]; PrefixCode: Code[5]; UnrelatedTableId: Integer; RecordSystemId: Guid): Boolean
    begin
        WordTemplateImpl.AddUnrelatedTable(WordTemplateCode, PrefixCode, UnrelatedTableId, RecordSystemId);
    end;

    /// <summary>
    /// Set the fields to be excluded from the word template.
    /// </summary>
    /// <param name="WordTemplateCode">The code of an existing parent Word template.</param>
    /// <param name="TableId">The ID of the table.</param>
    /// <param name="ExcludeFieldNames">The fields that should be excluded.</param>
    procedure SetExcludedFields(WordTemplateCode: Code[30]; TableId: Integer; ExcludeFieldNames: List of [Text[30]])
    begin
        WordTemplateFieldSelection.SetExcludedFields(WordTemplateCode, TableId, ExcludeFieldNames);
    end;

    /// <summary>
    /// Get the fields to be excluded from the word template.
    /// </summary>
    /// <param name="WordTemplateCode">The code of an existing parent Word template.</param>
    /// <param name="TableId">The ID of the table.</param>
    /// <returns>The fields that are being excluded.</returns>
    procedure GetExcludedFields(WordTemplateCode: Code[30]; TableId: Integer): List of [Text[30]]
    begin
        exit(WordTemplateFieldSelection.GetExcludedFields(WordTemplateCode, TableId));
    end;

    /// <summary>
    /// Get a list of all current custom table fields for a given table.
    /// </summary>
    /// <param name="TableId">The ID of the table.</param>
    /// <returns>The names of the custom fields.</returns>
    procedure GetCustomTableFields(TableId: Integer): List of [Text[30]]
    begin
        exit(WordTemplateFieldSelection.GetCustomTableFields(TableId));
    end;

    /// <summary>
    /// Get a list of all supported table fields. This list does not include custom fields.
    /// </summary>
    /// <param name="TableId">The ID of the table.</param>
    /// <returns>The names of all fields that are supported on the table.</returns>
    procedure GetSupportedTableFields(TableId: Integer): List of [Text[30]]
    begin
        exit(WordTemplateFieldSelection.GetSupportedTableFields(TableId));
    end;

    /// <summary>
    /// Determine whether a field is supported for Word Templates.
    /// </summary>
    /// <param name="Field">The field of a record.</param>
    /// <returns>Whether the given field is supported for Word Templates.</returns>
    procedure IsFieldSupported(Field: Record Field): Boolean
    begin
        exit(WordTemplateFieldSelection.IsFieldSupported(Field));
    end;

#if not CLEAN22
    /// <summary>
    /// Remove a related or unrelated table.
    /// </summary>
    /// <param name="WordTemplateCode">The code of the parent Word template.</param>
    /// <param name="RelatedTableID">The ID of the related table to remove. This table must not have tables depending on it, otherwise an error will be thrown.</param>
    /// <returns>True if the table was removed, false otherwise.</returns>
    [Obsolete('Replaced by RemoveTable below', '22.0')]
    procedure RemoveRelatedTable(WordTemplateCode: Code[30]; TableId: Integer): Boolean
    begin
        WordTemplateImpl.RemoveTable(WordTemplateCode, TableId);
    end;
#endif

    /// <summary>
    /// Remove a related or unrelated table.
    /// An error is thrown if the table has any children, these must be removed first.
    /// </summary>
    /// <param name="WordTemplateCode">The code of the parent Word template.</param>
    /// <param name="TableId">The ID of the table to remove. This table must not have tables depending on it, otherwise an error will be thrown.</param>
    /// <returns>True if the table was removed, false otherwise.</returns>
    procedure RemoveTable(WordTemplateCode: Code[30]; TableId: Integer): Boolean
    begin
        WordTemplateImpl.RemoveTable(WordTemplateCode, TableId);
    end;

    /// <summary>
    /// Get all tables in this template which has a relation to the given table.
    /// </summary>
    /// <param name="WordTemplateCode">The code of the parent Word template.</param>
    /// <param name="TableId">The ID of the table.</param>
    /// <returns>The tables related to this table.</returns>
    procedure GetChildren(WordTemplateCode: Code[30]; TableId: Integer): List of [Integer]
    begin
        exit(WordTemplateImpl.GetChildren(WordTemplateCode, TableId));
    end;

    /// <summary>
    /// Event to get custom field names for the word template based on the table id.
    /// Make sure to also subscribe to GetCustomRecordValues in order to provide the values for these fields.
    /// </summary>
    /// <example>
    /// if WordTemplateCustomFields.GetTableID() = Database::Customer then
    ///     WordTemplateCustomFields.AddField('Customer Title');
    /// </example>
    /// <param name="WordTemplateCustomFields">Interface for adding custom fields.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnGetCustomFieldNames(var WordTemplateCustomField: Codeunit "Word Template Custom Field")
    begin
    end;

    /// <summary>
    /// Event to add values for the custom fields specified through GetCustomFieldNames.
    /// In order to add a value for a field, it MUST be registered through the event GetCustomFieldNames.
    /// </summary>
    /// <example>
    /// RecRef := WordTemplateCustomFldValue.GetRecord();
    /// if RecRef.Number = Database::Customer then
    ///     WordTemplateCustomFldValue.AddFieldValue('Customer Title', GetCustomerTitle(RecRef));
    /// </example>
    /// <param name="WordTemplateCustomFldValue">Interface for adding custom field values.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnGetCustomRecordValues(var WordTemplateFieldValue: Codeunit "Word Template Field Value")
    begin
    end;
}