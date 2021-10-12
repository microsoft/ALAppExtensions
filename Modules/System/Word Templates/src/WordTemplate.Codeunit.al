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
    begin
        WordTemplateImpl.Create(TableId);
    end;

    /// <summary>
    /// Creates a template with the fields from a selected table and a list of related table IDs.
    /// </summary>
    /// <param name="TableId">Specifies the ID of the table from which fields will be used to insert data in the template.</param> 
    /// <param name="RelatedTableIds">Specifies the IDs of tables that are related to the selected table. Fields from these tables will also be used to insert data in the template.</param> /// 
    /// <param name="RelatedTableCodes">Specifies the IDs for each related table. The IDs must be the same length as the RelatedTableIds, and be between 1 and 5 characters.</param> 
    procedure Create(TableId: Integer; RelatedTableIds: List of [Integer]; RelatedTableCodes: List of [Code[5]])
    begin
        WordTemplateImpl.Create(TableId, RelatedTableIds, RelatedTableCodes);
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
        WordTemplateImpl.Merge(RecordVariant, SplitDocument, Enum::"Word Templates Save Format"::Docx);
    end;

    /// <summary>
    /// Performs mail merge on set template and data taken from the given Record. Output document type is of specified save format.
    /// </summary>
    /// <param name="RecordVariant">The Record to take data from, any filters on the Record will be respected.</param>
    /// <param name="SplitDocument">Specifies whether a separate document per record should be created.</param>
    /// <param name="SaveFormat">Format of the document to generate.</param>
    procedure Merge(RecordVariant: Variant; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
    begin
        WordTemplateImpl.Merge(RecordVariant, SplitDocument, SaveFormat);
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
    /// Remove a related table.
    /// </summary>
    /// <param name="WordTemplateCode">The code of the parent Word template.</param>
    /// <param name="RelatedTableID">The ID of the related table to remove.</param>
    /// <returns>True if the related table was removed, false otherwise.</returns>
    procedure RemoveRelatedTable(WordTemplateCode: Code[30]; RelatedTableId: Integer): Boolean
    begin
        WordTemplateImpl.RemoveRelatedTable(WordTemplateCode, RelatedTableId);
    end;
}