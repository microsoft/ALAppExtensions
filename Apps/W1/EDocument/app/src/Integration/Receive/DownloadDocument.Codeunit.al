// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Receive;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

codeunit 6180 "Download Document"
{
    Access = Internal;

    trigger OnRun()
    begin
        EDocumentService.TestField(Code);
#if not CLEAN26
        EDocIntegration := EDocumentService."Service Integration";
        if EDocIntegration is Receive then begin
            ReceiveInterface := EDocumentService."Service Integration";
            ReceiveInterface.DownloadDocument(EDocument, EDocumentService, DocumentsBlob, DownloadedBlob, HttpRequestMessage, HttpResponseMessage);
        end;
#else
        ReceiveInterface := EDocumentService."Service Integration";
        ReceiveInterface.DownloadDocument(EDocument, EDocumentService, DocumentsBlob, DownloadedBlob, HttpRequestMessage, HttpResponseMessage);
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
        ReceiveInterface: Interface Receive;
#if not CLEAN26
        EDocIntegration: Interface "E-Document Integration";
#endif
}
