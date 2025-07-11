// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Tracking;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 47026 "SL Item Migrator"
{
    Access = Internal;

    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        CurrentBatchNumber: Integer;
        CurrentBatchLineNo: Integer;
        DefaultPostingGroupCodeTxt: Label 'SL', Locked = true;
        DefaultPostingGroupDescriptionTxt: Label 'Migrated from SL', Locked = true;
        SLItemImportPostingGroupCodeTxt: Label 'SLITEMIMPORT', Locked = true;
        SLItemImportPostingGroupDescriptionTxt: Label 'SL Item Import (No impact to GL)', Locked = true;
        SimpleInvJnlNameTxt: Label 'DEFAULT', Comment = 'The default name of the item journal', Locked = true;
        TranStatusCodeInactiveTxt: Label 'IN', Locked = true;
        TranStatusCodeDeleteTxt: Label 'DE', Locked = true;
        ItemBatchCodePrefixTxt: Label 'SLITM', Locked = true;
        CostingMethodOption: Option FIFO,LIFO,Specific,Average,Standard;
        ItemTypeOption: Option Inventory,Service;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", OnMigrateItem, '', true, true)]
    local procedure OnMigrateItem(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId)
    begin
        MigrateItem(Sender, RecordIdToMigrate);
    end;

    internal procedure MigrateItem(var Sender: Codeunit "Item Data Migration Facade"; RecordToMigrate: RecordId)
    var
        SLInventory: Record "SL Inventory";
        SLINSetup: Record "SL INSetup";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if RecordToMigrate.TableNo() <> Database::"SL Inventory" then
            exit;
        SLCompanyAdditionalSettings.Get(CompanyName);
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetInventoryModuleEnabled() then
            exit;
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordToMigrate));
        if not SLInventory.Get(RecordToMigrate) then
            exit;
        if not ShouldMigrateItem(SLInventory) then begin
            DecrementMigratedCount();
            exit;
        end;

        SLINSetup.Get('IN');
        MigrateItemDetails(SLInventory, Sender);
        SetGeneralPostingSetupForInventory(SLINSetup);
    end;

    internal procedure ShouldMigrateItem(var SLInventory: Record "SL Inventory"): Boolean
    begin
        if SLInventory.TranStatusCode = TranStatusCodeInactiveTxt then
            if not SLCompanyAdditionalSettings.GetMigrateInactiveItems() then
                exit(false);
        if SLInventory.TranStatusCode = TranStatusCodeDeleteTxt then
            if not SLCompanyAdditionalSettings.GetMigrateDiscontinuedItems() then
                exit(false);
        exit(true);
    end;

    internal procedure DecrementMigratedCount()
    var
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigrationStatusFacade: Codeunit "Data Migration Status Facade";
    begin
        DataMigrationStatusFacade.IncrementMigratedRecordCount(SLHelperFunctions.GetMigrationTypeTxt(), Database::Item, -1);
    end;

    internal procedure MigrateItemDetails(SLInventory: Record "SL Inventory"; ItemDataMigrationFacade: Codeunit "Item Data Migration Facade")
    var
        SLInventoryADG: Record "SL InventoryADG";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if not ItemDataMigrationFacade.CreateItemIfNeeded(CopyStr(SLInventory.InvtID, 1, 20), CopyStr(SLInventory.Descr, 1, 50), CopyStr(SLInventory.Descr, 1, 50), ItemTypeOption::Inventory) then
            exit;
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLInventory.RecordId));
        ItemDataMigrationFacade.CreateUnitOfMeasureIfNeeded(SLInventory.StkUnit, SLInventory.StkUnit);
        ItemDataMigrationFacade.CreateUnitOfMeasureIfNeeded(SLInventory.DfltPOUnit, SLInventory.DfltPOUnit);
        ItemDataMigrationFacade.SetUnitPrice(SLInventory.StkBasePrc);
        if SLInventory.ValMthd <> 'T' then
            ItemDataMigrationFacade.SetUnitCost(SLInventory.LastCost)
        else
            ItemDataMigrationFacade.SetUnitCost(SLInventory.StdCost);
        if SLInventory.ValMthd = 'T' then
            ItemDataMigrationFacade.SetStandardCost(SLInventory.StdCost)
        else
            ItemDataMigrationFacade.SetStandardCost(SLInventory.LastCost);
        ItemDataMigrationFacade.SetCostingMethod(GetCostingMethod(SLInventory));
        ItemDataMigrationFacade.SetBaseUnitOfMeasure(SLInventory.StkUnit);
        ItemDataMigrationFacade.SetPurchUnitOfMeasure(SLInventory.DfltPOUnit);
        ItemDataMigrationFacade.SetSearchDescription(CopyStr(SLInventory.Descr, 1, 50));
        ItemDataMigrationFacade.SetItemTrackingCode(GetSLBCTrackingCode(SLInventory));

        if SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            ItemDataMigrationFacade.SetGeneralProductPostingGroup(DefaultPostingGroupCodeTxt);
        if SLInventoryADG.Get(SLInventory.InvtID) then
            ItemDataMigrationFacade.SetNetWeight(SLInventoryADG.StdGrossWt);

        ItemDataMigrationFacade.ModifyItem(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", OnMigrateItemPostingGroups, '', true, true)]
    local procedure OnMigrateItemPostingGroups(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartofAccountsMigrated: Boolean)
    begin
        MigrateItemPostingGroups(Sender, RecordIdToMigrate, ChartofAccountsMigrated);
    end;

    internal procedure MigrateItemPostingGroups(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartofAccountsMigrated: Boolean)
    var
        SLInventory: Record "SL Inventory";
    begin
        if not ChartofAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"SL Inventory" then
            exit;

        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        if SLInventory.Get(RecordIdToMigrate) then
            MigrateItemInventoryPostingGroup(SLInventory, Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Data Migration Facade", OnMigrateInventoryTransactions, '', true, true)]
    local procedure OnMigrateInventoryTransactions(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    begin
        MigrateInventoryTransactions(Sender, RecordIdToMigrate, ChartOfAccountsMigrated);
    end;

    internal procedure MigrateInventoryTransactions(var Sender: Codeunit "Item Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        Item: Record Item;
        ItemJnlLine: Record "Item Journal Line";
        SLItemCost: Record "SL ItemCost";
        SLItemSite: Record "SL ItemSite";
        SLInventory: Record "SL Inventory";
        SLLotSerMst: Record "SL LotSerMst";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        ErrorText: Text;
    begin
        if not ChartOfAccountsMigrated then
            exit;
        if RecordIdToMigrate.TableNo <> Database::"SL Inventory" then
            exit;
        SLCompanyAdditionalSettings.Get(CompanyName);
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetInventoryModuleEnabled() then
            exit;
        if SLCompanyAdditionalSettings.GetMigrateOnlyInventoryMaster() then
            exit;
        if SLInventory.Get(RecordIdToMigrate) then begin
            if not Sender.DoesItemExist(CopyStr(SLInventory.InvtID, 1, MaxStrLen(Item."No."))) then
                exit;
            if not ShouldMigrateItem(SLInventory) then
                exit;

            case SLInventory.ValMthd of
                'A', 'T', 'U':  // Average, Standard, User-Specified
                    begin
                        SLItemSite.SetRange(InvtID, SLInventory.InvtID);
                        SLItemSite.SetFilter(CpnyID, CompanyName);
                        SLItemSite.SetFilter(QtyOnHand, '<>%1', 0);
                        if SLItemSite.FindSet() then
                            repeat
                                CreateItemJnlLine(ItemJnlLine, SLInventory, SLItemSite, SLItemSite.QtyOnHand, WorkDate());
                                CreateItemTrackingLinesIfNecessary(SLItemSite, SLInventory, ItemJnlLine, '', '');
                            until SLItemSite.Next() = 0;
                    end;

                'F', 'L', 'S':  // FIFO, LIFO, Specific
                    begin
                        SLItemSite.SetRange(InvtID, SLInventory.InvtID);
                        SLItemSite.SetFilter(CpnyID, CompanyName);
                        SLItemSite.SetFilter(QtyOnHand, '<>%1', 0);
                        if SLItemSite.FindSet() then
                            repeat
                                if (SLInventory.LotSerTrack in ['LI', 'SI']) then begin
                                    SLLotSerMst.SetRange(InvtID, SLItemSite.InvtID);
                                    SLLotSerMst.SetRange(SiteID, SLItemSite.SiteID);
                                    SLLotSerMst.SetFilter(QtyOnHand, '<>%1', 0);
                                    if SLLotSerMst.FindSet() then
                                        repeat
                                            CreateItemJnlLineLotSerMst(ItemJnlLine, SLInventory, SLLotSerMst, SLLotSerMst.QtyOnHand, DT2Date(SLLotSerMst.RcptDate));
                                            CreateItemTrackingLinesIfNecessary(SLItemSite, SLInventory, ItemJnlLine, SLLotSerMst.LotSerNbr, SLLotSerMst.WhseLoc);
                                        until SLLotSerMst.Next() = 0;
                                end
                                else begin
                                    SLItemCost.SetRange(InvtID, SLItemSite.InvtID);
                                    SLItemCost.SetRange(SiteID, SLItemSite.SiteID);
                                    SLItemCost.SetFilter(Qty, '<>%1', 0);
                                    if SLItemCost.FindSet() then
                                        repeat
                                            CreateItemJnlLineItemCost(ItemJnlLine, SLInventory, SLItemCost, SLItemCost.Qty, DT2Date(SLItemCost.RcptDate));
                                            if ((SLInventory.LotSerTrack = 'NN') and (SLInventory.ValMthd = 'S')) then
                                                CreateItemTrackingLinesSpecificID(SLItemCost, SLInventory, ItemJnlLine);
                                        until SLItemCost.Next() = 0;
                                end;
                            until SLItemSite.Next() = 0;
                    end;
            end;

            DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLInventory.RecordId));
            if (SLInventory.TranStatusCode = TranStatusCodeInactiveTxt) or (SLInventory.TranStatusCode = TranStatusCodeDeleteTxt) then begin
                Item.Reset();
                if Item.Get(CopyStr(SLInventory.InvtID, 1, MaxStrLen(Item."No."))) then begin
                    Item.Blocked := true;
                    Item.Modify(true);
                end;
            end;
        end;

        if ErrorText <> '' then
            Error(ErrorText);
    end;

    internal procedure GetCurrentBatchState()
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

    internal procedure CreateOrGetItemBatch(TemplateName: Code[10]): Code[10]
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

    internal procedure CreateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; SLInventory: Record "SL Inventory"; SLItemSite: Record "SL ItemSite"; Quantity: Decimal; PostingDate: Date)
    var
        AdustItemInventory: Codeunit "Adjust Item Inventory";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        ItemTemplate: Code[10];
    begin
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLItemSite.RecordId));

        if SLItemSite.QtyOnHand = 0 then
            exit;

        GetCurrentBatchState();
        ItemTemplate := AdustItemInventory.SelectItemTemplateForAdjustment();
        Clear(ItemJnlLine);

        ItemJnlLine.Validate("Journal Template Name", ItemTemplate);
        ItemJnlLine.Validate("Journal Batch Name", CreateOrGetItemBatch(ItemTemplate));
        ItemJnlLine.Validate("Posting Date", PostingDate);
        ItemJnlLine."Document No." := CopyStr(SLInventory.InvtID, 1, MaxStrLen(ItemJnlLine."Document No."));

        CurrentBatchLineNo := CurrentBatchLineNo + 1;
        ItemJnlLine."Line No." := CurrentBatchLineNo;

        if SLItemSite.QtyOnHand > 0 then
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
        else
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");

        ItemJnlLine.Validate("Item No.", CopyStr(SLInventory.InvtID, 1, MaxStrLen(ItemJnlLine."Item No.")));
        ItemJnlLine.Validate(Description, SLInventory.Descr);
        ItemJnlLine.Validate(Quantity, Quantity);
        ItemJnlLine.Validate("Location Code", SLItemSite.SiteID);

        case GetCostingMethod(SLInventory) of
            CostingMethodOption::Average:
                ItemJnlLine.Validate("Unit Cost", SLItemSite.AvgCost);
            CostingMethodOption::Standard:
                ItemJnlLine.Validate("Unit Cost", SLItemSite.StdCost);
        end;

        ItemJnlLine.Validate("Gen. Prod. Posting Group", SLItemImportPostingGroupCodeTxt);

        ItemJnlLine.Insert(true);
    end;

    internal procedure CreateItemJnlLineItemCost(var ItemJnlLine: Record "Item Journal Line"; SLInventory: Record "SL Inventory"; SLItemCost: Record "SL ItemCost"; Quantity: Decimal; PostingDate: Date)
    var
        AdustItemInventory: Codeunit "Adjust Item Inventory";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        ItemTemplate: Code[10];
    begin
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLItemCost.RecordId));

        if SLItemCost.Qty = 0 then
            exit;

        GetCurrentBatchState();
        ItemTemplate := AdustItemInventory.SelectItemTemplateForAdjustment();
        Clear(ItemJnlLine);

        ItemJnlLine.Validate("Journal Template Name", ItemTemplate);
        ItemJnlLine.Validate("Journal Batch Name", CreateOrGetItemBatch(ItemTemplate));
        ItemJnlLine.Validate("Posting Date", PostingDate);
        if SLInventory.ValMthd = 'S' then begin
            ItemJnlLine.Validate("Posting Date", DT2Date(SLItemCost.Crtd_DateTime));
            ItemJnlLine."Document No." := CopyStr(SLItemCost.SpecificCostID, 1, MaxStrLen(ItemJnlLine."Document No."));
        end
        else begin
            ItemJnlLine.Validate("Posting Date", PostingDate);
            ItemJnlLine."Document No." := SLItemCost.RcptNbr;
        end;
        CurrentBatchLineNo := CurrentBatchLineNo + 1;
        ItemJnlLine."Line No." := CurrentBatchLineNo;
        if SLItemCost.Qty > 0 then
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
        else
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
        ItemJnlLine.Validate("Item No.", CopyStr(SLItemCost.InvtID, 1, MaxStrLen(ItemJnlLine."Item No.")));
        ItemJnlLine.Validate(Description, SLInventory.Descr);
        ItemJnlLine.Validate(Quantity, Quantity);
        ItemJnlLine.Validate("Location Code", SLItemCost.SiteID);
        ItemJnlLine.Validate("Unit Cost", SLItemCost.UnitCost);
        ItemJnlLine.Validate("Gen. Prod. Posting Group", SLItemImportPostingGroupCodeTxt);

        ItemJnlLine.Insert(true);
    end;

    internal procedure CreateItemJnlLineLotSerMst(var ItemJnlLine: Record "Item Journal Line"; SLInventory: Record "SL Inventory"; SLLotSerMst: Record "SL LotSerMst"; Quantity: Decimal; PostingDate: Date)
    var
        AdustItemInventory: Codeunit "Adjust Item Inventory";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        ItemTemplate: Code[10];
    begin
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLLotSerMst.RecordId));

        if SLLotSerMst.QtyOnHand = 0 then
            exit;

        GetCurrentBatchState();
        ItemTemplate := AdustItemInventory.SelectItemTemplateForAdjustment();
        Clear(ItemJnlLine);

        ItemJnlLine.Validate("Journal Template Name", ItemTemplate);
        ItemJnlLine.Validate("Journal Batch Name", CreateOrGetItemBatch(ItemTemplate));
        ItemJnlLine.Validate("Posting Date", PostingDate);
        ItemJnlLine."Document No." := SLLotSerMst.SrcOrdNbr;
        CurrentBatchLineNo := CurrentBatchLineNo + 1;
        ItemJnlLine."Line No." := CurrentBatchLineNo;
        if SLLotSerMst.QtyOnHand > 0 then
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
        else
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
        ItemJnlLine.Validate("Item No.", CopyStr(SLLotSerMst.InvtID, 1, 20));
        ItemJnlLine.Validate(Description, SLInventory.Descr);
        ItemJnlLine.Validate(Quantity, Quantity);
        ItemJnlLine.Validate("Location Code", SLLotSerMst.SiteID);
        ItemJnlLine.Validate("Unit Cost", SLLotSerMst.Cost);
        ItemJnlLine.Validate("Gen. Prod. Posting Group", SLItemImportPostingGroupCodeTxt);
        ItemJnlLine.Insert(true);
    end;

    internal procedure CreateItemTrackingLinesIfNecessary(SLItemSite: Record "SL ItemSite"; SLInventory: Record "SL Inventory"; ItemJnlLine: Record "Item Journal Line";
    LotSerNbr: Text[25]; WhseLoc: Text[10])
    var
        ReservationEntry: Record "Reservation Entry";
        SLLotSerMst: Record "SL LotSerMst";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemJrlLineReserve: Codeunit "Item Jnl. Line-Reserve";
        ReservationStatus: Enum "Reservation Status";
        LastEntryNo: Integer;
        SLLotSerialCode: Code[10];
    begin
        if (SLInventory.LotSerTrack.TrimEnd() = '') or ((SLInventory.LotSerTrack = 'NN') and (SLInventory.ValMthd <> 'S')) then
            exit;
        SLLotSerialCode := GetSLBCTrackingCode(SLInventory);
        if (SLLotSerialCode = 'LOTUSED') or (SLLotSerialCode = 'SERUSED') or (SLLotSerialCode = '') then
            exit;

        SLLotSerMst.SetRange(InvtID, SLItemSite.InvtID);
        if LotSerNbr.TrimEnd() <> '' then
            SLLotSerMst.SetRange(LotSerNbr, LotSerNbr);
        SLLotSerMst.SetRange(SiteID, SLItemSite.SiteID);
        if WhseLoc.TrimEnd() <> '' then
            SLLotSerMst.SetRange(WhseLoc, WhseLoc);
        SLLotSerMst.SetFilter(QtyOnHand, '<>%1', 0);
        if SLLotSerMst.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLItemSite.RecordId));

                ItemJrlLineReserve.InitFromItemJnlLine(TempTrackingSpecification, ItemJnlLine);

                case SLLotSerialCode of
                    // Lot-tracked, when received into Inventory
                    'LOTRCVD':
                        begin
                            TempTrackingSpecification."Lot No." := SLLotSerMst.LotSerNbr;
                            TempTrackingSpecification."Warranty Date" := 0D;
                            TempTrackingSpecification."Expiration Date" := 0D;

                            LastEntryNo += 1;
                            TempTrackingSpecification."Entry No." := LastEntryNo;
                            TempTrackingSpecification."Creation Date" := ItemJnlLine."Posting Date";

                            TempTrackingSpecification.Validate("Quantity (Base)", SLLotSerMst.QtyOnHand);

                            TempTrackingSpecification.Insert(true);

                            ReservationEntry.Init();
                            ReservationEntry.CopyTrackingFromSpec(TempTrackingSpecification);
                            CreateReservEntry.CreateReservEntryFor(
                                Database::"Item Journal Line",
                                ItemJnlLine."Entry Type".AsInteger(), ItemJnlLine."Journal Template Name",
                                ItemJnlLine."Journal Batch Name", 0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure",
                                TempTrackingSpecification."Quantity (Base)", TempTrackingSpecification."Quantity (Base)", ReservationEntry);

                            CreateReservEntry.CreateEntry(
                                ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
                                SLInventory.Descr, ItemJnlLine."Posting Date", ItemJnlLine."Posting Date", 0, ReservationStatus::Prospect);
                        end;

                    // Lot-tracked, when received into Inventory with expiration date
                    'LOTRCVDEXP':
                        begin
                            TempTrackingSpecification."Lot No." := SLLotSerMst.LotSerNbr;
                            TempTrackingSpecification."Warranty Date" := 0D;
                            if DT2Date(SLLotSerMst.ExpDate) = DMY2Date(1, 1, 1900) then
                                TempTrackingSpecification."Expiration Date" := 0D
                            else
                                TempTrackingSpecification."Expiration Date" := DT2Date(SLLotSerMst.ExpDate);

                            LastEntryNo += 1;
                            TempTrackingSpecification."Entry No." := LastEntryNo;
                            TempTrackingSpecification."Creation Date" := ItemJnlLine."Posting Date";

                            TempTrackingSpecification.Validate("Quantity (Base)", SLLotSerMst.QtyOnHand);

                            TempTrackingSpecification.Insert(true);

                            ReservationEntry.Init();
                            ReservationEntry.CopyTrackingFromSpec(TempTrackingSpecification);
                            CreateReservEntry.CreateReservEntryFor(
                                Database::"Item Journal Line",
                                ItemJnlLine."Entry Type".AsInteger(), ItemJnlLine."Journal Template Name",
                                ItemJnlLine."Journal Batch Name", 0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure",
                                TempTrackingSpecification."Quantity (Base)", TempTrackingSpecification."Quantity (Base)", ReservationEntry);

                            CreateReservEntry.SetDates(TempTrackingSpecification."Warranty Date", TempTrackingSpecification."Expiration Date");

                            CreateReservEntry.CreateEntry(
                                ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
                                SLInventory.Descr, ItemJnlLine."Posting Date", ItemJnlLine."Posting Date", 0, ReservationStatus::Prospect);
                        end;

                    // Serial-tracked, when received into Inventory
                    'SERRCVD':
                        begin
                            TempTrackingSpecification."Serial No." := SLLotSerMst.LotSerNbr;
                            TempTrackingSpecification."Warranty Date" := 0D;
                            TempTrackingSpecification."Expiration Date" := 0D;

                            LastEntryNo += 1;
                            TempTrackingSpecification."Entry No." := LastEntryNo;
                            TempTrackingSpecification."Creation Date" := ItemJnlLine."Posting Date";

                            TempTrackingSpecification.Validate("Quantity (Base)", 1);

                            TempTrackingSpecification.Insert(true);

                            ReservationEntry.Init();
                            ReservationEntry.CopyTrackingFromSpec(TempTrackingSpecification);
                            CreateReservEntry.CreateReservEntryFor(
                                Database::"Item Journal Line",
                                ItemJnlLine."Entry Type".AsInteger(), ItemJnlLine."Journal Template Name",
                                ItemJnlLine."Journal Batch Name", 0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure",
                                TempTrackingSpecification."Quantity (Base)", TempTrackingSpecification."Quantity (Base)", ReservationEntry);

                            CreateReservEntry.CreateEntry(
                                ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
                                SLInventory.Descr, ItemJnlLine."Posting Date", ItemJnlLine."Posting Date", 0, ReservationStatus::Prospect);
                        end;

                    // Serial-tracked, when received into Inventory with expiration date
                    'SERRCVDEXP':
                        begin
                            TempTrackingSpecification."Serial No." := SLLotSerMst.LotSerNbr;
                            TempTrackingSpecification."Warranty Date" := 0D;
                            if DT2Date(SLLotSerMst.ExpDate) = DMY2Date(1, 1, 1900) then
                                TempTrackingSpecification."Expiration Date" := 0D
                            else
                                TempTrackingSpecification."Expiration Date" := DT2Date(SLLotSerMst.ExpDate);

                            LastEntryNo += 1;
                            TempTrackingSpecification."Entry No." := LastEntryNo;
                            TempTrackingSpecification."Creation Date" := ItemJnlLine."Posting Date";

                            TempTrackingSpecification.Validate("Quantity (Base)", 1);

                            TempTrackingSpecification.Insert(true);

                            ReservationEntry.Init();
                            ReservationEntry.CopyTrackingFromSpec(TempTrackingSpecification);
                            CreateReservEntry.CreateReservEntryFor(
                                Database::"Item Journal Line",
                                ItemJnlLine."Entry Type".AsInteger(), ItemJnlLine."Journal Template Name",
                                ItemJnlLine."Journal Batch Name", 0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure",
                                TempTrackingSpecification."Quantity (Base)", TempTrackingSpecification."Quantity (Base)", ReservationEntry);

                            CreateReservEntry.SetDates(TempTrackingSpecification."Warranty Date", TempTrackingSpecification."Expiration Date");

                            CreateReservEntry.CreateEntry(
                                ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
                                SLInventory.Descr, ItemJnlLine."Posting Date", ItemJnlLine."Posting Date", 0, ReservationStatus::Prospect);
                        end;
                end;
            until SLLotSerMst.Next() = 0;
    end;

    internal procedure CreateItemTrackingLinesSpecificID(SLItemCost: Record "SL ItemCost"; SLInventory: Record "SL Inventory"; ItemJnlLine: Record "Item Journal Line")
    var
        ReservationEntry: Record "Reservation Entry";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemJrlLineReserve: Codeunit "Item Jnl. Line-Reserve";
        ReservationStatus: Enum "Reservation Status";
        LastEntryNo: Integer;
        SLLotSerialCode: Text[10];
    begin
        if SLInventory.ValMthd <> 'S' then
            exit;
        if SLInventory.LotSerTrack <> 'NN' then
            exit;
        SLLotSerialCode := GetSLBCTrackingCode(SLInventory);
        if SLLotSerialCode.TrimEnd() <> 'LOTRCVD' then
            exit;
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLItemCost.RecordId));

        ItemJrlLineReserve.InitFromItemJnlLine(TempTrackingSpecification, ItemJnlLine);

        TempTrackingSpecification."Lot No." := SLItemCost.SpecificCostID;
        TempTrackingSpecification."Warranty Date" := 0D;
        TempTrackingSpecification."Expiration Date" := 0D;
        LastEntryNo += 1;
        TempTrackingSpecification."Entry No." := LastEntryNo;
        TempTrackingSpecification."Creation Date" := ItemJnlLine."Posting Date";
        TempTrackingSpecification.Validate("Quantity (Base)", SLItemCost.Qty);

        TempTrackingSpecification.Insert(true);

        ReservationEntry.Init();
        ReservationEntry.CopyTrackingFromSpec(TempTrackingSpecification);
        CreateReservEntry.CreateReservEntryFor(
            Database::"Item Journal Line",
            ItemJnlLine."Entry Type".AsInteger(), ItemJnlLine."Journal Template Name",
            ItemJnlLine."Journal Batch Name", 0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure",
            TempTrackingSpecification."Quantity (Base)", TempTrackingSpecification."Quantity (Base)", ReservationEntry);

        CreateReservEntry.CreateEntry(
            ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
            SLInventory.Descr, ItemJnlLine."Posting Date", ItemJnlLine."Posting Date", 0, ReservationStatus::Prospect);
    end;

    internal procedure MigrateItemInventoryPostingGroup(SLInventory: Record "SL Inventory"; var Sender: Codeunit "Item Data Migration Facade")
    var
        Item: Record Item;
        SLSite: Record "SL Site";
        SLINSetup: Record "SL INSetup";
    begin
        if not Sender.DoesItemExist(CopyStr(SLInventory.InvtID, 1, MaxStrLen(Item."No."))) then
            exit;

        SLINSetup.Get('IN');
        Sender.CreateInventoryPostingSetupIfNeeded(DefaultPostingGroupCodeTxt, DefaultPostingGroupDescriptionTxt, '');
        Sender.CreateGeneralProductPostingSetupIfNeeded(SLItemImportPostingGroupCodeTxt, SLItemImportPostingGroupDescriptionTxt, '');
        Sender.CreateGeneralProductPostingSetupIfNeeded(SLItemImportPostingGroupCodeTxt, SLItemImportPostingGroupDescriptionTxt, DefaultPostingGroupCodeTxt);
        Sender.SetInventoryPostingSetupInventoryAccount(DefaultPostingGroupCodeTxt, '', SLINSetup.DfltInvtAcct);

        if SLSite.FindSet() then
            repeat
                Sender.CreateInventoryPostingSetupIfNeeded(DefaultPostingGroupCodeTxt, DefaultPostingGroupDescriptionTxt, SLSite.SiteId);
                Sender.CreateInventoryPostingSetupIfNeeded(SLItemImportPostingGroupCodeTxt, SLItemImportPostingGroupDescriptionTxt, SLSite.SiteId);
                Sender.SetInventoryPostingSetupInventoryAccount(DefaultPostingGroupCodeTxt, SLSite.SiteId, SLINSetup.DfltInvtAcct);
            until SLSite.Next() = 0;

        Sender.SetInventoryPostingGroup(DefaultPostingGroupCodeTxt);

        Sender.ModifyItem(true);
    end;

    internal procedure GetSLBCTrackingCode(SLInventory: Record "SL Inventory"): Code[10]
    begin
        if (SLInventory.LotSerTrack = 'LI') and (SLInventory.SerAssign = 'R') and (SLInventory.LotSerIssMthd = 'E') then
            exit('LOTRCVDEXP');
        if (SLInventory.LotSerTrack = 'LI') and (SLInventory.SerAssign = 'R') and (SLInventory.LotSerIssMthd <> 'E') then
            exit('LOTRCVD');
        if (SLInventory.LotSerTrack = 'LI') and (SLInventory.SerAssign = 'U') and (SLInventory.ValMthd <> 'S') then
            exit('LOTUSED');
        if (SLInventory.LotSerTrack = 'SI') and (SLInventory.SerAssign = 'R') and (SLInventory.LotSerIssMthd = 'E') then
            exit('SERRCVDEXP');
        if (SLInventory.LotSerTrack = 'SI') and (SLInventory.SerAssign = 'R') and (SLInventory.LotSerIssMthd <> 'E') then
            exit('SERRCVD');
        if (SLInventory.LotSerTrack = 'SI') and (SLInventory.SerAssign = 'U') and (SLInventory.ValMthd <> 'S') then
            exit('SERUSED');
        if (SLInventory.ValMthd = 'S') and ((SLInventory.LotSerTrack = 'NN') or (SLInventory.LotSerTrack in ['LI', 'SI'])) then
            exit('LOTRCVD');
        exit('');
    end;

    internal procedure SetGeneralPostingSetupForInventory(SLINSetup: Record "SL INSetup")
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if GeneralPostingSetup.Get('', DefaultPostingGroupCodeTxt) then begin
            if (SLINSetup.AdjustmentsAcct.TrimEnd() <> '') then
                GeneralPostingSetup."Inventory Adjmt. Account" := SLINSetup.AdjustmentsAcct;
            if (SLINSetup.DfltCOGSAcct.TrimEnd() <> '') then
                GeneralPostingSetup."COGS Account" := SLINSetup.DfltCOGSAcct;
            if (SLINSetup.DfltSalesAcct.TrimEnd() <> '') then
                GeneralPostingSetup."Sales Account" := SLINSetup.DfltSalesAcct;
            GeneralPostingSetup.Modify();
        end;

        if GeneralPostingSetup.Get(DefaultPostingGroupCodeTxt, DefaultPostingGroupCodeTxt) then begin
            if (SLINSetup.AdjustmentsAcct.TrimEnd() <> '') then
                GeneralPostingSetup."Inventory Adjmt. Account" := SLINSetup.AdjustmentsAcct;
            if (SLINSetup.DfltCOGSAcct.TrimEnd() <> '') then
                GeneralPostingSetup."COGS Account" := SLINSetup.DfltCOGSAcct;
            if (SLINSetup.DfltSalesAcct.TrimEnd() <> '') then
                GeneralPostingSetup."Sales Account" := SLINSetup.DfltSalesAcct;
            GeneralPostingSetup.Modify();
        end;

        if GeneralPostingSetup.Get(DefaultPostingGroupCodeTxt, SLItemImportPostingGroupCodeTxt) then begin
            if (SLINSetup.DfltInvtAcct <> '') then
                GeneralPostingSetup."Inventory Adjmt. Account" := SLINSetup.DfltInvtAcct;
            if (SLINSetup.DfltCOGSAcct.TrimEnd() <> '') then
                GeneralPostingSetup."COGS Account" := SLINSetup.DfltCOGSAcct;
            if (SLINSetup.DfltSalesAcct.TrimEnd() <> '') then
                GeneralPostingSetup."Sales Account" := SLINSetup.DfltSalesAcct;
            GeneralPostingSetup.Modify();
        end;

        if GeneralPostingSetup.Get('', SLItemImportPostingGroupCodeTxt) then begin
            if (SLINSetup.DfltInvtAcct <> '') then
                GeneralPostingSetup."Inventory Adjmt. Account" := SLINSetup.DfltInvtAcct;
            if (SLINSetup.DfltCOGSAcct.TrimEnd() <> '') then
                GeneralPostingSetup."COGS Account" := SLINSetup.DfltCOGSAcct;
            if (SLINSetup.DfltSalesAcct.TrimEnd() <> '') then
                GeneralPostingSetup."Sales Account" := SLINSetup.DfltSalesAcct;
            GeneralPostingSetup.Modify();
        end;
    end;

    internal procedure GetCostingMethod(var SLInventory: Record "SL Inventory"): Option
    begin
        case SLInventory.ValMthd of
            // FIFO, Specific Cost ID
            'F', 'S':
                exit(CostingMethodOption::FIFO);
            // LIFO
            'L':
                exit(CostingMethodOption::LIFO);
            // Average Cost, User-Specified Cost
            'A', 'U':
                exit(CostingMethodOption::Average);
            // Standard Cost
            'T':
                exit(CostingMethodOption::Standard);
        end;
    end;

    internal procedure GetMaxBatchLineCount(): Integer
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
    internal procedure OnBeforeGetMaxItemBatchLineCount(var IsHandled: Boolean; var NewMaxLineCount: Integer)
    begin
    end;
}