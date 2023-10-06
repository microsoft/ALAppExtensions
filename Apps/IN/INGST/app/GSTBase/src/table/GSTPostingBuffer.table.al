// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;

table 18006 "GST Posting Buffer"
{
    Caption = 'GST Posting Buffer';

    fields
    {
        field(1; Type; enum Type)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
        }
        field(2; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = SystemMetadata;
            TableRelation = "Gen. Business Posting Group";
        }
        field(3; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = SystemMetadata;
            TableRelation = "Gen. Product Posting Group";
        }
        field(4; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = SystemMetadata;
        }
        field(5; "GST Reverse Charge"; Boolean)
        {
            Caption = 'GST Reverse Charge';
            DataClassification = SystemMetadata;
        }
        field(6; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = SystemMetadata;
            TableRelation = "GST Group";
        }
        field(7; "Party Code"; Code[20])
        {
            Caption = 'Party Code';
            DataClassification = SystemMetadata;
        }
        field(8; "GST Base Amount"; Decimal)
        {
            Caption = 'GST Base Amount';
            DataClassification = SystemMetadata;
        }
        field(9; "GST %"; Decimal)
        {
            Caption = 'GST %';
            DataClassification = SystemMetadata;
        }
        field(10; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = SystemMetadata;
        }
        field(11; "Interim Amount"; Decimal)
        {
            Caption = 'Interim Amount';
            DataClassification = SystemMetadata;
        }
        field(12; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = SystemMetadata;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(13; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = SystemMetadata;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(14; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account";
        }
        field(15; "Interim Account No."; Code[20])
        {
            Caption = 'Interim Account No.';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account";
        }
        field(16; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account";
        }
        field(17; "Transaction Type"; enum "Buffer Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = SystemMetadata;
        }
        field(18; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = SystemMetadata;
        }
        field(19; "Custom Duty Amount"; Decimal)
        {
            Caption = 'Custom Duty Amount';
            DataClassification = SystemMetadata;
        }
        field(20; Availment; Boolean)
        {
            Caption = 'Availment';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(21; "Normal Payment"; Boolean)
        {
            Caption = 'Normal Payment';
            DataClassification = SystemMetadata;
        }
        field(22; "GST Amount (LCY)"; Decimal)
        {
            Caption = 'GST Amount (LCY)';
            DataClassification = SystemMetadata;
        }
        field(23; "Higher Inv. Exchange Rate"; Boolean)
        {
            Caption = 'Higher Inv. Exchange Rate';
            DataClassification = SystemMetadata;
        }
        field(24; "Forex Fluctuation"; Boolean)
        {
            Caption = 'Forex Fluctuation';
            DataClassification = SystemMetadata;
        }
        field(25; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = SystemMetadata;
        }
        field(26; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = SystemMetadata;
        }
        field(27; "External Document No."; Code[40])
        {
            Caption = 'External Document No.';
            DataClassification = SystemMetadata;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
    }

    keys
    {
        key(Key1; "Transaction Type", Type, "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "GST Component Code", "GST Group Type", "Account No.", "Dimension Set ID", "GST Reverse Charge", Availment, "Normal Payment", "Forex Fluctuation", "Document Line No.")
        {
            Clustered = true;
        }
    }
}
