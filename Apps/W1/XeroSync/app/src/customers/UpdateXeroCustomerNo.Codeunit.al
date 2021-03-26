codeunit 2408 "XS Update Xero Customer No."
{
    procedure UpdateXeroContactWithNAVCustomerNo(var Customer: Record Customer; var SyncMapping: Record "Sync Mapping");
    var
        Handled: Boolean;
    begin
        OnBeforeUpdateXeroContactWithNAVCustomerNo(Handled);

        DoUpdateXeroContactWithNAVCustomerNo(Customer, SyncMapping, Handled);

        OnAfterUpdateXeroContactWithNAVCustomerNo();
    end;

    local procedure DoUpdateXeroContactWithNAVCustomerNo(var Customer: Record Customer; var SyncMapping: Record "Sync Mapping"; var Handled: Boolean);
    var
        SyncChange: Record "Sync Change";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        XeroSyncTrackerEvents: Codeunit "XS Xero Sync Tracker Events";
        RecRef: RecordRef;
        IsCalledFromXeroSync: Boolean;
    begin
        if Handled then
            exit;

        XeroSyncTrackerEvents.OnBeforeQueueEntityForSync(IsCalledFromXeroSync);

        if Customer.IsTemporary() then
            exit;

        if IsCalledFromXeroSync then
            exit;

        SyncChange.Insert(true);
        CopyDataFromOldSyncChange(SyncMapping, SyncChange);
        SetSyncChangeDirection(SyncChange);
        SetChangeType(SyncChange);

        RecRef.GetTable(Customer);
        SyncChange.UpdateSyncChangeRecord(XeroSyncManagement.CreateCustomerDataJson(Customer, SyncChange."Change Type"), SyncChange."Change Type");
    end;

    local procedure CopyDataFromOldSyncChange(var SyncMapping: Record "Sync Mapping"; var NewSyncChange: Record "Sync Change")
    begin
        NewSyncChange."Internal ID" := SyncMapping."Internal ID";
        NewSyncChange."External ID" := SyncMapping."External ID";
        NewSyncChange."XS NAV Entity ID" := SyncMapping."XS NAV Entity ID";
    end;

    local procedure SetSyncChangeDirection(var SyncChange: Record "Sync Change")
    begin
        SyncChange.Validate(Direction, SyncChange.Direction::Outgoing);
    end;

    local procedure SetChangeType(var SyncChange: Record "Sync Change")
    begin
        SyncChange."Change Type" := SyncChange."Change Type"::Update;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateXeroContactWithNAVCustomerNo(var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateXeroContactWithNAVCustomerNo();
    begin
    end;
}