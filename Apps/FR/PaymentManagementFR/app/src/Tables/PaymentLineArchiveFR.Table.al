// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 10836 "Payment Line Archive FR"
{
    Caption = 'Payment Line Archive';
    DrillDownPageID = "Payment Lines Archive List FR";
    LookupPageID = "Payment Lines Archive List FR";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = "Payment Header Archive FR";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(4; "Account Type"; enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
        }
        field(5; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset";
        }
        field(6; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            Editable = true;
            TableRelation = if ("Account Type" = const(Customer)) "Customer Posting Group"
            else
            if ("Account Type" = const(Vendor)) "Vendor Posting Group"
            else
            if ("Account Type" = const("Fixed Asset")) "FA Posting Group";
        }
        field(7; "Copied To No."; Code[20])
        {
            Caption = 'Copied To No.';
        }
        field(8; "Copied To Line"; Integer)
        {
            Caption = 'Copied To Line';
        }
        field(9; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(10; "Acc. Type Last Entry Debit"; enum "Gen. Journal Account Type")
        {
            Caption = 'Acc. Type Last Entry Debit';
            Editable = false;
        }
        field(11; "Acc. No. Last Entry Debit"; Code[20])
        {
            Caption = 'Acc. No. Last Entry Debit';
            Editable = false;
            TableRelation = if ("Acc. Type Last Entry Debit" = const("G/L Account")) "G/L Account"
            else
            if ("Acc. Type Last Entry Debit" = const(Customer)) Customer
            else
            if ("Acc. Type Last Entry Debit" = const(Vendor)) Vendor
            else
            if ("Acc. Type Last Entry Debit" = const("Bank Account")) "Bank Account"
            else
            if ("Acc. Type Last Entry Debit" = const("Fixed Asset")) "Fixed Asset";
        }
        field(12; "Acc. Type Last Entry Credit"; enum "Gen. Journal Account Type")
        {
            Caption = 'Acc. Type Last Entry Credit';
            Editable = false;
        }
        field(13; "Acc. No. Last Entry Credit"; Code[20])
        {
            Caption = 'Acc. No. Last Entry Credit';
            Editable = false;
            TableRelation = if ("Acc. Type Last Entry Credit" = const("G/L Account")) "G/L Account"
            else
            if ("Acc. Type Last Entry Credit" = const(Customer)) Customer
            else
            if ("Acc. Type Last Entry Credit" = const(Vendor)) Vendor
            else
            if ("Acc. Type Last Entry Credit" = const("Bank Account")) "Bank Account"
            else
            if ("Acc. Type Last Entry Credit" = const("Fixed Asset")) "Fixed Asset";
        }
        field(14; "P. Group Last Entry Debit"; Code[20])
        {
            Caption = 'P. Group Last Entry Debit';
            Editable = false;
        }
        field(15; "P. Group Last Entry Credit"; Code[20])
        {
            Caption = 'P. Group Last Entry Credit';
            Editable = false;
        }
        field(16; "Payment Class"; Text[30])
        {
            Caption = 'Payment Class';
            TableRelation = "Payment Class FR";
        }
        field(17; "Status No."; Integer)
        {
            Caption = 'Status No.';
            Editable = false;
            TableRelation = "Payment Status FR".Line where("Payment Class" = field("Payment Class"));
        }
        field(18; "Status Name"; Text[50])
        {
            CalcFormula = lookup("Payment Status FR".Name where("Payment Class" = field("Payment Class"),
                                                              Line = field("Status No.")));
            Caption = 'Status Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; IsCopy; Boolean)
        {
            Caption = 'IsCopy';
        }
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(21; "Entry No. Debit"; Integer)
        {
            Caption = 'Entry No. Debit';
            Editable = false;
        }
        field(22; "Entry No. Credit"; Integer)
        {
            Caption = 'Entry No. Credit';
            Editable = false;
        }
        field(23; "Entry No. Debit Memo"; Integer)
        {
            Caption = 'Entry No. Debit Memo';
            Editable = false;
        }
        field(24; "Entry No. Credit Memo"; Integer)
        {
            Caption = 'Entry No. Credit Memo';
            Editable = false;
        }
        field(25; "Bank Account Code"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = if ("Account Type" = const(Customer)) "Customer Bank Account".Code where("Customer No." = field("Account No."))
            else
            if ("Account Type" = const(Vendor)) "Vendor Bank Account".Code where("Vendor No." = field("Account No."));
        }
        field(26; "Bank Branch No."; Text[20])
        {
            Caption = 'Bank Branch No.';
        }
        field(27; "Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';
        }
        field(28; "Agency Code"; Text[5])
        {
            Caption = 'Agency Code';
        }
        field(29; "RIB Key"; Integer)
        {
            Caption = 'RIB Key';
        }
        field(30; "RIB Checked"; Boolean)
        {
            Caption = 'RIB Checked';
            Editable = false;
        }
        field(31; "Acceptation Code"; Option)
        {
            Caption = 'Acceptation Code';
            InitValue = No;
            OptionCaption = 'LCR,No,BOR,LCR NA';
            OptionMembers = LCR,No,BOR,"LCR NA";
        }
        field(32; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(33; "Debit Amount"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Debit Amount';
        }
        field(34; "Credit Amount"; Decimal)
        {
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Credit Amount';
        }
        field(35; "Applies-to ID"; Code[50])
        {
            Caption = 'Applies-to ID';
        }
        field(36; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(37; Posted; Boolean)
        {
            Caption = 'Posted';
        }
        field(38; Correction; Boolean)
        {
            Caption = 'Correction';
        }
        field(39; "Bank Account Name"; Text[100])
        {
            Caption = 'Bank Account Name';
        }
        field(40; "Payment Address Code"; Code[10])
        {
            Caption = 'Payment Address Code';
            TableRelation = "Payment Address FR".Code where("Account Type" = field("Account Type"),
                                                          "Account No." = field("Account No."));
        }
        field(41; "Applies-to Doc. Type"; Option)
        {
            Caption = 'Applies-to Doc. Type';
            Editable = false;
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder;
        }
        field(42; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            Editable = false;
        }
        field(43; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(44; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(45; "Drawee Reference"; Text[10])
        {
            Caption = 'Drawee Reference';
        }
        field(46; "Bank City"; Text[30])
        {
            Caption = 'Bank City';
        }
        field(48; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(50; "Payment in Progress"; Boolean)
        {
            Caption = 'Payment in Progress';
            Editable = false;
        }
        field(55; IBAN; Code[50])
        {
            Caption = 'IBAN';

            trigger OnValidate()
            var
                CompanyInfo: Record "Company Information";
            begin
                CompanyInfo.CheckIBAN(IBAN);
            end;
        }
        field(56; "SWIFT Code"; Code[20])
        {
            Caption = 'SWIFT Code';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                Rec.ShowDimensions();
            end;
        }
    }

    keys
    {
        key(Key1; "No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Amount, "Amount (LCY)";
        }
        key(Key2; "Posting Date", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", CopyStr(StrSubstNo('%1 %2 %3', TableCaption(), "No.", "Line No."), 1, 250));
    end;
}

