// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GST.Base;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;

table 18326 "GST Adjustment Buffer"
{
    Caption = 'GST Adjustment Buffer';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Document Type"; Enum "GST Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(4; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(6; Type; Enum Type)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(7; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const(" ")) "Standard Text"
            else
            if (Type = const("G/L Account")) "G/L Account"
            else
            if (Type = const(Item)) Item
            else
            if (Type = const(Resource)) Resource
            else
            if (Type = const("Fixed Asset")) "Fixed Asset"
            else
            if (Type = const("Charge (Item)")) "Item Charge";
            DataClassification = CustomerContent;
        }
        field(8; "Product Type"; Enum "Product Type")
        {
            Caption = 'Product Type';
            DataClassification = CustomerContent;
        }
        field(9; "Source Type"; Enum "Source Type")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(10; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor;
            DataClassification = CustomerContent;
        }
        field(11; "GST Component Code"; Code[10])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
        }
        field(12; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = CustomerContent;
        }
        field(13; "GST %"; Decimal)
        {
            Caption = 'GST %';
            DataClassification = CustomerContent;
        }
        field(14; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
        }
        field(15; "GST Credit Type"; Enum "GST Credit")
        {
            Caption = 'GST Credit Type';
            DataClassification = CustomerContent;
        }
        field(16; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(17; "Amount Loaded on Inventory"; Decimal)
        {
            Caption = 'Amount Loaded on Inventory';
            DataClassification = CustomerContent;
        }
        field(18; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(19; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
        }
        field(20; "Transaction Type"; Enum "Detail Ledger Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(21; "Adjustment Type"; Enum "Adjustment Type")
        {
            Caption = 'Adjustment Type';
            DataClassification = CustomerContent;
        }
        field(22; "Transaction No"; Integer)
        {
            Caption = 'Transaction No';
            DataClassification = CustomerContent;
        }
        field(23; "Amount to be Adjusted"; Decimal)
        {
            Caption = 'Amount to be Adjusted';
            DataClassification = CustomerContent;
        }
        field(24; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "GST Journal Template";
            DataClassification = CustomerContent;
        }
        field(25; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "GST Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
            DataClassification = CustomerContent;
        }
        field(26; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(61; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            TableRelation = "Item Ledger Entry";
            DataClassification = CustomerContent;
        }
        field(62; "DGL Entry No."; Integer)
        {
            Caption = 'DGL Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Source Type")
        {
        }
    }
}

