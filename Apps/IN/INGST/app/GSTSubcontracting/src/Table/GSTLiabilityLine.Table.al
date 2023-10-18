// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Routing;

table 18470 "GST Liability Line"
{
    Caption = 'GST Liability Line';

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
        field(3; "Liability Document No."; Code[20])
        {
            Caption = 'Liability Document No.';
            DataClassification = CustomerContent;
        }
        field(4; "Liability Document Line No."; Integer)
        {
            Caption = 'Liability Document No.';
            DataClassification = CustomerContent;
        }
        field(5; "Liability Date"; Date)
        {
            Caption = 'Liability Date';
            DataClassification = CustomerContent;
        }
        field(6; "Parent Item No."; Code[20])
        {
            Caption = 'Parent Item No.';
            DataClassification = CustomerContent;
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(9; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
        }
        field(10; "Prod. BOM Quantity"; Decimal)
        {
            Caption = 'Prod. BOM Quantity';
            FieldClass = FlowField;
            CalcFormula = SUM("Prod. Order Component"."Expected Quantity" WHERE
                (Status = CONST(Released),
                "Prod. Order No." = FIELD("Production Order No."),
                "Prod. Order Line No." = FIELD("Production Order Line No."),
                "Line No." = FIELD("Line No.")));
        }
        field(11; "Quantity To Send"; Decimal)
        {
            Caption = 'Quantity To Send';
            DataClassification = CustomerContent;
        }
        field(12; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = CustomerContent;
        }
        field(13; "Quantity To Send (Base)"; Decimal)
        {
            Caption = 'Quantity To Send (Base)';
            DataClassification = CustomerContent;
        }
        field(14; "Description"; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Position"; Code[10])
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
            TableRelation = "Routing Link";
            DataClassification = CustomerContent;
        }
        field(20; "Scrap %"; Decimal)
        {
            Caption = 'Scrap %';
            DataClassification = CustomerContent;
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(22; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(23; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
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
        field(40; "Length"; Decimal)
        {
            Caption = 'Length';
            DataClassification = CustomerContent;
        }
        field(41; "Width"; Decimal)
        {
            Caption = 'Width';
            DataClassification = CustomerContent;
        }
        field(42; "Weight"; Decimal)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
        }
        field(43; "Depth"; Decimal)
        {
            Caption = 'Depth';
            DataClassification = CustomerContent;
        }
        field(44; "Calculation Formula"; Option)
        {
            Caption = 'Calculation Formula';
            OptionMembers = " ",Length,"Length * Width","Length * Width * Depth",Weight;
            OptionCaption = ' ,Length,Length * Width,Length * Width * Depth,Weight';
            DataClassification = CustomerContent;
        }
        field(45; "Quantity Per"; Decimal)
        {
            Caption = 'Quantity Per';
            DataClassification = CustomerContent;
        }
        field(46; "Company Location"; Code[10])
        {
            Caption = 'Company Location';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(47; "Vendor Location"; Code[10])
        {
            Caption = 'Vendor Location';
            DataClassification = CustomerContent;
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
            OptionMembers = Production,Purchase;
            OptionCaption = 'Production,Purchase';
            DataClassification = CustomerContent;
        }
        field(51; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
        }
        field(52; "Quantity at Vendor Location"; Decimal)
        {
            Caption = 'Quantity at Vendor Location';
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" WHERE
                ("Item No." = FIELD("Item No."),
                "Location Code" = FIELD("Vendor Location")));
        }
        field(53; "Total Scrap Quantity"; Decimal)
        {
            Caption = 'Total Scrap Quantity';
            DataClassification = CustomerContent;
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
        field(56; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(57; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" WHERE
                ("Entry Type" = CONST(Transfer),
                "Location Code" = FIELD("Vendor Location"),
                "External Document No." = FIELD("Delivery Challan No."),
                "Item No." = FIELD("Item No."),
                "Order Type" = CONST(Production),
                "Order No." = FIELD("Production Order No."),
                "Order Line No." = FIELD("Production Order Line No.")));
        }
        field(58; "Components in Rework Qty."; Decimal)
        {
            Caption = 'Components in Rework Qty.';
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
        }
        field(61; "Process Description"; Text[30])
        {
            Caption = 'Process Description';
            DataClassification = CustomerContent;
        }
        field(62; "Prod. Order Comp. Line No."; Integer)
        {
            Caption = 'Prod. Order Comp. Line No.';
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
            Caption = 'GST Last Date';
            DataClassification = CustomerContent;
        }
        field(94; "Job Work Return Period"; Integer)
        {
            Caption = 'Job Work Return Period';
            DataClassification = CustomerContent;
        }
        field(100; "Identification Mark"; Text[20])
        {
            Caption = 'Identification Mark';
            DataClassification = CustomerContent;
        }
        field(102; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            TableRelation = "GST Group";
            Editable = false;
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Rec."HSN/SAC Code" := '';
            end;
        }
        field(103; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            Editable = false;
            TableRelation = "HSN/SAC".Code WHERE("GST Group Code" = FIELD("GST Group Code"));
            DataClassification = CustomerContent;
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
        field(113; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
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
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Liability Document No.", "Liability Document Line No.")
        {
            Clustered = true;
        }
    }

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        "Dimension Set ID" := DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo(DimSetIDMsg, TableCaption, "Document No.", "Line No."));
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    var
        DimSetIDMsg: Label '%1 %2 %3', Comment = '%1 = TableCaption, %2 = Document No., %3 = Line No.';
}
