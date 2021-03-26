codeunit 2425 "XS Update Sync Change Record"
{
    procedure UpdateSyncChangeRecord(var SyncChange: Record "Sync Change"; EntityDataJsonText: Text; ChangeType: Option Create,Update,Delete," ");
    var
        Handled: Boolean;
    begin
        OnBeforeUpdateSyncChangeRecord(SyncChange, Handled);

        DoUpdateSyncChangeRecord(SyncChange, EntityDataJsonText, ChangeType);

        OnAfterUpdateSyncChangeRecord(SyncChange);
    end;

    local procedure DoUpdateSyncChangeRecord(var SyncChange: Record "Sync Change"; EntityDataJsonText: Text; ChangeType: Option Create,Update,Delete," ")
    begin
        UpdateChangeType(SyncChange, ChangeType);

        UpdateEntityJsonData(SyncChange, EntityDataJsonText);
    end;

    local procedure UpdateChangeType(var SyncChange: Record "Sync Change"; ChangeType: Option Create,Update,Delete," ")
    begin
        SyncChange.Validate("Change Type", ChangeType);
    end;

    local procedure UpdateEntityJsonData(var SyncChange: Record "Sync Change"; EntityDataJsonText: Text)
    var
        OutStream: OutStream;
    begin
        SyncChange."NAV Data".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(EntityDataJsonText);
        SyncChange.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSyncChangeRecord(SyncChange: Record "Sync Change"; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateSyncChangeRecord(SyncChange: Record "Sync Change");
    begin
    end;
}