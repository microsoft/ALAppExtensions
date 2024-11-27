// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Receive;

codeunit 6431 "E-Document Integration" implements IDocumentSender, IDocumentReceiver
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext);
    begin
        this.LogiqEDocumentManagement.Send(EDocument, EDocumentService, SendContext);
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
        this.LogiqEDocumentManagement.ReceiveDocuments(EDocumentService, DocumentsMetadata, ReceiveContext);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
        this.LogiqEDocumentManagement.DownloadDocument(EDocument, EDocumentService, DocumentMetadata, ReceiveContext);
    end;


    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var SetupPage: Integer)
    begin
        if EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::Logiq then
            SetupPage := Page::"Connection Setup";
    end;

    var
        LogiqEDocumentManagement: Codeunit "E-Document Management";
}
