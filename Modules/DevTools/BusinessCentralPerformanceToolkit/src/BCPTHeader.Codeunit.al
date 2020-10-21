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
        BCPTLine.SetRange("BCPT Code", Rec."Code");
        BCPTLine.DeleteAll(true);

        BCPTLogEntry.SetRange("BCPT Code");
        BCPTLogEntry.DeleteAll(true);
    end;


    [EventSubscriber(ObjectType::Table, Database::"BCPT Header", 'OnAfterModifyEvent', '', false, false)]
    local procedure LogTelemetryWhenSuiteChangesStateOnAfterModifyABTHeader(var Rec: Record "BCPT Header"; var xRec: Record "BCPT Header"; RunTrigger: Boolean)
    var
        TelemetryCustomDimensions: Dictionary of [Text, Text];
        PerformanceRunStartedLbl: Label 'Performance Toolkit run started.', Locked = true;
        PerformanceRunFinishedLbl: Label 'Performance Toolkit run finished.', Locked = true;
        PerformanceRunCancelledLbl: Label 'Performance Toolkit run cancelled.', Locked = true;
    begin
        if Rec.Status <> xRec.Status then begin
            TelemetryCustomDimensions.Add(Rec.FieldCaption(Code), Rec.Code);
            TelemetryCustomDimensions.Add(Rec.FieldCaption("Duration (minutes)"), Format(Rec."Duration (minutes)"));
            TelemetryCustomDimensions.Add(Rec.FieldCaption(CurrentRunType), Format(Rec.CurrentRunType));
            Rec.CalcFields("Total No. of Sessions");
            TelemetryCustomDimensions.Add(Rec.FieldCaption("Total No. of Sessions"), Format(Rec."Total No. of Sessions"));

            case (true) of
                (xRec.Status in [xRec.Status::" ", xRec.Status::Completed]) and (Rec.Status = Rec.Status::Running):
                    Session.LogMessage('0000DHR', PerformanceRunStartedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryCustomDimensions);
                (xRec.Status = xRec.Status::Running) and (Rec.Status = Rec.Status::Completed):
                    Session.LogMessage('0000DHS', PerformanceRunFinishedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryCustomDimensions);
                (xRec.Status = xRec.Status::Running) and (Rec.Status = Rec.Status::Cancelled):
                    Session.LogMessage('0000DHT', PerformanceRunCancelledLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryCustomDimensions);
            end;
        end;
    end;
}