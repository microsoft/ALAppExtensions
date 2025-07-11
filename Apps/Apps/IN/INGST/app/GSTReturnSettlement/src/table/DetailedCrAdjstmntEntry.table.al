// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 18317 "Detailed Cr. Adjstmnt. Entry"
{
    Caption = 'Detailed Cr. Adjstmnt. Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(2; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; "Credit Adjustment Type"; Enum "Credit Adjustment Type")
        {
            Caption = 'Credit Adjustment Type';
            DataClassification = CustomerContent;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(5; "Adjusted Doc. Entry No."; Integer)
        {
            Caption = 'Adjusted Doc. Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Detailed GST Ledger Entry";
        }
        field(6; "Adjusted Doc. Entry Type"; Enum "Detail Ledger Entry Type")
        {
            Caption = 'Adjusted Doc. Entry Type';
            DataClassification = CustomerContent;
        }
        field(7; "Adjusted Doc. Transaction Type"; Enum "Detail Ledger Transaction Type")
        {
            Caption = 'Adjusted Doc. Transaction Type';
            DataClassification = CustomerContent;
        }
        field(8; "Adjusted Doc. Type"; Enum "GST Document Type")
        {
            Caption = 'Adjusted Doc. Type';
            DataClassification = CustomerContent;
        }
        field(9; "Adjusted Doc. No."; Code[20])
        {
            Caption = 'Adjusted Doc. No.';
            DataClassification = CustomerContent;
        }
        field(10; "Adjusted Doc. Line No."; Integer)
        {
            Caption = 'Adjusted Doc. Line No.';
            DataClassification = CustomerContent;
        }
        field(11; "Adjusted Doc. Posting Date"; Date)
        {
            Caption = 'Adjusted Doc. Posting Date';
            DataClassification = CustomerContent;
        }
        field(12; Type; Enum Type)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(13; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const("G/L Account")) "G/L Account"
            else
            if (Type = const(Item)) Item
            else
            if (Type = const(Resource)) Resource
            else
            if (Type = const("Fixed Asset")) "Fixed Asset"
            else
            if (Type = const("Charge (Item)")) "Item Charge";
        }
        field(14; "Product Type"; Enum "Product Type")
        {
            Caption = 'Product Type';
            DataClassification = CustomerContent;
        }
        field(15; "Source Type"; Enum "Source Type")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(16; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor;
        }
        field(17; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(18; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
        }
        field(19; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
            TableRelation = "GST Group";
        }
        field(20; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
        }
        field(21; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = CustomerContent;
        }
        field(22; "GST %"; Decimal)
        {
            Caption = 'GST %';
            DataClassification = CustomerContent;
        }
        field(23; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
        }
        field(24; "Adjustment %"; Decimal)
        {
            Caption = 'Adjustment %';
            DataClassification = CustomerContent;
        }
        field(25; "Adjustment Amount"; Decimal)
        {
            Caption = 'Adjustment Amount';
            DataClassification = CustomerContent;
        }
        field(26; "External Document No."; Code[40])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(27; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(28; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(29; Positive; Boolean)
        {
            Caption = 'Positive';
            DataClassification = CustomerContent;
        }
        field(30; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
        }
        field(31; "Buyer/Seller State Code"; Code[10])
        {
            Caption = 'Buyer/Seller State Code';
            DataClassification = CustomerContent;
            TableRelation = State;
        }
        field(32; "Location  Reg. No."; Code[20])
        {
            Caption = 'Location  Reg. No.';
            DataClassification = CustomerContent;
        }
        field(33; "Buyer/Seller Reg. No."; Code[20])
        {
            Caption = 'Buyer/Seller Reg. No.';
            DataClassification = CustomerContent;
        }
        field(34; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
        }
        field(35; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(36; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(37; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 1 : 6;
        }
        field(38; "GST Rounding Precision"; Decimal)
        {
            Caption = 'GST Rounding Precision';
            DataClassification = CustomerContent;
        }
        field(39; "GST Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Rounding Type';
            DataClassification = CustomerContent;
        }
        field(40; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(41; "GST Vendor Type"; Enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(42; "Credit Availed"; Boolean)
        {
            Caption = 'Credit Availed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(43; Paid; Boolean)
        {
            Caption = 'Paid';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(44; Cess; Boolean)
        {
            Caption = 'Cess';
            DataClassification = CustomerContent;
        }
        field(45; "Input Service Distribution"; Boolean)
        {
            Caption = 'Input Service Distribution';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(46; "Liable to Pay"; Boolean)
        {
            Caption = 'Liable to Pay';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(47; "Payment Document No."; Code[20])
        {
            Caption = 'Payment Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(48; "Payment Document Date"; Date)
        {
            Caption = 'Payment Document Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Reverse Charge"; Boolean)
        {
            Caption = 'Reverse Charge';
            DataClassification = CustomerContent;
        }
        field(51; "Rem. Amt. Updated in DGLE"; Boolean)
        {
            Caption = 'Rem. Amt. Updated in DGLE';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Document No.", "Posting Date")
        {
        }
        key(Key3; "Location  Reg. No.", "GST Component Code", Paid, "Posting Date")
        {
        }
    }
}
