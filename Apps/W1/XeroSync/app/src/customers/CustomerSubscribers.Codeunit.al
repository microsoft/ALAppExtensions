codeunit 2405 "XS Customer Subscribers"
{
    var
        ChangeType: Option Create,Update,Delete," ";

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertCustomer(var Rec: Record Customer)
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

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyCustomer(var Rec: Record Customer; var xRec: Record Customer)
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

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteCustomer(var Rec: Record Customer)
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