namespace System.DataAdministration;

using Microsoft.EServices.EDocument;
using Microsoft.Finance.GeneralLedger.Ledger;
using System;
using System.Telemetry;

codeunit 6203 "Transact. Storage Export"
{
    Access = Internal;
    TableNo = "Transact. Storage Task Entry";
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Transact. Storage Export State" = R,
                  tabledata "Transact. Storage Table Entry" = RIM,
                  tabledata "Transact. Storage Task Entry" = RIM,
                  tabledata "Transaction Storage Setup" = RI,
                  tabledata "G/L Entry" = r,
                  tabledata "Incoming Document" = r;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TransactionStorageTok: Label 'Transaction Storage', Locked = true;
        ExportStartedTxt: Label 'Export started', Locked = true;
        ExportEndedTxt: Label 'Export ended', Locked = true;
        TaskTimedOutErr: Label 'Export task timed out. Time deadline: %1 hours. Task time: %2 hours.', Comment = '%1, %2 - number of hours', Locked = true;

    trigger OnRun()
    var
        TransactStorageExportData: Codeunit "Transact. Storage Export Data";
    begin
        FeatureTelemetry.LogUsage('0000LK3', TransactionStorageTok, ExportStartedTxt);
        Rec.SetStatusStarted();
        Commit();

        VerifyContainerNameLength();
        TransactStorageExportData.ExportData(Rec."Starting Date/Time");

        Rec.SetStatusCompleted();
        FeatureTelemetry.LogUsage('0000LK4', TransactionStorageTok, ExportEndedTxt);
    end;

    procedure IsTaskTimedOut(TaskStartingDateTime: DateTime; var TaskRunTimeHours: Decimal; var MaxExpectedRunTimeHours: Integer): Boolean
    var
        TransactionStorageSetup: Record "Transaction Storage Setup";
    begin
        if not TransactionStorageSetup.Get() then
            TransactionStorageSetup.Insert(true);
        MaxExpectedRunTimeHours := TransactionStorageSetup."Max. Number of Hours";
        TaskRunTimeHours := Round((CurrentDateTime() - TaskStartingDateTime) / (60 * 60 * 1000), 0.1);

        exit(TaskRunTimeHours > MaxExpectedRunTimeHours);
    end;

    procedure CheckTaskTimedOut(TaskStartingDateTime: DateTime)
    var
        TaskRunTimeHours: Decimal;
        MaxExpectedRunTimeHours: Integer;
    begin
        if IsTaskTimedOut(TaskStartingDateTime, TaskRunTimeHours, MaxExpectedRunTimeHours) then
            LogWarning('0000LNB', StrSubstNo(TaskTimedOutErr, MaxExpectedRunTimeHours, TaskRunTimeHours));
    end;

    procedure GetRecordExportData(var TransactStorageTableEntry: Record "Transact. Storage Table Entry"; var RecRef: RecordRef)
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

    procedure SetTableEntryProcessed(var TableEntry: Record "Transact. Storage Table Entry"; LastHandledDateTime: DateTime; ExportedToABS: Boolean; BlobNameInABS: Text[2048])
    begin
        TableEntry."Last Handled Date/Time" := LastHandledDateTime;
        TableEntry."Exported To ABS" := ExportedToABS;
        TableEntry."Blob Name in ABS" := BlobNameInABS;
        TableEntry.Modify();
    end;

    procedure CalcTenantExportStartTime() ExportStartTime: Time
    var
        TransactionStorageABS: Codeunit "Transaction Storage ABS";
        Convert: DotNet Convert;
        TenantIdTwoFirstChars: Text[2];
        TimeMultiplier: Integer;
    begin
        // take first two hex chars from tenant id (00-ff) and convert it to decimal integer (0-255)
        // divide it to 8 (0-32), multiply by 5 minutes and add to 2:00 AM
        // min value is 2:00 AM, max value is 4:40 AM
        // as tenant ids are distributed evenly, the export start time will be distributed evenly as well
        ExportStartTime := 020000T;
        TenantIdTwoFirstChars := CopyStr(TransactionStorageABS.GetAadTenantId(), 1, 2);
        if not IsHexString(TenantIdTwoFirstChars) then
            exit;
        TimeMultiplier := Round(Convert.ToInt32(TenantIdTwoFirstChars, 16) / 8, 1);
        ExportStartTime += TimeMultiplier * 5 * 60 * 1000;
    end;

    local procedure IsHexString(InputValue: Text): Boolean
    var
        ch: Char;
        IsHex: Boolean;
    begin
        InputValue := LowerCase(InputValue);
        foreach ch in InputValue do begin
            IsHex := ((ch >= '0') and (ch <= '9')) or
                     ((ch >= 'a') and (ch <= 'f'));
            if not IsHex then
                exit(false);
        end;
        exit(true);
    end;

    local procedure VerifyContainerNameLength()
    var
        TransactionStorageABS: Codeunit "Transaction Storage ABS";
        ContainerName: Text;
    begin
        ContainerName := TransactionStorageABS.GetContainerName();
        TransactionStorageABS.VerifyContainerNameLength(ContainerName);
    end;

    procedure LogWarning(EventId: Text; WarningText: Text)
    var
        Telemetry: Codeunit Telemetry;
    begin
        Telemetry.LogMessage(EventId, WarningText, Verbosity::Warning, DataClassification::SystemMetadata);
    end;

    procedure LogWarning(EventId: Text; WarningText: Text; CustomDimensions: Dictionary of [Text, Text])
    var
        Telemetry: Codeunit Telemetry;
    begin
        Telemetry.LogMessage(
            EventId, WarningText, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;
}