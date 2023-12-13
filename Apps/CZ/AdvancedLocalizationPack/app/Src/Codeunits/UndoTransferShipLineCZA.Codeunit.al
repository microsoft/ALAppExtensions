// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Inventory.Transfer;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Inventory;
using Microsoft.Inventory.Analysis;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Setup;
using Microsoft.Inventory.Tracking;
using Microsoft.Warehouse.History;
using Microsoft.Warehouse.Journal;
using Microsoft.Warehouse.Ledger;
using Microsoft.Warehouse.Request;
using Microsoft.Warehouse.Setup;

codeunit 31425 "Undo Transfer Ship. Line CZA"
{
    Permissions = TableData "Item Application Entry" = rmd,
                  TableData "Transfer Line" = imd,
                  TableData "Transfer Shipment Line" = imd,
                  TableData "Item Entry Relation" = ri;
    TableNo = "Transfer Shipment Line";
    ObsoleteReason = 'Replaced by standard "Undo Transfer Shipment" codeunit.';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    trigger OnRun()
    var
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        ItemList, ConfirmQst : Text;
        UndoShptLinesQst: Label 'Do you really want to undo the selected Shipment lines?';
        EmptyItemNoErr: Label 'Undo Shipment can be performed only for lines with nonempty Item No. Please select a line with nonempty Item No. and repeat the procedure.';
    begin
        ItemList := GetItemList(Rec);
        if ItemList = '' then
            Error(EmptyItemNoErr);

        ConfirmQst := UndoShptLinesQst + '\\' + ItemList;
        if not HideDialog then
            if not Confirm(ConfirmQst) then
                exit;

        TransferShipmentLineGlobal.Copy(Rec);
        Code();
        UpdateItemAnalysisView.UpdateAll(0, true);
        Rec := TransferShipmentLineGlobal;
    end;

    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLineGlobal: Record "Transfer Shipment Line";
        TempWarehouseJournalLineGlobal: Record "Warehouse Journal Line" temporary;
        TempItemLedgerEntryGlobal: Record "Item Ledger Entry" temporary;
        TempItemEntryRelationGlobal: Record "Item Entry Relation" temporary;
        InventorySetup: Record "Inventory Setup";
        UndoPostingManagement: Codeunit "Undo Posting Management";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        WhseUndoQuantity: Codeunit "Whse. Undo Quantity";
        InventoryAdjustment: Codeunit "Inventory Adjustment";
        HideDialog: Boolean;
        NextLineNoGlobal: Integer;
        CorrectionLineNo: Integer;

    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;

    local procedure Code()
    var
        TransferHeader: Record "Transfer Header";
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        ReleaseTransferDocument: Codeunit "Release Transfer Document";
        WindowDialog: Dialog;
        ItemShptEntryNo: Integer;
        Release, PostedWhseShptLineFound : Boolean;
        UndoQtyPostingMsg: Label 'Undo Quantity posting...';
        CheckingLinesMsg: Label 'Checking lines...';
    begin
        Clear(ItemJnlPostLine);
#pragma warning disable AA0210
        TransferShipmentLineGlobal.SetRange(TransferShipmentLineGlobal."Correction CZA", false);
#pragma warning restore AA0210

        repeat
            if not HideDialog then
                WindowDialog.Open(CheckingLinesMsg);
            CheckTransShptLine();
        until TransferShipmentLineGlobal.Next() = 0;

        TransferHeader.Get(TransferShipmentLineGlobal."Transfer Order No.");
        Release := TransferHeader.Status = TransferHeader.Status::Released;
        if Release then
            ReleaseTransferDocument.Reopen(TransferHeader);

        TransferShipmentLineGlobal.FindSet(false);
        repeat
            TempItemLedgerEntryGlobal.Reset();
            if not TempItemLedgerEntryGlobal.IsEmpty() then
                TempItemLedgerEntryGlobal.DeleteAll();
            TempItemEntryRelationGlobal.Reset();
            if not TempItemEntryRelationGlobal.IsEmpty() then
                TempItemEntryRelationGlobal.DeleteAll();

            if not HideDialog then
                WindowDialog.Open(UndoQtyPostingMsg);

            CorrectionLineNo := GetNextTransferShipmentLineNo(TransferShipmentLineGlobal);
            PostedWhseShptLineFound :=
              WhseUndoQuantity.FindPostedWhseShptLine(
                PostedWhseShipmentLine,
                Database::"Transfer Shipment Line",
                TransferShipmentLineGlobal."Document No.",
                Database::"Transfer Line",
                0,
                TransferShipmentLineGlobal."Transfer Order No.",
                TransferShipmentLineGlobal."Line No.");
            ItemShptEntryNo := PostItemJnlLine();
            InsertNewShipmentLine(TransferShipmentLineGlobal, ItemShptEntryNo);
            if PostedWhseShptLineFound then
                WhseUndoQuantity.UndoPostedWhseShptLine(PostedWhseShipmentLine);
            TempWarehouseJournalLineGlobal.SetRange("Source Line No.", TransferShipmentLineGlobal."Line No.");
            WhseUndoQuantity.PostTempWhseJnlLine(TempWarehouseJournalLineGlobal);
            UpdateTransLine(TransferShipmentLineGlobal);
            if PostedWhseShptLineFound then
                WhseUndoQuantity.UpdateShptSourceDocLines(PostedWhseShipmentLine);
            TransferShipmentLineGlobal."Correction CZA" := true;
            TransferShipmentLineGlobal.Modify();
        until TransferShipmentLineGlobal.Next() = 0;

        InventorySetup.Get();
        if InventorySetup."Automatic Cost Adjustment" <>
           InventorySetup."Automatic Cost Adjustment"::Never
        then begin
            TransferShipmentHeader.Get(TransferShipmentLineGlobal."Document No.");
            InventoryAdjustment.SetProperties(true, true);
            InventoryAdjustment.MakeMultiLevelAdjmt();
        end;

        if Release then begin
            TransferHeader.Find();
            ReleaseTransferDocument.Run(TransferHeader);
        end;
    end;

    local procedure CheckTransShptLine()
    var
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        TransferLine: Record "Transfer Line";
        ShptAlreadyReceiptErr: Label 'This shipment has already been received. Undo Shipment can be applied only to posted, but not received shipments.';
    begin
        TransferLine.Get(TransferShipmentLineGlobal."Transfer Order No.", TransferShipmentLineGlobal."Line No.");
        if TransferLine."Quantity Received" <> 0 then
            Error(ShptAlreadyReceiptErr);

        TestTransferShipmentLine(TransferShipmentLineGlobal);
        UndoPostingManagement.CollectItemLedgEntries(TempItemLedgerEntry, Database::"Transfer Shipment Line",
          TransferShipmentLineGlobal."Document No.", TransferShipmentLineGlobal."Line No.", TransferShipmentLineGlobal."Quantity (Base)", TransferShipmentLineGlobal."Item Shpt. Entry No.");
        UndoPostingManagement.CheckItemLedgEntries(TempItemLedgerEntry, TransferShipmentLineGlobal."Line No.");
    end;

    local procedure PostItemJnlLine(): Integer
    var
        ItemJournalLine: Record "Item Journal Line";
        TransferShipmentHeader2: Record "Transfer Shipment Header";
        SourceCodeSetup: Record "Source Code Setup";
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
    begin
        SourceCodeSetup.Get();
        TransferShipmentHeader2.Get(TransferShipmentLineGlobal."Document No.");

        ItemJournalLine.Init();
        ItemJournalLine."Posting Date" := TransferShipmentHeader2."Posting Date";
        ItemJournalLine."Document Date" := TransferShipmentHeader2."Posting Date";
        ItemJournalLine."Document Type" := ItemJournalLine."Document Type"::"Transfer Shipment";
        ItemJournalLine."Document No." := TransferShipmentHeader2."No.";
        ItemJournalLine."Document Line No." := CorrectionLineNo;
        ItemJournalLine."Order Type" := ItemJournalLine."Order Type"::Transfer;
        ItemJournalLine."Order No." := TransferShipmentHeader2."Transfer Order No.";
        ItemJournalLine."Order Line No." := TransferShipmentLineGlobal."Transfer Order Line No. CZA";
        ItemJournalLine."External Document No." := TransferShipmentHeader2."External Document No.";
        ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::Transfer;
        ItemJournalLine."Item No." := TransferShipmentLineGlobal."Item No.";
        ItemJournalLine.Description := TransferShipmentLineGlobal.Description;
        ItemJournalLine."Shortcut Dimension 1 Code" := TransferShipmentLineGlobal."Shortcut Dimension 1 Code";
        ItemJournalLine."New Shortcut Dimension 1 Code" := TransferShipmentLineGlobal."Shortcut Dimension 1 Code";
        ItemJournalLine."Shortcut Dimension 2 Code" := TransferShipmentLineGlobal."Shortcut Dimension 2 Code";
        ItemJournalLine."New Shortcut Dimension 2 Code" := TransferShipmentLineGlobal."Shortcut Dimension 2 Code";
        ItemJournalLine."Dimension Set ID" := TransferShipmentLineGlobal."Dimension Set ID";
        ItemJournalLine."New Dimension Set ID" := TransferShipmentLineGlobal."Dimension Set ID";
        ItemJournalLine."Location Code" := TransferShipmentHeader2."In-Transit Code";
        ItemJournalLine."New Location Code" := TransferShipmentHeader2."Transfer-from Code";
        ItemJournalLine.Quantity := TransferShipmentLineGlobal.Quantity;
        ItemJournalLine."Invoiced Quantity" := TransferShipmentLineGlobal.Quantity;
        ItemJournalLine."Quantity (Base)" := TransferShipmentLineGlobal."Quantity (Base)";
        ItemJournalLine."Invoiced Qty. (Base)" := TransferShipmentLineGlobal."Quantity (Base)";
        ItemJournalLine."Source Code" := SourceCodeSetup.Transfer;
        ItemJournalLine."Gen. Prod. Posting Group" := TransferShipmentLineGlobal."Gen. Prod. Posting Group";
        ItemJournalLine."Inventory Posting Group" := TransferShipmentLineGlobal."Inventory Posting Group";
        ItemJournalLine."Unit of Measure Code" := TransferShipmentLineGlobal."Unit of Measure Code";
        ItemJournalLine."Qty. per Unit of Measure" := TransferShipmentLineGlobal."Qty. per Unit of Measure";
        ItemJournalLine."Variant Code" := TransferShipmentLineGlobal."Variant Code";
        ItemJournalLine."New Bin Code" := TransferShipmentLineGlobal."Transfer-from Bin Code";
        ItemJournalLine."Country/Region Code" := TransferShipmentHeader2."Trsf.-from Country/Region Code";
        ItemJournalLine."Transaction Type" := TransferShipmentHeader2."Transaction Type";
        ItemJournalLine."Transport Method" := TransferShipmentHeader2."Transport Method";
        ItemJournalLine."Entry/Exit Point" := TransferShipmentHeader2."Entry/Exit Point";
        ItemJournalLine.Area := TransferShipmentHeader2.Area;
        ItemJournalLine."Transaction Specification" := TransferShipmentHeader2."Transaction Specification";
        ItemJournalLine."Item Category Code" := TransferShipmentLineGlobal."Item Category Code";
        ItemJournalLine."Shpt. Method Code" := TransferShipmentHeader2."Shipment Method Code";
        ItemJournalLine."Gen. Bus. Posting Group" := TransferShipmentLineGlobal."Gen.Bus.Post.Group Ship CZA";

        InsertTempWhseJnlLine(ItemJournalLine,
          Database::"Transfer Line",
          0,
          TransferShipmentLineGlobal."Transfer Order No.",
          TransferShipmentLineGlobal."Line No.",
          TempWarehouseJournalLineGlobal."Reference Document"::"Posted T. Shipment",
          TempWarehouseJournalLineGlobal,
          NextLineNoGlobal);

        if TransferShipmentLineGlobal."Item Shpt. Entry No." <> 0 then begin
            ItemJnlPostLine.RunWithCheck(ItemJournalLine);
            exit(ItemJournalLine."Item Shpt. Entry No.");
        end;
        UndoPostingManagement.CollectItemLedgEntries(TempItemLedgerEntry, Database::"Transfer Shipment Line",
          TransferShipmentLineGlobal."Document No.", TransferShipmentLineGlobal."Line No.", TransferShipmentLineGlobal."Quantity (Base)", TransferShipmentLineGlobal."Item Shpt. Entry No.");

        PostItemJnlLineAppliedToListTr(ItemJournalLine, TempItemLedgerEntry,
          TransferShipmentLineGlobal.Quantity, TransferShipmentLineGlobal."Quantity (Base)", TempItemLedgerEntryGlobal, TempItemEntryRelationGlobal);
        exit(0); // "Item Shpt. Entry No."
    end;

    local procedure InsertNewShipmentLine(OldTransferShipmentLine: Record "Transfer Shipment Line"; ItemShptEntryNo: Integer)
    var
        NewTransferShipmentLine: Record "Transfer Shipment Line";
    begin
        NewTransferShipmentLine.Reset();
        NewTransferShipmentLine.Init();
        NewTransferShipmentLine.Copy(OldTransferShipmentLine);
        NewTransferShipmentLine."Line No." := CorrectionLineNo;
        NewTransferShipmentLine."Item Shpt. Entry No." := ItemShptEntryNo;
        NewTransferShipmentLine.Quantity := -OldTransferShipmentLine.Quantity;
        NewTransferShipmentLine."Quantity (Base)" := -OldTransferShipmentLine."Quantity (Base)";
        NewTransferShipmentLine."Correction CZA" := true;
        NewTransferShipmentLine.Insert();

        InsertItemEntryRelation(TempItemEntryRelationGlobal, NewTransferShipmentLine);
    end;

    local procedure GetNextTransferShipmentLineNo(TransferShipmentLine: Record "Transfer Shipment Line"): Integer
    var
        NextTransferShipmentLine: Record "Transfer Shipment Line";
        LineSpacing: Integer;
        NotEnoughSpaceErr: Label 'There is not enough space to insert correction lines.';
    begin
        NextTransferShipmentLine.SetRange("Document No.", TransferShipmentLine."Document No.");
        NextTransferShipmentLine."Document No." := TransferShipmentLine."Document No.";
        NextTransferShipmentLine."Line No." := TransferShipmentLine."Line No.";
        NextTransferShipmentLine.Find('=');

        if NextTransferShipmentLine.Next() = 1 then begin
            LineSpacing := (NextTransferShipmentLine."Line No." - TransferShipmentLine."Line No.") div 2;
            if LineSpacing = 0 then
                Error(NotEnoughSpaceErr);
        end else
            LineSpacing := 10000;

        exit(TransferShipmentLine."Line No." + LineSpacing);
    end;

    local procedure UpdateTransLine(TransferShipmentLine: Record "Transfer Shipment Line")
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.Get(TransferShipmentLine."Transfer Order No.", TransferShipmentLine."Line No.");
        UpdateTransferLine(TransferLine, TransferShipmentLine.Quantity, TransferShipmentLine."Quantity (Base)", TempItemLedgerEntryGlobal);
    end;

    local procedure InsertItemEntryRelation(var TempItemEntryRelation: Record "Item Entry Relation" temporary; NewTransferShipmentLine: Record "Transfer Shipment Line")
    var
        ItemEntryRelation: Record "Item Entry Relation";
    begin
        if TempItemEntryRelation.FindSet(false) then
            repeat
                ItemEntryRelation := TempItemEntryRelation;
                ItemEntryRelation.TransferFieldsTransShptLine(NewTransferShipmentLine);
                ItemEntryRelation.Insert();
            until TempItemEntryRelation.Next() = 0;
    end;

    local procedure GetItemList(var TransferShipmentLine: Record "Transfer Shipment Line") ItemList: Text
    var
        TransferShipmentLine2: Record "Transfer Shipment Line";
        FourPlaceholdersTok: Label '%1 %2: %3 %4\', Locked = true;
    begin
        TransferShipmentLine2.Copy(TransferShipmentLine);
        TransferShipmentLine2.SetFilter(TransferShipmentLine2."Item No.", '<>%1', '');
        TransferShipmentLine2.SetFilter(TransferShipmentLine2.Quantity, '<>%1', 0);
        if TransferShipmentLine2.FindSet() then
            repeat
                ItemList += StrSubstNo(FourPlaceholdersTok, TransferShipmentLine2."Item No.", TransferShipmentLine2.Description, TransferShipmentLine2.Quantity, TransferShipmentLine2."Unit of Measure Code");
            until TransferShipmentLine2.Next() = 0;
    end;

    local procedure InsertTempWhseJnlLine(ItemJournalLine: Record "Item Journal Line"; SourceType: Integer; SourceSubType: Integer; SourceNo: Code[20]; SourceLineNo: Integer; RefDoc: Enum "Whse. Reference Document Type"; var TempWarehouseJournalLine: Record "Warehouse Journal Line" temporary; var NextLineNo: Integer)
    var
        WarehouseEntry: Record "Warehouse Entry";
        WhseManagement: Codeunit "Whse. Management";
        WMSManagement: Codeunit "WMS Management";
    begin
        WarehouseEntry.Reset();
        WarehouseEntry.SetCurrentKey("Source Type", "Source Subtype", "Source No.");
        WarehouseEntry.SetRange("Source Type", SourceType);
        WarehouseEntry.SetRange("Source Subtype", SourceSubType);
        WarehouseEntry.SetRange("Source No.", SourceNo);
        WarehouseEntry.SetRange("Source Line No.", SourceLineNo);
        WarehouseEntry.SetRange("Reference No.", ItemJournalLine."Document No.");
        WarehouseEntry.SetRange("Item No.", ItemJournalLine."Item No.");
        if WarehouseEntry.Find('+') then
            repeat
                TempWarehouseJournalLine.Init();
                if WarehouseEntry."Entry Type" = WarehouseEntry."Entry Type"::"Positive Adjmt." then
                    ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::"Negative Adjmt."
                else
                    ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::"Positive Adjmt.";
                ItemJournalLine.Quantity := Abs(WarehouseEntry.Quantity);
                ItemJournalLine."Quantity (Base)" := Abs(WarehouseEntry."Qty. (Base)");
                WMSManagement.CreateWhseJnlLine(ItemJournalLine, 0, TempWarehouseJournalLine, true);
                TempWarehouseJournalLine."Source Type" := SourceType;
                TempWarehouseJournalLine."Source Subtype" := SourceSubType;
                TempWarehouseJournalLine."Source No." := SourceNo;
                TempWarehouseJournalLine."Source Line No." := SourceLineNo;
#pragma warning disable AL0603
                TempWarehouseJournalLine."Source Document" := WhseManagement.GetSourceDocument(TempWarehouseJournalLine."Source Type", TempWarehouseJournalLine."Source Subtype");
#pragma warning restore AL0603
                TempWarehouseJournalLine."Reference Document" := RefDoc;
                TempWarehouseJournalLine."Reference No." := ItemJournalLine."Document No.";
                TempWarehouseJournalLine."Location Code" := WarehouseEntry."Location Code";
                TempWarehouseJournalLine."Zone Code" := WarehouseEntry."Zone Code";
                TempWarehouseJournalLine."Bin Code" := WarehouseEntry."Bin Code";
                TempWarehouseJournalLine."Whse. Document Type" := WarehouseEntry."Whse. Document Type";
                TempWarehouseJournalLine."Whse. Document No." := WarehouseEntry."Whse. Document No.";
                TempWarehouseJournalLine."Unit of Measure Code" := WarehouseEntry."Unit of Measure Code";
                TempWarehouseJournalLine."Line No." := NextLineNo;
                TempWarehouseJournalLine."Serial No." := WarehouseEntry."Serial No.";
                TempWarehouseJournalLine."Lot No." := WarehouseEntry."Lot No.";
                TempWarehouseJournalLine."Expiration Date" := WarehouseEntry."Expiration Date";
                if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::"Negative Adjmt." then begin
                    TempWarehouseJournalLine."From Zone Code" := TempWarehouseJournalLine."Zone Code";
                    TempWarehouseJournalLine."From Bin Code" := TempWarehouseJournalLine."Bin Code";
                end else begin
                    TempWarehouseJournalLine."To Zone Code" := TempWarehouseJournalLine."Zone Code";
                    TempWarehouseJournalLine."To Bin Code" := TempWarehouseJournalLine."Bin Code";
                end;
                TempWarehouseJournalLine.Insert();
                NextLineNo := TempWarehouseJournalLine."Line No." + 10000;
            until WarehouseEntry.Next(-1) = 0;

    end;

    local procedure TestTransferShipmentLine(TransferShipmentLine: Record "Transfer Shipment Line")
    begin
        UndoPostingManagement.RunTestAllTransactions(Database::"Transfer Shipment Line",
              TransferShipmentLine."Document No.", TransferShipmentLine."Line No.",
              Database::"Transfer Line",
              0,
              TransferShipmentLine."Transfer Order No.",
              TransferShipmentLine."Line No.");
    end;

    procedure PostItemJnlLineAppliedToListTr(ItemJournalLine: Record "Item Journal Line"; var TempApplyToItemLedgerEntry: Record "Item Ledger Entry" temporary; UndoQty: Decimal; UndoQtyBase: Decimal; var TempItemLedgerEntry: Record "Item Ledger Entry" temporary; var TempItemEntryRelation: Record "Item Entry Relation" temporary)
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemJnlPostLine2: Codeunit "Item Jnl.-Post Line";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        NonDistrQuantity: Decimal;
        NonDistrQuantityBase: Decimal;
        ExpDate: Date;
        DummyEntriesExist: Boolean;
    begin
        TempApplyToItemLedgerEntry.FindSet(false); // Assertion: will fail if not found.
        ItemJournalLine.TestField("Entry Type", ItemJournalLine."Entry Type"::Transfer);
        NonDistrQuantity := UndoQty;
        NonDistrQuantityBase := UndoQtyBase;
        repeat
            ItemJournalLine."Applies-to Entry" := 0;
            ItemJournalLine."Item Shpt. Entry No." := 0;
            ItemJournalLine."Quantity (Base)" := -TempApplyToItemLedgerEntry.Quantity;
            ItemJournalLine."Serial No." := TempApplyToItemLedgerEntry."Serial No.";
            ItemJournalLine."Lot No." := TempApplyToItemLedgerEntry."Lot No.";
            ItemJournalLine."New Serial No." := TempApplyToItemLedgerEntry."Serial No.";
            ItemJournalLine."New Lot No." := TempApplyToItemLedgerEntry."Lot No.";

            if (ItemJournalLine."Serial No." <> '') or
               (ItemJournalLine."Lot No." <> '')
            then begin
                ItemTrackingSetup."Serial No." := ItemJournalLine."Serial No.";
                ItemTrackingSetup."Lot No." := ItemJournalLine."Lot No.";
                ExpDate := ItemTrackingManagement.ExistingExpirationDate(
                    ItemJournalLine."Item No.",
                    ItemJournalLine."Variant Code",
                    ItemTrackingSetup,
                    false, DummyEntriesExist);
                ItemJournalLine."New Item Expiration Date" := ExpDate;
                ItemJournalLine."Item Expiration Date" := ExpDate;
            end;

            // Quantity is filled in according to UOM:
            ItemTrackingManagement.AdjustQuantityRounding(
              NonDistrQuantity, ItemJournalLine.Quantity,
              NonDistrQuantityBase, ItemJournalLine."Quantity (Base)");

            NonDistrQuantity -= ItemJournalLine.Quantity;
            NonDistrQuantityBase -= ItemJournalLine."Quantity (Base)";

            ItemJournalLine."Invoiced Quantity" := ItemJournalLine.Quantity;
            ItemJournalLine."Invoiced Qty. (Base)" := ItemJournalLine."Quantity (Base)";

            ItemJournalLine."Invoice No." := 'xSetExtLotSN';
            ItemJnlPostLine2.RunWithCheck(ItemJournalLine);

            ItemJnlPostLine2.CollectItemEntryRelation(TempItemEntryRelation);
            TempItemLedgerEntry := TempApplyToItemLedgerEntry;
            TempItemLedgerEntry.Insert();
        until TempApplyToItemLedgerEntry.Next() = 0;
    end;

    procedure UpdateTransferLine(TransferLine: Record "Transfer Line"; UndoQty: Decimal; UndoQtyBase: Decimal; var TempUndoneItemLedgerEntry: Record "Item Ledger Entry" temporary)
    var
        TransferLine1: Record "Transfer Line";
        TransferLine2: Record "Transfer Line";
        ReservationEntry: Record "Reservation Entry";
        ItemEntryRelation: Record "Item Entry Relation";
        TransferLineReserve: Codeunit "Transfer Line-Reserve";
        Line, ResEntryNo : Integer;
    begin
        TransferLine1 := TransferLine;
        TransferLine."Quantity Shipped" := TransferLine."Quantity Shipped" - UndoQty;
        TransferLine."Qty. Shipped (Base)" := TransferLine."Qty. Shipped (Base)" - UndoQtyBase;
        TransferLine.InitQtyInTransit();
        TransferLine.InitOutstandingQty();
        TransferLine.InitQtyToShip();
        TransferLine.InitQtyToReceive();
        TransferLine.Modify();
        TransferLine1."Quantity (Base)" := 0;
        TransferLineReserve.VerifyQuantity(TransferLine, TransferLine1);

        if TempUndoneItemLedgerEntry.FindSet(false) then
            repeat
                if (TempUndoneItemLedgerEntry."Serial No." <> '') or (TempUndoneItemLedgerEntry."Lot No." <> '') then begin
                    ReservationEntry.Reset();
                    ReservationEntry.SetCurrentKey("Source ID");
                    ReservationEntry.SetRange("Source Type", Database::"Transfer Line");
                    ReservationEntry.SetRange("Source ID", TransferLine."Document No.");
                    ReservationEntry.SetRange("Source Batch Name", '');
                    ReservationEntry.SetRange("Source Prod. Order Line", TransferLine."Line No.");
                    ReservationEntry.SetRange("Serial No.", TempUndoneItemLedgerEntry."Serial No.");
                    ReservationEntry.SetRange("Lot No.", TempUndoneItemLedgerEntry."Lot No.");
                    while ReservationEntry.FindFirst() do begin
                        if ReservationEntry."Source Ref. No." <> 0 then
                            Line := ReservationEntry."Source Ref. No.";
                        ReservationEntry.Delete();
                    end;
                    if ItemEntryRelation.Get(TempUndoneItemLedgerEntry."Entry No.") then begin
                        ItemEntryRelation."Undo CZA" := true;
                        ItemEntryRelation.Modify();
                    end;

                    ReservationEntry.Reset();
                    Clear(ResEntryNo);
                    if ReservationEntry.FindLast() then
                        ResEntryNo := ReservationEntry."Entry No.";
                    ResEntryNo += 1;
                    ReservationEntry.Init();
                    ReservationEntry."Entry No." := ResEntryNo;
                    ReservationEntry.Positive := false;
                    ReservationEntry."Item No." := TempUndoneItemLedgerEntry."Item No.";
                    ReservationEntry."Location Code" := TransferLine."Transfer-from Code";
                    ReservationEntry."Quantity (Base)" := TempUndoneItemLedgerEntry.Quantity;
                    ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
                    ReservationEntry."Creation Date" := Today;
                    ReservationEntry."Source Type" := Database::"Transfer Line";
                    ReservationEntry."Source Subtype" := 0;
                    ReservationEntry."Source ID" := TransferLine."Document No.";
                    ReservationEntry."Source Ref. No." := TransferLine."Line No.";
                    ReservationEntry."Expected Receipt Date" := 0D;
                    ReservationEntry."Shipment Date" := TransferLine."Shipment Date";
                    ReservationEntry."Created By" := CopyStr(UserId(), 1, StrLen(ReservationEntry."Created By"));
                    ReservationEntry."Qty. per Unit of Measure" := TempUndoneItemLedgerEntry."Qty. per Unit of Measure";
                    if TempUndoneItemLedgerEntry."Serial No." <> '' then
                        ReservationEntry.Quantity := -1
                    else
                        ReservationEntry.Quantity := ReservationEntry."Quantity (Base)" / ReservationEntry."Qty. per Unit of Measure";
                    ReservationEntry."Qty. to Handle (Base)" := ReservationEntry."Quantity (Base)";
                    ReservationEntry."Qty. to Invoice (Base)" := ReservationEntry."Quantity (Base)";
                    ReservationEntry."Lot No." := TempUndoneItemLedgerEntry."Lot No.";
                    ReservationEntry."Variant Code" := TempUndoneItemLedgerEntry."Variant Code";
                    ReservationEntry."Serial No." := TempUndoneItemLedgerEntry."Serial No.";
                    ReservationEntry.Insert();
                    ResEntryNo += 1;
                    ReservationEntry."Entry No." := ResEntryNo;
                    ReservationEntry.Positive := true;
                    ReservationEntry."Location Code" := TransferLine."Transfer-to Code";
                    ReservationEntry."Quantity (Base)" := -ReservationEntry."Quantity (Base)";
                    ReservationEntry."Source Subtype" := 1;
                    ReservationEntry."Expected Receipt Date" := TransferLine."Receipt Date";
                    ReservationEntry."Shipment Date" := 0D;
                    ReservationEntry.Quantity := -ReservationEntry.Quantity;
                    ReservationEntry."Qty. to Handle (Base)" := ReservationEntry."Quantity (Base)";
                    ReservationEntry."Qty. to Invoice (Base)" := ReservationEntry."Quantity (Base)";
                    ReservationEntry.Insert();
                end;
            until TempUndoneItemLedgerEntry.Next() = 0;
        if Line <> 0 then
            TransferLine2.SetRange("Line No.", Line);
        TransferLine2.SetRange("Document No.", TransferLine."Document No.");
        TransferLine2.SetRange("Derived From Line No.", TransferLine."Line No.");
#pragma warning disable AA0210
        TransferLine2.SetRange(Quantity, UndoQty);
#pragma warning restore AA0210
        TransferLine2.FindFirst();
        TransferLine2.Delete(true);

    end;
}
#endif
