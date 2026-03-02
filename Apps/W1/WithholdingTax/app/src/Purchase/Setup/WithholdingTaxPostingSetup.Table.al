// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.NoSeries;

table 6786 "Withholding Tax Posting Setup"
{
    Caption = 'Withholding Tax Posting Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Wthldg. Tax Bus. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Bus. Post. Group';
            TableRelation = "Wthldg. Tax Bus. Post. Group";
        }
        field(2; "Wthldg. Tax Prod. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Prod. Post. Group';
            TableRelation = "Wthldg. Tax Prod. Post. Group";
        }
        field(3; "Withholding Tax %"; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Withholding Tax %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(4; "Prepaid Wthldg. Tax Acc. Code"; Code[20])
        {
            Caption = 'Prepaid Withholding Tax Account Code';
            TableRelation = "G/L Account";
        }
        field(5; "Payable Wthldg. Tax Acc. Code"; Code[20])
        {
            Caption = 'Payable Withholding Tax Account Code';
            TableRelation = "G/L Account";
        }
        field(8; "Wthldg. Tax Rep Line No Series"; Code[20])
        {
            Caption = 'Withholding Tax Report Line No. Series';
            TableRelation = "No. Series";
        }
        field(9; "Revenue Type"; Code[10])
        {
            Caption = 'Revenue Type';
            TableRelation = "Withholding Tax Revenue Types";
        }
        field(10; "Bal. Prepaid Account Type"; Option)
        {
            Caption = 'Bal. Prepaid Account Type';
            OptionCaption = 'Bank Account,G/L Account';
            OptionMembers = "Bank Account","G/L Account";
        }
        field(11; "Bal. Prepaid Account No."; Code[20])
        {
            Caption = 'Bal. Prepaid Account No.';
            TableRelation = if ("Bal. Prepaid Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Bal. Prepaid Account Type" = const("G/L Account")) "G/L Account";
        }
        field(12; "Bal. Payable Account Type"; Option)
        {
            Caption = 'Bal. Payable Account Type';
            OptionCaption = 'Bank Account,G/L Account';
            OptionMembers = "Bank Account","G/L Account";
        }
        field(13; "Bal. Payable Account No."; Code[20])
        {
            Caption = 'Bal. Payable Account No.';
            TableRelation = if ("Bal. Payable Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Bal. Payable Account Type" = const("G/L Account")) "G/L Account";
        }
        field(20; "Purch. Wthldg. Tax Adj. Acc No"; Code[20])
        {
            Caption = 'Purch. Withholding Tax Adj. Account No.';
            TableRelation = "G/L Account";
        }
        field(21; "Sales Wthldg. Tax Adj. Acc No"; Code[20])
        {
            Caption = 'Sales Withholding Tax Adj. Account No.';
            TableRelation = "G/L Account";
        }
        field(22; Sequence; Integer)
        {
            Caption = 'Sequence';
        }
        field(23; "Realized Withholding Tax Type"; Option)
        {
            Caption = 'Realized Withholding Type';
            OptionCaption = ' ,Invoice,Payment,Earliest';
            OptionMembers = " ",Invoice,Payment,Earliest;
        }
        field(24; "Wthldg. Tax Min. Inv. Amount"; Decimal)
        {
            AutoFormatType = 2;
            AutoFormatExpression = '';
            Caption = 'Withholding Tax Minimum Invoice Amount';
        }
        field(25; "Wthldg. Tax Calculation Rule"; Option)
        {
            Caption = 'Withholding Tax Calculation Rule';
            OptionCaption = 'Less than,Less than or equal to,Equal to,Greater than,Greater than or equal to';
            OptionMembers = "Less than","Less than or equal to","Equal to","Greater than","Greater than or equal to";
        }
    }

    keys
    {
        key(Key1; "Wthldg. Tax Bus. Post. Group", "Wthldg. Tax Prod. Post. Group")
        {
            Clustered = true;
        }
        key(Key2; "Wthldg. Tax Bus. Post. Group", Sequence)
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetPrepaidWithholdingTaxAccount(): Code[20]
    begin
        TestField("Prepaid Wthldg. Tax Acc. Code");
        exit("Prepaid Wthldg. Tax Acc. Code");
    end;

    procedure GetPayableWithholdingTaxAccount(): Code[20]
    begin
        TestField("Payable Wthldg. Tax Acc. Code");
        exit("Payable Wthldg. Tax Acc. Code");
    end;
}

