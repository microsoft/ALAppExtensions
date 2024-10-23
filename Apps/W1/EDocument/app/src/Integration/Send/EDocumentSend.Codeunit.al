// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Integration.Interfaces;
using System.Utilities;

codeunit 6146 "E-Document Send"
{
    Access = Internal;

    trigger OnRun()
    begin
        if EDocumentService."Use Batch Processing" then
            SendBatch()
        else
            Send();
    end;

    local procedure Send()
    begin
#if not CLEAN26
        IEDocIntegration := EDocumentService."Service Integration";
        if IEDocIntegration is Send then begin
            SendInterface := EDocumentService."Service Integration";
            SendInterface.Send(EDocument, EDocumentService, TempBlob, HttpRequestMessage, HttpResponseMessage, IsAsyncValue);
        end else
            IEDocIntegration.Send(EDocument, TempBlob, IsAsyncValue, HttpRequestMessage, HttpResponseMessage);

#else
        SendInterface := EDocumentService."Service Integration";
        SendInterface.Send(EDocument, EDocumentService, TempBlob, HttpRequestMessage, HttpResponseMessage, IsAsyncValue);
#endif
    end;

    local procedure SendBatch()
    begin
#if not CLEAN26
        IEDocIntegration := EDocumentService."Service Integration";
        if IEDocIntegration is Send then begin
            SendInterface := EDocumentService."Service Integration";
            SendInterface.SendBatch(EDocument, EDocumentService, TempBlob, HttpRequestMessage, HttpResponseMessage, IsAsyncValue);
        end else
            IEDocIntegration.SendBatch(EDocument, TempBlob, IsAsyncValue, HttpRequestMessage, HttpResponseMessage);
#else
        SendInterface := EDocumentService."Service Integration";
        SendInterface.SendBatch(EDocument, EDocumentService, TempBlob, HttpRequestMessage, HttpResponseMessage, IsAsyncValue);
#endif
    end;

    procedure SetParameters(var EDoc: Record "E-Document"; var Service: Record "E-Document Service"; var Blob: Codeunit "Temp Blob")
    begin
        this.EDocument.Copy(EDoc);
        this.EDocumentService.Copy(Service);
        this.TempBlob := Blob;
    end;

    procedure GetParameters(var EDoc: Record "E-Document"; var Service: Record "E-Document Service"; var Blob: Codeunit "Temp Blob"; var RequestMessage: HttpRequestMessage; var ResponseMessage: HttpResponseMessage)
    begin
        EDoc.Copy(this.EDocument);
        Service.Copy(this.EDocumentService);
        Blob := this.TempBlob;
        RequestMessage := this.HttpRequestMessage;
        ResponseMessage := this.HttpResponseMessage;
    end;

    procedure IsAsync(): Boolean
    begin
        exit(IsAsyncValue);
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
#if not CLEAN26
        IEDocIntegration: Interface "E-Document Integration";
#endif
        SendInterface: Interface Send;
        IsAsyncValue: Boolean;
}
