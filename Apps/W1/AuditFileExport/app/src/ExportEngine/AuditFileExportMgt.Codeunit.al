// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Utilities;
using System.Environment;
using System.IO;
using System.Reflection;
using System.Utilities;

codeunit 5261 "Audit File Export Mgt."
{
    TableNo = "Audit File Export Header";

    var
        ExportIsInProgressMsg: label 'The export is in progress. Starting a new job cancels the current progress.\';
        LinesInProgressOrCompletedMsg: label 'One or more export document lines are in progress or completed.\';
        CancelExportIsInProgressQst: label 'Do you want to cancel all export jobs and restart?';
        DeleteExportIsInProgressQst: label 'Do you want to delete the export entry?';
        RestartExportLineQst: label 'Do you want to restart the export for this line?';
        ExportIsCompletedQst: label 'The export was completed. You can download the export result choosing the Download Audit File action.\';
        RestartExportQst: label 'Do you want to restart the export to get a new audit file?';
        SetStartDateTimeAsCurrentQst: label 'The Earliest Start Date/Time field is not filled in. Do you want to proceed and start the export immediately?';
        AuditFileExportTxt: label 'Audit File Export';
        StartingExportTxt: label 'Starting audit file export with ID: %1, Parallel: %2, Split By Month: %3', Comment = '%1 - integer; %2, %3 - boolean';
        CancellingExportTxt: label 'Cancelling audit file export with ID: %1, Task ID: %2', Comment = '%1 - integer; %2 - GUID';
        NotPossibleToScheduleMsg: label 'You are not allowed to schedule the audit file generation';
        GenerateAuditFileImmediatelyQst: label 'Since you did not schedule the audit file generation, it will be generated immediately which can take a while. Do you want to continue?';
        NoErrorMessageErr: label 'The generation of the audit file failed but no error message was logged.';
        AuditFileGeneratedTxt: label 'Audit file was generated.';
        AuditFileNotGeneratedTxt: label 'Audit file was not generated.';
        ParallelAuditFileGenerationTxt: label 'Parallel audit file generation';
        SaveFileDialogTxt: label 'Export audit file';
        NoFileGeneratedErr: label 'No file was generated.';
        NoExportLinesCreatedErr: label 'No audit file export document lines were created.';
        NoOfJobsInProgressTxt: label 'Number of jobs in progress: %1', Comment = '%1 = number';
        JobsStartedOrFailedTxt: label 'There are %1 jobs which are not started or failed', Comment = '%1 = number';
        SessionLostTxt: label 'The task for the line %1 was lost.', Comment = '%1 = number';
        NotPossibleToScheduleTxt: label 'It is not possible to schedule the task for line %1 because the Max. No. of Jobs is %2.', Comment = '%1,%2 = numbers';
        ScheduleTaskForLineTxt: label 'Schedule a task for the line %1.', Comment = '%1 = number';
        AuditFileAlreadyExistsQst: label 'The audit file already exists and is ready for downloading. Do you want to recreate the audit file?';
        TwoStringsTxt: label '%1%2', Comment = '%1, %2 - two strings to concatenate', Locked = true;

    procedure StartExport(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        TypeHelper: Codeunit "Type Helper";
        IAuditFileExportDataHandling: Interface "Audit File Export Data Handling";
    begin
        if not PreExportCheck(AuditFileExportHeader) then
            exit;

        SendTraceTagOfExport(AuditFileExportTxt, GetStartTraceTagMessage(AuditFileExportHeader));
        IAuditFileExportDataHandling := AuditFileExportHeader."Audit File Export Format";
        IAuditFileExportDataHandling.CreateAuditFileExportLines(AuditFileExportHeader);

        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        if AuditFileExportLine.IsEmpty() then
            Error(NoExportLinesCreatedErr);

        AuditFileExportHeader.Validate(Status, AuditFileExportHeader.Status::"In Progress");
        AuditFileExportHeader.Validate("Execution Start Date/Time", TypeHelper.GetCurrentDateTimeInUserTimeZone());
        AuditFileExportHeader.Validate("Execution End Date/Time", 0DT);
        OnBeforeModifyAuditFileExportHeaderToStartExport(AuditFileExportHeader);
        AuditFileExportHeader.Modify(true);
        Commit();

        StartExportLines(AuditFileExportHeader);
        AuditFileExportHeader.Find();
    end;

    procedure DeleteExport(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
    begin
        if not CheckStatus(AuditFileExportHeader.Status, DeleteExportIsInProgressQst) then
            exit;

        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        AuditFileExportLine.SetRange(Status, AuditFileExportLine.Status::"In Progress");
        if AuditFileExportLine.FindSet() then
            repeat
                CancelTask(AuditFileExportLine);
            until AuditFileExportLine.Next() = 0;
        AuditFileExportLine.SetRange(Status);
        AuditFileExportLine.DeleteAll(true);
    end;

    procedure ThrowNoParallelExecutionNotification()
    var
        ParallelExecutionNotification: Notification;
    begin
        ParallelExecutionNotification.Message := NotPossibleToScheduleMsg;
        ParallelExecutionNotification.Scope := NotificationScope::LocalScope;
        ParallelExecutionNotification.Send();
    end;

    procedure RestartTaskOnExportLine(var AuditFileExportLine: Record "Audit File Export Line")
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        DummyNoOfJobs: Integer;
        NotBefore: DateTime;
    begin
        if not CheckLineStatusForRestart(AuditFileExportLine) then
            exit;
        if not AuditFileExportLine.FindSet() then
            exit;

        repeat
            AuditFileExportLine.SetRange(ID, AuditFileExportLine.ID);
            repeat
                CancelTask(AuditFileExportLine);
                AuditFileExportHeader.Get(AuditFileExportLine.ID);
                NotBefore := CurrentDateTime();
                RunGenerateAuditFileOnSingleLine(AuditFileExportLine, AuditFileExportHeader, DummyNoOfJobs, NotBefore);
            until AuditFileExportLine.Next() = 0;
            AuditFileExportHeader.Find();
            UpdateExportStatus(AuditFileExportHeader);
            AuditFileExportLine.SetRange(ID);
        until AuditFileExportLine.Next() = 0;
    end;

    procedure SendTraceTagOfExport(Category: Text; TraceTagMessage: Text)
    begin
        Session.LogMessage('0000JN8', TraceTagMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', Category);
    end;

    procedure SendTraceTagError(CategoryText: Text; TraceTagMessage: Text)
    begin
        Session.LogMessage('0000JN9', TraceTagMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryText);
    end;

    procedure UpdateExportStatus(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        TypeHelper: Codeunit "Type Helper";
        TotalCount: Integer;
        Status: Integer;
    begin
        if AuditFileExportHeader.ID = 0 then
            exit;

        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        TotalCount := AuditFileExportLine.Count();
        AuditFileExportLine.SetRange(Status, AuditFileExportLine.Status::Completed);
        if AuditFileExportLine.Count() = TotalCount then begin
            AuditFileExportHeader.Validate(Status, AuditFileExportHeader.Status::Completed);
            AuditFileExportHeader.Validate("Execution End Date/Time", TypeHelper.GetCurrentDateTimeInUserTimeZone());
            AuditFileExportHeader.Modify(true);
            exit;
        end;

        AuditFileExportLine.SetRange(Status, AuditFileExportLine.Status::Failed);
        if AuditFileExportLine.IsEmpty() then
            Status := AuditFileExportHeader.Status::"In Progress"
        else
            Status := AuditFileExportHeader.Status::Failed;

        AuditFileExportHeader.Validate(Status, Status);
        AuditFileExportHeader.Modify(true);
    end;

    procedure StartExportLinesNotStartedYet(AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        NoOfJobs: Integer;
        NotBefore: DateTime;
        RunThisLine: Boolean;
    begin
        if not AuditFileExportHeader."Parallel Processing" then
            exit;

        NoOfJobs := GetNoOfJobsInProgress(Codeunit::"Audit Line Export Runner");
        LogState(AuditFileExportLine, StrSubstNo(NoOfJobsInProgressTxt, NoOfJobs), false);
        if NoOfJobs > AuditFileExportHeader."Max No. Of Jobs" then
            exit;

        AuditFileExportLine.LockTable();
        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        AuditFileExportLine.SetFilter("No. Of Attempts", '<>%1', 0);
        AuditFileExportLine.SetFilter(Status, '<>%1', AuditFileExportLine.Status::Completed);
        LogState(AuditFileExportLine, StrSubstNo(JobsStartedOrFailedTxt, AuditFileExportLine.Count()), false);
        if not AuditFileExportLine.FindSet() then
            exit;

        NotBefore := CurrentDateTime();
        repeat
            RunThisLine := false;
            if AuditFileExportLine.Status = AuditFileExportLine.Status::"In Progress" then begin
                RunThisLine := not IsExportSessionActive(AuditFileExportLine);
                if RunThisLine then
                    LogState(AuditFileExportLine, StrSubstNo(SessionLostTxt, AuditFileExportLine."Line No."), true);
            end else
                RunThisLine := true;

            if RunThisLine then
                RunGenerateAuditFileOnSingleLine(AuditFileExportLine, AuditFileExportHeader, NoOfJobs, NotBefore);
        until AuditFileExportLine.Next() = 0;
    end;

    procedure ShowActivityLog(AuditFileExportLine: Record "Audit File Export Line")
    var
        ActivityLog: Record "Activity Log";
        ActivityLogPage: Page "Activity Log";
    begin
        ActivityLog.SetRange("Record ID", AuditFileExportLine.RecordId());
        ActivityLogPage.SetTableView(ActivityLog);
        ActivityLogPage.Run();
    end;

    procedure ShowErrorOnExportLine(AuditFileExportLine: Record "Audit File Export Line")
    var
        ActivityLog: Record "Activity Log";
        ErrorTextInStream: InStream;
        ErrorMessage: Text;
    begin
        ActivityLog.SetRange("Record ID", AuditFileExportLine.RecordId());
        if not ActivityLog.FindLast() or (ActivityLog.Status <> ActivityLog.Status::Failed) then
            exit;

        ActivityLog.CalcFields("Detailed Info");
        if not ActivityLog."Detailed Info".HasValue() then
            SendTraceTagError(AuditFileExportTxt, NoErrorMessageErr);
        ActivityLog."Detailed Info".CreateInStream(ErrorTextInStream);
        ErrorTextInStream.ReadText(ErrorMessage);
        if ErrorMessage = '' then
            SendTraceTagError(AuditFileExportTxt, NoErrorMessageErr);
        Message(ErrorMessage);
    end;

    procedure LogSuccess(AuditFileExportLine: Record "Audit File Export Line")
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(AuditFileExportLine.RecordId(), ActivityLog.Status::Success, '', AuditFileGeneratedTxt, '');
        SendTraceTagOfExport(AuditFileExportTxt, AuditFileGeneratedTxt);
    end;

    procedure LogError(AuditFileExportLine: Record "Audit File Export Line")
    var
        ActivityLog: Record "Activity Log";
        ErrorMessage: Text;
    begin
        ErrorMessage := GetLastErrorText();
        ActivityLog.LogActivity(AuditFileExportLine.RecordId(), ActivityLog.Status::Failed, '', AuditFileNotGeneratedTxt, ErrorMessage);
        ActivityLog.SetDetailedInfoFromText(ErrorMessage);
    end;

    local procedure LogState(AuditFileExportLine: Record "Audit File Export Line"; Description: Text[250]; SetTraceTag: Boolean)
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(AuditFileExportLine.RecordId(), ActivityLog.Status::Success, '', ParallelAuditFileGenerationTxt, Description);
        if SetTraceTag then
            SendTraceTagOfExport(ParallelAuditFileGenerationTxt, Description);
    end;

    local procedure StartExportLines(AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        NoOfJobs: Integer;
        NotBefore: DateTime;
    begin
        AuditFileExportLine.LockTable();
        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        AuditFileExportLine.FindSet();
        NoOfJobs := 1;
        NotBefore := AuditFileExportHeader."Earliest Start Date/Time";
        repeat
            RunGenerateAuditFileOnSingleLine(AuditFileExportLine, AuditFileExportHeader, NoOfJobs, NotBefore);
        until AuditFileExportLine.Next() = 0;
    end;

    local procedure RunGenerateAuditFileOnSingleLine(var AuditFileExportLine: Record "Audit File Export Line"; AuditFileExportHeader: Record "Audit File Export Header"; var NoOfJobs: Integer; var NotBefore: DateTime)
    var
        DoNotScheduleTask: Boolean;
        TaskID: Guid;
    begin
        if AuditFileExportHeader."Parallel Processing" and (NoOfJobs > AuditFileExportHeader."Max No. Of Jobs") then begin
            LogState(AuditFileExportLine, StrSubstNo(NotPossibleToScheduleTxt, AuditFileExportLine."Line No.", NoOfJobs), false);
            exit;
        end;

        AuditFileExportLine.Validate(Status, AuditFileExportLine.Status::"In Progress");
        Clear(AuditFileExportLine."Audit File Content");
        AuditFileExportLine.Validate(Progress, 0);
        if AuditFileExportHeader."Parallel Processing" then begin
            LogState(AuditFileExportLine, StrSubstNo(ScheduleTaskForLineTxt, AuditFileExportLine."Line No."), true);
            NotBefore += 3000; // have a delay between running jobs to avoid deadlocks
            OnBeforeScheduleTask(DoNotScheduleTask, TaskID);
            if DoNotScheduleTask then
                AuditFileExportLine."Task ID" := TaskID
            else
                AuditFileExportLine."Task ID" :=
                    TaskScheduler.CreateTask(
                        Codeunit::"Audit Line Export Runner", Codeunit::"Audit File Export Error Handl.", true, CompanyName(),
                        NotBefore, AuditFileExportLine.RecordId());
            AuditFileExportLine.Modify(true);
            Commit();
            NoOfJobs += 1;
            exit;
        end;
        AuditFileExportLine."Task ID" := CreateGuid();
        AuditFileExportLine.Modify(true);
        Commit();

        ClearLastError();
        if not Codeunit.Run(Codeunit::"Audit Line Export Runner", AuditFileExportLine) then
            Codeunit.Run(Codeunit::"Audit File Export Error Handl.", AuditFileExportLine);
        Commit();
    end;

    procedure NotifyAuditFileExportLineCompleted(var AuditFileExportHeader: Record "Audit File Export Header")
    begin
        OnAuditFileExportLineCompleted(AuditFileExportHeader);
    end;

    local procedure PreExportCheck(var AuditFileExportHeader: Record "Audit File Export Header"): Boolean
    var
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageManagement: Codeunit "Error Message Management";
        IAuditFileExportDataCheck: Interface "Audit File Export Data Check";
    begin
        ErrorMessageManagement.Activate(ErrorMessageHandler);
        IAuditFileExportDataCheck := AuditFileExportHeader."Audit File Export Format";
        IAuditFileExportDataCheck.CheckAuditDocReadyToExport(AuditFileExportHeader);
        if ErrorMessageManagement.GetLastErrorID() <> 0 then begin
            ErrorMessageHandler.ShowErrors();
            exit(false);
        end;

        if AuditFileExportHeader.Status = AuditFileExportHeader.Status::"In Progress" then
            if HandleConfirm(StrSubstNo(TwoStringsTxt, ExportIsInProgressMsg, CancelExportIsInProgressQst)) then
                RemoveExportLines(AuditFileExportHeader)
            else
                exit(false);

        if AuditFileExportHeader.Status = AuditFileExportHeader.Status::Completed then
            if not HandleConfirm(StrSubstNo(TwoStringsTxt, ExportIsCompletedQst, RestartExportQst)) then
                exit(false);

        if (AuditFileExportHeader."Parallel Processing") and (AuditFileExportHeader."Earliest Start Date/Time" = 0DT) then begin
            if not HandleConfirm(SetStartDateTimeAsCurrentQst) then
                exit(false);
            AuditFileExportHeader."Earliest Start Date/Time" := CurrentDateTime();
        end;

        if not AuditFileExportHeader."Parallel Processing" then
            if not HandleConfirm(GenerateAuditFileImmediatelyQst) then
                exit(false);

        exit(true)
    end;

    local procedure GetStartTraceTagMessage(AuditFileExportHeader: Record "Audit File Export Header"): Text
    begin
        exit(
            StrSubstNo(
                StartingExportTxt, AuditFileExportHeader.ID, AuditFileExportHeader."Parallel Processing", AuditFileExportHeader."Split By Month"));
    end;

    local procedure GetCancelTraceTagMessage(AuditFileExportLine: Record "Audit File Export Line"): Text
    begin
        exit(StrSubstNo(CancellingExportTxt, AuditFileExportLine.ID, AuditFileExportLine."Task ID"));
    end;

    local procedure RemoveExportLines(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
    begin
        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        if not AuditFileExportLine.FindSet() then
            exit;

        repeat
            RemoveExportLine(AuditFileExportLine);
        until AuditFileExportLine.Next() = 0;
    end;

    local procedure RemoveExportLine(var AuditFileExportLine: Record "Audit File Export Line")
    begin
        CancelTask(AuditFileExportLine);
        AuditFileExportLine.Delete(true);
        SendTraceTagOfExport(AuditFileExportTxt, GetCancelTraceTagMessage(AuditFileExportLine));
    end;

    local procedure CancelTask(AuditFileExportLine: Record "Audit File Export Line")
    var
        DoNotCancelTask: Boolean;
    begin
        if IsNullGuid(AuditFileExportLine."Task ID") then
            exit;

        OnBeforeCancelTask(DoNotCancelTask);
        if not DoNotCancelTask then
            if TaskScheduler.TaskExists(AuditFileExportLine."Task ID") then
                TaskScheduler.CancelTask(AuditFileExportLine."Task ID");
        SendTraceTagOfExport(AuditFileExportTxt, GetCancelTraceTagMessage(AuditFileExportLine));
    end;

    procedure GenerateAuditFileWithCheck(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        ConfirmMgt: Codeunit "Confirm Management";
    begin
        if AuditFileExportHeader.Status <> AuditFileExportHeader.Status::Completed then
            exit;   // wait until content for all lines is generated

        if AuditFileExists(AuditFileExportHeader) then
            if not ConfirmMgt.GetResponseOrDefault(AuditFileAlreadyExistsQst, false) then
                exit;
        GenerateAuditFile(AuditFileExportHeader);
    end;

    procedure GenerateAuditFile(var AuditFileExportHeader: Record "Audit File Export Header")
    begin
        DeleteAuditFiles(AuditFileExportHeader);

        if AuditFileExportHeader."Archive to Zip" then begin
            if AuditFileExportHeader."Create Multiple Zip Files" then
                GenerateZipFileForEachLine(AuditFileExportHeader)
            else
                GenerateSingleZipFileForAllLines(AuditFileExportHeader);
        end else
            GenerateAuditFileForEachLine(AuditFileExportHeader);
    end;

    local procedure GenerateSingleZipFileForAllLines(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        AuditFile: Record "Audit File";
        DataCompression: Codeunit "Data Compression";
        EntryTempBlob: Codeunit "Temp Blob";
        EntryFileInStream: InStream;
        ZipOutStream: OutStream;
    begin
        AuditFileExportLine.LockTable();
        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        if not AuditFileExportLine.FindSet() then
            exit;

        DataCompression.CreateZipArchive();
        InitAuditFileLine(AuditFile, AuditFileExportHeader, AuditFileExportHeader."Audit File Name");
        repeat
            EntryTempBlob.FromRecord(AuditFileExportLine, AuditFileExportLine.FieldNo("Audit File Content"));
            EntryTempBlob.CreateInStream(EntryFileInStream);
            DataCompression.AddEntry(EntryFileInStream, AuditFileExportLine."Audit File Name");
        until AuditFileExportLine.Next() = 0;

        AuditFile."File Content".CreateOutStream(ZipOutStream);
        DataCompression.SaveZipArchive(ZipOutStream);
        DataCompression.CloseZipArchive();
        AuditFile."File Size" := GetAuditFileSizeText(AuditFile);
        if AuditFile."File Content".HasValue then
            AuditFile.Insert();
    end;

    local procedure GenerateZipFileForEachLine(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        AuditFile: Record "Audit File";
        DataCompression: Codeunit "Data Compression";
        EntryTempBlob: Codeunit "Temp Blob";
        EntryFileInStream: InStream;
        ZipOutStream: OutStream;
    begin
        AuditFileExportLine.LockTable();
        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        if not AuditFileExportLine.FindSet() then
            exit;

        repeat
            Clear(EntryTempBlob);
            Clear(DataCompression);
            DataCompression.CreateZipArchive();
            InitAuditFileLine(AuditFile, AuditFileExportHeader, AuditFileExportHeader."Audit File Name");
            EntryTempBlob.FromRecord(AuditFileExportLine, AuditFileExportLine.FieldNo("Audit File Content"));
            EntryTempBlob.CreateInStream(EntryFileInStream);
            DataCompression.AddEntry(EntryFileInStream, AuditFileExportLine."Audit File Name");
            AuditFile."File Content".CreateOutStream(ZipOutStream);
            DataCompression.SaveZipArchive(ZipOutStream);
            DataCompression.CloseZipArchive();
            AuditFile."File Size" := GetAuditFileSizeText(AuditFile);
            if AuditFile."File Content".HasValue then
                AuditFile.Insert();
        until AuditFileExportLine.Next() = 0;
    end;

    local procedure GenerateAuditFileForEachLine(var AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFileExportLine: Record "Audit File Export Line";
        AuditFile: Record "Audit File";
        EntryFileInStream: InStream;
        AuditFileOutStream: OutStream;
    begin
        AuditFileExportLine.LockTable();
        AuditFileExportLine.SetRange(ID, AuditFileExportHeader.ID);
        if not AuditFileExportLine.FindSet() then
            exit;

        repeat
            InitAuditFileLine(AuditFile, AuditFileExportHeader, AuditFileExportLine."Audit File Name");
            AuditFileExportLine.CalcFields("Audit File Content");
            AuditFileExportLine."Audit File Content".CreateInStream(EntryFileInStream);
            AuditFile."File Content".CreateOutStream(AuditFileOutStream);
            CopyStream(AuditFileOutStream, EntryFileInStream);
            AuditFile."File Size" := GetAuditFileSizeText(AuditFile);
            if AuditFile."File Content".HasValue then
                AuditFile.Insert();
        until AuditFileExportLine.Next() = 0;
    end;

    local procedure GetAuditFileSizeText(var AuditFile: Record "Audit File"): Text[20]
    var
        SizeInMbytes: Decimal;
        SizeInGbytes: Decimal;
    begin
        SizeInMbytes := Round(AuditFile."File Content".Length / (1024 * 1024));
        if SizeInMbytes <= 1024 then
            exit(StrSubstNo(TwoStringsTxt, Format(SizeInMbytes), ' MB'));

        SizeInGbytes := Round(SizeInMbytes / 1024);
        exit(StrSubstNo(TwoStringsTxt, Format(SizeInGbytes), ' GB'));
    end;

    procedure DownloadFileFromExportHeader(AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFile: Record "Audit File";
        AuditFilesPage: Page "Audit Files";
        FileInStream: InStream;
    begin
        AuditFile.SetRange("Export ID", AuditFileExportHeader.ID);
        if AuditFile.IsEmpty() then begin
            SendTraceTagError(NoFileGeneratedErr, NoErrorMessageErr);
            exit;
        end;

        if AuditFile.Count > 1 then begin
            AuditFilesPage.SetTableView(AuditFile);
            AuditFilesPage.RunModal();
        end;

        AuditFile.FindFirst();
        AuditFile.CalcFields("File Content");
        if not AuditFile."File Content".HasValue() then
            Error(NoFileGeneratedErr);
        AuditFile."File Content".CreateInStream(FileInStream);
#pragma warning disable AA0139
        DownloadFromStream(FileInStream, SaveFileDialogTxt, '', '', AuditFile."File Name");
#pragma warning restore
    end;

    procedure DownloadAuditFile(var AuditFile: Record "Audit File")
    var
        FileInStream: InStream;
    begin
        AuditFile.CalcFields("File Content");
        if not AuditFile."File Content".HasValue() then
            Error(NoFileGeneratedErr);
        AuditFile."File Content".CreateInStream(FileInStream);
#pragma warning disable AA0139
        DownloadFromStream(FileInStream, SaveFileDialogTxt, '', '', AuditFile."File Name");
#pragma warning restore
    end;

    procedure DownloadFileFromAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line")
    var
        FileInStream: InStream;
    begin
        AuditFileExportLine.CalcFields("Audit File Content");
        if not AuditFileExportLine."Audit File Content".HasValue() then
            Error(NoFileGeneratedErr);
        AuditFileExportLine."Audit File Content".CreateInStream(FileInStream);
#pragma warning disable AA0139
        DownloadFromStream(FileInStream, SaveFileDialogTxt, '', '', AuditFileExportLine."Audit File Name");
#pragma warning restore
    end;

    procedure DeleteAuditFiles(AuditFileExportHeader: Record "Audit File Export Header")
    var
        AuditFile: Record "Audit File";
    begin
        AuditFile.SetRange("Export ID", AuditFileExportHeader.ID);
        AuditFile.DeleteAll(true);
    end;

    local procedure InitAuditFileLine(var AuditFile: Record "Audit File"; AuditFileExportHeader: Record "Audit File Export Header"; FileNameTemplate: Text[1024])
    var
        FileNo: Integer;
        FileName: Text[1024];
    begin
        AuditFile.Reset();
        AuditFile.SetLoadFields("Export ID", "File No.");
        AuditFile.SetRange("Export ID", AuditFileExportHeader.ID);
        if AuditFile.FindLast() then
            FileNo := AuditFile."File No.";
        FileNo += 1;

        if FileNameTemplate.Contains('%1') then
            FileName := StrSubstNo(FileNameTemplate, FileNo)
        else
            FileName := FileNameTemplate;

        AuditFile.Init();
        AuditFile."Export ID" := AuditFileExportHeader.ID;
        AuditFile."File No." := FileNo;
        AuditFile."File Name" := FileName;
    end;

    procedure AuditFileExists(AuditFileExportHeader: Record "Audit File Export Header"): Boolean
    var
        AuditFile: Record "Audit File";
    begin
        AuditFile.SetRange("Export ID", AuditFileExportHeader.ID);
        exit(not AuditFile.IsEmpty());
    end;

    procedure InsertAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line"; var LineNo: Integer; AuditFileExportHeaderID: Integer; DataClass: Enum "Audit File Export Data Class"; DescriptionValue: Text; StartingDate: Date; EndingDate: Date)
    begin
        AuditFileExportLine.Init();
        AuditFileExportLine.Validate(ID, AuditFileExportHeaderID);
        LineNo += 1;
        AuditFileExportLine.Validate("Line No.", LineNo);
        AuditFileExportLine.Validate("Data Class", DataClass);
        AuditFileExportLine.Validate(Description, CopyStr(DescriptionValue, 1, MaxStrLen(DescriptionValue)));
        AuditFileExportLine.Validate("Starting Date", StartingDate);
        AuditFileExportLine.Validate("Ending Date", EndingDate);
        AuditFileExportLine.Insert(true);
    end;

    procedure CompleteAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line"; FileContentInStream: InStream; AuditFileName: Text[1024])
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        TypeHelper: Codeunit "Type Helper";
        CompletedDateTime: DateTime;
        FileContentOutStream: OutStream;
    begin
        AuditFileExportLine.Get(AuditFileExportLine.ID, AuditFileExportLine."Line No.");
        AuditFileExportLine.LockTable();
        AuditFileExportLine."Audit File Content".CreateOutStream(FileContentOutStream);
        CopyStream(FileContentOutStream, FileContentInStream);

        CompletedDateTime := TypeHelper.GetCurrentDateTimeInUserTimeZone();

        AuditFileExportLine.Validate(Status, AuditFileExportLine.Status::Completed);
        AuditFileExportLine.Validate(Progress, 10000);
        AuditFileExportLine.Validate("Created Date/Time", CompletedDateTime);
        AuditFileExportLine.Validate("Audit File Name", AuditFileName);
        AuditFileExportLine.Modify(true);
        Commit();

        AuditFileExportHeader.Get(AuditFileExportLine.ID);
        UpdateExportStatus(AuditFileExportHeader);
        LogSuccess(AuditFileExportLine);
        StartExportLinesNotStartedYet(AuditFileExportHeader);

        AuditFileExportHeader.Get(AuditFileExportHeader.Id);
        NotifyAuditFileExportLineCompleted(AuditFileExportHeader);
    end;

    procedure UpdateProgressBarOnAuditFileExportLine(var AuditFileExportLine: Record "Audit File Export Line"; ProgressFraction: Integer)
    begin
        AuditFileExportLine.Get(AuditFileExportLine.ID, AuditFileExportLine."Line No.");
        AuditFileExportLine.Validate(Progress, ProgressFraction * 10000);
        AuditFileExportLine.Modify(true);
    end;

    local procedure IsExportSessionActive(AuditFileExportLine: Record "Audit File Export Line"): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if AuditFileExportLine."Server Instance ID" = ServiceInstanceId() then
            exit(ActiveSession.Get(AuditFileExportLine."Server Instance ID", AuditFileExportLine."Session ID"));
        if AuditFileExportLine."Server Instance ID" <= 0 then
            exit(false);
        exit(not IsSessionLoggedOff(AuditFileExportLine));
    end;

    local procedure IsSessionLoggedOff(AuditFileExportLine: Record "Audit File Export Line"): Boolean
    var
        SessionEvent: Record "Session Event";
        AuditFileExportHeader: Record "Audit File Export Header";
    begin
        SessionEvent.SetRange("Server Instance ID", AuditFileExportLine."Server Instance ID");
        SessionEvent.SetRange("Session ID", AuditFileExportLine."Session ID");
        SessionEvent.SetRange("Event Type", SessionEvent."Event Type"::Logoff);
        AuditFileExportHeader.Get(AuditFileExportLine.Id);
        SessionEvent.SetFilter("Event Datetime", '>%1', AuditFileExportHeader."Earliest Start Date/Time");
        SessionEvent.SetRange("User SID", UserSecurityId());
        exit(not SessionEvent.IsEmpty());
    end;

    local procedure GetNoOfJobsInProgress(ExportProcessingCodeunit: Integer): Integer
    var
        ScheduledTask: Record "Scheduled Task";
    begin
        ScheduledTask.SetRange("Run Codeunit", ExportProcessingCodeunit);
        exit(ScheduledTask.Count());
    end;

    local procedure HandleConfirm(ConfirmText: Text): Boolean
    begin
        if not GuiAllowed() then
            exit(true);
        exit(Confirm(ConfirmText, false));
    end;

    local procedure CheckStatus(Status: Option; Question: Text): Boolean
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        StatusMessage: Text;
    begin
        if Status = AuditFileExportHeader.Status::"In Progress" then
            StatusMessage := ExportIsInProgressMsg;
        if Status = AuditFileExportHeader.Status::Completed then
            StatusMessage := ExportIsCompletedQst;
        if StatusMessage <> '' then
            exit(HandleConfirm(StatusMessage + Question));
        exit(true);
    end;

    local procedure CheckLineStatusForRestart(var AuditFileExportLine: Record "Audit File Export Line"): Boolean;
    begin
        AuditFileExportLine.SetFilter(Status, '%1|%2', AuditFileExportLine.Status::"In Progress", AuditFileExportLine.Status::Completed);
        if not AuditFileExportLine.IsEmpty() then
            exit(HandleConfirm(StrSubstNo(TwoStringsTxt, LinesInProgressOrCompletedMsg, RestartExportLineQst)));
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleTask(var DoNotScheduleTask: Boolean; var TaskID: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCancelTask(var DoNotCancelTask: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAuditFileExportLineCompleted(var AuditFileExportHeader: Record "Audit File Export Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyAuditFileExportHeaderToStartExport(var AuditFileExportHeader: Record "Audit File Export Header")
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Audit File Export Mgt.", 'OnAuditFileExportLineCompleted', '', false, false)]
    local procedure CreateFileOnAuditFileExportLineCompleted(var AuditFileExportHeader: Record "Audit File Export Header")
    begin
        GenerateAuditFileWithCheck(AuditFileExportHeader);
    end;
}
