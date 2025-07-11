// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.AuditCodes;

table 18005 "GST Ledger Entry"
{
    Caption = 'GST Ledger Entry';
    LookupPageId = "GST Ledger Entry";
    DrillDownPageId = "GST Ledger Entry";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = True;
        }
        field(2; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(3; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(7; "Document Type"; Enum "Detail GST Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(8; "Transaction Type"; enum "GST Ledger Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(9; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = CustomerContent;
        }
        field(10; "Source Type"; enum "GST Ledger Source Type")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(11; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
        }
        field(12; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(13; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(14; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(15; "Purchase Group Type"; enum "Purchase Group Type")
        {
            Caption = 'Purchase Group Type';
            DataClassification = CustomerContent;
        }
        field(18; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(19; "External Document No."; Code[45])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(20; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
        }
        field(25; "GST on Advance Payment"; Boolean)
        {
            Caption = 'GST on Advance Payment';
            DataClassification = CustomerContent;
        }
        field(26; "Reverse Charge"; Boolean)
        {
            Caption = 'Reverse Charge';
            DataClassification = CustomerContent;
        }
        field(27; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
        }
        field(28; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(29; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 1 : 6;
            DataClassification = CustomerContent;
        }
        field(30; Reversed; Boolean)
        {
            Caption = 'Reversed';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(31; "Reversed Entry No."; Integer)
        {
            Caption = 'Reversed Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(32; "Reversed by Entry No."; Integer)
        {
            Caption = 'Reversed by Entry No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(33; UnApplied; Boolean)
        {
            Caption = 'UnApplied';
            DataClassification = CustomerContent;
        }
        field(34; "Entry Type"; Enum "Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(35; "Payment Type"; Enum "Payment Type")
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
        }
        field(36; "Input Service Distribution"; Boolean)
        {
            Caption = 'Input Service Distribution';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(37; Availment; Boolean)
        {
            Caption = 'Availment';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(38; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(39; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(40; "Bal. Account No. 2"; Code[20])
        {
            Caption = 'Bal. Account No. 2';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(41; "Account No. 2"; Code[20])
        {
            Caption = 'Account No. 2';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(42; "POS Out Of India"; Boolean)
        {
            Caption = 'POS Out Of India';
            DataClassification = CustomerContent;
        }
        field(43; "G/L Entry No."; Integer)
        {
            Caption = 'G/L Entry No.';
            DataClassification = CustomerContent;
            Editable = False;
        }
        field(44; "Skip Tax Engine Trigger"; Boolean)
        {
            Caption = 'Skip Tax Engine Trigger';
            DataClassification = CustomerContent;
            Editable = False;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Transaction No.")
        {
        }
        key(Key3; "Transaction Type", "Transaction No.", "Source No.", "Entry Type", "Document Type", "Document No.", "GST Component Code")
        {
        }
    }
}
