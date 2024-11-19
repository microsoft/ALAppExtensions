// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Send;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration;

codeunit 6149 "Get Response Runner"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;


    trigger OnRun()
    begin
        if EDocumentService."Service Integration V2" <> Enum::"Service Integration"::"No Integration" then begin
            IDocumentSender := EDocumentService."Service Integration V2";
            if IDocumentSender is IDocumentResponseHandler then
                Result := (IDocumentSender as IDocumentResponseHandler).GetResponse(this.EDocument, this.EDocumentService, SendContext);
            exit;
        end;

#if not CLEAN26
        IEDocIntegration := this.EDocumentService."Service Integration";
        Result := IEDocIntegration.GetResponse(this.EDocument, this.HttpRequestMessage, this.HttpResponseMessage);
        SendContext.Http().SetHttpRequestMessage(this.HttpRequestMessage);
        SendContext.Http().SetHttpResponseMessage(this.HttpResponseMessage);
#endif
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

    procedure SetContext(SendContext: Codeunit SendContext)
    begin
        this.SendContext := SendContext;
    end;

    procedure GetResponseResult(): Boolean
    begin
        exit(Result);
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        SendContext: Codeunit SendContext;
#if not CLEAN26
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        IEDocIntegration: Interface "E-Document Integration";
#endif
        IDocumentSender: Interface IDocumentSender;
        Result: Boolean;
}
