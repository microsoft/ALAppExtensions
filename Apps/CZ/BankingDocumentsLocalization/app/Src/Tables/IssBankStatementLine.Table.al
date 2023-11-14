// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Setup;
using Microsoft.Finance.Currency;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 31255 "Iss. Bank Statement Line CZB"
{
    Caption = 'Issued Bank Statement Line';
    DrillDownPageID = "Iss. Bank Statement Lines CZB";
    LookupPageId = "Iss. Bank Statement Lines CZB";

    fields
    {
        field(1; "Bank Statement No."; Code[20])
        {
            Caption = 'Bank Statement No.';
            TableRelation = "Iss. Bank Statement Header CZB"."No.";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; Type; Enum "Banking Line Type CZB")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const(Customer)) Customer."No." else
            if (Type = const(Vendor)) Vendor."No." else
            if (Type = const("Bank Account")) "Bank Account"."No." else
            if (Type = const(Employee)) Employee."No.";
            DataClassification = CustomerContent;
        }
        field(5; "Cust./Vendor Bank Account Code"; Code[20])
        {
            Caption = 'Cust./Vendor Bank Account Code';
            TableRelation = if (Type = const(Customer)) "Customer Bank Account".Code where("Customer No." = field("No.")) else
            if (Type = const(Vendor)) "Vendor Bank Account".Code where("Vendor No." = field("No."));
            DataClassification = CustomerContent;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; "Account No."; Text[30])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
        field(8; "Variable Symbol"; Code[10])
        {
            Caption = 'Variable Symbol';
            DataClassification = CustomerContent;
        }
        field(9; "Constant Symbol"; Code[10])
        {
            Caption = 'Constant Symbol';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;
        }
        field(10; "Specific Symbol"; Code[10])
        {
            Caption = 'Specific Symbol';
            DataClassification = CustomerContent;
        }
        field(11; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            DataClassification = CustomerContent;
        }
        field(12; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            AutoFormatType = 1;
            DataClassification = CustomerContent;
        }
        field(17; Positive; Boolean)
        {
            Caption = 'Positive';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18; "Transit No."; Text[20])
        {
            Caption = 'Transit No.';
            DataClassification = CustomerContent;
        }
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(25; "Bank Statement Currency Code"; Code[10])
        {
            Caption = 'Bank Statement Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(26; "Amount (Bank Stat. Currency)"; Decimal)
        {
            Caption = 'Amount (Bank Statement Currency)';
            AutoFormatExpression = "Bank Statement Currency Code";
            AutoFormatType = 1;
            DataClassification = CustomerContent;
        }
        field(27; "Bank Statement Currency Factor"; Decimal)
        {
            Caption = 'Bank Statement Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(40; IBAN; Code[50])
        {
            Caption = 'IBAN';
            DataClassification = CustomerContent;
        }
        field(45; "SWIFT Code"; Code[20])
        {
            Caption = 'SWIFT Code';
            DataClassification = CustomerContent;
        }
        field(70; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Bank Statement No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Bank Statement No.", Positive)
        {
            SumIndexFields = Amount, "Amount (LCY)";
        }
    }

    procedure ConvertTypeToBankAccReconLineAccountType(): Integer
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        case Type of
            Type::Customer:
                exit(BankAccReconciliationLine."Account Type"::Customer.AsInteger());
            Type::Vendor:
                exit(BankAccReconciliationLine."Account Type"::Vendor.AsInteger());
            Type::"Bank Account":
                exit(BankAccReconciliationLine."Account Type"::"Bank Account".AsInteger());
            Type::Employee:
                exit(BankAccReconciliationLine."Account Type"::Employee.AsInteger());
        end;
    end;
}
