codeunit 4019 "GP Item Migrator"
{
    TableNo = "GP Item";

    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        DefaultPostingGroupCodeTxt: Label 'GP', Locked = true;
        DefaultPostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;
        InventoryAccountTok: Label 'InventoryAccount', Locked = true;
        DefaultAccountNumber: Text[20];
        ItemTypeOption: Option Inventory,Service;
        CostingMethodOption: Option FIFO,LIFO,Specific,Average,Standard;
        SimpleInvJnlNameTxt: Label 'DEFAULT', Comment = 'The default name of the item journal', Locked = true;
        LastEntryNo: Integer;

#pragma warning disable AA0207
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateItem', '', true, true)]
    procedure OnMigrateItem(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPItem: Record "GP Item";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Item" then
            exit;

        if not GPItem.Get(RecordIdToMigrate) then
            exit;

        if not ShouldMigrateItem(GPItem) then begin
            DecrementMigratedCount();
            exit;
        end;

        MigrateItemDetails(GPItem, Sender);
    end;

#pragma warning restore AA0207
    local procedure ShouldMigrateItem(var GPItem: Record "GP Item"): Boolean
    var
        GPIV00101: Record "GP IV00101";
    begin
        if GPIV00101.Get(GPItem.No) then begin
            if GPIV00101.INACTIVE then
                if not GPCompanyAdditionalSettings.GetMigrateInactiveItems() then
                    exit(false);

            if GPIV00101.IsDiscontinued() then
                if not GPCompanyAdditionalSettings.GetMigrateDiscontinuedItems() then
                    exit(false);
        end;

        exit(true);
    end;

    local procedure DecrementMigratedCount()
    var
        HelperFunctions: Codeunit "Helper Functions";
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
    begin
        DataMigrationStatusFacade.IncrementMigratedRecordCount(HelperFunctions.GetMigrationTypeTxt(), Database::Item, -1);
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
        ItemDataMigrationFacade.SetGeneralProductPostingGroup(CopyStr(DefaultPostingGroupCodeTxt, 1, 20));
        ItemDataMigrationFacade.SetNetWeight(GPItem.ShipWeight);
        ItemDataMigrationFacade.SetSearchDescription(GPItem.SearchDescription);
        ItemDataMigrationFacade.SetPurchUnitOfMeasure(GPItem.PurchUnitOfMeasure);
        ItemDataMigrationFacade.SetItemTrackingCode(GPItem.ItemTrackingCode);
        ItemDataMigrationFacade.ModifyItem(true);
    end;

#pragma warning disable AA0207
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateItemPostingGroups', '', true, true)]
    procedure OnMigrateItemPostingGroups(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        GPItem: Record "GP Item";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Item" then
            exit;

        if GPItem.Get(RecordIdToMigrate) then
            MigrateItemInventoryPostingGroup(GPItem, Sender);
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

        if GPCompanyAdditionalSettings.GetMigrateOnlyInventoryMaster() then
            exit;

        if GPItem.Get(RecordIdToMigrate) then begin
            if not Sender.DoesItemExist(CopyStr(GPItem.No, 1, MaxStrLen(Item."No."))) then
                exit;

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
#pragma warning restore AA0207

    procedure MigrateItemInventoryPostingGroup(GPItem: Record "GP Item"; var Sender: Codeunit "Item Data Migration Facade")
    var
        Item: Record Item;
        GPIV00101: Record "GP IV00101";
        ItemClassId: Text[11];
    begin
        if not Sender.DoesItemExist(CopyStr(GPItem.No, 1, MaxStrLen(Item."No."))) then
            exit;

        MigrateItemClassesIfNeeded(GPItem, Sender);

        if GPItem.ItemType = 0 then begin
            if GPCompanyAdditionalSettings.GetMigrateItemClasses() then
                if GPIV00101.Get(GPItem.No) then
#pragma warning disable AA0139
                    ItemClassId := GPIV00101.ITMCLSCD.Trim();
#pragma warning restore AA0139

            if (ItemClassId <> '') then
                Sender.SetInventoryPostingGroup(ItemClassId)
            else
                Sender.SetInventoryPostingGroup(CopyStr(DefaultPostingGroupCodeTxt, 1, 20));

            Sender.ModifyItem(true);
        end;
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

#if not CLEAN21
    [Obsolete('Method is not supported, it was using files', '21.0')]
    procedure GetAll()
    begin
    end;
#endif
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

    procedure MigrateItemClassesIfNeeded(var GPItem: Record "GP Item"; var ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    var
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if DefaultAccountNumber = '' then
            DefaultAccountNumber := HelperFunctions.GetPostingAccountNumber(InventoryAccountTok);

        MigrateDefaultPostingGroupIfNeeded(ItemDataMigrationFacade);
        MigrateGPPostingGroupIfNeeded(GPItem, ItemDataMigrationFacade);
    end;

    local procedure MigrateDefaultPostingGroupIfNeeded(var ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
        InventoryPostingSetup: Record "Inventory Posting Setup";
        GPItemLocation: Record "GP Item Location";
        PostingGroupCode: Code[20];
    begin
        PostingGroupCode := CopyStr(DefaultPostingGroupCodeTxt, 1, MaxStrLen(PostingGroupCode));
        if not InventoryPostingGroup.Get(PostingGroupCode) then begin
#pragma warning disable AA0139
            ItemDataMigrationFacade.CreateInventoryPostingSetupIfNeeded(PostingGroupCode, CopyStr(DefaultPostingGroupDescriptionTxt, 1, MaxStrLen(InventoryPostingGroup.Description)), '');
#pragma warning restore AA0139                 
            ItemDataMigrationFacade.SetInventoryPostingSetupInventoryAccount(PostingGroupCode, '', DefaultAccountNumber);

            if GPItemLocation.FindSet() then
                repeat
#pragma warning disable AA0139                
                    ItemDataMigrationFacade.CreateInventoryPostingSetupIfNeeded(PostingGroupCode, CopyStr(DefaultPostingGroupDescriptionTxt, 1, MaxStrLen(InventoryPostingGroup.Description)), CopyStr(GPItemLocation.LOCNCODE, 1, MaxStrLen(InventoryPostingSetup."Location Code")));
#pragma warning restore AA0139                       
                    ItemDataMigrationFacade.SetInventoryPostingSetupInventoryAccount(PostingGroupCode, CopyStr(GPItemLocation.LOCNCODE, 1, MaxStrLen(InventoryPostingSetup."Location Code")), DefaultAccountNumber);
                until GPItemLocation.Next() = 0;
        end;
    end;

    local procedure MigrateGPPostingGroupIfNeeded(var GPItem: Record "GP Item"; var ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
        InventoryPostingSetup: Record "Inventory Posting Setup";
        GPIV00101: Record "GP IV00101";
        GPIV40400: Record "GP IV40400";
        GPItemLocation: Record "GP Item Location";
        HelperFunctions: Codeunit "Helper Functions";
        PostingGroupCode: Code[20];
        AccountNumber: Code[20];
    begin
        if not GPCompanyAdditionalSettings.GetMigrateItemClasses() then
            exit;

        if GPIV40400.IsEmpty() then
            exit;

        if not GPIV00101.Get(GPItem.No) then
            exit;

#pragma warning disable AA0139
        PostingGroupCode := GPIV00101.ITMCLSCD.Trim();
#pragma warning restore AA0139

        if PostingGroupCode = '' then
            exit;

        if InventoryPostingGroup.Get(PostingGroupCode) then
            exit;

        if not GPIV40400.Get(PostingGroupCode) then
            exit;

        AccountNumber := DefaultAccountNumber;

        if GPIV40400.IVIVINDX > 0 then
            AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPIV40400.IVIVINDX);

        ItemDataMigrationFacade.CreateInventoryPostingSetupIfNeeded(PostingGroupCode, GPIV40400.ITMCLSDC, '');
        ItemDataMigrationFacade.SetInventoryPostingSetupInventoryAccount(PostingGroupCode, '', AccountNumber);

        if GPItemLocation.FindSet() then
            repeat
                ItemDataMigrationFacade.CreateInventoryPostingSetupIfNeeded(PostingGroupCode, GPIV40400.ITMCLSDC, CopyStr(GPItemLocation.LOCNCODE, 1, MaxStrLen(InventoryPostingSetup."Location Code")));
                ItemDataMigrationFacade.SetInventoryPostingSetupInventoryAccount(PostingGroupCode, CopyStr(GPItemLocation.LOCNCODE, 1, MaxStrLen(InventoryPostingSetup."Location Code")), AccountNumber);
            until GPItemLocation.Next() = 0;
    end;
}