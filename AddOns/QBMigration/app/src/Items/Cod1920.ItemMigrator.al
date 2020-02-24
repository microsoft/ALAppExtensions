codeunit 1920 "MigrationQB Item Migrator"
{
    TableNo = "MigrationQB Item";

    var
        PostingGroupCodeTxt: Label 'QB', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from QB', Locked = true;
        ItemType: Option Inventory,Service;
        CostingMethod: Option FIFO,LIFO,Specific,Average,Standard;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateItem', '', true, true)]
    procedure OnMigrateItem(VAR Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationQBItem: Record "MigrationQB Item";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Item" then
            exit;
        MigrationQBItem.Get(RecordIdToMigrate);
        MigrateItemDetails(MigrationQBItem, Sender);
    end;

    procedure MigrateItemDetails(MigrationQBItem: Record "MigrationQB Item"; ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    begin
        if not ItemDataMigrationFacade.CreateItemIfNeeded(CopyStr(MigrationQBItem.Id, 1, 20), CopyStr(MigrationQBItem.Name, 1, 50), CopyStr(MigrationQBItem.Description, 1, 50), ConvertItemType(MigrationQBItem.Type)) then
            exit;

        ItemDataMigrationFacade.SetUnitPrice(MigrationQBItem.UnitPrice);
        ItemDataMigrationFacade.SetUnitCost(MigrationQBItem.PurchaseCost);
        ItemDataMigrationFacade.SetCostingMethod(GetCostingMethod(MigrationQBItem));
        ItemDataMigrationFacade.SetBaseUnitOfMeasure(GetUnitOfMeasure());
        ItemDataMigrationFacade.SetGeneralProductPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        ItemDataMigrationFacade.ModifyItem(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateItemPostingGroups', '', true, true)]
    procedure OnMigrateItemPostingGroups(VAR Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        MigrationQBItem: Record "MigrationQB Item";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Item" then
            exit;

        Sender.CreateInventoryPostingSetupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 5), CopyStr(PostingGroupDescriptionTxt, 1, 20), '');
        Sender.SetInventoryPostingSetupInventoryAccount(CopyStr(PostingGroupCodeTxt, 1, 5), '', HelperFunctions.GetPostingAccountNumber('InventoryAccount'));

        if MigrationQBItem.Get(RecordIdToMigrate) then
            if MigrationQBItem.Type = 'Inventory' then
                Sender.SetInventoryPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));

        Sender.ModifyItem(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateInventoryTransactions', '', true, true)]
    procedure OnMigrateInventoryTransactions(VAR Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        Item: Record Item;
        MigrationQBItem: Record "MigrationQB Item";
        AdjustItemInventory: Codeunit "Adjust Item Inventory";
        ErrorText: Text;
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Item" then
            exit;

        if MigrationQBItem.Get(RecordIdToMigrate) then
            if MigrationQBItem.Type = 'Inventory' then
                if MigrationQBItem.QtyOnHand > 0 then
                    if item.Get(MigrationQBItem.Id) then
                        ErrorText := AdjustItemInventory.PostAdjustmentToItemLedger(Item, MigrationQBItem.QtyOnHand);

        if ErrorText <> '' then
            Error(ErrorText);
    end;

    local procedure ConvertItemType(MigrationQBItemType: Text): Option
    begin
        case MigrationQBItemType of
            'Inventory':
                exit(ItemType::Inventory);
            'Service', 'NonInventory':
                exit(ItemType::Service);
            else
                exit(ItemType::Service);
        end;
    end;

    procedure GetAll(IsOnline: Boolean)
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        JArray: JsonArray;
        Success: Boolean;
    begin
        DeleteAll();

        if IsOnline then
            Success := HelperFunctions.GetEntities('Select * from Item', 'Item', JArray)
        else
            Success := HelperFunctions.GetEntities('Item', JArray);

        if Success then
            GetItemsFromJson(JArray);
    end;

    procedure PopulateStagingTable(JArray: JsonArray)
    begin
        GetItemsFromJson(JArray);
    end;

    procedure DeleteAll()
    var
        MigrationQBItem: Record "MigrationQB Item";
    begin
        MigrationQBItem.DeleteAll();
    end;

    local procedure GetItemsFromJson(JArray: JsonArray)
    var
        MigrationQBItem: Record "MigrationQB Item";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[15];
        i: Integer;
    begin
        i := 0;

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id')), 1, 15);

            if not MigrationQBItem.Get(EntityId) then begin
                MigrationQBItem.Init();
                MigrationQBItem.VALIDATE(MigrationQBItem.Id, EntityId);
                MigrationQBItem.Insert(true);
            end;

            RecordVariant := MigrationQBItem;
            UpdateItemFromJson(RecordVariant, ChildJToken);
            MigrationQBItem := RecordVariant;
            MigrationQBItem.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateItemFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationQBItem: Record "MigrationQB Item";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBItem.FieldNO(Name), JToken.AsObject(), 'Name');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBItem.FieldNO(Description), JToken.AsObject(), 'Description');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBItem.FieldNO(Type), JToken.AsObject(), 'Type');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBItem.FieldNO(Taxable), JToken.AsObject(), 'Taxable');

        if HelperFunctions.IsOnlineData() then begin
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBItem.FieldNO(UnitPrice), JToken.AsObject(), 'UnitPrice');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBItem.FieldNO(PurchaseCost), JToken.AsObject(), 'PurchaseCost');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBItem.FieldNO(QtyOnHand), JToken.AsObject(), 'QtyOnHand');
        end else begin
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBItem.FieldNO(OrType), JToken.AsObject(), 'ORSalesPurchase.Ortype');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBItem.FieldNO(QtyOnHand), JToken.AsObject(), 'QuantityOnHand');
            if (IsItemServiceType(RecordVariant)) then begin
                HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBItem.FieldNO(UnitPrice), JToken.AsObject(), GetSearchPath(RecordVariant, true));
                HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBItem.FieldNO(PurchaseCost), JToken.AsObject(), GetSearchPath(RecordVariant, false));
            end else begin
                HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBItem.FieldNO(UnitPrice), JToken.AsObject(), 'SalesPrice');
                HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBItem.FieldNO(PurchaseCost), JToken.AsObject(), 'UnitPrice');
            end;
        end;
    end;

    local procedure GetCostingMethod(var MigrationQBItem: Record "MigrationQB Item"): Option
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if ConvertItemType(MigrationQBItem.Type) = ItemType::Service then
            exit(CostingMethod::FIFO);

        if InventorySetup.Get() then
            exit(InventorySetup."Default Costing Method")
        else
            exit(CostingMethod::FIFO);
    end;

    local procedure GetUnitOfMeasure(): Code[10]
    var
        MigrationQBAccountSetup: Record "MigrationQB Account Setup";
    begin
        if MigrationQBAccountSetup.FindFirst() then
            exit(CopyStr(MigrationQBAccountSetup.UnitOfMeasure, 1, 10))
        else
            exit('');
    end;

    local procedure IsItemServiceType(MigrationQBItem: Record "MigrationQB Item"): Boolean
    begin
        if MigrationQBItem.Type = 'Service' then
            exit(true);
        exit(false);
    end;

    local procedure GetSearchPath(MigrationQBItem: Record "MigrationQB Item"; FindSalesPrice: Boolean): Text
    begin
        case MigrationQBItem.OrType of
            true:
                if FindSalesPrice then
                    exit('ORSalesPurchase.SalesAndPurchase.SalesPrice')
                else
                    exit('ORSalesPurchase.SalesAndPurchase.UnitPrice');
            false:
                if FindSalesPrice then
                    exit('ORSalesPurchase.SalesOrPurchase.ORPrice.Price')
                else
                    exit('ORSalesPurchase.SalesOrPurchase.ORPrice.UnitPrice');
        end;
    end;
}