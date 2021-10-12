codeunit 4019 "GP Item Migrator"
{
    TableNo = "GP Item";

    var
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;
        ItemTypeOption: Option Inventory,Service;
        CostingMethodOption: Option FIFO,LIFO,Specific,Average,Standard;
        SimpleInvJnlNameTxt: Label 'DEFAULT', Comment = 'The default name of the item journal', Locked = true;
        LastEntryNo: Integer;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateItem', '', true, true)]
    procedure OnMigrateItem(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPItem: Record "GP Item";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Item" then
            exit;
        GPItem.Get(RecordIdToMigrate);
        MigrateItemDetails(GPItem, Sender);
    end;

    procedure MigrateItemDetails(GPItem: Record "GP Item"; ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    begin
        if not ItemDataMigrationFacade.CreateItemIfNeeded(CopyStr(GPItem.No, 1, 20), GPItem.Description, GPItem.ShortName, ConvertItemType(GPItem.ItemType)) then
            exit;
        ItemDataMigrationFacade.CreateUnitOfMeasureIfNeeded(GPItem.BaseUnitOfMeasure, GPItem.BaseUnitOfMeasure);
        ItemDataMigrationFacade.CreateUnitOfMeasureIfNeeded(GPItem.PurchUnitOfMeasure, GPItem.PurchUnitOfMeasure);

        ItemDataMigrationFacade.SetUnitListPrice(GPItem.UnitListPrice);
        ItemDataMigrationFacade.SetUnitCost(GPItem.CurrentCost);
        ItemDataMigrationFacade.SetStandardCost(GPItem.StandardCost);
        ItemDataMigrationFacade.SetCostingMethod(GetCostingMethod(GPItem));
        ItemDataMigrationFacade.SetBaseUnitOfMeasure(GPItem.BaseUnitOfMeasure);
        ItemDataMigrationFacade.SetGeneralProductPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 20));
        ItemDataMigrationFacade.SetNetWeight(GPItem.ShipWeight);
        ItemDataMigrationFacade.SetSearchDescription(GPItem.SearchDescription);
        ItemDataMigrationFacade.SetPurchUnitOfMeasure(GPItem.PurchUnitOfMeasure);
        ItemDataMigrationFacade.SetItemTrackingCode(GPItem.ItemTrackingCode);
        ItemDataMigrationFacade.ModifyItem(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateItemPostingGroups', '', true, true)]
    procedure OnMigrateItemPostingGroups(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        GPItem: Record "GP Item";
        GPItemLocation: Record "GP Item Location";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Item" then
            exit;

        Sender.CreateInventoryPostingSetupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 20), CopyStr(PostingGroupDescriptionTxt, 1, 50), '');
        Sender.SetInventoryPostingSetupInventoryAccount(CopyStr(PostingGroupCodeTxt, 1, 20), '', HelperFunctions.GetPostingAccountNumber('InventoryAccount'));
        if GPItemLocation.FindSet() then
            repeat
                Sender.CreateInventoryPostingSetupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 20), CopyStr(PostingGroupDescriptionTxt, 1, 50), CopyStr(GPItemLocation.LOCNCODE, 1, 10));
                Sender.SetInventoryPostingSetupInventoryAccount(CopyStr(PostingGroupCodeTxt, 1, 20), CopyStr(GPItemLocation.LOCNCODE, 1, 10), HelperFunctions.GetPostingAccountNumber('InventoryAccount'));
            until GPItemLocation.Next() = 0;

        if GPItem.Get(RecordIdToMigrate) then
            if GPItem.ItemType = 0 then
                Sender.SetInventoryPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 20));

        Sender.ModifyItem(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateInventoryTransactions', '', true, true)]
    procedure OnMigrateInventoryTransactions(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        Item: Record Item;
        ItemJnlLine: Record "Item Journal Line";
        GPItem: Record "GP Item";
        GPItemTransaction: Record "GP Item Transactions";
        AdjustItemInventory: Codeunit "Adjust Item Inventory";
        GPItemTransactionAverageQuery: Query "GP Item Transaction Average";
        GPItemTransactionStandardQuery: Query "GP Item Transaction Standard";
        GPItemTransactionQuery: Query "GP Item Transaction";
        ErrorText: Text;
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Item" then
            exit;

        if GPItem.Get(RecordIdToMigrate) then begin
            if GPItem.ItemType = 0 then
                case GetCostingMethod(GPItem) of
                    CostingMethodOption::Average:
                        begin
                            // Average : Group by Loc, CurrCost
                            GPItemTransactionAverageQuery.SetRange(No, GPItem.No);
                            GPItemTransactionAverageQuery.Open();
                            while GPItemTransactionAverageQuery.Read() do begin
                                // 1 transaction for each grouping w/ Sum of all Quantities using CurrCost
                                // Date can just be today's date
                                GPItemTransaction.SetRange(No, GPItemTransactionAverageQuery.No);
                                GPItemTransaction.SetRange(Location, GPItemTransactionAverageQuery.Location);
                                GPItemTransaction.SetRange(CurrentCost, GPItemTransactionAverageQuery.CurrentCost);
                                if GPItemTransaction.FindSet() then begin
                                    CreateItemJnlLine(ItemJnlLine, GPItem, GPItemTransaction, GPItemTransactionAverageQuery.Quantity, WorkDate());
                                    repeat
                                        CreateNewItemTrackingLinesIfNecessary(GPItemTransaction, GPItem, ItemJnlLine);
                                    until GPItemTransaction.Next() = 0;
                                    AdjustItemInventory.PostItemJnlLines(ItemJnlLine);
                                end;
                            end;
                        end;
                    CostingMethodOption::Standard:
                        begin
                            // Standard : Group by Loc, Standard
                            GPItemTransactionStandardQuery.SetRange(No, GPItem.No);
                            GPItemTransactionStandardQuery.Open();
                            while GPItemTransactionStandardQuery.Read() do begin
                                // 1 transaction for each grouping w/ Sum of all Quantities using Standard
                                // Date can just be today's date
                                GPItemTransaction.SetRange(No, GPItemTransactionStandardQuery.No);
                                GPItemTransaction.SetRange(Location, GPItemTransactionStandardQuery.Location);
                                GPItemTransaction.SetRange(StandardCost, GPItemTransactionStandardQuery.StandardCost);
                                if GPItemTransaction.FindSet() then begin
                                    CreateItemJnlLine(ItemJnlLine, GPItem, GPItemTransaction, GPItemTransactionStandardQuery.Quantity, WorkDate());
                                    repeat
                                        CreateNewItemTrackingLinesIfNecessary(GPItemTransaction, GPItem, ItemJnlLine);
                                    until GPItemTransaction.Next() = 0;
                                    AdjustItemInventory.PostItemJnlLines(ItemJnlLine);
                                end;
                            end;
                        end;
                    else
                        // LIFO/FIFO : 1 transaction for each record using Unit Cost
                        case GPItem.ItemTrackingCode of
                            '':
                                begin
                                    // 1 transaction for each record using Unit Cost
                                    GPItemTransaction.SetRange(No, GPItem.No);
                                    if GPItemTransaction.FindSet() then
                                        repeat
                                            CreateItemJnlLine(ItemJnlLine, GPItem, GPItemTransaction, GPItemTransaction.Quantity, GPItemTransaction.DateReceived);
                                            AdjustItemInventory.PostItemJnlLines(ItemJnlLine);
                                        until GPItemTransaction.Next() = 0;
                                end;
                            else begin
                                    GPItemTransactionQuery.SetRange(No, GPItem.No);
                                    GPItemTransactionQuery.Open();
                                    while GPItemTransactionQuery.Read() do begin
                                        // 1 transaction for each grouping using Unit Cost
                                        GPItemTransaction.SetRange(No, GPItemTransactionQuery.No);
                                        GPItemTransaction.SetRange(Location, GPItemTransactionQuery.Location);
                                        GPItemTransaction.SetRange(ReceiptNumber, GPItemTransactionQuery.ReceiptNumber);
                                        GPItemTransaction.SetRange(UnitCost, GPItemTransactionQuery.UnitCost);
                                        if GPItemTransaction.FindSet() then begin
                                            CreateItemJnlLine(ItemJnlLine, GPItem, GPItemTransaction, GPItemTransactionQuery.Quantity, GPItemTransaction.DateReceived);
                                            repeat
                                                CreateNewItemTrackingLinesIfNecessary(GPItemTransaction, GPItem, ItemJnlLine);
                                            until GPItemTransaction.Next() = 0;
                                            AdjustItemInventory.PostItemJnlLines(ItemJnlLine);
                                        end;
                                    end;
                                end;
                        end;
                end;

            if GPItem.InActive then begin
                Item.Reset();
                if Item.Get(GPItem.No) then begin
                    Item.Blocked := true;
                    Item.Modify(true);
                end;
            end;
        end;

        if ErrorText <> '' then
            Error(ErrorText);
    end;

    local procedure CreateItemBatch(TemplateName: Code[10]): Code[10]
    var
        ItemJnlBatch: Record "Item Journal Batch";
    begin
        ItemJnlBatch.Init();
        ItemJnlBatch."Journal Template Name" := TemplateName;
        ItemJnlBatch.Name := CreateBatchName();
        ItemJnlBatch.Description := SimpleInvJnlNameTxt;
        ItemJnlBatch.Insert();

        exit(ItemJnlBatch.Name);
    end;

    local procedure CreateBatchName(): Code[10]
    var
        BatchName: Text;
    begin
        BatchName := Format(CreateGuid());
        exit(CopyStr(BatchName, 2, 10));
    end;

    local procedure CreateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; GPItem: Record "GP Item"; GPItemTransaction: Record "GP Item Transactions"; Quantity: Decimal; PostingDate: Date)
    var
        AdjustItemInventory: Codeunit "Adjust Item Inventory";
        ItemTemplate: Code[10];
    begin
        ItemTemplate := AdjustItemInventory.SelectItemTemplateForAdjustment();

        ItemJnlLine.Init();
        ItemJnlLine.Validate("Journal Template Name", ItemTemplate);
        ItemJnlLine.Validate("Journal Batch Name", CreateItemBatch(ItemTemplate));
        ItemJnlLine.Validate("Posting Date", PostingDate);
        ItemJnlLine."Document No." := CopyStr(GPItem.No, 1, 20);

        if GPItemTransaction.Quantity > 0 then
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
        else
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");

        ItemJnlLine.Validate("Item No.", GPItem.No);
        ItemJnlLine.Validate(Description, GPItem.Description);
        ItemJnlLine.Validate(Quantity, Quantity);
        ItemJnlLine.Validate("Location Code", GPItemTransaction.Location);

        case GetCostingMethod(GPItem) of
            CostingMethodOption::Average:
                ItemJnlLine.Validate("Unit Cost", GPItemTransaction.CurrentCost);
            CostingMethodOption::Standard:
                ItemJnlLine.Validate("Unit Cost", GPItemTransaction.StandardCost);
            else
                ItemJnlLine.Validate("Unit Cost", GPItemTransaction.UnitCost);
        end;

        ItemJnlLine.Insert(true);
    end;

    local procedure CreateNewItemTrackingLinesIfNecessary(GPItemTransactions: Record "GP Item Transactions"; GPItem: Record "GP Item"; ItemJnlLine: Record "Item Journal Line")
    var
        ReservationEntry: Record "Reservation Entry";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        CreateReserveEntry: Codeunit "Create Reserv. Entry";
        ExpirationDate: Date;
    begin
        if GPItem.ItemTrackingCode = '' then
            exit;

        TempTrackingSpecification.InitFromItemJnlLine(ItemJnlLine);

        if GPItemTransactions.ExpirationDate = DMY2Date(1, 1, 1900) then
            ExpirationDate := 0D
        else
            ExpirationDate := GPItemTransactions.ExpirationDate;

        TempTrackingSpecification."Serial No." := GPItemTransactions.SerialNumber;
        TempTrackingSpecification."Lot No." := GPItemTransactions.LotNumber;
        TempTrackingSpecification."Warranty Date" := 0D;
        TempTrackingSpecification."Expiration Date" := ExpirationDate;

        LastEntryNo += 1;
        TempTrackingSpecification."Entry No." := LastEntryNo;
        TempTrackingSpecification."Creation Date" := ItemJnlLine."Posting Date";

        case GPItem.ItemTrackingCode of
            'LOT':
                TempTrackingSpecification.Validate("Quantity (Base)", GPItemTransactions.Quantity);
            'SERIAL':
                TempTrackingSpecification.Validate("Quantity (Base)", 1);
        end;

        TempTrackingSpecification.Insert(true);

        ReservationEntry.Init();
        ReservationEntry.CopyTrackingFromSpec(TempTrackingSpecification);
        CreateReserveEntry.CreateReservEntryFor(
            DATABASE::"Item Journal Line",
            ItemJnlLine."Entry Type".AsInteger(), ItemJnlLine."Journal Template Name",
            ItemJnlLine."Journal Batch Name", 0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure",
            TempTrackingSpecification."Quantity (Base)", TempTrackingSpecification."Quantity (Base)", ReservationEntry);
        CreateReserveEntry.CreateEntry(
          ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
          GPItem.Description, ItemJnlLine."Posting Date", ItemJnlLine."Posting Date", 0, ReservationEntry."Reservation Status"::Prospect);
    end;

    local procedure ConvertItemType(GPItemType: Integer): Option
    begin
        if GPItemType = 0 then
            exit(ItemTypeOption::Inventory);

        exit(ItemTypeOption::Service);
    end;

    procedure GetAll()
    var
        HelperFunctions: Codeunit "Helper Functions";
        JArray: JsonArray;
    begin
        HelperFunctions.GetEntities('Item', JArray);
        GetItemsFromJson(JArray);
    end;

    local procedure GetItemsFromJson(JArray: JsonArray)
    var
        GPItem: Record "GP Item";
        HelperFunctions: Codeunit "Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[75];
        i: Integer;
    begin
        i := 0;
        GPItem.Reset();
        GPItem.DeleteAll();

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.GetTextFromJToken(ChildJToken, 'ITEMNMBR'), 1, MAXSTRLEN(GPItem.No));
            EntityId := CopyStr(HelperFunctions.TrimBackslash(EntityId), 1, 75);
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(EntityId), 1, 75);
            if strlen(EntityId) > 20 then
                EntityId := CopyStr(EntityId, 1, 20);

            if not GPItem.Get(EntityId) then begin
                GPItem.Init();
                GPItem.Validate(GPItem.No, EntityId);
                GPItem.Insert(true);
            end;

            RecordVariant := GPItem;
            UpdateItemFromJson(RecordVariant, ChildJToken);
            GPItem := RecordVariant;
            GPItem.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateItemFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        GPItem: Record "GP Item";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(Description), JToken.AsObject(), 'SEARCHDESC');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(SearchDescription), JToken.AsObject(), 'SEARCHDESC');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(ShortName), JToken.AsObject(), 'ITMSHNAM');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(BaseUnitOfMeasure), JToken.AsObject(), 'BASEUOFM');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(ItemType), JToken.AsObject(), 'ITEMTYPE');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(CostingMethod), JToken.AsObject(), 'COSTINGMETHOD');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(CurrentCost), JToken.AsObject(), 'CURRCOST');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(StandardCost), JToken.AsObject(), 'STNDCOST');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(UnitListPrice), JToken.AsObject(), 'UNITLISTPRICE');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(ShipWeight), JToken.AsObject(), 'ITEMSHWT');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(InActive), JToken.AsObject(), 'INACTIVE');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(QuantityOnHand), JToken.AsObject(), 'QTYONHND');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(SalesUnitOfMeasure), JToken.AsObject(), 'SELNGUOM');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPItem.FieldNo(PurchUnitOfMeasure), JToken.AsObject(), 'PRCHSUOM');
    end;

    local procedure GetCostingMethod(var GPItem: Record "GP Item"): Option
    begin
        if ConvertItemType(GPItem.ItemType) = ItemTypeOption::Service then
            exit(CostingMethodOption::FIFO);

        case GPItem.CostingMethod of
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