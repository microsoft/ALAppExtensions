// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Currency;

using Microsoft.Finance.GeneralLedger.Journal;

table 11795 "Adj. Exchange Rate Buffer CZL"
{
    Caption = 'Adjust Exchange Rate Buffer Extended';
    ReplicateData = false;
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(2; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
        }
        field(3; AdjBase; Decimal)
        {
            Caption = 'AdjBase';
        }
        field(4; AdjBaseLCY; Decimal)
        {
            Caption = 'AdjBaseLCY';
        }
        field(5; AdjAmount; Decimal)
        {
            Caption = 'AdjAmount';
        }
        field(6; TotalGainsAmount; Decimal)
        {
            Caption = 'TotalGainsAmount';
        }
        field(7; TotalLossesAmount; Decimal)
        {
            Caption = 'TotalLossesAmount';
        }
        field(8; "Dimension Entry No."; Integer)
        {
            Caption = 'Dimension Entry No.';
        }
        field(9; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(10; "IC Partner Code"; Code[20])
        {
            Caption = 'IC Partner Code';
        }
        field(11; Index; Integer)
        {
            Caption = 'Index';
        }
        field(11760; "Initial G/L Account No."; Code[20])
        {
            Caption = 'Initial G/L Account No.';
        }
        field(11765; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
        }
        field(11766; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(31000; Advance; Boolean)
        {
            Caption = 'Advance';
        }
    }

    keys
    {
        key(Key1; "Currency Code", "Posting Group", "Dimension Entry No.", "Posting Date", "IC Partner Code", Advance, "Initial G/L Account No.")
        {
            Clustered = true;
        }
    }
}
