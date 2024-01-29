// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
#if not CLEAN22
using Microsoft.Finance.VAT.Calculation;
#endif
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Enums;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;
using System.Utilities;

codeunit 31019 "PurchAdvLetterManagement CZZ"
{
    Permissions = tabledata "Vendor Ledger Entry" = m;

    var
        PurchAdvLetterEntryCZZGlob: Record "Purch. Adv. Letter Entry CZZ";
        TempPurchAdvLetterEntryCZZGlob: Record "Purch. Adv. Letter Entry CZZ" temporary;
        CurrencyGlob: Record Currency;
#if not CLEAN22
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
#endif
        DateEmptyErr: Label 'Posting Date and VAT Date cannot be empty.';
        DocumentNoOrDatesEmptyErr: Label 'Document No. and Dates cannot be empty.';
        ExternalDocumentNoEmptyErr: Label 'External Document No. cannot be empty.';
        OriginalDocVATDateMustBeLessOrVATDateErr: Label 'Original Document VAT Date (%1) must be less or equal to VAT Date (%2).', Comment = '%1 = OriginalDocVATDate, %2 = VATDate';
        NothingToPostErr: Label 'Nothing to Post.';
        VATDocumentExistsErr: Label 'VAT Document already exists.';
        PostingDateEmptyErr: Label 'Posting Date cannot be empty.';
        LaterPostingDateQst: Label 'The linked advance letter %1 is paid after %2. If you continue, the advance letter won''t be deducted.\\Do you want to continue?', Comment = '%1 = advance letter no., %2 = posting date';

    procedure AdvEntryInit(Preview: Boolean)
    begin
        if (PurchAdvLetterEntryCZZGlob."Entry No." = 0) and (not Preview) then begin
            PurchAdvLetterEntryCZZGlob.LockTable();
            if PurchAdvLetterEntryCZZGlob.FindLast() then;
        end;
        PurchAdvLetterEntryCZZGlob.Init();
        PurchAdvLetterEntryCZZGlob."Entry No." += 1;
    end;

    procedure AdvEntryInsert(EntryType: Enum "Advance Letter Entry Type CZZ"; AdvLetterNo: Code[20]; PostingDate: Date; Amt: Decimal; AmtLCY: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; DocumentNo: Code[20]; ExternalDocumentNo: Code[35]; GlDim1Code: Code[20]; GlDim2Code: Code[20]; DimSetID: Integer; Preview: Boolean)
    begin
        PurchAdvLetterEntryCZZGlob."Entry Type" := EntryType;
        PurchAdvLetterEntryCZZGlob."Purch. Adv. Letter No." := AdvLetterNo;
        PurchAdvLetterEntryCZZGlob."Posting Date" := PostingDate;
        PurchAdvLetterEntryCZZGlob.Amount := Amt;
        PurchAdvLetterEntryCZZGlob."Amount (LCY)" := AmtLCY;
        PurchAdvLetterEntryCZZGlob."Currency Code" := CurrencyCode;
        PurchAdvLetterEntryCZZGlob."Currency Factor" := CurrencyFactor;
        PurchAdvLetterEntryCZZGlob."Document No." := DocumentNo;
        PurchAdvLetterEntryCZZGlob."External Document No." := ExternalDocumentNo;
        PurchAdvLetterEntryCZZGlob."User ID" := CopyStr(UserId(), 1, MaxStrLen(PurchAdvLetterEntryCZZGlob."User ID"));
        PurchAdvLetterEntryCZZGlob."Global Dimension 1 Code" := GlDim1Code;
        PurchAdvLetterEntryCZZGlob."Global Dimension 2 Code" := GlDim2Code;
        PurchAdvLetterEntryCZZGlob."Dimension Set ID" := DimSetID;
        OnBeforeInsertAdvEntry(PurchAdvLetterEntryCZZGlob, Preview);
        if Preview then begin
            TempPurchAdvLetterEntryCZZGlob := PurchAdvLetterEntryCZZGlob;
            TempPurchAdvLetterEntryCZZGlob.Insert();
        end else
            PurchAdvLetterEntryCZZGlob.Insert();
        OnAfterInsertAdvEntry(PurchAdvLetterEntryCZZGlob, Preview);
    end;

    procedure AdvEntryInitVAT(VATBusPostGr: Code[20]; VATProdPostGr: Code[20]; VATDate: Date; OriginalDocumentVATDate: Date; VATEntryNo: Integer; VATPer: Decimal; VATIdentifier: Code[20]; VATCalcType: Enum "Tax Calculation Type"; VATAmount: Decimal; VATAmountLCY: Decimal; VATBase: Decimal; VATBaseLCY: Decimal)
    begin
        PurchAdvLetterEntryCZZGlob."VAT Bus. Posting Group" := VATBusPostGr;
        PurchAdvLetterEntryCZZGlob."VAT Prod. Posting Group" := VATProdPostGr;
        PurchAdvLetterEntryCZZGlob."VAT Date" := VATDate;
        PurchAdvLetterEntryCZZGlob."Original Document VAT Date" := OriginalDocumentVATDate;
        PurchAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
        PurchAdvLetterEntryCZZGlob."VAT %" := VATPer;
        PurchAdvLetterEntryCZZGlob."VAT Identifier" := VATIdentifier;
        PurchAdvLetterEntryCZZGlob."VAT Calculation Type" := VATCalcType;
        PurchAdvLetterEntryCZZGlob."VAT Amount" := VATAmount;
        PurchAdvLetterEntryCZZGlob."VAT Amount (LCY)" := VATAmountLCY;
        PurchAdvLetterEntryCZZGlob."VAT Base Amount" := VATBase;
        PurchAdvLetterEntryCZZGlob."VAT Base Amount (LCY)" := VATBaseLCY;
    end;

    procedure AdvEntryInitVendLedgEntryNo(VendLedgEntryNo: Integer)
    begin
        PurchAdvLetterEntryCZZGlob."Vendor Ledger Entry No." := VendLedgEntryNo;
    end;

    procedure AdvEntryInitDetVendLedgEntryNo(DetVendLedgEntryNo: Integer)
    begin
        PurchAdvLetterEntryCZZGlob."Det. Vendor Ledger Entry No." := DetVendLedgEntryNo;
    end;

    procedure AdvEntryInitRelatedEntry(RelatedEntry: Integer)
    begin
        PurchAdvLetterEntryCZZGlob."Related Entry" := RelatedEntry;
    end;

    procedure AdvEntryInitCancel()
    begin
        PurchAdvLetterEntryCZZGlob.Cancelled := true;
    end;

    procedure GetTempAdvLetterEntry(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
        if TempPurchAdvLetterEntryCZZGlob.FindSet() then begin
            repeat
                PurchAdvLetterEntryCZZ := TempPurchAdvLetterEntryCZZGlob;
                PurchAdvLetterEntryCZZ.Insert();
            until TempPurchAdvLetterEntryCZZGlob.Next() = 0;
            TempPurchAdvLetterEntryCZZGlob.DeleteAll();
        end;
    end;

    procedure UpdateStatus(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; DocStatus: Enum "Advance Letter Doc. Status CZZ")
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        OnBeforeUpdateStatus(PurchAdvLetterHeaderCZZ, DocStatus);
        case DocStatus of
            DocStatus::New:
                begin
                    PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
                    PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
                    PurchAdvLetterEntryCZZ.CalcSums(Amount);
                    if PurchAdvLetterEntryCZZ.Amount = 0 then begin
                        PurchAdvLetterHeaderCZZ.Status := PurchAdvLetterHeaderCZZ.Status::New;
                        PurchAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::"To Pay":
                begin
                    PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
                    PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
                    PurchAdvLetterEntryCZZ.CalcSums(Amount);
                    if PurchAdvLetterEntryCZZ.Amount <> 0 then begin
                        PurchAdvLetterHeaderCZZ.Status := PurchAdvLetterHeaderCZZ.Status::"To Pay";
                        PurchAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::"To Use":
                begin
                    PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
                    PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry", PurchAdvLetterEntryCZZ."Entry Type"::Payment, PurchAdvLetterEntryCZZ."Entry Type"::Close);
                    PurchAdvLetterEntryCZZ.CalcSums(Amount);
                    if PurchAdvLetterEntryCZZ.Amount = 0 then begin
                        PurchAdvLetterHeaderCZZ.Status := PurchAdvLetterHeaderCZZ.Status::"To Use";
                        PurchAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::Closed:
                begin
                    PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
                    PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry", PurchAdvLetterEntryCZZ."Entry Type"::Payment, PurchAdvLetterEntryCZZ."Entry Type"::Close);
                    PurchAdvLetterEntryCZZ.CalcSums(Amount);
                    if PurchAdvLetterEntryCZZ.Amount = 0 then begin
                        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3|%4|%5|%6', PurchAdvLetterEntryCZZ."Entry Type"::Payment, PurchAdvLetterEntryCZZ."Entry Type"::Usage, PurchAdvLetterEntryCZZ."Entry Type"::Close,
                            PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Close");
                        PurchAdvLetterEntryCZZ.CalcSums(Amount, "VAT Base Amount", "VAT Amount");
                        if (PurchAdvLetterEntryCZZ.Amount = 0) and (PurchAdvLetterEntryCZZ."VAT Base Amount" = 0) and (PurchAdvLetterEntryCZZ."VAT Amount" = 0) then begin
                            PurchAdvLetterHeaderCZZ.Status := PurchAdvLetterHeaderCZZ.Status::Closed;
                            PurchAdvLetterHeaderCZZ.Modify();
                        end;
                    end;
                end;
            else
                OnUpdateStatus(PurchAdvLetterHeaderCZZ, DocStatus);
        end;
    end;

    procedure CancelInitEntry(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; EntryDate: Date; Cancel: Boolean)
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        ToPayLCY: Decimal;
    begin
        PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
        if PurchAdvLetterHeaderCZZ."To Pay" = 0 then
            exit;

        if Cancel then begin
            PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
            PurchAdvLetterHeaderCZZ.TestField("To Pay", PurchAdvLetterHeaderCZZ."Amount Including VAT");
        end;

        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if PurchAdvLetterEntryCZZ.FindFirst() then begin
            if EntryDate = 0D then
                EntryDate := PurchAdvLetterEntryCZZ."Posting Date";

            if PurchAdvLetterEntryCZZ."Currency Factor" = 0 then
                ToPayLCY := PurchAdvLetterHeaderCZZ."To Pay"
            else
                ToPayLCY := Round(PurchAdvLetterHeaderCZZ."To Pay" / PurchAdvLetterEntryCZZ."Currency Factor");

            AdvEntryInit(false);
            if Cancel then
                AdvEntryInitCancel();
            AdvEntryInsert("Advance Letter Entry Type CZZ"::"Initial Entry", PurchAdvLetterHeaderCZZ."No.", EntryDate,
                PurchAdvLetterHeaderCZZ."To Pay", ToPayLCY,
                PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor", PurchAdvLetterHeaderCZZ."No.", '',
                PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", PurchAdvLetterHeaderCZZ."Dimension Set ID", false);

            if Cancel then begin
                PurchAdvLetterEntryCZZ.Cancelled := true;
                PurchAdvLetterEntryCZZ.Modify();
            end;
        end;
    end;

    procedure LinkAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        TempAdvanceLetterLinkBuffer: Record "Advance Letter Link Buffer CZZ" temporary;
        AdvanceLetterLink: Page "Advance Letter Link CZZ";
        PostingDate: Date;
    begin
        AdvanceLetterLink.SetCVEntry(VendorLedgerEntry.RecordId);
        AdvanceLetterLink.LookupMode(true);
        if AdvanceLetterLink.RunModal() = Action::LookupOK then begin
            AdvanceLetterLink.GetLetterLink(TempAdvanceLetterLinkBuffer);
            TempAdvanceLetterLinkBuffer.SetFilter(Amount, '>0');
            if not TempAdvanceLetterLinkBuffer.IsEmpty() then begin
                PostingDate := GetPostingDateUI(VendorLedgerEntry."Posting Date");
                if PostingDate = 0D then
                    Error(PostingDateEmptyErr);
                LinkAdvancePayment(VendorLedgerEntry, TempAdvanceLetterLinkBuffer, PostingDate);
            end;
        end;
    end;

    procedure LinkAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var TempAdvanceLetterLinkBuffer: Record "Advance Letter Link Buffer CZZ" temporary; PostingDate: Date)
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        TempAdvanceLetterLinkBuffer.SetFilter(Amount, '>0');
        if not TempAdvanceLetterLinkBuffer.IsEmpty() then
            repeat
                PostAdvancePayment(VendorLedgerEntry, TempAdvanceLetterLinkBuffer."Advance Letter No.", TempAdvanceLetterLinkBuffer.Amount, GenJnlPostLine, PostingDate);
            until TempAdvanceLetterLinkBuffer.Next() = 0;
    end;

    procedure PostAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry"; AdvanceLetterNo: Code[20]; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        PostingDate: Date;
    begin
        PostingDate := GetPostingDateUI(VendorLedgerEntry."Posting Date");
        if PostingDate = 0D then
            Error(PostingDateEmptyErr);

        PostAdvancePayment(VendorLedgerEntry, AdvanceLetterNo, LinkAmount, GenJnlPostLine, PostingDate);
    end;

    procedure PostAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostedGenJournalLine: Record "Gen. Journal Line"; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        PostingDate: Date;
    begin
        PostingDate := GetPostingDateUI(VendorLedgerEntry."Posting Date");
        if PostingDate = 0D then
            Error(PostingDateEmptyErr);

        PostAdvancePayment(VendorLedgerEntry, PostedGenJournalLine, LinkAmount, GenJnlPostLine, PostingDate);
    end;

    procedure PostAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry"; AdvanceLetterNo: Code[20]; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PostingDate: Date)
    var
        PostedGenJournalLine: Record "Gen. Journal Line";
    begin
        PostedGenJournalLine."Advance Letter No. CZZ" := AdvanceLetterNo;
        PostAdvancePayment(VendorLedgerEntry, PostedGenJournalLine, LinkAmount, GenJnlPostLine, PostingDate);
    end;

    procedure PostAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostedGenJournalLine: Record "Gen. Journal Line"; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PostingDate: Date)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        ApplId: Code[50];
        Amount: Decimal;
        AmountLCY: Decimal;
        IsHandled: Boolean;
        RemainingAmountExceededErr: Label 'The amount cannot be higher than remaining amount on ledger entry.';
        ToPayAmountExceededErr: Label 'The amount cannot be higher than to pay on advance letter.';
    begin
        OnBeforePostAdvancePayment(VendorLedgerEntry, PostedGenJournalLine, LinkAmount, GenJnlPostLine, IsHandled);
        if IsHandled then
            exit;

        VendorLedgerEntry.TestField("Advance Letter No. CZZ", '');
        PurchAdvLetterHeaderCZZ.Get(PostedGenJournalLine."Advance Letter No. CZZ");
        PurchAdvLetterHeaderCZZ.CheckPurchaseAdvanceLetterPostRestrictions();
        PurchAdvLetterHeaderCZZ.TestField("Currency Code", VendorLedgerEntry."Currency Code");
        PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", VendorLedgerEntry."Vendor No.");
        if LinkAmount = 0 then begin
            VendorLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
            Amount := VendorLedgerEntry."Remaining Amount";
            AmountLCY := VendorLedgerEntry."Remaining Amt. (LCY)";
        end else begin
            VendorLedgerEntry.CalcFields("Remaining Amount");
            if LinkAmount > VendorLedgerEntry."Remaining Amount" then
                Error(RemainingAmountExceededErr);

            Amount := LinkAmount;
            AmountLCY := Round(Amount / VendorLedgerEntry."Original Currency Factor");
        end;
        PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
        if Amount > PurchAdvLetterHeaderCZZ."To Pay" then
            Error(ToPayAmountExceededErr);

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Posting Date" := PostingDate;
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine.SetCurrencyFactor(VendorLedgerEntry."Currency Code", VendorLedgerEntry."Original Currency Factor");
        GenJournalLine.Amount := -Amount;
        GenJournalLine."Amount (LCY)" := -AmountLCY;

        ApplId := CopyStr(VendorLedgerEntry."Document No." + Format(VendorLedgerEntry."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
        VendorLedgerEntry.CalcFields("Remaining Amount");
        VendorLedgerEntry."Amount to Apply" := VendorLedgerEntry."Remaining Amount";
        VendorLedgerEntry."Applies-to ID" := ApplId;
        VendorLedgerEntry."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry);

        GenJournalLine."Applies-to ID" := ApplId;
        OnBeforePostPaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ, PostedGenJournalLine);
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        OnAfterPostPaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ, PostedGenJournalLine);

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Posting Date" := PostingDate;
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterHeaderCZZ."No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(VendorLedgerEntry."Currency Code", VendorLedgerEntry."Original Currency Factor");
        GenJournalLine.Amount := Amount;
        GenJournalLine."Amount (LCY)" := AmountLCY;
        OnBeforePostPayment(GenJournalLine, PurchAdvLetterHeaderCZZ, PostedGenJournalLine);
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        OnAfterPostPayment(GenJournalLine, PurchAdvLetterHeaderCZZ, PostedGenJournalLine);

        VendorLedgerEntry2.FindLast();
        AdvEntryInit(false);
        AdvEntryInitVendLedgEntryNo(VendorLedgerEntry2."Entry No.");
        AdvEntryInsert("Advance Letter Entry Type CZZ"::Payment, PurchAdvLetterHeaderCZZ."No.", GenJournalLine."Posting Date",
            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

        UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::"To Use")
    end;

    procedure GetAdvanceGLAccount(var GenJournalLine: Record "Gen. Journal Line"): Code[20]
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
    begin
        PurchAdvLetterHeaderCZZ.Get(GenJournalLine."Adv. Letter No. (Entry) CZZ");
        PurchAdvLetterHeaderCZZ.TestField("Advance Letter Code");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter G/L Account");
        exit(AdvanceLetterTemplateCZZ."Advance Letter G/L Account");
    end;

    procedure PostAdvancePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PostingDate: Date)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        DocumentTypeHandlerCZZ: Codeunit "Document Type Handler CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        ConfirmManagement: Codeunit "Confirm Management";
        VATDocumentCZZ: Page "VAT Document CZZ";
        DocumentNo: Code[20];
        IsHandled: Boolean;
        DocumentDate: Date;
        VATDate: Date;
        OriginalDocumentVATDate: Date;
        ExternalDocumentNo: Code[35];
        VATDocumentExistsQst: Label 'VAT Document already exists.\Continue?';
        ExceededAmountErr: Label 'Amount has been exceeded.';
    begin
        OnBeforePostPaymentVAT(PurchAdvLetterEntryCZZ, PostingDate, IsHandled);
        if IsHandled then
            exit;

        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        if PurchAdvLetterHeaderCZZ."Amount Including VAT" = 0 then
            exit;

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if not PurchAdvLetterEntryCZZ2.IsEmpty() then
            if not ConfirmManagement.GetResponseOrDefault(VATDocumentExistsQst, false) then
                exit;

        if PostingDate = 0D then
            PostingDate := PurchAdvLetterEntryCZZ."Posting Date";

        VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter Invoice Nos.");

        InitVATAmountLine(TempAdvancePostingBufferCZZ, PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ.Amount, PurchAdvLetterEntryCZZ."Currency Factor");
        VATDocumentCZZ.InitDocument(AdvanceLetterTemplateCZZ."Advance Letter Invoice Nos.", '', PurchAdvLetterHeaderCZZ."Document Date",
          PostingDate, PurchAdvLetterEntryCZZ."VAT Date", PurchAdvLetterHeaderCZZ."Original Document VAT Date",
          PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor", '', TempAdvancePostingBufferCZZ);
        if VATDocumentCZZ.RunModal() <> Action::OK then
            exit;

        VATDocumentCZZ.SaveNoSeries();
        VATDocumentCZZ.GetDocument(DocumentNo, PostingDate, DocumentDate, VATDate, OriginalDocumentVATDate, ExternalDocumentNo, TempAdvancePostingBufferCZZ);
        if (DocumentNo = '') or (PostingDate = 0D) or (VATDate = 0D) or (OriginalDocumentVATDate = 0D) then
            Error(DocumentNoOrDatesEmptyErr);

        if OriginalDocumentVATDate > VATDate then
            Error(OriginalDocVATDateMustBeLessOrVATDateErr, OriginalDocumentVATDate, VATDate);
        PurchasesPayablesSetup.Get();
        if PurchasesPayablesSetup."Ext. Doc. No. Mandatory" and (ExternalDocumentNo = '') then
            Error(ExternalDocumentNoEmptyErr);

#pragma warning disable AA0210
        TempAdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
#pragma warning restore AA0210
        if TempAdvancePostingBufferCZZ.IsEmpty() then
            Error(NothingToPostErr);

        PurchAdvLetterEntryCZZ2.CalcSums(Amount);
        TempAdvancePostingBufferCZZ.CalcSums(Amount);
        if Abs(PurchAdvLetterEntryCZZ.Amount - PurchAdvLetterEntryCZZ2.Amount) < Abs(TempAdvancePostingBufferCZZ.Amount) then
            Error(ExceededAmountErr);

        GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");

        TempAdvancePostingBufferCZZ.FindSet();
        repeat
            VATPostingSetup.Get(TempAdvancePostingBufferCZZ."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Purch. Adv. Letter Account CZZ");
            VATPostingSetup.TestField("Purch. Adv.Letter VAT Acc. CZZ");

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, VendorLedgerEntry."Source Code", PurchAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
            GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            GenJournalLine.Validate("Original Doc. VAT Date CZL", OriginalDocumentVATDate);
            GenJournalLine."Document Date" := DocumentDate;
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
            GenJournalLine."VAT Calculation Type" := TempAdvancePostingBufferCZZ."VAT Calculation Type";
            GenJournalLine."VAT Bus. Posting Group" := TempAdvancePostingBufferCZZ."VAT Bus. Posting Group";
            GenJournalLine.Validate("VAT Prod. Posting Group", TempAdvancePostingBufferCZZ."VAT Prod. Posting Group");
            GenJournalLine.Validate(Amount, TempAdvancePostingBufferCZZ.Amount);
            GenJournalLine."VAT Amount" := TempAdvancePostingBufferCZZ."VAT Amount";
            GenJournalLine."VAT Base Amount" := TempAdvancePostingBufferCZZ."VAT Base Amount";
            GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
            if GenJournalLine."Currency Code" <> '' then begin
                GenJournalLine."Amount (LCY)" := TempAdvancePostingBufferCZZ."Amount (ACY)";
                GenJournalLine."VAT Amount (LCY)" := TempAdvancePostingBufferCZZ."VAT Amount (ACY)";
                GenJournalLine."VAT Base Amount (LCY)" := TempAdvancePostingBufferCZZ."VAT Base Amount (ACY)";
                GenJournalLine."Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
            end else begin
                GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
                GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
            end;
            GenJournalLine."Bill-to/Pay-to No." := PurchAdvLetterHeaderCZZ."Pay-to Vendor No.";
            GenJournalLine."Country/Region Code" := PurchAdvLetterHeaderCZZ."Pay-to Country/Region Code";
            GenJournalLine."VAT Registration No." := PurchAdvLetterHeaderCZZ."VAT Registration No.";
            GenJournalLine."Registration No. CZL" := PurchAdvLetterHeaderCZZ."Registration No.";
            GenJournalLine."Tax Registration No. CZL" := PurchAdvLetterHeaderCZZ."Tax Registration No.";
            OnPostAdvancePaymentVATOnBeforeGenJnlPostLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, GenJournalLine);

            BindSubscription(VATPostingSetupHandlerCZZ);
            BindSubscription(DocumentTypeHandlerCZZ);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            UnbindSubscription(VATPostingSetupHandlerCZZ);
            UnbindSubscription(DocumentTypeHandlerCZZ);

