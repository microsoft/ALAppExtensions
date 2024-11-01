#pragma warning disable AS0128
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;
using System.Utilities;

/// <summary>
/// Interface for receiving E-Documents from E-Document service
/// </summary>
interface Fetchable
{

    /// <summary>  
    /// Marks the specified E-Document as fetched by the API
    /// </summary>  
    /// <param name="EDocument">The E-Document record that is being marked as fetched.</param>  
    /// <param name="EDocumentService">The E-Document Service record used for the API interaction.</param>  
    /// <param name="DocumentBlob">The temporary blob containing the document data.</param>  
    /// <param name="HttpRequestMessage">The HTTP request message object used to send the request.</param>  
    /// <param name="HttpResponseMessage">The HTTP response message object that will be populated with the received response.</param>  
    /// <remarks>  
    /// The implementation should send an HTTP request to the API to mark the document as fetched.  
    /// In case document could not be marked as fetched, the implementation should throw an error and E-Document wont be created.
    /// If API does not support marking documents as fetched, dont implement the interfaces
    /// </remarks>  
    /// <example>  
    /// This example demonstrates how to implement the MarkFetched method:  
    /// <code>  
    /// procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)  
    /// var  
    ///     HttpClient: HttpClient;  
    /// begin  
    ///     // Initialize the HTTP request  
    ///     HttpRequestMessage.Method := 'POST';  
    ///     HttpRequestMessage.SetRequestUri('https://api.example.com/documents/' + EDocument.Id + '/mark-fetched');  
    ///   
    ///     // Send the HTTP request  
    ///     HttpClient.Send(HttpRequestMessage, HttpResponseMessage);  
    ///   
    ///     // Check if the response status code is 200 (OK)  
    ///     if HttpResponseMessage.IsSuccessStatusCode then begin  
    ///         // Handle successful marking of the document as fetched by exiting without error
    ///         exit;
    ///     end;  
    ///     Error('Failed to mark the document as fetched.');
    /// end;  
    /// </code>  
    /// </example>
    procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)

}