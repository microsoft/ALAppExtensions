// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Telemetry;
using System.Threading;
using Microsoft.EServices.EDocument;

codeunit 6392 JobHelperImpl
{
    TableNo = "Job Queue Entry";
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    #region variables

    var
        Telemetry: Codeunit Telemetry;
        JobQueueCategoryTok: Label 'EDocument', Locked = true, Comment = 'Max Length 10';
        EDocumentJobTelemetryLbl: Label 'E-Document Background Job Scheduled', Locked = true;
        JobQueueIdTxt: Label 'Job Queue Id', Locked = true;
        CodeunitIsTxt: Label 'Codeunit Id', Locked = true;
        RecordIdTxt: Label 'Record Id', Locked = true;
        UserSessionIdTxt: Label 'User Session ID', Locked = true;
        EarliestStartDateTimeTxt: Label 'Earliest Start Date/Time', Locked = true;

    #endregion

    #region public methods

    procedure ScheduleEDocumentJob(CodeunitId: Integer; JobRecordId: RecordId; EarliestStartDateTime: Integer): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if this.IsJobQueueScheduled(CodeunitId) then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CodeunitId;
        JobQueueEntry."Record ID to Process" := JobRecordId;
        JobQueueEntry."User Session ID" := SessionId();
        JobQueueEntry."Job Queue Category Code" := this.JobQueueCategoryTok;
        JobQueueEntry."No. of Attempts to Run" := 0;
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime + EarliestStartDateTime;

        TelemetryDimensions.Add(this.JobQueueIdTxt, JobQueueEntry.ID);
        TelemetryDimensions.Add(this.CodeunitIsTxt, Format(CodeunitId));
        TelemetryDimensions.Add(this.RecordIdTxt, Format(JobRecordId));
        TelemetryDimensions.Add(this.UserSessionIdTxt, Format(JobQueueEntry."User Session ID"));
        TelemetryDimensions.Add(this.EarliestStartDateTimeTxt, Format(JobQueueEntry."Earliest Start Date/Time"));
        this.Telemetry.LogMessage('', this.EDocumentJobTelemetryLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
        exit(JobQueueEntry.ID);
    end;

    procedure FetchEDocumentAndService(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; EDocumentServiceStatus: Record "E-Document Service Status")
    begin
        EDocumentService.SetLoadFields("Service Integration", "Document Format");
        EDocumentService.Get(EDocumentServiceStatus."E-Document Service Code");
        EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
    end;

    #endregion

    #region local methods

    local procedure IsJobQueueScheduled(CodeunitId: Integer): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitId);
        JobQueueEntry.SetFilter(Status, '%1|%2', JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process");
        exit(not JobQueueEntry.IsEmpty());
    end;

    #endregion
}