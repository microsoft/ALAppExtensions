namespace System.DataAdministration;

using Microsoft.Foundation.Company;
#if not CLEAN24
using System.Azure.KeyVault;
#endif
using System.Environment;
using System.Telemetry;

codeunit 6207 "Trans. Storage Schedule Task"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Transact. Storage Export State" = RIM,
                  tabledata "Transact. Storage Task Entry" = RIM,
                  tabledata "Transaction Storage Setup" = RI,
                  tabledata Company = r,
                  tabledata "Scheduled Task" = rid;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TransactionStorageTok: Label 'Transaction Storage', Locked = true;
        TaskScheduledTxt: Label 'A new task for export has been scheduled.', Locked = true;
        CannotCreateTaskErr: Label 'The task for export cannot be created.', Locked = true;
        TaskDeletedErr: Label 'Export task was removed by user', Locked = true;
#if not CLEAN24
        TransactionStorageFeatureEnabledKeyTok: Label 'TransactionStorage-Enabled', Locked = true;
        CannotGetStorageNameFromKeyVaultErr: Label 'Cannot get storage account name from Azure Key Vault using key %1', Locked = true;
#endif

    internal procedure ScheduleTaskToExport()
    var
        TransactionStorageSetup: Record "Transaction Storage Setup";
        TransactStorageExportState: Record "Transact. Storage Export State";
        TaskDateTime: DateTime;
        TaskDate: Date;
    begin
        if IsValidTaskExist() then
            exit;

#if not CLEAN24
        if not IsFeatureEnabled() then
            exit;
#endif
        if not IsSaaSProductionCompany() then
            exit;

        if not TaskScheduler.CanCreateTask() then begin
            FeatureTelemetry.LogError('0000MFR', TransactionStorageTok, '', CannotCreateTaskErr);
            exit;
        end;

        FeatureTelemetry.LogUptake('0000MVU', TransactionStorageTok, "Feature Uptake Status"::Used);
        TransactStorageExportState.ResetSetup();
        if not TransactionStorageSetup.Get() then
            TransactionStorageSetup.Insert(true);
        TaskDate := GetTaskDate(TransactionStorageSetup."Earliest Start Time");
        TaskDateTime := CreateDateTime(TaskDate, TransactionStorageSetup."Earliest Start Time");
        CreateTaskToExport(TaskDateTime, true);
    end;

    internal procedure CreateTaskToExport(TaskDateTime: DateTime; IsFirstAttempt: Boolean)
    var
        TransactStorageTaskEntry: Record "Transact. Storage Task Entry";
    begin
        if not TaskScheduler.CanCreateTask() then
            exit;

        TransactStorageTaskEntry.Init();
        TransactStorageTaskEntry.Insert();
        TransactStorageTaskEntry."Task ID" :=
            TaskScheduler.CreateTask(
                Codeunit::"Transact. Storage Export", Codeunit::"Trans. Storage Error Handler", true, CompanyName(),
                TaskDateTime, TransactStorageTaskEntry.RecordId);
        TransactStorageTaskEntry.Status := TransactStorageTaskEntry.Status::Scheduled;
        TransactStorageTaskEntry."Scheduled Date/Time" := TaskDateTime;
        TransactStorageTaskEntry."Is First Attempt" := IsFirstAttempt;
        TransactStorageTaskEntry.Modify();
        FeatureTelemetry.LogUsage('0000LNC', TransactionStorageTok, TaskScheduledTxt);
    end;

    local procedure GetTaskDate(EarliestStartTime: Time) TaskDate: Date
    var
        TransactStorageTaskEntry: Record "Transact. Storage Task Entry";
        LastTaskDate: Date;
    begin
        TaskDate := Today();
        if Time > EarliestStartTime then
            TaskDate := Today() + 1;

        TransactStorageTaskEntry.SetFilter(Status, '<>%1', Enum::"Trans. Storage Export Status"::Failed);
        TransactStorageTaskEntry.SetFilter("Starting Date/Time", '<>%1', 0DT);
        if TransactStorageTaskEntry.FindLast() then begin
            LastTaskDate := DT2Date(TransactStorageTaskEntry."Starting Date/Time");
            if LastTaskDate >= Today() then
                TaskDate := Today() + 1;
        end;
    end;

    local procedure IsSaaSProductionCompany(): Boolean
    var
        Company: Record Company;
        EnvironmentInformation: Codeunit "Environment Information";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if not EnvironmentInformation.IsProduction() then
            exit(false);

        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit(false);

        Company.Get(CompanyName());
        if Company."Evaluation Company" then
            exit(false);

        if CompanyInformationMgt.IsDemoCompany() then
            exit(false);

        exit(true);
    end;

    procedure IsValidTaskExist(): Boolean
    var
        ScheduledTask: Record "Scheduled Task";
        OutdatedTaskScheduledDate: Date;
        IsTaskOutdated: Boolean;
    begin
        if ScheduledTask.ReadPermission() then begin
            ScheduledTask.SetRange("Run Codeunit", Codeunit::"Transact. Storage Export");
            if not ScheduledTask.FindFirst() then
                exit(false);

            OutdatedTaskScheduledDate := Today() - 7;
            IsTaskOutdated := ScheduledTask."Not Before" < CreateDateTime(OutdatedTaskScheduledDate, 0T);
            if (not ScheduledTask."Is Ready") or IsTaskOutdated then begin
                TaskScheduler.CancelTask(ScheduledTask.ID);
                exit(false);
            end;
        end;

        exit(true);
    end;
#if not CLEAN24
    [NonDebuggable]
    local procedure IsFeatureEnabled(): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        FeatureEnabledValue: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(TransactionStorageFeatureEnabledKeyTok, FeatureEnabledValue) then begin
            FeatureTelemetry.LogError('0000LZM', TransactionStorageTok, '', StrSubstNo(CannotGetStorageNameFromKeyVaultErr, TransactionStorageFeatureEnabledKeyTok));
            exit(false);
        end;
        exit(FeatureEnabledValue = 'True');
    end;
#endif

    [EventSubscriber(ObjectType::Table, Database::"Scheduled Task", 'OnAfterDeleteEvent', '', false, false)]
    local procedure LogTaskDeletionOnAfterDeleteEvent(var Rec: Record "Scheduled Task")
    begin
        if Rec."Run Codeunit" <> Codeunit::"Transact. Storage Export" then
            exit;
        FeatureTelemetry.LogError('0000MLG', TransactionStorageTok, '', TaskDeletedErr);
    end;
}