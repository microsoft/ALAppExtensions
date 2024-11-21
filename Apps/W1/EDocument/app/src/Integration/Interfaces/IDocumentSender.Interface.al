// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Send;

/// <summary>
/// Interface for sending E-Documents to E-Document service
/// </summary>
interface IDocumentSender
{
    /// <summary>
    /// Sends an E-Document to an external service.
    /// </summary>
    /// <param name="EDocument">The record representing the E-Document to be sent.</param>
    /// <param name="EDocumentService">The record representing the E-Document Service containing service configuration.</param>
    /// <param name="SendContext">The context for the send operation, providing access to resources and settings.</param>
    /// <remarks>
    /// If the E-Document is sent asynchronously (<c>IsAsync</c> is <c>true</c>), a background job will automatically be queued to fetch the response using the <see cref="GetResponse"/> procedure.
    /// If the HTTP request is populated within <c>SendContext</c>, the request content and headers will be automatically logged to communication logs.
    /// </remarks>
    /// <example>
    /// This example demonstrates how to implement the <c>Send</c> method:
    /// <code>
    /// procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    /// var
    ///     TempBlob: Codeunit "Temp Blob";
    ///     HttpClient: HttpClient;
    ///     HttpRequest: HttpRequestMessage;
    /// begin
    ///     // Get the TempBlob from the SendContext
    ///     SendContext.GetTempBlob(TempBlob);
    ///
    ///     // Read the E-Document content from TempBlob and prepare the HTTP request
    ///     HttpRequest := SendContext.Http().GetHttpRequestMessage();
    ///     HttpRequest.Method := 'POST';
    ///     HttpRequest.SetRequestUri(EDocumentService."Service URL");
    ///     HttpRequest.Content := TempBlob.AsHttpContent('application/xml'); // Or 'application/json' based on format
    ///
    ///     // Set additional headers if necessary
    ///     HttpRequest.Headers.Add('Authorization', 'Bearer ' + EDocumentService."Access Token");
    ///
    ///     // Send the HTTP request
    ///     HttpClient.Send(HttpRequest, SendContext.Http().GetHttpResponseMessage());
    ///
    ///     // Set IsAsync to true to enable asynchronous processing
    ///     SendContext.SetIsAsync(true);
    /// end;
    /// </code>
    /// </example>
    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext);

}