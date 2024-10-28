// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.EServices.EDocument;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using System.Utilities;

codeunit 6391 ConnectionImpl
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "E-Document" = m;

    #region variables

    var
        APIRequests: Codeunit APIRequests;
        HelpersImpl: Codeunit HelpersImpl;
        UnsuccessfulResponseErr: Label 'There was an error sending the request. Response code: %1 and error message: %2', Comment = '%1 - http response status code, e.g. 400, %2- error message';
        EnvironmentBlocksErr: Label 'The request to send documents has been blocked. To resolve the problem, enable outgoing HTTP requests for the E-Document apps on the Extension Management page.';

    #endregion

    #region public methods

    procedure SendFilePostRequest(var TempBlob: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        this.APIRequests.SendFilePostRequest(TempBlob, EDocument, HttpRequestMessage, HttpResponseMessage);
        exit(this.CheckIfSuccessfulRequest(EDocument, HttpResponseMessage));
    end;

    procedure CheckDocumentStatus(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        this.APIRequests.GetSentDocumentStatus(EDocument, HttpRequestMessage, HttpResponseMessage);
        exit(this.CheckIfSuccessfulRequest(EDocument, HttpResponseMessage));
    end;

    procedure GetReceivedDocuments(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        this.APIRequests.GetReceivedDocumentsRequest(HttpRequestMessage, HttpResponseMessage);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            exit;

        exit(this.HelpersImpl.ParseJsonString(HttpResponseMessage.Content) <> '');
    end;

    procedure GetTargetDocumentRequest(DocumentId: Text; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        this.APIRequests.GetTargetDocumentRequest(DocumentId, HttpRequestMessage, HttpResponseMessage);
        exit(HttpResponseMessage.IsSuccessStatusCode());
    end;

    procedure RemoveDocumentFromReceived(EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    begin
        this.APIRequests.PatchReceivedDocument(EDocument, HttpRequestMessage, HttpResponseMessage);
        exit(HttpResponseMessage.IsSuccessStatusCode());
    end;

    #endregion

    #region local methods

    local procedure CheckIfSuccessfulRequest(EDocument: Record "E-Document"; HttpResponseMessage: HttpResponseMessage): Boolean
    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
    begin
        if HttpResponseMessage.IsSuccessStatusCode() then
            exit(true);

        if HttpResponseMessage.IsBlockedByEnvironment() then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, this.EnvironmentBlocksErr)
        else
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(this.UnsuccessfulResponseErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase));
    end;

    #endregion

    #region event subscribers

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterCheckAndUpdate, '', false, false)]
    local procedure CheckOnPosting(var PurchaseHeader: Record "Purchase Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        if PurchaseHeader.IsTemporary() then
            exit;

        EDocument.SetLoadFields("Entry No");
        EDocument.SetRange("Document Record ID", PurchaseHeader.RecordId);
        if not EDocument.FindFirst() then
            exit;

        EDocumentService.SetLoadFields(Code);
        EDocumentService.SetRange("Service Integration", EDocumentService."Service Integration"::"ExFlow E-Invoicing");
        if not EDocumentService.FindFirst() then
            exit;

        EDocumentServiceStatus.SetLoadFields(Status);
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocumentServiceStatus.TestField(EDocumentServiceStatus.Status, EDocumentServiceStatus.Status::Approved);
            until EDocumentServiceStatus.Next() = 0;
    end;

    #endregion
}