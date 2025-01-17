// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

table 31112 "Acc. Schedule Result Col. CZL"
{
    Caption = 'Acc. Schedule Result Column';

    fields
    {
        field(1; "Result Code"; Code[20])
        {
            Caption = 'Result Code';
            DataClassification = CustomerContent;
            TableRelation = "Acc. Schedule Result Hdr. CZL";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Column No."; Code[10])
        {
            Caption = 'Column No.';
            DataClassification = CustomerContent;
        }
        field(4; "Column Header"; Text[50])
        {
            Caption = 'Column Header';
            DataClassification = CustomerContent;
        }
        field(5; "Column Type"; Enum "Column Layout Type")
        {
            Caption = 'Column Type';
            DataClassification = CustomerContent;
            InitValue = "Net Change";
        }
        field(6; "Ledger Entry Type"; Enum "Column Layout Entry Type")
        {
            Caption = 'Ledger Entry Type';
            DataClassification = CustomerContent;
        }
        field(7; "Amount Type"; Enum "Account Schedule Amount Type")
        {
            Caption = 'Amount Type';
            DataClassification = CustomerContent;
        }
        field(8; Formula; Code[80])
        {
            Caption = 'Formula';
            DataClassification = CustomerContent;
        }
        field(9; "Comparison Date Formula"; DateFormula)
        {
            Caption = 'Comparison Date Formula';
            DataClassification = CustomerContent;
        }
        field(10; "Show Opposite Sign"; Boolean)
        {
            Caption = 'Show Opposite Sign';
            DataClassification = CustomerContent;
        }
        field(11; Show; Option)
        {
            Caption = 'Show';
            DataClassification = CustomerContent;
            InitValue = Always;
            NotBlank = true;
            OptionCaption = 'Always,Never,When Positive,When Negative';
            OptionMembers = Always,Never,"When Positive","When Negative";
        }
        field(12; "Rounding Factor"; Option)
        {
            Caption = 'Rounding Factor';
            DataClassification = CustomerContent;
            OptionCaption = 'None,1,1000,1000000';
            OptionMembers = "None","1","1000","1000000";
        }
        field(14; "Comparison Period Formula"; Code[20])
        {
            Caption = 'Comparison Period Formula';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Result Code", "Line No.")
        {
            Clustered = true;
        }
    }
}
