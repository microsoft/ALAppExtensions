// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Utilities;

interface "E-Document Integration"
{
    /// <summary>
    /// Use it to send an E-Document to external service.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempBlob">The tempblob that was created based on the E-Document format.</param>
    /// <param name="IsAsync">Is sending the document is async.</param>
    /// <remarks>If the E-Document is sent asynchronously, a background job will automatically get queued to fetch the response using GetResponse procedure.</remarks>
    /// <param name="HttpRequest">The HTTP request message object that you should use when sending the request.</param>
    /// <param name="HttpResponse">The HTTP response object that you should use when sending the request.</param>
    /// <remarks>If http request and response are populated, the response content and headers will be logged automatically to communication logs.</remarks>
    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage);

    /// <summary>
    /// Use it to send a batch of E-Documents to external service.
    /// </summary>
    /// <param name="EDocuments">Set of E-Documents record.</param>
    /// <param name="TempBlob">The tempblob that was created based on the E-Document format.</param>
    /// <param name="IsAsync">Is sending the document is async.</param>
    /// <remarks>If the E-Document is sent asynchronously, a background job will automatically get queued to fetch the response using GetResponse procedure.</remarks>
    /// <param name="HttpRequest">The HTTP request message object that you should use when sending the request.</param>
    /// <param name="HttpResponse">The HTTP response object that you should use when sending the request.</param>
    /// <remarks>If http request and response are populated, the response content and headers will be logged automatically to communication logs.</remarks>
    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage);

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
    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean;

    /// <summary>
    /// Use it to check if document is approved or rejected.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="HttpRequest">The HTTP request message object that you should use when sending the request.</param>
    /// <param name="HttpResponse">The HTTP response object that you should use when sending the request.</param>
    /// <remarks>If http response is populated, the response content and headers will be logged automatically to communication logs.</remarks>
    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean;

    /// <summary>
    /// Use it to send a cancel request for an E-Document.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="HttpRequest">The HTTP request message object that you should use when sending the request.</param>
    /// <param name="HttpResponse">The HTTP response object that you should use when sending the request.</param>
    /// <remarks>If http response is populated, the response content and headers will be logged automatically to communication logs.</remarks>
    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean;

    /// <summary>
    /// Use it to receive E-Document from external service.
    /// </summary>
    /// <param name="EDocument">The E-Document record.</param>
    /// <param name="TempBlob">The tempblob that was created based on the E-Document format.</param>
    /// <param name="IsAsync">Is sending the document is async.</param>
    /// <remarks>If the E-Document is sent asynchronously, a background job will automatically get queued to fetch the response using GetResponse procedure.</remarks>
    /// <param name="HttpRequest">The HTTP request message object that you should use when sending the request.</param>
    /// <param name="HttpResponse">The HTTP response object that you should use when sending the request.</param>
    /// <remarks>If http response is populated, the response content and headers will be logged automatically to communication logs.</remarks>
    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage);

    /// <summary>
    /// Use it to define how many received documents in batch import.
    /// </summary>
    /// <param name="TempBlob">The tempblob that was received from the external service.</param>
    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer;

    /// <summary>
    /// Use it to define the integration setup of a service
    /// </summary>
    /// <param name="SetupPage">The E-Document integration page id.</param>
    /// <param name="SetupTable">The E-Dcoument integration table id.</param>
    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer);
}
