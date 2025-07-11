// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Send;

/// <summary>
/// Interface for getting response for sent E-Documents from E-Document service
/// </summary>
interface IDocumentResponseHandler
{
    /// <summary>
    /// Retrieves the response from the external service for an asynchronously sent E-Document.
    /// </summary>
    /// <param name="EDocument">The record representing the E-Document for which the response is being retrieved.</param>
    /// <param name="EDocumentService">The record representing the E-Document Service containing service configuration.</param>
    /// <param name="SendContext">The context for the get response operation, providing access to resources and status updates.</param>
    /// <returns>
    /// <c>true</c> if the response was successfully received from the service, marking the E-Document Service Status as "Sent";
    /// <c>false</c> if the response is not yet ready from the service, marking the E-Document Service Status as "Pending Response".
    /// </returns>
    /// <remarks>
    /// If a runtime error occurs or an error message is logged for the E-Document, the E-Document Service Status is set to "Sending Error",
    /// and no further retry attempts will be made.
    /// If the HTTP response is populated within <c>SendContext</c>, the response content and headers will be automatically logged to communication logs.
    /// </remarks>
    /// <example>
    /// This example demonstrates how to implement the <c>GetResponse</c> method:
    /// <code>
    /// procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean
    /// var
    ///     HttpClient: HttpClient;
    ///     HttpRequest: HttpRequestMessage;
    ///     HttpResponse: HttpResponseMessage;
    /// begin
    ///     // Prepare the HTTP request to check the status of the E-Document
    ///     HttpRequest := SendContext.Http().GetHttpRequestMessage();
    ///     HttpRequest.Method := 'GET';
    ///     HttpRequest.SetRequestUri(EDocumentService."Service URL" + '/status/' + EDocument."Document ID");
    ///     HttpRequest.Headers.Add('Authorization', 'Bearer ' + EDocumentService."Access Token");
    ///
    ///     // Send the HTTP request
    ///     HttpClient.Send(HttpRequest, HttpResponse);
    ///
    ///     // Set the response in SendContext for automatic logging
    ///     SendContext.Http().SetHttpResponseMessage(HttpResponse);
    ///
    ///     // Determine the result based on the response status code
    ///     if HttpResponse.IsSuccessStatusCode() then
    ///         exit(true) // The document was successfully processed
    ///     else if HttpResponse.HttpStatusCode() = 202 then
    ///         exit(false) // The document is still being processed
    ///     else begin
    ///         // Log the error and set the status to "Sending Error"
    ///         EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, 'Error retrieving response: ' + Format(HttpResponse.HttpStatusCode()));
    ///         exit(false);
    ///     end;
    /// end;
    /// </code>
    /// </example> 
    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean;
}