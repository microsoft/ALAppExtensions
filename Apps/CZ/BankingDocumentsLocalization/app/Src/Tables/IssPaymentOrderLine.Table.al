// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.HumanResources.Employee;
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Utilities;

table 31259 "Iss. Payment Order Line CZB"
{
    Caption = 'Issued Payment Order Line';
    DrillDownPageID = "Iss. Payment Order Lines CZB";
    LookupPageID = "Iss. Payment Order Lines CZB";
    Permissions = tabledata "Iss. Payment Order Line CZB" = rm;

    fields
    {
        field(1; "Payment Order No."; Code[20])
        {
            Caption = 'Payment Order No.';
            TableRelation = "Iss. Payment Order Header CZB"."No.";
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
        field(13; "Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-to Doc. Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(16; "Applies-to C/V/E Entry No."; Integer)
        {
            Caption = 'Applies-to C/V/E Entry No.';
            BlankZero = true;
            TableRelation = if (Type = const(Vendor)) "Vendor Ledger Entry"."Entry No." else
            if (Type = const(Customer)) "Cust. Ledger Entry"."Entry No." else
            if (Type = const(Employee)) "Employee Ledger Entry"."Entry No.";
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
        field(24; "Applied Currency Code"; Code[10])
        {
            Caption = 'Applied Currency Code';
            Editable = false;
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(25; "Payment Order Currency Code"; Code[10])
        {
            Caption = 'Payment Order Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(26; "Amount(Payment Order Currency)"; Decimal)
        {
            Caption = 'Amount (Payment Order Currency)';
            AutoFormatExpression = "Payment Order Currency Code";
            AutoFormatType = 1;
            DataClassification = CustomerContent;
        }
        field(27; "Payment Order Currency Factor"; Decimal)
        {
            Caption = 'Payment Order Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(30; "Due Date"; Date)
        {
            Caption = 'Due Date';
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
        field(60; Status; Enum "Payment Order Line Status CZB")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(70; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(150; "Letter Type"; Option)
        {
            Caption = 'Letter Type';
            OptionCaption = ' ,,Purchase';
            OptionMembers = " ",,Purchase;
            ObsoleteState = Removed;
            ObsoleteReason = 'Remove after new Advance Payment Localization for Czech will be implemented.';
            ObsoleteTag = '22.0';
        }
        field(151; "Letter No."; Code[20])
        {
            Caption = 'Letter No.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Remove after new Advance Payment Localization for Czech will be implemented.';
            ObsoleteTag = '22.0';
        }
        field(152; "Letter Line No."; Integer)
        {
            Caption = 'Letter Line No.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Remove after new Advance Payment Localization for Czech will be implemented.';
            ObsoleteTag = '22.0';
        }
        field(190; "VAT Unreliable Payer"; Boolean)
        {
            Caption = 'VAT Unreliable Payer';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(191; "Public Bank Account"; Boolean)
        {
            Caption = 'Public Bank Account';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(192; "Third Party Bank Account"; Boolean)
        {
            Caption = 'Third Party Bank Account';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(200; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Payment Order No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Payment Order No.", Positive)
        {
            SumIndexFields = Amount, "Amount (LCY)";
        }
        key(Key3; Type, "Applies-to C/V/E Entry No.", Status)
        {
            SumIndexFields = "Amount (LCY)", Amount;
        }
    }

    procedure CancelLines(var IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        CancelLineQst: Label 'Do you want to cancel payment order lines?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(CancelLineQst, false) then
            Error('');

        IssPaymentOrderLineCZB.ModifyAll(Status, IssPaymentOrderLineCZB.Status::Canceled);
        OnAfterIssuedPaymentOrderLineCancel(IssPaymentOrderLineCZB);
    end;

    procedure ConvertTypeToGenJnlLineType(): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        case Type of
            Type::Customer:
                exit(GenJournalLine."Account Type"::Customer.AsInteger());
            Type::Vendor:
                exit(GenJournalLine."Account Type"::Vendor.AsInteger());
            Type::"Bank Account":
                exit(GenJournalLine."Account Type"::"Bank Account".AsInteger());
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIssuedPaymentOrderLineCancel(var IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB")
    begin
    end;
}

