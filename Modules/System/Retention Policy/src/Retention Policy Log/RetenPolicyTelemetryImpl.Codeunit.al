codeunit 3912 "Reten. Policy Telemetry Impl."
{
    Access = Internal;
    Permissions = tabledata "Retention Policy Log Entry" = r;

    var
        FirstRetenPolEnabledLbl: Label 'First retention policy enabled on: %1', Locked = true;
        LastRetenPolDisabledLbl: Label 'Last retention policy disabled on: %1', Locked = true;
        RecordsDeletedLbl: Label 'Records Deleted Using Retention Policy: Deleted %1 records from Table %2, %3', Locked = true;
        RetenPolEntryLoggedLbl: Label 'Retention Policy Log Entry Logged: %1', Locked = true;

    procedure SendLogEntryToTelemetry(RetentionPolicyLogEntry: Record "Retention Policy Log Entry")
    var
        SavedGlobalLanguage: Integer;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        SavedGlobalLanguage := GlobalLanguage();
        GlobalLanguage := 1033; // ENU

        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add(RetentionPolicyLogEntry.FieldName(Category), Format(RetentionPolicyLogEntry.Category));
        TelemetryDimensions.Add(DelChr(RetentionPolicyLogEntry.FieldName("Message Type"), '=', ' '), Format(RetentionPolicyLogEntry."Message Type"));
        TelemetryDimensions.Add('LogEntry', RetentionPolicyLogEntry.Message);

        Session.LogMessage('0000D3L', StrSubstNo(RetenPolEntryLoggedLbl, RetentionPolicyLogEntry."Message Type"), ConvertMessageTypeToVerbosity(RetentionPolicyLogEntry."Message Type"), DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
        GlobalLanguage := SavedGlobalLanguage;
    end;

    procedure SendTelemetryOnRecordsDeleted(TableNo: Integer; TableName: Text; RecordCount: Integer; ManualRun: Boolean)
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add('TableNo', Format(TableNo, 0, 9));
        TelemetryDimensions.Add('TableName', TableName);
        TelemetryDimensions.Add('RecordsDeleted', Format(RecordCount, 0, 9));
        TelemetryDimensions.Add('ManualRun', Format(ManualRun, 0, 9));

        Session.LogMessage('0000D6H', StrSubstNo(RecordsDeletedLbl, RecordCount, TableNo, TableName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure SendTelemetryOnAfterInsert(var Rec: Record "Retention Policy Setup")
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        RetentionPolicySetup.SetRange(Enabled, true);
        if (RetentionPolicySetup.Count() = 1) and Rec.Enabled then begin
            Rec.CalcFields("Table Name");
            SendTelemetryOnFirstRetentionPolicyEnabled(Rec."Table Id", Rec."Table Name");
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SendTelemetryOnAfterModify(var Rec: Record "Retention Policy Setup"; var xRec: Record "Retention Policy Setup")
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        Count: Integer;
    begin
        if Rec.IsTemporary() then
            exit;

        Rec.CalcFields("Table Name");

        RetentionPolicySetup.SetRange(Enabled, true);
        Count := RetentionPolicySetup.Count();
        if (Count = 1) and Rec.Enabled and (not xrec.Enabled) then begin
            SendTelemetryOnFirstRetentionPolicyEnabled(Rec."Table Id", Rec."Table Name");
            exit;
        end;

        if (Count = 0) and xRec.Enabled and (not Rec.Enabled) then begin
            SendTelemetryOnLastRetentionPolicyDisabled(Rec."Table Id", Rec."Table Name");
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SendTelemetryOnAfterDelete(var Rec: Record "Retention Policy Setup")
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        RetentionPolicySetup.SetRange(Enabled, true);
        if (RetentionPolicySetup.Count() = 0) and Rec.Enabled then begin
            Rec.CalcFields("Table Name");
            SendTelemetryOnLastRetentionPolicyDisabled(Rec."Table Id", Rec."Table Name");
            exit;
        end;
    end;

    local procedure ConvertMessageTypeToVerbosity(MessageType: Enum "Retention Policy Log Message Type"): Verbosity
    begin
        case MessageType of
            MessageType::Error:
                exit(Verbosity::Error);
            MessageType::Info:
                exit(verbosity::Normal);
            MessageType::Warning:
                exit(Verbosity::Warning);
            else
                exit(Verbosity::Verbose);
        end;
    end;

    local procedure SendTelemetryOnFirstRetentionPolicyEnabled(TableNo: Integer; TableName: Text)
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add('TableNo', Format(TableNo, 0, 9));
        TelemetryDimensions.Add('TableName', TableName);
        Session.LogMessage('0000D6I', StrSubstNo(FirstRetenPolEnabledLbl, CompanyName()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
    end;

    local procedure SendTelemetryOnLastRetentionPolicyDisabled(TableNo: Integer; TableName: Text)
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add('TableNo', Format(TableNo, 0, 9));
        TelemetryDimensions.Add('TableName', TableName);
        Session.LogMessage('0000D6J', StrSubstNo(LastRetenPolDisabledLbl, CompanyName()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
    end;
}