// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Integration.Interfaces;

codeunit 6149 "E-Document Response"
{
    Access = Internal;

    trigger OnRun()
    begin
#if not CLEAN26
        IEDocIntegration := EDocumentService."Service Integration";
        if IEDocIntegration is Send then begin
            SendInterface := EDocumentService."Service Integration";
            Result := SendInterface.GetResponse(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);
        end else
            Result := IEDocIntegration.GetResponse(EDocument, HttpRequestMessage, HttpResponseMessage);

#else
        SendInterface := EDocumentService."Service Integration";
        Result := SendInterface.GetResponse(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);
#endif
    end;

    procedure SetParameters(var EDoc: Record "E-Document"; var Service: Record "E-Document Service")
    begin
        this.EDocument.Copy(EDoc);
        this.EDocumentService.Copy(Service);
    end;

    procedure GetParameters(var EDoc: Record "E-Document"; var Service: Record "E-Document Service"; var RequestMessage: HttpRequestMessage; var ResponseMessage: HttpResponseMessage)
    begin
        EDoc.Copy(this.EDocument);
        Service.Copy(this.EDocumentService);
        RequestMessage := this.HttpRequestMessage;
        ResponseMessage := this.HttpResponseMessage;
    end;

    procedure GetResponseResult(): Boolean
    begin
        exit(Result);
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
#if not CLEAN26
        IEDocIntegration: Interface "E-Document Integration";
#endif
        SendInterface: Interface Send;
        Result: Boolean;
}
