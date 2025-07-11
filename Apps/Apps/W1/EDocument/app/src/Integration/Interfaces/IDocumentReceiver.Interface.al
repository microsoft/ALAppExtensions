// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Receive;

/// <summary>
/// Interface for receiving E-Documents from E-Document service
/// </summary>
interface IDocumentReceiver
{

    /// <summary>
    /// Retrieves one or more documents from the API and returns the count of documents to be created.
    /// </summary>
    /// <param name="EDocumentService">The record representing the E-Document Service used for the API interaction.</param>
    /// <param name="Documents">The temporary blob list used to store the received documents.</param>
    /// <param name="ReceiveContext">The receive context used for managing HTTP requests and responses.</param>
    /// <remarks>
    /// Sends an HTTP request to the API to retrieve the documents. 
    /// The response is stored in the DocumentsMetadata list, and the count of documents is implicitly determined by the number of temp blobs added to the list.
    /// </remarks>
    /// <example>
    /// This example demonstrates how to implement the <c>ReceiveDocuments</c> method:
    /// <code>
    /// procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    /// var
    ///     HttpRequest: HttpRequestMessage;
    ///     JsonResponse: JsonArray;
    ///     DocumentBlob: Codeunit "Temp Blob";
    ///     JsonObject: JsonObject;
    ///     OutStream: OutStream;
    /// begin
    ///     // Prepare the HTTP request
    ///     HttpRequest := ReceiveContext.Http().GetHttpRequestMessage();
    ///     HttpRequest.Method := 'GET';
    ///     HttpRequest.SetRequestUri(EDocumentService."Service URL" + '/documents');
    ///
    ///     // Send the HTTP request
    ///     HttpClient.Send(HttpRequest, ReceiveContext.Http().GetHttpResponseMessage());
    ///
    ///     // Parse the JSON response
    ///     JsonResponse.ReadFrom(HttpResponse.ContentAsText());
    ///
    ///     // Iterate over each object in the JSON array and add a temp blob to the DocumentsMetadata list
    ///     foreach JsonObject in JsonResponse do begin
    ///         DocumentBlob.CreateOutStream(OutStream);
    ///         JsonObject.WriteTo(OutStream);
    ///         DocumentsMetadata.Add(DocumentBlob);
    ///     end;
    /// end;
    /// </code>
    /// </example>
    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)

    /// <summary>
    /// Downloads the data (e.g., XML, PDF) for the specified document from the API.
    /// </summary>
    /// <param name="EDocument">The record representing the E-Document for which the data is being downloaded.</param>
    /// <param name="EDocumentService">The record representing the E-Document Service used for the API interaction.</param>
    /// <param name="DocumentMetadata">The temporary blob containing the metadata for the document.</param>
    /// <param name="ReceiveContext">The receive context used for managing HTTP requests and responses.</param>
    /// <remarks>
    /// Reads the document ID from the DocumentMetadata and sends an HTTP request to download the document data. 
    /// The document data is downloaded using an authenticated request and stored in the ReceiveContext. If the document ID is not found, an error is logged, and no further actions are taken.
    /// </remarks>
    /// <example>
    /// This example demonstrates how to implement the <c>DownloadDocument</c> method:
    /// <code>
    /// procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    /// var
    ///     Request: Codeunit Requests;
    ///     HttpExecutor: Codeunit "Http Executor";
    ///     ResponseContent: Text;
    ///     InStream: InStream;
    ///     DocumentId: Text;
    ///     OutStream: OutStream;
    /// begin
    ///     // Read the document ID from the DocumentMetadata
    ///     DocumentMetadata.CreateInStream(InStream, TextEncoding::UTF8);
    ///     InStream.ReadText(DocumentId);
    ///
    ///     if DocumentId = '' then begin
    ///         EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, DocumentIdNotFoundErr);
    ///         exit;
    ///     end;
    ///
    ///     // Update the document record with the document ID
    ///     EDocument."Document Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."Document Id"));
    ///     EDocument.Modify();
    ///
    ///     // Prepare the HTTP request
    ///     Request.Init();
    ///     Request.Authenticate().CreateDownloadRequest(DocumentId);
    ///     ReceiveContext.Http().SetHttpRequestMessage(Request.GetRequest());
    ///
    ///     // Execute the HTTP request
    ///     ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, ReceiveContext.Http().GetHttpResponseMessage());
    ///
    ///     // Store the response in the ReceiveContext
    ///     ReceiveContext.GetTempBlob().CreateOutStream(OutStream, TextEncoding::UTF8);
    ///     OutStream.WriteText(ResponseContent);
    /// end;
    /// </code>
    /// </example>
    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)

}