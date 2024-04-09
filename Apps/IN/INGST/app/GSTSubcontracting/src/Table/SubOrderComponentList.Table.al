// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Warehouse.Structure;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Tracking;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.Document;

table 18479 "Sub Order Component List"
{
    Caption = 'Sub Order Component List';

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
        field(9; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                if "Line Type" = "Line Type"::Production then
                    Error(LineTypeErr);
            end;
        }
        field(10; "Prod. Order Qty."; Decimal)
        {
            CalcFormula = Sum("Prod. Order Component"."Expected Quantity"
                where(Status = const(Released),
                "Prod. Order No." = field("Production Order No."),
                "Prod. Order Line No." = field("Production Order Line No."),
                "Line No." = field("Line No.")));
            Caption = 'Prod. Order Qty.';
            DecimalPlaces = 2 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Quantity To Send"; Decimal)
        {
            Caption = 'Quantity To Send';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                PurchaseLine.Get(PurchaseLine."Document Type"::Order, "Document No.", "Document Line No.");
                PurchaseLine.TestField(status, 0);
                Validate("Quantity To Send (Base)", CalcBaseQty("Quantity To Send"));
            end;
        }
        field(12; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Quantity To Send (Base)"; Decimal)
        {
            Caption = 'Quantity To Send (Base)';
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
                CalcFields("Prod. Order Qty.");
                "Total Scrap Quantity" := ("Prod. Order Qty." * "Scrap %") / 100;
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
        field(52; "Total Qty at Vendor Location"; Decimal)
        {
            CalcFormula = Sum(
                "Item Ledger Entry"."Remaining Quantity"
                where("Location Code" = field("Vendor Location"),
                "Item No." = field("Item No.")));
            Caption = 'Total Qty at Vendor Location';
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
                CalcFields("Prod. Order Qty.");
                "Scrap %" := (100 * "Total Scrap Quantity") / "Prod. Order Qty.";
                GetProdOrderCompLine();
                ProdOrderComp.Validate("Scrap %", "Scrap %");
                ProdOrderComp.Modify();
            end;
        }
        field(54; "Qty. at Vendor Location"; Decimal)
        {
            CalcFormula = Sum(
                "Item Ledger Entry"."Remaining Quantity"
                where("Entry Type" = const(Transfer),
                "Location Code" = field("Vendor Location"),
                "Order Type" = const(Production),
                "Order No." = field("Production Order No."),
                "Order Line No." = field("Production Order Line No."),
                "Prod. Order Comp. Line No." = field("Line No.")));
            Caption = 'Qty. at Vendor Location';
            DecimalPlaces = 0 : 3;
            Editable = false;
            FieldClass = FlowField;
        }
        field(55; "Qty. for Rework"; Decimal)
        {
            Caption = 'Qty. for Rework';
            DecimalPlaces = 0 : 3;
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(56; "Posting date"; Date)
        {
            Caption = 'Posting date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(57; "Applies-to Entry (Sending)"; Integer)
        {
            BlankZero = true;
            Caption = 'Applies-to Entry (Sending)';
            TableRelation = "Item Ledger Entry"."Entry No."
                where("Location Code" = field("Company Location"),
                "Item No." = field("Item No."),
                Positive = const(true),
                Correction = const(false),
                Open = const(true));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(58; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(59; "Job Work Return Period"; Integer)
        {
            Caption = 'Job Work Return Period';
            MinValue = 0;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(60; "Identification Mark"; Text[20])
        {
            Caption = 'Identification Mark';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(61; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = if ("Quantity To Send" = filter(> 0)) "Bin Content"."Bin Code" where("Location Code" = field("Company Location"), "Item No." = field("Item No."), "Variant Code" = field("Variant Code"));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
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

    fieldgroups
    {
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
        if not ProdOrderComp.FindFirst() then
            Error(ProdOrderCompErr, "Production Order No.");
    end;

    procedure CalculateQtyToSend(PurchLine: Record "Purchase Line"; Quantity: Decimal)
    begin
        SubOderComponentList.Reset();
        SubOderComponentList.SetRange("Document No.", PurchLine."Document No.");
        SubOderComponentList.SetRange("Document Line No.", PurchLine."Line No.");
        SubOderComponentList.SetRange("Parent Item No.", PurchLine."No.");
        SubOderComponentList.FindSet();
        repeat
            SubOderComponentList."Quantity To Send" := SubOderComponentList."Quantity per" * Quantity;
            SubOderComponentList.Modify();
        until SubOderComponentList.Next() = 0;
    end;

    procedure OpenItemTrackingLines(SubOrderComp: Record "Sub Order Component List")
    begin
        ProdOrderComp.Reset();
        ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Released);
        ProdOrderComp.SetRange("Prod. Order No.", "Production Order No.");
        ProdOrderComp.SetRange("Prod. Order Line No.", "Production Order Line No.");
        ProdOrderComp.SetRange("Line No.", "Line No.");
        GetProdOrderCompLine();
        ReserveProdOrderComp.CallItemTracking(ProdOrderComp);
    end;

    procedure UpdateIssueDetails(PurchLine: Record "Purchase Line"; "Deliver Comp. For": Decimal; "Qty. to Reject (Rework)": Decimal)
    var
        SubOrderComponents: Record "Sub Order Component List";
    begin
        SubOrderComponents.Reset();
        SubOrderComponents.SetRange("Document No.", PurchLine."Document No.");
        SubOrderComponents.SetRange("Document Line No.", PurchLine."Line No.");
        SubOrderComponents.FindSet();
        repeat
            SubOrderComponents.Validate(
              "Quantity To Send", ("Deliver Comp. For" * SubOrderComponents."Quantity per"));
            SubOrderComponents.Validate(
              "Qty. for Rework", (SubOrderComponents."Quantity per" * "Qty. to Reject (Rework)"));
            if SubOrderComponents."Scrap %" <> 0 then begin
                SubOrderComponents."Quantity To Send" := SubOrderComponents."Quantity To Send" +
                  (SubOrderComponents."Quantity To Send" / 100) * SubOrderComponents."Scrap %";
                SubOrderComponents."Quantity To Send (Base)" := SubOrderComponents."Quantity To Send (Base)" +
                  (SubOrderComponents."Quantity To Send (Base)" / 100) * SubOrderComponents."Scrap %";
            end;

            SubOrderComponents.Modify();
        until SubOrderComponents.Next() = 0
    end;

    procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure", 0.00001));
    end;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
        DimensionSetLbl: Label '%1 %2 %3', Comment = '%1 = TableCaption %2 Document No %3 Line No';
    begin
        TestField("Document No.");
        TestField("Line No.");
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(DimensionSetLbl, TableCaption, Rec."Document No.", Rec."Line No."));
    end;

    procedure InitTrackingSpecification(var TrackingSpecification: Record "Tracking Specification")
    begin
        TrackingSpecification.Init();
        TrackingSpecification."Source Type" := Database::"Sub Order Component List";
        TrackingSpecification."Item No." := "Item No.";
        TrackingSpecification."Location Code" := "Company Location";
        TrackingSpecification.Description := Description;
        TrackingSpecification."Variant Code" := "Variant Code";
        TrackingSpecification."Source ID" := "Production Order No.";
        TrackingSpecification."Source Batch Name" := '';
        TrackingSpecification."Source Prod. Order Line" := "Production Order Line No.";
        TrackingSpecification."Source Ref. No." := "Line No.";
        TrackingSpecification."Quantity (Base)" := "Quantity To Send (Base)";
        TrackingSpecification."Qty. to Handle" := "Quantity To Send";
        TrackingSpecification."Qty. to Handle (Base)" := "Quantity To Send (Base)";
        TrackingSpecification."Qty. to Invoice" := "Quantity To Send";
        TrackingSpecification."Qty. to Invoice (Base)" := "Quantity To Send (Base)";
        TrackingSpecification."Quantity Handled (Base)" := "Quantity To Send (Base)";
        TrackingSpecification."Quantity Invoiced (Base)" := "Quantity To Send (Base)";
        TrackingSpecification."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
    end;

    procedure OpenItemTrackingLinesSubcon()
    var
        TrackingSpecification: Record "Tracking Specification";
        ItemTrackingForm: Page "Item Tracking Lines";
    begin
        TestField("Item No.");
        InitTrackingSpecification(TrackingSpecification);
        ItemTrackingForm.SetSourceSpec(TrackingSpecification, WorkDate());
        ItemTrackingForm.RunModal();
    end;

    var
        ProdOrderComp: Record "Prod. Order Component";
        SubOderComponentList: Record "Sub Order Component List";
        PurchaseLine: Record "Purchase Line";
        ReserveProdOrderComp: Codeunit "Prod. Order Comp.-Reserve";
        ProdOrderCompErr: Label 'Production Order %1 does not exist in released state, \ No transaction allowed',
            Comment = '%1 = Production Order No';
        LineTypeErr: Label 'Can Not Insert,Delete or Modify Component details ';
}