#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
            AdvEntryInit(false);
            AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
            AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group",
                GenJournalLine."VAT Reporting Date", GenJournalLine."Original Doc. VAT Date CZL",
                GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
            AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Payment", PurchAdvLetterHeaderCZZ."No.", GenJournalLine."Posting Date",
                GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, VendorLedgerEntry."Source Code", PurchAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            GenJournalLine.Validate("Original Doc. VAT Date CZL", OriginalDocumentVATDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
            GenJournalLine.Validate(Amount, -TempAdvancePostingBufferCZZ.Amount);
            if GenJournalLine."Currency Code" <> '' then begin
                GenJournalLine."Amount (LCY)" := -TempAdvancePostingBufferCZZ."Amount (ACY)";
                GenJournalLine."Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
            end;
            GenJnlPostLine.RunWithCheck(GenJournalLine);
        until TempAdvancePostingBufferCZZ.Next() = 0;
    end;

    local procedure InitVATAmountLine(var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; PurchAdvanceNo: Code[20]; Amount: Decimal; CurrencyFactor: Decimal)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        Coeff: Decimal;
    begin
        AdvancePostingBufferCZZ.Reset();
        AdvancePostingBufferCZZ.DeleteAll();

        if Amount = 0 then
            exit;

        PurchAdvLetterHeaderCZZ.Get(PurchAdvanceNo);
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");

        Coeff := Amount / PurchAdvLetterHeaderCZZ."Amount Including VAT";

        BufferAdvanceLines(PurchAdvLetterHeaderCZZ, TempAdvancePostingBufferCZZ);
        TempAdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        if TempAdvancePostingBufferCZZ.FindSet() then
            repeat
                AdvancePostingBufferCZZ.Init();
                AdvancePostingBufferCZZ := TempAdvancePostingBufferCZZ;
                AdvancePostingBufferCZZ.RecalcAmountsByCoefficient(Coeff);
                AdvancePostingBufferCZZ.UpdateLCYAmounts(PurchAdvLetterHeaderCZZ."Currency Code", CurrencyFactor);
                AdvancePostingBufferCZZ.Insert();
            until TempAdvancePostingBufferCZZ.Next() = 0;
    end;

    local procedure BufferAdvanceLines(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
    begin
        AdvancePostingBufferCZZ.Reset();
        AdvancePostingBufferCZZ.DeleteAll();

        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");

        PurchAdvLetterLineCZZ.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterLineCZZ.SetFilter(Amount, '<>0');
        if not AdvanceLetterTemplateCZZ."Post VAT Doc. for Rev. Charge" then
            PurchAdvLetterLineCZZ.SetFilter("VAT Calculation Type", '<>%1', PurchAdvLetterLineCZZ."VAT Calculation Type"::"Reverse Charge VAT");
        if PurchAdvLetterLineCZZ.FindSet() then
            repeat
                TempAdvancePostingBufferCZZ.PrepareForPurchAdvLetterLine(PurchAdvLetterLineCZZ);
                AdvancePostingBufferCZZ.Update(TempAdvancePostingBufferCZZ);
            until PurchAdvLetterLineCZZ.Next() = 0;
    end;

    local procedure GetCurrency(CurrencyCode: Code[10])
    begin
        CurrencyGlob.Initialize(CurrencyCode, true);
    end;

    procedure LinkAdvanceLetter(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; PayToVendorNo: Code[20]; PostingDate: Date; CurrencyCode: Code[10])
    var
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        AdvanceLetterApplEditPageCZZ: Page "Advance Letter Appl. Edit CZZ";
        ModifyRecord: Boolean;
    begin
        AdvanceLetterApplEditPageCZZ.InitializePurchase(AdvLetterUsageDocTypeCZZ, DocumentNo, PayToVendorNo, PostingDate, CurrencyCode);
        Commit();
        AdvanceLetterApplEditPageCZZ.LookupMode(true);
        if AdvanceLetterApplEditPageCZZ.RunModal() = Action::LookupOK then begin
            AdvanceLetterApplEditPageCZZ.GetAssignedAdvance(TempAdvanceLetterApplicationCZZ);
            AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
            AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
            if AdvanceLetterApplicationCZZ.FindSet(true) then
                repeat
                    if TempAdvanceLetterApplicationCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter No.",
                        AdvanceLetterApplicationCZZ."Document Type", AdvanceLetterApplicationCZZ."Document No.") then begin
                        if TempAdvanceLetterApplicationCZZ.Amount <> AdvanceLetterApplicationCZZ.Amount then begin
                            AdvanceLetterApplicationCZZ.Amount := TempAdvanceLetterApplicationCZZ.Amount;
                            AdvanceLetterApplicationCZZ."Amount (LCY)" := TempAdvanceLetterApplicationCZZ."Amount (LCY)";
                            ModifyRecord := true;
                        end;
                        OnLinkAdvanceLetterOnBeforeModifyAdvanceLetterApplication(AdvanceLetterApplicationCZZ, TempAdvanceLetterApplicationCZZ, ModifyRecord);
                        if ModifyRecord then
                            AdvanceLetterApplicationCZZ.Modify();
                        TempAdvanceLetterApplicationCZZ.Delete(false);
                    end else
                        AdvanceLetterApplicationCZZ.Delete(true);
                until AdvanceLetterApplicationCZZ.Next() = 0;

            if TempAdvanceLetterApplicationCZZ.FindSet() then
                repeat
                    AdvanceLetterApplicationCZZ.Init();
                    AdvanceLetterApplicationCZZ."Advance Letter Type" := TempAdvanceLetterApplicationCZZ."Advance Letter Type";
                    AdvanceLetterApplicationCZZ."Advance Letter No." := TempAdvanceLetterApplicationCZZ."Advance Letter No.";
                    AdvanceLetterApplicationCZZ."Posting Date" := TempAdvanceLetterApplicationCZZ."Posting Date";
                    AdvanceLetterApplicationCZZ."Document Type" := AdvLetterUsageDocTypeCZZ;
                    AdvanceLetterApplicationCZZ."Document No." := DocumentNo;
                    AdvanceLetterApplicationCZZ.Amount := TempAdvanceLetterApplicationCZZ.Amount;
                    AdvanceLetterApplicationCZZ."Amount (LCY)" := TempAdvanceLetterApplicationCZZ."Amount (LCY)";
                    OnLinkAdvanceLetterOnBeforeInsertAdvanceLetterApplication(AdvanceLetterApplicationCZZ, TempAdvanceLetterApplicationCZZ);
                    AdvanceLetterApplicationCZZ.Insert();
                until TempAdvanceLetterApplicationCZZ.Next() = 0;
        end;
    end;

    procedure UnlinkAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PostingDate: Date;
    begin
        VendorLedgerEntry.TestField("Advance Letter No. CZZ");

        PostingDate := GetPostingDateUI(VendorLedgerEntry."Posting Date");
        if PostingDate = 0D then
            Error(PostingDateEmptyErr);

        PurchAdvLetterEntryCZZ1.SetRange("Purch. Adv. Letter No.", VendorLedgerEntry."Advance Letter No. CZZ");
        PurchAdvLetterEntryCZZ1.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ1.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        if PurchAdvLetterEntryCZZ1.FindSet() then
            repeat
                PurchAdvLetterEntryCZZ2 := PurchAdvLetterEntryCZZ1;
                UnlinkAdvancePayment(PurchAdvLetterEntryCZZ2, PostingDate);
            until PurchAdvLetterEntryCZZ1.Next() = 0;
    end;

    procedure UnlinkAdvancePayment(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PostingDate: Date;
    begin
        VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        PostingDate := GetPostingDateUI(VendorLedgerEntry."Posting Date");
        if PostingDate = 0D then
            Error(PostingDateEmptyErr);
        UnlinkAdvancePayment(PurchAdvLetterEntryCZZ, PostingDate);
    end;

    procedure UnlinkAdvancePayment(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PostingDate: Date)
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntryPay: Record "Vendor Ledger Entry";
        VendorLedgerEntryAdv: Record "Vendor Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        DocumentTypeHandlerCZZ: Codeunit "Document Type Handler CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        GenJnlCheckLnHandlerCZZ: Codeunit "Gen.Jnl.-Check Ln. Handler CZZ";
        ApplId: Code[50];
        UsedOnDocument: Text;
        UnlinkIsNotPossibleErr: Label 'Unlink is not possible, because %1 entry exists.', Comment = '%1 = Entry type';
        UsedOnDocumentQst: Label 'Advance is used on document(s) %1.\Continue?', Comment = '%1 = Advance No. list';
    begin
        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if PurchAdvLetterEntryCZZ2.FindFirst() then
            Error(UnlinkIsNotPossibleErr, PurchAdvLetterEntryCZZ2."Entry Type");

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase);
        AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        if AdvanceLetterApplicationCZZ.FindSet() then
            repeat
                if UsedOnDocument <> '' then
                    UsedOnDocument := UsedOnDocument + ', ';
                UsedOnDocument := AdvanceLetterApplicationCZZ."Document No.";
            until AdvanceLetterApplicationCZZ.Next() = 0;
        if UsedOnDocument <> '' then
            if not Confirm(UsedOnDocumentQst, false, UsedOnDocument) then
                Error('');

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        GetCurrency(PurchAdvLetterHeaderCZZ."Currency Code");

        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if PurchAdvLetterEntryCZZ2.FindSet() then begin
            repeat
                VATPostingSetup.Get(PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                VATPostingSetup.TestField("Purch. Adv. Letter Account CZZ");
                VATPostingSetup.TestField("Purch. Adv.Letter VAT Acc. CZZ");

                InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ2."External Document No.", '', '', GenJournalLine);
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
                GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ2."Posting Date");
                GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ2."Currency Code", PurchAdvLetterEntryCZZ2."Currency Factor");
                GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
                GenJournalLine."VAT Calculation Type" := PurchAdvLetterEntryCZZ2."VAT Calculation Type";
                GenJournalLine."VAT Bus. Posting Group" := PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group";
                GenJournalLine.validate("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                GenJournalLine.Validate(Amount, -PurchAdvLetterEntryCZZ2.Amount);
                GenJournalLine."VAT Amount" := -PurchAdvLetterEntryCZZ2."VAT Amount";
                GenJournalLine."VAT Base Amount" := -PurchAdvLetterEntryCZZ2."VAT Base Amount";
                GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                    CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ2."Amount (LCY)";
                GenJournalLine."VAT Amount (LCY)" := -PurchAdvLetterEntryCZZ2."VAT Amount (LCY)";
                GenJournalLine."VAT Base Amount (LCY)" := -PurchAdvLetterEntryCZZ2."VAT Base Amount (LCY)";
                BindSubscription(VATPostingSetupHandlerCZZ);
                BindSubscription(DocumentTypeHandlerCZZ);
                GenJnlPostLine.RunWithCheck(GenJournalLine);
                UnbindSubscription(VATPostingSetupHandlerCZZ);
                UnbindSubscription(DocumentTypeHandlerCZZ);

#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
                AdvEntryInit(false);
                AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
                AdvEntryInitCancel();
                AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group",
                    GenJournalLine."VAT Reporting Date", GenJournalLine."Original Doc. VAT Date CZL",
                    GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                    GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                AdvEntryInsert(PurchAdvLetterEntryCZZ2."Entry Type", PurchAdvLetterEntryCZZ2."Purch. Adv. Letter No.", GenJournalLine."Posting Date",
                    GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                    GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                    GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ."External Document No.", '', '', GenJournalLine);
                GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ2."Posting Date");
                GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ2."Currency Code", PurchAdvLetterEntryCZZ2."Currency Factor");
                GenJournalLine.Amount := PurchAdvLetterEntryCZZ2.Amount;
                GenJournalLine."Amount (LCY)" := PurchAdvLetterEntryCZZ2."Amount (LCY)";
                GenJnlPostLine.RunWithCheck(GenJournalLine);
            until PurchAdvLetterEntryCZZ2.Next() = 0;
            PurchAdvLetterEntryCZZ2.ModifyAll(Cancelled, true);
        end;

        VendorLedgerEntryAdv.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        VendorLedgerEntryPay := VendorLedgerEntryAdv;
