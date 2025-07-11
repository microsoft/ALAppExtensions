// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Setup;
using Microsoft.Manufacturing.Document;
using System.Security.User;

codeunit 31078 "Item Journal Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforeValidateEvent', 'Entry Type', false, false)]
    local procedure InvtMovementTemplateOnBeforeValidateEntryType(var Rec: Record "Item Journal Line"; CurrFieldNo: Integer)
    begin
        if (Rec."Invt. Movement Template CZL" <> '') and (CurrFieldNo = Rec.FieldNo("Entry Type")) then
            Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforeValidateEvent', 'Gen. Bus. Posting Group', false, false)]
    local procedure InvtMovementTemplateOnBeforeValidateGenBusPostingGroup(var Rec: Record "Item Journal Line"; CurrFieldNo: Integer)
    begin
        if (Rec."Invt. Movement Template CZL" <> '') and (CurrFieldNo = Rec.FieldNo("Gen. Bus. Posting Group")) then
            Rec.TestField("Invt. Movement Template CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Qty. (Phys. Inventory)', false, false)]
    local procedure UpdateInvtMovementTemplateOnAfterValidateQtyPhysInventory(var Rec: Record "Item Journal Line")
    var
        InvtMovementTemplateName: Code[10];
    begin
        InvtMovementTemplateName := GetInvtMovementTemplateName(Rec);
        if InvtMovementTemplateName <> '' then
            Rec.Validate("Invt. Movement Template CZL", InvtMovementTemplateName);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyFromProdOrderLine', '', false, false)]
    local procedure UpdateUnitCostOnAfterCopyFromProdOrderLine(var ItemJournalLine: Record "Item Journal Line"; ProdOrderLine: Record "Prod. Order Line")
    var
        ProdOrderLine2: Record "Prod. Order Line";
        UnitCost: Decimal;
    begin
        ProdOrderLine2.SetFilterByReleasedOrderNo(ItemJournalLine."Order No.");
        ProdOrderLine2.SetRange("Item No.", ItemJournalLine."Item No.");
        if ProdOrderLine2.Count() <> 1 then // ShouldCopyFromSingleProdOrderLine
            exit;

        UnitCost := RetrieveCosts(ItemJournalLine);
        ItemJournalLine."Unit Cost" := UnitCost;
        ItemJournalLine."Unit Amount" := UnitCost;
    end;

    local procedure RetrieveCosts(var ItemJournalLine: Record "Item Journal Line") UnitCost: Decimal
    var
        Item: Record Item;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if (ItemJournalLine."Value Entry Type" <> ItemJournalLine."Value Entry Type"::"Direct Cost") or (ItemJournalLine."Item Charge No." <> '') then
            exit;

        if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Transfer then
            UnitCost := 0
        else begin
            Item.Get(ItemJournalLine."Item No.");
            GeneralLedgerSetup.Get();
            UnitCost := FindUnitCost(Item, ItemJournalLine);
            if Item."Costing Method" <> Item."Costing Method"::Standard then
                UnitCost := Round(UnitCost, GeneralLedgerSetup."Unit-Amount Rounding Precision");
        end;
    end;

    local procedure FindUnitCost(Item: Record Item; ItemJournalLine: Record "Item Journal Line") UnitCost: Decimal
    var
        InventorySetup: Record "Inventory Setup";
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        InventorySetup.Get();
        if InventorySetup."Average Cost Calc. Type" = InventorySetup."Average Cost Calc. Type"::Item then
            UnitCost := Item."Unit Cost"
        else
            if StockkeepingUnit.Get(ItemJournalLine."Location Code", ItemJournalLine."Item No.", ItemJournalLine."Variant Code") then
                UnitCost := StockkeepingUnit."Unit Cost"
            else
                UnitCost := Item."Unit Cost";
    end;

    local procedure GetInvtMovementTemplateName(ItemJournalLine: Record "Item Journal Line"): Code[10]
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if ItemJournalLine."Qty. (Phys. Inventory)" > ItemJournalLine."Qty. (Calculated)" then
            exit(InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL");
        if ItemJournalLine."Qty. (Phys. Inventory)" < ItemJournalLine."Qty. (Calculated)" then
            exit(InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL");
        exit('');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterSetupNewLine', '', false, false)]
    local procedure SetInvtMovementTemplateOnAfterSetupNewLine(var ItemJournalLine: Record "Item Journal Line"; var LastItemJournalLine: Record "Item Journal Line")
    begin
        ItemJournalLine.Validate("Invt. Movement Template CZL", LastItemJournalLine."Invt. Movement Template CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ItemJnlManagement, 'OnBeforeOpenJnl', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJnl(var ItemJnlLine: Record "Item Journal Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := ItemJnlLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"Item Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);
    end;
}
