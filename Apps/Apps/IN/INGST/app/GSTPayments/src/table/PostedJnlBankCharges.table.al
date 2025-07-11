// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;

table 18248 "Posted Jnl. Bank Charges"
{
    Caption = 'Posted Jnl. Bank Charges';

    fields
    {
        field(1; "GL Entry No."; Integer)
        {
            Caption = 'GL Entry No.';
            Editable = false;
            TableRelation = "G/L Entry";
            DataClassification = SystemMetadata;
        }
        field(2; "Bank Charge"; Code[10])
        {
            Caption = 'Bank Charge';
            Editable = false;
            TableRelation = "Bank Charge";
            DataClassification = CustomerContent;
        }
        field(3; Amount; Decimal)
        {
            Caption = 'Amount';
            Editable = false;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(4; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(6; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(7; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
            TableRelation = "GST Group" where(
                "GST Group Type" = filter(Service),
                "Reverse Charge" = filter(false));
        }
        field(8; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Foreign Exchange"; Boolean)
        {
            Caption = 'Foreign Exchange';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(14; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
        field(15; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(16; "GST Jurisdiction Type"; ENum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
        }
        field(17; "GST Bill to/Buy From State"; Code[10])
        {
            Caption = 'GST Bill to/Buy From State';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(18; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(19; "Location  Reg. No."; Code[20])
        {
            Caption = 'Location  Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "GST Registration Status"; Enum "Bank Registration Status")
        {
            Caption = 'GST Registration Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; "GST Inv. Rounding Type"; ENum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(23; "Nature of Supply"; Enum "GST Nature of Supply")
        {
            Caption = 'Nature of Supply';
            DataClassification = CustomerContent;
        }
        field(24; "External Document No."; Code[40])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(25; LCY; Boolean)
        {
            Caption = 'LCY';
            DataClassification = CustomerContent;
        }
        field(26; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(27; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = CustomerContent;
        }
        field(28; "GST Document Type"; Enum "BankCharges DocumentType")
        {
            Caption = 'GST Document Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "GL Entry No.", "Bank Charge")
        {
            Clustered = true;
        }
    }
}