#pragma warning disable AA0181
        VendorLedgerEntryPay.Next(-1);
#pragma warning restore AA0181
        UnapplyVendLedgEntry(VendorLedgerEntryPay, GenJnlPostLine);

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntryAdv, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Posting Date" := PostingDate;
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := -PurchAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ."Amount (LCY)";
        ApplId := CopyStr(VendorLedgerEntryAdv."Document No." + Format(VendorLedgerEntryAdv."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
        VendorLedgerEntryAdv.Prepayment := false;
        VendorLedgerEntryAdv."Advance Letter No. CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
        VendorLedgerEntryAdv.CalcFields("Remaining Amount");
        VendorLedgerEntryAdv."Amount to Apply" := VendorLedgerEntryAdv."Remaining Amount";
        VendorLedgerEntryAdv."Applies-to ID" := ApplId;
        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntryAdv);
        GenJournalLine."Applies-to ID" := ApplId;
        GenJnlPostLine.RunWithCheck(GenJournalLine);

        VendorLedgerEntry.FindLast();

        AdvEntryInit(false);
        AdvEntryInitVendLedgEntryNo(VendorLedgerEntry."Entry No.");
        AdvEntryInitCancel();
        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
        AdvEntryInsert(PurchAdvLetterEntryCZZ."Entry Type", GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntryAdv, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Posting Date" := PostingDate;
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := PurchAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := PurchAdvLetterEntryCZZ."Amount (LCY)";
        ApplId := CopyStr(VendorLedgerEntryPay."Document No." + Format(VendorLedgerEntryPay."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
        VendorLedgerEntryPay.CalcFields("Remaining Amount");
        VendorLedgerEntryPay."Amount to Apply" := VendorLedgerEntryPay."Remaining Amount";
        VendorLedgerEntryPay."Applies-to ID" := ApplId;
        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntryPay);
        GenJournalLine."Applies-to ID" := ApplId;
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        UnbindSubscription(GenJnlCheckLnHandlerCZZ);

        PurchAdvLetterEntryCZZ.Cancelled := true;
        PurchAdvLetterEntryCZZ.Modify();

        UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::"To Pay");
    end;

    procedure PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; var PurchInvHeader: Record "Purch. Inv. Header"; var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        TempPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ" temporary;
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        AdvanceLetterTypeCZZ: Enum "Advance Letter Type CZZ";
        AmountToUse, UseAmount, UseAmountLCY : Decimal;
        IsHandled: Boolean;
    begin
        OnBeforePostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ, DocumentNo, PurchInvHeader, VendorLedgerEntry, GenJnlPostLine, Preview, IsHandled);
        if IsHandled then
            exit;

        if VendorLedgerEntry."Remaining Amount" = 0 then
            VendorLedgerEntry.CalcFields("Remaining Amount");

        if VendorLedgerEntry."Remaining Amount" = 0 then
            exit;

        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
        if AdvanceLetterApplicationCZZ.IsEmpty() then
            exit;

        AdvanceLetterApplicationCZZ.FindSet();
        repeat
            PurchAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
            PurchAdvLetterHeaderCZZ.TestField("Currency Code", PurchInvHeader."Currency Code");
            PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", PurchInvHeader."Pay-to Vendor No.");

            PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
            PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
            PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
            PurchAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', PurchInvHeader."Posting Date");
            OnPostAdvancePaymentUsageOnBeforeLoopPurchAdvLetterEntry(AdvanceLetterApplicationCZZ, PurchAdvLetterEntryCZZ);
            if PurchAdvLetterEntryCZZ.FindSet() then
                repeat
                    TempPurchAdvLetterEntryCZZ := PurchAdvLetterEntryCZZ;
                    TempPurchAdvLetterEntryCZZ.Amount := GetRemAmtPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D);
                    if TempPurchAdvLetterEntryCZZ.Amount <> 0 then
                        TempPurchAdvLetterEntryCZZ.Insert();
                until PurchAdvLetterEntryCZZ.Next() = 0;
            TempAdvanceLetterApplicationCZZ.Init();
            TempAdvanceLetterApplicationCZZ."Advance Letter No." := AdvanceLetterApplicationCZZ."Advance Letter No.";
            TempAdvanceLetterApplicationCZZ.Amount := AdvanceLetterApplicationCZZ.Amount;
            TempAdvanceLetterApplicationCZZ."Amount (LCY)" := AdvanceLetterApplicationCZZ."Amount (LCY)";
            TempAdvanceLetterApplicationCZZ.Insert();
        until AdvanceLetterApplicationCZZ.Next() = 0;

        AmountToUse := -VendorLedgerEntry."Remaining Amount";
        TempPurchAdvLetterEntryCZZ.Reset();
        TempPurchAdvLetterEntryCZZ.SetCurrentKey("Posting Date");
        if TempPurchAdvLetterEntryCZZ.FindSet() then
            repeat
                TempAdvanceLetterApplicationCZZ.Get(0, TempPurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                if TempAdvanceLetterApplicationCZZ.Amount < TempPurchAdvLetterEntryCZZ.Amount then
                    TempPurchAdvLetterEntryCZZ.Amount := TempAdvanceLetterApplicationCZZ.Amount;

                if AmountToUse > TempPurchAdvLetterEntryCZZ.Amount then
                    UseAmount := TempPurchAdvLetterEntryCZZ.Amount
                else
                    UseAmount := AmountToUse;

                if UseAmount <> 0 then begin
                    PurchAdvLetterEntryCZZ.Get(TempPurchAdvLetterEntryCZZ."Entry No.");
                    UseAmountLCY := Round(GetRemAmtLCYPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D) * UseAmount / GetRemAmtPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D));
                    ReverseAdvancePayment(PurchAdvLetterEntryCZZ, PurchInvHeader, UseAmount, UseAmountLCY, VendorLedgerEntry, GenJnlPostLine, Preview);
                    AmountToUse -= UseAmount;
                    TempAdvanceLetterApplicationCZZ.Amount -= UseAmount;
                    TempAdvanceLetterApplicationCZZ."Amount (LCY)" -= UseAmountLCY;
                    TempAdvanceLetterApplicationCZZ.Modify();

                    if not Preview then
                        if AdvanceLetterApplicationCZZ.Get(AdvanceLetterTypeCZZ::Purchase, PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", AdvLetterUsageDocTypeCZZ, DocumentNo) then
                            if AdvanceLetterApplicationCZZ.Amount <= UseAmount then
                                AdvanceLetterApplicationCZZ.Delete(true)
                            else begin
                                AdvanceLetterApplicationCZZ.Amount -= UseAmount;
                                AdvanceLetterApplicationCZZ.Modify();
                            end;
                end;
            until (TempPurchAdvLetterEntryCZZ.Next() = 0) or (AmountToUse = 0);
    end;

    local procedure ReverseAdvancePayment(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PurchInvHeader: Record "Purch. Inv. Header"; ReverseAmount: Decimal; ReverseAmountLCY: Decimal; var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        DocumentTypeHandlerCZZ: Codeunit "Document Type Handler CZZ";
        GenJnlCheckLnHandlerCZZ: Codeunit "Gen.Jnl.-Check Ln. Handler CZZ";
        RemainingAmount: Decimal;
        RemainingAmountLCY: Decimal;
        ApplId: Code[50];
        ReverseErr: Label 'Reverse amount %1 is not posible on entry %2.', Comment = '%1 = Reverse Amount, %2 = Purchase Advance Entry No.';
    begin
        RemainingAmount := GetRemAmtPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D);
        RemainingAmountLCY := GetRemAmtLCYPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D);

        if ReverseAmount <> 0 then begin
            if ReverseAmount > RemainingAmount then
                Error(ReverseErr, ReverseAmount, PurchAdvLetterEntryCZZ."Entry No.");
        end else begin
            ReverseAmount := RemainingAmount;
            ReverseAmountLCY := RemainingAmountLCY;
        end;

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := ReverseAmount;
        GenJournalLine."Amount (LCY)" := ReverseAmountLCY;

        if not Preview then begin
            ApplId := CopyStr(VendorLedgerEntry."Document No." + Format(VendorLedgerEntry."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
            VendorLedgerEntry.CalcFields("Remaining Amount");
            VendorLedgerEntry."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
            VendorLedgerEntry."Amount to Apply" := VendorLedgerEntry."Remaining Amount";
            VendorLedgerEntry."Applies-to ID" := ApplId;
            Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry);
            GenJournalLine."Applies-to ID" := ApplId;

            OnBeforePostReversePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
            BindSubscription(GenJnlCheckLnHandlerCZZ);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            OnAfterPostReversePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
        end;

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::Invoice);
        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := -ReverseAmount;
        GenJournalLine."Amount (LCY)" := -ReverseAmountLCY;

        VendorLedgerEntry2.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        if not Preview then begin
            ApplId := CopyStr(VendorLedgerEntry2."Document No." + Format(VendorLedgerEntry2."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
            VendorLedgerEntry2.Prepayment := false;
            VendorLedgerEntry2."Advance Letter No. CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
            VendorLedgerEntry2.Modify();
            VendorLedgerEntry2.CalcFields("Remaining Amount");
            VendorLedgerEntry2."Amount to Apply" := VendorLedgerEntry2."Remaining Amount";
            VendorLedgerEntry2."Applies-to ID" := ApplId;
            Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry2);
            GenJournalLine."Applies-to ID" := ApplId;

            OnBeforePostReversePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);
            BindSubscription(DocumentTypeHandlerCZZ);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            UnbindSubscription(GenJnlCheckLnHandlerCZZ);
            UnbindSubscription(DocumentTypeHandlerCZZ);
            OnAfterPostReversePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);

            VendorLedgerEntry2.FindLast();
        end;

        AdvEntryInit(Preview);
        AdvEntryInitVendLedgEntryNo(VendorLedgerEntry2."Entry No.");
        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
        AdvEntryInsert("Advance Letter Entry Type CZZ"::Usage, GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", Preview);

        if PurchAdvLetterHeaderCZZ."Automatic Post VAT Usage" then
            ReverseAdvancePaymentVAT(PurchAdvLetterEntryCZZ, VendorLedgerEntry."Source Code", VendorLedgerEntry.Description,
                PurchInvHeader."VAT Currency Factor CZL", Enum::"Gen. Journal Document Type"::Invoice,
                VendorLedgerEntry."Document No.", VendorLedgerEntry."External Document No.",
                VendorLedgerEntry."Posting Date", VendorLedgerEntry."VAT Date CZL", PurchInvHeader."Original Doc. VAT Date CZL",
                ReverseAmount, PurchAdvLetterEntryCZZGlob."Entry No.", VendorLedgerEntry."Document No.",
                "Advance Letter Entry Type CZZ"::"VAT Usage", true, GenJnlPostLine, Preview);

        if not Preview then begin
            PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
            UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::Closed);
        end;
    end;

    local procedure ReverseAdvancePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; SourceCode: Code[10]; PostDescription: Text[100]; CurrencyFactor: Decimal; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; ExternalDocumentNo: Code[35]; PostingDate: Date; VATDate: Date; OriginalDocumentVATDate: Date; ReverseAmount: Decimal; UsageEntryNo: Integer; InvoiceNo: Code[20]; EntryType: enum "Advance Letter Entry Type CZZ"; AutoPostVATUsage: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        DocumentTypeHandlerCZZ: Codeunit "Document Type Handler CZZ";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        VATDocumentCZZ: Page "VAT Document CZZ";
        CalcVATAmountLCY: Decimal;
        CalcAmountLCY: Decimal;
        ExchRateAmount: Decimal;
        ExchRateVATAmount: Decimal;
        AmountToUse: Decimal;
        DocumentDate: Date;
        IsHandled: Boolean;
        UsedMoreAmountErr: Label 'Post VAT Document higher than usage is not possible.';
    begin
        OnBeforePostReversePaymentVAT(PurchAdvLetterEntryCZZ, PostingDate, Preview, IsHandled);
        if IsHandled then
            exit;

        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if PurchAdvLetterEntryCZZ2.IsEmpty() then
            exit;

        GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, 0D);
        SuggestUsageVAT(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, InvoiceNo, ReverseAmount, CurrencyFactor, Preview);

        if not AutoPostVATUsage then begin
            VATDocumentCZZ.InitDocument('', DocumentNo, PostingDate, PostingDate, VATDate,
              OriginalDocumentVATDate, PurchAdvLetterHeaderCZZ."Currency Code", CurrencyFactor, ExternalDocumentNo, TempAdvancePostingBufferCZZ1);
            if VATDocumentCZZ.RunModal() <> Action::OK then
                exit;

            VATDocumentCZZ.GetDocument(DocumentNo, PostingDate, DocumentDate, VATDate, OriginalDocumentVATDate, ExternalDocumentNo, TempAdvancePostingBufferCZZ1);
            if (DocumentNo = '') or (PostingDate = 0D) or (VATDate = 0D) or (OriginalDocumentVATDate = 0D) then
                Error(DocumentNoOrDatesEmptyErr);

            if OriginalDocumentVATDate > VATDate then
                Error(OriginalDocVATDateMustBeLessOrVATDateErr, OriginalDocumentVATDate, VATDate);
            PurchasesPayablesSetup.Get();
            if PurchasesPayablesSetup."Ext. Doc. No. Mandatory" and (ExternalDocumentNo = '') then
                Error(ExternalDocumentNoEmptyErr);

            TempAdvancePostingBufferCZZ1.SetFilter(Amount, '<>0');
            if TempAdvancePostingBufferCZZ1.IsEmpty() then
                Error(NothingToPostErr);

            if ReverseAmount <> 0 then begin
                TempAdvancePostingBufferCZZ1.CalcSums(Amount);
                if TempAdvancePostingBufferCZZ1.Amount > ReverseAmount then
                    Error(UsedMoreAmountErr);
            end;
        end;

        if OriginalDocumentVATDate = 0D then
            OriginalDocumentVATDate := VATDate;

        TempAdvancePostingBufferCZZ1.FilterGroup(-1);
