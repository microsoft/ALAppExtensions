// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;

/// <summary>
/// Interface for Action Invoker
/// </summary>
interface "Action Invoker"
{

    /// <summary>  
    /// Invokes an action based on the specified action type for the given E-Document and E-Document Service.  
    /// </summary>    
    /// <param name="EDocument">The E-Document record on which the action is performed.</param>  
    /// <param name="EDocumentService">The E-Document Service record used for the API interaction.</param>  
    /// <param name="HttpRequestMessage">The HTTP request message object used to send the request.</param>  
    /// <param name="HttpResponseMessage">The HTTP response message object that will be populated with the received response.</param>  
    /// <param name="Status">The status of the E-Document Service after the action is performed. Will also determine the EDocument Status</param>  
    /// <returns>Returns true if the action performed should update E-Document status ; otherwise, false.</returns>  
    /// <remarks>  
    /// The implementation should send an HTTP request to the API to perform the specified action on the E-Document.  
    /// </remarks>  
    /// <example>  
    /// This example demonstrates how to implement the InvokeAction method to reset the E-Document status by calling the API:  
    /// <code>  
    /// procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean  
    /// var  
    ///     HttpClient: HttpClient;  
    /// begin  
    ///     // Initialize the HTTP request  
    ///     HttpRequestMessage.Method := 'POST';  
    ///     HttpRequestMessage.SetRequestUri('https://api.example.com/documents/reset');  
    ///     HttpRequestMessage.Content.WriteFromText('{"documentId": "' + EDocument."Document ID" + '"}');  
    ///  
    ///     // Send the HTTP request and receive the response  
    ///     HttpClient.Send(HttpRequestMessage, HttpResponseMessage);  
    ///  
    ///     // Update the E-Document status  
    ///     EDocument.Status := EDocument.Status::Open;  
    ///     Status := EDocument.Status::Open;  
    ///     exit(true);  
    /// end;  
    /// </code>  
    /// </example>
    procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean

    /// <summary>  
    /// Gets the fallback status for the specified action type for the given E-Document and E-Document Service.  
    /// </summary>  
    /// <param name="EDocument">The E-Document record for which the fallback status is retrieved.</param>  
    /// <param name="EDocumentService">The E-Document Service record used for the API interaction.</param>  
    /// <returns>Returns the fallback status of the E-Document Service.</returns>  
    /// <remarks>  
    /// The implementation should return a fallback status in case the action fails with a runtime error.  
    /// </remarks>  
    /// <example>  
    /// This example demonstrates how to implement the GetFallbackStatus method to return a default fallback status:  
    /// <code>  
    /// procedure GetFallbackStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"): Enum "E-Document Service Status"  
    /// begin  
    ///     exit(Enum::"E-Document Service Status"::"Sending Error");  
    /// end;  
    /// </code>  
    /// </example> 
    procedure GetFallbackStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"): Enum "E-Document Service Status"

}