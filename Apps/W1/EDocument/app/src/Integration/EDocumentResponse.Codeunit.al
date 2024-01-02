// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

codeunit 6149 "E-Document Response"
{
    Access = Internal;

    trigger OnRun()
    var
        EDocument: Record "E-Document";
    begin
        EDocumentIntegrationInterface := EDocumentService."Service Integration";
        EDocument.Get(EdocumentServiceStatus."E-Document Entry No");
        GetResponseBooleanResult := EDocumentIntegrationInterface.GetResponse(EDocument, HttpRequest, HttpResponse);
    end;

    procedure SetSource(EDocService2: Record "E-Document Service"; var EDocumentServiceStatus2: Record "E-Document Service Status"; var HttpRequest2: HttpRequestMessage; var HttpResponse2: HttpResponseMessage)
    begin
        EDocumentService.Copy(EDocService2);
        EdocumentServiceStatus.Copy(EDocumentServiceStatus2);
        HttpResponse := HttpResponse2;
        HttpRequest := HttpRequest2;
    end;

    procedure GetResponseResult(): Boolean
    begin
        exit(GetResponseBooleanResult);
    end;

    procedure GetRequestResponse(var HttpRequest2: HttpRequestMessage; var HttpResponse2: HttpResponseMessage)
    begin
        HttpRequest2 := HttpRequest;
        HttpResponse2 := HttpResponse;
    end;


    var
        EDocumentService: Record "E-Document Service";
        EdocumentServiceStatus: Record "E-Document Service Status";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        EDocumentIntegrationInterface: Interface "E-Document Integration";
        GetResponseBooleanResult: Boolean;
}
