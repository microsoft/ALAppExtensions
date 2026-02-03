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
using Microsoft.Foundation.Address;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 10834 "Payment Header Archive FR"
{
    Caption = 'Payment Header Archive';
    DrillDownPageID = "Payment Slip List Archive FR";
    LookupPageID = "Payment Slip List Archive FR";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(3; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(5; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(6; "Payment Class"; Text[30])
        {
            Caption = 'Payment Class';
            TableRelation = "Payment Class FR";
        }
        field(7; "Status No."; Integer)
        {
            Caption = 'Status No.';
            TableRelation = "Payment Status FR".Line where("Payment Class" = field("Payment Class"));
        }
        field(8; "Status Name"; Text[50])
        {
            CalcFormula = lookup("Payment Status FR".Name where("Payment Class" = field("Payment Class"),
                                                              Line = field("Status No.")));
            Caption = 'Status Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(10; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
        }
        field(11; "Payment Class Name"; Text[50])
        {
            CalcFormula = lookup("Payment Class FR".Name where(Code = field("Payment Class")));
            Caption = 'Payment Class Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
        }
        field(13; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(14; "Account Type"; enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
        }
        field(15; "Account No."; Code[20])
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
#pragma warning disable AA0232
        field(16; "Amount (LCY)"; Decimal)
        {
            CalcFormula = sum("Payment Line Archive FR"."Amount (LCY)" where("No." = field("No.")));
            Caption = 'Amount (LCY)';
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Editable = false;
            FieldClass = FlowField;
        }
#pragma warning restore AA0232
        field(17; Amount; Decimal)
        {
            CalcFormula = sum("Payment Line Archive FR".Amount where("No." = field("No.")));
            Caption = 'Amount';
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            FieldClass = FlowField;
        }
        field(18; "Bank Branch No."; Text[20])
        {
            Caption = 'Bank Branch No.';
        }
        field(19; "Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';
        }
        field(20; "Agency Code"; Text[20])
        {
            Caption = 'Agency Code';
        }
        field(21; "RIB Key"; Integer)
        {
            Caption = 'RIB Key';
        }
        field(22; "RIB Checked"; Boolean)
        {
            Caption = 'RIB Checked';
            Editable = false;
        }
        field(23; "Bank Name"; Text[100])
        {
            Caption = 'Bank Name';
        }
        field(24; "Bank Post Code"; Code[20])
        {
            Caption = 'Bank Post Code';
            TableRelation = "Post Code";
            ValidateTableRelation = false;
        }
        field(25; "Bank City"; Text[30])
        {
            Caption = 'Bank City';
        }
        field(26; "Bank Name 2"; Text[50])
        {
            Caption = 'Bank Name 2';
        }
        field(27; "Bank Address"; Text[100])
        {
            Caption = 'Bank Address';
        }
        field(28; "Bank Address 2"; Text[50])
        {
            Caption = 'Bank Address 2';
        }
        field(29; "Bank Contact"; Text[100])
        {
            Caption = 'Bank Contact';
        }
        field(30; "Bank County"; Text[30])
        {
            Caption = 'Bank County';
        }
        field(31; "Bank Country/Region Code"; Code[10])
        {
            Caption = 'Bank Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(32; "National Issuer No."; Code[6])
        {
            Caption = 'National Issuer No.';
            Numeric = true;
        }
        field(50; IBAN; Code[50])
        {
            Caption = 'IBAN';

            trigger OnValidate()
            var
                CompanyInfo: Record "Company Information";
            begin
                CompanyInfo.CheckIBAN(IBAN);
            end;
        }
        field(51; "SWIFT Code"; Code[20])
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
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Posting Date")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.")
        {
        }
    }

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", CopyStr(StrSubstNo('%1 %2', TableCaption(), "No."), 1, 250));
    end;
}

