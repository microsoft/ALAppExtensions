// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Tracking;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.Currency;

codeunit 18467 "Subcontracting Post Batch"
{
    TableNo = "Multiple Subcon. Order Details";

    var
        SubOrderComponentList: Record "Sub Order Component List";
        ItemJnlLine: Record "Item Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        DeliveryChallanHeader: Record "Delivery Challan Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        SubcontractingPost: Codeunit "Subcontracting Post";
        DeliveryChallanNo: Code[20];
        BuyfromVendorNo: Code[20];
        NextlineNo: Integer;
        SubconOrderNo: Code[20];
        NotEnoughInventoryErr: Label 'Not Enough Inventory Available at Vendor Location for this order';
        NothingtoSendErr: Label 'Nothing to Send';
        PostConfirmationQst: Label 'Do you want to Post the Receipt and Report the Consumption on the Received Material';
        NothingtoSendDocErr: Label 'There is nothing to send in Document Type=%1, Document No.=%2 and Line No.=%3.',
            Comment = '%1 = Docuemnt Type, %2 = Document No, %3 = Line No';
        NothingtoReceiveErr: Label 'Nothing to receive.';
        SendConfirmationMsg: Label 'Items sent against Delivery Challan No. = %1.', Comment = '%1 = Document No.';
        QtyMismatchErr: Label 'The %1 does not match the quantity defined in item tracking.', Comment = '%1 = Quantity to Send field caption';
        SubConVendCompErr: Label 'Production Order does not exist, No %1, Production Line No %2, Line No %3',
            comment = '%1 = Production Order No, %2 = Production Order Line No, %3 = Line No';
        UnitCostErr: Label 'UnitCost should not be empty in %1.', Comment = '%1 = Delivery Challan Item No.';

    trigger OnRun()
    begin
        if Rec."No." = '' then
            exit;

        Rec.TestField("Posting Date");
        BuyfromVendorNo := Rec."Subcontractor No.";
        CheckQuantitytoSendReceive(Rec."No.", true);
        CreateDeliveryChallanHeader(Rec."Posting Date");

        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Buy-from Vendor No.", Rec."Subcontractor No.");
        PurchaseLine.SetRange("Applies-to ID (Delivery)", Rec."No.");
        PurchaseLine.SetRange(Subcontracting, true);
        if PurchaseLine.FindSet() then begin
            repeat
                SubconOrderNo := PurchaseLine."Document No.";
                PurchaseLine.SubConSend := true;
                SubOrderComponentList.Reset();
                SubOrderComponentList.SetRange("Document No.", PurchaseLine."Document No.");
                SubOrderComponentList.SetRange("Document Line No.", PurchaseLine."Line No.");
                SubOrderComponentList.SetRange("Parent Item No.", PurchaseLine."No.");
                CreateDeliveryChallan(SubOrderComponentList, PurchaseLine);
                SubOrderComponentList.FindSet();
                repeat
                    SubOrderComponentList.TestField("Job Work Return Period");
                    if SubOrderComponentList."Quantity To Send" <> 0 then begin
                        FillSendCompItemJnlLineAndPost(SubOrderComponentList);
                        SubOrderComponentList."Quantity To Send" := 0;
                    end;

                    if SubOrderComponentList."Qty. for Rework" <> 0 then begin
                        RecieveBackCompRW(SubOrderComponentList);
                        SendAgain(SubOrderComponentList);
                        SubOrderComponentList."Qty. for Rework" := 0;
                    end;

                    SubOrderComponentList.Modify();
                until SubOrderComponentList.Next() = 0;

                PurchaseLine."Qty. to Reject (Rework)" := 0;
                PurchaseLine."Deliver Comp. For" := 0;
                PurchaseLine."Applies-to ID (Delivery)" := '';
                PurchaseLine.Modify();
            until PurchaseLine.Next() = 0;

            Rec.Modify();
            Message(SendConfirmationMsg, DeliveryChallanHeader."No.");

            Rec."Posting Date" := 0D;
            Rec.Modify();
        end else
            Error(NothingtoSendErr);
    end;

    procedure FillSendCompItemJnlLineAndPost(SubOrderCompList: Record "Sub Order Component List")
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingManagement: Codeunit "Item Tracking Management";

        Inbound: Boolean;
        SNRequired: Boolean;
        LotRequired: Boolean;
        SNInfoRequired: Boolean;
        LotInfoRequired: Boolean;
        CheckTrackingLine: Boolean;
        TrackingQtyHandled: Decimal;
        TrackingQtyToHandle: Decimal;
        QuantitySent: Decimal;
    begin
        ItemJnlLine.Init();
        ItemJnlLine."Posting Date" := DeliveryChallanHeader."Challan Date";
        ItemJnlLine."Document Date" := DeliveryChallanHeader."Challan Date";
        ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
        ItemJnlLine."Document No." := SubOrderCompList."Production Order No.";
        ItemJnlLine."External Document No." := DeliveryChallanNo;
        ItemJnlLine."Subcon Order No." := SubconOrderNo;
        ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
        ItemJnlLine."Order No." := SubOrderCompList."Production Order No.";
        ItemJnlLine."Order Line No." := SubOrderCompList."Production Order Line No.";
        ItemJnlLine."Prod. Order Comp. Line No." := SubOrderCompList."Line No.";
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
        ItemJnlLine."Item No." := SubOrderCompList."Item No.";
        ItemJnlLine.Description := SubOrderCompList.Description;
        ItemJnlLine."Gen. Prod. Posting Group" := SubOrderCompList."Gen. Prod. Posting Group";
        ItemJnlLine.Validate("Location Code", SubOrderCompList."Company Location");
        ItemJnlLine.Validate("New Location Code", SubOrderCompList."Vendor Location");
        ItemJnlLine.Validate("Bin Code", SubOrderCompList."Bin Code");
        ItemJnlLine.Quantity := SubOrderCompList."Quantity To Send";
        ItemJnlLine."Unit of Measure Code" := SubOrderCompList."Unit of Measure Code";
        ItemJnlLine."Qty. per Unit of Measure" := SubOrderCompList."Quantity per";
        ItemJnlLine."Invoiced Quantity" := SubOrderCompList."Quantity To Send";
        ItemJnlLine."Unit of Measure Code" := SubOrderCompList."Unit of Measure Code";
        ItemJnlLine."Qty. per Unit of Measure" := SubOrderCompList."Qty. per Unit of Measure";
        ItemJnlLine."Quantity (Base)" := SubOrderCompList."Quantity To Send (Base)";
        ItemJnlLine."Invoiced Qty. (Base)" := SubOrderCompList."Quantity To Send (Base)";

        if SubOrderCompList."Applies-to Entry (Sending)" <> 0 then
            ItemJnlLine."Applies-to Entry" := SubOrderCompList."Applies-to Entry (Sending)";

        Item.Get(SubOrderCompList."Item No.");
        ItemJnlLine."Variant Code" := SubOrderCompList."Variant Code";
        ItemJnlLine."Item Category Code" := Item."Item Category Code";
        ItemJnlLine."Inventory Posting Group" := Item."Inventory Posting Group";
        ItemJnlLine."Gen. Prod. Posting Group" := SubOrderCompList."Gen. Prod. Posting Group";
        SubcontractingPost.GetDimensionsFromPurchaseLine(ItemJnlLine, SubOrderCompList);

        if Item."Item Tracking Code" <> '' then begin
            Inbound := false;
            ItemTrackingCode.Code := Item."Item Tracking Code";
            ItemTrackingManagement.GetItemTrackingSetup(
                ItemTrackingCode,
                ItemJnlLine."Entry Type",
                Inbound,
                ItemTrackingSetup);
            SNRequired := ItemTrackingSetup."Serial No. Required";
            LotRequired := ItemTrackingSetup."Lot No. Required";
            SNInfoRequired := ItemTrackingSetup."Serial No. Info Required";
            LotInfoRequired := ItemTrackingSetup."Lot No. Info Required";

            CheckTrackingLine := (SNRequired = false) and (LotRequired = false);
            QuantitySent := 0;

            if CheckTrackingLine then
                CheckTrackingLine := SubcontractingPost.GetTrackingQuantities(
                    SubOrderCompList,
                    0,
                    SubOrderCompList."Quantity To Send",
                    QuantitySent);
        end else
            CheckTrackingLine := false;

        TrackingQtyToHandle := 0;
        TrackingQtyHandled := 0;

        if CheckTrackingLine then begin
            SubcontractingPost.GetTrackingQuantities(SubOrderCompList, 1, TrackingQtyToHandle, TrackingQtyHandled);
            if ((TrackingQtyHandled + TrackingQtyToHandle) <> SubOrderCompList."Quantity To Send") or
               (TrackingQtyToHandle <> SubOrderCompList."Quantity To Send")
            then
                Error(QtyMismatchErr, SubOrderCompList.FieldCaption("Quantity To Send"));
        end;

        if Item."Item Tracking Code" <> '' then
            SubcontractingPost.TransferTrackingToItemJnlLine(SubOrderCompList, ItemJnlLine, SubOrderCompList."Quantity To Send", 0);

        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
    end;

    procedure PostPurchOrder(MultiSubOrderDet: Record "Multiple Subcon. Order Details")
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchLineToUpdate: Record "Purchase Line";
        Currency: Record Currency;
        PurchPost: Codeunit "Purch.-Post";
    begin
        if not Confirm(PostConfirmationQst) then
            Error('');

        PurchLine.Reset();
        PurchLine.SetCurrentKey("Document Type", "Buy-from Vendor No.", Subcontracting, "Applies-to ID (Receipt)");
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange("Buy-from Vendor No.", MultiSubOrderDet."Subcontractor No.");
        PurchLine.SetRange("Applies-to ID (Receipt)", MultiSubOrderDet."No.");
        PurchLine.SetRange(Subcontracting, true);
        if PurchLine.FindSet() then
            repeat
                PurchLine.Validate("Posting Date", MultiSubOrderDet."Posting Date");
                PurchLine.Validate("Vendor Shipment No.", MultiSubOrderDet."Vendor Shipment No.");
                PurchLine.SubConSend := true;
                PurchLine.Modify();
            until PurchLine.Next() = 0;

        PurchLine.Reset();
        PurchLine.SetCurrentKey("Document Type", "Buy-from Vendor No.", Subcontracting, "Applies-to ID (Receipt)");
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange("Buy-from Vendor No.", MultiSubOrderDet."Subcontractor No.");
        PurchLine.SetRange("Applies-to ID (Receipt)", MultiSubOrderDet."No.");
        PurchLine.SetRange(Subcontracting, true);
        if PurchLine.FindSet() then
            repeat
                PurchHeader.SetRange("Document Type", PurchLine."Document Type");
                PurchHeader.SetRange("No.", PurchLine."Document No.");
                PurchHeader.SetRange("Subcon. Multiple Receipt", false);
                if PurchHeader.FindFirst() then begin
                    if PurchHeader."Currency Code" = '' then
                        Currency.InitRoundingPrecision()
                    else begin
                        PurchHeader.TestField("Currency Factor");
                        Currency.Get(PurchHeader."Currency Code");
                        Currency.TestField("Amount Rounding Precision");
                    end;
                    PurchHeader."Vendor Shipment No." := MultiSubOrderDet."Vendor Shipment No.";
                    PurchHeader.Receive := true;
                    PurchHeader.Invoice := false;
                    PurchHeader.SubConPostLine := PurchLine."Line No.";
                    PurchPost.Run(PurchHeader);
                    PurchHeader.Modify();
                end;
                PurchLineToUpdate.Get(PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.");
                PurchLineToUpdate."Applies-to ID (Receipt)" := '';
                PurchLineToUpdate."Line Discount Amount" := Round(
                    Round(PurchLineToUpdate.Quantity * PurchLineToUpdate."Direct Unit Cost", Currency."Amount Rounding Precision") *
                        PurchLineToUpdate."Line Discount %" / 100,
                        Currency."Amount Rounding Precision");
                PurchLineToUpdate.UpdateAmounts();
                PurchLineToUpdate.Modify();
            until PurchLine.Next() = 0
        else
            Error(NothingtoReceiveErr);
    end;

    procedure CreateDeliveryChallan(var SubOrderComponentList: Record "Sub Order Component List"; PurchLine: Record "Purchase Line")
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        Item: Record Item;
        SubOrderCompListCheck: Record "Sub Order Component List";
        PurchaseHeader: Record "Purchase Header";
        SubcontractingValidations: Codeunit "Subcontracting Validations";
        TotalQty: Decimal;
        UnitCost: Decimal;
    begin
        SubOrderCompListCheck.Copy(SubOrderComponentList);
        if SubOrderCompListCheck.FindSet() then begin
            SubOrderCompListCheck.CalcSums("Quantity To Send", "Qty. for Rework");
            TotalQty := SubOrderCompListCheck."Quantity To Send" + SubOrderCompListCheck."Qty. for Rework";
        end;

        if TotalQty = 0 then
            Error(NothingtoSendDocErr, PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.");

        SubOrderComponentList.FindSet();

        DeliveryChallanHeader."Quantity for rework" += PurchLine."Qty. to Reject (Rework)";
        if DeliveryChallanLine.FindLast() then
            NextlineNo := DeliveryChallanLine."Line No." + 10000
        else
            NextlineNo := 10000;
        repeat
            // Update missing dimension set id from purchase line
            if (PurchLine."Dimension Set ID" <> 0) and (SubOrderComponentList."Dimension Set ID" = 0) then begin
                SubOrderComponentList.Validate("Dimension Set ID", PurchLine."Dimension Set ID");
                SubOrderComponentList.Modify(true);
            end;
            DeliveryChallanLine.Reset();
            DeliveryChallanLine.SetRange("Delivery Challan No.", DeliveryChallanHeader."No.");

            Item.Get(SubOrderComponentList."Item No.");

            DeliveryChallanLine.Init();
            DeliveryChallanLine."Delivery Challan No." := DeliveryChallanHeader."No.";
            DeliveryChallanLine."Document No." := PurchLine."Document No.";
            DeliveryChallanLine."Document Line No." := PurchLine."Line No.";
            DeliveryChallanLine."Posting Date" := DeliveryChallanHeader."Challan Date";
            DeliveryChallanLine."Line No." := NextlineNo;
            DeliveryChallanLine."Vendor No." := PurchLine."Buy-from Vendor No.";
            DeliveryChallanLine."Parent Item No." := SubOrderComponentList."Parent Item No.";
            DeliveryChallanLine."Item No." := SubOrderComponentList."Item No.";
            DeliveryChallanLine."Unit of Measure" := SubOrderComponentList."Unit of Measure Code";
            DeliveryChallanLine.Description := SubOrderComponentList.Description;
            DeliveryChallanLine."Scrap %" := SubOrderComponentList."Scrap %";
            DeliveryChallanLine."Variant Code" := SubOrderComponentList."Variant Code";
            DeliveryChallanLine."Quantity per" := SubOrderComponentList."Quantity per";
            DeliveryChallanLine."Company Location" := SubOrderComponentList."Company Location";
            DeliveryChallanLine."Vendor Location" := SubOrderComponentList."Vendor Location";
            DeliveryChallanLine."Production Order No." := SubOrderComponentList."Production Order No.";
            DeliveryChallanLine."Production Order Line No." := SubOrderComponentList."Production Order Line No.";
            DeliveryChallanLine."Line Type" := SubOrderComponentList."Line Type";
            DeliveryChallanLine."Gen. Prod. Posting Group" := SubOrderComponentList."Gen. Prod. Posting Group";
            DeliveryChallanLine."Total Scrap Quantity" := SubOrderComponentList."Total Scrap Quantity";
            DeliveryChallanLine.Quantity := SubOrderComponentList."Quantity To Send";
            DeliveryChallanLine."Components in Rework Qty." := SubOrderComponentList."Qty. for Rework";
            DeliveryChallanLine."Prod. BOM Quantity" := SubOrderComponentList."Prod. Order Qty.";
            DeliveryChallanLine."Process Description" := PurchLine.Description;
            DeliveryChallanLine."Prod. Order Comp. Line No." := SubOrderComponentList."Line No.";
            DeliveryChallanLine."Job Work Return Period" := SubOrderComponentList."Job Work Return Period";
            DeliveryChallanLine."Last Date" := DeliveryChallanLine."Posting Date" + DeliveryChallanLine."Job Work Return Period" - 1;
            DeliveryChallanLine."Identification Mark" := SubOrderComponentList."Identification Mark";
            DeliveryChallanLine."Dimension Set ID" := SubOrderComponentList."Dimension Set ID";
            DeliveryChallanLine."Job Work Return Period" := SubOrderComponentList."Job Work Return Period";
            DeliveryChallanLine."Last Date" := DeliveryChallanLine."Posting Date" + DeliveryChallanLine."Job Work Return Period" - 1;
            DeliveryChallanLine."GST Group Code" := Item."GST Group Code";
            DeliveryChallanLine."HSN/SAC Code" := Item."HSN/SAC Code";
            DeliveryChallanLine."GST Credit" := Item."GST Credit";
            DeliveryChallanLine.Exempted := Item.Exempted;
            DeliveryChallanLine."GST Jurisdiction Type" := PurchLine."GST Jurisdiction Type";

            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DeliveryChallanLine."Document No.") then begin
                DeliveryChallanLine."Location State Code" := PurchaseHeader."Location State Code";
                DeliveryChallanLine."Location GST Reg. No." := PurchaseHeader."Location GST Reg. No.";
                DeliveryChallanLine."GST Vendor Type" := PurchaseHeader."GST Vendor Type";
                DeliveryChallanLine."Vendor State Code" := PurchaseHeader.State;
                DeliveryChallanLine."Vendor GST Reg. No." := PurchaseHeader."Vendor GST Reg. No.";
            end;

            UnitCost := 0;
            UnitCost := SubcontractingValidations.GetProdOrderCompUnitCost(
                DeliveryChallanLine."Production Order No.",
                DeliveryChallanLine."Production Order Line No.",
                DeliveryChallanLine."Item No.");
            if UnitCost = 0 then
                Error(UnitCostErr, DeliveryChallanLine."Item No.");

            DeliveryChallanLine.Validate("GST Base Amount", (UnitCost * DeliveryChallanLine."Quantity"));
            DeliveryChallanLine."Total GST Amount" := SubcontractingValidations.GetTotalGSTAmount(DeliveryChallanLine.RecordId);
            DeliveryChallanLine."GST Amount Remaining" := DeliveryChallanLine."Total GST Amount";

            DeliveryChallanLine.Insert(true);
            NextlineNo += 10000;
        until SubOrderComponentList.Next() = 0;
    end;

    procedure RecieveBackCompRW(SubOrderCompList: Record "Sub Order Component List")
    var
        CompItem: Record Item;
        ItemledgerEntry: Record "Item Ledger Entry";
        CopyItemLedgerEntry: Record "Item Ledger Entry";
        SubOrderCompVend: Record "Sub Order Comp. List Vend";
        RemQtytoPost: Decimal;
        TotalQtyToPost: Decimal;
        Completed: Boolean;
        AvailableQty: Decimal;
    begin
        SubOrderCompVend.Reset();
        SubOrderCompVend.SetRange("Production Order No.", SubOrderComponentList."Production Order No.");
        SubOrderCompVend.SetRange("Production Order Line No.", SubOrderComponentList."Production Order Line No.");
        SubOrderCompVend.SetRange("Line No.", SubOrderComponentList."Line No.");
        if SubOrderCompVend.IsEmpty() then
            Error(SubConVendCompErr,
                SubOrderCompList."Production Order No.",
                SubOrderCompList."Production Order Line No.",
                SubOrderCompList."Line No.");

        SourceCodeSetup.Get();
        CompItem.Get(SubOrderComponentList."Item No.");
        CompItem.TestField("Rounding Precision");

        TotalQtyToPost := Round(SubOrderComponentList."Qty. for Rework" * SubOrderComponentList."Qty. per Unit of Measure", 0.00001);
        TotalQtyToPost := Round(TotalQtyToPost, CompItem."Rounding Precision", '>');
        RemQtytoPost := TotalQtyToPost;

        ItemledgerEntry.Reset();
        ItemledgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Prod. Order Comp. Line No.", "Entry Type", "Location Code");
        ItemledgerEntry.SetRange("Order Type", ItemledgerEntry."Order Type"::Production);
        ItemledgerEntry.SetRange("Order No.", SubOrderComponentList."Production Order No.");
        ItemledgerEntry.SetRange("Order Line No.", SubOrderComponentList."Production Order Line No.");
        ItemledgerEntry.SetRange("Prod. Order Comp. Line No.", SubOrderComponentList."Line No.");
        ItemledgerEntry.SetRange("Entry Type", ItemledgerEntry."Entry Type"::Transfer);
        ItemledgerEntry.SetRange("Location Code", SubOrderComponentList."Vendor Location");

        CopyItemLedgerEntry.Copy(ItemledgerEntry);
        if CopyItemLedgerEntry.FindSet() then begin
            CopyItemLedgerEntry.CalcSums("Remaining Quantity");
            AvailableQty := CopyItemLedgerEntry."Remaining Quantity";
        end;

        if AvailableQty < TotalQtyToPost then
            Error(NotEnoughInventoryErr);

        if ItemledgerEntry.FindSet() then
            repeat
                ItemJnlLine.Init();
                ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
                ItemJnlLine.Validate("Posting Date", DeliveryChallanHeader."Challan Date");
                ItemJnlLine."Document No." := SubOrderComponentList."Production Order No.";
                ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
                ItemJnlLine."Source No." := SubOrderComponentList."Item No.";
                ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
                ItemJnlLine."Order No." := SubOrderComponentList."Production Order No.";
                ItemJnlLine."Order Line No." := SubOrderComponentList."Production Order Line No.";
                ItemJnlLine.Validate("Prod. Order Comp. Line No.", SubOrderComponentList."Line No.");
                ItemJnlLine.Validate("Item No.", SubOrderComponentList."Item No.");
                ItemJnlLine.Validate("Unit of Measure Code", SubOrderComponentList."Unit of Measure Code");
                ItemJnlLine.Description := SubOrderComponentList.Description;

                if ItemledgerEntry."Remaining Quantity" <> 0 then begin
                    if RemQtytoPost > ItemledgerEntry."Remaining Quantity" then begin
                        RemQtytoPost -= ItemledgerEntry."Remaining Quantity";
                        ItemJnlLine.Validate(Quantity, ItemledgerEntry."Remaining Quantity");
                    end else begin
                        ItemJnlLine.Validate(Quantity, RemQtytoPost);
                        Completed := true;
                    end;

                    ItemJnlLine.Validate("Applies-to Entry", ItemledgerEntry."Entry No.");
                    ItemJnlLine."Location Code" := SubOrderComponentList."Vendor Location";
                    ItemJnlLine."New Location Code" := SubOrderComponentList."Company Location";
                    ItemJnlLine."Variant Code" := SubOrderComponentList."Variant Code";
                    ItemJnlLine."Gen. Prod. Posting Group" := CompItem."Gen. Prod. Posting Group";
                    ItemJnlLine."Item Category Code" := CompItem."Item Category Code";
                    ItemJnlLine."Inventory Posting Group" := CompItem."Inventory Posting Group";

                    ItemJnlPostLine.RunWithCheck(ItemJnlLine);
                end;
            until (ItemledgerEntry.Next() = 0) or Completed;
    end;

    procedure SendAgain(SubOrderCompList: Record "Sub Order Component List")
    var
        CompItem: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        RemQtytoPost: Decimal;
        TotalQtyToPost: Decimal;
        Completed: Boolean;
    begin
        SourceCodeSetup.Get();
        CompItem.Get(SubOrderComponentList."Item No.");
        CompItem.TestField("Rounding Precision");
        TotalQtyToPost := Round(SubOrderComponentList."Qty. for Rework" * SubOrderComponentList."Qty. per Unit of Measure", 0.00001);
        TotalQtyToPost := Round(TotalQtyToPost, CompItem."Rounding Precision", '>');
        RemQtytoPost := TotalQtyToPost;

        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Prod. Order Comp. Line No.", "Entry Type", "Location Code");
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", SubOrderComponentList."Production Order No.");
        ItemLedgerEntry.SetRange("Order Line No.", SubOrderComponentList."Production Order Line No.");
        ItemLedgerEntry.SetRange("Prod. Order Comp. Line No.", SubOrderComponentList."Line No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Location Code", SubOrderComponentList."Company Location");
        ItemLedgerEntry.SetCurrentKey("Entry No.");
        ItemLedgerEntry.Ascending := true;
        if ItemLedgerEntry.FindSet() then
            repeat
                ItemJnlLine.Init();
                ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
                ItemJnlLine.Validate("Posting Date", DeliveryChallanHeader."Challan Date");
                ItemJnlLine."Document No." := SubOrderComponentList."Production Order No.";
                ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
                ItemJnlLine."Source No." := SubOrderComponentList."Item No.";
                ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
                ItemJnlLine."Order No." := SubOrderComponentList."Production Order No.";
                ItemJnlLine."Order Line No." := SubOrderComponentList."Production Order Line No.";
                ItemJnlLine."External Document No." := DeliveryChallanNo;
                ItemJnlLine.Validate("Prod. Order Comp. Line No.", SubOrderComponentList."Line No.");
                ItemJnlLine.Validate("Item No.", SubOrderComponentList."Item No.");
                ItemJnlLine.Validate("Unit of Measure Code", SubOrderComponentList."Unit of Measure Code");
                ItemJnlLine.Description := SubOrderComponentList.Description;

                if ItemLedgerEntry."Remaining Quantity" <> 0 then begin
                    if RemQtytoPost > ItemLedgerEntry."Remaining Quantity" then begin
                        RemQtytoPost -= ItemLedgerEntry."Remaining Quantity";
                        ItemJnlLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity");
                    end else begin
                        ItemJnlLine.Validate(Quantity, RemQtytoPost);
                        Completed := true;
                    end;

                    ItemJnlLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");
                    ItemJnlLine."Location Code" := SubOrderComponentList."Company Location";
                    ItemJnlLine."New Location Code" := SubOrderComponentList."Vendor Location";
                    ItemJnlLine."Variant Code" := SubOrderComponentList."Variant Code";
                    ItemJnlLine."Gen. Prod. Posting Group" := CompItem."Gen. Prod. Posting Group";
                    ItemJnlLine."Item Category Code" := CompItem."Item Category Code";
                    ItemJnlLine."Inventory Posting Group" := CompItem."Inventory Posting Group";
                    SubcontractingPost.GetDimensionsFromPurchaseLine(ItemJnlLine, SubOrderComponentList);

                    ItemJnlPostLine.RunWithCheck(ItemJnlLine);
                end;
            until (ItemLedgerEntry.Next() = 0) or Completed;
    end;

    procedure UpdateExciseInChallan(DeliveryChallanHeader: Record "Delivery Challan Header"; DocNo: Code[20]; LineNo: Integer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        DeliveryChallanLine: Record "Delivery Challan Line";
    begin
        DeliveryChallanLine.Reset();
        DeliveryChallanLine.SetRange("Delivery Challan No.", DeliveryChallanHeader."No.");
        DeliveryChallanLine.SetRange("Document No.", DocNo);
        DeliveryChallanLine.SetRange("Document Line No.", LineNo);
        if DeliveryChallanLine.FindSet() then
            repeat
                ItemLedgerEntry.SetCurrentKey("Entry Type", "Location Code", "External Document No.", "Item No.");
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
                ItemLedgerEntry.SetRange("Location Code", DeliveryChallanLine."Vendor Location");
                ItemLedgerEntry.SetRange("External Document No.", DeliveryChallanLine."Delivery Challan No.");
                ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
                ItemLedgerEntry.SetRange("Order No.", DeliveryChallanLine."Production Order No.");
                ItemLedgerEntry.SetRange("Order Line No.", DeliveryChallanLine."Production Order Line No.");
                ItemLedgerEntry.SetRange("Item No.", DeliveryChallanLine."Item No.");
                if ItemLedgerEntry.FindSet() then
                    repeat
                        DeliveryChallanLine.UpdateChallanLine(DeliveryChallanLine);
                    until ItemLedgerEntry.Next() = 0;
            until DeliveryChallanLine.Next() = 0;
    end;

    procedure CreateDeliveryChallanHeader(PostingDate: Date)
    begin
        DeliveryChallanHeader.Init();
        DeliveryChallanHeader."No." := '';
        DeliveryChallanHeader."Challan Date" := PostingDate;
        DeliveryChallanHeader."Posting Date" := PostingDate;
        DeliveryChallanHeader."Vendor No." := BuyfromVendorNo;
        Vendor.Get(DeliveryChallanHeader."Vendor No.");
        DeliveryChallanHeader."Commissioner's Permission No." := Vendor."Commissioner's Permission No.";
        DeliveryChallanHeader.Insert(true);
        DeliveryChallanNo := DeliveryChallanHeader."No.";
    end;

    procedure CheckQuantitytoSendReceive(SubconHeaderNo: Code[20]; Delivery: Boolean)
    var
        PurchLine: Record "Purchase Line";
        TotalQty: Decimal;
    begin
        PurchLine.Reset();
        PurchLine.SetCurrentKey("Document Type", "Buy-from Vendor No.", Subcontracting, "Applies-to ID (Delivery)");
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange("Buy-from Vendor No.", BuyfromVendorNo);
        PurchLine.SetRange(Subcontracting, true);
        if Delivery then
            PurchLine.SetRange("Applies-to ID (Delivery)", SubconHeaderNo)
        else
            PurchLine.SetRange("Applies-to ID (Receipt)", SubconHeaderNo);

        if Delivery then begin
            PurchLine.CalcSums("Deliver Comp. For");
            TotalQty := PurchLine."Deliver Comp. For";
            if TotalQty = 0 then
                Error(NothingtoSendErr)
        end else begin
            PurchLine.CalcSums("Qty. to Receive");
            TotalQty := PurchLine."Qty. to Receive";
            if TotalQty = 0 then
                Error(NothingtoReceiveErr)
        end;
    end;
}
