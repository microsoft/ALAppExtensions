// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;
using Microsoft.Foundation.Reporting;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.Security.AccessControl;

table 31006 "Sales Adv. Letter Entry CZZ"
{
    Caption = 'Sales Adv. Letter Entry';
    DataClassification = CustomerContent;
    LookupPageId = "Sales Adv. Letter Entries CZZ";
    DrillDownPageId = "Sales Adv. Letter Entries CZZ";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Sales Adv. Letter No."; Code[20])
        {
            Caption = 'Sales Adv. Letter No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Adv. Letter Header CZZ";
        }
        field(10; "Entry Type"; Enum "Advance Letter Entry Type CZZ")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(13; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(15; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(16; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(17; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
        }
        field(18; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
        }
        field(19; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
        }
        field(25; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(26; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            MinValue = 0;
        }
        field(28; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(30; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(33; "VAT Date"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = CustomerContent;
        }
        field(35; "VAT Entry No."; Integer)
        {
            Caption = 'VAT Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "VAT Entry";
        }
        field(38; "Cust. Ledger Entry No."; Integer)
        {
            Caption = 'Cust. Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Cust. Ledger Entry";
        }
        field(39; "Det. Cust. Ledger Entry No."; Integer)
        {
            Caption = 'Detailed Cust. Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Detailed Cust. Ledg. Entry";
        }
        field(40; "VAT Base Amount"; Decimal)
        {
            Caption = 'VAT Base Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
        }
        field(41; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
        }
        field(42; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatExpression = "Currency Code";
        }
        field(45; "VAT Base Amount (LCY)"; Decimal)
        {
            Caption = 'VAT Base Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(46; "VAT Amount (LCY)"; Decimal)
        {
            Caption = 'VAT Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(47; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(50; Cancelled; Boolean)
        {
            Caption = 'Cancelled';
            DataClassification = CustomerContent;
        }
        field(55; "Related Entry"; Integer)
        {
            Caption = 'Related Entry';
            DataClassification = CustomerContent;
            TableRelation = "Sales Adv. Letter Entry CZZ";
        }
        field(60; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(61; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(70; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            Editable = false;
        }
        field(80; "Auxiliary Entry"; Boolean)
        {
            Caption = 'Auxiliary Entry';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Sales Adv. Letter No.", "Entry Type")
        {
        }
        key(Key3; "Related Entry")
        {
        }
        key(Key4; "Document No.", "Posting Date", Cancelled)
        {
        }
        key(Key5; "Posting Date")
        {
        }
        key(Key6; "Det. Cust. Ledger Entry No.")
        {
        }
    }

    var
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";

    procedure ShowDimensions()
    var
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetCaptionTok: Label '%1 %2', Locked = true;
    begin
        DimensionManagement.ShowDimensionSet("Dimension Set ID", StrSubstNo(DimensionSetCaptionTok, TableCaption, "Entry No."));
    end;

    procedure PrintRecords(ShowRequestPage: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePrintRecords(DummyReportSelections, Rec, ShowRequestPage, IsHandled);
        if not IsHandled then
            DocumentSendingProfile.TrySendToPrinter(
              DummyReportSelections.Usage::"Sales Advance VAT Document CZZ".AsInteger(), Rec, FieldNo("Customer No."), ShowRequestPage);
    end;

    procedure EmailRecords(ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        ReportDistributionManagement: Codeunit "Report Distribution Management";
        DocumentTypeTxt: Text[50];
        IsHandled: Boolean;
    begin
        DocumentTypeTxt := ReportDistributionManagement.GetFullDocumentTypeText(Rec);

        IsHandled := false;
        OnBeforeEmailRecords(DummyReportSelections, Rec, DocumentTypeTxt, ShowDialog, IsHandled);
        if not IsHandled then
            DocumentSendingProfile.TrySendToEMail(
              DummyReportSelections.Usage::"Sales Advance VAT Document CZZ".AsInteger(), Rec, FieldNo("Document No."), DocumentTypeTxt, FieldNo("Customer No."), ShowDialog);
    end;

    procedure CalcUsageVATAmountLines(var SalesInvoiceHeader: Record "Sales Invoice Header"; var VATAmountLine: Record "VAT Amount Line")
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        SalesAdvLetterEntryCZZ.SetRange("Auxiliary Entry", false);
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if SalesAdvLetterEntryCZZ.FindSet() then
            repeat
                VATAmountLine.Init();
                VATAmountLine."VAT Identifier" := SalesAdvLetterEntryCZZ."VAT Identifier";
                VATAmountLine."VAT Calculation Type" := SalesAdvLetterEntryCZZ."VAT Calculation Type";
                VATAmountLine."VAT %" := SalesAdvLetterEntryCZZ."VAT %";
                VATAmountLine."VAT Base" := -SalesAdvLetterEntryCZZ."VAT Base Amount";
                VATAmountLine."VAT Amount" := -SalesAdvLetterEntryCZZ."VAT Amount";
                VATAmountLine."Amount Including VAT" := -SalesAdvLetterEntryCZZ.Amount;
                VATAmountLine."VAT Base (LCY) CZL" := -SalesAdvLetterEntryCZZ."VAT Base Amount (LCY)";
                VATAmountLine."VAT Amount (LCY) CZL" := -SalesAdvLetterEntryCZZ."VAT Amount (LCY)";
                if SalesInvoiceHeader."Prices Including VAT" then
                    VATAmountLine."Line Amount" := VATAmountLine."Amount Including VAT"
                else
                    VATAmountLine."Line Amount" := VATAmountLine."VAT Base";
                VATAmountLine.InsertLine();
            until SalesAdvLetterEntryCZZ.Next() = 0;
    end;

    procedure CalcDocumentAmount(): Decimal
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.SetRange("Document No.", "Document No.");
        SalesAdvLetterEntryCZZ.CalcSums(Amount);
        exit(SalesAdvLetterEntryCZZ.Amount)
    end;

    internal procedure GetCustomerNo(): Code[20]
    var
        SalesAdvLetterHeader: Record "Sales Adv. Letter Header CZZ";
    begin
        SalesAdvLetterHeader.SetLoadFields("Bill-to Customer No.");
        SalesAdvLetterHeader.Get("Sales Adv. Letter No.");
        exit(SalesAdvLetterHeader."Bill-to Customer No.");
    end;

    procedure InitNewEntry()
    begin
        if ("Entry No." = 0) and (not IsTemporary()) then begin
            LockTable();
            if FindLast() then;
        end;
        Init();
        "Entry No." += 1;
        OnAfterInitNewEntry(Rec);
    end;

    procedure InitRelatedEntry(EntryNo: Integer)
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        if not SalesAdvLetterEntryCZZ.Get(EntryNo) then
            SalesAdvLetterEntryCZZ."Entry No." := EntryNo;
        InitRelatedEntry(SalesAdvLetterEntryCZZ);
    end;

    procedure InitRelatedEntry(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
        "Related Entry" := SalesAdvLetterEntryCZZ."Entry No.";
        OnAfterInitRelatedEntry(SalesAdvLetterEntryCZZ, Rec);
    end;

    procedure InitCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        "Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
        OnAfterInitCustLedgerEntry(CustLedgerEntry, Rec);
    end;

    procedure InitDetailedCustLedgerEntry(DetailedCustLedgEntryNo: Integer)
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        if not DetailedCustLedgEntry.Get(DetailedCustLedgEntryNo) then
            DetailedCustLedgEntry."Entry No." := DetailedCustLedgEntryNo;
        InitDetailedCustLedgerEntry(DetailedCustLedgEntry);
    end;

    procedure InitDetailedCustLedgerEntry(DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
    begin
        "Det. Cust. Ledger Entry No." := DetailedCustLedgEntry."Entry No.";
        OnAfterInitDetailedCustLedgerEntry(DetailedCustLedgEntry, Rec);
    end;

    procedure CopyFromGenJnlLine(GenJournalLine: Record "Gen. Journal Line")
    begin
        "Document No." := GenJournalLine."Document No.";
        "Global Dimension 1 Code" := GenJournalLine."Shortcut Dimension 1 Code";
        "Global Dimension 2 Code" := GenJournalLine."Shortcut Dimension 2 Code";
        "Dimension Set ID" := GenJournalLine."Dimension Set ID";
        "Posting Date" := GenJournalLine."Posting Date";
        "VAT Date" := GenJournalLine."VAT Reporting Date";
        "VAT Bus. Posting Group" := GenJournalLine."VAT Bus. Posting Group";
        "VAT Prod. Posting Group" := GenJournalLine."VAT Prod. Posting Group";
        "VAT %" := GenJournalLine."VAT %";
        "VAT Calculation Type" := GenJournalLine."VAT Calculation Type";
        "Currency Code" := GenJournalLine."Currency Code";
        "Currency Factor" := GenJournalLine."Currency Factor";
        Amount := GenJournalLine.Amount;
        "Amount (LCY)" := GenJournalLine."Amount (LCY)";
        "VAT Amount" := GenJournalLine."VAT Amount";
        "VAT Amount (LCY)" := GenJournalLine."VAT Amount (LCY)";
        "VAT Base Amount" := GenJournalLine."VAT Base Amount";
        "VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount (LCY)";
        OnAfterCopyFromGenJnlLine(GenJournalLine, Rec);
    end;

    procedure CopyFromVATPostingSetup(VATPostingSetup: Record "VAT Posting Setup")
    begin
        "VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        "VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        "VAT %" := VATPostingSetup."VAT %";
        "VAT Identifier" := VATPostingSetup."VAT Identifier";
        "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
        OnAfterCopyFromVATPostingSetup(VATPostingSetup, Rec);
    end;

    procedure CopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        "Sales Adv. Letter No." := SalesAdvLetterHeaderCZZ."No.";
        "Customer No." := SalesAdvLetterHeaderCZZ."Bill-to Customer No.";
        OnAfterCopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ, Rec);
    end;

    procedure InsertNewEntry(WriteToDatabase: Boolean) EntryNo: Integer
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        OnBeforeInsertNewEntry(WriteToDatabase, Rec);
        if not IsTemporary() then
            exit;

        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
        EntryNo := "Entry No.";
        if WriteToDatabase then begin
            SalesAdvLetterEntryCZZ.InitNewEntry();
            EntryNo := SalesAdvLetterEntryCZZ."Entry No.";
            SalesAdvLetterEntryCZZ := Rec;
            SalesAdvLetterEntryCZZ."Entry No." := EntryNo;
            SalesAdvLetterEntryCZZ.Insert(true);
            Rec := SalesAdvLetterEntryCZZ;
        end else
            Insert();
        OnAfterInsertNewEntry(WriteToDatabase, Rec);
    end;

    procedure GetRemainingAmount(): Decimal
    begin
        exit(GetRemainingAmount(0D))
    end;

    procedure GetRemainingAmount(BalanceAtDate: Date) RemainingAmount: Decimal
    begin
        RemainingAmount := SalesAdvLetterManagementCZZ.GetRemAmtSalAdvPayment(Rec, BalanceAtDate);
        OnAfterRemainingAmount(Rec, BalanceAtDate, RemainingAmount);
    end;

    procedure GetRemainingAmountLCY(): Decimal
    begin
        exit(GetRemainingAmountLCY(0D))
    end;

    procedure GetRemainingAmountLCY(BalanceAtDate: Date) RemainingAmountLCY: Decimal
    begin
        RemainingAmountLCY := SalesAdvLetterManagementCZZ.GetRemAmtLCYSalAdvPayment(Rec, BalanceAtDate);
        OnAfterRemainingAmountLCY(Rec, BalanceAtDate, RemainingAmountLCY);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintRecords(var ReportSelections: Record "Report Selections"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; ShowRequestPage: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEmailRecords(var ReportSelections: Record "Report Selections"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; DocTxt: Text; ShowDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitNewEntry(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRelatedEntry(RelatedSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDetailedCustLedgerEntry(DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromVATPostingSetup(VATPostingSetup: Record "VAT Posting Setup"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertNewEntry(WriteToDatabase: Boolean; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertNewEntry(WriteToDatabase: Boolean; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRemainingAmount(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; BalanceAtDate: Date; var RemainingAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRemainingAmountLCY(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; BalanceAtDate: Date; var RemainingAmountLCY: Decimal)
    begin
    end;
}
