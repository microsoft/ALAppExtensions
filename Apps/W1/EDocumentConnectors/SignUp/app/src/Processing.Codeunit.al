// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using System.Utilities;

codeunit 6388 Processing
{
    Access = Internal;

    #region variables
    var
        ProcessingImpl: Codeunit ProcessingImpl;

    #endregion

    #region public methods

    /// <summary>
    /// The method sends the E-Document to the API.
    /// </summary>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="TempBlob">TempBlob</param>
    /// <param name="IsAsync">IsAsync</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    procedure SendEDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        this.ProcessingImpl.SendEDocument(EDocument, TempBlob, IsAsync, HttpRequestMessage, HttpResponseMessage);
    end;

    /// <summary>
    /// The method gets the E-Document response.
    /// </summary>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure GetDocumentResponse(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.ProcessingImpl.GetDocumentResponse(EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method gets the E-Document sent response.
    /// </summary>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure GetDocumentSentResponse(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.ProcessingImpl.GetDocumentSentResponse(EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method gets the E-Document approval.
    /// </summary>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure GetDocumentApproval(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.ProcessingImpl.GetDocumentApproval(EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method receives the document.
    /// </summary>
    /// <param name="TempBlob">TempBlob</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        this.ProcessingImpl.ReceiveDocument(TempBlob, HttpRequestMessage, HttpResponseMessage);
    end;

    /// <summary>
    /// The method gets the document count in batch.
    /// </summary>
    /// <param name="TempBlob">TempBlob</param>
    /// <returns>True - if completed successfully</returns>
    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    begin
        exit(this.ProcessingImpl.GetDocumentCountInBatch(TempBlob));
    end;

    /// <summary>
    /// The method inserts the integration log.
    /// </summary>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="EDocumentService">E-Document Service record</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    procedure InsertIntegrationLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequestMessage: HttpRequestMessage; HttpResponseMessage: HttpResponseMessage)
    begin
        this.ProcessingImpl.InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);
    end;

    /// <summary>
    /// The method inserts the log with integration.
    /// </summary>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="EDocumentService">E-Document Service record</param>
    /// <param name="EDocumentServiceStatus">E-Document Service Status</param>
    /// <param name="EDocDataStorageEntryNo">E-Document Data Storage Entry No.</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    procedure InsertLogWithIntegration(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service";
                EDocumentServiceStatus: Enum "E-Document Service Status"; EDocDataStorageEntryNo: Integer; HttpRequestMessage: HttpRequestMessage; HttpResponseMessage: HttpResponseMessage)
    begin
        this.ProcessingImpl.InsertLogWithIntegration(EDocument, EDocumentService, EDocumentServiceStatus, EDocDataStorageEntryNo, HttpRequestMessage, HttpResponseMessage);
    end;

    #endregion
}