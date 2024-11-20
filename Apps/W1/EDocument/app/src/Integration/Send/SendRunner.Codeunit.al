// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Send;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

#if not CLEAN26
using System.Utilities;
using Microsoft.eServices.EDocument.Integration;
#endif

codeunit 6146 "Send Runner"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
#if not CLEAN26
        if EDocumentService."Service Integration V2" <> Enum::"Service Integration"::"No Integration" then
            SendV2()
        else
            if EDocumentService."Use Batch Processing" then
                SendBatch()
            else
                Send();
#else
        SendV2();
#endif
    end;

#if not CLEAN26
    local procedure Send()
    begin
        this.TempBlob := SendContext.GetTempBlob();
        IEDocIntegration := this.EDocumentService."Service Integration";
        IEDocIntegration.Send(this.EDocument, this.TempBlob, this.IsAsyncValue, this.HttpRequestMessage, this.HttpResponseMessage);
        SendContext.Http().SetHttpRequestMessage(this.HttpRequestMessage);
        SendContext.Http().SetHttpResponseMessage(this.HttpResponseMessage);
    end;

    local procedure SendBatch()
    begin
        this.TempBlob := SendContext.GetTempBlob();
        IEDocIntegration := this.EDocumentService."Service Integration";
        IEDocIntegration.SendBatch(this.EDocument, this.TempBlob, this.IsAsyncValue, this.HttpRequestMessage, this.HttpResponseMessage);
        SendContext.Http().SetHttpRequestMessage(this.HttpRequestMessage);
        SendContext.Http().SetHttpResponseMessage(this.HttpResponseMessage);
    end;
#endif

    local procedure SendV2()
    begin
        IDocumentSender := this.EDocumentService."Service Integration V2";
        IDocumentSender.Send(this.EDocument, this.EDocumentService, SendContext);
        this.IsAsyncValue := IDocumentSender is IDocumentResponseHandler;
    end;

    procedure SetContext(SendContext: Codeunit SendContext)
    begin
        this.SendContext := SendContext;
    end;

    procedure SetDocumentAndService(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service")
    begin
        this.EDocument.Copy(EDocument);
        this.EDocumentService.Copy(EDocumentService);
    end;

    procedure GetDocumentAndService(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service")
    begin
        EDocument.Copy(this.EDocument);
        EDocumentService.Copy(this.EDocumentService);
    end;

    procedure GetIsAsync(): Boolean
    begin
        exit(this.IsAsyncValue);
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        SendContext: Codeunit SendContext;
#if not CLEAN26
        TempBlob: Codeunit "Temp Blob";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        IEDocIntegration: Interface "E-Document Integration";
#endif
        IDocumentSender: Interface IDocumentSender;
        IsAsyncValue: Boolean;
}
