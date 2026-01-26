// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;

using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration.Send;
using System.Utilities;

codeunit 10779 "Verifactu Sender" implements IDocumentSender, IDocumentReceiver
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    var
        VerifactuDocUploadMgt: Codeunit "Verifactu Doc. Upload Mgt.";
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob := SendContext.GetTempBlob();

        VerifactuDocUploadMgt.SendEDocument(TempBlob, EDocument, SendContext);
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    begin
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    begin
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnBeforeOpenServiceIntegrationSetupPage, '', false, false)]
    local procedure OnBeforeOpenServiceIntegrationSetupPage(EDocumentService: Record "E-Document Service"; var IsServiceIntegrationSetupRun: Boolean)
    var
        VerifactuSetup: Page "Verifactu Setup";
    begin
        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::"Verifactu Service" then
            exit;

        VerifactuSetup.RunModal();
        IsServiceIntegrationSetupRun := true;
    end;
}