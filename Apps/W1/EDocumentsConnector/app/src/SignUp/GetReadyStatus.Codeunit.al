// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Telemetry;
using System.Threading;
using Microsoft.EServices.EDocument;

codeunit 6374 SignUpGetReadyStatus
{
    TableNo = "Job Queue Entry";
    Access = Internal;

    trigger OnRun()
    var
        BlankRecordId: RecordId;
    begin
        if not IsEDocumentStatusSent() then
            exit;

        ProcessSentDocuments();

        if IsEDocumentStatusSent() then
            ScheduleEDocumentJob(Codeunit::SignUpGetReadyStatus, BlankRecordId, 300000);
    end;

    local procedure ProcessSentDocuments()
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
    begin
        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus.Status::Sent);
        if EDocumentServiceStatus.FindSet() then
            repeat
                FetchEDocumentAndService(EDocument, EDocumentService, EDocumentServiceStatus);
                HandleResponse(EDocument, EDocumentService, EDocumentServiceStatus);
                FetchEDocumentAndService(EDocument, EDocumentService, EDocumentServiceStatus);
            until EDocumentServiceStatus.Next() = 0;
    end;

    local procedure FetchEDocumentAndService(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status")
    begin
        EDocumentService.Get(EDocumentServiceStatus."E-Document Service Code");
        EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
    end;

    local procedure HandleResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status")
    var
        SignUpProcessing: Codeunit SignUpProcessing;
        BlankRecordId: RecordId;
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
    begin
        if GetResponse(EDocumentServiceStatus, HttpRequest, HttpResponse) then begin
            SignUpProcessing.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::Approved, 0, HttpRequest, HttpResponse);
            ScheduleEDocumentJob(Codeunit::SignUpPatchSent, BlankRecordId, 300000);
        end;

    end;

    local procedure GetResponse(var EDocumentServiceStatus: Record "E-Document Service Status"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage) ReturnStatus: Boolean
    var
        EDocument: Record "E-Document";
        SignUpProcessing: Codeunit SignUpProcessing;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit before create document with error handling
        Commit();
        Telemetry.LogMessage('', EDocTelemetryGetResponseScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        EDocument.Get(EDocumentServiceStatus."E-Document Entry No");

        if SignUpProcessing.GetDocumentSentResponse(EDocument, HttpRequest, HttpResponse) then
            ReturnStatus := true;

        Telemetry.LogMessage('', EDocTelemetryGetResponseScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure IsEDocumentStatusSent(): Boolean
    var
        EdocumentServiceStatus: Record "E-Document Service Status";
    begin
        EdocumentServiceStatus.SetRange(Status, EdocumentServiceStatus.Status::Sent);
        exit(not EdocumentServiceStatus.IsEmpty());
    end;

    procedure ScheduleEDocumentJob(CodeunitId: Integer; JobRecordId: RecordId; EarliestStartDateTime: Integer): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if IsJobQueueScheduled(CodeunitId) then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CodeunitId;
        JobQueueEntry."Record ID to Process" := JobRecordId;
        JobQueueEntry."User Session ID" := SessionId();
        JobQueueEntry."Job Queue Category Code" := JobQueueCategoryTok;
        JobQueueEntry."No. of Attempts to Run" := 0;
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime + EarliestStartDateTime;

        TelemetryDimensions.Add('Job Queue Id', JobQueueEntry.ID);
        TelemetryDimensions.Add('Codeunit Id', Format(CodeunitId));
        TelemetryDimensions.Add('Record Id', Format(JobRecordId));
        TelemetryDimensions.Add('User Session ID', Format(JobQueueEntry."User Session ID"));
        TelemetryDimensions.Add('Earliest Start Date/Time', Format(JobQueueEntry."Earliest Start Date/Time"));
        Telemetry.LogMessage('', EDocumentJobTelemetryLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
        exit(JobQueueEntry.ID);
    end;

    local procedure IsJobQueueScheduled(CodeunitId: Integer): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitId);
        JobQueueEntry.SetFilter(Status, '%1|%2', JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process");
        if not JobQueueEntry.IsEmpty() then
            exit(true);
    end;

    var
        Telemetry: Codeunit Telemetry;
        EDocTelemetryGetResponseScopeStartLbl: Label 'E-Document Get Response: Start Scope', Locked = true;
        EDocTelemetryGetResponseScopeEndLbl: Label 'E-Document Get Response: End Scope', Locked = true;
        JobQueueCategoryTok: Label 'EDocument', Locked = true, Comment = 'Max Length 10';
        EDocumentJobTelemetryLbl: Label 'E-Document Background Job Scheduled', Locked = true;
}