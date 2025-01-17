// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Tracking;

table 18466 "Applied Delivery Challan"
{
    Caption = 'Applied Delivery Challan';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(2; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; "Applied Delivery Challan No."; Code[20])
        {
            Caption = 'Applied Delivery Challan No.';
            Editable = false;
            TableRelation = "Delivery Challan Header";
            DataClassification = CustomerContent;
        }
        field(4; "App. Delivery Challan Line No."; Integer)
        {
            Caption = 'App. Delivery Challan Line No.';
            TableRelation = "Delivery Challan Line"."Line No.";
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                DeliveryChallanLine1: Record "Delivery Challan Line";
                ItemLedgerEntry: Record "Item Ledger Entry";
                DeliveryChallanLineList: Page "Delivery Challan Line";
            begin
                DeliveryChallanLine.Reset();
                DeliveryChallanLine.SetRange("Document No.", "Document No.");
                DeliveryChallanLine.SetRange("Document Line No.", "Document Line No.");
                DeliveryChallanLine.SetRange("Parent Item No.", "Parent Item No.");
                DeliveryChallanLine.SetRange("Item No.", "Item No.");
                DeliveryChallanLine.SetFilter("Remaining Quantity", '<>0');
                DeliveryChallanLineList.SetTableView(DeliveryChallanLine);
                DeliveryChallanLineList.LookupMode := true;
                if DeliveryChallanLineList.RunModal() = Action::LookupOK then begin
                    DeliveryChallanLineList.GetRecord(DeliveryChallanLine1);
                    DeliveryChallanLine1.CalcFields("Remaining Quantity");

                    if (DeliveryChallanLine1."Remaining Quantity" <
                        ("Qty. to Receive" + "Qty. to Consume" + "Qty. to Return (C.E.)" + "Qty. To Return (V.E.)"))
                    then
                        Error(RemainingQtyErr);

                    ItemLedgerEntry.Reset();
                    ItemLedgerEntry.SetCurrentKey("Entry Type", "Location Code", "External Document No.", "Item No.");
                    ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
                    ItemLedgerEntry.SetRange("Location Code", DeliveryChallanLine1."Vendor Location");
                    ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
                    ItemLedgerEntry.SetRange("Order No.", DeliveryChallanLine1."Production Order No.");
                    ItemLedgerEntry.SetRange("Order Line No.", DeliveryChallanLine1."Production Order Line No.");
                    ItemLedgerEntry.SetRange("External Document No.", DeliveryChallanLine1."Delivery Challan No.");
                    ItemLedgerEntry.SetRange("Item No.", "Item No.");
                    if ItemLedgerEntry.FindFirst() then
                        "Applies-to Entry" := ItemLedgerEntry."Entry No."
                    else
                        Error(ItemErr, "Item No.", DeliveryChallanLine."Delivery Challan No.");

                    "Applied Delivery Challan No." := DeliveryChallanLine1."Delivery Challan No.";
                    "App. Delivery Challan Line No." := DeliveryChallanLine1."Line No.";
                    "Job Work Return Period" := DeliveryChallanLine1."Job Work Return Period";
                end;
            end;
        }
        field(5; "Parent Item No."; Code[20])
        {
            Caption = 'Parent Item No.';
            Editable = false;
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(8; "Production Order No."; Code[20])
        {
            Caption = 'Production Order No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(9; "Production Order Line No."; Integer)
        {
            Caption = 'Production Order Line No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; "Qty. to Receive"; Decimal)
        {
            Caption = 'Qty. to Receive';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record "Item";
                Type_: Enum "Subcon Type";
            begin
                if "Applied Delivery Challan No." <> '' then
                    FilterDeliveryChallanLine();

                Item.Get("Item No.");
                if Item."Item Tracking Code" <> '' then begin
                    VerifyQuantity(Rec, xRec, Type_::Receive);
                    if ("Qty. to Receive" <> xRec."Qty. to Receive") and ("Qty. to Receive" = 0) then
                        DeleteAppDelChEntryType(Rec, Type_::Receive);
                end;
            end;
        }
        field(11; "Qty. to Consume"; Decimal)
        {
            Caption = 'Qty. to Consume';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
                Type_: Enum "Subcon Type";
            begin
                if "Applied Delivery Challan No." <> '' then
                    FilterDeliveryChallanLine();

                Item.Get("Item No.");

                if Item."Item Tracking Code" <> '' then begin
                    VerifyQuantity(Rec, xRec, Type_::Consume);

                    if ("Qty. to Consume" <> xRec."Qty. to Consume") and ("Qty. to Consume" = 0) then
                        DeleteAppDelChEntryType(Rec, Type_::Consume);
                end;
            end;
        }
        field(12; "Qty. to Return (C.E.)"; Decimal)
        {
            Caption = 'Qty. to Return (C.E.)';
            DecimalPlaces = 0 : 3;
            Editable = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
                Type_: Enum "Subcon Type";
            begin
                if "Applied Delivery Challan No." <> '' then
                    FilterDeliveryChallanLine();

                Item.Get("Item No.");

                if Item."Item Tracking Code" <> '' then begin
                    VerifyQuantity(Rec, xRec, Type_::RejectCE);

                    if ("Qty. to Return (C.E.)" <> xRec."Qty. to Return (C.E.)") and ("Qty. to Return (C.E.)" = 0) then
                        DeleteAppDelChEntryType(Rec, Type_::RejectCE);
                end;
            end;
        }
        field(13; "Qty. To Return (V.E.)"; Decimal)
        {
            Caption = 'Qty. To Return (V.E.)';
            DecimalPlaces = 0 : 3;
            Editable = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
                Type_: Enum "Subcon Type";
            begin
                if "Applied Delivery Challan No." <> '' then
                    FilterDeliveryChallanLine();

                Item.Get("Item No.");

                if Item."Item Tracking Code" <> '' then begin
                    VerifyQuantity(Rec, xRec, Type_::RejectVE);

                    if ("Qty. To Return (V.E.)" <> xRec."Qty. To Return (V.E.)") and ("Qty. To Return (V.E.)" = 0) then
                        DeleteAppDelChEntryType(Rec, Type_::RejectVE);
                end;
            end;
        }
        field(14; "Applies-to Entry"; Integer)
        {
            BlankZero = true;
            Caption = 'Applies-to Entry';
            Editable = false;
            TableRelation = "Item Ledger Entry";
            DataClassification = CustomerContent;
        }
        field(15; "Job Work Return Period"; Integer)
        {
            Caption = 'Job Work Return Period';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1;
        "Document No.",
            "Document Line No.",
            "Parent Item No.",
            "Line No.",
            "Item No.",
            "Applied Delivery Challan No.",
            "App. Delivery Challan Line No.")
        {
            Clustered = true;
            SumIndexFields = "Qty. to Receive", "Qty. to Consume", "Qty. to Return (C.E.)", "Qty. To Return (V.E.)";
        }
    }

    trigger OnDelete()
    begin
        DeleteAppDelChLnEntry(Rec);
    end;

    trigger OnInsert()
    var
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        SubOrderCompListVend.Reset();
        SubOrderCompListVend.SetRange("Document No.", "Document No.");
        SubOrderCompListVend.SetRange("Document Line No.", "Document Line No.");
        SubOrderCompListVend.SetRange("Parent Item No.", "Parent Item No.");
        SubOrderCompListVend.SetRange("Line No.", "Line No.");
        if SubOrderCompListVend.FindFirst() then begin
            "Production Order No." := SubOrderCompListVend."Production Order No.";
            "Production Order Line No." := SubOrderCompListVend."Production Order Line No.";
        end;

        DeliveryChallanLine.Reset();
        DeliveryChallanLine.SetRange("Delivery Challan No.", "Applied Delivery Challan No.");
        DeliveryChallanLine.SetRange("Line No.", "App. Delivery Challan Line No.");
        if not DeliveryChallanLine.FindFirst() then
            Error(DeliveryChallanErr);

        "Job Work Return Period" := DeliveryChallanLine."Job Work Return Period";

        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Location Code", "External Document No.", "Item No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Location Code", DeliveryChallanLine."Vendor Location");
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", DeliveryChallanLine."Production Order No.");
        ItemLedgerEntry.SetRange("Order Line No.", DeliveryChallanLine."Production Order Line No.");
        ItemLedgerEntry.SetRange("External Document No.", DeliveryChallanLine."Delivery Challan No.");
        ItemLedgerEntry.SetRange("Item No.", "Item No.");
        if ItemLedgerEntry.FindFirst() then
            "Applies-to Entry" := ItemLedgerEntry."Entry No."
        else
            Error(ItemErr, "Item No.", DeliveryChallanLine."Delivery Challan No.");
    end;

    trigger OnModify()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        DeliveryChallanLine.Reset();
        DeliveryChallanLine.SetRange("Delivery Challan No.", "Applied Delivery Challan No.");
        DeliveryChallanLine.SetRange("Line No.", "App. Delivery Challan Line No.");
        if not DeliveryChallanLine.FindFirst() then
            Error(DeliveryChallanErr);

        "Job Work Return Period" := DeliveryChallanLine."Job Work Return Period";

        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Location Code", "External Document No.", "Item No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Location Code", DeliveryChallanLine."Vendor Location");
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", DeliveryChallanLine."Production Order No.");
        ItemLedgerEntry.SetRange("Order Line No.", DeliveryChallanLine."Production Order Line No.");
        ItemLedgerEntry.SetRange("External Document No.", DeliveryChallanLine."Delivery Challan No.");
        ItemLedgerEntry.SetRange("Item No.", "Item No.");
        if ItemLedgerEntry.FindFirst() then
            "Applies-to Entry" := ItemLedgerEntry."Entry No."
        else
            Error(ItemErr, "Item No.", DeliveryChallanLine."Delivery Challan No.");
    end;

    trigger OnRename()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        AppDelChEntry: Record "Applied Delivery Challan Entry";
    begin
        DeliveryChallanLine.Reset();
        DeliveryChallanLine.SetRange("Delivery Challan No.", "Applied Delivery Challan No.");
        DeliveryChallanLine.SetRange("Line No.", "App. Delivery Challan Line No.");
        if not DeliveryChallanLine.FindFirst() then
            Error(DeliveryChallanErr);

        "Job Work Return Period" := DeliveryChallanLine."Job Work Return Period";

        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Location Code", "External Document No.", "Item No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Location Code", DeliveryChallanLine."Vendor Location");
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", DeliveryChallanLine."Production Order No.");
        ItemLedgerEntry.SetRange("Order Line No.", DeliveryChallanLine."Production Order Line No.");
        ItemLedgerEntry.SetRange("External Document No.", DeliveryChallanLine."Delivery Challan No.");
        ItemLedgerEntry.SetRange("Item No.", "Item No.");
        if ItemLedgerEntry.FindFirst() then
            "Applies-to Entry" := ItemLedgerEntry."Entry No."
        else
            Error(ItemErr, "Item No.", DeliveryChallanLine."Delivery Challan No.");

        AppDelChEntry.Reset();
        AppDelChEntry.SetRange("Document No.", xRec."Document No.");
        AppDelChEntry.SetRange("Document Line No.", xRec."Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", xRec."Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", xRec."App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", xRec."Parent Item No.");
        AppDelChEntry.SetRange("Line No.", xRec."Line No.");
        AppDelChEntry.SetRange("Item No.", xRec."Item No.");
        if AppDelChEntry.FindSet() then
            repeat
                AppDelChEntry."Document No." := "Document No.";
                AppDelChEntry."Document Line No." := "Document Line No.";
                AppDelChEntry."Applied Delivery Challan No." := "Applied Delivery Challan No.";
                AppDelChEntry."App. Delivery Challan Line No." := "App. Delivery Challan Line No.";
                AppDelChEntry."Parent Item No." := "Parent Item No.";
                AppDelChEntry."Line No." := "Line No.";
                AppDelChEntry."Item No." := "Item No.";
                AppDelChEntry.Modify();
            until AppDelChEntry.Next() = 0;
    end;

    procedure FilterDeliveryChallanLine()
    begin
        if DeliveryChallanLine.Get("Applied Delivery Challan No.", "App. Delivery Challan Line No.") then begin
            DeliveryChallanLine.CalcFields("Remaining Quantity");
            if (DeliveryChallanLine."Remaining Quantity") <
               ("Qty. to Receive" + "Qty. to Consume" + "Qty. to Return (C.E.)" + "Qty. To Return (V.E.)")
            then
                Error(RemainingQtyErr)
        end;
    end;

    procedure InitTrackingSpecification(
        var TrackingSpecification: Record "Tracking Specification";
        Type_: Option Consume,RejectVE,RejectCE,Receive,Rework; Quantity_: Decimal)
    var
        DeliveryChallanLn: Record "Delivery Challan Line";
        Item: Record Item;
        AppDelChEntry: Record "Applied Delivery Challan Entry";
    begin
        DeliveryChallanLn.Get("Applied Delivery Challan No.", "App. Delivery Challan Line No.");
        Item.Get("Item No.");

        AppDelChEntry.Reset();
        AppDelChEntry.SetRange("Document No.", "Document No.");
        AppDelChEntry.SetRange("Document Line No.", "Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", "Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", "App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", "Parent Item No.");
        AppDelChEntry.SetRange("Line No.", "Line No.");
        AppDelChEntry.SetRange("Item No.", "Item No.");
        AppDelChEntry.SetRange("Type of Quantity", Type_);
        if AppDelChEntry.FindFirst() then begin
            TrackingSpecification.Init();
            TrackingSpecification."Source Type" := Database::"Applied Delivery Challan Entry";
            TrackingSpecification."Item No." := "Item No.";
            TrackingSpecification."Location Code" := DeliveryChallanLn."Vendor Location";
            TrackingSpecification.Description := Item.Description;
            TrackingSpecification."Variant Code" := DeliveryChallanLn."Variant Code";
            TrackingSpecification."Source ID" := '';
            TrackingSpecification."Source Batch Name" := '';
            TrackingSpecification."Source Prod. Order Line" := 0;
            TrackingSpecification."Source Ref. No." := AppDelChEntry."Entry No.";
            TrackingSpecification."Quantity (Base)" := Quantity_;
            TrackingSpecification."Qty. to Handle" := Quantity_;
            TrackingSpecification."Qty. to Handle (Base)" := Quantity_;
            TrackingSpecification."Qty. to Invoice" := Quantity_;
            TrackingSpecification."Qty. to Invoice (Base)" := Quantity_;
            TrackingSpecification."Quantity Handled (Base)" := 0;
            TrackingSpecification."Quantity Invoiced (Base)" := 0;
            TrackingSpecification."Qty. per Unit of Measure" := DeliveryChallanLn."Quantity per";
        end;
    end;

    procedure OpenItemTrackingLinesSubcon(Type_: Option Consume,RejectVE,RejectCE,Receive,Rework)
    var
        TrackingSpecification: Record "Tracking Specification";
        ApplyDeliveryChallanMgt: Codeunit "Apply Delivery Challan Mgt.";
        ItemTrackingForm: Page "Item Tracking Lines";
    begin
        TestField("Item No.");
        case Type_ of
            Type_::Consume:
                begin
                    TestField("Qty. to Consume");
                    InsertAppDelChLnEntry("Qty. to Consume", Type_::Consume);
                    InitTrackingSpecification(TrackingSpecification, Type_::Consume, "Qty. to Consume");
                end;
            Type_::RejectVE:
                begin
                    TestField("Qty. To Return (V.E.)");
                    InsertAppDelChLnEntry("Qty. To Return (V.E.)", Type_::RejectVE);
                    InitTrackingSpecification(TrackingSpecification, Type_::RejectVE, "Qty. To Return (V.E.)");
                end;
            Type_::RejectCE:
                begin
                    TestField("Qty. to Return (C.E.)");
                    InsertAppDelChLnEntry("Qty. to Return (C.E.)", Type_::RejectCE);
                    InitTrackingSpecification(TrackingSpecification, Type_::RejectCE, "Qty. to Return (C.E.)");
                end;
            Type_::Receive:
                begin
                    TestField("Qty. to Receive");
                    InsertAppDelChLnEntry("Qty. to Receive", Type_::Receive);
                    InitTrackingSpecification(TrackingSpecification, Type_::Receive, "Qty. to Receive");
                end;
        end;

        Clear(ItemTrackingForm);
        ApplyDeliveryChallanMgt.SetAppDelChallan(true, "Applied Delivery Challan No.");
        ItemTrackingForm.SetSourceSpec(TrackingSpecification, WorkDate());
        ItemTrackingForm.RunModal();
        ApplyDeliveryChallanMgt.SetAppDelChallan(false, '');
    end;

    procedure InsertAppDelChLnEntry(Quantity_: Decimal; Type_: Option Consume,RejectVE,RejectCE,Receive,Rework)
    var
        AppDelChEntry: Record "Applied Delivery Challan Entry";
        EntryNo: Integer;
    begin
        AppDelChEntry.Reset();
        AppDelChEntry.SetRange("Document No.", "Document No.");
        AppDelChEntry.SetRange("Document Line No.", "Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", "Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", "App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", "Parent Item No.");
        AppDelChEntry.SetRange("Line No.", "Line No.");
        AppDelChEntry.SetRange("Item No.", "Item No.");
        AppDelChEntry.SetRange("Type of Quantity", Type_);
        if AppDelChEntry.FindFirst() then begin
            AppDelChEntry.Quantity := Quantity_;
            AppDelChEntry.Modify();
        end else begin
            AppDelChEntry.Reset();
            if AppDelChEntry.FindLast() then
                EntryNo := AppDelChEntry."Entry No." + 1
            else
                EntryNo := 1;

            AppDelChEntry.Init();
            AppDelChEntry."Entry No." := EntryNo;
            AppDelChEntry."Document No." := "Document No.";
            AppDelChEntry."Document Line No." := "Document Line No.";
            AppDelChEntry."Applied Delivery Challan No." := "Applied Delivery Challan No.";
            AppDelChEntry."App. Delivery Challan Line No." := "App. Delivery Challan Line No.";
            AppDelChEntry."Parent Item No." := "Parent Item No.";
            AppDelChEntry."Line No." := "Line No.";
            AppDelChEntry."Item No." := "Item No.";
            AppDelChEntry.Quantity := Quantity_;
            AppDelChEntry."Type of Quantity" := Type_;
            AppDelChEntry.Insert();
        end;
        Commit();
    end;

    procedure DeleteAppDelChLnEntry(AppliedDeliveryChallan: Record "Applied Delivery Challan")
    var
        AppDelChEntry: Record "Applied Delivery Challan Entry";
    begin
        AppDelChEntry.Reset();
        AppDelChEntry.SetRange("Document No.", AppliedDeliveryChallan."Document No.");
        AppDelChEntry.SetRange("Document Line No.", AppliedDeliveryChallan."Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", AppliedDeliveryChallan."Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", AppliedDeliveryChallan."Parent Item No.");
        AppDelChEntry.SetRange("Line No.", AppliedDeliveryChallan."Line No.");
        AppDelChEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        AppDelChEntry.DeleteAll();
    end;

    procedure DeleteLine(var AppliedDeliveryChallan: Record "Applied Delivery Challan")
    var
        AppDelChEntry: Record "Applied Delivery Challan Entry";
        ReservMgt: Codeunit "Reservation Management";
        ApplyDeliveryChallanMgt: Codeunit "Apply Delivery Challan Mgt.";
    begin
        AppDelChEntry.Reset();
        AppDelChEntry.SetRange("Document No.", AppliedDeliveryChallan."Document No.");
        AppDelChEntry.SetRange("Document Line No.", AppliedDeliveryChallan."Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", AppliedDeliveryChallan."Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", AppliedDeliveryChallan."Parent Item No.");
        AppDelChEntry.SetRange("Line No.", AppliedDeliveryChallan."Line No.");
        AppDelChEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        if AppDelChEntry.FindSet() then
            repeat
                ApplyDeliveryChallanMgt.SetAppliedDeliveryChallanEntry(AppDelChEntry);
                if DeleteItemTracking then
                    ReservMgt.SetItemTrackingHandling(1);

                ReservMgt.DeleteReservEntries(true, 0);
            until AppDelChEntry.Next() = 0;
    end;

    procedure DeleteLineConfirm(var AppliedDeliveryChallan: Record "Applied Delivery Challan"): Boolean
    var
        OldReservEntry: Record "Reservation Entry";
        AppDelChEntry: Record "Applied Delivery Challan Entry";
        ReservMgt: Codeunit "Reservation Management";
        TypeQty: Option Consume,RejectVE,RejectCE,Receive,Rework;
    begin
        OldReservEntry.Reset();
        if ((not ReservEntryExist(AppliedDeliveryChallan, OldReservEntry, 0, TypeQty::Consume)) and
            (not ReservEntryExist(AppliedDeliveryChallan, OldReservEntry, 0, TypeQty::RejectVE)) and
            (not ReservEntryExist(AppliedDeliveryChallan, OldReservEntry, 0, TypeQty::RejectCE)) and
            (not ReservEntryExist(AppliedDeliveryChallan, OldReservEntry, 0, TypeQty::Receive)))
        then
            exit(true);

        AppDelChEntry.Reset();
        AppDelChEntry.SetRange("Document No.", AppliedDeliveryChallan."Document No.");
        AppDelChEntry.SetRange("Document Line No.", AppliedDeliveryChallan."Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", AppliedDeliveryChallan."Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", AppliedDeliveryChallan."Parent Item No.");
        AppDelChEntry.SetRange("Line No.", AppliedDeliveryChallan."Line No.");
        AppDelChEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        if not AppDelChEntry.IsEmpty() then begin
            if ReservMgt.DeleteItemTrackingConfirm() then
                DeleteItemTracking := true;
            exit(DeleteItemTracking);
        end;

        exit(true);
    end;

    procedure ReservEntryExist(
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        var ReservEntry: Record "Reservation Entry";
        Direction: Option Outbound,Inbound;
        Type_: Option Consume,RejectVE,RejectCE,Receive,Rework): Boolean
    var
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
    begin
        ReservEngineMgt.InitFilterAndSortingLookupFor(ReservEntry, false);
        FilterReservForVend(ReservEntry, AppliedDeliveryChallan, Direction, Type_);
        exit(ReservEntry.FindLast());
    end;

    procedure FilterReservForVend(
        var FilterReservEntry: Record "Reservation Entry";
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        Direction: Option Outbound,Inbound; Type_: Option Consume,RejectVE,RejectCE,Receive,Rework)
    var
        AppDelChEntry: Record "Applied Delivery Challan Entry";
    begin
        DeliveryChallanLine.Get(AppliedDeliveryChallan."Applied Delivery Challan No.",
          AppliedDeliveryChallan."App. Delivery Challan Line No.");

        FilterReservEntry.SetRange("Source Type", Database::"Applied Delivery Challan Entry");
        FilterReservEntry.SetRange("Source Subtype", Direction);
        FilterReservEntry.SetRange("Source ID", '');
        FilterReservEntry.SetRange("Source Batch Name", '');
        FilterReservEntry.SetRange("Source Prod. Order Line", 0);
        FilterReservEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        FilterReservEntry.SetRange("Location Code", DeliveryChallanLine."Vendor Location");
        FilterReservEntry.SetRange("Variant Code", DeliveryChallanLine."Variant Code");

        AppDelChEntry.Reset();
        AppDelChEntry.SetRange("Document No.", AppliedDeliveryChallan."Document No.");
        AppDelChEntry.SetRange("Document Line No.", AppliedDeliveryChallan."Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", AppliedDeliveryChallan."Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", AppliedDeliveryChallan."Parent Item No.");
        AppDelChEntry.SetRange("Line No.", AppliedDeliveryChallan."Line No.");
        AppDelChEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        AppDelChEntry.SetRange("Type of Quantity", Type_);
        if AppDelChEntry.FindFirst() then
            FilterReservEntry.SetRange("Source Ref. No.", AppDelChEntry."Entry No.");
    end;

    procedure VerifyQuantity(
        var NewAppDeliveryChallan: Record "Applied Delivery Challan";
        var OldAppDeliveryChallan: Record "Applied Delivery Challan";
        Type_: Enum "subcon type");
    var
        AppDelChEntry: Record "Applied Delivery Challan Entry";
        DeliveryChallanLine2: Record "Delivery Challan Line";
        ReservMgt: Codeunit "Reservation Management";
    begin
        if "App. Delivery Challan Line No." = OldAppDeliveryChallan."App. Delivery Challan Line No." then begin
            DeliveryChallanLine2.Get("Applied Delivery Challan No.", "App. Delivery Challan Line No.");
            AppDelChEntry.Reset();
            AppDelChEntry.SetRange("Document No.", "Document No.");
            AppDelChEntry.SetRange("Document Line No.", "Document Line No.");
            AppDelChEntry.SetRange("Applied Delivery Challan No.", "Applied Delivery Challan No.");
            AppDelChEntry.SetRange("App. Delivery Challan Line No.", "App. Delivery Challan Line No.");
            AppDelChEntry.SetRange("Parent Item No.", "Parent Item No.");
            AppDelChEntry.SetRange("Line No.", "Line No.");
            AppDelChEntry.SetRange("Item No.", "Item No.");
            AppDelChEntry.SetRange("Type of Quantity", Type_);
            if not AppDelChEntry.IsEmpty() then
                case Type_ of
                    Type_::Consume:
                        begin
                            if "Qty. to Consume" = OldAppDeliveryChallan."Qty. to Consume" then
                                exit;

                            if "Qty. to Consume" * OldAppDeliveryChallan."Qty. to Consume" < 0 then
                                ReservMgt.DeleteReservEntries(true, 0)
                            else
                                ReservMgt.DeleteReservEntries(false, "Qty. to Consume");
                        end;
                    Type_::RejectVE:
                        begin
                            if "Qty. To Return (V.E.)" = OldAppDeliveryChallan."Qty. To Return (V.E.)" then
                                exit;

                            if "Qty. To Return (V.E.)" * OldAppDeliveryChallan."Qty. To Return (V.E.)" < 0 then
                                ReservMgt.DeleteReservEntries(true, 0)
                            else
                                ReservMgt.DeleteReservEntries(false, "Qty. To Return (V.E.)");
                        end;
                    Type_::RejectCE:
                        begin
                            if "Qty. to Return (C.E.)" = OldAppDeliveryChallan."Qty. to Return (C.E.)" then
                                exit;

                            if "Qty. to Return (C.E.)" * OldAppDeliveryChallan."Qty. to Return (C.E.)" < 0 then
                                ReservMgt.DeleteReservEntries(true, 0)
                            else
                                ReservMgt.DeleteReservEntries(false, "Qty. to Return (C.E.)");
                        end;
                    Type_::Receive:
                        begin
                            if "Qty. to Receive" = OldAppDeliveryChallan."Qty. to Receive" then
                                exit;

                            if "Qty. to Receive" * OldAppDeliveryChallan."Qty. to Receive" < 0 then
                                ReservMgt.DeleteReservEntries(true, 0)
                            else
                                ReservMgt.DeleteReservEntries(false, "Qty. to Receive");
                        end;
                end;
        end;
    end;

    procedure DeleteAppDelChEntryType(AppliedDeliveryChallan: Record "Applied Delivery Challan"; Type_: Enum "Subcon Type")
    var
        AppDelChEntry: Record "Applied Delivery Challan Entry";
    begin
        AppDelChEntry.Reset();
        AppDelChEntry.SetRange("Document No.", AppliedDeliveryChallan."Document No.");
        AppDelChEntry.SetRange("Document Line No.", AppliedDeliveryChallan."Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", AppliedDeliveryChallan."Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", AppliedDeliveryChallan."Parent Item No.");
        AppDelChEntry.SetRange("Line No.", AppliedDeliveryChallan."Line No.");
        AppDelChEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        AppDelChEntry.SetRange("Type of Quantity", Type_);
        AppDelChEntry.DeleteAll();
    end;

    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        DeleteItemTracking: Boolean;
        RemainingQtyErr: Label 'Remaining Quantity is not sufficient in the challan line selected.';
        ItemErr: Label 'Item No. %1 was not delivered in Delivery Challan No. %2.', Comment = '%1 = Item No, %2 = Document No';
        DeliveryChallanErr: Label 'Delivery Challan Line does not exist.';
}
