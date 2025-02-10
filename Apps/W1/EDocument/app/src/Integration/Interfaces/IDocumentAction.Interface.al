// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Receive;

/// <summary>
/// Interface for E-Document actionable actions.
/// </summary>
interface IDocumentAction
{

    /// <summary>  
    /// Invokes an action based on the specified action type for the given E-Document and E-Document Service.  
    /// </summary>    
    /// <param name="EDocument">The E-Document record on which the action is performed.</param>  
    /// <param name="EDocumentService">The E-Document Service record used for the API interaction.</param>  
    /// <param name="ActionContext">The context for the action to be performed.</param>
    /// <returns>Returns true if the action performed should update E-Document status ; otherwise, false.</returns>  
    /// <remarks>  
    /// The implementation should send an HTTP request to the API to perform the specified action on the E-Document.  
    /// </remarks>  
    /// <example>  
    /// This example demonstrates how to implement the InvokeAction method to reset the E-Document status by calling the API:  
    /// <code>  
    /// procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
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
    ///     ActionContext.Status().SetStatus(Enum::"E-Document Service Status"::MyStatus);
    ///     exit(true);  
    /// end;  
    /// </code>  
    /// </example>
    procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean

}