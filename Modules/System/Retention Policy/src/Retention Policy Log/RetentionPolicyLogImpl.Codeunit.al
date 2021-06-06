// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3909 "Retention Policy Log Impl."
{
    Access = Internal;
    TableNo = "Retention Policy Log Entry";
    Permissions = tabledata "Retention Policy Log Entry" = rimd;

    var
        MessageType: Enum "Retention Policy Log Message Type";

    trigger OnRun()
    begin
        if not Rec.IsTemporary then
            exit;

        CreateLogEntry(Rec."Message Type", Rec.Category, rec.Message, rec."Session Id");
    end;

    procedure LogError(Category: Enum "Retention Policy Log Category"; Message: Text[2048]; DisplayError: Boolean);
    begin
        CreateTempLogEntry(MessageType::Error, Category, Message);

        if DisplayError then
            Error(Message);
    end;

    procedure LogWarning(Category: Enum "Retention Policy Log Category"; Message: Text[2048]);
    begin
        CreateTempLogEntry(MessageType::Warning, Category, Message);
    end;

    procedure LogInfo(Category: Enum "Retention Policy Log Category"; Message: Text[2048]);
    begin
        CreateTempLogEntry(MessageType::Info, Category, Message);
    end;

    local procedure CreateTempLogEntry(MessageType: Enum "Retention Policy Log Message Type"; Category: Enum "Retention Policy Log Category"; Message: Text[2048])
    var
        TempRetentionPolicyLogEntry: Record "Retention Policy Log Entry" temporary;
        RetenPolicyTelemetryImpl: Codeunit "Reten. Policy Telemetry Impl.";
        SystemInitialization: Codeunit "System Initialization";
    begin
        Clear(TempRetentionPolicyLogEntry);
        TempRetentionPolicyLogEntry.Category := Category;
        TempRetentionPolicyLogEntry."Message Type" := MessageType;
        TempRetentionPolicyLogEntry.Message := Message;
        TempRetentionPolicyLogEntry."Session Id" := Database.SessionId();
        TempRetentionPolicyLogEntry.Insert();

        RetenPolicyTelemetryImpl.SendLogEntryToTelemetry(TempRetentionPolicyLogEntry);
        if (not SystemInitialization.IsInProgress()) and (Session.GetExecutionContext() = ExecutionContext::Normal) then begin // no background logging during OnCompanyOpen() or during install/upgrade
            // add log entry in background session to avoid rollback
            if not InsertLogEntryInBackgroundSession(TempRetentionPolicyLogEntry) then
                RetenPolicyTelemetryImpl.SendTelemetryOnInsertLogEntryInBackgroundSessionFailed(SystemInitialization.IsInProgress(), Session.GetExecutionContext());
        end else begin
            RetenPolicyTelemetryImpl.SendTelemetryOnInsertLogEntryInForegroundSessionStart(SystemInitialization.IsInProgress(), Session.GetExecutionContext());
            CreateLogEntry(MessageType, Category, Message, Database.SessionId());
            RetenPolicyTelemetryImpl.SendTelemetryOnInsertLogEntryInForegroundSessionEnd(SystemInitialization.IsInProgress(), Session.GetExecutionContext());
        end;
    end;

    [TryFunction]
    local procedure InsertLogEntryInBackgroundSession(var TempRetentionPolicyLogEntry: Record "Retention Policy Log Entry" temporary)
    var
        RetenPolicyTelemetryImpl: Codeunit "Reten. Policy Telemetry Impl.";
        SystemInitialization: Codeunit "System Initialization";
        SessionId: Integer;
    begin
        RetenPolicyTelemetryImpl.SendTelemetryOnInsertLogEntryInBackgroundSessionStart(SystemInitialization.IsInProgress(), Session.GetExecutionContext());

        StartSession(SessionId, Codeunit::"Retention Policy Log Impl.", CompanyName(), TempRetentionPolicyLogEntry);

        RetenPolicyTelemetryImpl.SendTelemetryOnInsertLogEntryInBackgroundSessionEnd(SystemInitialization.IsInProgress(), Session.GetExecutionContext());
    end;

    local procedure CreateLogEntry(MessageType: Enum "Retention Policy Log Message Type"; Category: Enum "Retention Policy Log Category"; Message: Text[2048]; SessionId: Integer)
    var
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
    begin
        RetentionPolicyLogEntry.Category := Category;
        RetentionPolicyLogEntry."Message Type" := MessageType;
        RetentionPolicyLogEntry.Message := Message;
        RetentionPolicyLogEntry."Session Id" := SessionId;
        RetentionPolicyLogEntry.Insert();
    end;
}