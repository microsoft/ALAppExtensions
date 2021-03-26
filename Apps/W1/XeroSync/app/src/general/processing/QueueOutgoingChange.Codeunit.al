codeunit 2420 "XS Queue Outgoing Change"
{
    procedure QueueOutgoingChange(var RecRef: RecordRef; var SyncChange: Record "Sync Change"; ChangeType: Option Create,Update,Delete," ");
    var
        Handled: Boolean;
    begin
        OnBeforeQueueOutgoingChange(Handled);

        DoQueueOutgoingChange(RecRef, SyncChange, ChangeType, Handled);

        OnAfterQueueOutgoingChange();
    end;

    local procedure DoQueueOutgoingChange(var RecRef: RecordRef; var SyncChange: Record "Sync Change"; ChangeType: Option Create,Update,Delete," "; var Handled: Boolean);
    var
        SyncMapping: Record "Sync Mapping";
        XeroSyncTrackerEvents: Codeunit "XS Xero Sync Tracker Events";
        IsCalledFromXeroSync: Boolean;
    begin
        if Handled then
            exit;

        XeroSyncTrackerEvents.OnBeforeQueueEntityForSync(IsCalledFromXeroSync);

        if RecRef.IsTemporary() then
            exit;

        if IsCalledFromXeroSync then
            exit;

        SetSyncChangeDirection(SyncChange);

        SetInternalID(SyncChange, RecRef.RecordId());
        FilterSyncMapping(SyncChange, SyncMapping);

        SetChangeType(SyncChange, SyncMapping, ChangeType);

        if SyncChange."Change Type" = SyncChange."Change Type"::Delete then
            if SyncMapping.IsEmpty() then begin
                if SyncChangeForEntityExists(SyncChange."Internal ID") then begin
                    GetSyncChange(SyncChange, SyncChange."Internal ID");
                    SyncChange.Delete();
                end;
                exit;
            end else
                SyncMapping.FindFirst();

        if SyncChangeForEntityExists(RecRef.RecordId()) then begin
            if (ChangeType <> ChangeType::Update) and (ChangeType <> ChangeType::Delete) then
                GetSyncChange(SyncChange, RecRef.RecordId());
            UpdateSyncChange(SyncChange, RecRef);
        end else
            SyncChange.CreateSyncChangeRecord(RecRef.Number(), CreateEntityDataJsonText(RecRef, SyncChange."Change Type"));
    end;

    local procedure SetSyncChangeDirection(var SyncChange: Record "Sync Change")
    begin
        SyncChange.Validate(Direction, SyncChange.Direction::Outgoing);
    end;

    local procedure FilterSyncMapping(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping")
    begin
        SyncMapping.SetRange("Internal ID", SyncChange."Internal ID");
    end;

    local procedure SetChangeType(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping"; ChangeType: Option Create,Update,Delete," ")
    begin
        if ChangeType = ChangeType::Delete then
            SyncChange."Change Type" := ChangeType
        else begin
            SyncMapping.SetRange("XS Active", true);
            if SyncMapping.FindFirst() then
                SyncChange."Change Type" := SyncChange."Change Type"::Update
            else
                SyncChange."Change Type" := SyncChange."Change Type"::Create;
        end;
    end;

    local procedure SetInternalID(var SyncChange: Record "Sync Change"; RecID: RecordId)
    begin
        SyncChange."Internal ID" := RecID;
    end;

    local procedure SyncChangeForEntityExists(RecID: RecordId): Boolean
    var
        SyncChange: Record "Sync Change";
    begin
        SyncChange.SetRange("Internal ID", RecID);
        SyncChange.SetRange(Direction, SyncChange.Direction::Outgoing);
        exit(SyncChange.FindFirst());
    end;

    local procedure GetSyncChange(var SyncChange: Record "Sync Change"; RecID: RecordId): Boolean
    begin
        SyncChange.SetRange("Internal ID", RecID);
        SyncChange.SetRange(Direction, SyncChange.Direction::Outgoing);
        exit(SyncChange.FindFirst());
    end;

    local procedure UpdateSyncChange(var SyncChange: Record "Sync Change"; var RecRef: RecordRef)
    var
        ExistingSyncChange: Record "Sync Change";
    begin
        ExistingSyncChange.CopyFilters(SyncChange);
        if ExistingSyncChange.FindFirst() then
            ExistingSyncChange.UpdateSyncChangeRecord(CreateEntityDataJsonText(RecRef, SyncChange."Change Type"), SyncChange."Change Type");
        SyncChange := ExistingSyncChange;
        SyncChange.Modify(true);
    end;

    local procedure CreateEntityDataJsonText(var RecRef: RecordRef; ChangeType: Option Create,Update,Delete," "): Text
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesInvoice: Record "Sales Invoice Header";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
    begin
        case RecRef.Number() of
            Database::Customer:
                begin
                    RecRef.SetTable(Customer);
                    if ChangeType = ChangeType::Delete then
                        exit(XeroSyncManagement.CreateCustomerDeleteJson())
                    else
                        exit(XeroSyncManagement.CreateCustomerDataJson(Customer, ChangeType));
                end;
            Database::Item:
                begin
                    RecRef.SetTable(Item);
                    if ChangeType <> ChangeType::Delete then
                        exit(XeroSyncManagement.CreateItemDataJson(Item));
                end;
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvoice);
                    if ChangeType <> ChangeType::Delete then
                        exit(XeroSyncManagement.CreateSalesInvoiceJson(SalesInvoice));
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeQueueOutgoingChange(var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterQueueOutgoingChange();
    begin
    end;
}