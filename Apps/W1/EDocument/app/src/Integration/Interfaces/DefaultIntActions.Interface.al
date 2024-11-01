#pragma warning disable AS0128
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;

/// <summary>
/// Default Integration Actions that framework provides.
/// </summary>
#if not CLEAN26
interface "Default Int. Actions" extends "E-Document Integration"
#else
interface "Default Int. Actions"
#endif
{

    /// <summary>  
    /// Sends a outgoing E-Document approval request to the API, to check if sent document is approved. 
    /// </summary>  
    /// <param name="EDocument">The E-Document record to be approved.</param>  
    /// <param name="EDocumentService">The E-Document Service record used for the API interaction.</param>  
    /// <param name="HttpRequest">The HTTP request message object used to send the request.</param>  
    /// <param name="HttpResponse">The HTTP response message object that will be populated with the received response.</param>  
    /// <param name="Status">The status of the E-Document Service after the action is performed.</param>  
    /// <returns>Returns true if the document approval request should update the E-Document status; otherwise, false.</returns>  
    /// <remarks>  
    /// The implementation should send an HTTP request to the API to ask if document was approved by the service.  
    /// </remarks>  
    /// <example>  
    /// This example demonstrates how to implement the GetSentDocumentApprovalStatus method to send a document approval request:  
    /// <code>  
    /// procedure GetSentDocumentApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean  
    /// var  
    ///     HttpClient: HttpClient;  
    /// begin  
    ///     // Initialize the HTTP request  
    ///     HttpRequest.Method := 'POST';  
    ///     HttpRequest.SetRequestUri('https://api.example.com/documents/approve');  
    ///     HttpRequest.Content.WriteFromText('{"documentId": "' + EDocument."Document ID" + '"}');  
    ///  
    ///     // Send the HTTP request and receive the response  
    ///     HttpClient.Send(HttpRequest, HttpResponse);  
    ///  
    ///     // Check the response
    ///     ....
    /// end;  
    /// </code>  
    /// </example>  
    procedure GetSentDocumentApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean;

    /// <summary>  
    /// Sends a outgoing E-Document cancelation request to the API, to check if sent document was canceled.
    /// </summary>  
    /// <param name="EDocument">The E-Document record to be canceled.</param>  
    /// <param name="EDocumentService">The E-Document Service record used for the API interaction.</param>  
    /// <param name="HttpRequest">The HTTP request message object used to send the request.</param>  
    /// <param name="HttpResponse">The HTTP response message object that will be populated with the received response.</param>  
    /// <param name="Status">The status of the E-Document Service after the action is performed.</param>  
    /// <returns>Returns true if the document approval request should update the E-Document status; otherwise, false.</returns>  
    /// <remarks>  
    /// The implementation should send an HTTP request to the API to ask if document was canceled by the service.   
    /// </remarks> 
    procedure GetSentDocumentCancelationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean;

    /// <summary>  
    /// Opens the service integration setup page.  
    /// </summary>  
    /// <param name="EDocumentService">The E-Document Service record for which the setup page is opened.</param>  
    /// <returns>Returns true if the setup page was successfully opened and handled; otherwise, false.</returns>  
    /// <remarks>  
    /// The implementation should open the setup page for the specified E-Document Service.  
    /// </remarks>  
    /// <example>  
    /// This example demonstrates how to implement the OpenServiceIntegrationSetupPage method to open the setup page:  
    /// <code>  
    /// procedure OpenServiceIntegrationSetupPage(var EDocumentService: Record "E-Document Service"): Boolean  
    /// begin  
    ///     PAGE.Run(PAGE::"Service Integration Setup", EDocumentService);  
    ///     exit(true);  
    /// end;  
    /// </code>  
    /// </example>      
    procedure OpenServiceIntegrationSetupPage(var EDocumentService: Record "E-Document Service"): Boolean

}
#pragma warning restore AS0128