// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Routing;
using Microsoft.Purchases.Vendor;

table 18469 "Delivery Challan Line"
{
    Caption = 'Delivery Challan Line';
    DrillDownPageID = "Delivery Challan Line";
    LookupPageID = "Sub. Item Tracking";

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(2; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(6; "Parent Item No."; Code[20])
        {
            Caption = 'Parent Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(9; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Unit of Measure";
        }
        field(10; "Prod. BOM Quantity"; Decimal)
        {
            CalcFormula = Sum(
                "Prod. Order Component"."Expected Quantity"
                where(Status = const(Released),
                "Prod. Order No." = field("Production Order No."),
                "Prod. Order Line No." = field("Production Order Line No."),
                "Line No." = field("Line No.")));
            Caption = 'Prod. BOM Quantity';
            DecimalPlaces = 2 : 5;
            FieldClass = FlowField;
        }
        field(11; "Quantity To Send"; Decimal)
        {
            Caption = 'Quantity To Send';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(12; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(13; "Quantity To Send (Base)"; Decimal)
        {
            Caption = 'Quantity To Send (Base)';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(14; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; Position; Code[10])
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
        }
        field(16; "Position 2"; Code[10])
        {
            Caption = 'Position 2';
            DataClassification = CustomerContent;
        }
        field(17; "Position 3"; Code[10])
        {
            Caption = 'Position 3';
            DataClassification = CustomerContent;
        }
        field(18; "Production Lead Time"; DateFormula)
        {
            Caption = 'Production Lead Time';
            DataClassification = CustomerContent;
        }
        field(19; "Routing Link Code"; Code[10])
        {
            Caption = 'Routing Link Code';
            DataClassification = CustomerContent;
            TableRelation = "Routing Link";
        }
        field(20; "Scrap %"; Decimal)
        {
            BlankNumbers = BlankNeg;
            Caption = 'Scrap %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(28; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(29; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(40; Length; Decimal)
        {
            Caption = 'Length';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Calculation Formula");
            end;
        }
        field(41; Width; Decimal)
        {
            Caption = 'Width';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Calculation Formula");
            end;
        }
        field(42; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Calculation Formula");
            end;
        }
        field(43; Depth; Decimal)
        {
            Caption = 'Depth';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Calculation Formula");
            end;
        }
        field(44; "Calculation Formula"; Option)
        {
            Caption = 'Calculation Formula';
            OptionCaption = ' ,Length,Length * Width,Length * Width * Depth,Weight';
            OptionMembers = " ",Length,"Length * Width","Length * Width * Depth",Weight;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CASE "Calculation Formula" OF
                    "Calculation Formula"::" ":
                        "Prod. BOM Quantity" := "Quantity per";
                    "Calculation Formula"::Length:
                        "Prod. BOM Quantity" := Round(Length * "Quantity per", 0.00001);
                    "Calculation Formula"::"Length * Width":
                        "Prod. BOM Quantity" := Round(Length * Width * "Quantity per", 0.00001);
                    "Calculation Formula"::"Length * Width * Depth":
                        "Prod. BOM Quantity" := Round(Length * Width * Depth * "Quantity per", 0.00001);
                    "Calculation Formula"::Weight:
                        "Prod. BOM Quantity" := Round(Weight * "Quantity per", 0.00001);
                end;
            end;
        }
        field(45; "Quantity per"; Decimal)
        {
            Caption = 'Quantity per';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Calculation Formula");
            end;
        }
        field(46; "Company Location"; Code[10])
        {
            Caption = 'Company Location';
            DataClassification = CustomerContent;
            TableRelation = Location where("Use As In-Transit" = const(false), "Subcontracting Location" = const(false));
        }
        field(47; "Vendor Location"; Code[10])
        {
            Caption = 'Vendor Location';
            DataClassification = CustomerContent;
            TableRelation = Location where("Use As In-Transit" = const(false), "Subcontracting Location" = const(false));
        }
        field(48; "Production Order No."; Code[20])
        {
            Caption = 'Production Order No.';
            DataClassification = CustomerContent;
        }
        field(49; "Production Order Line No."; Integer)
        {
            Caption = 'Production Order Line No.';
            DataClassification = CustomerContent;
        }
        field(50; "Line Type"; Option)
        {
            Caption = 'Line Type';
            OptionCaption = 'Production,Purchase';
            DataClassification = CustomerContent;
            OptionMembers = Production,Purchase;
        }
        field(51; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(52; "Quantity at Vendor Location"; Decimal)
        {
            CalcFormula = Sum(
                "Item Ledger Entry"."Remaining Quantity"
                where("Item No." = field("Item No."),
                "Location Code" = field("Vendor Location")));
            Caption = 'Quantity at Vendor Location';
            DecimalPlaces = 0 : 3;
            FieldClass = FlowField;
        }
        field(53; "Total Scrap Quantity"; Decimal)
        {
            Caption = 'Total Scrap Quantity';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcFields("Prod. BOM Quantity");
            end;
        }
        field(54; "Delivery Challan No."; Code[20])
        {
            Caption = 'Delivery Challan No.';
            DataClassification = CustomerContent;
        }
        field(55; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(56; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(57; "Remaining Quantity"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum(
                "Item Ledger Entry"."Remaining Quantity"
                where("Entry Type" = const(Transfer),
                "Location Code" = field("Vendor Location"),
                "External Document No." = field("Delivery Challan No."),
                "Item No." = field("Item No."),
                "Subcon Order No." = field("Document No.")));
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0 : 3;
        }
        field(58; "Components in Rework Qty."; Decimal)
        {
            Caption = 'Components in Rework Qty.';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(59; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(60; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(61; "Process Description"; Text[100])
        {
            Caption = 'Process Description';
            DataClassification = CustomerContent;
        }
        field(62; "Prod. Order Comp. Line No."; Integer)
        {
            Caption = 'Prod. Order Comp. Line No.';
            DataClassification = CustomerContent;
        }
        field(65; SSI; Boolean)
        {
            Caption = 'SSI';
            DataClassification = CustomerContent;
        }
        field(83; "Debit Note Created"; Boolean)
        {
            Caption = 'Debit Note Created';
            DataClassification = CustomerContent;
        }
        field(84; "Return Date"; Date)
        {
            Caption = 'Return Date';
            DataClassification = CustomerContent;
        }
        field(86; "Last Date"; Date)
        {
            Caption = 'Last Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(93; "ADC VAT Amount"; Decimal)
        {
            Caption = 'ADC VAT Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(94; "Job Work Return Period"; Integer)
        {
            Caption = 'Job Work Return Period';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(100; "Identification Mark"; Text[20])
        {
            Caption = 'Identification Mark';
            DataClassification = CustomerContent;
        }
        field(102; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "GST Group";
            trigger OnValidate()
            begin
                Rec."HSN/SAC Code" := '';
            end;
        }
        field(103; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(104; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(105; "Total GST Amount"; Decimal)
        {
            Caption = 'Total GST Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(106; "GST Liability Created"; Decimal)
        {
            Caption = 'GST Liability Created';
            DataClassification = CustomerContent;
        }
        field(109; "GST Amount Remaining"; Decimal)
        {
            Caption = 'GST Amount Remaining';
            DataClassification = CustomerContent;
        }
        field(111; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(112; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(113; "GST Jurisdiction Type"; enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
        }
        field(114; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(115; "Location GST Reg. No."; Code[20])
        {
            Caption = 'Location GST Reg. No.';
            TableRelation = "GST Registration Nos.";
            DataClassification = CustomerContent;
        }
        field(116; "GST Vendor Type"; Enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(117; "Vendor State Code"; Code[10])
        {
            Caption = 'Vendor State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(118; "Vendor GST Reg. No."; Code[20])
        {
            Caption = 'Vendor GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Delivery Challan No.", "Line No.")
        {
        }
        key(Key2; "Production Order No.", "Production Order Line No.", "Prod. Order Comp. Line No.")
        {
        }
        key(Key3; "Delivery Challan No.", "Item No.")
        {
        }
        key(Key4; "Item No.")
        {
        }
        key(Key5; "Document No.", "Document Line No.", "Production Order No.", "Production Order Line No.", "Prod. Order Comp. Line No.")
        {
        }
        key(Key6;
        "Vendor No.",
            "Document No.",
            "Document Line No.",
            "Production Order No.",
            "Production Order Line No.",
            "Prod. Order Comp. Line No.")
        {
        }
    }

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
        ShowDimensionSetLbl: Label '%1 %2 %3', Comment = '%1 = Tavle Caption, %2 = Document No, %3 = Line No';
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(ShowDimensionSetLbl, TableCaption, "Delivery Challan No.", "Line No."));
    end;

    procedure UpdateChallanLine(ChallanLine: Record "Delivery Challan Line");
    var
        DimMgt: Codeunit DimensionManagement;
        ShowDimensionSetLbl: Label '%1 %2 %3', Comment = '%1 = Tavle Caption, %2 = Document No, %3 = Line No';
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(ShowDimensionSetLbl, TableCaption, "Delivery Challan No.", "Line No."));
    end;
}
