// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using System.Utilities;

codeunit 6382 Connection
{
    Access = Internal;

    var
        ConnectionImpl: Codeunit ConnectionImpl;

    /// <summary>
    /// The methods sends a file to the API.
    /// </summary>
    /// <param name="TempBlob">Content</param>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True - if completed successfully</returns>
    procedure SendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.ConnectionImpl.SendFilePostRequest(TempBlob, EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method checks the status of the document.
    /// </summary>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure CheckDocumentStatus(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.ConnectionImpl.CheckDocumentStatus(EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method gets received documents.
    /// </summary>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure GetReceivedDocuments(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.ConnectionImpl.GetReceivedDocuments(HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method gets the target document.
    /// </summary>
    /// <param name="DocumentId">DocumentId</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure GetTargetDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.ConnectionImpl.GetTargetDocumentRequest(DocumentId, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method removes the document from received.
    /// </summary>
    /// <param name="EDocument">E-Document record</param>
    /// <param name="HttpRequestMessage">HttpRequestMessage</param>
    /// <param name="HttpResponseMessage">HttpResponseMessage</param>
    /// <returns>True - if completed successfully</returns>
    procedure RemoveDocumentFromReceived(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.ConnectionImpl.RemoveDocumentFromReceived(EDocument, HttpRequestMessage, HttpResponseMessage));
    end;
}