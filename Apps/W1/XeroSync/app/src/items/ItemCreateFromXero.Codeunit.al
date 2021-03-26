codeunit 2450 "XS Item Create From Xero"
{
    TableNo = "Sync Change";

    trigger OnRun()
    begin
        ItemCreateFromXero(Rec);
    end;

    var
        XeroSyncTracker: Codeunit "XS Xero Sync Tracker";
        UpdatedDateUTC: Text;

    procedure ItemCreateFromXero(var SyncChange: Record "Sync Change")
    var
        Handled: Boolean;
    begin
        OnBeforeItemCreateFromXero(SyncChange, UpdatedDateUTC, Handled);

        UpdatedDateUTC := DoItemCreateFromXero(SyncChange, Handled);

        OnAfterItemCreateFromXero(UpdatedDateUTC);
    end;

    local procedure DoItemCreateFromXero(var SyncChange: Record "Sync Change"; var Handled: Boolean) UpdatedDateUTC: Text
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        RecRef: RecordRef;
        ItemJson: JsonObject;
        ItemIsNotSynchedTxt: Label 'Item (%1) is not synchronized. Direction: %2';
    begin
        if Handled then
            exit;

        RecRef.GetTable(SyncChange);

        ItemJson := JsonObjectHelper.GetBLOBDataAsJsonObject(RecRef, SyncChange.FieldNo("XS Xero Json Response"));

        UpdatedDateUTC := GetItemData(ItemJson, TempItem);
        OnBeforeInsertItem(ItemJson, TempItem);

        if DoInsertItem(Item, TempItem) then
            SyncChange.UpdateSyncChangeWithInternalID(Item.RecordId())
        else
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(ItemIsNotSynchedTxt, Item.Description, SyncChange.Direction));
    end;

    local procedure GetItemData(var ItemJson: JsonObject; var TempItem: Record Item) UpdatedDateUTC: Text
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        Item: Record Item;
        ItemTemplate: Record "Item Template";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        ItemNo: Code[20];
        Token: JsonToken;
    begin
        JsonObjectHelper.SetJsonObject(ItemJson);
        TempItem.Init();

        ItemNo := CopyStr(JsonObjectHelper.GetJsonValueAsText('Code'), 1, MaxStrLen(ItemNo));
        if not Item.Get(ItemNo) then
            TempItem.Validate("No.", ItemNo);


        ConfigTemplateHeader.SetRange(Enabled, true);
        ConfigTemplateHeader.SetRange("Table ID", Database::Item);
        if ConfigTemplateHeader.FindFirst() then
            ItemTemplate.InsertItemFromTemplate(ConfigTemplateHeader, TempItem);

        UpdatedDateUTC := JsonObjectHelper.GetJsonValueAsText('UpdatedDateUTC');

        TempItem.Validate(Description, CopyStr(JsonObjectHelper.GetJsonValueAsText('Name'), 1, MaxStrLen(TempItem.Description)));

        TempItem.Validate("Description 2", CopyStr(JsonObjectHelper.GetJsonValueAsText('Description'), 1, MaxStrLen(TempItem."Description 2")));

        TempItem.Validate(Type, Item.Type::Service);

        Token := JsonObjectHelper.GetJsonToken('SalesDetails');
        JsonObjectHelper.SetJsonObject(Token);
        TempItem.Validate("Unit Price", JsonObjectHelper.GetJsonValueAsDecimal('UnitPrice'));
        TempItem.Validate("XS Tax Type", CopyStr(JsonObjectHelper.GetJsonValueAsText('TaxType'), 1, MaxStrLen(TempItem."XS Tax Type")));
        TempItem.Validate("XS Account Code", CopyStr(JsonObjectHelper.GetJsonValueAsText('AccountCode'), 1, MaxStrLen(TempItem."XS Account Code")));

        JsonObjectHelper.SetJsonObject(ItemJson);
        Token := JsonObjectHelper.GetJsonToken('PurchaseDetails');
        JsonObjectHelper.SetJsonObject(Token);
        TempItem.Validate("Unit Cost", JsonObjectHelper.GetJsonValueAsDecimal('UnitPrice'));

        XeroSyncTracker.SetCalledFromXeroSync(true);
        BindSubscription(XeroSyncTracker);
    end;

    local procedure DoInsertItem(var Item: Record Item; TempItem: Record Item): Boolean
    begin
        Item := TempItem;
        exit(Item.Insert(true));
    end;

    procedure GetUpdatedDateUTC(): Text
    begin
        exit(UpdatedDateUTC);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertItem(var ItemJson: JsonObject; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemCreateFromXero(var SyncChange: Record "Sync Change"; var UpdatedDateUTC: Text; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterItemCreateFromXero(var UpdatedDateUTC: Text);
    begin
    end;
}