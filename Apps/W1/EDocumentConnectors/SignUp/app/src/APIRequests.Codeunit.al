// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using System.Utilities;


codeunit 6380 APIRequests
{
    Access = Internal;

    var
        APIRequestsImpl: Codeunit APIRequestsImpl;

    #region public methods

    /// <summary>
    /// The method sends a file to the API.
    /// https://[BASEURL]/api/Peppol    
    /// </summary>
    /// <param name="TempBlob">TempBlob</param>
    /// <param name="EDocument">EDocument table</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure SendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.APIRequestsImpl.SendFilePostRequest(TempBlob, EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method checks the status of the sent document.
    /// https://[BASE URL]/api/Peppol/status?peppolInstanceId=
    /// </summary>
    /// <param name="EDocument">EDocument table</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure GetSentDocumentStatus(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.APIRequestsImpl.GetSentDocumentStatus(EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method modifies the document.
    /// https://[BASE URL]/api/Peppol/outbox?peppolInstanceId=
    /// </summary>
    /// <param name="EDocument">EDocument table</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure PatchDocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.APIRequestsImpl.PatchDocument(EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method gets the received document request.
    /// https://[BASE URL]/api/Peppol/Inbox?peppolId=
    /// </summary>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>    
    /// <returns>True if successfully completed</returns>
    procedure GetReceivedDocumentsRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.APIRequestsImpl.GetReceivedDocumentsRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method gets the target document request.
    /// https://[BASE URL]/api/Peppol/inbox-document?peppolId=
    /// </summary>
    /// <param name="DocumentId">Document ID</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure GetTargetDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.APIRequestsImpl.GetTargetDocumentRequest(DocumentId, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method modifies the received document.
    /// // https://[BASE URL]/api/Peppol/inbox?peppolInstanceId=
    /// </summary>
    /// <param name="EDocument">EDocument table</param>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure PatchReceivedDocument(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.APIRequestsImpl.PatchReceivedDocument(EDocument, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// The method gets the marketplace credentials.
    /// </summary>
    /// <param name="HttpRequestMessage">Http Request Message</param>
    /// <param name="HttpResponseMessage">Http Response Message</param>
    /// <returns>True if successfully completed</returns>
    procedure GetMarketPlaceCredentials(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        exit(this.APIRequestsImpl.GetMarketPlaceCredentials(HttpRequestMessage, HttpResponseMessage));
    end;

    #endregion
}