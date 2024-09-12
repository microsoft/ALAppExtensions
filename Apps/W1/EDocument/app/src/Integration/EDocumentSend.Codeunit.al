// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Utilities;

codeunit 6146 "E-Document Send"
{
    Access = Internal;

    trigger OnRun()
    begin
        if EDocumentService."Use Batch Processing" then
            CreateBatch()
        else
            Send();
    end;

    local procedure Send()
    begin
        EDocumentIntegrationInterface := EDocumentService."Service Integration";
        EDocumentIntegrationInterface.Send(EDocument, TempBlob, IsAsync2, HttpRequest, HttpResponse);
    end;

    local procedure CreateBatch()
    begin
        EDocumentIntegrationInterface := EDocumentService."Service Integration";
        EDocumentIntegrationInterface.SendBatch(EDocument, TempBlob, IsAsync2, HttpRequest, HttpResponse);
    end;

    procedure SetSource(var EDocService: Record "E-Document Service"; var EDocument2: Record "E-Document"; var TempBlob2: Codeunit "Temp Blob"; var HttpRequest2: HttpRequestMessage; var HttpResponse2: HttpResponseMessage)
    begin
        EDocumentService.Copy(EDocService);
        EDocument.Copy(EDocument2);
        TempBlob := TempBlob2;
        HttpResponse := HttpResponse2;
        HttpRequest := HttpRequest2;
    end;

    procedure GetSource(var EDocService: Record "E-Document Service"; var EDocument2: Record "E-Document"; var HttpRequest2: HttpRequestMessage; var HttpResponse2: HttpResponseMessage)
    begin
        EDocService.Copy(EDocumentService);
        EDocument2.Copy(EDocument);
        HttpRequest2 := HttpRequest;
        HttpResponse2 := HttpResponse;
    end;

    procedure IsAsync(): Boolean
    begin
        exit(IsAsync2);
    end;

    procedure GetRequestResponse(var HttpRequest2: HttpRequestMessage; var HttpResponse2: HttpResponseMessage)
    begin
        HttpRequest2 := HttpRequest;
        HttpResponse2 := HttpResponse;
    end;

    var
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        IsAsync2: Boolean;
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        EDocumentIntegrationInterface: Interface "E-Document Integration";
}
