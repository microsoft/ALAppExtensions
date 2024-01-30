// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Finance.GeneralLedger.Account;
using System.Security.AccessControl;

table 31283 "Detailed G/L Entry CZA"
{
    Caption = 'Detailed G/L Entry';
    DataCaptionFields = "G/L Account No.";
    DrillDownPageID = "Detailed G/L Entries CZA";
    LookupPageID = "Detailed G/L Entries CZA";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "G/L Entry No."; Integer)
        {
            Caption = 'G/L Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Entry"."Entry No.";
        }
        field(3; "Applied G/L Entry No."; Integer)
        {
            Caption = 'Applied G/L Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Entry"."Entry No.";
        }
        field(4; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
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
        field(7; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(8; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(9; Unapplied; Boolean)
        {
            Caption = 'Unapplied';
            DataClassification = CustomerContent;
        }
        field(10; "Unapplied by Entry No."; Integer)
        {
            Caption = 'Unapplied by Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Detailed G/L Entry CZA";
        }
        field(11; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }

        key(Key2; "G/L Entry No.", "Posting Date")
        {
            SumIndexFields = Amount;
        }
        key(Key3; "Document No.", "Posting Date")
        {
            SumIndexFields = Amount;
        }
        key(key4; "Transaction No.")
        {
        }
    }
}
