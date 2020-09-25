codeunit 1940 "MigrationGP Item Migrator"
{
    TableNo = "MigrationGP Item";

    var
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;
        ItemTypeOption: Option Inventory,Service;
        CostingMethodOption: Option FIFO,LIFO,Specific,Average,Standard;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateItem', '', true, true)]
    procedure OnMigrateItem(VAR Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationGPItem: Record "MigrationGP Item";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"MigrationGP Item" then
            exit;
        MigrationGPItem.Get(RecordIdToMigrate);
        MigrateItemDetails(MigrationGPItem, Sender);
    end;

    procedure MigrateItemDetails(MigrationGPItem: Record "MigrationGP Item"; ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    begin
        if not ItemDataMigrationFacade.CreateItemIfNeeded(CopyStr(MigrationGPItem.No, 1, 20), MigrationGPItem.Description, MigrationGPItem.ShortName, ConvertItemType(MigrationGPItem.ItemType)) then
            exit;
        ItemDataMigrationFacade.CreateUnitOfMeasureIfNeeded(MigrationGPItem.BaseUnitOfMeasure, MigrationGPItem.BaseUnitOfMeasure);
        ItemDataMigrationFacade.CreateUnitOfMeasureIfNeeded(MigrationGPItem.PurchUnitOfMeasure, MigrationGPItem.PurchUnitOfMeasure);

        ItemDataMigrationFacade.SetUnitListPrice(MigrationGPItem.UnitListPrice);
        ItemDataMigrationFacade.SetUnitCost(MigrationGPItem.CurrentCost);
        ItemDataMigrationFacade.SetStandardCost(MigrationGPItem.StandardCost);
        ItemDataMigrationFacade.SetCostingMethod(GetCostingMethod(MigrationGPItem));
        ItemDataMigrationFacade.SetBaseUnitOfMeasure(MigrationGPItem.BaseUnitOfMeasure);
        ItemDataMigrationFacade.SetGeneralProductPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 20));
        ItemDataMigrationFacade.SetNetWeight(MigrationGPItem.ShipWeight);
        ItemDataMigrationFacade.SetSearchDescription(MigrationGPItem.SearchDescription);
        ItemDataMigrationFacade.SetPurchUnitOfMeasure(MigrationGPItem.PurchUnitOfMeasure);
        ItemDataMigrationFacade.SetItemTrackingCode(MigrationGPItem.ItemTrackingCode);
        ItemDataMigrationFacade.ModifyItem(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateItemPostingGroups', '', true, true)]
    procedure OnMigrateItemPostingGroups(VAR Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        MigrationGPItem: Record "MigrationGP Item";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationGP Item" then
            exit;

        Sender.CreateInventoryPostingSetupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 20), CopyStr(PostingGroupDescriptionTxt, 1, 50), '');
        Sender.SetInventoryPostingSetupInventoryAccount(CopyStr(PostingGroupCodeTxt, 1, 20), '', HelperFunctions.GetPostingAccountNumber('InventoryAccount'));

        if MigrationGPItem.Get(RecordIdToMigrate) then
            if MigrationGPItem.ItemType = 0 then
                Sender.SetInventoryPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 20));

        Sender.ModifyItem(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateInventoryTransactions', '', true, true)]
    procedure OnMigrateInventoryTransactions(VAR Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        Item: Record Item;
        MigrationGPItem: Record "MigrationGP Item";
        AdjustItemInventory: Codeunit "Adjust Item Inventory";
        ErrorText: Text;
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationGP Item" then
            exit;

        if MigrationGPItem.Get(RecordIdToMigrate) then begin
            if MigrationGPItem.ItemType = 0 then
                if MigrationGPItem.QuantityOnHand <> 0 then
                    if Item.Get(MigrationGPItem.No) then
                        ErrorText := AdjustItemInventory.PostAdjustmentToItemLedger(Item, MigrationGPItem.QuantityOnHand);

            if MigrationGPItem.InActive then begin
                Item.Reset();
                if Item.Get(MigrationGPItem.No) then begin
                    Item.Blocked := true;
                    Item.Modify(true);
                end;
            end;
        end;

        if ErrorText <> '' then
            Error(ErrorText);
    end;

    local procedure ConvertItemType(MigrationGPItemType: Integer): Option
    begin
        if MigrationGPItemType = 0 then
            exit(ItemTypeOption::Inventory);

        exit(ItemTypeOption::Service);
    end;

    procedure GetAll()
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        JArray: JsonArray;
    begin
        HelperFunctions.GetEntities('Item', JArray);
        GetItemsFromJson(JArray);
    end;

    local procedure GetItemsFromJson(JArray: JsonArray)
    var
        MigrationGPItem: Record "MigrationGP Item";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[75];
        i: Integer;
    begin
        i := 0;
        MigrationGPItem.Reset();
        MigrationGPItem.DeleteAll();

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.GetTextFromJToken(ChildJToken, 'ITEMNMBR'), 1, MAXSTRLEN(MigrationGPItem.No));
            EntityId := CopyStr(HelperFunctions.TrimBackslash(EntityId), 1, 75);
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(EntityId), 1, 75);
            if strlen(EntityId) > 20 then
                EntityId := CopyStr(EntityId, 1, 20);

            if not MigrationGPItem.Get(EntityId) then begin
                MigrationGPItem.Init();
                MigrationGPItem.Validate(MigrationGPItem.No, EntityId);
                MigrationGPItem.Insert(true);
            end;

            RecordVariant := MigrationGPItem;
            UpdateItemFromJson(RecordVariant, ChildJToken);
            MigrationGPItem := RecordVariant;
            MigrationGPItem.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateItemFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationGPItem: Record "MigrationGP Item";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(Description), JToken.AsObject(), 'SEARCHDESC');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(SearchDescription), JToken.AsObject(), 'SEARCHDESC');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(ShortName), JToken.AsObject(), 'ITMSHNAM');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(BaseUnitOfMeasure), JToken.AsObject(), 'BASEUOFM');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(ItemType), JToken.AsObject(), 'ITEMTYPE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(CostingMethod), JToken.AsObject(), 'COSTINGMETHOD');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(CurrentCost), JToken.AsObject(), 'CURRCOST');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(StandardCost), JToken.AsObject(), 'STNDCOST');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(UnitListPrice), JToken.AsObject(), 'UNITLISTPRICE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(ShipWeight), JToken.AsObject(), 'ITEMSHWT');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(InActive), JToken.AsObject(), 'INACTIVE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(QuantityOnHand), JToken.AsObject(), 'QTYONHND');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(SalesUnitOfMeasure), JToken.AsObject(), 'SELNGUOM');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPItem.FieldNo(PurchUnitOfMeasure), JToken.AsObject(), 'PRCHSUOM');
    end;

    local procedure GetCostingMethod(var MigrationGPItem: Record "MigrationGP Item"): Option
    begin
        if ConvertItemType(MigrationGPItem.ItemType) = ItemTypeOption::Service then
            exit(CostingMethodOption::FIFO);

        case MigrationGPItem.CostingMethod of
            '0':
                exit(CostingMethodOption::FIFO);
            '1':
                exit(CostingMethodOption::LIFO);
            '2':
                exit(CostingMethodOption::Specific);
            '3':
                exit(CostingMethodOption::Average);
            '4':
                exit(CostingMethodOption::Standard);
        end;
    end;
}