#pragma warning disable AA0210
        TempAdvancePostingBufferCZZ1.SetFilter("VAT Base Amount", '<>0');
        TempAdvancePostingBufferCZZ1.SetFilter("VAT Amount", '<>0');
#pragma warning restore AA0210
        TempAdvancePostingBufferCZZ1.FilterGroup(0);
        if TempAdvancePostingBufferCZZ1.IsEmpty() then
            exit;

        if PurchAdvLetterEntryCZZ."Currency Code" <> '' then begin
            BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ2, 0D);
            TempAdvancePostingBufferCZZ2.CalcSums(Amount);
            AmountToUse := TempAdvancePostingBufferCZZ2.Amount;
        end;

        CalculateVATAmountInBuffer(PostingDate, PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor, TempAdvancePostingBufferCZZ1);

        TempAdvancePostingBufferCZZ1.FindSet();
        repeat
            VATPostingSetup.Get(TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Purch. Adv. Letter Account CZZ");
            VATPostingSetup.TestField("Purch. Adv.Letter VAT Acc. CZZ");

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, SourceCode, PostDescription, GenJournalLine);
            GenJournalLine."Document Type" := DocumentType;
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            GenJournalLine.Validate("Original Doc. VAT Date CZL", OriginalDocumentVATDate);
            GenJournalLine."Document Date" := DocumentDate;
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
            GenJournalLine."VAT Calculation Type" := TempAdvancePostingBufferCZZ1."VAT Calculation Type";
            if GenJournalLine."VAT Calculation Type" = GenJournalLine."VAT Calculation Type"::"Reverse Charge VAT" then
                GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
            GenJournalLine."VAT Bus. Posting Group" := TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group";
            GenJournalLine.Validate("VAT Prod. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
            GenJournalLine.Validate(Amount, -TempAdvancePostingBufferCZZ1.Amount);
            GenJournalLine."VAT Amount" := -TempAdvancePostingBufferCZZ1."VAT Amount";
            GenJournalLine."VAT Base Amount" := -TempAdvancePostingBufferCZZ1."VAT Base Amount";
            GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
            if GenJournalLine."Currency Code" <> '' then begin
                GenJournalLine."Amount (LCY)" := -TempAdvancePostingBufferCZZ1."Amount (ACY)";
                GenJournalLine."VAT Amount (LCY)" := -TempAdvancePostingBufferCZZ1."VAT Amount (ACY)";
                GenJournalLine."VAT Base Amount (LCY)" := -TempAdvancePostingBufferCZZ1."VAT Base Amount (ACY)";
                GenJournalLine."Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
            end else begin
                GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
                GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
            end;
            if not Preview then begin
                BindSubscription(VATPostingSetupHandlerCZZ);
                BindSubscription(DocumentTypeHandlerCZZ);
                GenJnlPostLine.RunWithCheck(GenJournalLine);
                UnbindSubscription(VATPostingSetupHandlerCZZ);
                UnbindSubscription(DocumentTypeHandlerCZZ);
            end;

            if TempAdvancePostingBufferCZZ1."VAT Calculation Type" = TempAdvancePostingBufferCZZ1."VAT Calculation Type"::"Reverse Charge VAT" then begin
                GenJournalLine."VAT Amount" := 0;
                GenJournalLine."VAT Amount (LCY)" := 0;
            end;

#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
            AdvEntryInit(Preview);
            AdvEntryInitRelatedEntry(UsageEntryNo);
            AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group",
                GenJournalLine."VAT Reporting Date", GenJournalLine."Original Doc. VAT Date CZL",
                GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
            AdvEntryInsert(EntryType, PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", GenJournalLine."Posting Date",
                GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", Preview);

            if GenJournalLine."Currency Code" <> '' then begin
                TempAdvancePostingBufferCZZ2.Reset();
                TempAdvancePostingBufferCZZ2.SetRange("VAT Bus. Posting Group", TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group");
                TempAdvancePostingBufferCZZ2.SetRange("VAT Prod. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
                if TempAdvancePostingBufferCZZ2.FindFirst() then begin
                    CalcAmountLCY := Round(TempAdvancePostingBufferCZZ2."Amount (ACY)" * TempAdvancePostingBufferCZZ1.Amount / TempAdvancePostingBufferCZZ2.Amount);
                    CalcVATAmountLCY := Round(TempAdvancePostingBufferCZZ2."VAT Amount (ACY)" * TempAdvancePostingBufferCZZ1.Amount / TempAdvancePostingBufferCZZ2.Amount);

                    ExchRateAmount := CalcAmountLCY + GenJournalLine."Amount (LCY)";
                    ExchRateVATAmount := CalcVATAmountLCY + GenJournalLine."VAT Amount (LCY)";
                    if (ExchRateAmount <> 0) or (ExchRateVATAmount <> 0) then
                        PostExchangeRate(-ExchRateAmount, -ExchRateVATAmount, PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                            DocumentNo, PostingDate, VATDate, SourceCode, PostDescription, UsageEntryNo, false, GenJnlPostLine, Preview);

                    ReverseUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, TempAdvancePostingBufferCZZ1.Amount / AmountToUse,
                        UsageEntryNo, DocumentNo, PostingDate, VATDate, PostDescription, GenJnlPostLine, Preview);
                end;
            end;

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            GenJournalLine.Validate("Original Doc. VAT Date CZL", OriginalDocumentVATDate);
            GenJournalLine."Document Date" := DocumentDate;
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
            GenJournalLine.Validate(Amount, TempAdvancePostingBufferCZZ1.Amount);
            if GenJournalLine."Currency Code" <> '' then
                GenJournalLine."Amount (LCY)" := TempAdvancePostingBufferCZZ1."Amount (ACY)";
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);
        until TempAdvancePostingBufferCZZ1.Next() = 0;

        if not Preview then
            UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

    local procedure CalculateVATAmountInBuffer(PostingDate: Date; CurrencyCode: Code[10]; CurrencyFactor: Decimal; var TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        VATAmount: Decimal;
        VATAmountRemainder: Decimal;
    begin
        VATAmountRemainder := 0;

        GetCurrency(CurrencyCode);

        if TempAdvancePostingBufferCZZ.FindSet() then
            repeat
                if TempAdvancePostingBufferCZZ."VAT Calculation Type" = TempAdvancePostingBufferCZZ."VAT Calculation Type"::"Reverse Charge VAT" then begin
                    VATPostingSetup.Get(TempAdvancePostingBufferCZZ."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ."VAT Prod. Posting Group");

                    VATAmount := TempAdvancePostingBufferCZZ."VAT Base Amount" * VATPostingSetup."VAT %" / 100;

                    VATAmountRemainder += VATAmount;
                    TempAdvancePostingBufferCZZ."VAT Amount" := Round(VATAmountRemainder, CurrencyGlob."Amount Rounding Precision");
                    TempAdvancePostingBufferCZZ."VAT Amount (ACY)" := TempAdvancePostingBufferCZZ."VAT Amount";
                    VATAmountRemainder -= TempAdvancePostingBufferCZZ."VAT Amount";

                    if CurrencyCode <> '' then
                        TempAdvancePostingBufferCZZ."VAT Amount (ACY)" :=
                            Round(
                                CurrExchRate.ExchangeAmtFCYToLCY(
                                    PostingDate, CurrencyCode, TempAdvancePostingBufferCZZ."VAT Amount", CurrencyFactor));
                    TempAdvancePostingBufferCZZ.Modify();
                end
            until TempAdvancePostingBufferCZZ.Next() = 0;
    end;

    local procedure SuggestUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; InvoiceNo: Code[20]; UsedAmount: Decimal; CurrencyFactor: Decimal; Preview: Boolean)
    var
        PurchInvLine: Record "Purch. Inv. Line";
        PurchaseLine: Record "Purchase Line";
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        TotalAmount: Decimal;
        UseAmount: Decimal;
        UseBaseAmount: Decimal;
        i: Integer;
        Continue: Boolean;
    begin
        AdvancePostingBufferCZZ.CalcSums(Amount);
        TotalAmount := AdvancePostingBufferCZZ.Amount;
        if (UsedAmount <> 0) and (TotalAmount > UsedAmount) then begin
            Continue := InvoiceNo <> '';
            if Continue then
                if Preview then begin
                    PurchaseLine.SetFilter("Document Type", '%1|%2', PurchaseLine."Document Type"::Order, PurchaseLine."Document Type"::Invoice);
                    PurchaseLine.SetRange("Document No.", InvoiceNo);
                    Continue := PurchaseLine.FindSet();
                end else begin
                    PurchInvLine.SetRange("Document No.", InvoiceNo);
                    Continue := PurchInvLine.FindSet();
                end;

            if Continue then begin
                BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ2, 0D);

                if Preview then
                    repeat
                        TempAdvancePostingBufferCZZ1.Init();
                        TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group" := PurchaseLine."VAT Bus. Posting Group";
                        TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group" := PurchaseLine."VAT Prod. Posting Group";
                        if TempAdvancePostingBufferCZZ1.Find() then begin
                            TempAdvancePostingBufferCZZ1.Amount += PurchaseLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" += PurchaseLine.Amount;
                            TempAdvancePostingBufferCZZ1.Modify();
                        end else begin
                            TempAdvancePostingBufferCZZ1."VAT Calculation Type" := PurchaseLine."VAT Calculation Type";
                            TempAdvancePostingBufferCZZ1."VAT %" := PurchaseLine."VAT %";
                            TempAdvancePostingBufferCZZ1.Amount := PurchaseLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" := PurchaseLine.Amount;
                            TempAdvancePostingBufferCZZ1.Insert();
                        end;
                    until PurchaseLine.Next() = 0
                else
                    repeat
                        TempAdvancePostingBufferCZZ1.Init();
                        TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group" := PurchInvLine."VAT Bus. Posting Group";
                        TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group" := PurchInvLine."VAT Prod. Posting Group";
                        if TempAdvancePostingBufferCZZ1.Find() then begin
                            TempAdvancePostingBufferCZZ1.Amount += PurchInvLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" += PurchInvLine.Amount;
                            TempAdvancePostingBufferCZZ1.Modify();
                        end else begin
                            TempAdvancePostingBufferCZZ1."VAT Calculation Type" := PurchInvLine."VAT Calculation Type";
                            TempAdvancePostingBufferCZZ1."VAT %" := PurchInvLine."VAT %";
                            TempAdvancePostingBufferCZZ1.Amount := PurchInvLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" := PurchInvLine.Amount;
                            TempAdvancePostingBufferCZZ1.Insert();
                        end;
                    until PurchInvLine.Next() = 0;

                GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");

                for i := 1 to 3 do begin
                    TempAdvancePostingBufferCZZ1.FindSet();
                    repeat
                        case i of
                            1:
                                begin
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT Bus. Posting Group", TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group");
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT Prod. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
                                end;
                            2:
                                begin
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT Calculation Type", TempAdvancePostingBufferCZZ1."VAT Calculation Type");
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT %", TempAdvancePostingBufferCZZ1."VAT %");
                                end;
                        end;
                        TempAdvancePostingBufferCZZ2.SetFilter(Amount, '<>%1', 0);
                        if TempAdvancePostingBufferCZZ2.FindSet() then
                            repeat
                                UseAmount := TempAdvancePostingBufferCZZ1.Amount;
                                UseBaseAmount := TempAdvancePostingBufferCZZ1."VAT Base Amount";
                                if Abs(TempAdvancePostingBufferCZZ2.Amount) < Abs(UseAmount) then begin
                                    UseAmount := TempAdvancePostingBufferCZZ2.Amount;
                                    UseBaseAmount := TempAdvancePostingBufferCZZ2."VAT Base Amount";
                                end;
                                if Abs(UsedAmount) < Abs(UseAmount) then begin
                                    UseAmount := UsedAmount;
                                    UseBaseAmount := Round(TempAdvancePostingBufferCZZ2."VAT Base Amount" * UseAmount / TempAdvancePostingBufferCZZ2.Amount, CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                                end;
                                if TempAdvancePostingBufferCZZ1."VAT %" <> TempAdvancePostingBufferCZZ2."VAT %" then
                                    UseBaseAmount := Round(TempAdvancePostingBufferCZZ2."VAT Base Amount" * UseAmount / TempAdvancePostingBufferCZZ2.Amount, CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());

                                TempAdvancePostingBufferCZZ2.Amount -= UseAmount;
                                TempAdvancePostingBufferCZZ2."VAT Base Amount" -= UseBaseAmount;
                                TempAdvancePostingBufferCZZ2.Modify();
                                TempAdvancePostingBufferCZZ1.Amount -= UseAmount;
                                TempAdvancePostingBufferCZZ1."VAT Base Amount" -= UseBaseAmount;
                                TempAdvancePostingBufferCZZ1.Modify();
                                UsedAmount -= UseAmount;
                            until (TempAdvancePostingBufferCZZ2.Next() = 0) or (UsedAmount = 0);
                        TempAdvancePostingBufferCZZ2.Reset();
                    until TempAdvancePostingBufferCZZ1.Next() = 0;
                end;

                if AdvancePostingBufferCZZ.FindSet() then
                    repeat
                        TempAdvancePostingBufferCZZ2.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");
                        case true of
                            TempAdvancePostingBufferCZZ2.Amount = 0:
                                ;
                            TempAdvancePostingBufferCZZ2.Amount <> AdvancePostingBufferCZZ.Amount:
                                begin
                                    AdvancePostingBufferCZZ.Amount := AdvancePostingBufferCZZ.Amount - TempAdvancePostingBufferCZZ2.Amount;
                                    AdvancePostingBufferCZZ."VAT Base Amount" := AdvancePostingBufferCZZ."VAT Base Amount" - TempAdvancePostingBufferCZZ2."VAT Base Amount";
                                    AdvancePostingBufferCZZ."VAT Amount" := AdvancePostingBufferCZZ.Amount - AdvancePostingBufferCZZ."VAT Base Amount";
                                    AdvancePostingBufferCZZ.Modify();
                                end;
                            TempAdvancePostingBufferCZZ2.Amount = AdvancePostingBufferCZZ.Amount:
                                begin
                                    AdvancePostingBufferCZZ.Amount := 0;
                                    AdvancePostingBufferCZZ."VAT Base Amount" := 0;
                                    AdvancePostingBufferCZZ."VAT Amount" := 0;
                                    AdvancePostingBufferCZZ.Modify();
                                end;
                        end;
                    until AdvancePostingBufferCZZ.Next() = 0;
            end else begin
                AdvancePostingBufferCZZ.FindSet();
                repeat
                    AdvancePostingBufferCZZ.Amount := Round(AdvancePostingBufferCZZ.Amount * UsedAmount / TotalAmount, CurrencyGlob."Amount Rounding Precision");
                    AdvancePostingBufferCZZ."VAT Amount" := Round(AdvancePostingBufferCZZ."VAT Amount" * UsedAmount / TotalAmount, CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                    AdvancePostingBufferCZZ."VAT Base Amount" := AdvancePostingBufferCZZ.Amount - AdvancePostingBufferCZZ."VAT Amount";
                    AdvancePostingBufferCZZ.Modify();
                until AdvancePostingBufferCZZ.Next() = 0;
            end;
        end;

        if AdvancePostingBufferCZZ.FindSet() then
            repeat
                AdvancePostingBufferCZZ.UpdateLCYAmounts(PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                AdvancePostingBufferCZZ.Modify();
            until AdvancePostingBufferCZZ.Next() = 0;
    end;

    procedure PostAdvancePaymentUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        PurchInvHeader: Record "Purch. Inv. Header";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CurrencyFactor: Decimal;
    begin
        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Usage then
            exit;

        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        if not PurchAdvLetterEntryCZZ2.IsEmpty() then
            Error(VATDocumentExistsErr);

        PurchAdvLetterEntryCZZ2.Get(PurchAdvLetterEntryCZZ."Related Entry");
        PurchAdvLetterEntryCZZ2.TestField(PurchAdvLetterEntryCZZ2."Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::Payment);

        BufferAdvanceVATLines(PurchAdvLetterEntryCZZ2, TempAdvancePostingBufferCZZ, 0D);
        TempAdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        if TempAdvancePostingBufferCZZ.IsEmpty() then
            Error(NothingToPostErr);

        VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");

        if PurchInvHeader.Get(VendorLedgerEntry."Document No.") then
            CurrencyFactor := PurchInvHeader."VAT Currency Factor CZL"
        else
            CurrencyFactor := VendorLedgerEntry."Original Currency Factor";

        ReverseAdvancePaymentVAT(PurchAdvLetterEntryCZZ2, VendorLedgerEntry."Source Code", VendorLedgerEntry.Description,
            CurrencyFactor, Enum::"Gen. Journal Document Type"::Invoice, PurchAdvLetterEntryCZZ."Document No.",
            VendorLedgerEntry."External Document No.", VendorLedgerEntry."Posting Date", VendorLedgerEntry."VAT Date CZL",
            VendorLedgerEntry."VAT Date CZL", -PurchAdvLetterEntryCZZ.Amount, PurchAdvLetterEntryCZZ."Entry No.",
            VendorLedgerEntry."Document No.", "Advance Letter Entry Type CZZ"::"VAT Usage", false, GenJnlPostLine, false);
    end;

    local procedure PostExchangeRate(ExchRateAmount: Decimal; ExchRateVATAmount: Decimal; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var VATPostingSetup: Record "VAT Posting Setup";
        DocumentNo: Code[20]; PostingDate: Date; VATDate: Date; SourceCode: Code[10]; PostDescription: Text[100]; UsageEntryNo: Integer; Correction: Boolean;
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if (ExchRateAmount = 0) and (ExchRateVATAmount = 0) then
            exit;

        if ExchRateVATAmount <> 0 then begin
            GetCurrency(PurchAdvLetterHeaderCZZ."Currency Code");

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, '', SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.Validate(Amount, ExchRateAmount - ExchRateVATAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, '', SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Correction := true;
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            if ExchRateVATAmount < 0 then begin
                CurrencyGlob.TestField("Realized Losses Acc.");
                GenJournalLine."Account No." := CurrencyGlob."Realized Losses Acc.";
            end else begin
                CurrencyGlob.TestField("Realized Gains Acc.");
                GenJournalLine."Account No." := CurrencyGlob."Realized Gains Acc.";
            end;
            GenJournalLine.Validate(Amount, ExchRateVATAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, '', SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.Validate(Amount, -ExchRateAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);
        end;

        AdvEntryInit(Preview);
        if Correction then
            AdvEntryInitCancel();
        AdvEntryInitRelatedEntry(UsageEntryNo);
        AdvEntryInitVAT(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", VATDate, VATDate,
            0, VATPostingSetup."VAT %", VATPostingSetup."VAT Identifier", VATPostingSetup."VAT Calculation Type",
            0, ExchRateVATAmount, 0, ExchRateAmount - ExchRateVATAmount);
        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Rate", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", PostingDate,
            0, ExchRateAmount, '', 0, DocumentNo, GenJournalLine."External Document No.",
            PurchAdvLetterEntryCZZ."Global Dimension 1 Code", PurchAdvLetterEntryCZZ."Global Dimension 2 Code", PurchAdvLetterEntryCZZ."Dimension Set ID", Preview);
    end;

    local procedure BufferAdvanceVATLines(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; BalanceAtDate: Date)
    begin
        BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, AdvancePostingBufferCZZ, BalanceAtDate, true);
    end;

    local procedure BufferAdvanceVATLines(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; BalanceAtDate: Date; ResetBuffer: Boolean)
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
    begin
        if ResetBuffer then begin
            AdvancePostingBufferCZZ.Reset();
            AdvancePostingBufferCZZ.DeleteAll();
        end;

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment");
        if BalanceAtDate <> 0D then
            PurchAdvLetterEntryCZZ2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        if PurchAdvLetterEntryCZZ2.FindSet() then
            repeat
                if PurchAdvLetterEntryCZZ2."Entry Type" in
                  [PurchAdvLetterEntryCZZ2."Entry Type"::Payment,
                   PurchAdvLetterEntryCZZ2."Entry Type"::Usage,
                   PurchAdvLetterEntryCZZ2."Entry Type"::Close]
                then
                    BufferAdvanceVATLines(PurchAdvLetterEntryCZZ2, AdvancePostingBufferCZZ, BalanceAtDate, false)
                else begin
                    TempAdvancePostingBufferCZZ.PrepareForPurchAdvLetterEntry(PurchAdvLetterentryCZZ2);
                    AdvancePostingBufferCZZ.Update(TempAdvancePostingBufferCZZ);
                end;
            until PurchAdvLetterEntryCZZ2.Next() = 0;
    end;

    local procedure InitGenJnlLineFromVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; GenJournalDocumentType: Enum "Gen. Journal Document Type")
    begin
        GenJournalLine.InitNewLine(
            VendorLedgerEntry."Posting Date", VendorLedgerEntry."Document Date", VendorLedgerEntry."VAT Date CZL", VendorLedgerEntry.Description,
            VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code",
            VendorLedgerEntry."Dimension Set ID", VendorLedgerEntry."Reason Code");
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine.CopyDocumentFields(GenJournalDocumentType, VendorLedgerEntry."Document No.", VendorLedgerEntry."External Document No.", VendorLedgerEntry."Source Code", '');
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
        GenJournalLine."Account No." := VendorLedgerEntry."Vendor No.";
        GenJournalLine."Source Currency Code" := VendorLedgerEntry."Currency Code";
        GenJournalLine."Currency Factor" := VendorLedgerEntry."Original Currency Factor";
        GenJournalLine."Sell-to/Buy-from No." := VendorLedgerEntry."Buy-from Vendor No.";
        GenJournalLine."Bill-to/Pay-to No." := VendorLedgerEntry."Vendor No.";
        GenJournalLine."IC Partner Code" := VendorLedgerEntry."IC Partner Code";
        GenJournalLine."Salespers./Purch. Code" := VendorLedgerEntry."Purchaser Code";
        GenJournalLine."On Hold" := VendorLedgerEntry."On Hold";
        GenJournalLine."Posting Group" := VendorLedgerEntry."Vendor Posting Group";
#if not CLEAN22
#pragma warning disable AL0432
        if not ReplaceVATDateMgtCZL.IsEnabled() then
            GenJournalLine.Validate("VAT Date CZL", VendorLedgerEntry."VAT Date CZL")
        else
#pragma warning restore AL0432
#endif
        GenJournalLine.Validate("VAT Reporting Date", VendorLedgerEntry."VAT Date CZL");
        GenJournalLine.Validate("Original Doc. VAT Date CZL", VendorLedgerEntry."VAT Date CZL");
        GenJournalLine."System-Created Entry" := true;
        OnAfterInitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine);
    end;

    local procedure InitGenJnlLineFromAdvance(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; DocumentNo: Code[20]; ExternalDocumentNo: Code[35]; SourceCode: Code[10]; PostDescription: Text[100]; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Init();
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."External Document No." := ExternalDocumentNo;
        GenJournalLine.Description := PostDescription;
        GenJournalLine."Bill-to/Pay-to No." := PurchAdvLetterHeaderCZZ."Pay-to Vendor No.";
        GenJournalLine."Country/Region Code" := PurchAdvLetterHeaderCZZ."Pay-to Country/Region Code";
        GenJournalLine."Source Code" := SourceCode;
        GenJournalLine."VAT Registration No." := PurchAdvLetterHeaderCZZ."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := PurchAdvLetterHeaderCZZ."Registration No.";
        GenJournalLine."Tax Registration No. CZL" := PurchAdvLetterHeaderCZZ."Tax Registration No.";
        GenJournalLine."Shortcut Dimension 1 Code" := PurchAdvLetterEntryCZZ."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := PurchAdvLetterEntryCZZ."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := PurchAdvLetterEntryCZZ."Dimension Set ID";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
        OnAfterInitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, GenJournalLine);
    end;

    procedure GetRemAmtPurchAdvPayment(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; BalanceAtDate: Date): Decimal
    var
        PurchAdvLetterEntry2: Record "Purch. Adv. Letter Entry CZZ";
    begin
        if (PurchAdvLetterEntryCZZ."Posting Date" > BalanceAtDate) and (BalanceAtDate <> 0D) then
            exit(0);

        PurchAdvLetterEntry2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntry2.SetRange(Cancelled, false);
        PurchAdvLetterEntry2.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntry2."Entry Type"::Payment,
            PurchAdvLetterEntry2."Entry Type"::Usage, PurchAdvLetterEntry2."Entry Type"::Close);
        PurchAdvLetterEntry2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            PurchAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        PurchAdvLetterEntry2.CalcSums(Amount);
        exit(PurchAdvLetterEntryCZZ.Amount + PurchAdvLetterEntry2.Amount);
    end;

    procedure GetRemAmtLCYPurchAdvPayment(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; BalanceAtDate: Date): Decimal
    var
        PurchAdvLetterEntry2: Record "Purch. Adv. Letter Entry CZZ";
    begin
        if (PurchAdvLetterEntryCZZ."Posting Date" > BalanceAtDate) and (BalanceAtDate <> 0D) then
            exit(0);

        PurchAdvLetterEntry2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntry2.SetRange(Cancelled, false);
        PurchAdvLetterEntry2.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntry2."Entry Type"::Payment,
            PurchAdvLetterEntry2."Entry Type"::Usage, PurchAdvLetterEntry2."Entry Type"::Close);
        PurchAdvLetterEntry2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            PurchAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        PurchAdvLetterEntry2.CalcSums("Amount (LCY)");
        exit(PurchAdvLetterEntryCZZ."Amount (LCY)" + PurchAdvLetterEntry2."Amount (LCY)");
    end;

    procedure GetRemAmtLCYVATAdjust(var AmountLCY: Decimal; var VATAmountLCY: Decimal; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; BalanceAtDate: Date; VATBusPostGr: Code[20]; VATProdPostGr: Code[20])
    var
        PurchAdvLetterEntry2: Record "Purch. Adv. Letter Entry CZZ";
        AmountLCY2, VATAmountLCY2 : Decimal;
    begin
        PurchAdvLetterEntry2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntry2.SetRange(Cancelled, false);
        PurchAdvLetterEntry2.SetRange("Entry Type", PurchAdvLetterEntry2."Entry Type"::"VAT Adjustment");
        PurchAdvLetterEntry2.SetRange("VAT Bus. Posting Group", VATBusPostGr);
        PurchAdvLetterEntry2.SetRange("VAT Prod. Posting Group", VATProdPostGr);
        PurchAdvLetterEntry2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            PurchAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        PurchAdvLetterEntry2.CalcSums("Amount (LCY)", "VAT Amount (LCY)");
        AmountLCY := PurchAdvLetterEntry2."Amount (LCY)";
        VATAmountLCY := PurchAdvLetterEntry2."VAT Amount (LCY)";

        PurchAdvLetterEntry2.SetRange("VAT Bus. Posting Group");
        PurchAdvLetterEntry2.SetRange("VAT Prod. Posting Group");
        PurchAdvLetterEntry2.SetRange("Entry Type", PurchAdvLetterEntry2."Entry Type"::Usage);
        if PurchAdvLetterEntry2.FindSet() then
            repeat
                GetRemAmtLCYVATAdjust(AmountLCY2, VATAmountLCY2, PurchAdvLetterEntry2, BalanceAtDate, VATBusPostGr, VATProdPostGr);
                AmountLCY += AmountLCY2;
                VATAmountLCY += VATAmountLCY2;
            until PurchAdvLetterEntry2.Next() = 0
    end;

    procedure CloseAdvanceLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        AdvPaymentCloseDialogCZZ: Page "Adv. Payment Close Dialog CZZ";
        OriginalDocumentVATDate: Date;
        PostingDate: Date;
        VATDate: Date;
        CurrencyFactor: Decimal;
    begin
        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::Closed then
            exit;

        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::New then begin
            UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::Closed);
            exit;
        end;

        AdvPaymentCloseDialogCZZ.SetValues(WorkDate(), WorkDate(), PurchAdvLetterHeaderCZZ."Currency Code", 0, '', true);
        if AdvPaymentCloseDialogCZZ.RunModal() <> Action::OK then
            exit;

        AdvPaymentCloseDialogCZZ.GetValues(PostingDate, VATDate, OriginalDocumentVATDate, CurrencyFactor);
        if (PostingDate = 0D) or (VATDate = 0D) then
            Error(DateEmptyErr);

        CloseAdvanceLetter(PurchAdvLetterHeaderCZZ, PostingDate, VATDate, OriginalDocumentVATDate, CurrencyFactor, AdvPaymentCloseDialogCZZ.GetExternalDocumentNo());
    end;

    procedure CloseAdvanceLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostingDate: Date; VATDate: Date; OriginalDocumentVATDate: Date; CurrencyFactor: Decimal; ExternalDocumentNo: Code[35])
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry1: Record "Vendor Ledger Entry";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ApplId: Code[50];
        VATDocumentNo: Code[20];
        RemAmount: Decimal;
        RemAmountLCY: Decimal;
        UsageEntryNo: Integer;
    begin
        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::Closed then
            exit;

        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::New then begin
            UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::Closed);
            exit;
        end;

        if PostingDate = 0D then
            PostingDate := WorkDate();
        if VATDate = 0D then
            VATDate := WorkDate();
        if OriginalDocumentVATDate = 0D then
            OriginalDocumentVATDate := WorkDate();
        if CurrencyFactor = 0 then
            CurrencyFactor := CurrencyExchangeRate.ExchangeRate(PostingDate, PurchAdvLetterHeaderCZZ."Currency Code");
        PurchasesPayablesSetup.Get();
        if PurchasesPayablesSetup."Ext. Doc. No. Mandatory" and (ExternalDocumentNo = '') then
            Error(ExternalDocumentNoEmptyErr);

        VATDocumentNo := '';

        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if PurchAdvLetterEntryCZZ.FindSet() then
            repeat
                RemAmount := GetRemAmtPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D);
                RemAmountLCY := GetRemAmtLCYPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D);

                if RemAmount <> 0 then begin
                    if VATDocumentNo = '' then begin
                        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
                        AdvanceLetterTemplateCZZ.TestField("Advance Letter Cr. Memo Nos.");
                        VATDocumentNo := NoSeriesManagement.GetNextNo(AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", PostingDate, true);
                    end;

                    PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                    VendorLedgerEntry1.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
                    if RemAmount <> 0 then begin
                        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry1, GenJournalLine, GenJournalLine."Document Type"::" ");
                        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
                        GenJournalLine.Correction := true;
                        GenJournalLine."External Document No." := ExternalDocumentNo;
                        GenJournalLine."Document No." := VATDocumentNo;
                        GenJournalLine."Posting Date" := PostingDate;
                        GenJournalLine."Document Date" := PostingDate;
