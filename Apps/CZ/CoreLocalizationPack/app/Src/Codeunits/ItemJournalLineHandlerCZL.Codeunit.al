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
#if not CLEAN22
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Service.Document;
using Microsoft.Service.History;
#endif
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
#if not CLEAN22
#pragma warning disable AL0432

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateItemNoOnAfterGetItem', '', false, false)]
    local procedure CopyFromItemOnValidateItemNoOnAfterGetItem(var ItemJournalLine: Record "Item Journal Line"; Item: Record Item)
    begin
        ItemJournalLine."Tariff No. CZL" := Item."Tariff No.";
        ItemJournalLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        ItemJournalLine."Net Weight CZL" := Item."Net Weight";
        ItemJournalLine."Country/Reg. of Orig. Code CZL" := Item."Country/Region of Origin Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesHeader', '', false, false)]
    local procedure SetIntrastatTransactionOnAfterCopyItemJnlLineFromSalesHeader(var ItemJnlLine: Record "Item Journal Line"; SalesHeader: Record "Sales Header")
    begin
        ItemJnlLine."Physical Transfer CZL" := SalesHeader."Physical Transfer CZL";
        ItemJnlLine."Intrastat Transaction CZL" := SalesHeader.IsIntrastatTransactionCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromSalesLine(var ItemJnlLine: Record "Item Journal Line"; SalesLine: Record "Sales Line")
    begin
        ItemJnlLine."Tariff No. CZL" := SalesLine."Tariff No. CZL";
        ItemJnlLine."Net Weight CZL" := SalesLine."Net Weight";
        // recalc to base UOM
        if ItemJnlLine."Net Weight CZL" <> 0 then
            if SalesLine."Qty. per Unit of Measure" <> 0 then
                ItemJnlLine."Net Weight CZL" := Round(ItemJnlLine."Net Weight CZL" / SalesLine."Qty. per Unit of Measure", 0.00001);
        ItemJnlLine."Country/Reg. of Orig. Code CZL" := SalesLine."Country/Reg. of Orig. Code CZL";
        ItemJnlLine."Statistic Indication CZL" := SalesLine."Statistic Indication CZL";
        ItemJnlLine."Physical Transfer CZL" := SalesLine."Physical Transfer CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromPurchHeader', '', false, false)]
    local procedure SetIntrastatTransactionOnAfterCopyItemJnlLineFromPurchHeader(var ItemJnlLine: Record "Item Journal Line"; PurchHeader: Record "Purchase Header")
    begin
        ItemJnlLine."Physical Transfer CZL" := PurchHeader."Physical Transfer CZL";
        ItemJnlLine."Intrastat Transaction CZL" := PurchHeader.IsIntrastatTransactionCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromPurchLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromPurchLine(var ItemJnlLine: Record "Item Journal Line"; PurchLine: Record "Purchase Line")
    begin
        ItemJnlLine."Tariff No. CZL" := PurchLine."Tariff No. CZL";
        ItemJnlLine."Net Weight CZL" := PurchLine."Net Weight";
        // recalc to base UOM
        if ItemJnlLine."Net Weight CZL" <> 0 then
            if PurchLine."Qty. per Unit of Measure" <> 0 then
                ItemJnlLine."Net Weight CZL" := Round(ItemJnlLine."Net Weight CZL" / PurchLine."Qty. per Unit of Measure", 0.00001);
        ItemJnlLine."Country/Reg. of Orig. Code CZL" := PurchLine."Country/Reg. of Orig. Code CZL";
        ItemJnlLine."Statistic Indication CZL" := PurchLine."Statistic Indication CZL";
        ItemJnlLine."Physical Transfer CZL" := PurchLine."Physical Transfer CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServHeader', '', false, false)]
    local procedure SetIntrastatTransactionOnAfterCopyItemJnlLineFromServHeader(var ItemJnlLine: Record "Item Journal Line"; ServHeader: Record "Service Header")
    begin
        ItemJnlLine."Physical Transfer CZL" := ServHeader."Physical Transfer CZL";
        ItemJnlLine."Intrastat Transaction CZL" := ServHeader.IsIntrastatTransactionCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromServLine(var ItemJnlLine: Record "Item Journal Line"; ServLine: Record "Service Line")
    begin
        ItemJnlLine."Tariff No. CZL" := ServLine."Tariff No. CZL";
        ItemJnlLine."Net Weight CZL" := ServLine."Net Weight";
        // recalc to base UOM
        if ItemJnlLine."Net Weight CZL" <> 0 then
            if ServLine."Qty. per Unit of Measure" <> 0 then
                ItemJnlLine."Net Weight CZL" := Round(ItemJnlLine."Net Weight CZL" / ServLine."Qty. per Unit of Measure", 0.00001);
        ItemJnlLine."Country/Reg. of Orig. Code CZL" := ServLine."Country/Reg. of Orig. Code CZL";
        ItemJnlLine."Statistic Indication CZL" := ServLine."Statistic Indication CZL";
        ItemJnlLine."Physical Transfer CZL" := ServLine."Physical Transfer CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServShptLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromServShptLine(var ItemJnlLine: Record "Item Journal Line"; ServShptLine: Record "Service Shipment Line")
    begin
        ItemJnlLine.CopyFromServiceShipmentLineCZL(ServShptLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServShptLineUndo', '', false, false)]
    local procedure CopyFieldsOnAfterCopyItemJnlLineFromServShptLineUndo(var ItemJnlLine: Record "Item Journal Line"; ServShptLine: Record "Service Shipment Line")
    begin
        ItemJnlLine.CopyFromServiceShipmentLineCZL(ServShptLine);
    end;
#pragma warning restore AL0432
#endif

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
