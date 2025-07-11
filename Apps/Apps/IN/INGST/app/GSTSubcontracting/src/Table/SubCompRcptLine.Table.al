// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.Dimension;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;

table 18475 "Sub. Comp. Rcpt. Line"
{
    Caption = 'Sub. Comp. Rcpt. Line';
    LookupPageID = "Posted Purchase Receipt Lines";

    fields
    {
        field(2; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            Editable = false;
            TableRelation = Vendor;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            Description = '1';
            TableRelation = Item;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Description = '1';
            TableRelation = Location where("Use As In-Transit" = const(false));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            Description = '1';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Unit of Measure"; Text[10])
        {
            Caption = 'Unit of Measure';
            Description = '1';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Description = '1';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(22; "Direct Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(23; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(31; "Unit Price (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price (LCY)';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(65; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(66; "Order Line No."; Integer)
        {
            Caption = 'Order Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(100; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(5401; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            Description = '1';
            TableRelation = "Production Order"."No." where(Status = filter(Released | Finished));
            //This property is currently not supported
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("No."));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("No."));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5415; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5461; "Qty. Invoiced (Base)"; Decimal)
        {
            Caption = 'Qty. Invoiced (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16321; "Sub Order Component Line No."; Integer)
        {
            Caption = 'Sub Order Component Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16322; "Sub Order Component"; Code[20])
        {
            Caption = 'Sub Order Component';
            DataClassification = EndUserIdentifiableInformation;
        }
#pragma warning disable AS0013 // The ID should have been within the range [1..49999]
        field(99000754; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            Description = '1';
            TableRelation = "Prod. Order Line"."Line No." where(Status = filter(Released ..), "Prod. Order No." = field("Prod. Order No."));
            DataClassification = EndUserIdentifiableInformation;
        }
#pragma warning restore AS0013 // The ID should have been within the range [1..49999]
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    procedure ShowDimensions()
    var
        DimensionLbl: Label '%1,%2,%3', Comment = '%1 = Table Caption, %2 = Document No, %3 = Line No';
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(DimensionLbl, TableCaption, "Document No.", "Line No."));
    end;

    var
        DimMgt: Codeunit DimensionManagement;
}
