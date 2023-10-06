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
using Microsoft.Purchases.Vendor;

table 18476 "Subcon. Delivery Challan Line"
{
    Caption = 'Subcon. Delivery Challan Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Subcontractor Delivery Challan"."No.";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Parent Item No."; Code[20])
        {
            Caption = 'Parent Item No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                SubcontractorDeliveryChallan.SetRange("No.", "Document No.");
                if SubcontractorDeliveryChallan.FindFirst() then
                    "Vendor Location" := SubcontractorDeliveryChallan."Vendor Location";

                if Item.Get("Item No.") then
                    Validate("Unit of Measure", Item."Base Unit of Measure");
            end;
        }
        field(5; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            Editable = false;
            TableRelation = "Unit of Measure";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Quantity To Send"; Decimal)
        {
            Caption = 'Quantity To Send';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                "Quantity (Base)" := "Quantity To Send";
            end;
        }
        field(7; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; "Quantity To Send (Base)"; Decimal)
        {
            Caption = 'Quantity To Send (Base)';
            DecimalPlaces = 0 : 3;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Company Location"; Code[10])
        {
            Caption = 'Company Location';
            TableRelation = Location where(
                "Use As In-Transit" = const(false),
                "Subcontracting Location" = const(false));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "Vendor Location"; Code[10])
        {
            Caption = 'Vendor Location';
            Editable = false;
            TableRelation = Location;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14; "Posting date"; Date)
        {
            Caption = 'Posting date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Applies-to Entry"; Integer)
        {
            BlankZero = true;
            Caption = 'Applies-to Entry';
            TableRelation = "Item Ledger Entry"."Entry No."
                where("Location Code" = field("Company Location"),
                "Item No." = field("Item No."),
                Positive = const(true),
                Correction = const(false),
                Open = const(true));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 3;
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(17; "Subcontractor No."; Code[20])
        {
            Caption = 'Subcontractor No.';
            Editable = false;
            TableRelation = Vendor;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        SubcontractorDeliveryChallan: Record "Subcontractor Delivery Challan";
        Item: Record Item;
}
