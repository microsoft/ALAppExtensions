namespace System.DataAdministration;

using System.Telemetry;

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
        TransactionStorageTok: Label 'Transaction Storage', Locked = true;
        TaskFailedErr: Label 'Export task failed', Locked = true;
        TaskFailedMultipleTimesErr: Label 'Export task failed 4 times', Locked = true;
        TaskFailedMultipleDaysErr: Label 'Export task failed %1 days in a row', Locked = true;

    trigger OnRun()
    var
        TransactStorageExportState: Record "Transact. Storage Export State";
        TransStorageExportData: Record "Trans. Storage Export Data";
        TransStorageScheduleTask: Codeunit "Trans. Storage Schedule Task";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ExportDateTime: DateTime;
        ErrorText: Text;
    begin
        ErrorText := GetLastErrorText();
        FeatureTelemetry.LogError('0000LK2', TransactionStorageTok, TaskFailedErr, ErrorText);
        Rec.SetStatusFailed(ErrorText, GetLastErrorCallStack());

        TransactStorageExportState.Get();
        if TransactStorageExportState."Number Of Attempts" = 0 then begin
            FeatureTelemetry.LogError('0000LNA', TransactionStorageTok, '', TaskFailedMultipleTimesErr);
            CheckMultipleTaskFailures();
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
        FeatureTelemetry: Codeunit "Feature Telemetry";
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