#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine.Validate("VAT Date CZL", VATDate)
                        else
#pragma warning restore AL0432
#endif
                            GenJournalLine.Validate("VAT Reporting Date", VATDate);
                        GenJournalLine.Validate("Original Doc. VAT Date CZL", OriginalDocumentVATDate);
                        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
                        GenJournalLine."Use Advance G/L Account CZZ" := true;
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                        GenJournalLine.Validate(Amount, -RemAmount);

                        ApplId := CopyStr(VendorLedgerEntry1."Document No." + Format(VendorLedgerEntry1."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
                        VendorLedgerEntry1.Prepayment := false;
                        VendorLedgerEntry1."Advance Letter No. CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
                        VendorLedgerEntry1.Modify();
                        VendorLedgerEntry1.CalcFields("Remaining Amount");
                        VendorLedgerEntry1."Amount to Apply" := VendorLedgerEntry1."Remaining Amount";
                        VendorLedgerEntry1."Applies-to ID" := ApplId;
                        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry1);
                        GenJournalLine."Applies-to ID" := ApplId;

                        OnBeforePostClosePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        OnAfterPostClosePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);

                        VendorLedgerEntry2.FindLast();
                        AdvEntryInit(false);
                        AdvEntryInitVendLedgEntryNo(VendorLedgerEntry2."Entry No.");
                        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
                        AdvEntryInsert("Advance Letter Entry Type CZZ"::Close, GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
                            GenJournalLine.Amount, -RemAmountLCY,
                            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                        UsageEntryNo := PurchAdvLetterEntryCZZGlob."Entry No.";
                    end else begin
                        VendorLedgerEntry2.Init();
                        UsageEntryNo := 0;
                    end;

                    ReverseAdvancePaymentVAT(PurchAdvLetterEntryCZZ, VendorLedgerEntry1."Source Code",
                        PurchAdvLetterHeaderCZZ."Posting Description", CurrencyFactor, Enum::"Gen. Journal Document Type"::"Credit Memo",
                        VATDocumentNo, ExternalDocumentNo, PostingDate, VATDate, OriginalDocumentVATDate, 0, UsageEntryNo, '',
                        "Advance Letter Entry Type CZZ"::"VAT Close", true, GenJnlPostLine, false);

                    if RemAmount <> 0 then begin
                        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry1, GenJournalLine, GenJournalLine."Document Type"::Payment);
                        GenJournalLine.Correction := true;
                        GenJournalLine."External Document No." := ExternalDocumentNo;
                        GenJournalLine."Document No." := VATDocumentNo;
                        GenJournalLine."Posting Date" := PostingDate;
                        GenJournalLine."Document Date" := PostingDate;
