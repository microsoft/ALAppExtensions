// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Receive;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

/// <summary>
/// Codeunit to run MarkFetched from Fetchable Interface
/// </summary>
codeunit 6181 "Mark Fetched"
{
    Access = Internal;

    trigger OnRun()
    begin
        Receiver := this.EDocumentService."Service Integration";
        if Receiver is Fetchable then
            (Receiver as Fetchable).MarkFetched(this.EDocument, this.EDocumentService, this.DownloadedBlob, this.HttpRequestMessage, this.HttpResponseMessage);
    end;

    procedure SetParameters(var EDoc: Record "E-Document"; var EDocService: Record "E-Document Service"; var DocBlob: Codeunit "Temp Blob")
    begin
        this.EDocument.Copy(EDoc);
        this.EDocumentService.Copy(EDocService);
        this.DownloadedBlob := DocBlob;
    end;

    procedure GetParameters(var EDoc: Record "E-Document"; var EDocService: Record "E-Document Service"; var RequestMessage: HttpRequestMessage; var ResponseMessage: HttpResponseMessage)
    begin
        EDoc.Copy(this.EDocument);
        EDocService.Copy(this.EDocumentService);
        RequestMessage := this.HttpRequestMessage;
        ResponseMessage := this.HttpResponseMessage;
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        DownloadedBlob: Codeunit "Temp Blob";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Receiver: Interface Receiver;
}
