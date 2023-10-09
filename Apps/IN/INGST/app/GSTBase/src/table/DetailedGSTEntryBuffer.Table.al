// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 18000 "Detailed GST Entry Buffer"
{
    Caption = 'Detailed GST Entry Buffer';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Document Type"; enum "Document Type Enum")
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
        }
        field(5; Type; enum Type)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
        }
        field(7; "Product Type"; enum "Product Type")
        {
            Caption = 'Product Type';
            DataClassification = SystemMetadata;
        }
        field(8; "Transaction Type"; enum "Transaction Type Enum")
        {
            Caption = 'Transaction Type';
            DataClassification = SystemMetadata;
        }
        field(9; "Source Type"; enum "Source Type")
        {
            Caption = 'Source Type';
            DataClassification = SystemMetadata;
        }
        field(10; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = SystemMetadata;
            TableRelation = if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Vendor)) Vendor;
        }
        field(11; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = SystemMetadata;
        }
        field(12; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = SystemMetadata;
        }
        field(13; "GST %"; Decimal)
        {
            Caption = 'GST %';
            DataClassification = SystemMetadata;
        }
        field(14; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = SystemMetadata;
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
        }
        field(16; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = SystemMetadata;
            TableRelation = "GST Group";
        }
        field(17; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = SystemMetadata;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(18; "GST Input/Output Credit Amount"; Decimal)
        {
            Caption = 'GST Input/Output Credit Amount';
            DataClassification = SystemMetadata;
        }
        field(19; "Amount Loaded on Item"; Decimal)
        {
            Caption = 'Amount Loaded on Item';
            DataClassification = SystemMetadata;
        }
        field(20; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(21; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(22; "Item Charge Assgn. Line No."; Integer)
        {
            Caption = 'Item Charge Assgn. Line No.';
            DataClassification = SystemMetadata;
        }
        field(24; "GST on Advance Payment"; Boolean)
        {
            Caption = 'GST on Advance Payment';
            DataClassification = SystemMetadata;
        }
        field(25; "Reverse Charge"; Boolean)
        {
            Caption = 'Reverse Charge';
            DataClassification = SystemMetadata;
        }
        field(26; "Item Charge Assgn. Doc. Type"; enum "Item Charge Assgn Doc Type")
        {
            Caption = 'Item Charge Assgn. Doc. Type';
            DataClassification = SystemMetadata;
        }
        field(27; "Item Charge Assgn Doc. No."; Code[20])
        {
            Caption = 'Item Charge Assgn Doc. No.';
            DataClassification = SystemMetadata;
        }
        field(28; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = SystemMetadata;
            TableRelation = "Gen. Journal Template";
        }
        field(29; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = SystemMetadata;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(30; "Bill Of Export No."; Code[20])
        {
            Caption = 'Bill Of Export No.';
            DataClassification = SystemMetadata;
        }
        field(31; "Bill Of Export Date"; Date)
        {
            Caption = 'Bill Of Export Date';
            DataClassification = SystemMetadata;
        }
        field(32; "e-Comm. Merchant Id"; Code[30])
        {
            Caption = 'e-Comm. Merchant Id';
            DataClassification = SystemMetadata;
        }
        field(33; "e-Comm. Operator GST Reg. No."; Code[20])
        {
            Caption = 'e-Comm. Operator GST Reg. No.';
            DataClassification = SystemMetadata;
        }
        field(34; "Invoice Type"; enum "Sales Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = SystemMetadata;
        }
        field(35; "Original Invoice No."; Code[20])
        {
            Caption = 'Original Invoice No.';
            DataClassification = SystemMetadata;
        }
        field(36; "Original Invoice Date"; Date)
        {
            Caption = 'Original Invoice Date';
            DataClassification = SystemMetadata;
        }
        field(37; "Adv. Pmt. Adjustment"; Boolean)
        {
            Caption = 'Adv. Pmt. Adjustment';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(38; "Original Adv. Pmt Doc. No."; Code[20])
        {
            Caption = 'Original Adv. Pmt Doc. No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(39; "Original Adv. Pmt Doc. Date"; Date)
        {
            Caption = 'Original Adv. Pmt Doc. Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(40; Cess; Boolean)
        {
            Caption = 'Cess';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(41; "GST Group Type"; enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(42; "Buyer/Seller State Code"; Code[10])
        {
            Caption = 'Buyer/Seller State Code';
            DataClassification = SystemMetadata;
            TableRelation = State;
        }
        field(43; "Shipping Address State Code"; Code[10])
        {
            Caption = 'Shipping Address State Code';
            DataClassification = SystemMetadata;
            TableRelation = State;
        }
        field(44; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = State;
        }
        field(45; "Location  Reg. No."; Code[20])
        {
            Caption = 'Location  Reg. No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(46; "Buyer/Seller Reg. No."; Code[20])
        {
            Caption = 'Buyer/Seller Reg. No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(47; "GST Place of Supply"; enum "GST Dependency Type")
        {
            Caption = 'GST Place of Supply';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(48; "Charge To Cust/Vend"; Decimal)
        {
            Caption = 'Charge To Cust/Vend';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(49; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
        }
        field(50; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = SystemMetadata;
            DecimalPlaces = 1 : 6;
        }
        field(51; "GST Rounding Precision"; Decimal)
        {
            Caption = 'GST Rounding Precision';
            DataClassification = SystemMetadata;
        }
        field(52; "GST Rounding Type"; enum "GST Inv Rounding Type")
        {
            Caption = 'GST Rounding Type';
            DataClassification = SystemMetadata;
        }
        field(53; "GST Base Amount (LCY)"; Decimal)
        {
            Caption = 'GST Base Amount (LCY)';
            DataClassification = SystemMetadata;
        }
        field(54; "GST Amount (LCY)"; Decimal)
        {
            Caption = 'GST Amount (LCY)';
            DataClassification = SystemMetadata;
        }
        field(55; "TDS/TCS Amount"; Decimal)
        {
            Caption = 'TDS/TCS Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(56; "Input Service Distribution"; Boolean)
        {
            Caption = 'Input Service Distribution';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(57; Inward; Boolean)
        {
            Caption = 'Inward';
            DataClassification = SystemMetadata;
        }
        field(58; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(59; "Delivery Challan Amount"; Decimal)
        {
            Caption = 'Delivery Challan Amount';
            DataClassification = SystemMetadata;
        }
        field(60; "Custom Duty Amount"; Decimal)
        {
            Caption = 'Custom Duty Amount';
            DataClassification = SystemMetadata;
        }
        field(61; "GST Assessable Value"; Decimal)
        {
            Caption = 'GST Assessable Value';
            DataClassification = SystemMetadata;
        }
        field(62; "Custom Duty Amount (LCY)"; Decimal)
        {
            Caption = 'Custom Duty Amount (LCY)';
            DataClassification = SystemMetadata;
        }
        field(63; "GST Assessable Value (LCY)"; Decimal)
        {
            Caption = 'GST Assessable Value (LCY)';
            DataClassification = SystemMetadata;
        }
        field(66; "Component Calc. Type"; enum "Component Calc Type")
        {
            Caption = 'Component Calc. Type';
            DataClassification = SystemMetadata;
        }
        field(67; "Cess Amount Per Unit Factor"; Decimal)
        {
            Caption = 'Cess Amount Per Unit Factor';
            DataClassification = SystemMetadata;
        }
        field(68; "Cess UOM"; Code[10])
        {
            Caption = 'Cess UOM';
            DataClassification = SystemMetadata;
            TableRelation = "Unit of Measure";
        }
        field(69; "Cess Factor Quantity"; Decimal)
        {
            Caption = 'Cess Factor Quantity';
            DataClassification = SystemMetadata;
        }
        field(70; "Cess Amt Per Unit Factor (LCY)"; Decimal)
        {
            Caption = 'Cess Amt Per Unit Factor (LCY)';
            DataClassification = SystemMetadata;
        }
        field(71; UOM; Code[10])
        {
            Caption = 'UOM';
            DataClassification = SystemMetadata;
            TableRelation = "Unit of Measure";
        }
        field(72; "Jnl. Bank Charge"; Code[10])
        {
            Caption = 'Bank Charge';
            DataClassification = SystemMetadata;
        }
        field(73; "Bank Charge Entry"; Boolean)
        {
            Caption = 'Bank Charge Entry';
            DataClassification = SystemMetadata;
        }
        field(74; "Non-Availment"; Boolean)
        {
            Caption = 'Non-Availment';
            DataClassification = SystemMetadata;
        }
        field(75; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            DataClassification = SystemMetadata;
        }
        field(76; "GST Inv. Rounding Type"; enum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = SystemMetadata;
        }
        field(77; "GST Order Address State"; Code[10])
        {
            Caption = 'GST Order Address State';
            DataClassification = SystemMetadata;
        }
        field(78; "Buy-From GST Registration No"; Code[20])
        {
            Caption = 'Buy-From GST Registration No';
            DataClassification = SystemMetadata;
        }
        field(79; "Order Address Code"; Code[10])
        {
            Caption = 'Order Address Code';
            DataClassification = SystemMetadata;
        }
        field(80; "Bill to-Location(POS)"; Code[10])
        {
            Caption = 'Bill to-Location(POS)';
            DataClassification = SystemMetadata;
        }
        field(85; "Recurring Journal"; Boolean)
        {
            Caption = 'Recurring Journal';
            DataClassification = SystemMetadata;
        }
        field(86; "Allocations Line No."; Integer)
        {
            Caption = 'Allocations Line No.';
            DataClassification = SystemMetadata;
        }
        field(87; "ARN No."; Code[20])
        {
            Caption = 'ARN No.';
            DataClassification = SystemMetadata;
        }
        field(88; "FA Journal Entry"; Boolean)
        {
            Caption = 'FA Journal Entry';
            DataClassification = SystemMetadata;
        }
        field(89; "Without Bill Of Entry"; Boolean)
        {
            Caption = 'Without Bill Of Entry';
            DataClassification = SystemMetadata;
        }
        field(90; "Finance Charge Memo"; Boolean)
        {
            Caption = 'Finance Charge Memo';
            DataClassification = SystemMetadata;
        }
        field(91; "GST TDS"; Boolean)
        {
            Caption = 'GST TDS';
            DataClassification = SystemMetadata;
        }
        field(92; "GST TCS"; Boolean)
        {
            Caption = 'GST TCS';
            DataClassification = SystemMetadata;
        }
        field(93; "POS Out Of India"; Boolean)
        {
            Caption = 'POS Out Of India';
            DataClassification = SystemMetadata;
        }
        field(94; "External Document No."; Code[40])
        {
            Caption = 'External Document No.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Transaction Type", "Document Type", "Document No.", "Line No.")
        {
        }
        key(Key3; "Transaction Type", "Journal Template Name", "Journal Batch Name", "Line No.")
        {
        }
    }
}
