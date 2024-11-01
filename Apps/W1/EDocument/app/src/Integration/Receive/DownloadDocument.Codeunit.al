// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Receive;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

/// <summary>
/// Codeunit to run DownloadDocument from Receive Interface
/// </summary>
codeunit 6180 "Download Document"
{
    Access = Internal;

    trigger OnRun()
    begin
        this.EDocumentService.TestField(Code);
#if not CLEAN26
        EDocIntegration := this.EDocumentService."Service Integration";
        if EDocIntegration is Receiver then begin
            ReceiveInterface := this.EDocumentService."Service Integration";
            ReceiveInterface.DownloadDocument(this.EDocument, this.EDocumentService, this.DocumentsBlob, this.DownloadedBlob, this.HttpRequestMessage, this.HttpResponseMessage);
        end;
#else
        ReceiveInterface := this.EDocumentService."Service Integration";
        ReceiveInterface.DownloadDocument(this.EDocument, this.EDocumentService, this.DocumentsBlob, this.DownloadedBlob, this.HttpRequestMessage, this.HttpResponseMessage);
#endif
    end;

    procedure SetParameters(var EDoc: Record "E-Document"; var EDocService: Record "E-Document Service"; var DocsBlob: Codeunit "Temp Blob")
    begin
        this.EDocument.Copy(EDoc);
        this.EDocumentService.Copy(EDocService);
        this.DocumentsBlob := DocsBlob;
    end;

    procedure GetParameters(var EDoc: Record "E-Document"; var EDocService: Record "E-Document Service"; var DocBlob: Codeunit "Temp Blob"; var RequestMessage: HttpRequestMessage; var ResponseMessage: HttpResponseMessage)
    begin
        EDoc.Copy(this.EDocument);
        EDocService.Copy(this.EDocumentService);
        DocBlob := this.DownloadedBlob;
        RequestMessage := this.HttpRequestMessage;
        ResponseMessage := this.HttpResponseMessage;
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        DocumentsBlob, DownloadedBlob : Codeunit "Temp Blob";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ReceiveInterface: Interface Receiver;
#if not CLEAN26
        EDocIntegration: Interface "E-Document Integration";
#endif
}
