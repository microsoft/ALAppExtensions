// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Telemetry;
using System.Threading;
using Microsoft.EServices.EDocument;

codeunit 6384 GetReadyStatusJob
{
    TableNo = "Job Queue Entry";
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocTelemetryGetResponseScopeStartLbl: Label 'E-Document Get Response: Start Scope', Locked = true;
        EDocTelemetryGetResponseScopeEndLbl: Label 'E-Document Get Response: End Scope', Locked = true;

    trigger OnRun()
    var
        JobHelperImpl: Codeunit JobHelperImpl;
        BlankRecordId: RecordId;
    begin
        if not this.IsEDocumentStatusSent() then
            exit;

        this.ProcessSentDocuments();

        if this.IsEDocumentStatusSent() then
            JobHelperImpl.ScheduleEDocumentJob(Codeunit::GetReadyStatusJob, BlankRecordId, 300000);
    end;

    local procedure ProcessSentDocuments()
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        JobHelperImpl: Codeunit JobHelperImpl;
    begin
        EDocumentServiceStatus.SetLoadFields("E-Document Service Code", "E-Document Entry No");
        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus.Status::Sent);
        if EDocumentServiceStatus.FindSet() then
            repeat
                JobHelperImpl.FetchEDocumentAndService(EDocument, EDocumentService, EDocumentServiceStatus);
                this.HandleResponse(EDocument, EDocumentService);
            until EDocumentServiceStatus.Next() = 0;
    end;

    local procedure HandleResponse(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        Processing: Codeunit Processing;
        JobHelperImpl: Codeunit JobHelperImpl;
        BlankRecordId: RecordId;
        HttpResponseMessage: HttpResponseMessage;
        HttpRequestMessage: HttpRequestMessage;
    begin
        if this.GetResponse(EDocument, HttpRequestMessage, HttpResponseMessage) then begin
            Processing.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::Approved, 0, HttpRequestMessage, HttpResponseMessage);
            JobHelperImpl.ScheduleEDocumentJob(Codeunit::PatchSentJob, BlankRecordId, 300000);
        end;
    end;

    local procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage) ReturnStatus: Boolean
    var
        Processing: Codeunit Processing;
        Telemetry: Codeunit Telemetry;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit before create document with error handling
        Commit();

        Telemetry.LogMessage('', this.EDocTelemetryGetResponseScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        if Processing.GetDocumentSentResponse(EDocument, HttpRequestMessage, HttpResponseMessage) then
            ReturnStatus := true;

        Telemetry.LogMessage('', this.EDocTelemetryGetResponseScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure IsEDocumentStatusSent(): Boolean
    var
        EdocumentServiceStatus: Record "E-Document Service Status";
    begin
        EdocumentServiceStatus.SetRange(Status, EdocumentServiceStatus.Status::Sent);
        exit(not EdocumentServiceStatus.IsEmpty());
    end;
}