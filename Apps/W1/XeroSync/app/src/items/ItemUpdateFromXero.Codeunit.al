codeunit 2451 "XS Item Update From Xero"
{
    var
        XeroSyncTracker: Codeunit "XS Xero Sync Tracker";

    procedure ItemUpdateFromXero(var SyncChange: Record "Sync Change"; var Success: Boolean; var FalseIncomingChange: Boolean) UpdatedDateUTC: Text
    var
        Handled: Boolean;
    begin
        OnBeforeItemUpdateFromXero(SyncChange, UpdatedDateUTC, Handled);

        UpdatedDateUTC := DoItemUpdateFromXero(SyncChange, Success, FalseIncomingChange, Handled);

        OnAfterItemUpdateFromXero(UpdatedDateUTC);
    end;

    local procedure DoItemUpdateFromXero(var SyncChange: Record "Sync Change"; var Success: Boolean; var FalseIncomingChange: Boolean; var Handled: Boolean) UpdatedDateUTC: Text
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        RecRef: RecordRef;
        RecRefItem: RecordRef;
        RecRefTempItem: RecordRef;
        ItemJson: JsonObject;
        DoUpdate: Boolean;
        ItemLedgerEntryExists: Boolean;
        ItemDoesntExistErr: Label 'Item can not be updated from Xero because the item does not exists.';
        ItemIsNotSynchedErr: Label 'Item (%1 - %2) is not synchronized. Direction: %3';
    begin
        if Handled then
            exit;

        RecRef.GetTable(SyncChange);

        ItemJson := JsonObjectHelper.GetBLOBDataAsJsonObject(RecRef, SyncChange.FieldNo("XS Xero Json Response"));

        if not GetItem(ItemJson, Item) then
            SyncChange.UpdateSyncChangeWithErrorMessage(ItemDoesntExistErr);

        ItemLedgerEntryExists := CheckIfItemLedgerEntryExists(Item);

        UpdatedDateUTC := GetItemData(ItemJson, TempItem, Item, ItemLedgerEntryExists);

        RecRefItem.GetTable(Item);
        RecRefTempItem.GetTable(TempItem);

        DoUpdate := XeroSyncManagement.CompareRecords(RecRefTempItem, RecRefItem, Database::Item);

        if not DoUpdate then begin
            FalseIncomingChange := true;
            exit;
        end;

        OnBeforeUpdateItem(ItemJson, TempItem);
        RecRefItem.SetTable(Item);
        if DoUpdateItem(Item) then begin
            SyncChange.UpdateSyncChangeWithInternalID(Item.RecordId());
            Success := true;
        end else
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(ItemIsNotSynchedErr, Item."No.", Item.Description, SyncChange.Direction));
    end;

    local procedure GetItem(var ItemJson: JsonObject; var Item: Record Item): Boolean
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
    begin
        JsonObjectHelper.SetJsonObject(ItemJson);
        exit(Item.Get(JsonObjectHelper.GetJsonValueAsText('Code')));
    end;

    local procedure CheckIfItemLedgerEntryExists(var Item: Record Item): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.Reset();
        ItemLedgEntry.SetCurrentKey("Item No.");
        ItemLedgEntry.SetRange("Item No.", Item."No.");
        exit(not ItemLedgEntry.IsEmpty());
    end;

    local procedure GetItemData(var ItemJson: JsonObject; var TempItem: Record Item; var Item: Record Item; ItemLedgerEntryExists: Boolean) UpdatedDateUTC: Text
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        Token: JsonToken;
    begin
        JsonObjectHelper.SetJsonObject(ItemJson);

        UpdatedDateUTC := JsonObjectHelper.GetJsonValueAsText('UpdatedDateUTC');

        TempItem.Validate(Type, Item.Type::Service);

        TempItem.Validate("No.", JsonObjectHelper.GetJsonValueAsText('Code'));

        TempItem.Validate(Description, CopyStr(JsonObjectHelper.GetJsonValueAsText('Name'), 1, MaxStrLen(Item.Description)));

        TempItem.Validate("Description 2", CopyStr(JsonObjectHelper.GetJsonValueAsText('Description'), 1, MaxStrLen(Item."Description 2")));

        Token := JsonObjectHelper.GetJsonToken('SalesDetails');
        JsonObjectHelper.SetJsonObject(Token);
        TempItem.Validate("Unit Price", JsonObjectHelper.GetJsonValueAsDecimal('UnitPrice'));
        TempItem.Validate("XS Tax Type", CopyStr(JsonObjectHelper.GetJsonValueAsText('TaxType'), 1, MaxStrLen(TempItem."XS Tax Type")));
        TempItem.Validate("XS Account Code", CopyStr(JsonObjectHelper.GetJsonValueAsText('AccountCode'), 1, MaxStrLen(TempItem."XS Account Code")));

        if not ItemLedgerEntryExists then begin
            JsonObjectHelper.SetJsonObject(ItemJson);
            Token := JsonObjectHelper.GetJsonToken('PurchaseDetails');
            JsonObjectHelper.SetJsonObject(Token);
            TempItem.Validate("Unit Cost", JsonObjectHelper.GetJsonValueAsDecimal('UnitPrice'));
        end;

        XeroSyncTracker.SetCalledFromXeroSync(true);
        BindSubscription(XeroSyncTracker);
    end;

    local procedure DoUpdateItem(var Item: Record Item): Boolean
    begin
        exit(Item.Modify(true));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateItem(var ItemJson: JsonObject; var TempItem: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemUpdateFromXero(var SyncChange: Record "Sync Change"; UpdatedDateUTC: Text; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterItemUpdateFromXero(UpdatedDateUTC: Text);
    begin
    end;
}