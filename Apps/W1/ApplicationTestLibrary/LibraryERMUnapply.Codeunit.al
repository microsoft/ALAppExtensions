/// <summary>
/// Provides utility functions for unapplying customer and vendor ledger entries in test scenarios. This is an extension library for Library - ERM.
/// </summary>
codeunit 131301 "Library - ERM Unapply"
{

    trigger OnRun()
    begin
    end;

    procedure UnapplyCustomerLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        UnapplyCustomerLedgerEntryBase(CustLedgerEntry, 0D);
    end;

    procedure UnapplyVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        UnapplyVendorLedgerEntryBase(VendorLedgerEntry, 0D);
    end;

    procedure UnapplyEmployeeLedgerEntry(EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
        UnapplyEmployeeLedgerEntryBase(EmployeeLedgerEntry, 0D);
    end;

    procedure UnapplyCustomerLedgerEntryBase(CustLedgerEntry: Record "Cust. Ledger Entry"; PostingDate: Date)
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
#pragma warning disable AA0210
        DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
        DetailedCustLedgEntry.SetRange("Customer No.", CustLedgerEntry."Customer No.");
        DetailedCustLedgEntry.SetRange("Document No.", CustLedgerEntry."Document No.");
        DetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
        DetailedCustLedgEntry.SetRange(Unapplied, false);
#pragma warning restore AA0210
        DetailedCustLedgEntry.FindFirst();
        if PostingDate = 0D then
            PostingDate := DetailedCustLedgEntry."Posting Date";
        SourceCodeSetup.Get();
        CustLedgerEntry.Get(DetailedCustLedgEntry."Cust. Ledger Entry No.");
        GenJournalLine.Validate("Document No.", DetailedCustLedgEntry."Document No.");
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
        GenJournalLine.Validate("Account No.", DetailedCustLedgEntry."Customer No.");
        GenJournalLine.Validate(Correction, true);
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::" ");
        GenJournalLine.Validate(Description, CustLedgerEntry.Description);
        GenJournalLine.Validate("Shortcut Dimension 1 Code", CustLedgerEntry."Global Dimension 1 Code");
        GenJournalLine.Validate("Shortcut Dimension 2 Code", CustLedgerEntry."Global Dimension 2 Code");
        GenJournalLine.Validate("Posting Group", CustLedgerEntry."Customer Posting Group");
        GenJournalLine.Validate("Source Type", GenJournalLine."Source Type"::Vendor);
        GenJournalLine.Validate("Source No.", DetailedCustLedgEntry."Customer No.");
        GenJournalLine.Validate("Source Code", SourceCodeSetup."Unapplied Sales Entry Appln.");
        GenJournalLine.Validate("Source Currency Code", DetailedCustLedgEntry."Currency Code");
        GenJournalLine.Validate("System-Created Entry", true);
        GenJnlPostLine.UnapplyCustLedgEntry(GenJournalLine, DetailedCustLedgEntry);
    end;

    procedure UnapplyVendorLedgerEntryBase(VendorLedgerEntry: Record "Vendor Ledger Entry"; PostingDate: Date)
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
#pragma warning disable AA0210
        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
        DetailedVendorLedgEntry.SetRange("Vendor No.", VendorLedgerEntry."Vendor No.");
        DetailedVendorLedgEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
        DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        DetailedVendorLedgEntry.SetRange(Unapplied, false);
#pragma warning restore AA0210
        DetailedVendorLedgEntry.FindFirst();
        if PostingDate = 0D then
            PostingDate := DetailedVendorLedgEntry."Posting Date";
        SourceCodeSetup.Get();
        VendorLedgerEntry.Get(DetailedVendorLedgEntry."Vendor Ledger Entry No.");
        GenJournalLine.Validate("Document No.", DetailedVendorLedgEntry."Document No.");
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Vendor);
        GenJournalLine.Validate("Account No.", DetailedVendorLedgEntry."Vendor No.");
        GenJournalLine.Validate(Correction, true);
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::" ");
        GenJournalLine.Validate(Description, VendorLedgerEntry.Description);
        GenJournalLine.Validate("Shortcut Dimension 1 Code", VendorLedgerEntry."Global Dimension 1 Code");
        GenJournalLine.Validate("Shortcut Dimension 2 Code", VendorLedgerEntry."Global Dimension 2 Code");
        GenJournalLine.Validate("Posting Group", VendorLedgerEntry."Vendor Posting Group");
        GenJournalLine.Validate("Source Type", GenJournalLine."Source Type"::Vendor);
        GenJournalLine.Validate("Source No.", DetailedVendorLedgEntry."Vendor No.");
        GenJournalLine.Validate("Source Code", SourceCodeSetup."Unapplied Purch. Entry Appln.");
        GenJournalLine.Validate("Source Currency Code", DetailedVendorLedgEntry."Currency Code");
        GenJournalLine.Validate("System-Created Entry", true);
        GenJnlPostLine.UnapplyVendLedgEntry(GenJournalLine, DetailedVendorLedgEntry);
    end;

    procedure UnapplyEmployeeLedgerEntryBase(EmployeeLedgerEntry: Record "Employee Ledger Entry"; PostingDate: Date)
    var
        DetailedEmployeeLedgerEntry: Record "Detailed Employee Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
#pragma warning disable AA0210
        DetailedEmployeeLedgerEntry.SetRange("Entry Type", DetailedEmployeeLedgerEntry."Entry Type"::Application);
        DetailedEmployeeLedgerEntry.SetRange("Employee No.", EmployeeLedgerEntry."Employee No.");
        DetailedEmployeeLedgerEntry.SetRange("Document No.", EmployeeLedgerEntry."Document No.");
        DetailedEmployeeLedgerEntry.SetRange("Employee Ledger Entry No.", EmployeeLedgerEntry."Entry No.");
        DetailedEmployeeLedgerEntry.SetRange(Unapplied, false);
#pragma warning restore AA0210
        DetailedEmployeeLedgerEntry.FindFirst();
        if PostingDate = 0D then
            PostingDate := DetailedEmployeeLedgerEntry."Posting Date";
        SourceCodeSetup.Get();
        EmployeeLedgerEntry.Get(DetailedEmployeeLedgerEntry."Employee Ledger Entry No.");
        GenJournalLine.Validate("Document No.", DetailedEmployeeLedgerEntry."Document No.");
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Employee);
        GenJournalLine.Validate("Account No.", DetailedEmployeeLedgerEntry."Employee No.");
        GenJournalLine.Validate(Correction, true);
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::" ");
        GenJournalLine.Validate(Description, EmployeeLedgerEntry.Description);
        GenJournalLine.Validate("Posting Group", EmployeeLedgerEntry."Employee Posting Group");
        GenJournalLine.Validate("Shortcut Dimension 1 Code", EmployeeLedgerEntry."Global Dimension 1 Code");
        GenJournalLine.Validate("Shortcut Dimension 2 Code", EmployeeLedgerEntry."Global Dimension 2 Code");
        GenJournalLine.Validate("Source Type", GenJournalLine."Source Type"::Vendor);
        GenJournalLine.Validate("Source No.", DetailedEmployeeLedgerEntry."Employee No.");
        GenJournalLine.Validate("Source Code", SourceCodeSetup."Unapplied Purch. Entry Appln.");
        GenJournalLine.Validate("Source Currency Code", DetailedEmployeeLedgerEntry."Currency Code");
        GenJournalLine.Validate("System-Created Entry", true);
        GenJnlPostLine.UnapplyEmplLedgEntry(GenJournalLine, DetailedEmployeeLedgerEntry);
    end;
}

