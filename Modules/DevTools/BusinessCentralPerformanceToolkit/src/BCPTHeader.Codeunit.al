// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 149004 "BCPT Header"
{
    Access = Internal;

    procedure DecreaseNoOfTestsRunningNow(var BCPTHeader: Record "BCPT Header")
    begin
        if BCPTHeader.Code = '' then
            exit;
        BCPTHeader.LockTable();
        if not BCPTHeader.Find() then
            exit;
        BCPTHeader.Validate("No. of tests running", BCPTHeader."No. of tests running" - 1);
        BCPTHeader.Modify();
        Commit();
    end;

    procedure ResetStatus(var BCPTHeader: Record "BCPT Header")
    var
        BCPTLine: Record "BCPT Line";
        ConfirmResetStatusQst: Label 'This action will mark the run as Completed. Are you sure you want to continue ?';
    begin
        if Confirm(ConfirmResetStatusQst) then begin
            BCPTLine.SetRange("BCPT Code", BCPTHeader."Code");
            BCPTLine.ModifyAll(Status, BCPTLine.Status::Completed);
            BCPTLine.ModifyAll("No. of Running Sessions", 0);

            BCPTHeader.Status := BCPTHeader.Status::Completed;
            BCPTHeader."No. of tests running" := 0;
            BCPTHeader.Modify(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"BCPT Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SetDefaultWorkdateOnAfterInsertBCPTHeader(var Rec: Record "BCPT Header"; RunTrigger: Boolean)
    begin
        Rec."Work date starts at" := WorkDate();
    end;

    [EventSubscriber(ObjectType::Table, Database::"BCPT Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure DeleteLinesOnDeleteBCPTHeader(var Rec: Record "BCPT Header"; RunTrigger: Boolean)
    var
        BCPTLine: Record "BCPT Line";
        BCPTLogEntry: Record "BCPT Log Entry";
    begin
        if Rec.IsTemporary() then
            exit;

        BCPTLine.SetRange("BCPT Code", Rec."Code");
        BCPTLine.DeleteAll(true);

        BCPTLogEntry.SetRange("BCPT Code", Rec."Code");
        BCPTLogEntry.DeleteAll(true);
    end;

    procedure SetRunStatus(var BCPTHeader: Record "BCPT Header"; BCPTHeaderStatus: Enum "BCPT Header Status")
    var
        TelemetryCustomDimensions: Dictionary of [Text, Text];
        PerformanceRunStartedLbl: Label 'Performance Toolkit run started.', Locked = true;
        PerformanceRunFinishedLbl: Label 'Performance Toolkit run finished.', Locked = true;
        PerformanceRunCancelledLbl: Label 'Performance Toolkit run cancelled.', Locked = true;
    begin
        TelemetryCustomDimensions.Add('Code', BCPTHeader.Code);
        TelemetryCustomDimensions.Add('DurationInMinutes', Format(BCPTHeader."Duration (minutes)"));
        TelemetryCustomDimensions.Add('CurrentRunType', Format(BCPTHeader.CurrentRunType));
        TelemetryCustomDimensions.Add('RunID', Format(BCPTHeader.Version));
        BCPTHeader.CalcFields("Total No. of Sessions");
        TelemetryCustomDimensions.Add('SessionCount', Format(BCPTHeader."Total No. of Sessions"));

        BCPTHeader.Status := BCPTHeaderStatus;

        case BCPTHeaderStatus of
            BCPTHeaderStatus::Running:
                Session.LogMessage('0000DHR', PerformanceRunStartedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryCustomDimensions);
            BCPTHeaderStatus::Completed:
                Session.LogMessage('0000DHS', PerformanceRunFinishedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryCustomDimensions);
            BCPTHeaderStatus::Cancelled:
                Session.LogMessage('0000DHT', PerformanceRunCancelledLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryCustomDimensions);
        end;
        BCPTHeader.Modify();
        Commit();

    end;

}