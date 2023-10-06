// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.ReturnSettlement;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 18430 "GST Application Buffer"
{
    Caption = 'GST Application Buffer';

    fields
    {
        field(1; "Transaction Type"; Enum "Detail Ledger Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = SystemMetadata;
        }
        field(2; "Original Document Type"; Enum "Original Doc Type")
        {
            Caption = 'Original Document Type';
            DataClassification = SystemMetadata;
        }
        field(3; "Original Document No."; Code[20])
        {
            Caption = 'Original Document No.';
            DataClassification = SystemMetadata;
        }
        field(4; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = SystemMetadata;
        }
        field(5; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = SystemMetadata;
        }
        field(6; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = SystemMetadata;
        }
        field(7; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = SystemMetadata;
        }
        field(8; "Applied Doc. Type"; Enum "Current Doc. Type")
        {
            Caption = 'Applied Doc. Type';
            DataClassification = SystemMetadata;
        }
        field(9; "Applied Doc. No."; Code[20])
        {
            Caption = 'Applied Doc. No.';
            DataClassification = SystemMetadata;
        }
        field(10; "Applied Amount"; Decimal)
        {
            Caption = 'Applied Amount';
            DataClassification = SystemMetadata;
        }
        field(11; "Current Doc. Type"; Enum "GST Document Type")
        {
            Caption = 'Current Doc. Type';
            DataClassification = SystemMetadata;
        }
        field(12; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = SystemMetadata;
        }
        field(13; "Application Type"; Enum "Application Type")
        {
            Caption = 'Application Type';
            DataClassification = SystemMetadata;
        }
        field(14; "Applied Doc. Type(Posted)"; Enum "Current Doc. Type")
        {
            Caption = 'Applied Doc. Type(Posted)';
            DataClassification = SystemMetadata;
        }
        field(15; "Applied Doc. No.(Posted)"; Code[20])
        {
            Caption = 'Applied Doc. No.(Posted)';
            DataClassification = SystemMetadata;
        }
        field(16; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = SystemMetadata;
        }
        field(17; "CLE/VLE Entry No."; Integer)
        {
            Caption = 'CLE/VLE Entry No.';
            DataClassification = SystemMetadata;
        }
        field(18; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = if ("Transaction Type" = const(Purchase)) Vendor."No."
            else
            if ("Transaction Type" = const(Sales)) Customer."No.";
        }
        field(19; "Applied Base Amount"; Decimal)
        {
            Caption = 'Applied Base Amount';
            DataClassification = SystemMetadata;
        }
        field(20; "GST Cess"; Boolean)
        {
            Caption = 'GST Cess';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(21; "Charge To Cust/Vend"; Decimal)
        {
            Caption = 'Charge To Cust/Vend';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(22; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
        }
        field(23; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = SystemMetadata;
            DecimalPlaces = 1 : 6;
        }
        field(24; "GST Rounding Precision"; Decimal)
        {
            Caption = 'GST Rounding Precision';
            DataClassification = SystemMetadata;
        }
        field(25; "GST Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Rounding Type';
            DataClassification = SystemMetadata;
        }
        field(26; "TDS/TCS Amount"; Decimal)
        {
            Caption = 'TDS/TCS Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(27; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = SystemMetadata;
        }
        field(28; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = SystemMetadata;
        }
        field(29; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            DataClassification = SystemMetadata;
        }
        field(30; "GST Inv. Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = SystemMetadata;
        }
        field(31; "RCM Exempt"; Boolean)
        {
            Caption = 'RCM Exempt';
            DataClassification = SystemMetadata;
        }
        field(32; "GST Base Amount(LCY)"; Decimal)
        {
            Caption = 'GST Base Amount(LCY)';
            DataClassification = SystemMetadata;
        }
        field(33; "GST Amount(LCY)"; Decimal)
        {
            Caption = 'GST Amount(LCY)';
            DataClassification = SystemMetadata;
        }
        field(34; "GST %"; Decimal)
        {
            Caption = 'GST %';
            DataClassification = SystemMetadata;
        }
        field(35; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
        }
        field(36; "Amt to Apply"; Decimal)
        {
            Caption = 'Amt to Apply';
            DataClassification = SystemMetadata;
        }
        field(37; "Amt to Apply (Applied)"; Decimal)
        {
            Caption = 'Amt to Apply (Applied)';
            DataClassification = SystemMetadata;
        }
        field(38; "Total Base(LCY)"; Decimal)
        {
            Caption = 'Total Base(LCY)';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Transaction Type", "Account No.", "Original Document Type", "Original Document No.", "Transaction No.", "GST Group Code", "GST Component Code")
        {
            Clustered = true;
        }
        key(Key2; "Transaction No.", "CLE/VLE Entry No.")
        {
        }
        key(Key3; "CLE/VLE Entry No.")
        {
        }
    }
}
