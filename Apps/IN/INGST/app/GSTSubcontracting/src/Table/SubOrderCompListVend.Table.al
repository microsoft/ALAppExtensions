// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.Document;
using Microsoft.Warehouse.Structure;

table 18478 "Sub Order Comp. List Vend"
{
    Caption = 'Sub Order Comp. List Vend';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Parent Item No."; Code[20])
        {
            Caption = 'Parent Item No.';
            TableRelation = Item;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                if "Line Type" = "Line Type"::Production then
                    Error(LineTypeErr);
            end;
        }
        field(9; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            Editable = false;
            TableRelation = "Unit of Measure";
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                if "Line Type" = "Line Type"::Production then
                    Error(LineTypeErr);
            end;
        }
        field(10; "Expected Quantity"; Decimal)
        {
            CalcFormula = Sum(
                "Prod. Order Component"."Expected Quantity"
                where(Status = const(Released),
                "Prod. Order No." = field("Production Order No."),
                "Prod. Order Line No." = field("Production Order Line No."),
                "Line No." = field("Line No.")));
            Caption = 'Expected Quantity';
            DecimalPlaces = 2 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; "Scrap %"; Decimal)
        {
            BlankNumbers = BlankNeg;
            Caption = 'Scrap %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                GetProdOrderCompLine();
                ProdOrderComp.Validate("Scrap %", "Scrap %");
                ProdOrderComp.Modify();

                CalcFields("Expected Quantity");
                "Total Scrap Quantity" := ("Expected Quantity" * "Scrap %") / 100;
            end;
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(45; "Quantity per"; Decimal)
        {
            Caption = 'Quantity per';
            DecimalPlaces = 0 : 5;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(46; "Company Location"; Code[10])
        {
            Caption = 'Company Location';
            TableRelation = Location
                where("Use As In-Transit" = const(false),
                "Subcontracting Location" = const(false));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(47; "Vendor Location"; Code[10])
        {
            Caption = 'Vendor Location';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(48; "Production Order No."; Code[20])
        {
            Caption = 'Production Order No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(49; "Production Order Line No."; Integer)
        {
            Caption = 'Production Order Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(50; "Line Type"; Option)
        {
            Caption = 'Line Type';
            OptionCaption = 'Production,Purchase';
            OptionMembers = Production,Purchase;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(51; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(52; "Quantity at Vendor Location"; Decimal)
        {
            CalcFormula = Sum(
                "Item Ledger Entry"."Remaining Quantity"
                where("Entry Type" = const(Transfer),
                "Location Code" = field("Vendor Location"),
                "Order Type" = const(Production),
                "Order No." = field("Production Order No."),
                "Order Line No." = field("Production Order Line No."),
                "Prod. Order Comp. Line No." = field("Line No.")));
            Caption = 'Quantity at Vendor Location';
            DecimalPlaces = 0 : 3;
            Editable = false;
            FieldClass = FlowField;
        }
        field(53; "Total Scrap Quantity"; Decimal)
        {
            Caption = 'Total Scrap Quantity';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                CalcFields("Expected Quantity");
                "Scrap %" := (100 * "Total Scrap Quantity") / "Expected Quantity";
                GetProdOrderCompLine();
                ProdOrderComp.Validate("Scrap %", "Scrap %");
                ProdOrderComp.Modify();
            end;
        }
        field(54; "Qty. Received"; Decimal)
        {
            Caption = 'Qty. Received';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(55; "Qty. Received (Base)"; Decimal)
        {
            Caption = 'Qty. Received (Base)';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(56; "Qty. to Receive"; Decimal)
        {
            Caption = 'Qty. to Receive';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ReinitializeApplication();
            end;
        }
        field(57; "Qty. to Consume"; Decimal)
        {
            Caption = 'Qty. to Consume';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                GetProdOrderCompLine();
                GetPurchaseOrderLine();
                UpdateConInProdCompLines();
                ReinitializeApplication();
            end;
        }
        field(59; "Qty. to Return (C.E.)"; Decimal)
        {
            Caption = 'Qty. to Return (C.E.)';
            DecimalPlaces = 0 : 3;
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                UpdateConInProdCompLines();
                ReinitializeApplication();
            end;
        }
        field(60; "Qty. To Return (V.E.)"; Decimal)
        {
            Caption = 'Qty. To Return (V.E.)';
            DecimalPlaces = 0 : 3;
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                ReinitializeApplication();
            end;
        }
        field(61; "Qty. Consumed"; Decimal)
        {
            CalcFormula = - Sum(
                "Item Ledger Entry".Quantity
                where("Entry Type" = const(Consumption),
                "Order Type" = const(Production),
                "Order No." = field("Production Order No."),
                "Order Line No." = field("Production Order Line No."),
                "Prod. Order Comp. Line No." = field("Line No.")));
            Caption = 'Qty. Consumed';
            DecimalPlaces = 0 : 3;
            Editable = false;
            FieldClass = FlowField;
        }
        field(62; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(63; "Quantity Dispatched"; Decimal)
        {
            CalcFormula = - Sum(
                "Item Ledger Entry".Quantity
                where("Entry Type" = const(Transfer),
                "Location Code" = field("Company Location"),
                "Order Type" = const(Production),
                "Order No." = field("Production Order No."),
                "Order Line No." = field("Production Order Line No."),
                "Prod. Order Comp. Line No." = field("Line No.")));
            Caption = 'Quantity Dispatched';
            DecimalPlaces = 0 : 3;
            Editable = false;
            FieldClass = FlowField;
        }
        field(64; "Charge Recoverable"; Decimal)
        {
            CalcFormula = - Sum(
                "Value Entry"."Cost Amount (Actual)"
                where("Item Ledger Entry Type" = const("Negative Adjmt."),
                "Location Code" = field("Vendor Location"),
                "Order Type" = const(Production),
                "Order No." = field("Production Order No."),
                "Order Line No." = field("Production Order Line No."),
                "Source Type" = const(Item),
                "Source No." = field("Item No.")));
            Caption = 'Charge Recoverable';
            Editable = false;
            FieldClass = FlowField;
        }
        field(65; "Debit Note Amount"; Decimal)
        {
            Caption = 'Debit Note Amount';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(66; "Applies-to Entry"; Integer)
        {
            BlankZero = true;
            Caption = 'Applies-to Entry';
            Editable = false;
            TableRelation = "Item Ledger Entry";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(67; "Applied Delivery Challan No."; Code[20])
        {
            Caption = 'Applied Delivery Challan No.';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            begin
                DeliveryChallanHeader.Reset();
                if DeliveryChallanHeader.FindSet() then
                    repeat
                        TempDeliveryChallanHeader := DeliveryChallanHeader;
                        TempDeliveryChallanHeader.Insert();
                    until DeliveryChallanHeader.Next() = 0;

                if Action::LookupOK = Page.Runmodal(Page::"Delivery Challan List", TempDeliveryChallanHeader) then begin
                    DeliveryChallanHeader.Get(TempDeliveryChallanHeader."No.");
                    TempDeliveryChallanHeader.DeleteAll();
                    Validate("Applied Delivery Challan No.", DeliveryChallanHeader."No.");
                end;

                TempDeliveryChallanHeader.DeleteAll();
            end;

            trigger OnValidate()
            begin
                if "Applied Delivery Challan No." <> '' then
                    if not DeliveryChallanHeader.Get("Applied Delivery Challan No.") then
                        Error(DeliveryChallanErr);

                if "Applied Delivery Challan No." <> '' then
                    CheckAvialibility()
                else
                    "Applies-to Entry" := 0;
            end;
        }
        field(70; SSI; Boolean)
        {
            Caption = 'SSI';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(71; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = if ("Qty. To Receive" = filter(> 0)) "Bin Content"."Bin Code" where("Location Code" = field("Company Location"), "Item No." = field("Item No."), "Variant Code" = field("Variant Code"));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(89; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Document Line No.", "Parent Item No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        if "Line Type" = "Line Type"::Production then
            Error(LineTypeErr);
    end;

    trigger OnInsert()
    begin
        if "Line Type" = "Line Type"::Production then
            Error(LineTypeErr);
    end;

    procedure GetProdOrderCompLine()
    begin
        ProdOrderComp.Reset();
        ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Released);
        ProdOrderComp.SetRange("Prod. Order No.", "Production Order No.");
        ProdOrderComp.SetRange("Prod. Order Line No.", "Production Order Line No.");
        ProdOrderComp.SetRange("Line No.", "Line No.");
        if ProdOrderComp.FindFirst() then;
    end;

    procedure GetPurchaseOrderLine()
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", "Document No.");
        PurchaseLine.SetRange("Line No.", "Document Line No.");
        PurchaseLine.FindFirst();
        PurchaseLine.TestField(Status, 0);
    end;

    procedure SyncronizeSubOrderCompList()
    begin
        SubOrderCompList.Reset();
        SubOrderCompList.SetRange("Document No.", "Document No.");
        SubOrderCompList.SetRange("Document Line No.", "Document Line No.");
        SubOrderCompList.SetRange("Parent Item No.", "Parent Item No.");
        SubOrderCompList.SetRange("Line No.", "Line No.");
        SubOrderCompList.SetRange("Item No.", "Item No.");
        SubOrderCompList.FindFirst();
    end;

    procedure UpdateConInProdCompLines()
    begin
        ProdOrderComp."Qty. To Consume" := "Qty. to Consume" + "Qty. to Return (C.E.)";
        ProdOrderComp.Modify();
    end;

    procedure CheckAvialibility()
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        DeliveryChallanLine.Reset();
        DeliveryChallanLine.SetCurrentKey("Delivery Challan No.", "Item No.");
        DeliveryChallanLine.SetRange("Delivery Challan No.", DeliveryChallanHeader."No.");
        DeliveryChallanLine.SetRange("Item No.", "Item No.");
        if DeliveryChallanLine.FindFirst() then begin
            DeliveryChallanLine.CalcFields("Remaining Quantity");
            if (DeliveryChallanLine."Remaining Quantity" <
                ("Qty. to Receive" + "Qty. to Consume" + "Qty. to Return (C.E.)" + "Qty. To Return (V.E.)"))
            then
                Error(RemainingQtyErr);

            ItemLedgerEntry.Reset();
            ItemLedgerEntry.SetCurrentKey("Entry Type", "Location Code", "External Document No.", "Item No.");
            ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
            ItemLedgerEntry.SetRange("Location Code", DeliveryChallanLine."Vendor Location");
            ItemLedgerEntry.SetRange("External Document No.", DeliveryChallanLine."Delivery Challan No.");
            ItemLedgerEntry.SetRange("Item No.", "Item No.");
            if ItemLedgerEntry.FindFirst() then
                "Applies-to Entry" := ItemLedgerEntry."Entry No."
            else
                Error(ItemErr, "Item No.", DeliveryChallanLine."Delivery Challan No.");
        end else
            "Applies-to Entry" := 0;
    end;

    procedure GetILE()
    begin
    end;

    procedure ReinitializeApplication();
    begin
        Validate("Applied Delivery Challan No.", '');
    end;

    procedure UpdateReceiptDetails(var PurchLine: Record "Purchase Line"; "Qty. to Reject (C.E.)": Decimal; "Qty. to Reject (V.E.)": Decimal)
    var
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
    begin
        SubOrderCompListVend.Reset();
        SubOrderCompListVend.SetRange("Document No.", PurchLine."Document No.");
        SubOrderCompListVend.SetRange("Document Line No.", PurchLine."Line No.");
        SubOrderCompListVend.FindSet();
        repeat
            SubOrderCompListVend.Validate("Qty. to Consume", (PurchLine."Qty. to Receive" * SubOrderCompListVend."Quantity per" * SubOrderCompListVend."Qty. per Unit of Measure"));
            SubOrderCompListVend.Validate("Qty. to Return (C.E.)", (PurchLine."Qty. to Reject (C.E.)" * SubOrderCompListVend."Quantity per"));
            SubOrderCompListVend.Validate("Qty. To Return (V.E.)", (SubOrderCompListVend."Quantity per" * PurchLine."Qty. to Reject (V.E.)"));

            if SubOrderCompListVend."Scrap %" <> 0 then begin
                SubOrderCompListVend."Qty. to Consume" +=
                    (SubOrderCompListVend."Qty. to Consume" / 100) * SubOrderCompListVend."Scrap %";
                SubOrderCompListVend."Qty. to Return (C.E.)" +=
                    (SubOrderCompListVend."Qty. to Return (C.E.)" / 100) * SubOrderCompListVend."Scrap %";
                SubOrderCompListVend."Qty. To Return (V.E.)" +=
                    (SubOrderCompListVend."Qty. To Return (V.E.)" / 100) * SubOrderCompListVend."Scrap %";
            end;

            SubOrderCompListVend.Modify();
        until SubOrderCompListVend.Next() = 0
    end;

    procedure ApplyDeliveryChallan()
    var
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
    begin
        AppliedDeliveryChallan.Reset();
        AppliedDeliveryChallan.SetRange("Document No.", "Document No.");
        AppliedDeliveryChallan.SetRange("Document Line No.", "Document Line No.");
        AppliedDeliveryChallan.SetRange("Parent Item No.", "Parent Item No.");
        AppliedDeliveryChallan.SetRange("Line No.", "Line No.");
        AppliedDeliveryChallan.SetRange("Item No.", "Item No.");
        Page.run(Page::"Applied Delivery Challan", AppliedDeliveryChallan);
    end;

    var
        ProdOrderComp: Record "Prod. Order Component";
        PurchaseLine: Record "Purchase Line";
        SubOrderCompList: Record "Sub Order Component List";
        DeliveryChallanHeader: Record "Delivery Challan Header";
        TempDeliveryChallanHeader: Record "Delivery Challan Header" temporary;
        LineTypeErr: Label 'Can Not Insert,Delete  or Modify() Component details. ';
        ItemErr: Label 'Item No. %1 was not delivered in Delivery Challan No. %2.', Comment = '%1 = Item No, %2 = Delivery Challan No';
        DeliveryChallanErr: Label 'Delivery Challan does not exist.';
        RemainingQtyErr: Label 'Remaining Quantity is not sufficient in the challan selected.';
}
