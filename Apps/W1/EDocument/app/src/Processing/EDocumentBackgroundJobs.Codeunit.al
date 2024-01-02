// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Telemetry;
using System.Threading;

codeunit 6133 "E-Document Background Jobs"
{
    Access = Internal;
    Permissions =
            tabledata "E-Document" = m,
            tabledata "E-Document Service" = m,
            tabledata "Job Queue Entry" = im;

    procedure StartEdocumentCreatedFlow(EDocument: Record "E-Document")
    begin
        EDocument."Job Queue Entry ID" := ScheduleEDocumentJob(Codeunit::"E-Document Created Flow", EDocument.RecordId(), 0);
        EDocument.Modify();
    end;

    procedure GetEDocumentResponse()
    begin
        GetEDocumentResponse(true);
    end;

    procedure GetEDocumentResponse(SkipSchedulingIfJobExists: Boolean)
    var
        BlankRecord: RecordId;
    begin
        if SkipSchedulingIfJobExists and IsJobQueueScheduled(Codeunit::"E-Document Get Response") then
            exit;

        //  Run background job every 5 minutes (300 second) to check the status of async documents.
        ScheduleEDocumentJob(Codeunit::"E-Document Get Response", BlankRecord, 300000);
    end;

    procedure ScheduleRecurrentBatchJob(EDocumentService: Record "E-Document Service")
    var
        JobQueueEntry: Record "Job Queue Entry";
        Telemetry: Codeunit Telemetry;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if not IsRecurrentJobScheduledForAService(EDocumentService."Batch Recurrent Job Id") then begin
            JobQueueEntry.ScheduleRecurrentJobQueueEntryWithFrequency(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Doc. Recurrent Batch Send", EDocumentService.RecordId, EDocumentService."Batch Minutes between runs", EDocumentService."Batch Start Time");
            EDocumentService."Batch Recurrent Job Id" := JobQueueEntry.ID;
            EDocumentService.Modify();

            JobQueueEntry."Rerun Delay (sec.)" := 600;
            JobQueueEntry."No. of Attempts to Run" := 0;
            JobQueueEntry."Job Queue Category Code" := JobQueueCategoryTok;
            JobQueueEntry.Modify();
        end else begin
            JobQueueEntry.Get(EDocumentService."Batch Recurrent Job Id");
            JobQueueEntry."Starting Time" := EDocumentService."Batch Start Time";
            JobQueueEntry."No. of Minutes between Runs" := EDocumentService."Batch Minutes between runs";
            JobQueueEntry."No. of Attempts to Run" := 0;
            JobQueueEntry.Modify();
            if not JobQueueEntry.IsReadyToStart() then
                JobQueueEntry.Restart();
        end;
        TelemetryDimensions.Add('Job Queue Id', JobQueueEntry.ID);
        TelemetryDimensions.Add('Codeunit Id', Format(Codeunit::"E-Document Import Job"));
        TelemetryDimensions.Add('Record Id', Format(EDocumentService.RecordId));
        TelemetryDimensions.Add('User Session ID', Format(JobQueueEntry."User Session ID"));
        TelemetryDimensions.Add('Earliest Start Date/Time', Format(JobQueueEntry."Earliest Start Date/Time"));
        Telemetry.LogMessage('0000LC4', EDocumentJobTelemetryLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
    end;

    procedure ScheduleRecurrentImportJob(EDocumentService: Record "E-Document Service")
    var
        JobQueueEntry: Record "Job Queue Entry";
        Telemetry: Codeunit Telemetry;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if EDocumentService.Code = '' then
            exit;

        if not IsRecurrentJobScheduledForAService(EDocumentService."Import Recurrent Job Id") then begin
            JobQueueEntry.ScheduleRecurrentJobQueueEntryWithFrequency(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Import Job", EDocumentService.RecordId, EDocumentService."Import Minutes between runs", EDocumentService."Import Start Time");
            EDocumentService."Import Recurrent Job Id" := JobQueueEntry.ID;
            EDocumentService.Modify();

            JobQueueEntry."Rerun Delay (sec.)" := 600;
            JobQueueEntry."No. of Attempts to Run" := 0;
            JobQueueEntry."Job Queue Category Code" := JobQueueCategoryTok;
            JobQueueEntry.Modify();
        end else begin
            JobQueueEntry.Get(EDocumentService."Import Recurrent Job Id");
            JobQueueEntry."Starting Time" := EDocumentService."Import Start Time";
            JobQueueEntry."No. of Minutes between Runs" := EDocumentService."Import Minutes between runs";
            JobQueueEntry."No. of Attempts to Run" := 0;
            JobQueueEntry.Modify();
            if not JobQueueEntry.IsReadyToStart() then
                JobQueueEntry.Restart();
        end;
        TelemetryDimensions.Add('Job Queue Id', JobQueueEntry.ID);
        TelemetryDimensions.Add('Codeunit Id', Format(Codeunit::"E-Document Import Job"));
        TelemetryDimensions.Add('Record Id', Format(EDocumentService.RecordId));
        TelemetryDimensions.Add('User Session ID', Format(JobQueueEntry."User Session ID"));
        TelemetryDimensions.Add('Earliest Start Date/Time', Format(JobQueueEntry."Earliest Start Date/Time"));
        Telemetry.LogMessage('0000LC5', EDocumentJobTelemetryLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
    end;

    procedure HandleRecurrentBatchJob(EDocumentService: Record "E-Document Service")
    begin
        if EDocumentService."Use Batch Processing" then
            if EDocumentService."Batch Mode" = EDocumentService."Batch Mode"::Recurrent then begin
                EDocumentService.TestField("Batch Start Time");
                EDocumentService.TestField("Batch Minutes between runs");
                ScheduleRecurrentBatchJob(EDocumentService);
            end else
                RemoveJob(EDocumentService."Batch Recurrent Job Id");
    end;

    procedure HandleRecurrentImportJob(EDocumentService: Record "E-Document Service")
    begin
        if EDocumentService."Auto Import" then begin
            EDocumentService.TestField("Import Start Time");
            EDocumentService.TestField("Import Minutes between runs");
            ScheduleRecurrentImportJob(EDocumentService);
        end else
            RemoveJob(EDocumentService."Import Recurrent Job Id");
    end;

    procedure RemoveJob(JobId: Guid)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntry.Get(JobId) then
            JobQueueEntry.Delete();
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

    local procedure IsRecurrentJobScheduledForAService(JobId: Guid): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if IsNullGuid(JobId) then
            exit(false);

        exit(JobQueueEntry.Get(JobId));
    end;

    local procedure ScheduleEDocumentJob(CodeunitId: Integer; JobRecordId: RecordId; EarliestStartDateTime: Integer): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        Telemetry: Codeunit Telemetry;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
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
        Telemetry.LogMessage('0000LC6', EDocumentJobTelemetryLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
        exit(JobQueueEntry.ID);
    end;

    var
        JobQueueCategoryTok: Label 'EDocument', Locked = true, Comment = 'Max Length 10';
        EDocumentJobTelemetryLbl: Label 'E-Document Background Job Scheduled', Locked = true;
}
