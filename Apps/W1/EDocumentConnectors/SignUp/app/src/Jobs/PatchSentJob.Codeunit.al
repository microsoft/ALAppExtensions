// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Threading;
using Microsoft.EServices.EDocument;
using System.Security.Authentication;

codeunit 6387 PatchSentJob
{
    TableNo = "Job Queue Entry";
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        JobHelperImpl: Codeunit JobHelperImpl;
        BlankRecordId: RecordId;
    begin
        if not this.IsEDocumentApproved() then
            exit;

        this.ProcessApprovedDocuments();

        if this.IsEDocumentApproved() then
            JobHelperImpl.ScheduleEDocumentJob(Codeunit::PatchSentJob, BlankRecordId, 300000);
    end;

    local procedure ProcessApprovedDocuments()
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentService: Record "E-Document Service";
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        EDocument: Record "E-Document";
        APIRequests: Codeunit APIRequests;
        Processing: Codeunit Processing;
        JobHelperImpl: Codeunit JobHelperImpl;
        HttpResponseMessage: HttpResponseMessage;
        HttpRequestMessage: HttpRequestMessage;
    begin
        EDocumentServiceStatus.SetLoadFields("E-Document Service Code", "E-Document Entry No");
        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus.Status::Approved);
        if EDocumentServiceStatus.FindSet() then
            repeat
                JobHelperImpl.FetchEDocumentAndService(EDocument, EDocumentService, EDocumentServiceStatus);

                EDocumentIntegrationLog.Reset();
                EDocumentIntegrationLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
                EDocumentIntegrationLog.SetRange("Response Status", 204);
                EDocumentIntegrationLog.SetRange(Method, Format("Http Request Type"::PATCH));
                if EDocumentIntegrationLog.IsEmpty() then
                    if APIRequests.PatchDocument(EDocument, HttpRequestMessage, HttpResponseMessage) then
                        Processing.InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);
            until EDocumentServiceStatus.Next() = 0;
    end;

    local procedure IsEDocumentApproved(): Boolean
    var
        EdocumentServiceStatus: Record "E-Document Service Status";
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        HasRecords: Boolean;
    begin
        EdocumentServiceStatus.SetLoadFields("E-Document Entry No");
        EdocumentServiceStatus.SetRange(Status, EdocumentServiceStatus.Status::Approved);
        if EdocumentServiceStatus.FindSet() then
            repeat
                EDocumentIntegrationLog.Reset();
                EDocumentIntegrationLog.SetRange("E-Doc. Entry No", EdocumentServiceStatus."E-Document Entry No");
                EDocumentIntegrationLog.SetRange("Response Status", 204);
                EDocumentIntegrationLog.SetRange(Method, Format("Http Request Type"::PATCH));
                HasRecords := EDocumentIntegrationLog.IsEmpty();
            until (EdocumentServiceStatus.Next() = 0) or (HasRecords);

        exit(HasRecords);
    end;
}