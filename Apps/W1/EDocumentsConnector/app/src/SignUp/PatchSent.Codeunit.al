// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Threading;
using Microsoft.EServices.EDocument;

codeunit 6387 PatchSent
{
    TableNo = "Job Queue Entry";
    Access = Internal;

    trigger OnRun()
    var
        GetReadyStatus: Codeunit GetReadyStatus;
        BlankRecordId: RecordId;
    begin
        if not IsEDocumentApproved() then
            exit;

        ProcessApprovedDocuments();

        if IsEDocumentApproved() then
            GetReadyStatus.ScheduleEDocumentJob(Codeunit::PatchSent, BlankRecordId, 300000);
    end;

    local procedure ProcessApprovedDocuments()
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentService: Record "E-Document Service";
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        EDocument: Record "E-Document";
        APIRequests: Codeunit APIRequests;
        SignUpProcessing: Codeunit SignUpProcessing;
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
    begin
        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus.Status::Approved);
        if EDocumentServiceStatus.FindSet() then
            repeat
                FetchEDocumentAndService(EDocument, EDocumentService, EDocumentServiceStatus);

                EDocumentIntegrationLog.Reset();
                EDocumentIntegrationLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
                EDocumentIntegrationLog.SetRange("Response Status", 204);
                EDocumentIntegrationLog.SetRange(Method, 'PATCH');
                if EDocumentIntegrationLog.IsEmpty then
                    if APIRequests.PatchADocument(EDocument, HttpRequest, HttpResponse) then
                        SignUpProcessing.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
            until EDocumentServiceStatus.Next() = 0;
    end;

    local procedure FetchEDocumentAndService(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status")
    begin
        EDocumentService.Get(EDocumentServiceStatus."E-Document Service Code");
        EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
    end;

    local procedure IsEDocumentApproved(): Boolean
    var
        EdocumentServiceStatus: Record "E-Document Service Status";
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        HasRecords: Boolean;
    begin
        EdocumentServiceStatus.SetRange(Status, EdocumentServiceStatus.Status::Approved);
        if EdocumentServiceStatus.FindSet() then
            repeat
                EDocumentIntegrationLog.Reset();
                EDocumentIntegrationLog.SetRange("E-Doc. Entry No", EdocumentServiceStatus."E-Document Entry No");
                EDocumentIntegrationLog.SetRange("Response Status", 204);
                EDocumentIntegrationLog.SetRange(Method, 'PATCH');
                if EDocumentIntegrationLog.IsEmpty then
                    HasRecords := true;

            until (EdocumentServiceStatus.Next() = 0) or (HasRecords);

        exit(HasRecords);
    end;
}