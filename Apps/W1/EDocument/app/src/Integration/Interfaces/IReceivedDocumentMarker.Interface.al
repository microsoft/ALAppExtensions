#pragma warning disable AS0128
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Receive;

/// <summary>
/// Interface for marking received E-Documents fetched from the E-Document service.
/// </summary>
interface IReceivedDocumentMarker
{

    /// <summary>
    /// Marks the given E-Document as fetched using an API call.
    /// </summary>
    /// <param name="EDocument">The record representing the E-Document to be marked as fetched.</param>
    /// <param name="EDocumentService">The record representing the E-Document Service used for API interaction.</param>
    /// <param name="DocumentBlob">The temporary blob containing document metadata.</param>
    /// <param name="ReceiveContext">The receive context interface used for managing HTTP requests and responses.</param>
    /// <remarks>
    /// Sends an HTTP request to the API to mark the document as fetched. If the request fails, an error is thrown, preventing the document from being created.
    /// If the API does not support this functionality, the implementation should avoid implementing the associated interfaces.
    /// </remarks>
    /// <example>
    /// This example shows how to implement the MarkFetched method:
    /// <code>
    /// procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    /// var
    ///     HttpClient: HttpClient;
    /// begin
    ///     // Set up the HTTP request
    ///     HttpRequestMessage.Method := 'POST';
    ///     HttpRequestMessage.SetRequestUri('https://api.example.com/documents/' + EDocument.Id + '/mark-fetched');
    ///
    ///     // Send the HTTP request
    ///     HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
    ///
    ///     // Check if the response was successful
    ///     if HttpResponseMessage.IsSuccessStatusCode then begin
    ///         // Successfully marked the document as fetched
    ///         exit;
    ///     end;
    ///     Error('Failed to mark the document as fetched.');
    /// end;
    /// </code>
    /// </example>    
    procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)

}