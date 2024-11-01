#pragma warning disable AS0128
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using System.Utilities;
using Microsoft.eServices.EDocument;

/// <summary>
/// Interface for receiving E-Documents from E-Document service
/// </summary>
#if not CLEAN26
interface Receiver extends "E-Document Integration"
#else
interface Receiver
#endif
{

    /// <summary>  
    /// Retrieves one or more documents from the API and returns the count of documents to be created.  
    /// </summary>  
    /// <param name="EDocumentService">The E-Document Service record used for the API interaction.</param>  
    /// <param name="TempBlob">The temporary blob used to store the received documents.</param>  
    /// <param name="HttpRequestMessage">The HTTP request message object used to send the request.</param>  
    /// <param name="HttpResponseMessage">The HTTP response message object that will be populated with the received response.</param>  
    /// <param name="Count">The count of documents to be created and expected in the TempBlob.</param>  
    /// <remarks>  
    /// The implementation should send an HTTP request to the API to retrieve the documents.
    /// The response should be stored in the TempBlob, and the Count parameter should be set to the number of documents retrieved.  
    /// </remarks>  
    /// <example>  
    /// This example demonstrates how to implement the ReceiveDocuments method:  
    /// <code>  
    /// procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Count: Integer)  
    /// var  
    ///     HttpClient: HttpClient;  
    ///     JsonResponse: JsonArray;  
    /// begin  
    ///     // Initialize the HTTP request  
    ///     HttpRequestMessage.Method := 'GET';  
    ///     HttpRequestMessage.SetRequestUri('https://api.example.com/documents');  
    ///  
    ///     // Send the HTTP request and receive the response  
    ///     HttpClient.Send(HttpRequestMessage, HttpResponseMessage);  
    ///  
    ///     // Parse the JSON response and store it in TempBlob  
    ///     JsonResponse.ReadFrom(HttpResponseMessage.ContentAsText());  
    ///     TempBlob.CreateOutStream().WriteText(HttpResponseMessage.ContentAsText());  
    ///  
    ///     // Set the count of documents  
    ///     Count := JsonResponse.Count();  
    /// end;  
    /// </code>  
    /// </example>
    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Count: Integer)

    /// <summary>  
    /// Downloads the data (XML, PDF, etc.) for each created document from the API.  
    /// </summary>  
    /// <param name="EDocument">The E-Document record for which the data is being downloaded.</param>  
    /// <param name="EDocumentService">The E-Document Service record used for the API interaction.</param>  
    /// <param name="DocumentsBlob">The temporary blob containing the list of documents.</param>  
    /// <param name="DocumentBlob">The temporary blob used to store the downloaded document data for the specific e-document.</param>  
    /// <param name="HttpRequestMessage">The HTTP request message object used to send the request.</param>  
    /// <param name="HttpResponseMessage">The HTTP response message object that will be populated with the received response.</param>  
    /// <remarks>  
    /// The implementation should extract the document information from the DocumentsBlob, here it can be usefull to use the "index in batch". 
    /// Then send an HTTP request to download the document data, and store the data in the DocumentBlob.  
    /// </remarks>  
    /// <example>  
    /// This example demonstrates how to implement the DownloadDocument method:  
    /// <code>  
    /// procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentsBlob: Codeunit "Temp Blob"; var DocumentBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)  
    /// var  
    ///     HttpClient: HttpClient;  
    ///     JsonResponse: JsonObject;  
    ///     DocumentId: Text;  
    /// begin  
    ///     // Extract the document ID from the DocumentsBlob  
    ///     DocumentsBlob.CreateInStream().ReadText(DocumentId);  
    ///  
    ///     // Initialize the HTTP request  
    ///     HttpRequestMessage.Method := 'GET';  
    ///     HttpRequestMessage.SetRequestUri('https://api.example.com/documents/' + DocumentId);  
    ///  
    ///     // Send the HTTP request  
    ///     if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin  
    ///         // Check if the response status code is 200 (OK)  
    ///         if HttpResponseMessage.IsSuccessStatusCode then begin  
    ///             // Store the response in DocumentBlob  
    ///             DocumentBlob.CreateOutStream().WriteText(HttpResponseMessage.ContentAsText());  
    ///         end;  
    ///     end;  
    /// end;  
    /// </code>  
    /// </example>
    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentsBlob: Codeunit "Temp Blob"; var DocumentBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)

}
#pragma warning restore AS0128