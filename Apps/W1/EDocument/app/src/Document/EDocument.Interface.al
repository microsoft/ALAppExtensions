// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Utilities;

interface "E-Document"
{
    ///
    /// The following methods are to create EDocument from Business Central document to send to the endpoint
    ///

    /// <summary>
    /// Use it to run check on release/post action of a document to make sure all necessary fields to submit the document are available.
    /// </summary>
    /// <param name="SourceDocumentHeader">The source document header as a recored ref.</param>
    /// <param name="EDocumentService">The document service used to send the document electronically.</param>
    /// <param name="EDocumentProcessingPhase">The document processing phase enum, for example it can be create, release, etc.</param>
    /// <remarks>You should validated all required data to convert a document to a specific format, and throw an error if something missing.</remarks>
    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")

    /// <summary>
    /// Use it to create a blob representing the posted document.
    /// </summary>
    /// <param name="EDocumentService">The document service used to send the document electronically.</param>
    /// <param name="EDocument">Electronic document.</param>
    /// <param name="SourceDocumentHeader">The source document header as a recored ref.</param>
    /// <param name="SourceDocumentLines">The source document lines as a recored ref.</param>
    /// <param name="TempBlob">Tempblob that should contatin the exported document in the correspondant format.</param>
    procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")

    /// <summary>
    /// Use it to create a blob representing a batch of posted documents.
    /// </summary>
    /// <param name="EDocumentService">The document service used to send the document electronically.</param>
    /// <param name="EDocument">Electronic document.</param>
    /// <param name="SourceDocumentHeader">The source document header as a recored ref.</param>
    /// <param name="SourceDocumentLines">The source document lines as a recored ref.</param>
    /// <param name="TempBlob">Tempblob that should contatin the exported document in the correspondant format.</param>
    procedure CreateBatch(EDocumentService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: Codeunit "Temp Blob")

    ///
    /// The following methods are to receive a document from an endpoint and prepare it to be a BC
    ///

    /// <summary>
    /// Use it to get the basic information of an E-Document from received blob.
    /// </summary>
    /// <param name="EDocument">Electronic document.</param>
    /// <param name="TempBlob">Contians received blob from external service</param>
    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")

    /// <summary>
    /// Use it to create a document from imported blob.
    /// </summary>
    /// <param name="EDocument">Electronic document.</param>
    /// <param name="CreatedDocumentHeader">The document header that should be populated from the blob as a recored ref.</param>
    /// <param name="CreatedDocumentLines">The document lines that should be populated from the blob as a recored ref.</param>
    /// <param name="TempBlob">Tempblob that should contatin the exported document in the correspondant format.</param>
    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
}