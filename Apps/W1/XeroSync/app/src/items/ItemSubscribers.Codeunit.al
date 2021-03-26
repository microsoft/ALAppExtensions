codeunit 2452 "XS Item Subscribers"
{
    var
        ChangeType: Option Create,Update,Delete," ";

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertItem(var Rec: Record Item)
    var
        SyncChange: Record "Sync Change";
        SyncSetup: Record "Sync Setup";
        RecRef: RecordRef;
    begin
        SyncSetup.GetSingleInstance();
        if not SyncSetup."XS Enabled" then
            exit;
        RecRef.GetTable(Rec);
        SyncChange.QueueOutgoingChangeForEntity(RecRef, ChangeType::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyItem(var Rec: Record Item; var xRec: Record Item)
    var
        SyncChange: Record "Sync Change";
        SyncSetup: Record "Sync Setup";
        RecRef: RecordRef;
    begin
        SyncSetup.GetSingleInstance();
        if not SyncSetup."XS Enabled" then
            exit;
        RecRef.GetTable(Rec);
        SyncChange.QueueOutgoingChangeForEntity(RecRef, ChangeType::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteItem(var Rec: Record Item)
    var
        SyncChange: Record "Sync Change";
        SyncSetup: Record "Sync Setup";
        RecRef: RecordRef;
    begin
        SyncSetup.GetSingleInstance();
        if not SyncSetup."XS Enabled" then
            exit;
        RecRef.GetTable(Rec);
        SyncChange.QueueOutgoingChangeForEntity(RecRef, ChangeType::Delete);
    end;
}
