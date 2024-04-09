// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.Setup;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

table 31260 "Match Bank Payment Buffer CZB"
{
    Caption = 'Match Bank Payment Buffer';
    ReplicateData = false;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Account Type"; Enum "Search Rule Account Type CZB")
        {
            Caption = 'Account Type';
            DataClassification = SystemMetadata;
        }
        field(3; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
        field(8; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
        }
        field(9; "Due Date"; Date)
        {
            Caption = 'Due Date';
            DataClassification = SystemMetadata;
        }
        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
        }
        field(11; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
        }
        field(20; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            DataClassification = SystemMetadata;
        }
        field(21; "Remaining Amt. Incl. Discount"; Decimal)
        {
            Caption = 'Remaining Amt. Incl. Discount';
            DataClassification = SystemMetadata;
        }
        field(22; "Pmt. Discount Due Date"; Date)
        {
            Caption = 'Pmt. Discount Due Date';
            DataClassification = SystemMetadata;
        }
        field(30; "Specific Symbol"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            DataClassification = SystemMetadata;
        }
        field(31; "Variable Symbol"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            DataClassification = SystemMetadata;
        }
        field(32; "Constant Symbol"; Code[10])
        {
            Caption = 'Constant Symbol';
            CharAllowed = '09';
            DataClassification = SystemMetadata;
            TableRelation = "Constant Symbol CZL";
        }
        field(40; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
        }
        field(45; "Letter No."; Code[20])
        {
            Caption = 'Letter No.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Remove after new Advance Payment Localization for Czech will be implemented.';
            ObsoleteTag = '22.0';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Posting Date")
        {
        }
        key(Key3; "Due Date")
        {
        }
        key(Key4; "Remaining Amount")
        {
        }
    }

    trigger OnInsert()
    begin
        "Entry No." := Count() + 1;
    end;

    procedure InsertFromCustomerLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry"; UseLCYAmounts: Boolean; var UsePaymentDiscounts: Boolean)
    begin
        Clear(Rec);
        "Account Type" := "Account Type"::Customer;
        "Account No." := CustLedgerEntry."Customer No.";
        "Due Date" := CustLedgerEntry."Due Date";
        "Posting Date" := CustLedgerEntry."Posting Date";
        "Document Type" := CustLedgerEntry."Document Type";
        "Document No." := CustLedgerEntry."Document No.";
        "Specific Symbol" := CustLedgerEntry."Specific Symbol CZL";
        "Variable Symbol" := CustLedgerEntry."Variable Symbol CZL";
        "Constant Symbol" := CustLedgerEntry."Constant Symbol CZL";
        if UseLCYAmounts then
            "Remaining Amount" := CustLedgerEntry."Remaining Amt. (LCY)"
        else
            "Remaining Amount" := CustLedgerEntry."Remaining Amount";
        "Pmt. Discount Due Date" := GetCustomerLedgerEntryDiscountDueDate(CustLedgerEntry);
        "Remaining Amt. Incl. Discount" := "Remaining Amount";
        if "Pmt. Discount Due Date" > 0D then begin
            if UseLCYAmounts then
                "Remaining Amt. Incl. Discount" -=
                  Round(CustLedgerEntry."Remaining Pmt. Disc. Possible" / CustLedgerEntry."Adjusted Currency Factor")
            else
                "Remaining Amt. Incl. Discount" -= CustLedgerEntry."Remaining Pmt. Disc. Possible";
            UsePaymentDiscounts := true;
        end;
        "Dimension Set ID" := CustLedgerEntry."Dimension Set ID";
        OnBeforeInsertFromCustomerLedgerEntry(Rec, CustLedgerEntry);
        Insert(true);
    end;

    procedure InsertFromVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry"; UseLCYAmounts: Boolean; var UsePaymentDiscounts: Boolean)
    begin
        Clear(Rec);
        "Account Type" := "Account Type"::Vendor;
        "Account No." := VendorLedgerEntry."Vendor No.";
        "Due Date" := VendorLedgerEntry."Due Date";
        "Posting Date" := VendorLedgerEntry."Posting Date";
        "Document Type" := VendorLedgerEntry."Document Type";
        "Document No." := VendorLedgerEntry."Document No.";
        "Specific Symbol" := VendorLedgerEntry."Specific Symbol CZL";
        "Variable Symbol" := VendorLedgerEntry."Variable Symbol CZL";
        "Constant Symbol" := VendorLedgerEntry."Constant Symbol CZL";
        if UseLCYAmounts then
            "Remaining Amount" := VendorLedgerEntry."Remaining Amt. (LCY)"
        else
            "Remaining Amount" := VendorLedgerEntry."Remaining Amount";
        "Pmt. Discount Due Date" := GetVendorLedgerEntryDiscountDueDate(VendorLedgerEntry);
        "Remaining Amt. Incl. Discount" := "Remaining Amount";
        if "Pmt. Discount Due Date" > 0D then begin
            if UseLCYAmounts then
                "Remaining Amt. Incl. Discount" -=
                  Round(VendorLedgerEntry."Remaining Pmt. Disc. Possible" / VendorLedgerEntry."Adjusted Currency Factor")
            else
                "Remaining Amt. Incl. Discount" -= VendorLedgerEntry."Remaining Pmt. Disc. Possible";
            UsePaymentDiscounts := true;
        end;
        "Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
        OnBeforeInsertFromVendorLedgerEntry(Rec, VendorLedgerEntry);
        Insert(true);
    end;

    procedure InsertFromEmployeeLedgerEntry(EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
        Clear(Rec);
        "Account Type" := "Account Type"::Employee;
        "Account No." := EmployeeLedgerEntry."Employee No.";
        "Posting Date" := EmployeeLedgerEntry."Posting Date";
        "Document Type" := EmployeeLedgerEntry."Document Type";
        "Document No." := EmployeeLedgerEntry."Document No.";
        "Remaining Amount" := EmployeeLedgerEntry."Remaining Amount";
        "Remaining Amt. Incl. Discount" := "Remaining Amount";
        "Dimension Set ID" := EmployeeLedgerEntry."Dimension Set ID";
        OnBeforeInsertFromEmployeeLedgerEntry(Rec, EmployeeLedgerEntry);
        Insert(true);
    end;

    local procedure GetCustomerLedgerEntryDiscountDueDate(CustLedgerEntry: Record "Cust. Ledger Entry"): Date
    begin
        if CustLedgerEntry."Remaining Pmt. Disc. Possible" = 0 then
            exit(0D);
        if CustLedgerEntry."Pmt. Disc. Tolerance Date" >= CustLedgerEntry."Pmt. Discount Date" then
            exit(CustLedgerEntry."Pmt. Disc. Tolerance Date");
        exit(CustLedgerEntry."Pmt. Discount Date");
    end;

    local procedure GetVendorLedgerEntryDiscountDueDate(VendorLedgerEntry: Record "Vendor Ledger Entry"): Date
    begin
        if VendorLedgerEntry."Remaining Pmt. Disc. Possible" = 0 then
            exit(0D);
        if VendorLedgerEntry."Pmt. Disc. Tolerance Date" >= VendorLedgerEntry."Pmt. Discount Date" then
            exit(VendorLedgerEntry."Pmt. Disc. Tolerance Date");
        exit(VendorLedgerEntry."Pmt. Discount Date");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertFromCustomerLedgerEntry(var MatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertFromVendorLedgerEntry(var MatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertFromEmployeeLedgerEntry(var MatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
    end;
}
