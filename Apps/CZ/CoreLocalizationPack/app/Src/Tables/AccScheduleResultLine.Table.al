// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.Finance.GeneralLedger.Account;


table 31111 "Acc. Schedule Result Line CZL"
{
    Caption = 'Acc. Schedule Result Line';

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
        field(3; "Row No."; Code[20])
        {
            Caption = 'Row No.';
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; Totaling; Text[250])
        {
            Caption = 'Totaling';
            DataClassification = CustomerContent;
            TableRelation = if ("Totaling Type" = const("Posting Accounts")) "G/L Account"
            else
            if ("Totaling Type" = const("Total Accounts")) "G/L Account"
            else
            if ("Totaling Type" = const("Custom CZL")) "Acc. Schedule Extension CZL";
            ValidateTableRelation = false;
        }
        field(6; "Totaling Type"; Enum "Acc. Schedule Line Totaling Type")
        {
            Caption = 'Totaling Type';
            DataClassification = CustomerContent;
        }
        field(7; "New Page"; Boolean)
        {
            Caption = 'New Page';
            DataClassification = CustomerContent;
        }
        field(16; Show; Option)
        {
            Caption = 'Show';
            DataClassification = CustomerContent;
            OptionCaption = 'Yes,No,If Any Column Not Zero,When Positive Balance,When Negative Balance';
            OptionMembers = Yes,No,"If Any Column Not Zero","When Positive Balance","When Negative Balance";
        }
        field(23; Bold; Boolean)
        {
            Caption = 'Bold';
            DataClassification = CustomerContent;
        }
        field(24; Italic; Boolean)
        {
            Caption = 'Italic';
            DataClassification = CustomerContent;
        }
        field(25; Underline; Boolean)
        {
            Caption = 'Underline';
            DataClassification = CustomerContent;
        }
        field(26; "Show Opposite Sign"; Boolean)
        {
            Caption = 'Show Opposite Sign';
            DataClassification = CustomerContent;
        }
        field(27; "Row Type"; Option)
        {
            Caption = 'Row Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Net Change,Balance at Date,Beginning Balance';
            OptionMembers = "Net Change","Balance at Date","Beginning Balance";
        }
        field(28; "Amount Type"; Option)
        {
            Caption = 'Amount Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Net Amount,Debit Amount,Credit Amount';
            OptionMembers = "Net Amount","Debit Amount","Credit Amount";
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
