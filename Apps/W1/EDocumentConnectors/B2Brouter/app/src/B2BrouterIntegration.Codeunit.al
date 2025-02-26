// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;

using System.Utilities;
using Microsoft.EServices.EDocument;
using Microsoft.EServices.EDocument.Integration.Send;
using Microsoft.EServices.EDocument.Integration.Receive;
using Microsoft.EServices.EDocument.Integration.Interfaces;

codeunit 71107795 "B2Brouter Integration" implements IDocumentSender, IDocumentReceiver, IDocumentResponseHandler, IReceivedDocumentMarker
{
    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    var
        IsAsync: Boolean;
    begin
        IsAsync := true;

        ApiManagement.SendDocument(EDocument, SendContext, IsAsync);
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        ApiManagement.ReceiveDocuments(EDocumentService, DocumentsMetadata, ReceiveContext);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        ApiManagement.DownloadDocument(EDocument, EDocumentService, DocumentMetadata, ReceiveContext);
    end;

    procedure GetResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext): Boolean
    var
        Success: Boolean;
    begin
        Success := ApiManagement.GetResponse(EDocument, SendContext);
        exit(Success);
    end;

    procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
    begin
        ApiManagement.MarkFetched(EDocument."B2Brouter File Id", ReceiveContext);
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure "E-Document Service_OnBeforeOpenServiceIntegrationSetupPage"(EDocumentService: Record "E-Document Service"; var IsServiceIntegrationSetupRun: Boolean)
    var
        B2BrouterSetupCard: page "B2Brouter Setup";
    begin
        if EDocumentService."Service Integration V2" <> Enum::Microsoft.EServices.EDocument.Integration."Service Integration"::B2Brouter then
            exit;

        B2BrouterSetupCard.RunModal();
        IsServiceIntegrationSetupRun := true;
    end;

    var
        ApiManagement: Codeunit "B2Brouter API Management";
}