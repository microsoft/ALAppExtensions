// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.TaxBase;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Ledger;
using Microsoft.Sales.Customer;

table 18016 "Detailed GST Ledger Entry Info"
{
    Caption = 'Detailed GST Ledger Entry Information';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(3; Positive; Boolean)
        {
            Caption = 'Positive';
            DataClassification = CustomerContent;
        }
        field(4; "Nature of Supply"; Enum "GST Nature of Supply")
        {
            Caption = 'Nature of Supply';
            DataClassification = CustomerContent;
        }
        field(5; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
        }
        field(6; "Buyer/Seller State Code"; Code[10])
        {
            Caption = 'Buyer/Seller State Code';
            TableRelation = State;
            DataClassification = CustomerContent;
        }
        field(7; "Shipping Address State Code"; Code[10])
        {
            Caption = 'Shipping Address State Code';
            TableRelation = State;
            DataClassification = CustomerContent;
        }
        field(8; "Original Doc. Type"; enum "Original Doc Type")
        {
            Caption = 'Original Doc. Type';
            DataClassification = CustomerContent;
        }
        field(9; "Original Doc. No."; Code[20])
        {
            Caption = 'Original Doc. No.';
            DataClassification = CustomerContent;
        }
        field(10; "CLE/VLE Entry No."; Integer)
        {
            Caption = 'CLE/VLE Entry No.';
            DataClassification = CustomerContent;
        }
        field(11; "Bill Of Export No."; Code[20])
        {
            Caption = 'Bill Of Export No.';
            DataClassification = CustomerContent;
        }
        field(12; "Bill Of Export Date"; Date)
        {
            Caption = 'Bill Of Export Date';
            DataClassification = CustomerContent;
        }
        field(13; "e-Comm. Merchant Id"; Code[30])
        {
            Caption = 'e-Comm. Merchant Id';
            DataClassification = CustomerContent;
        }
        field(14; "e-Comm. Operator GST Reg. No."; Code[20])
        {
            Caption = 'e-Comm. Operator GST Reg. No.';
            DataClassification = CustomerContent;
        }
        field(15; "Sales Invoice Type"; Enum "Sales Invoice Type")
        {
            Caption = 'Sales Invoice Type';
            DataClassification = CustomerContent;
        }
        field(16; "Original Invoice Date"; Date)
        {
            Caption = 'Original Invoice Date';
            DataClassification = CustomerContent;
        }
        field(17; "Amount to Customer/Vendor"; Decimal)
        {
            Caption = 'Amount to Customer/Vendor';
            DataClassification = CustomerContent;
        }
        field(18; "Adv. Pmt. Adjustment"; Boolean)
        {
            Caption = 'Adv. Pmt. Adjustment';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "Payment Document Date"; Date)
        {
            Caption = 'Payment Document Date';
            DataClassification = CustomerContent;
        }
        field(22; Cess; Boolean)
        {
            Caption = 'Cess';
            DataClassification = CustomerContent;
        }
        field(23; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            Editable = false;
            TableRelation = "Item Ledger Entry" where("Entry No." = field("Item Ledger Entry No."));
            DataClassification = CustomerContent;
        }
        field(24; "Credit Reversal"; Enum "Credit Reversal")
        {
            Caption = 'Credit Reversal';
            DataClassification = CustomerContent;
        }
        field(25; "Item Charge Assgn. Line No."; Integer)
        {
            Caption = 'Item Charge Assgn. Line No.';
            DataClassification = CustomerContent;
        }
        field(26; "Delivery Challan Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Delivery Challan Amount';
        }
        field(27; "Subcon Document No."; Code[20])
        {
            Caption = 'Subcon Document No.';
            DataClassification = CustomerContent;
        }
        field(28; "Component Calc. Type"; Enum "Component Calc Type")
        {
            Caption = 'Component Calc. Type';
            DataClassification = CustomerContent;
        }
        field(29; "Cess Amount Per Unit Factor"; Decimal)
        {
            Caption = 'Cess Amount Per Unit Factor';
            DataClassification = CustomerContent;
        }
        field(30; "Cess UOM"; Code[10])
        {
            Caption = 'Cess UOM';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }
        field(31; "Cess Factor Quantity"; Decimal)
        {
            Caption = 'Cess Factor Quantity';
            DataClassification = CustomerContent;
        }
        field(32; "Purchase Invoice Type"; Enum "GST Invoice Type")
        {
            Caption = 'Purchase Invoice Type';
            DataClassification = CustomerContent;
        }
        field(33; "Allocations Line No."; Integer)
        {
            Caption = 'Allocations Line No.';
            DataClassification = CustomerContent;
        }
        field(34; "Adjustment Type"; Enum "Adjustment Type")
        {
            Caption = 'Adjustment Type';
            DataClassification = CustomerContent;
        }
        field(35; "Rate Change Applicable"; Boolean)
        {
            Caption = 'Rate Change Applicable';
            DataClassification = CustomerContent;
        }
        field(36; "Remaining Amount Closed"; Boolean)
        {
            Caption = 'Remaining Amount Closed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(37; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Gen. Business Posting Group";
        }
        field(38; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Gen. Product Posting Group";
        }
        field(39; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Reason Code";
        }
        field(40; "Last Credit Adjusted Date"; Date)
        {
            Caption = 'Last Credit Adjusted Date';
            DataClassification = CustomerContent;
        }
        field(41; UOM; Code[10])
        {
            Caption = 'UOM';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }
        field(42; "Bank Charge Entry"; Boolean)
        {
            Caption = 'Bank Charge Entry';
            DataClassification = CustomerContent;
        }
        field(43; "Foreign Exchange"; Boolean)
        {
            Caption = 'Foreign Exchange';
            DataClassification = CustomerContent;
        }
        field(44; "Bill of Entry No."; Text[20])
        {
            Caption = 'Bill of Entry No.';
            DataClassification = CustomerContent;
        }
        field(45; "Bill of Entry Date"; Date)
        {
            Caption = 'Bill of Entry Date';
            DataClassification = CustomerContent;
        }
        field(47; "Jnl. Bank Charge"; Code[10])
        {
            Caption = 'Bank Charge';
            TableRelation = "Bank Charge";
            DataClassification = CustomerContent;
        }
        field(48; "GST Reason Type"; Enum "GST Reason Type")
        {
            Caption = 'GST Reason Type';
            DataClassification = CustomerContent;
        }
        field(49; "RCM Exempt"; Boolean)
        {
            Caption = 'RCM Exempt';
            DataClassification = CustomerContent;
        }
        field(50; "RCM Exempt Transaction"; Boolean)
        {
            Caption = 'RCM Exempt Transaction';
            DataClassification = CustomerContent;
        }
        field(51; "Order Address Code"; Code[10])
        {
            Caption = 'Order Address Code';
            DataClassification = CustomerContent;
        }
        field(52; "Bill to-Location(POS)"; Code[10])
        {
            Caption = 'Bill to-Location(POS)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(53; "Recurring Journal"; Boolean)
        {
            Caption = 'Recurring Journal';
            DataClassification = CustomerContent;
        }
        field(54; "GST Journal Type"; Enum "GST Journal Type")
        {
            Caption = 'GST Journal Type';
            DataClassification = CustomerContent;
        }
        field(55; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code;
            DataClassification = CustomerContent;
        }
        field(56; "FA Journal Entry"; Boolean)
        {
            Caption = 'FA Journal Entry';
            DataClassification = CustomerContent;
        }
        field(57; "Without Bill Of Entry"; Boolean)
        {
            Caption = 'Without Bill Of Entry';
            DataClassification = CustomerContent;
        }
        field(58; "Finance Charge Memo"; Boolean)
        {
            Caption = 'Finance Charge Memo';
            DataClassification = CustomerContent;
        }
        field(59; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "Depreciation Book";
            DataClassification = CustomerContent;
        }
        field(60; "Location ARN No."; Code[20])
        {
            Caption = 'Location ARN No.';
            DataClassification = CustomerContent;
        }
        field(61; "GST Base Amount FCY"; Decimal)
        {
            Caption = 'GST Base Amount FCY';
            DataClassification = CustomerContent;
        }
        field(62; "GST Amount FCY"; Decimal)
        {
            Caption = 'GST Amount FCY';
            DataClassification = CustomerContent;
        }
        field(63; "POS as Vendor State"; Boolean)
        {
            Caption = 'POS as Vendor State';
            DataClassification = CustomerContent;
        }
        field(64; "POS Out Of India"; Boolean)
        {
            Caption = 'POS Out Of India';
            DataClassification = CustomerContent;
        }
        field(65; "Ship-to Customer"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Customer';
        }
        field(66; "Ship-to GST Customer Type"; Enum "GST Customer Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to GST Customer Type';
        }
        field(67; "Ship-to Reg. No"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Reg. No';
        }
        field(68; "From Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'From Location Code';
        }
        field(69; "To Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'To Location Code';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
