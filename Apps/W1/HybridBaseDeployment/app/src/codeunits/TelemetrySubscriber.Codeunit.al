namespace Microsoft.DataMigration;

codeunit 40022 "Telemetry Subscriber"
{
    SingleInstance = true;

    var
        CreatedTok: Label 'Created';
        ModifiedTok: Label 'Modified';
        RenameTok: Label 'Renamed';
        DeletedTok: Label 'Deleted';
        TableMappingChangedLbl: Label 'Table mapping has been %1 by UserSecurityId %2.', Comment = '%1 - Event type, %2 - User Security ID', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Migration Table Mapping", OnAfterInsertEvent, '', true, true)]
    local procedure LogTableMappingInsert(var Rec: Record "Migration Table Mapping")
    begin
        LogTableMappingTelemetry(Rec, CreatedTok);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Migration Table Mapping", OnAfterModifyEvent, '', true, true)]
    local procedure LogTableMappingModify(var Rec: Record "Migration Table Mapping")
    begin
        LogTableMappingTelemetry(Rec, ModifiedTok);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Migration Table Mapping", OnAfterRenameEvent, '', true, true)]
    local procedure LogTableMappingRename(var Rec: Record "Migration Table Mapping")
    begin
        LogTableMappingTelemetry(Rec, RenameTok);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Migration Table Mapping", OnAfterDeleteEvent, '', true, true)]
    local procedure LogTableMappingDelete(var Rec: Record "Migration Table Mapping")
    begin
        LogTableMappingTelemetry(Rec, DeletedTok);
    end;

    local procedure LogTableMappingTelemetry(var MigrationTableMapping: Record "Migration Table Mapping"; EventType: Text)
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if MigrationTableMapping.IsTemporary() then
            exit;

        TelemetryDimensions.Add('TableName', MigrationTableMapping."Table Name");
        TelemetryDimensions.Add('SourceTableName', MigrationTableMapping."Source Table Name");
        TelemetryDimensions.Add('TargetTableType', Format(MigrationTableMapping."Target Table Type"));

        Session.LogAuditMessage(StrSubstNo(TableMappingChangedLbl, EventType, UserSecurityId()), SecurityOperationResult::Success, AuditCategory::ApplicationManagement, 6, 0, TelemetryDimensions);
    end;
}