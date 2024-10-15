namespace System.DataAdministration;

using System.Telemetry;
using System.IO;

codeunit 6204 "Trans. Storage Error Handler"
{
    Access = Internal;
    TableNo = "Transact. Storage Task Entry";
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Transact. Storage Export State" = RIM,
                  tabledata "Transact. Storage Task Entry" = R,
                  tabledata "Trans. Storage Export Data" = RD;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TransactionStorageTok: Label 'Transaction Storage', Locked = true;
        TaskFailedErr: Label 'Export task failed', Locked = true;
        TaskFailedMultipleTimesErr: Label 'Export task failed 4 times', Locked = true;
        TaskFailedMultipleDaysErr: Label 'Export task failed %1 days in a row', Locked = true;
        TaskTimedOutErr: Label 'Task will not be rescheduled because it timed out. Time deadline: %1 hours. Task time: %2 hours.', Comment = '%1, %2 - number of hours', Locked = true;

    trigger OnRun()
    var
        TransactStorageExportState: Record "Transact. Storage Export State";
        TransStorageExportData: Record "Trans. Storage Export Data";
        TransStorageScheduleTask: Codeunit "Trans. Storage Schedule Task";
        TransactStorageExport: Codeunit "Transact. Storage Export";
        TranslationHelper: Codeunit "Translation Helper";
        TaskRunTimeHours: Decimal;
        MaxExpectedRunTimeHours: Integer;
        ExportDateTime: DateTime;
        ErrorText: Text;
    begin
        TranslationHelper.SetGlobalLanguageToDefault();
        ErrorText := GetLastErrorText();
        TranslationHelper.RestoreGlobalLanguage();
        FeatureTelemetry.LogError('0000LK2', TransactionStorageTok, TaskFailedErr, ErrorText);
        Rec.SetStatusFailed(ErrorText, GetLastErrorCallStack());

        // do not reschedule task if it already failed 4 times
        TransactStorageExportState.Get();
        if TransactStorageExportState."Number Of Attempts" = 0 then begin
            FeatureTelemetry.LogError('0000LNA', TransactionStorageTok, '', TaskFailedMultipleTimesErr);
            CheckMultipleTaskFailures();
            exit;
        end;

        // do not schedule new task if current task timed out
        if TransactStorageExport.IsTaskTimedOut(Rec."Starting Date/Time", TaskRunTimeHours, MaxExpectedRunTimeHours) then begin
            TransactStorageExport.LogWarning('0000NU8', StrSubstNo(TaskTimedOutErr, MaxExpectedRunTimeHours, TaskRunTimeHours));
            exit;
        end;

        ExportDateTime := CurrentDateTime() + Random(3) * 5 * 60 * 1000;   // 5 - 15 minutes
        TransStorageScheduleTask.CreateTaskToExport(ExportDateTime, false);
        TransactStorageExportState."Number Of Attempts" -= 1;
        TransactStorageExportState.Modify();
        TransStorageExportData.DeleteAll(true);
    end;

    local procedure CheckMultipleTaskFailures()
    var
        TransactStorageTaskEntry: Record "Transact. Storage Task Entry";
        MaxNumberFailureDays: Integer;
    begin
        MaxNumberFailureDays := 7;
        TransactStorageTaskEntry.SetRange("Is First Attempt", true);
        if TransactStorageTaskEntry.Count < MaxNumberFailureDays then
            exit;

        // go 7 days back in log and check if all tasks failed
        TransactStorageTaskEntry.FindSet();
        if TransactStorageTaskEntry.Next(-MaxNumberFailureDays) = -MaxNumberFailureDays then begin
            TransactStorageTaskEntry.SetRange("Is First Attempt");
            repeat
                if TransactStorageTaskEntry.Status <> Enum::"Trans. Storage Export Status"::Failed then
                    exit;
            until TransactStorageTaskEntry.Next() = 0;
            FeatureTelemetry.LogError('0000LQX', TransactionStorageTok, '', StrSubstNo(TaskFailedMultipleDaysErr, MaxNumberFailureDays));
        end;
    end;
}