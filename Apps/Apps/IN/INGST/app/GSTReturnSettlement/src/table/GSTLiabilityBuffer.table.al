// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Finance.GST.Base;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 18320 "GST Liability Buffer"
{
    Caption = 'GST Liability Buffer';

    fields
    {
        field(1; "Transaction Type"; Enum "Detail Ledger Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(2; "Original Document Type"; Enum "Current Doc. Type")
        {
            Caption = 'Original Document Type';
            DataClassification = CustomerContent;
        }
        field(3; "Original Document No."; Code[20])
        {
            Caption = 'Original Document No.';
            DataClassification = CustomerContent;
        }
        field(4; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
        }
        field(5; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
        }
        field(6; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = CustomerContent;
        }
        field(7; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
        }
        field(8; "Applied Doc. Type"; Enum "Current Doc. Type")
        {
            Caption = 'Applied Doc. Type';
            DataClassification = CustomerContent;
        }
        field(9; "Applied Doc. No."; Code[20])
        {
            Caption = 'Applied Doc. No.';
            DataClassification = CustomerContent;
        }
        field(10; "Applied Amount"; Decimal)
        {
            Caption = 'Applied Amount';
            DataClassification = CustomerContent;
        }
        field(11; "Current Doc. Type"; Enum "GST Document Type")
        {
            Caption = 'Current Doc. Type';
            DataClassification = CustomerContent;
        }
        field(12; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(13; "Application Type"; Enum "Application Type")
        {
            Caption = 'Application Type';
            DataClassification = CustomerContent;
        }
        field(14; "Applied Doc. Type(Posted)"; Enum "Current Doc. Type")
        {
            Caption = 'Applied Doc. Type(Posted)';
            DataClassification = CustomerContent;
        }
        field(15; "Applied Doc. No.(Posted)"; Code[20])
        {
            Caption = 'Applied Doc. No.(Posted)';
            DataClassification = CustomerContent;
        }
        field(16; "GST Group Type"; enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
        }
        field(17; "CLE/VLE Entry No."; Integer)
        {
            Caption = 'CLE/VLE Entry No.';
            DataClassification = CustomerContent;
        }
        field(18; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = if ("Transaction Type" = const(Purchase)) Vendor."No."
            else
            if ("Transaction Type" = const(Sales)) Customer."No.";
        }
        field(19; "Applied Base Amount"; Decimal)
        {
            Caption = 'Applied Base Amount';
            DataClassification = CustomerContent;
        }
        field(20; "GST Cess"; Boolean)
        {
            Caption = 'GST Cess';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "Charge To Cust/Vend"; Decimal)
        {
            Caption = 'Charge To Cust/Vend';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(23; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 1 : 6;
        }
        field(24; "GST Rounding Precision"; Decimal)
        {
            Caption = 'GST Rounding Precision';
            DataClassification = CustomerContent;
        }
        field(25; "GST Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Rounding Type';
            DataClassification = CustomerContent;
        }
        field(26; "TDS/TCS Amount"; Decimal)
        {
            Caption = 'TDS/TCS Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(28; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
        }
        field(29; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            DataClassification = CustomerContent;
        }
        field(30; "GST Inv. Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = CustomerContent;
        }
        field(31; "RCM Exempt"; Boolean)
        {
            Caption = 'RCM Exempt';
            DataClassification = CustomerContent;
        }
        field(32; "GST %"; Decimal)
        {
            Caption = 'GST %';
            DataClassification = CustomerContent;
        }
        field(33; "Credit Amount"; Decimal)
        {
            Caption = 'Credit Amount';
            DataClassification = CustomerContent;
        }
        field(34; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
        }
        field(35; "Original Line No."; Integer)
        {
            Caption = 'Original Line No.';
            DataClassification = CustomerContent;
        }
        field(36; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Transaction Type", "Account No.", "Original Document Type", "Original Document No.", "Transaction No.", "GST Group Code", Exempted, "GST Component Code")
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