#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine.Validate("VAT Date CZL", VATDate)
                        else
#pragma warning restore AL0432
#endif
                            GenJournalLine.Validate("VAT Reporting Date", VATDate);
                        GenJournalLine.Validate("Original Doc. VAT Date CZL", OriginalDocumentVATDate);
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                        GenJournalLine.Validate(Amount, RemAmount);
                        GenJournalLine."Variable Symbol CZL" := PurchAdvLetterHeaderCZZ."Variable Symbol";
                        OnBeforePostClosePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        OnAfterPostClosePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
                    end;
                end;
            until PurchAdvLetterEntryCZZ.Next() = 0;

        CancelInitEntry(PurchAdvLetterHeaderCZZ, PostingDate, false);
        PurchAdvLetterHeaderCZZ.Find();
        UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::Closed);

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase);
        AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", PurchAdvLetterHeaderCZZ."No.");
        AdvanceLetterApplicationCZZ.DeleteAll(true);
    end;

    procedure PostAdvanceCreditMemoVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ3: Record "Purch. Adv. Letter Entry CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        VATEntry: Record "VAT Entry";
        DocumentTypeHandlerCZZ: Codeunit "Document Type Handler CZZ";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATDocumentCZZ: Page "VAT Document CZZ";
        DocumentNo: Code[20];
        ExternalDocumentNo: Code[35];
        VATDate: Date;
        OriginalDocumentVATDate: Date;
        DocumentDate: Date;
        PostingDate: Date;
        ExchRateAmount: Decimal;
        ExchRateVATAmount: Decimal;
    begin
        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        VATEntry.Get(PurchAdvLetterEntryCZZ."VAT Entry No.");

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ2.SetRange("Document No.", PurchAdvLetterEntryCZZ."Document No.");
        PurchAdvLetterEntryCZZ2.FindSet();
        repeat
            TempAdvancePostingBufferCZZ.PrepareForPurchAdvLetterEntry(PurchAdvLetterEntryCZZ2);
            TempAdvancePostingBufferCZZ1.Update(TempAdvancePostingBufferCZZ);
        until PurchAdvLetterEntryCZZ2.Next() = 0;

        VATDocumentCZZ.InitDocument(AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", '', PurchAdvLetterEntryCZZ."Posting Date",
          PurchAdvLetterEntryCZZ."Posting Date", PurchAdvLetterEntryCZZ."VAT Date", PurchAdvLetterEntryCZZ."Original Document VAT Date",
          PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor", PurchAdvLetterEntryCZZ."External Document No.", TempAdvancePostingBufferCZZ1);
        if VATDocumentCZZ.RunModal() <> Action::OK then
            exit;

        VATDocumentCZZ.SaveNoSeries();
        VATDocumentCZZ.GetDocument(DocumentNo, PostingDate, DocumentDate, VATDate, OriginalDocumentVATDate, ExternalDocumentNo, TempAdvancePostingBufferCZZ1);
        if (DocumentNo = '') or (PostingDate = 0D) or (VATDate = 0D) or (OriginalDocumentVATDate = 0D) then
            Error(DocumentNoOrDatesEmptyErr);

        OnPostAdvanceCreditMemoVATOnAfterGetDocument(PurchAdvLetterEntryCZZ, PostingDate, VATDate, OriginalDocumentVATDate);

        TempAdvancePostingBufferCZZ1.SetFilter(Amount, '<>0');
        if not TempAdvancePostingBufferCZZ1.FindSet() then
            Error(NothingToPostErr);

        GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");

        if PurchAdvLetterEntryCZZ."Currency Code" <> '' then begin
            PurchAdvLetterEntryCZZ3.Get(PurchAdvLetterEntryCZZ."Related Entry");
            BufferAdvanceVATLines(PurchAdvLetterEntryCZZ3, TempAdvancePostingBufferCZZ2, 0D);
        end;

        PurchAdvLetterEntryCZZ2.FindSet(true);
        repeat
            TempAdvancePostingBufferCZZ1.Reset();
            TempAdvancePostingBufferCZZ1.SetRange("VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group");
            TempAdvancePostingBufferCZZ1.SetRange("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
            TempAdvancePostingBufferCZZ1.FindFirst();
            PurchAdvLetterEntryCZZ2.TestField(Amount, TempAdvancePostingBufferCZZ1.Amount);

            VATPostingSetup.Get(TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Purch. Adv. Letter Account CZZ");
            VATPostingSetup.TestField("Purch. Adv.Letter VAT Acc. CZZ");

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, VATEntry."Source Code", PurchAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
            GenJournalLine."Document Type" := GenJournalLine."Document Type"::"Credit Memo";
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            GenJournalLine.Validate("Original Doc. VAT Date CZL", OriginalDocumentVATDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
            GenJournalLine."VAT Calculation Type" := TempAdvancePostingBufferCZZ1."VAT Calculation Type";
            GenJournalLine."VAT Bus. Posting Group" := TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group";
            GenJournalLine.validate("VAT Prod. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
            GenJournalLine.Validate(Amount, -TempAdvancePostingBufferCZZ1.Amount);
            GenJournalLine."VAT Amount" := -TempAdvancePostingBufferCZZ1."VAT Amount";
            GenJournalLine."VAT Base Amount" := GenJournalLine.Amount - GenJournalLine."VAT Amount";
            GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
            if GenJournalLine."Currency Code" <> '' then begin
                GenJournalLine."Amount (LCY)" := -TempAdvancePostingBufferCZZ1."Amount (ACY)";
                GenJournalLine."VAT Amount (LCY)" := -TempAdvancePostingBufferCZZ1."VAT Amount (ACY)";
                GenJournalLine."VAT Base Amount (LCY)" := -TempAdvancePostingBufferCZZ1."VAT Base Amount (ACY)";
                GenJournalLine."Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
            end else begin
                GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
                GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
            end;
            BindSubscription(VATPostingSetupHandlerCZZ);
            BindSubscription(DocumentTypeHandlerCZZ);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            UnbindSubscription(VATPostingSetupHandlerCZZ);
            UnbindSubscription(DocumentTypeHandlerCZZ);

#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
            AdvEntryInit(false);
            AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Related Entry");
            AdvEntryInitCancel();
            AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group",
                GenJournalLine."VAT Reporting Date", GenJournalLine."Original Doc. VAT Date CZL",
                GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
            AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Payment", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", GenJournalLine."Posting Date",
                GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

            if GenJournalLine."Currency Code" <> '' then begin
                ExchRateAmount := PurchAdvLetterEntryCZZ2."Amount (LCY)" + GenJournalLine."Amount (LCY)";
                ExchRateVATAmount := PurchAdvLetterEntryCZZ2."VAT Amount (LCY)" + GenJournalLine."VAT Amount (LCY)";
                if (ExchRateAmount <> 0) or (ExchRateVATAmount <> 0) then
                    PostExchangeRate(ExchRateAmount, ExchRateVATAmount, PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                        DocumentNo, PostingDate, VATDate, '', PurchAdvLetterHeaderCZZ."Posting Description", PurchAdvLetterEntryCZZ2."Related Entry", true, GenJnlPostLine, false);

                TempAdvancePostingBufferCZZ2.Reset();
                TempAdvancePostingBufferCZZ2.SetRange("VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group");
                TempAdvancePostingBufferCZZ2.SetRange("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                TempAdvancePostingBufferCZZ2.FindFirst();

                ReverseUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, TempAdvancePostingBufferCZZ1.Amount / TempAdvancePostingBufferCZZ2.Amount,
                    PurchAdvLetterEntryCZZ."Related Entry", DocumentNo, PostingDate, VATDate, PurchAdvLetterHeaderCZZ."Posting Description", GenJnlPostLine, false);
            end;

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, VATEntry."Source Code", PurchAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            GenJournalLine.Validate("Original Doc. VAT Date CZL", OriginalDocumentVATDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
            GenJournalLine.Validate(Amount, TempAdvancePostingBufferCZZ1.Amount);
            GenJournalLine."Amount (LCY)" := TempAdvancePostingBufferCZZ1."Amount (ACY)";
            GenJournalLine."Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
            GenJnlPostLine.RunWithCheck(GenJournalLine);
        until PurchAdvLetterEntryCZZ2.Next() = 0;

        PurchAdvLetterEntryCZZ2.ModifyAll(Cancelled, true);
    end;

    procedure PostCancelUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        DocumentNo: Code[20];
    begin
        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter Cr. Memo Nos.");
        DocumentNo := NoSeriesManagement.GetNextNo(AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", 0D, true);

        GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");

        PurchAdvLetterEntryCZZ2.Reset();
        PurchAdvLetterEntryCZZ2.SetRange("Document No.", PurchAdvLetterEntryCZZ."Document No.");
        PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment",
            PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Rate", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.Find('+');
        PurchAdvLetterEntryCZZ2.SetFilter("Entry No.", '..%1', PurchAdvLetterEntryCZZ2."Entry No.");
        repeat
            case PurchAdvLetterEntryCZZ2."Entry Type" of
                PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                        PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup, -PurchAdvLetterEntryCZZ2."Amount (LCY)", -PurchAdvLetterEntryCZZ2."VAT Amount (LCY)",
                            PurchAdvLetterEntryCZZ2."Related Entry", 0, DocumentNo, PurchAdvLetterEntryCZZ2."Posting Date", PurchAdvLetterEntryCZZ2."VAT Date", '', GenJnlPostLine, true, false);
                    end;
                PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Rate":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                        PostExchangeRate(-PurchAdvLetterEntryCZZ2."Amount (LCY)", -PurchAdvLetterEntryCZZ2."VAT Amount (LCY)", PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, VATPostingSetup,
                            PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ2."Posting Date", PurchAdvLetterEntryCZZ2."VAT Date", '',
                            '', PurchAdvLetterEntryCZZ2."Related Entry", true, GenJnlPostLine, false);
                    end;
                PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                        InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ2."External Document No.",
                            '', '', GenJournalLine);
                        GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ2."Posting Date");
#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine.Validate("VAT Date CZL", PurchAdvLetterEntryCZZ2."VAT Date")
                        else
#pragma warning restore AL0432
#endif
                        GenJournalLine.Validate("VAT Reporting Date", PurchAdvLetterEntryCZZ2."VAT Date");
                        GenJournalLine.Validate("Original Doc. VAT Date CZL", PurchAdvLetterEntryCZZ2."Original Document VAT Date");
                        GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ2."Currency Code", PurchAdvLetterEntryCZZ2."Currency Factor");
                        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
                        GenJournalLine."VAT Calculation Type" := PurchAdvLetterEntryCZZ2."VAT Calculation Type";
                        GenJournalLine."VAT Bus. Posting Group" := PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group";
                        GenJournalLine.Validate("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Validate(Amount, -PurchAdvLetterEntryCZZ2.Amount);
                        GenJournalLine."VAT Amount" := -PurchAdvLetterEntryCZZ2."VAT Amount";
                        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount - GenJournalLine."VAT Amount";
                        GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                             CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                        if GenJournalLine."Currency Code" = '' then begin
                            GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                            GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
                            GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
                        end else begin
                            GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ2."Amount (LCY)";
                            GenJournalLine."VAT Amount (LCY)" := -PurchAdvLetterEntryCZZ2."VAT Amount (LCY)";
                            GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."Amount (LCY)" - GenJournalLine."VAT Amount (LCY)";
                        end;
                        BindSubscription(VATPostingSetupHandlerCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        UnbindSubscription(VATPostingSetupHandlerCZZ);

#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
                        AdvEntryInit(false);
                        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ2."Related Entry");
                        AdvEntryInitCancel();
                        AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group",
                            GenJournalLine."VAT Reporting Date", GenJournalLine."Original Doc. VAT Date CZL",
                            GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                            GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Usage", PurchAdvLetterEntryCZZ2."Purch. Adv. Letter No.", GenJournalLine."Posting Date",
                            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                        InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ2."External Document No.", '', '', GenJournalLine);
                        GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ2."Posting Date");
#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine.Validate("VAT Date CZL", PurchAdvLetterEntryCZZ2."VAT Date")
                        else
#pragma warning restore AL0432
#endif
                        GenJournalLine.Validate("VAT Reporting Date", PurchAdvLetterEntryCZZ2."VAT Date");
                        GenJournalLine.Validate("Original Doc. VAT Date CZL", PurchAdvLetterEntryCZZ2."Original Document VAT Date");
                        GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ2."Currency Code", PurchAdvLetterEntryCZZ2."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Validate(Amount, PurchAdvLetterEntryCZZ2.Amount);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                    end;
            end;
        until PurchAdvLetterEntryCZZ2.Next(-1) = 0;

        PurchAdvLetterEntryCZZ2.ModifyAll(Cancelled, true);
        UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::"To Use");
    end;

    procedure PostAdvancePaymentUsagePreview(var PurchaseHeader: Record "Purchase Header"; Amount: Decimal; AmountLCY: Decimal; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ";
    begin
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.DeleteAll();

        if not TempPurchAdvLetterEntryCZZGlob.IsEmpty() then
            TempPurchAdvLetterEntryCZZGlob.DeleteAll();

        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Order:
                AdvLetterUsageDocTypeCZZ := AdvLetterUsageDocTypeCZZ::"Purchase Order";
            PurchaseHeader."Document Type"::Invoice:
                AdvLetterUsageDocTypeCZZ := AdvLetterUsageDocTypeCZZ::"Purchase Invoice";
            else
                exit;
        end;

        PurchInvHeader.TransferFields(PurchaseHeader);
        VendorLedgerEntry.Init();
        VendorLedgerEntry."Vendor No." := PurchaseHeader."Pay-to Vendor No.";
        VendorLedgerEntry."Posting Date" := PurchaseHeader."Posting Date";
        VendorLedgerEntry."Document Date" := PurchaseHeader."Document Date";
        VendorLedgerEntry."Document Type" := PurchaseHeader."Document Type";
        VendorLedgerEntry."Document No." := PurchaseHeader."No.";
        VendorLedgerEntry."External Document No." := PurchaseHeader."Vendor Order No.";
        VendorLedgerEntry.Description := PurchaseHeader."Posting Description";
        VendorLedgerEntry."Currency Code" := PurchaseHeader."Currency Code";
        VendorLedgerEntry."Buy-from Vendor No." := PurchaseHeader."Buy-from Vendor No.";
        VendorLedgerEntry."Vendor Posting Group" := PurchaseHeader."Vendor Posting Group";
        VendorLedgerEntry."Global Dimension 1 Code" := PurchaseHeader."Shortcut Dimension 1 Code";
        VendorLedgerEntry."Global Dimension 2 Code" := PurchaseHeader."Shortcut Dimension 2 Code";
        VendorLedgerEntry."Dimension Set ID" := PurchaseHeader."Dimension Set ID";
        VendorLedgerEntry."Purchaser Code" := PurchaseHeader."Purchaser Code";
        VendorLedgerEntry."Due Date" := PurchaseHeader."Due Date";
        VendorLedgerEntry."Payment Method Code" := PurchaseHeader."Payment Method Code";
#if not CLEAN22
#pragma warning disable AL0432
        if not ReplaceVATDateMgtCZL.IsEnabled() then
            PurchaseHeader."VAT Reporting Date" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        VendorLedgerEntry."VAT Date CZL" := PurchaseHeader."VAT Reporting Date";
        VendorLedgerEntry."Original Currency Factor" := PurchaseHeader."Currency Factor";
        VendorLedgerEntry.Amount := -Amount;
        VendorLedgerEntry."Amount (LCY)" := -AmountLCY;
        VendorLedgerEntry."Remaining Amount" := -Amount;
        VendorLedgerEntry."Remaining Amt. (LCY)" := -AmountLCY;

        PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ, PurchaseHeader."No.", PurchInvHeader, VendorLedgerEntry, GenJnlPostLine, true);

        if TempPurchAdvLetterEntryCZZGlob.FindSet() then begin
            repeat
                PurchAdvLetterEntryCZZ := TempPurchAdvLetterEntryCZZGlob;
                PurchAdvLetterEntryCZZ.Insert();
            until TempPurchAdvLetterEntryCZZGlob.Next() = 0;

            TempPurchAdvLetterEntryCZZGlob.DeleteAll();
        end;
    end;

    procedure UnapplyAdvanceLetter(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        TempPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryInv: Record "Vendor Ledger Entry";
        DocumentTypeHandlerCZZ: Codeunit "Document Type Handler CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        GenJnlCheckLnHandlerCZZ: Codeunit "Gen.Jnl.-Check Ln. Handler CZZ";
        ConfirmManagement: Codeunit "Confirm Management";
        ApplId: Code[50];
        AdvLetters: Text;
        UnapplyIsNotPossibleErr: Label 'Unapply is not possible.';
        UnapplyAdvLetterQst: Label 'Unapply advance letter: %1\Continue?', Comment = '%1 = Advance Letters';
    begin
        PurchAdvLetterEntryCZZ.SetRange(PurchAdvLetterEntryCZZ."Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if not PurchAdvLetterEntryCZZ.FindSet() then
            exit;

        repeat
            if not TempPurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.") then begin
                TempPurchAdvLetterHeaderCZZ."No." := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
                TempPurchAdvLetterHeaderCZZ.Insert();
            end;
        until PurchAdvLetterEntryCZZ.Next() = 0;

        if TempPurchAdvLetterHeaderCZZ.FindSet() then
            repeat
                if AdvLetters <> '' then
                    AdvLetters := AdvLetters + ', ';
                AdvLetters := AdvLetters + TempPurchAdvLetterHeaderCZZ."No.";
            until TempPurchAdvLetterHeaderCZZ.Next() = 0;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(UnapplyAdvLetterQst, AdvLetters), false) then
            exit;

        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ.Find('+');
        PurchAdvLetterEntryCZZ.SetFilter("Entry No.", '..%1', PurchAdvLetterEntryCZZ."Entry No.");
        repeat
            PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
            case PurchAdvLetterEntryCZZ."Entry Type" of
                PurchAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, -PurchAdvLetterEntryCZZ."Amount (LCY)", -PurchAdvLetterEntryCZZ."VAT Amount (LCY)",
                            PurchAdvLetterEntryCZZ."Related Entry", 0, PurchAdvLetterEntryCZZ."Document No.", PurchAdvLetterEntryCZZ."Posting Date", PurchAdvLetterEntryCZZ."VAT Date", PurchInvHeader."Posting Description", GenJnlPostLine, true, false);
                    end;
                PurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        PostExchangeRate(-PurchAdvLetterEntryCZZ."Amount (LCY)", -PurchAdvLetterEntryCZZ."VAT Amount (LCY)", PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                            PurchAdvLetterEntryCZZ."Document No.", PurchAdvLetterEntryCZZ."Posting Date", PurchAdvLetterEntryCZZ."VAT Date", PurchInvHeader."Source Code",
                            PurchInvHeader."Posting Description", PurchAdvLetterEntryCZZ."Related Entry", true, GenJnlPostLine, false);
                    end;
                PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, PurchAdvLetterEntryCZZ."Document No.", PurchAdvLetterEntryCZZ."External Document No.",
                            PurchInvHeader."Source Code", PurchInvHeader."Posting Description", GenJournalLine);
                        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
                        GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ."Posting Date");
