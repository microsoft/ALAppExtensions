codeunit 3912 "Reten. Policy Telemetry Impl."
{
    Access = Internal;
    Permissions = tabledata "Retention Policy Log Entry" = r;

    var
        FirstRetenPolEnabledLbl: Label 'First retention policy enabled on: %1', Locked = true;
        LastRetenPolDisabledLbl: Label 'Last retention policy disabled on: %1', Locked = true;
        RecordsDeletedLbl: Label 'Records Deleted Using Retention Policy: Deleted %1 records from Table %2, %3', Locked = true;
        RetenPolEntryLoggedLbl: Label 'Retention Policy Log Entry Logged: %1', Locked = true;
        RetentionPolicySetupLbl: Label 'Retention Policy Setup', Locked = true;
        RetentionPolicySetupValuesLbl: Label 'Retention Policy Setup status was changed to: %1 for table id: %2 with retention period %3', Locked = true;
        RetentionPolicySetupLineValuesLbl: Label 'Retention Policy Setup Line status was changed to: %1 for table id: %2 with retention period %3 and filters: %4', Locked = true;
        EntryDeletedLbl: Label 'Deleted', Locked = true;
        BeforeStartSessionLbl: Label 'Calling StartSession to insert a retention policy log entry.', Locked = true;
        AfterStartSessionLbl: Label 'Called StartSession to insert a retention policy log entry.', Locked = true;
        StartSessionFailureErr: Label 'A call to StartSession failed.', Locked = true;
        BeforeInsertInForegroundLbl: Label 'Inserting a retention policy log entry in foreground.', Locked = true;
        AfterInsertInForegroundLbl: Label 'Inserted a retention policy log entry in foreground.', Locked = true;

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

        Session.LogMessage('0000D3L', StrSubstNo(RetenPolEntryLoggedLbl, RetentionPolicyLogEntry."Message Type"), ConvertMessageTypeToVerbosity(RetentionPolicyLogEntry."Message Type"), DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
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

        Session.LogMessage('0000D6H', StrSubstNo(RecordsDeletedLbl, RecordCount, TableNo, TableName), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
    end;

    procedure SendTelemetryOnInsertLogEntryInForegroundSessionStart(InitializationInProgress: Boolean; CurrenExecutionContext: ExecutionContext)
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add('InitializationInProgress', Format(InitializationInProgress, 0, 9));
        TelemetryDimensions.Add('CurrenExecutionContext', Format(CurrenExecutionContext, 0, 9));

        Session.LogMessage('0000F6G', BeforeInsertInForegroundLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, TelemetryDimensions);
    end;

    procedure SendTelemetryOnInsertLogEntryInForegroundSessionEnd(InitializationInProgress: Boolean; CurrenExecutionContext: ExecutionContext)
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add('InitializationInProgress', Format(InitializationInProgress, 0, 9));
        TelemetryDimensions.Add('CurrenExecutionContext', Format(CurrenExecutionContext, 0, 9));

        Session.LogMessage('0000F6H', AfterInsertInForegroundLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, TelemetryDimensions);
    end;

    procedure SendTelemetryOnInsertLogEntryInBackgroundSessionStart(InitializationInProgress: Boolean; CurrenExecutionContext: ExecutionContext)
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add('InitializationInProgress', Format(InitializationInProgress, 0, 9));
        TelemetryDimensions.Add('CurrenExecutionContext', Format(CurrenExecutionContext, 0, 9));

        Session.LogMessage('0000F6I', BeforeStartSessionLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, TelemetryDimensions);
    end;

    procedure SendTelemetryOnInsertLogEntryInBackgroundSessionEnd(InitializationInProgress: Boolean; CurrenExecutionContext: ExecutionContext)
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add('InitializationInProgress', Format(InitializationInProgress, 0, 9));
        TelemetryDimensions.Add('CurrenExecutionContext', Format(CurrenExecutionContext, 0, 9));

        Session.LogMessage('0000F6J', AfterStartSessionLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, TelemetryDimensions);
    end;

    procedure SendTelemetryOnInsertLogEntryInBackgroundSessionFailed(InitializationInProgress: Boolean; CurrenExecutionContext: ExecutionContext)
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add('InitializationInProgress', Format(InitializationInProgress, 0, 9));
        TelemetryDimensions.Add('CurrenExecutionContext', Format(CurrenExecutionContext, 0, 9));

        Session.LogMessage('0000F6K', StartSessionFailureErr, Verbosity::Error, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, TelemetryDimensions);
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
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        FeatureTelemetry.LogUptake('0000FVW', 'Retention policies', Enum::"Feature Uptake Status"::"Set up");
        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add('TableNo', Format(TableNo, 0, 9));
        TelemetryDimensions.Add('TableName', TableName);
        Session.LogMessage('0000D6I', StrSubstNo(FirstRetenPolEnabledLbl, CompanyName()), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
    end;

    local procedure SendTelemetryOnLastRetentionPolicyDisabled(TableNo: Integer; TableName: Text)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        FeatureTelemetry.LogUptake('0000FVX', 'Retention policies', Enum::"Feature Uptake Status"::Undiscovered);
        TelemetryDimensions.Add('CompanyName', CompanyName());
        TelemetryDimensions.Add('TableNo', Format(TableNo, 0, 9));
        TelemetryDimensions.Add('TableName', TableName);
        Session.LogMessage('0000D6J', StrSubstNo(LastRetenPolDisabledLbl, CompanyName()), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyRetentionPolicySetup(var Rec: Record "Retention Policy Setup"; var xRec: Record "Retention Policy Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        if (Rec.Enabled <> xRec.Enabled) or (Rec."Retention Period" <> xRec."Retention Period") then
            Session.LogSecurityAudit(RetentionPolicySetupLbl, SecurityOperationResult::Success,
                StrSubstNo(RetentionPolicySetupValuesLbl, Rec.Enabled, Rec."Table Id", Rec."Retention Period"), AuditCategory::PolicyManagement);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertRetentionPolicySetup(var Rec: Record "Retention Policy Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        Session.LogSecurityAudit(RetentionPolicySetupLbl, SecurityOperationResult::Success,
            StrSubstNo(RetentionPolicySetupValuesLbl, Rec.Enabled, Rec."Table Id", Rec."Retention Period"), AuditCategory::PolicyManagement);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteRetentionPolicySetup(var Rec: Record "Retention Policy Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        Session.LogSecurityAudit(RetentionPolicySetupLbl, SecurityOperationResult::Success,
            StrSubstNo(RetentionPolicySetupValuesLbl, EntryDeletedLbl, Rec."Table Id", Rec."Retention Period"), AuditCategory::PolicyManagement);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyRetentionPolicySetupLine(var Rec: Record "Retention Policy Setup Line"; var xRec: Record "Retention Policy Setup Line"; RunTrigger: Boolean)
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
        FilterTxt: Text;
    begin
        if Rec.IsTemporary then
            exit;

        FilterTxt := RetentionPolicySetupImpl.GetTableFilterText(Rec);
        if (Rec.Enabled <> xRec.Enabled) or (Rec."Retention Period" <> xRec."Retention Period") or (FilterTxt <> RetentionPolicySetupImpl.GetTableFilterText(xRec)) then
            Session.LogSecurityAudit(RetentionPolicySetupLbl, SecurityOperationResult::Success,
                StrSubstNo(RetentionPolicySetupLineValuesLbl, Rec.Enabled, Rec."Table Id", Rec."Retention Period", FilterTxt), AuditCategory::PolicyManagement);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertRetentionPolicySetupLine(var Rec: Record "Retention Policy Setup Line"; RunTrigger: Boolean)
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        if Rec.IsTemporary then
            exit;
        Session.LogSecurityAudit(RetentionPolicySetupLbl, SecurityOperationResult::Success,
            StrSubstNo(RetentionPolicySetupLineValuesLbl, Rec.Enabled, Rec."Table Id", Rec."Retention Period", RetentionPolicySetupImpl.GetTableFilterText(Rec)),
            AuditCategory::PolicyManagement);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Retention Policy Setup Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteRetentionPolicySetupLine(var Rec: Record "Retention Policy Setup Line"; RunTrigger: Boolean)
    var
        RetentionPolicySetupImpl: Codeunit "Retention Policy Setup Impl.";
    begin
        if Rec.IsTemporary then
            exit;
        Session.LogSecurityAudit(RetentionPolicySetupLbl, SecurityOperationResult::Success,
            StrSubstNo(RetentionPolicySetupLineValuesLbl, EntryDeletedLbl, Rec."Table Id", Rec."Retention Period", RetentionPolicySetupImpl.GetTableFilterText(Rec)),
            AuditCategory::PolicyManagement);
    end;
}