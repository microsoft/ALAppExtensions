codeunit 2455 "Xero Sync Telemetry"
{
    var
        XeroCategoryLbl: Label 'Xero Sync', Comment = 'Locked';
        XeroSyncEnabledLbl: Label 'Xero Sync Enabled.', Comment = 'Locked';
        XeroSyncStoppedLbl: Label 'Xero Sync Stopped.', Comment = 'Locked';
        XeroEntityAddedForSyncLbl: Label 'A record from table %1 was added for sync. Change Type: %2, Direction %3', Comment = 'Locked';
        XeroUnsuccessfulSyncLbl: Label 'Maximum number of retries reached the record will be skipped. Error Message: %1', Comment = 'Locked';


    [EventSubscriber(ObjectType::Table, DataBase::"Sync Change", 'OnBeforeUpdateSyncChangeWithErrorMessage', '', true, true)]
    local procedure OnBeforeUpdateSyncChangeWithErrorMessageSubscriber(ErrorMessage: Text)
    begin
        Session.LogMessage('000029F', ErrorMessage, Verbosity::Error, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', XeroCategoryLbl);
    end;

    [EventSubscriber(ObjectType::Page, Page::"XS Xero Synchronization Wizard", 'OnAfterXeroSyncEnabled', '', true, true)]
    local procedure OnAfterXeroSyncEnabledSubscriber()
    begin
        Session.LogMessage('000029G', XeroSyncEnabledLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', XeroCategoryLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sync Setup", 'OnAfterXeroSyncStopped', '', true, true)]
    local procedure OnAfterXeroSyncStoppedSubScriber()
    begin
        Session.LogMessage('000029H', XeroSyncStoppedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', XeroCategoryLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sync Change", 'OnAfterInsertRecord', '', true, true)]
    local procedure OnAfterInsertRecordSubscriber(SyncChange: Record "Sync Change")
    var
        Entity: Text;
    begin
        case SyncChange."XS NAV Entity ID" of
            Database::Item:
                Entity := 'Item';
            Database::Customer:
                Entity := 'Customer';
            Database::"Sales Invoice Header":
                Entity := 'Invoice';
            else
                Entity := 'Other';
        end;
        Session.LogMessage('000029I', StrSubstNo(XeroEntityAddedForSyncLbl, Entity, SyncChange."Change Type", SyncChange.Direction), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', XeroCategoryLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sync Job", 'OnCreateJobQueueEntryLogForUnsuccessfulSync', '', true, true)]
    local procedure OnCreateJobQueueEntryLogForUnsuccessfulSyncSubScriber(var JobQueueEntry: Record "Job Queue Entry"; ErrorMessage: Text)
    begin
        Session.LogMessage('000029J', StrSubstNo(XeroUnsuccessfulSyncLbl, ErrorMessage), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', XeroCategoryLbl);
    end;
}
