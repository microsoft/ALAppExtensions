namespace System.DataAdministration;

using Microsoft.EServices.EDocument;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Company;
#if not CLEAN24
using System.Azure.KeyVault;
#endif
using System.Environment;
using System.Telemetry;

codeunit 6203 "Transaction Storage Impl."
{
    Access = Internal;
    TableNo = "Transact. Storage Task Entry";
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Transact. Storage Export State" = RIM,
                  tabledata "Transact. Storage Task Entry" = RIM,
                  tabledata "Transaction Storage Setup" = RI,
                  tabledata "G/L Entry" = r,
                  tabledata "Incoming Document" = r,
                  tabledata Company = r,
                  tabledata "Scheduled Task" = r;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TransactionStorageTok: Label 'Transaction Storage', Locked = true;
#if not CLEAN24
        TransactionStorageFeatureEnabledKeyTok: Label 'TransactionStorage-Enabled', Locked = true;
        CannotGetStorageNameFromKeyVaultErr: Label 'Cannot get storage account name from Azure Key Vault using key %1', Locked = true;
#endif
        TimeDeadlineExceededErr: Label 'A time deadline of %1 hours for the export has been exceeded. The export has been stopped.', Comment = '%1 = number of hours';

    trigger OnRun()
    var
        TransactStorageExportData: Codeunit "Transact. Storage Export Data";
    begin
        FeatureTelemetry.LogUsage('0000LK3', TransactionStorageTok, 'Export started');
        Rec.SetStatusStarted();
        Commit();

        TransactStorageExportData.ExportData(Rec);

        Rec.SetStatusCompleted();
        FeatureTelemetry.LogUsage('0000LK4', TransactionStorageTok, 'Export ended');
    end;

    internal procedure ScheduleTaskToExport()
    var
        TransactionStorageSetup: Record "Transaction Storage Setup";
        TransactStorageExportState: Record "Transact. Storage Export State";
        TaskDateTime: DateTime;
        TaskDate: Date;
    begin
#if not CLEAN24
        if not IsFeatureEnabled() then
            exit;
#endif
        if not IsSaaSProductionCompany() then
            exit;

        if IsValidTaskExist() then
            exit;

        TransactStorageExportState.ResetSetup();
        if not TransactionStorageSetup.Get() then
            TransactionStorageSetup.Insert();
        TaskDate := GetTaskDate(TransactionStorageSetup."Earliest Start Time");
        TaskDateTime := CreateDateTime(TaskDate, TransactionStorageSetup."Earliest Start Time");
        CreateTaskToExport(TaskDateTime, true);
    end;

    internal procedure CreateTaskToExport(TaskDateTime: DateTime; IsFirstAttempt: Boolean)
    var
        TransactStorageTaskEntry: Record "Transact. Storage Task Entry";
    begin
        TransactStorageTaskEntry.Init();
        TransactStorageTaskEntry.Insert();
        TransactStorageTaskEntry."Task ID" :=
            TaskScheduler.CreateTask(
                Codeunit::"Transaction Storage Impl.", Codeunit::"Trans. Storage Error Handler", true, CompanyName(),
                TaskDateTime, TransactStorageTaskEntry.RecordId);
        TransactStorageTaskEntry.Status := TransactStorageTaskEntry.Status::Scheduled;
        TransactStorageTaskEntry."Scheduled Date/Time" := TaskDateTime;
        TransactStorageTaskEntry."Is First Attempt" := IsFirstAttempt;
        TransactStorageTaskEntry.Modify();
        FeatureTelemetry.LogUsage('0000LNC', TransactionStorageTok, 'A new task has been scheduled to export data.');
    end;

    local procedure GetTaskDate(EarliestStartTime: Time) TaskDate: Date
    var
        TransactStorageTaskEntry: Record "Transact. Storage Task Entry";
    begin
        TaskDate := Today();
        if Time > EarliestStartTime then
            TaskDate += 1;
        TransactStorageTaskEntry.SetFilter(Status, '<>%1', Enum::"Trans. Storage Export Status"::Failed);
        if TransactStorageTaskEntry.FindLast() then
            if DT2Date(TransactStorageTaskEntry."Starting Date/Time") + 1 > TaskDate then
                TaskDate := DT2Date(TransactStorageTaskEntry."Starting Date/Time") + 1;
    end;

    procedure CheckTimeDeadline(TransactStorageTaskEntry: Record "Transact. Storage Task Entry")
    var
        TransactionStorageSetup: Record "Transaction Storage Setup";
    begin
        if not TransactionStorageSetup.Get() then
            TransactionStorageSetup.Insert();
        if (CurrentDateTime() - TransactStorageTaskEntry."Starting Date/Time") >= (TransactionStorageSetup."Max. Number of Hours" * 60 * 60 * 1000) then begin
            FeatureTelemetry.LogError('0000LNB', TransactionStorageTok, StrSubstNo(TimeDeadlineExceededErr, TransactionStorageSetup."Max. Number of Hours"), '');
            Error('');
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

    local procedure IsValidTaskExist(): Boolean
    var
        ScheduledTask: Record "Scheduled Task";
        OutdatedTaskScheduledDate: Date;
        IsTaskOutdated: Boolean;
    begin
        ScheduledTask.SetRange("Run Codeunit", Codeunit::"Transaction Storage Impl.");
        if not ScheduledTask.FindFirst() then
            exit(false);

        OutdatedTaskScheduledDate := Today() - 7;
        IsTaskOutdated := ScheduledTask."Not Before" < CreateDateTime(OutdatedTaskScheduledDate, 0T);
        if (not ScheduledTask."Is Ready") or IsTaskOutdated then begin
            TaskScheduler.CancelTask(ScheduledTask.ID);
            exit(false);
        end;

        exit(true);
    end;

    procedure GetExportDataTrack(var TransactStorageTableEntry: Record "Transact. Storage Table Entry"; var RecRef: RecordRef)
    var
        TransactStorageExportState: Record "Transact. Storage Export State";
    begin
        TransactStorageTableEntry."Table ID" := RecRef.Number;
        if TransactStorageTableEntry.Find() then
            exit;
        TransactStorageExportState.Get();
        TransactStorageTableEntry."Last Handled Date/Time" := CreateDateTime(TransactStorageExportState."First Run Date", 0T);
        TransactStorageTableEntry.Insert();
    end;

    procedure HandleIncomingDocuments(var HandledIncomingDocs: Dictionary of [Text, Integer]; var RecRef: RecordRef)
    var
        GLEntry: Record "G/L Entry";
        IncomingDocument: Record "Incoming Document";
        FieldRef: FieldRef;
        IncDocKey: Text;
    begin
        if RecRef.Number = Database::"G/L Entry" then begin
            FieldRef := RecRef.Field(GLEntry.FieldNo("Posting Date"));
            IncDocKey := Format(FieldRef.Value, 0, '<Year4><Month,2><Day,2>');
            FieldRef := RecRef.Field(GLEntry.FieldNo("Document No."));
            IncDocKey += '-' + Format(FieldRef.Value);
            if not HandledIncomingDocs.ContainsKey(IncDocKey) then
                if GetIncomingDocumentRecordFromRecordRef(IncomingDocument, RecRef) then
                    HandledIncomingDocs.Add(IncDocKey, IncomingDocument."Entry No.");
        end;
    end;

    local procedure GetIncomingDocumentRecordFromRecordRef(var IncomingDocument: Record "Incoming Document"; MainRecordRef: RecordRef): Boolean
    begin
        IncomingDocument.SetLoadFields(Description, "Document No.", "Document Type", "Posting Date", Posted);
        if IncomingDocument.FindFromIncomingDocumentEntryNo(MainRecordRef, IncomingDocument) then
            exit(true);
        if IncomingDocument.FindByDocumentNoAndPostingDate(MainRecordRef, IncomingDocument) then
            exit(true);
        exit(false);
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
    [InternalEvent(false)]
    internal procedure OnBeforeCheckFeatureEnableDate(var FeatureEnableDatePassed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterGLFinishPosting', '', false, false)]
    local procedure ScheduleTaskToExportOnOnAfterGLFinishPosting(GLEntry: Record "G/L Entry"; var GenJnlLine: Record "Gen. Journal Line"; var IsTransactionConsistent: Boolean; FirstTransactionNo: Integer; var GLRegister: Record "G/L Register"; var TempGLEntryBuf: Record "G/L Entry" temporary; var NextEntryNo: Integer; var NextTransactionNo: Integer)
    begin
        ScheduleTaskToExport();
    end;
}