#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine.Validate("VAT Date CZL", PurchInvHeader."VAT Date CZL")
                        else
#pragma warning restore AL0432
#endif
                        GenJournalLine.Validate("VAT Reporting Date", PurchInvHeader."VAT Reporting Date");
                        GenJournalLine."Original Doc. VAT Date CZL" := PurchInvHeader."Original Doc. VAT Date CZL";
                        GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
                        GenJournalLine."VAT Calculation Type" := PurchAdvLetterEntryCZZ."VAT Calculation Type";
                        if GenJournalLine."VAT Calculation Type" = GenJournalLine."VAT Calculation Type"::"Reverse Charge VAT" then
                            GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
                        GenJournalLine."VAT Bus. Posting Group" := PurchAdvLetterEntryCZZ."VAT Bus. Posting Group";
                        GenJournalLine.validate("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Validate(Amount, -PurchAdvLetterEntryCZZ.Amount);
                        GenJournalLine."VAT Amount" := -PurchAdvLetterEntryCZZ."VAT Amount";
                        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount - GenJournalLine."VAT Amount";
                        GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                             CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                        if GenJournalLine."Currency Code" = '' then begin
                            GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                            GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
                            GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
                        end else begin
                            if GenJournalLine."VAT Calculation Type" = GenJournalLine."VAT Calculation Type"::"Reverse Charge VAT" then begin
                                VATEntry.Get(PurchAdvLetterEntryCZZ."VAT Entry No.");
                                GenJournalLine."VAT Amount (LCY)" := -VATEntry.Amount;
                            end else
                                GenJournalLine."VAT Amount (LCY)" := -PurchAdvLetterEntryCZZ."VAT Amount (LCY)";
                            GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ."Amount (LCY)";
                            GenJournalLine."VAT Base Amount (LCY)" := -PurchAdvLetterEntryCZZ."VAT Base Amount (LCY)";
                        end;
                        BindSubscription(VATPostingSetupHandlerCZZ);
                        BindSubscription(DocumentTypeHandlerCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        UnbindSubscription(VATPostingSetupHandlerCZZ);
                        UnbindSubscription(DocumentTypeHandlerCZZ);

#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
                        AdvEntryInit(false);
                        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Related Entry");
                        AdvEntryInitCancel();
                        AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group",
                            GenJournalLine."VAT Reporting Date", GenJournalLine."Original Doc. VAT Date CZL",
                            GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                            GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Usage", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", GenJournalLine."Posting Date",
                            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                        InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, PurchAdvLetterEntryCZZ."Document No.", PurchAdvLetterEntryCZZ."External Document No.", PurchInvHeader."Source Code", PurchInvHeader."Posting Description", GenJournalLine);
                        GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ."Posting Date");
#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine.Validate("VAT Date CZL", PurchInvHeader."VAT Date CZL")
                        else
