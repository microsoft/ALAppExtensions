// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Tracking;
using Microsoft.Manufacturing.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Service.Document;
using Microsoft.Service.History;

codeunit 31253 "Item Journal Line Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Variant Code', false, false)]
    local procedure SetGPPGfromSKUOnAfterValidateVariantCode(var Rec: Record "Item Journal Line")
    begin
        Rec.SetGPPGfromSKUCZA();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure SetGPPGfromSKUOnAfterValidateEventLocationCode(var Rec: Record "Item Journal Line")
    begin
        Rec.SetGPPGfromSKUCZA();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateItemNoOnAfterGetItem', '', false, false)]
    local procedure SetGPPGfromSKUOnValidateItemNoOnAfterGetItem(var ItemJournalLine: Record "Item Journal Line")
    begin
        ItemJournalLine.SetGPPGfromSKUCZA();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesHeader', '', false, false)]
    local procedure AddFieldsOnAfterCopyItemJnlLineFromSalesHeader(var ItemJnlLine: Record "Item Journal Line"; SalesHeader: Record "Sales Header")
    begin
        ItemJnlLine."Source No." := SalesHeader."Sell-to Customer No.";
        ItemJnlLine."Invoice-to Source No." := SalesHeader."Bill-to Customer No.";
        ItemJnlLine."Delivery-to Source No. CZA" := SalesHeader."Ship-to Code";
        ItemJnlLine."Currency Code CZA" := SalesHeader."Currency Code";
        ItemJnlLine."Currency Factor CZA" := SalesHeader."Currency Factor";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromPurchHeader', '', false, false)]
    local procedure AddFieldsOnAfterCopyItemJnlLineFromPurchHeader(var ItemJnlLine: Record "Item Journal Line"; PurchHeader: Record "Purchase Header")
    begin
        ItemJnlLine."Source No." := PurchHeader."Buy-from Vendor No.";
        ItemJnlLine."Invoice-to Source No." := PurchHeader."Pay-to Vendor No.";
        ItemJnlLine."Delivery-to Source No. CZA" := PurchHeader."Order Address Code";
        ItemJnlLine."Currency Code CZA" := PurchHeader."Currency Code";
        ItemJnlLine."Currency Factor CZA" := PurchHeader."Currency Factor";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServHeader', '', false, false)]
    local procedure AddFieldsOnAfterCopyItemJnlLineFromServHeader(var ItemJnlLine: Record "Item Journal Line"; ServHeader: Record "Service Header")
    begin
        ItemJnlLine."Source No." := ServHeader."Customer No.";
        ItemJnlLine."Invoice-to Source No." := ServHeader."Bill-to Customer No.";
        ItemJnlLine."Delivery-to Source No. CZA" := ServHeader."Ship-to Code";
        ItemJnlLine."Currency Code CZA" := ServHeader."Currency Code";
        ItemJnlLine."Currency Factor CZA" := ServHeader."Currency Factor";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromServShptHeader', '', false, false)]
    local procedure AddFieldsOnAfterCopyItemJnlLineFromServShptHeader(var ItemJnlLine: Record "Item Journal Line"; ServShptHeader: Record "Service Shipment Header")
    begin
        ItemJnlLine."Currency Code CZA" := ServShptHeader."Currency Code";
        ItemJnlLine."Currency Factor CZA" := ServShptHeader."Currency Factor";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Applies-from Entry', false, false)]
    local procedure CheckExactCostReturnOnAfterValidateAppliesFromEntry(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if Rec."Applies-from Entry" <> 0 then begin
            ItemLedgerEntry.Get(Rec."Applies-from Entry");
            if Rec."Entry Type" = Rec."Entry Type"::Consumption then begin
                ManufacturingSetup.Get();
                if ManufacturingSetup."Exact Cost Rev.Mand. Cons. CZA" then begin
                    ItemLedgerEntry.TestField("Order No.", Rec."Order No.");
                    ItemLedgerEntry.TestField("Order Line No.", Rec."Order Line No.");
                    ItemLedgerEntry.TestField("Prod. Order Comp. Line No.", Rec."Prod. Order Comp. Line No.");
                    ItemLedgerEntry.TestField("Entry Type", Rec."Entry Type");
                end;
            end;
            if ItemLedgerEntry."Invoiced Quantity" = 0 then
                Rec."Unit Cost" := 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnSelectItemEntryOnBeforeOpenPage', '', false, false)]
    local procedure FilterForExactCostReturnOnSelectItemEntryOnBeforeOpenPage(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; CurrentFieldNo: Integer)
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        if (ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Consumption) and
            (ItemJournalLine."Value Entry Type" <> ItemJournalLine."Value Entry Type"::Revaluation) and
            (CurrentFieldNo = ItemJournalLine.FieldNo("Applies-from Entry"))
        then begin
            ManufacturingSetup.Get();
            if ManufacturingSetup."Exact Cost Rev.Mand. Cons. CZA" then begin
                ItemLedgerEntry.SetCurrentKey(
                  "Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No.");
                ItemLedgerEntry.SetRange("Order No.", ItemJournalLine."Order No.");
                ItemLedgerEntry.SetRange("Order Line No.", ItemJournalLine."Order Line No.");
                ItemLedgerEntry.SetRange("Prod. Order Comp. Line No.", ItemJournalLine."Prod. Order Comp. Line No.");
                ItemLedgerEntry.SetRange("Entry Type", ItemJournalLine."Entry Type");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyTrackingFromItemLedgEntry', '', false, false)]
    local procedure CheckSerialNoOnAfterCopyTrackingFromItemLedgEntry(var ItemJournalLine: Record "Item Journal Line"; ItemLedgEntry: Record "Item Ledger Entry")
    var
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        SerialNoOnInventoryErr: Label 'Serial No. %1 is already on inventory.', Comment = '%1 = Serial No.';
    begin
        if not ItemLedgEntry.IsTemporary() then
            exit;
        if (ItemJournalLine."Item No." = '') or (ItemJournalLine."Serial No." = '') then
            exit;

        if (ItemLedgEntry.Quantity < 0) and
           (ItemLedgEntry."Document Type" in [ItemLedgEntry."Document Type"::"Sales Shipment",
            ItemLedgEntry."Document Type"::"Purchase Return Shipment",
            ItemLedgEntry."Document Type"::"Service Shipment",
            ItemLedgEntry."Document Type"::"Purchase Receipt",
            ItemLedgEntry."Document Type"::"Sales Return Receipt"])
        then
            if SerialNoRequired(ItemJournalLine."Item No.") then
                if ItemTrackingManagement.FindInInventory(ItemJournalLine."Item No.", ItemJournalLine."Variant Code", ItemJournalLine."Serial No.") then
                    Error(SerialNoOnInventoryErr, ItemJournalLine."Serial No.");
    end;

    local procedure SerialNoRequired(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        Item.Get(ItemNo);
        if Item."Item Tracking Code" = '' then
            exit;
        ItemTrackingCode.Get(Item."Item Tracking Code");
        exit(ItemTrackingCode."SN Specific Tracking");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Standard Item Journal", 'OnAfterCopyItemJnlFromStdJnl', '', false, false)]
    local procedure NewLocationCodeOnAfterCopyItemJnlFromStdJnl(var ItemJournalLine: Record "Item Journal Line"; var StandardItemJournalLine: Record "Standard Item Journal Line")
    begin
        ItemJournalLine."New Location Code" := StandardItemJournalLine."New Location Code CZA";
    end;
}
