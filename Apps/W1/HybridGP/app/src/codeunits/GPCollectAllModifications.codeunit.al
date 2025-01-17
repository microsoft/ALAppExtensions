namespace Microsoft.DataMigration.GP;

using System.Environment;
using System.Integration;
using Microsoft.DataMigration;

codeunit 40043 "GP Collect All Modifications"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", 'GetDatabaseTableTriggerSetup', '', false, false)]
    local procedure HandleGetDatabaseTriggerSetup(TableId: Integer; var OnDatabaseDelete: Boolean; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseRename: Boolean)
    begin
        if not ShouldLogTable(TableId) then
            exit;

        OnDatabaseDelete := true;
        OnDatabaseInsert := true;
        OnDatabaseModify := true;
        OnDatabaseRename := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", 'OnDatabaseInsert', '', false, false)]
    local procedure HandleDatabaseInsert(RecRef: RecordRef)
    begin
        if not ShouldLogTable(RecRef.Number) then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(StrSubstNo(InsertedLbl, Format(RecRef.RecordId)));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", 'OnDatabaseModify', '', false, false)]
    local procedure HandleDatabaseModify(RecRef: RecordRef)
    begin
        if not ShouldLogTable(RecRef.Number) then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(StrSubstNo(ModifiedLbl, Format(RecRef.RecordId)));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", 'OnDatabaseDelete', '', false, false)]
    local procedure HandleDatabaseDelete(RecRef: RecordRef)
    begin
        if not ShouldLogTable(RecRef.Number) then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(StrSubstNo(DeletedLbl, Format(RecRef.RecordId)));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", 'OnDatabaseRename', '', false, false)]
    local procedure HandleDatabaseRename(RecRef: RecordRef)
    begin
        if not ShouldLogTable(RecRef.Number) then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(StrSubstNo(RenamedLbl, Format(RecRef.RecordId)));
    end;

    local procedure ShouldLogTable(TableId: Integer): Boolean
    var
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if TableId in [
            Database::"Hybrid Company",
            Database::"Hybrid Company Status",
            Database::"Hybrid Replication Detail",
            Database::"Hybrid Replication Summary",
            Database::"Data Migration Error",
            Database::"Data Migration Entity",
            Database::"GP Configuration",
            Database::"GP Upgrade Settings",
            Database::"GP Company Additional Settings",
            Database::"GP Company Migration Settings",
            Database::"GP Migration Error Overview",
            Database::"GP Migration Errors",
            Database::"GP Hist. Source Error",
            Database::"GP Hist. Source Progress"] then
            exit(false);

        exit(HybridGPWizard.GetGPMigrationEnabled());
    end;

    var
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        InsertedLbl: Label 'Inserted - %1', Comment = '%1 represents the record id, e.g. Customer 10000';
        ModifiedLbl: Label 'Modified - %1', Comment = '%1 represents the record id, e.g. Customer 10000';
        DeletedLbl: Label 'Deleted - %1', Comment = '%1 represents the record id, e.g. Customer 10000';
        RenamedLbl: Label 'Renamed - %1', Comment = '%1 represents the record id, e.g. Customer 10000';
}