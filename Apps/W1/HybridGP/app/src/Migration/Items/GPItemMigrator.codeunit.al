namespace Microsoft.DataMigration.GP;

using System.Integration;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.BOM;

codeunit 4019 "GP Item Migrator"
{
    TableNo = "GP Item";

    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        DefaultPostingGroupCodeTxt: Label 'GP', Locked = true;
        DefaultPostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;
        InventoryAccountTok: Label 'InventoryAccount', Locked = true;
        ItemTypeOption: Option Inventory,Service;
        CostingMethodOption: Option FIFO,LIFO,Specific,Average,Standard;
        SimpleInvJnlNameTxt: Label 'DEFAULT', Comment = 'The default name of the item journal', Locked = true;
        LastEntryNo: Integer;
        ItemBatchCodePrefixTxt: Label 'GPITM', Locked = true;
        CurrentBatchNumber: Integer;
        CurrentBatchLineNo: Integer;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateItem', '', true, true)]
    local procedure OnMigrateItem(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId)
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Item" then
            exit;

        MigrateItemImp(Sender, RecordIdToMigrate);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateItemPostingGroups', '', true, true)]
    local procedure OnMigrateItemPostingGroups(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Item" then
            exit;

        MigrateItemPostingGroupsImp(Sender, RecordIdToMigrate, ChartOfAccountsMigrated);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", 'OnMigrateInventoryTransactions', '', true, true)]
    local procedure OnMigrateInventoryTransactions(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Item" then
            exit;

        MigrateInventoryTransactionsImp(Sender, RecordIdToMigrate, ChartOfAccountsMigrated);
    end;

    internal procedure MigrateItemImp(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPItem: Record "GP Item";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));
        if not GPItem.Get(RecordIdToMigrate) then
            exit;

        if not HelperFunctions.ShouldMigrateItem(GPItem.No) then begin
            DecrementMigratedCount();
            exit;
        end;

        MigrateItemDetailsImp(GPItem, Sender);
    end;

    internal procedure MigrateItemPostingGroupsImp(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        GPItem: Record "GP Item";
        ItemNo: Code[20];
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        if not GPItem.Get(RecordIdToMigrate) then
            exit;

        ItemNo := CopyStr(GPItem.No, 1, MaxStrLen(ItemNo));
        if not Sender.DoesItemExist(ItemNo) then
            exit;

        CreateDefaultInventoryPostingGroup(Sender);
        MigrateItemInventoryPostingGroupImp(GPItem, Sender);
        MigrateItemGeneralPostingGroupImp(GPItem, Sender);

        Sender.ModifyItem(true);
    end;

    local procedure DecrementMigratedCount()
    var
        HelperFunctions: Codeunit "Helper Functions";
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
    begin
        DataMigrationStatusFacade.IncrementMigratedRecordCount(HelperFunctions.GetMigrationTypeTxt(), Database::Item, -1);
    end;

    local procedure MigrateItemDetailsImp(var GPItem: Record "GP Item"; ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    var
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if not ItemDataMigrationFacade.CreateItemIfNeeded(CopyStr(GPItem.No, 1, 20), GPItem.Description, GPItem.ShortName, ConvertItemType(GPItem.ItemType)) then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPItem.RecordId));
        ItemDataMigrationFacade.CreateUnitOfMeasureIfNeeded(GPItem.BaseUnitOfMeasure, GPItem.BaseUnitOfMeasure);
        ItemDataMigrationFacade.CreateUnitOfMeasureIfNeeded(GPItem.PurchUnitOfMeasure, GPItem.PurchUnitOfMeasure);
        ItemDataMigrationFacade.SetUnitListPrice(GPItem.UnitListPrice);
        ItemDataMigrationFacade.SetUnitCost(GPItem.CurrentCost);
        ItemDataMigrationFacade.SetStandardCost(GPItem.StandardCost);
        ItemDataMigrationFacade.SetCostingMethod(GetCostingMethod(GPItem));
        ItemDataMigrationFacade.SetBaseUnitOfMeasure(GPItem.BaseUnitOfMeasure);
        ItemDataMigrationFacade.SetNetWeight(GPItem.ShipWeight);
        ItemDataMigrationFacade.SetSearchDescription(GPItem.SearchDescription);
        ItemDataMigrationFacade.SetPurchUnitOfMeasure(GPItem.PurchUnitOfMeasure);
        ItemDataMigrationFacade.SetItemTrackingCode(GPItem.ItemTrackingCode);

        if GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            ItemDataMigrationFacade.SetGeneralProductPostingGroup(CopyStr(DefaultPostingGroupCodeTxt, 1, 20));

        ItemDataMigrationFacade.ModifyItem(true);
    end;

    internal procedure MigrateInventoryTransactionsImp(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        Item: Record Item;
        ItemJnlLine: Record "Item Journal Line";
        GPItem: Record "GP Item";
        GPItemTransaction: Record "GP Item Transactions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        GPItemTransactionAverageQuery: Query "GP Item Transaction Average";
        GPItemTransactionStandardQuery: Query "GP Item Transaction Standard";
        GPItemTransactionQuery: Query "GP Item Transaction";
        ErrorText: Text;
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
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
                                    end;
                                end;
                            end;
                        end;
                end;

            DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPItem.RecordId));
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

    local procedure MigrateItemInventoryPostingGroupImp(var GPItem: Record "GP Item"; var Sender: Codeunit "Item Data Migration Facade")
    var
        GPIV00101: Record "GP IV00101";
        ItemClassId: Code[20];
    begin
        if not GPItem.ShouldSetPostingGroup() then
            exit;

        CreateInventoryPostingGroup(GPItem, Sender);

        if GPCompanyAdditionalSettings.GetMigrateItemClasses() then
            if GPIV00101.Get(GPItem.No) then
                ItemClassId := CopyStr(GPIV00101.ITMCLSCD.Trim(), 1, MaxStrLen(ItemClassId));

        if (ItemClassId <> '') then
            Sender.SetInventoryPostingGroup(ItemClassId)
        else
            Sender.SetInventoryPostingGroup(CopyStr(DefaultPostingGroupCodeTxt, 1, MaxStrLen(ItemClassId)));
    end;

    local procedure MigrateItemGeneralPostingGroupImp(var GPItem: Record "GP Item"; var Sender: Codeunit "Item Data Migration Facade")
    var
        GPIV00101: Record "GP IV00101";
        ItemClassId: Code[20];
    begin
        CreateGenProductPostingGroup(GPItem, Sender);

        if GPCompanyAdditionalSettings.GetMigrateItemClasses() then
            if GPIV00101.Get(GPItem.No) then
                ItemClassId := CopyStr(GPIV00101.ITMCLSCD.TrimEnd(), 1, MaxStrLen(ItemClassId));

        if (ItemClassId <> '') then
            Sender.SetGeneralProductPostingGroup(ItemClassId)
        else
            Sender.SetGeneralProductPostingGroup(CopyStr(DefaultPostingGroupCodeTxt, 1, MaxStrLen(ItemClassId)));
    end;

    local procedure GetCurrentBatchState()
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        CurrentBatchNumber := ItemJournalBatch.Count();

        if ItemJournalBatch.FindLast() then begin
            ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);

            CurrentBatchLineNo := ItemJournalLine.Count();
        end;
    end;

    local procedure CreateOrGetItemBatch(TemplateName: Code[10]): Code[10]
    var
        ItemJnlBatch: Record "Item Journal Batch";
        BatchName: Code[10];
    begin
        if CurrentBatchNumber = 0 then
            CurrentBatchNumber := 1;

        if CurrentBatchLineNo >= GetMaxBatchLineCount() then begin
            CurrentBatchNumber := CurrentBatchNumber + 1;
            CurrentBatchLineNo := 0;
        end;

        BatchName := CopyStr(ItemBatchCodePrefixTxt + Format(CurrentBatchNumber), 1, 10);
        if not ItemJnlBatch.Get(TemplateName, BatchName) then begin
            Clear(ItemJnlBatch);
            ItemJnlBatch."Journal Template Name" := TemplateName;
            ItemJnlBatch.Name := BatchName;
            ItemJnlBatch.Description := SimpleInvJnlNameTxt;
            ItemJnlBatch.Insert();
        end;

        exit(BatchName);
    end;

    local procedure CreateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; GPItem: Record "GP Item"; GPItemTransaction: Record "GP Item Transactions"; Quantity: Decimal; PostingDate: Date)
    var
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        AdjustItemInventory: Codeunit "Adjust Item Inventory";
        ItemTemplate: Code[10];
    begin
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPItemTransaction.RecordId));

        if GPItemTransaction.Quantity = 0 then
            exit;

        GetCurrentBatchState();

        ItemTemplate := AdjustItemInventory.SelectItemTemplateForAdjustment();

        Clear(ItemJnlLine);
        ItemJnlLine.Validate("Journal Template Name", ItemTemplate);
        ItemJnlLine.Validate("Journal Batch Name", CreateOrGetItemBatch(ItemTemplate));
        ItemJnlLine.Validate("Posting Date", PostingDate);
        ItemJnlLine."Document No." := CopyStr(GPItem.No, 1, 20);

        CurrentBatchLineNo := CurrentBatchLineNo + 1;
        ItemJnlLine."Line No." := CurrentBatchLineNo;

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
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        CreateReserveEntry: Codeunit "Create Reserv. Entry";
#if CLEAN25
        ItemJnlLineReserve: Codeunit "Item Jnl. Line-Reserve";
