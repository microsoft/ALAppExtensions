// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GST.Base;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 18321 "Posted GST Liability Adj."
{
    Caption = 'Posted GST Liability Adj.';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(3; "USER ID"; Code[50])
        {
            Caption = 'USER ID';
            DataClassification = CustomerContent;
        }
        field(4; "Adjustment Amount"; Decimal)
        {
            Caption = 'Adjustment Amount';
            DataClassification = CustomerContent;
        }
        field(5; "Adjusted Doc. Entry No."; Integer)
        {
            Caption = 'Adjusted Doc. Entry No.';
            DataClassification = CustomerContent;
        }
        field(6; "Adjusted Doc. Entry Type"; Enum "Detail Ledger Entry Type")
        {
            Caption = 'Adjusted Doc. Entry Type';
            DataClassification = CustomerContent;
        }
        field(7; "Transaction Type"; Enum "Detail Ledger Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(8; "Document Type"; Enum "GST Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(9; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(10; "Adjusted Doc. Posting Date"; Date)
        {
            Caption = 'Adjusted Doc. Posting Date';
            DataClassification = CustomerContent;
        }
        field(11; Type; Enum Type)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(12; "No."; Code[20])
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
        field(13; "Product Type"; Enum "Product Type")
        {
            Caption = 'Product Type';
            DataClassification = CustomerContent;
        }
        field(14; "Source Type"; Enum "Source Type")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(15; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor;
        }
        field(16; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(17; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
        }
        field(18; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
            TableRelation = "GST Group";
        }
        field(19; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
        }
        field(20; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = CustomerContent;
        }
        field(21; "GST %"; Decimal)
        {
            Caption = 'GST %';
            DataClassification = CustomerContent;
        }
        field(22; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
        }
        field(23; "G/L Account"; Code[20])
        {
            Caption = 'G/L Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(24; "External Document No."; Code[40])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(25; Positive; Boolean)
        {
            Caption = 'Positive';
            DataClassification = CustomerContent;
        }
        field(26; "Location  Reg. No."; Code[20])
        {
            Caption = 'Location  Reg. No.';
            DataClassification = CustomerContent;
        }
        field(27; "Buyer/Seller Reg. No."; Code[20])
        {
            Caption = 'Buyer/Seller Reg. No.';
            DataClassification = CustomerContent;
        }
        field(28; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
        }
        field(29; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(30; "GST Rounding Precision"; Decimal)
        {
            Caption = 'GST Rounding Precision';
            DataClassification = CustomerContent;
        }
        field(31; "GST Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Rounding Type';
            DataClassification = CustomerContent;
        }
        field(32; "GST Vendor Type"; Enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(33; Cess; Boolean)
        {
            Caption = 'Cess';
            DataClassification = CustomerContent;
        }
        field(34; "Input Service Distribution"; Boolean)
        {
            Caption = 'Input Service Distribution';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(35; "Credit Availed"; Boolean)
        {
            Caption = 'Credit Availed';
            DataClassification = CustomerContent;
        }
        field(36; "Liable to Pay"; Boolean)
        {
            Caption = 'Liable to Pay';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(37; "Credit Adjustment Type"; Enum "Cr Libty Adjustment Type")
        {
            Caption = 'Credit Adjustment Type';
            DataClassification = CustomerContent;
        }
        field(38; Paid; Boolean)
        {
            Caption = 'Paid';
            DataClassification = CustomerContent;
        }
        field(39; "Payment Document No."; Code[20])
        {
            Caption = 'Payment Document No.';
            DataClassification = CustomerContent;
        }
        field(40; "Payment Document Date"; Date)
        {
            Caption = 'Payment Document Date';
            DataClassification = CustomerContent;
        }
        field(41; "Adjustment Document No."; Code[20])
        {
            Caption = 'Adjustment Document No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}
