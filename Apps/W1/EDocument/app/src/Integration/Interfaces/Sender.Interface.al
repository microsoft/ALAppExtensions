#pragma warning disable AS0128
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;
using System.Utilities;

/// <summary>
/// Interface for sending E-Documents to E-Document service
/// </summary>
#if not CLEAN26
interface Sender extends "E-Document Integration"
#else
interface Sender
#endif
{
    /// <summary>
    /// Use it to send an E-Document to external service.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="EDocumentService">The E-Document service record.</param>
    /// <param name="TempBlob">The tempblob that was created based on the E-Document format.</param>
    /// <param name="IsAsync">Is sending the document is async.</param>
    /// <remarks>If the E-Document is sent asynchronously, a background job will automatically get queued to fetch the response using GetResponse procedure.</remarks>
    /// <param name="HttpRequest">The HTTP request message object that you should use when sending the request.</param>
    /// <param name="HttpResponse">The HTTP response object that you should use when sending the request.</param>
    /// <remarks>If http request and response are populated, the response content and headers will be logged automatically to communication logs.</remarks>
    /// <example>   
    /// This example demonstrates how to implement the GetResponse method:  
    /// <code> 
    /// procedure Send()
    /// begin  
    ///     // Initialize records and objects  
    ///     IsAsync := true;  
    ///       
    ///     // Fill HttpRequest with data from EDocument and EDocumentService  
    ///     HttpRequest.Method := 'POST';  
    ///     HttpRequest.Content.WriteFrom(EDocument.GetJson()); // Assuming GetJson() returns the JSON representation of the E-Document  
    ///     HttpRequest.Content.GetHeaders().Add('Content-Type', 'application/json');  
    ///     
    ///     // Use HttpClient to send the request  
    ///     HttpClient.Send(HttpRequest, HttpResponse);  
    ///  
    ///     // Handle the response
    ///     if HttpResponse.IsSuccessStatusCode() then  
    ///         // Handle success case  
    ///     else  
    ///         // Handle failure case  
    /// end;  
    /// </code>
    /// </example>
    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsAsync: Boolean);

    /// <summary>
    /// Use it to send a batch of E-Documents to external service.
    /// </summary>
    /// <param name="EDocuments">Set of E-Documents record.</param>
    /// <param name="EDocumentService">The E-Document service record.</param>
    /// <param name="TempBlob">The tempblob that was created based on the E-Document format.</param>
    /// <param name="IsAsync">Is sending the document is async.</param>
    /// <remarks>If the E-Document is sent asynchronously, a background job will automatically get queued to fetch the response using GetResponse procedure.</remarks>
    /// <param name="HttpRequest">The HTTP request message object that you should use when sending the request.</param>
    /// <param name="HttpResponse">The HTTP response object that you should use when sending the request.</param>
    /// <remarks>If http request and response are populated, the response content and headers will be logged automatically to communication logs.</remarks>
    procedure SendBatch(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsAsync: Boolean);

    /// <summary>
    /// Use this method to asynchronously retrieve the response after sending a request for an E-Document.
    /// </summary>
    /// <param name="EDocument">The E-Document record for which the request is being made.</param>
    /// <param name="HttpRequest">The HTTP request message object to be used when sending the request.</param>
    /// <param name="HttpResponse">The HTTP response object that will be populated with the received response.</param>
    /// <returns>
    ///     <c>true</c> if the response was successfully received by the service, marking the E-Document Service Status as "Sent."
    ///     <c>false</c> if the response is not yet ready from the service, marking the E-Document Service Status as "Pending Response."
    /// </returns>
    /// <remarks>
    /// If a runtime error occurs or an error message is logged for the E-Document, the E-Document Service Status is set to "Sending Error,"
    /// and no further retry attempts will be made.
    /// </remarks>
    /// <remarks>
    /// If the HTTP response is populated, the response content and headers will be automatically logged to the communication logs.
    /// </remarks>
    /// <example>
    /// This example demonstrates how to implement the GetResponse method:  
    /// <code> 
    /// // Initialize the HTTP request  
    /// HttpRequest.Method := 'GET';  
    /// HttpRequest.SetRequestUri('https://example.com/getresponse?documentId=' + EDocument."Document ID");  
    ///
    /// // Send the HTTP request  
    /// HttpClient.Send(HttpRequest, HttpResponse);  
    /// if JsonResponse.ReadFrom(HttpResponse.ContentAsText()) then begin  
    ///     // Extract the status from the JSON response  
    ///     JsonResponse.GetValue('status', Status);  
    ///     exit(Status = 'received');
    /// end;  
    ///
    /// EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, 'Something went wrong reading the response');
    /// exit(false); 
    /// </code>
    /// </example>    
    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean;

}
#pragma warning restore AS0128