#endif
        ExpirationDate: Date;
    begin
        if GPItem.ItemTrackingCode = '' then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPItemTransactions.RecordId));
#if not CLEAN25
#pragma warning disable AL0432
        TempTrackingSpecification.InitFromItemJnlLine(ItemJnlLine);
#pragma warning restore AL0432
#else
        ItemJnlLineReserve.InitFromItemJnlLine(TempTrackingSpecification, ItemJnlLine);
#endif
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
        if (GPItemType in [0, 2]) then
            exit(ItemTypeOption::Inventory);

        exit(ItemTypeOption::Service);
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

    local procedure CreateDefaultInventoryPostingGroup(var ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
        InventoryPostingSetup: Record "Inventory Posting Setup";
        GPItemLocation: Record "GP Item Location";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        HelperFunctions: Codeunit "Helper Functions";
        PostingGroupCode: Code[20];
        PostingGroupDescription: Text[50];
        DefaultAccountNumber: Code[20];
    begin
        if InventoryPostingGroup.Get(DefaultPostingGroupCodeTxt) then
            exit;

        PostingGroupCode := CopyStr(DefaultPostingGroupCodeTxt, 1, MaxStrLen(PostingGroupCode));
        DefaultAccountNumber := HelperFunctions.GetPostingAccountNumber(InventoryAccountTok);
        PostingGroupDescription := CopyStr(DefaultPostingGroupDescriptionTxt, 1, MaxStrLen(PostingGroupDescription));

        ItemDataMigrationFacade.CreateInventoryPostingSetupIfNeeded(PostingGroupCode, PostingGroupDescription, '');
        ItemDataMigrationFacade.SetInventoryPostingSetupInventoryAccount(PostingGroupCode, '', DefaultAccountNumber);

        if not GPItemLocation.FindSet() then
            exit;

        repeat
            DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPItemLocation.RecordId));
            ItemDataMigrationFacade.CreateInventoryPostingSetupIfNeeded(PostingGroupCode, PostingGroupDescription, CopyStr(GPItemLocation.LOCNCODE, 1, MaxStrLen(InventoryPostingSetup."Location Code")));
            ItemDataMigrationFacade.SetInventoryPostingSetupInventoryAccount(PostingGroupCode, CopyStr(GPItemLocation.LOCNCODE, 1, MaxStrLen(InventoryPostingSetup."Location Code")), DefaultAccountNumber);
        until GPItemLocation.Next() = 0;
    end;

    local procedure CreateInventoryPostingGroup(var GPItem: Record "GP Item"; var ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
        InventoryPostingSetup: Record "Inventory Posting Setup";
        GPIV00101: Record "GP IV00101";
        GPIV40400: Record "GP IV40400";
        GPItemLocation: Record "GP Item Location";
        HelperFunctions: Codeunit "Helper Functions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PostingGroupCode: Code[20];
        PostingGroupDescription: Text[50];
        AccountNumber: Code[20];
    begin
        if not GPCompanyAdditionalSettings.GetMigrateItemClasses() then
            exit;

        if GPIV40400.IsEmpty() then
            exit;

        if not GPIV00101.Get(GPItem.No) then
            exit;

        PostingGroupCode := CopyStr(GPIV00101.ITMCLSCD.TrimEnd(), 1, MaxStrLen(PostingGroupCode));
        if PostingGroupCode = '' then
            exit;

        if InventoryPostingGroup.Get(PostingGroupCode) then
            exit;

        if not GPIV40400.Get(PostingGroupCode) then
            exit;

        AccountNumber := HelperFunctions.GetPostingAccountNumber(InventoryAccountTok);

        if GPIV40400.IVIVINDX > 0 then
            AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPIV40400.IVIVINDX);

        PostingGroupDescription := CopyStr(GPIV40400.ITMCLSDC.TrimEnd(), 1, MaxStrLen(PostingGroupDescription));

        ItemDataMigrationFacade.CreateInventoryPostingSetupIfNeeded(PostingGroupCode, PostingGroupDescription, '');
        ItemDataMigrationFacade.SetInventoryPostingSetupInventoryAccount(PostingGroupCode, '', AccountNumber);

        if GPItemLocation.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPItemLocation.RecordId));
                ItemDataMigrationFacade.CreateInventoryPostingSetupIfNeeded(PostingGroupCode, PostingGroupDescription, CopyStr(GPItemLocation.LOCNCODE.TrimEnd(), 1, MaxStrLen(InventoryPostingSetup."Location Code")));
                ItemDataMigrationFacade.SetInventoryPostingSetupInventoryAccount(PostingGroupCode, CopyStr(GPItemLocation.LOCNCODE.TrimEnd(), 1, MaxStrLen(InventoryPostingSetup."Location Code")), AccountNumber);
            until GPItemLocation.Next() = 0;
    end;

    local procedure CreateGenProductPostingGroup(var GPItem: Record "GP Item"; var ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GPIV00101: Record "GP IV00101";
        GPIV40400: Record "GP IV40400";
        PostingGroupCode: Code[20];
        PostingGroupDescription: Text[50];
    begin
        if not GPCompanyAdditionalSettings.GetMigrateItemClasses() then
            exit;

        if not GPIV00101.Get(GPItem.No) then
            exit;

        PostingGroupCode := CopyStr(GPIV00101.ITMCLSCD.TrimEnd(), 1, MaxStrLen(PostingGroupCode));
        if PostingGroupCode = '' then
            exit;

        if not GPIV40400.Get(PostingGroupCode) then
            exit;

        PostingGroupDescription := CopyStr(GPIV40400.ITMCLSDC.TrimEnd(), 1, MaxStrLen(PostingGroupDescription));

        if GenProductPostingGroup.Get(PostingGroupCode) then
            exit;

        // Create two versions of the General Posting Setup. One with GP as the Gen. Bus. Posting Group and the other as blank
        CreateGeneralPostingSetup(ItemDataMigrationFacade, GPIV40400, PostingGroupCode, PostingGroupDescription, '');
        CreateGeneralPostingSetup(ItemDataMigrationFacade, GPIV40400, PostingGroupCode, PostingGroupDescription, 'GP');
    end;

    local procedure CreateGeneralPostingSetup(var ItemDataMigrationFacade: Codeunit "Item Data Migration Facade"; var GPIV40400: Record "GP IV40400"; PostingGroupCode: Code[20]; GeneralProdPostingGroupDescription: Text[50]; GeneralBusPostingGroupCode: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        AccountNumber: Code[20];
    begin
        if ItemDataMigrationFacade.CreateGeneralProductPostingSetupIfNeeded(PostingGroupCode, GeneralProdPostingGroupDescription, GeneralBusPostingGroupCode) then
            if GeneralPostingSetup.Get(GeneralBusPostingGroupCode, PostingGroupCode) then begin
                if CanAddGenProductPostingAccount(GPIV40400.IVSLSIDX, AccountNumber, '') then
                    GeneralPostingSetup.Validate("Sales Account", AccountNumber);

                if CanAddGenProductPostingAccount(GPIV40400.IVSLDSIX, AccountNumber, '') then
                    GeneralPostingSetup.Validate("Sales Line Disc. Account", AccountNumber);

                if CanAddGenProductPostingAccount(GPIV40400.IVIVINDX, AccountNumber, '') then
                    GeneralPostingSetup.Validate("Purch. Account", AccountNumber);

                if CanAddGenProductPostingAccount(GPIV40400.IVCOGSIX, AccountNumber, '') then
                    GeneralPostingSetup.Validate("COGS Account", AccountNumber);

                if CanAddGenProductPostingAccount(GPIV40400.IVIVINDX, AccountNumber, '') then
                    GeneralPostingSetup.Validate("Direct Cost Applied Account", AccountNumber);

                if CanAddGenProductPostingAccount(GPIV40400.PURPVIDX, AccountNumber, '') then
                    GeneralPostingSetup.Validate("Purchase Variance Account", AccountNumber);

                ApplyGenPostingSetupCommonAccounts(GeneralPostingSetup);

                GeneralPostingSetup.Modify(true);
            end;
    end;

    local procedure ApplyGenPostingSetupCommonAccounts(var GeneralPostingSetup: Record "General Posting Setup")
    var
        GPPostingAccounts: Record "GP Posting Accounts";
        HelperFunctions: Codeunit "Helper Functions";
        AccountNumber: Code[20];
        DefaultAccountNumber: Code[20];
    begin
        if GPPostingAccounts.FindFirst() then begin
            DefaultAccountNumber := HelperFunctions.GetPostingAccountNumber(InventoryAccountTok);

            if CanAddGenProductPostingAccount(GPPostingAccounts.InventoryAdjmtAccountIdx, AccountNumber, DefaultAccountNumber) then
                GeneralPostingSetup.Validate("Inventory Adjmt. Account", AccountNumber);

            if CanAddGenProductPostingAccount(GPPostingAccounts.SalesInvDiscAccountIdx, AccountNumber, '') then
                GeneralPostingSetup.Validate("Sales Inv. Disc. Account", AccountNumber);

            if CanAddGenProductPostingAccount(GPPostingAccounts.SalesPmtDiscDebitAccountIdx, AccountNumber, '') then begin
                EnsureGLSetupAdjustforPaymentDiscTrue();
                GeneralPostingSetup.Validate("Sales Pmt. Disc. Debit Acc.", AccountNumber);
            end;

            if CanAddGenProductPostingAccount(GPPostingAccounts.PurchPmtDiscDebitAccIdx, AccountNumber, '') then begin
                EnsureGLSetupAdjustforPaymentDiscTrue();
                GeneralPostingSetup.Validate("Purch. Pmt. Disc. Debit Acc.", AccountNumber);
            end;
        end;
    end;

    local procedure EnsureGLSetupAdjustforPaymentDiscTrue()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not GLSetup.Get() then
            exit;

        if GLSetup."Adjust for Payment Disc." then
            exit;

        GLSetup.Validate("VAT Tolerance %", 0);
        GLSetup.Validate("Pmt. Disc. Excl. VAT", false);
        GLSetup.Validate("Adjust for Payment Disc.", true);
        GLSetup.Modify(true);
    end;

    local procedure CanAddGenProductPostingAccount(GPAccountIdx: Integer; var AccountNumber: Code[20]; DefaultAccountNo: Code[20]): Boolean
    var
        GLAccount: Record "G/L Account";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        AccountNumber := DefaultAccountNo;

        if GPAccountIdx < 1 then
            exit;

        if (GLAccount.Get(HelperFunctions.GetGPAccountNumberByIndex(GPAccountIdx))) then
            AccountNumber := GLAccount."No.";

        exit(AccountNumber <> '');
    end;

    internal procedure MigrateKitItems()
    var
        GPItem: Record "GP Item";
    begin
        GPItem.SetRange(ItemType, 2);
        if GPItem.FindSet() then
            repeat
                MigrateKitComponents(GPItem);
            until GPItem.Next() = 0;
    end;

    local procedure MigrateKitComponents(var GPItem: Record "GP Item")
    var
        ParentItem: Record Item;
        GPIV00104: Record "GP IV00104";
        LineNo: Integer;
    begin
        if not ParentItem.Get(GPItem.No) then
            exit;

        // Kit items must be of type Inventory
        if ParentItem.Type <> ParentItem.Type::Inventory then begin
            ParentItem.Validate(Type, ParentItem.Type::Inventory);
            ParentItem.Modify();
        end;

        LineNo := 0;
        GPIV00104.SetRange(ITEMNMBR, ParentItem."No.");
        GPIV00104.SetCurrentKey(SEQNUMBR);
        GPIV00104.SetAscending(SEQNUMBR, true);
        if GPIV00104.FindSet() then
            repeat
                CreateBOMComponent(GPIV00104, ParentItem, LineNo);
            until GPIV00104.Next() = 0;
    end;

    local procedure CreateBOMComponent(var GPIV00104: Record "GP IV00104"; var ParentItem: Record Item; var LineNo: Integer)
    var
        ComponentItem: Record Item;
        BOMComponent: Record "BOM Component";
        ComponentItemNo: Code[20];
    begin
        ComponentItemNo := CopyStr(GPIV00104.CMPTITNM.TrimEnd(), 1, MaxStrLen(ComponentItemNo));
        if ComponentItemNo = ParentItem."No." then
            exit;

        if not ComponentItem.Get(ComponentItemNo) then
            exit;

        // Kit component items must be either Inventory or Non-Inventory
        if ComponentItem.Type = ComponentItem.Type::Service then begin
            ComponentItem.Validate(Type, ComponentItem.Type::"Non-Inventory");
            ComponentItem.Modify();
        end;

        LineNo += 10000;

        BOMComponent.SetRange("Parent Item No.", ParentItem."No.");
        BOMComponent.SetRange("No.", ComponentItem."No.");
        if BOMComponent.IsEmpty() then begin
            Clear(BOMComponent);
            BOMComponent.Validate(Type, BOMComponent.Type::Item);
            BOMComponent.Validate("Parent Item No.", ParentItem."No.");
            BOMComponent.Validate("Line No.", LineNo);
            BOMComponent.Validate("No.", ComponentItem."No.");
            BOMComponent.Validate("Quantity per", GPIV00104.CMPITQTY);
            BOMComponent.Insert(true);
        end;
    end;

    internal procedure CreateItemCategories()
    var
        Item: Record Item;
    begin
        if not Item.FindSet() then
            exit;

        repeat
            CreateItemCategoryImp(Item);
        until Item.Next() = 0;
    end;

    internal procedure CreateItemCategoryImp(var Item: Record Item)
    var
        ItemCategory: Record "Item Category";
        GPIV00101: Record "GP IV00101";
        GPIV40400: Record "GP IV40400";
        ItemClass: Code[20];
    begin
        if not GPIV00101.Get(Item."No.") then
            exit;

        ItemClass := CopyStr(GPIV00101.ITMCLSCD.TrimEnd(), 1, MaxStrLen(ItemClass));
        if ItemClass = '' then
            exit;

        if not GPIV40400.Get(ItemClass) then
            exit;

        if not ItemCategory.Get(ItemClass) then begin
            ItemCategory.Validate(Code, ItemClass);
            ItemCategory.Validate(Description, CopyStr(GPIV40400.ITMCLSDC.TrimEnd(), 1, MaxStrLen(ItemCategory.Description)));
            ItemCategory.Insert(true);
        end;

        Item.Validate("Item Category Code", ItemClass);
        Item.Modify(true);
    end;

    local procedure GetMaxBatchLineCount(): Integer
    var
        IsHandled: Boolean;
        MaxLineCount: Integer;
        NewMaxLineCount: Integer;
    begin
        MaxLineCount := 10000;

        OnBeforeGetMaxItemBatchLineCount(IsHandled, NewMaxLineCount);
        if IsHandled then
            if NewMaxLineCount > 0 then
                MaxLineCount := NewMaxLineCount;

        exit(MaxLineCount);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetMaxItemBatchLineCount(var IsHandled: Boolean; var NewMaxLineCount: Integer)
    begin
    end;

#if not CLEAN28
    [Obsolete('Should not call this procedure directly.', '28.0')]
    procedure MigrateItem(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId)
    begin
    end;

    [Obsolete('Should not call this procedure directly.', '28.0')]
    procedure MigrateItemDetails(var GPItem: Record "GP Item"; ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    begin
    end;

    [Obsolete('Should not call this procedure directly.', '28.0')]
    procedure MigrateItemPostingGroups(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    begin
    end;

    [Obsolete('Should not call this procedure directly.', '28.0')]
    procedure MigrateInventoryTransactions(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    begin
    end;

    [Obsolete('Should not call this procedure directly.', '28.0')]
    procedure MigrateItemInventoryPostingGroup(GPItem: Record "GP Item"; var Sender: Codeunit "Item Data Migration Facade")
    begin
    end;

    [Obsolete('Should not call this procedure directly.', '28.0')]
    procedure MigrateItemClassesIfNeeded(var GPItem: Record "GP Item"; var ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    begin
    end;
#endif
}