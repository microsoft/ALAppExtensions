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
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using System.Security.AccessControl;

table 31009 "Purch. Adv. Letter Entry CZZ"
{
    Caption = 'Purchase Adv. Letter Entry';
    DataClassification = CustomerContent;
    LookupPageId = "Purch. Adv. Letter Entries CZZ";
    DrillDownPageId = "Purch. Adv. Letter Entries CZZ";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Purch. Adv. Letter No."; Code[20])
        {
            Caption = 'Purch. Adv. Letter No.';
            DataClassification = CustomerContent;
            TableRelation = "Purch. Adv. Letter Header CZZ";
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
        field(34; "Original Document VAT Date"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = CustomerContent;
        }
        field(35; "VAT Entry No."; Integer)
        {
            Caption = 'VAT Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "VAT Entry";
        }
        field(38; "Vendor Ledger Entry No."; Integer)
        {
            Caption = 'Vendor Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Vendor Ledger Entry";
        }
        field(39; "Det. Vendor Ledger Entry No."; Integer)
        {
            Caption = 'Detailed Vendor Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Detailed Vendor Ledg. Entry";
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
            TableRelation = "Purch. Adv. Letter Entry CZZ";
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
        field(65; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(70; "Non-Deductible VAT %"; Decimal)
        {
            Caption = 'Non-Deductible VAT %"';
            DecimalPlaces = 0 : 5;
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
        key(Key2; "Purch. Adv. Letter No.", "Entry Type")
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
        key(Key6; "Det. Vendor Ledger Entry No.")
        {
        }
    }

    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";

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
            DocumentSendingProfile.TrySendToPrinterVendor(
              DummyReportSelections.Usage::"Purchase Advance VAT Document CZZ".AsInteger(), Rec, 0, ShowRequestPage);
    end;

    procedure CalcUsageVATAmountLines(var PurchInvHeader: Record "Purch. Inv. Header"; var VATAmountLine: Record "VAT Amount Line")
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        VatEntry: Record "VAT Entry";
    begin
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ.SetRange("Auxiliary Entry", false);
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if PurchAdvLetterEntryCZZ.FindSet() then
            repeat
                VATAmountLine.Init();
                VATAmountLine."VAT Identifier" := PurchAdvLetterEntryCZZ."VAT Identifier";
                VATAmountLine."VAT Calculation Type" := PurchAdvLetterEntryCZZ."VAT Calculation Type";
                VATAmountLine."VAT %" := PurchAdvLetterEntryCZZ."VAT %";
                VATAmountLine."VAT Base" := PurchAdvLetterEntryCZZ."VAT Base Amount";
                VATAmountLine."VAT Amount" := PurchAdvLetterEntryCZZ."VAT Amount";
                VATAmountLine."Amount Including VAT" := PurchAdvLetterEntryCZZ.Amount;
                VATAmountLine."VAT Base (LCY) CZL" := PurchAdvLetterEntryCZZ."VAT Base Amount (LCY)";
                VATAmountLine."VAT Amount (LCY) CZL" := PurchAdvLetterEntryCZZ."VAT Amount (LCY)";
                if PurchAdvLetterEntryCZZ."VAT Entry No." <> 0 then
                    if VATEntry.Get(PurchAdvLetterEntryCZZ."VAT Entry No.") then begin
                        VATAmountLine."Additional-Currency Base CZL" := VATEntry."Additional-Currency Base";
                        VATAmountLine."Additional-Currency Amount CZL" := VATEntry."Additional-Currency Amount";
                    end;
                if PurchInvHeader."Prices Including VAT" then
                    VATAmountLine."Line Amount" := VATAmountLine."Amount Including VAT"
                else
                    VATAmountLine."Line Amount" := VATAmountLine."VAT Base";
                VATAmountLine.InsertLine();
            until PurchAdvLetterEntryCZZ.Next() = 0;
    end;

    procedure CalcDocumentAmount(): Decimal
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        PurchAdvLetterEntryCZZ.SetRange("Document No.", "Document No.");
        PurchAdvLetterEntryCZZ.CalcSums(Amount);
        exit(PurchAdvLetterEntryCZZ.Amount)
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
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        if not PurchAdvLetterEntryCZZ.Get(EntryNo) then
            PurchAdvLetterEntryCZZ."Entry No." := EntryNo;
        InitRelatedEntry(PurchAdvLetterEntryCZZ);
    end;

    procedure InitRelatedEntry(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
        "Related Entry" := PurchAdvLetterEntryCZZ."Entry No.";
        OnAfterInitRelatedEntry(PurchAdvLetterEntryCZZ, Rec);
    end;

    procedure InitVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        "Vendor Ledger Entry No." := VendorLedgerEntry."Entry No.";
        OnAfterInitVendorLedgerEntry(VendorLedgerEntry, Rec);
    end;

    procedure InitDetailedVendorLedgerEntry(DetailedVendorLedgEntryNo: Integer)
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        if not DetailedVendorLedgEntry.Get(DetailedVendorLedgEntryNo) then
            DetailedVendorLedgEntry."Entry No." := DetailedVendorLedgEntryNo;
        InitDetailedVendorLedgerEntry(DetailedVendorLedgEntry);
    end;

    procedure InitDetailedVendorLedgerEntry(DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry")
    begin
        "Det. Vendor Ledger Entry No." := DetailedVendorLedgEntry."Entry No.";
        OnAfterInitDetailedVendorLedgerEntry(DetailedVendorLedgEntry, Rec);
    end;

    procedure CopyFromGenJnlLine(GenJournalLine: Record "Gen. Journal Line")
    begin
        "Document No." := GenJournalLine."Document No.";
        "External Document No." := GenJournalLine."External Document No.";
        "Global Dimension 1 Code" := GenJournalLine."Shortcut Dimension 1 Code";
        "Global Dimension 2 Code" := GenJournalLine."Shortcut Dimension 2 Code";
        "Dimension Set ID" := GenJournalLine."Dimension Set ID";
        "Posting Date" := GenJournalLine."Posting Date";
        "VAT Date" := GenJournalLine."VAT Reporting Date";
        "Original Document VAT Date" := GenJournalLine."Original Doc. VAT Date CZL";
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

    procedure CopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        "Purch. Adv. Letter No." := PurchAdvLetterHeaderCZZ."No.";
        OnAfterCopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ, Rec);
    end;

    procedure InsertNewEntry(WriteToDatabase: Boolean) EntryNo: Integer
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        OnBeforeInsertNewEntry(WriteToDatabase, Rec);
        if not IsTemporary() then
            exit;

        "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
        EntryNo := "Entry No.";
        if WriteToDatabase then begin
            PurchAdvLetterEntryCZZ.InitNewEntry();
            EntryNo := PurchAdvLetterEntryCZZ."Entry No.";
            PurchAdvLetterEntryCZZ := Rec;
            PurchAdvLetterEntryCZZ."Entry No." := EntryNo;
            PurchAdvLetterEntryCZZ.Insert(true);
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
        RemainingAmount := PurchAdvLetterManagementCZZ.GetRemAmtPurchAdvPayment(Rec, BalanceAtDate);
        OnAfterRemainingAmount(Rec, BalanceAtDate, RemainingAmount);
    end;

    procedure GetRemainingAmountLCY(): Decimal
    begin
        exit(GetRemainingAmountLCY(0D))
    end;

    procedure GetRemainingAmountLCY(BalanceAtDate: Date) RemainingAmountLCY: Decimal
    begin
        RemainingAmountLCY := PurchAdvLetterManagementCZZ.GetRemAmtLCYPurchAdvPayment(Rec, BalanceAtDate);
        OnAfterRemainingAmountLCY(Rec, BalanceAtDate, RemainingAmountLCY);
    end;

    internal procedure IsNonDeductibleVATAllowed(): Boolean
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        exit(VATPostingSetup.IsNonDeductibleVATAllowed(
            "VAT Bus. Posting Group", "VAT Prod. Posting Group"));
    end;

    internal procedure CheckNonDeductibleVATAllowed()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.CheckNonDeductibleVATAllowed(
            "VAT Bus. Posting Group", "VAT Prod. Posting Group");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintRecords(var ReportSelections: Record "Report Selections"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; ShowRequestPage: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitNewEntry(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRelatedEntry(RelatedPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDetailedVendorLedgerEntry(DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromVATPostingSetup(VATPostingSetup: Record "VAT Posting Setup"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromPurchAdvLetterHeader(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertNewEntry(WriteToDatabase: Boolean; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertNewEntry(WriteToDatabase: Boolean; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRemainingAmount(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; BalanceAtDate: Date; var RemainingAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRemainingAmountLCY(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; BalanceAtDate: Date; var RemainingAmountLCY: Decimal)
    begin
    end;
}
