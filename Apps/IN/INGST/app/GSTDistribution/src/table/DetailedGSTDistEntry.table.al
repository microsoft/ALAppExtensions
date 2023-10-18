// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GST.Base;

table 18200 "Detailed GST Dist. Entry"
{
    Caption = 'Detailed GST Dist. Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Detailed GST Ledger Entry No."; Integer)
        {
            Caption = 'Detailed GST Ledger Entry No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Dist. Location Code"; Code[10])
        {
            Caption = 'Dist. Location Code';
            DataClassification = CustomerContent;
        }
        field(4; "Dist. Location State Code"; Code[10])
        {
            Caption = 'Dist. Location State  Code';
            DataClassification = CustomerContent;
        }
        field(5; "Dist. GST Regn. No."; Code[20])
        {
            Caption = 'Dist. GST Regn. No.';
            DataClassification = CustomerContent;
        }
        field(6; "Dist. GST Credit"; Enum "GST credit")
        {
            Caption = 'Dist. GST Credit';
            DataClassification = CustomerContent;
        }
        field(7; "ISD Document Type"; Enum "Adjustment Document Type")
        {
            Caption = 'ISD Document Type';
            DataClassification = CustomerContent;
        }
        field(8; "ISD Document No."; Code[20])
        {
            Caption = 'ISD Document No.';
            DataClassification = CustomerContent;
        }
        field(9; "ISD Posting Date"; Date)
        {
            Caption = 'ISD Posting Date';
            DataClassification = CustomerContent;
        }
        field(10; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
        }
        field(11; "Supplier GST Reg. No."; Code[20])
        {
            Caption = 'Supplier GST Reg. No.';
            DataClassification = CustomerContent;
        }
        field(12; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
        }
        field(13; "Vendor Address"; Text[100])
        {
            Caption = 'Vendor Address';
            DataClassification = CustomerContent;
        }
        field(14; "Vendor State Code"; Code[10])
        {
            Caption = 'Vendor State Code';
            DataClassification = CustomerContent;
        }
        field(15; "Document Type"; Enum "GST Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(16; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(17; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(18; "Vendor Invoice No."; Code[40])
        {
            Caption = 'Vendor Invoice No.';
            DataClassification = CustomerContent;
        }
        field(19; "Vendor Document Date"; Date)
        {
            Caption = 'Vendor Document Date';
            DataClassification = CustomerContent;
        }
        field(20; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = CustomerContent;
        }
        field(21; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
        }
        field(22; "GST %"; Decimal)
        {
            Caption = 'GST%';
            DataClassification = CustomerContent;
        }
        field(23; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
        }
        field(24; "Rcpt. Location Code"; Code[10])
        {
            Caption = 'Rcpt. Location Code';
            DataClassification = CustomerContent;
        }
        field(25; "Rcpt. GST Reg. No."; Code[20])
        {
            Caption = 'Rcpt. GST Reg. No.';
            DataClassification = CustomerContent;
        }
        field(26; "Rcpt. Location State Code"; Code[10])
        {
            Caption = 'Rcpt. Location State Code';
            DataClassification = CustomerContent;
        }
        field(27; "Rcpt. GST Credit"; Enum "GST Credit")
        {
            Caption = 'Rcpt. GST Credit';
            DataClassification = CustomerContent;
        }
        field(28; "Distribution Jurisdiction"; Enum "GST Jurisdiction Type")
        {
            Caption = 'Distribution Jurisdiction';
            DataClassification = CustomerContent;
        }
        field(29; "Location Distribution %"; Decimal)
        {
            Caption = 'Location Distribution %';
            DataClassification = CustomerContent;
        }
        field(30; "Distributed Component Code"; Code[30])
        {
            Caption = 'Distributed Component Code';
            DataClassification = CustomerContent;
        }
        field(31; "Rcpt. Component Code"; Code[30])
        {
            Caption = 'Rcpt. Component Code';
            DataClassification = CustomerContent;
        }
        field(32; "Distribution Amount"; Decimal)
        {
            Caption = 'Distribution Amount';
            DataClassification = CustomerContent;
        }
        field(33; "Pre Dist. Invoice No."; Code[20])
        {
            Caption = 'Pre Dist. Invoice No.';
            DataClassification = CustomerContent;
        }
        field(36; Reversal; Boolean)
        {
            Caption = 'Reversal';
            DataClassification = CustomerContent;
        }
        field(37; "Reversal Date"; Date)
        {
            Caption = 'Reversal Date';
            DataClassification = CustomerContent;
        }
        field(38; "Original Dist. Invoice No."; Code[20])
        {
            Caption = 'Original Dist. Invoice No.';
            DataClassification = CustomerContent;
        }
        field(39; "Original Dist. Invoice Date"; Date)
        {
            Caption = 'Original Dist. Invoice Date';
            DataClassification = CustomerContent;
        }
        field(40; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(41; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(42; "GST Rounding Precision"; Decimal)
        {
            Caption = 'GST Rounding Precision';
            DataClassification = CustomerContent;
        }
        field(43; "GST Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Rounding Type';
            DataClassification = CustomerContent;
        }
        field(44; Cess; Boolean)
        {
            Caption = 'Cess';
            DataClassification = CustomerContent;
        }
        field(45; Paid; Boolean)
        {
            Caption = 'Paid';
            DataClassification = CustomerContent;
        }
        field(46; "Credit Availed"; Boolean)
        {
            Caption = 'Credit Availed';
            DataClassification = CustomerContent;
        }
        field(47; "Payment Document No."; Code[20])
        {
            Caption = 'Payment Document No.';
            DataClassification = CustomerContent;
        }
        field(48; "Payment Document Date"; Date)
        {
            Caption = 'Payment Document Date';
            DataClassification = CustomerContent;
        }
        field(49; "Invoice Type"; Enum "GST Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
        }
        field(50; "Service Account No."; Code[20])
        {
            Caption = 'Service Account No.';
            DataClassification = CustomerContent;
            Editable = false;
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