#pragma warning restore AL0432
#endif
                        GenJournalLine.Validate("VAT Reporting Date", PurchInvHeader."VAT Reporting Date");
                        GenJournalLine."Original Doc. VAT Date CZL" := PurchInvHeader."Original Doc. VAT Date CZL";
                        GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                        GenJournalLine.SetCurrencyFactor(PurchInvHeader."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Validate(Amount, PurchAdvLetterEntryCZZ.Amount);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                    end;
                PurchAdvLetterEntryCZZ."Entry Type"::Usage:
                    begin
                        VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
                        VendorLedgerEntryInv := VendorLedgerEntry;
#pragma warning disable AA0181
                        VendorLedgerEntryInv.Next(-1);
#pragma warning restore AA0181
                        UnapplyVendLedgEntry(VendorLedgerEntry, GenJnlPostLine);

                        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, VendorLedgerEntry."Document Type"::" ");
                        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
                        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
                        GenJournalLine."Use Advance G/L Account CZZ" := true;
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Amount := -PurchAdvLetterEntryCZZ.Amount;
                        GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ."Amount (LCY)";

                        ApplId := CopyStr(VendorLedgerEntry."Document No." + Format(VendorLedgerEntry."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
                        VendorLedgerEntry.CalcFields("Remaining Amount");
                        VendorLedgerEntry."Amount to Apply" := VendorLedgerEntry."Remaining Amount";
                        VendorLedgerEntry."Applies-to ID" := ApplId;
                        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry);
                        GenJournalLine."Applies-to ID" := ApplId;

                        BindSubscription(GenJnlCheckLnHandlerCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);

                        VendorLedgerEntry.FindLast();
                        AdvEntryInit(false);
                        AdvEntryInitCancel();
                        AdvEntryInitVendLedgEntryNo(VendorLedgerEntry."Entry No.");
                        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
                        AdvEntryInsert("Advance Letter Entry Type CZZ"::Usage, GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
                            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
                        GenJournalLine."Adv. Letter Template Code CZZ" := PurchAdvLetterHeaderCZZ."Advance Letter Code";
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Amount := PurchAdvLetterEntryCZZ.Amount;
                        GenJournalLine."Amount (LCY)" := PurchAdvLetterEntryCZZ."Amount (LCY)";

                        ApplId := CopyStr(VendorLedgerEntryInv."Document No." + Format(VendorLedgerEntryInv."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
                        VendorLedgerEntryInv.Prepayment := false;
                        VendorLedgerEntryInv."Advance Letter No. CZZ" := '';
                        VendorLedgerEntryInv.CalcFields("Remaining Amount");
                        VendorLedgerEntryInv."Amount to Apply" := VendorLedgerEntryInv."Remaining Amount";
                        VendorLedgerEntryInv."Applies-to ID" := ApplId;
                        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntryInv);
                        GenJournalLine."Applies-to ID" := ApplId;

                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        UnbindSubscription(GenJnlCheckLnHandlerCZZ);

                        UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::"To Use");
                    end;
                else
                    Error(UnapplyIsNotPossibleErr);
            end;
        until PurchAdvLetterEntryCZZ.Next(-1) = 0;

        PurchAdvLetterEntryCZZ.ModifyAll(Cancelled, true);
    end;

    local procedure UnapplyVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        DetailedVendorLedgEntry1: Record "Detailed Vendor Ledg. Entry";
        DetailedVendorLedgEntry2: Record "Detailed Vendor Ledg. Entry";
        DetailedVendorLedgEntry3: Record "Detailed Vendor Ledg. Entry";
        GenJournalLine: Record "Gen. Journal Line";
        Succes: Boolean;
        UnapplyLastInvoicesErr: Label 'First you must unapply invoces that were applied to advance last time.';
    begin
        DetailedVendorLedgEntry1.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
        DetailedVendorLedgEntry1.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        DetailedVendorLedgEntry1.SetRange("Entry Type", DetailedVendorLedgEntry1."Entry Type"::Application);
        DetailedVendorLedgEntry1.SetRange(Unapplied, false);
        Succes := false;
        repeat
            if DetailedVendorLedgEntry1.FindLast() then begin
                DetailedVendorLedgEntry2.Reset();
                DetailedVendorLedgEntry2.SetCurrentKey("Transaction No.", "Vendor No.", "Entry Type");
                DetailedVendorLedgEntry2.SetRange("Transaction No.", DetailedVendorLedgEntry1."Transaction No.");
                DetailedVendorLedgEntry2.SetRange("Vendor No.", DetailedVendorLedgEntry1."Vendor No.");
                if DetailedVendorLedgEntry2.FindSet() then
                    repeat
                        if (DetailedVendorLedgEntry2."Entry Type" <> DetailedVendorLedgEntry2."Entry Type"::"Initial Entry") and
                           not DetailedVendorLedgEntry2.Unapplied
                        then begin
                            DetailedVendorLedgEntry3.Reset();
                            DetailedVendorLedgEntry3.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
                            DetailedVendorLedgEntry3.SetRange("Vendor Ledger Entry No.", DetailedVendorLedgEntry2."Vendor Ledger Entry No.");
                            DetailedVendorLedgEntry3.SetRange(Unapplied, false);
                            if DetailedVendorLedgEntry3.FindLast() and
                               (DetailedVendorLedgEntry3."Transaction No." > DetailedVendorLedgEntry2."Transaction No.")
                            then
                                Error(UnapplyLastInvoicesErr);
                        end;
                    until DetailedVendorLedgEntry2.Next() = 0;

                GenJournalLine.Init();
                GenJournalLine."Document No." := DetailedVendorLedgEntry1."Document No.";
                GenJournalLine."Posting Date" := DetailedVendorLedgEntry1."Posting Date";
#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    GenJournalLine.Validate("VAT Date CZL", VendorLedgerEntry."VAT Date CZL")
                else
#pragma warning restore AL0432
#endif
                GenJournalLine.Validate("VAT Reporting Date", VendorLedgerEntry."VAT Date CZL");
                GenJournalLine.Validate("Original Doc. VAT Date CZL", VendorLedgerEntry."VAT Date CZL");
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                GenJournalLine."Account No." := DetailedVendorLedgEntry1."Vendor No.";
                GenJournalLine.Correction := true;
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
                GenJournalLine.Description := VendorLedgerEntry.Description;
                GenJournalLine."Shortcut Dimension 1 Code" := VendorLedgerEntry."Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := VendorLedgerEntry."Global Dimension 2 Code";
                GenJournalLine."Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                GenJournalLine."Posting Group" := VendorLedgerEntry."Vendor Posting Group";
                GenJournalLine."Source Currency Code" := DetailedVendorLedgEntry1."Currency Code";
                GenJournalLine."System-Created Entry" := true;
                OnUnapplyVendLedgEntryOnBeforePostUnapplyVendLedgEntry(VendorLedgerEntry, DetailedVendorLedgEntry1, GenJournalLine);
                GenJnlPostLine.UnapplyVendLedgEntry(GenJournalLine, DetailedVendorLedgEntry1);
            end else
                Succes := true;
        until Succes;
    end;

    procedure ApplyAdvanceLetter(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ConfirmManagement: Codeunit "Confirm Management";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        ApplyAdvanceLetterQst: Label 'Apply Advance Letter?';
        CannotApplyErr: Label 'You cannot apply more than %1.', Comment = '%1 = Remaining amount to apply';
    begin
        AdvanceLetterApplication.SetRange("Document Type", AdvanceLetterApplication."Document Type"::"Posted Purchase Invoice");
        AdvanceLetterApplication.SetRange("Document No.", PurchInvHeader."No.");
        if AdvanceLetterApplication.IsEmpty() then
            LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Posted Purchase Invoice", PurchInvHeader."No.", PurchInvHeader."Pay-to Vendor No.", PurchInvHeader."Posting Date", PurchInvHeader."Currency Code");

        if AdvanceLetterApplication.IsEmpty() then
            exit;

        if not ConfirmManagement.GetResponseOrDefault(ApplyAdvanceLetterQst, false) then
            exit;

        CheckAdvancePayment(AdvanceLetterApplication."Document Type"::"Posted Purchase Invoice", PurchInvHeader);
        AdvanceLetterApplication.CalcSums(Amount);
        VendorLedgerEntry.SetCurrentKey("Document No.");
        VendorLedgerEntry.SetRange("Document No.", PurchInvHeader."No.");
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.FindLast();
        VendorLedgerEntry.CalcFields("Remaining Amount");
        OnApplyAdvanceLetterOnBeforeTestAmount(AdvanceLetterApplication, VendorLedgerEntry);
        if AdvanceLetterApplication.Amount > -VendorLedgerEntry."Remaining Amount" then
            Error(CannotApplyErr, -VendorLedgerEntry."Remaining Amount");

        PostAdvancePaymentUsage(AdvanceLetterApplication."Document Type"::"Posted Purchase Invoice", PurchInvHeader."No.", PurchInvHeader,
            VendorLedgerEntry, GenJnlPostLine, false);
    end;
#if not CLEAN24
    [Obsolete('Replaced by CheckAdvancePayment with Variant parameter.', '24.0')]
    procedure CheckAdvancePayement(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20])
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        ConfirmManagement: Codeunit "Confirm Management";
        UsageQst: Label 'Usage all applicated advances is not possible.\Continue?';
    begin
        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
        if AdvanceLetterApplicationCZZ.FindSet() then
            repeat
                PurchAdvLetterHeaderCZZ.SetAutoCalcFields("To Use");
                PurchAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
                if PurchAdvLetterHeaderCZZ."To Use" < AdvanceLetterApplicationCZZ.Amount then
                    if not ConfirmManagement.GetResponseOrDefault(UsageQst, false) then
                        Error('');
            until AdvanceLetterApplicationCZZ.Next() = 0;
    end;
#endif

    procedure CheckAdvancePayment(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentHeader: Variant)
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        ConfirmManagement: Codeunit "Confirm Management";
        DocumentNo: Code[20];
        PostingDate: Date;
        IsHandled: Boolean;
        UsageQst: Label 'Usage all applicated advances is not possible.\Continue?';
    begin
        OnBeforeCheckAdvancePayment(AdvLetterUsageDocTypeCZZ, DocumentHeader, IsHandled);
        if IsHandled then
            exit;

        case AdvLetterUsageDocTypeCZZ of
            AdvLetterUsageDocTypeCZZ::"Posted Purchase Invoice":
                begin
                    PurchInvHeader := DocumentHeader;
                    DocumentNo := PurchInvHeader."No.";
                    PostingDate := PurchInvHeader."Posting Date";
                end;
            AdvLetterUsageDocTypeCZZ::"Purchase Invoice",
            AdvLetterUsageDocTypeCZZ::"Purchase Order":
                begin
                    PurchaseHeader := DocumentHeader;
                    DocumentNo := PurchaseHeader."No.";
                    PostingDate := PurchaseHeader."Posting Date";
                end;
        end;

        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
        if AdvanceLetterApplicationCZZ.FindSet() then
            repeat
                PurchAdvLetterHeaderCZZ.SetAutoCalcFields("To Use");
                PurchAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
                if PurchAdvLetterHeaderCZZ."To Use" < AdvanceLetterApplicationCZZ.Amount then
                    if not ConfirmManagement.GetResponseOrDefault(UsageQst, false) then
                        Error('');
                PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
                PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
                PurchAdvLetterEntryCZZ.SetFilter("Posting Date", '%1..', PostingDate + 1);
                if not PurchAdvLetterEntryCZZ.IsEmpty() then
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(LaterPostingDateQst, AdvanceLetterApplicationCZZ."Advance Letter No.", Format(PostingDate)), false) then
                        Error('');
            until AdvanceLetterApplicationCZZ.Next() = 0;
    end;

    procedure AdjustVATExchangeRate(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; Amount: Decimal; DetEntryNo: Integer; ToDate: Date; DocumentNo: Code[20]; PostDescription: Text[100])
    var
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ3: Record "Purch. Adv. Letter Entry CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AmountToDivide: Decimal;
        AmountToPost: Decimal;
        AmountTotal: Decimal;
        Coeff: Decimal;
        VATAmountToPost: Decimal;
        VATDocAmtToDate: Decimal;
    begin
        if Amount = 0 then
            exit;
        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        PurchAdvLetterEntryCZZ2.SetRange("Det. Vendor Ledger Entry No.", DetEntryNo);
        if not PurchAdvLetterEntryCZZ2.IsEmpty() then
            exit;

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, ToDate);
        TempAdvancePostingBufferCZZ1.CalcSums(Amount);
        VATDocAmtToDate := TempAdvancePostingBufferCZZ1.Amount;
        if VATDocAmtToDate <> 0 then begin
            Coeff := Amount / VATDocAmtToDate;
            TempAdvancePostingBufferCZZ1.FindSet();
            repeat
                TempAdvancePostingBufferCZZ2.Init();
                TempAdvancePostingBufferCZZ2 := TempAdvancePostingBufferCZZ1;
                TempAdvancePostingBufferCZZ2.RecalcAmountsByCoefficient(Coeff);
                TempAdvancePostingBufferCZZ2.Insert();
            until TempAdvancePostingBufferCZZ1.Next() = 0;

            if TempAdvancePostingBufferCZZ2.FindSet() then
                repeat
                    VATPostingSetup.Get(TempAdvancePostingBufferCZZ2."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ2."VAT Prod. Posting Group");
                    PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, TempAdvancePostingBufferCZZ2.Amount, TempAdvancePostingBufferCZZ2."VAT Amount",
                        PurchAdvLetterEntryCZZ."Entry No.", DetEntryNo, DocumentNo, ToDate, ToDate, PostDescription, GenJnlPostLine, false, false);
                until TempAdvancePostingBufferCZZ2.Next() = 0;

            BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, 0D);
            TempAdvancePostingBufferCZZ1.CalcSums(Amount);
            TempAdvancePostingBufferCZZ2.CalcSums(Amount);
            if TempAdvancePostingBufferCZZ1.Amount = 0 then
                AmountToDivide := TempAdvancePostingBufferCZZ2.Amount
            else begin
                PurchAdvLetterEntryCZZ2.Reset();
                PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
                PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
                PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
                PurchAdvLetterEntryCZZ2.CalcSums(Amount);
                AmountToDivide := Round(TempAdvancePostingBufferCZZ2.Amount * (VATDocAmtToDate - TempAdvancePostingBufferCZZ1.Amount) / PurchAdvLetterEntryCZZ2.Amount);
            end;

            AmountTotal := 0;
            PurchAdvLetterEntryCZZ2.Reset();
            PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
            PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
            PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
            PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::Usage);
            PurchAdvLetterEntryCZZ2.SetFilter("Posting Date", '>%1', ToDate);
            if PurchAdvLetterEntryCZZ2.FindSet() then begin
                repeat
                    PurchAdvLetterEntryCZZ3.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                    PurchAdvLetterEntryCZZ3.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ3.SetRange("Related Entry", PurchAdvLetterEntryCZZ2."Entry No.");
                    PurchAdvLetterEntryCZZ3.SetRange("Entry Type", PurchAdvLetterEntryCZZ3."Entry Type"::"VAT Usage");
                    PurchAdvLetterEntryCZZ3.SetFilter("Posting Date", '>%1', ToDate);
                    PurchAdvLetterEntryCZZ3.CalcSums(Amount);
                    AmountTotal += PurchAdvLetterEntryCZZ3.Amount;
                until PurchAdvLetterEntryCZZ2.Next() = 0;

                Coeff := AmountToDivide / AmountTotal;
                PurchAdvLetterEntryCZZ2.FindSet();
                repeat
                    PurchAdvLetterEntryCZZ3.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                    PurchAdvLetterEntryCZZ3.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ3.SetRange("Related Entry", PurchAdvLetterEntryCZZ2."Entry No.");
                    PurchAdvLetterEntryCZZ3.SetRange("Entry Type", PurchAdvLetterEntryCZZ3."Entry Type"::"VAT Usage");
                    PurchAdvLetterEntryCZZ3.SetFilter("Posting Date", '>%1', ToDate);
                    if PurchAdvLetterEntryCZZ3.FindSet() then
                        repeat
                            AmountToPost := Round(PurchAdvLetterEntryCZZ3.Amount * Coeff);
                            case PurchAdvLetterEntryCZZ3."VAT Calculation Type" of
                                PurchAdvLetterEntryCZZ3."VAT Calculation Type"::"Normal VAT":
                                    VATAmountToPost := Round(AmountToPost * PurchAdvLetterEntryCZZ3."VAT %" / (100 + PurchAdvLetterEntryCZZ3."VAT %"));
                                PurchAdvLetterEntryCZZ3."VAT Calculation Type"::"Reverse Charge VAT":
                                    VATAmountToPost := 0;
                            end;

                            VATPostingSetup.Get(PurchAdvLetterEntryCZZ3."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ3."VAT Prod. Posting Group");
                            PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, -AmountToPost, -VATAmountToPost,
                                PurchAdvLetterEntryCZZ2."Entry No.", 0, DocumentNo, PurchAdvLetterEntryCZZ3."Posting Date", PurchAdvLetterEntryCZZ3."VAT Date", PostDescription, GenJnlPostLine, false, false);
                        until PurchAdvLetterEntryCZZ3.Next() = 0;
                until PurchAdvLetterEntryCZZ2.Next() = 0;
            end;
        end;
    end;

    local procedure PostUnrealizedExchangeRate(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var VATPostingSetup: Record "VAT Posting Setup";
        Amount: Decimal; VATAmount: Decimal; RelatedEntryNo: Integer; RelatedDetEntryNo: Integer; DocumentNo: Code[20]; PostingDate: Date; VATDate: Date; PostDescription: Text[100]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Correction: Boolean; Preview: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        GetCurrency(PurchAdvLetterHeaderCZZ."Currency Code");

        if VATAmount <> 0 then begin
            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, '', SourceCodeSetup."Exchange Rate Adjmt.", PostDescription, GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            if VATAmount > 0 then begin
                CurrencyGlob.TestField("Unrealized Losses Acc.");
                GenJournalLine."Account No." := CurrencyGlob."Unrealized Losses Acc.";
            end else begin
                CurrencyGlob.TestField("Unrealized Gains Acc.");
                GenJournalLine."Account No." := CurrencyGlob."Unrealized Gains Acc.";
            end;
            GenJournalLine.Validate(Amount, VATAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, '', SourceCodeSetup."Exchange Rate Adjmt.", PostDescription, GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not ReplaceVATDateMgtCZL.IsEnabled() then
                GenJournalLine.Validate("VAT Date CZL", VATDate)
            else
#pragma warning restore AL0432
#endif
            GenJournalLine.Validate("VAT Reporting Date", VATDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.Validate(Amount, -VATAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);
        end;

        AdvEntryInit(Preview);
        if Correction then
            AdvEntryInitCancel();
        AdvEntryInitRelatedEntry(RelatedEntryNo);
        AdvEntryInitDetVendLedgEntryNo(RelatedDetEntryNo);
        AdvEntryInitVAT(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", VATDate, VATDate,
            0, VATPostingSetup."VAT %", VATPostingSetup."VAT Identifier", VATPostingSetup."VAT Calculation Type",
            0, VATAmount, 0, Amount - VATAmount);
        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Adjustment", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", PostingDate,
            0, Amount, '', 0, DocumentNo, GenJournalLine."External Document No.",
            PurchAdvLetterEntryCZZ."Global Dimension 1 Code", PurchAdvLetterEntryCZZ."Global Dimension 2 Code", PurchAdvLetterEntryCZZ."Dimension Set ID", Preview);
    end;

    local procedure ReverseUnrealizedExchangeRate(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        var VATPostingSetup: Record "VAT Posting Setup"; Coef: Decimal; RelatedEntryNo: Integer;
        DocumentNo: Code[20]; PostingDate: Date; VATDate: Date; PostDescription: Text[100]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        AmountLCY: Decimal;
        VATAmountLCY: Decimal;
    begin
        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        GetRemAmtLCYVATAdjust(AmountLCY, VATAmountLCY, PurchAdvLetterEntryCZZ, PostingDate, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        if (AmountLCY = 0) and (VATAmountLCY = 0) then
            exit;

        AmountLCY := Round(AmountLCY * Coef);
        VATAmountLCY := Round(VATAmountLCY * Coef);

        PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, -AmountLCY, -VATAmountLCY,
            RelatedEntryNo, 0, DocumentNo, PostingDate, VATDate, PostDescription, GenJnlPostLine, false, Preview);
    end;

    local procedure GetPostingDateUI(DefaultPostingDate: Date): Date
    var
        GetPostingDateCZZ: Page "Get Posting Date CZZ";
        PostingDate: Date;
    begin
        if not GuiAllowed() then
            exit(DefaultPostingDate);

        GetPostingDateCZZ.SetValues(DefaultPostingDate);
        if GetPostingDateCZZ.RunModal() = Action::OK then
            GetPostingDateCZZ.GetValues(PostingDate);
        exit(PostingDate);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertAdvEntry(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var Preview: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertAdvEntry(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var Preview: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateStatus(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; DocStatus: Enum "Advance Letter Doc. Status CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateStatus(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; DocStatus: Enum "Advance Letter Doc. Status CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PostingDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReversePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReversePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PostingDate: Date; var Preview: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostClosePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostClosePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostClosePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostClosePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnUnapplyVendLedgEntryOnBeforePostUnapplyVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInitGenJnlLineFromVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInitGenJnlLineFromAdvance(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnApplyAdvanceLetterOnBeforeTestAmount(var AdvanceLetterApplication: Record "Advance Letter Application CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePayment(VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLinkAdvanceLetterOnBeforeModifyAdvanceLetterApplication(var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary; var ModifyRecord: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLinkAdvanceLetterOnBeforeInsertAdvanceLetterApplication(var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUsageOnBeforeLoopPurchAdvLetterEntry(var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostAdvanceCreditMemoVATOnAfterGetDocument(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var PostingDate: Date; var VATDate: Date; var OriginalDocumentVATDate: Date)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforePostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; var PurchInvHeader: Record "Purch. Inv. Header"; var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostAdvancePaymentVATOnBeforeGenJnlPostLine(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckAdvancePayment(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentHeader: Variant; var IsHandled: Boolean);
    begin
    end;
}
