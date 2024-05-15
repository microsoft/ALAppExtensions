﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;
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
        PurchAdvLetterPostCZZ: Codeunit "Purch. Adv. Letter-Post CZZ";
        DateEmptyErr: Label 'Posting Date and VAT Date cannot be empty.';
        DocumentNoOrDatesEmptyErr: Label 'Document No. and Dates cannot be empty.';
        ExternalDocumentNoEmptyErr: Label 'External Document No. cannot be empty.';
        NothingToPostErr: Label 'Nothing to Post.';
        VATDocumentExistsErr: Label 'VAT Document already exists.';
        PostingDateEmptyErr: Label 'Posting Date cannot be empty.';
        LaterPostingDateQst: Label 'The linked advance letter %1 is paid after %2. If you continue, the advance letter won''t be deducted.\\Do you want to continue?', Comment = '%1 = advance letter no., %2 = posting date';
        ExceededUsageAmountErr: Label 'Post VAT Document higher than usage is not possible.';

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
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
    begin
        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."Amount to Link" := LinkAmount;

        PurchAdvLetterPostCZZ.PostAdvancePayment(
            VendorLedgerEntry, PostedGenJournalLine, GenJnlPostLine, AdvancePostingParametersCZZ);
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
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        ConfirmManagement: Codeunit "Confirm Management";
        VATDocumentCZZ: Page "VAT Document CZZ";
        DocumentNo: Code[20];
        IsHandled: Boolean;
        DocumentDate: Date;
        VATDate: Date;
        OriginalDocumentVATDate: Date;
        ExternalDocumentNo: Code[35];
        VATDocumentExistsQst: Label 'VAT Document already exists.\Continue?';
    begin
        IsHandled := false;
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

        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Document Type" := Enum::"Gen. Journal Document Type"::Invoice;
        AdvancePostingParametersCZZ."Document No." := DocumentNo;
        AdvancePostingParametersCZZ."External Document No." := ExternalDocumentNo;
        AdvancePostingParametersCZZ."Posting Description" := PurchAdvLetterHeaderCZZ."Posting Description";
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."Document Date" := DocumentDate;
        AdvancePostingParametersCZZ."VAT Date" := VATDate;
        AdvancePostingParametersCZZ."Original Document VAT Date" := OriginalDocumentVATDate;
        AdvancePostingParametersCZZ."Currency Code" := PurchAdvLetterEntryCZZ."Currency Code";
        AdvancePostingParametersCZZ."Currency Factor" := PurchAdvLetterEntryCZZ."Currency Factor";

        PurchAdvLetterPostCZZ.PostAdvancePaymentVAT(
            PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure InitVATAmountLine(var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; PurchAdvanceNo: Code[20]; Amount: Decimal; CurrencyFactor: Decimal)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        AmountRemainder: Decimal;
        Coeff: Decimal;
    begin
        AdvancePostingBufferCZZ.Reset();
        AdvancePostingBufferCZZ.DeleteAll();

        if Amount = 0 then
            exit;

        PurchAdvLetterHeaderCZZ.Get(PurchAdvanceNo);
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");

        Coeff := Amount / PurchAdvLetterHeaderCZZ."Amount Including VAT";
        AmountRemainder := 0;

        BufferAdvanceLines(PurchAdvLetterHeaderCZZ, TempAdvancePostingBufferCZZ);
        TempAdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        if TempAdvancePostingBufferCZZ.FindSet() then
            repeat
                AdvancePostingBufferCZZ.Init();
                AdvancePostingBufferCZZ := TempAdvancePostingBufferCZZ;
                AmountRemainder += AdvancePostingBufferCZZ.Amount * Coeff;
                AdvancePostingBufferCZZ.Amount := AmountRemainder;
                AdvancePostingBufferCZZ.UpdateVATAmounts();
                AdvancePostingBufferCZZ.UpdateLCYAmounts(PurchAdvLetterHeaderCZZ."Currency Code", CurrencyFactor);
                AdvancePostingBufferCZZ.Insert();
                AmountRemainder -= AdvancePostingBufferCZZ.Amount;
            until TempAdvancePostingBufferCZZ.Next() = 0;
    end;

    local procedure BufferAdvanceLines(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    var
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
    begin
        AdvancePostingBufferCZZ.Reset();
        AdvancePostingBufferCZZ.DeleteAll();

        PurchAdvLetterLineCZZ.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterLineCZZ.SetFilter(Amount, '<>0');
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
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
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

        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;

        PurchAdvLetterPostCZZ.PostAdvancePaymentUnlinking(PurchAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; var PurchInvHeader: Record "Purch. Inv. Header"; var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
    begin
        AdvancePostingParametersCZZ."Temporary Entries Only" := Preview;

        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
        PurchAdvLetterPostCZZ.PostAdvancePaymentUsage(PurchInvHeader, AdvanceLetterApplicationCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvancePaymentUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        PurchInvHeader: Record "Purch. Inv. Header";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATDocumentCZZ: Page "VAT Document CZZ";
        DocumentNo: Code[20];
        PostingDate: Date;
        DocumentDate: Date;
        VATDate: Date;
        OriginalDocumentVATDate: Date;
        ExternalDocumentNo: Code[35];
        CurrencyFactor: Decimal;
        UsedAmount: Decimal;
    begin
        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        if not PurchAdvLetterEntryCZZ2.IsEmpty() then
            Error(VATDocumentExistsErr);

        PurchAdvLetterEntryCZZ2.Get(PurchAdvLetterEntryCZZ."Related Entry");
        PurchAdvLetterEntryCZZ2.TestField(PurchAdvLetterEntryCZZ2."Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::Payment);

        VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");

        if PurchInvHeader.Get(VendorLedgerEntry."Document No.") then
            CurrencyFactor := PurchInvHeader."VAT Currency Factor CZL"
        else
            CurrencyFactor := VendorLedgerEntry."Original Currency Factor";

        UsedAmount := -PurchAdvLetterEntryCZZ.Amount;
        PurchAdvLetterPostCZZ.BufferAdvanceVATLines(PurchAdvLetterEntryCZZ2, TempAdvancePostingBufferCZZ, 0D);
        PurchAdvLetterPostCZZ.SuggestUsageVAT(PurchAdvLetterEntryCZZ2, TempAdvancePostingBufferCZZ, VendorLedgerEntry."Document No.",
            UsedAmount, CurrencyFactor, false);

        VATDocumentCZZ.InitDocument('', VendorLedgerEntry."Document No.", VendorLedgerEntry."Posting Date",
            VendorLedgerEntry."Document Date", VendorLedgerEntry."VAT Date CZL", PurchInvHeader."Original Doc. VAT Date CZL",
            VendorLedgerEntry."Currency Code", CurrencyFactor, VendorLedgerEntry."External Document No.",
            TempAdvancePostingBufferCZZ);
        if VATDocumentCZZ.RunModal() <> Action::OK then
            exit;

        VATDocumentCZZ.GetDocument(DocumentNo, PostingDate, DocumentDate, VATDate, OriginalDocumentVATDate, ExternalDocumentNo, TempAdvancePostingBufferCZZ);

        TempAdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        if TempAdvancePostingBufferCZZ.IsEmpty() then
            Error(NothingToPostErr);

        if UsedAmount <> 0 then begin
            TempAdvancePostingBufferCZZ.CalcSums(Amount);
            if TempAdvancePostingBufferCZZ.Amount > UsedAmount then
                Error(ExceededUsageAmountErr);
        end;

        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ.CopyFromVendorLedgerEntry(VendorLedgerEntry);
        AdvancePostingParametersCZZ."Document Type" := "Gen. Journal Document Type"::Invoice;
        AdvancePostingParametersCZZ."Document No." := DocumentNo;
        AdvancePostingParametersCZZ."External Document No." := ExternalDocumentNo;
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."Document Date" := DocumentDate;
        AdvancePostingParametersCZZ."VAT Date" := VATDate;
        AdvancePostingParametersCZZ."Original Document VAT Date" := VATDate;
        if OriginalDocumentVATDate <> 0D then
            AdvancePostingParametersCZZ."Original Document VAT Date" := OriginalDocumentVATDate;
        AdvancePostingParametersCZZ."Currency Code" := PurchAdvLetterEntryCZZ2."Currency Code";
        AdvancePostingParametersCZZ."Currency Factor" := CurrencyFactor;

        AdvancePostingParametersCZZ.CheckDocumentNo();
        AdvancePostingParametersCZZ.CheckPurchaseDates();

        PurchasesPayablesSetup.Get();
        if PurchasesPayablesSetup."Ext. Doc. No. Mandatory" then
            AdvancePostingParametersCZZ.CheckExternalDocumentNo();

        PurchAdvLetterPostCZZ.PostAdvancePaymentUsageVAT(
            PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure PostExchangeRate(ExchRateAmount: Decimal; ExchRateVATAmount: Decimal; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var VATPostingSetup: Record "VAT Posting Setup";
        DocumentNo: Code[20]; PostingDate: Date; VATDate: Date; SourceCode: Code[10]; PostDescription: Text[100]; UsageEntryNo: Integer; Correction: Boolean;
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
    begin
        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Document No." := DocumentNo;
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."VAT Date" := VATDate;
        AdvancePostingParametersCZZ."Source Code" := SourceCode;
        AdvancePostingParametersCZZ."Posting Description" := PostDescription;
        AdvancePostingParametersCZZ."Temporary Entries Only" := Preview;

        PurchAdvLetterPostCZZ.PostExchangeRate(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
            ExchRateAmount, ExchRateVATAmount, UsageEntryNo, Correction, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure InitGenJnlLineFromAdvance(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; DocumentNo: Code[20]; ExternalDocumentNo: Code[35]; SourceCode: Code[10]; PostDescription: Text[100]; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Init();
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."External Document No." := ExternalDocumentNo;
        GenJournalLine.Description := PostDescription;
        GenJournalLine."Source Code" := SourceCode;
        GenJournalLine."Bill-to/Pay-to No." := PurchAdvLetterHeaderCZZ."Pay-to Vendor No.";
        GenJournalLine."Country/Region Code" := PurchAdvLetterHeaderCZZ."Pay-to Country/Region Code";
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
            PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::Closed);
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
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::Closed then
            exit;

        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::New then begin
            PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::Closed);
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

        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."External Document No." := ExternalDocumentNo;
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."Document Date" := PostingDate;
        AdvancePostingParametersCZZ."VAT Date" := VATDate;
        AdvancePostingParametersCZZ."Original Document VAT Date" := OriginalDocumentVATDate;
        AdvancePostingParametersCZZ."Currency Code" := PurchAdvLetterHeaderCZZ."Currency Code";
        AdvancePostingParametersCZZ."Currency Factor" := CurrencyFactor;

        PurchAdvLetterPostCZZ.PostAdvanceLetterClosing(PurchAdvLetterHeaderCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvanceCreditMemoVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        VATEntry: Record "VAT Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATDocumentCZZ: Page "VAT Document CZZ";
        DocumentNo: Code[20];
        ExternalDocumentNo: Code[35];
        VATDate: Date;
        OriginalDocumentVATDate: Date;
        DocumentDate: Date;
        PostingDate: Date;
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

        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Document Type" := "Gen. Journal Document Type"::"Credit Memo";
        AdvancePostingParametersCZZ."Document No." := DocumentNo;
        AdvancePostingParametersCZZ."External Document No." := ExternalDocumentNo;
        AdvancePostingParametersCZZ."Source Code" := VATEntry."Source Code";
        AdvancePostingParametersCZZ."Posting Description" := PurchAdvLetterHeaderCZZ."Posting Description";
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."Document Date" := PostingDate;
        AdvancePostingParametersCZZ."VAT Date" := VATDate;
        AdvancePostingParametersCZZ."Original Document VAT Date" := OriginalDocumentVATDate;
        AdvancePostingParametersCZZ."Currency Code" := PurchAdvLetterEntryCZZ."Currency Code";
        AdvancePostingParametersCZZ."Currency Factor" := PurchAdvLetterEntryCZZ."Currency Factor";

        PurchAdvLetterPostCZZ.PostAdvanceCreditMemoVAT(
            PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostCancelUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
    begin
        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter Cr. Memo Nos.");

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
                            PurchAdvLetterEntryCZZ2."Related Entry", 0, PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ2."Posting Date", PurchAdvLetterEntryCZZ2."VAT Date", '', GenJnlPostLine, true, false);
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
        PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::"To Use");
    end;

    procedure PostAdvancePaymentUsagePreview(var PurchaseHeader: Record "Purchase Header"; Amount: Decimal; AmountLCY: Decimal; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
        PurchAdvLetterPostCZZ.PostAdvancePaymentUsageForStatistics(PurchaseHeader, Amount, AmountLCY, PurchAdvLetterEntryCZZ);
    end;

    procedure UnapplyAdvanceLetter(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        TempPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        ConfirmManagement: Codeunit "Confirm Management";
        AdvLetters: Text;
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

        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Document No." := PurchInvHeader."No.";

        PurchAdvLetterPostCZZ.PostAdvanceLetterUnapplying(PurchInvHeader, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure ApplyAdvanceLetter(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
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

        PurchAdvLetterPostCZZ.PostAdvanceLetterApplying(PurchInvHeader, GenJnlPostLine, AdvancePostingParametersCZZ);
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
        AmountRemainder: Decimal;
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

        PurchAdvLetterPostCZZ.BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, ToDate);
        TempAdvancePostingBufferCZZ1.CalcSums(Amount);
        VATDocAmtToDate := TempAdvancePostingBufferCZZ1.Amount;
        if VATDocAmtToDate <> 0 then begin
            Coeff := Amount / VATDocAmtToDate;
            AmountRemainder := 0;
            TempAdvancePostingBufferCZZ1.FindSet();
            repeat
                TempAdvancePostingBufferCZZ2.Init();
                TempAdvancePostingBufferCZZ2 := TempAdvancePostingBufferCZZ1;
                AmountRemainder += TempAdvancePostingBufferCZZ2.Amount * Coeff;
                TempAdvancePostingBufferCZZ2.Amount := AmountRemainder;
                TempAdvancePostingBufferCZZ2.UpdateVATAmounts();
                TempAdvancePostingBufferCZZ2.Insert();
                AmountRemainder -= TempAdvancePostingBufferCZZ2.Amount;
            until TempAdvancePostingBufferCZZ1.Next() = 0;

            if TempAdvancePostingBufferCZZ2.FindSet() then
                repeat
                    VATPostingSetup.Get(TempAdvancePostingBufferCZZ2."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ2."VAT Prod. Posting Group");
                    PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, TempAdvancePostingBufferCZZ2.Amount, TempAdvancePostingBufferCZZ2."VAT Amount",
                        PurchAdvLetterEntryCZZ."Entry No.", DetEntryNo, DocumentNo, ToDate, ToDate, PostDescription, GenJnlPostLine, false, false);
                until TempAdvancePostingBufferCZZ2.Next() = 0;

            PurchAdvLetterPostCZZ.BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, 0D);
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
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
    begin
        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Document No." := DocumentNo;
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."VAT Date" := VATDate;
        AdvancePostingParametersCZZ."Posting Description" := PostDescription;
        AdvancePostingParametersCZZ."Temporary Entries Only" := Preview;

        PurchAdvLetterPostCZZ.PostUnrealizedExchangeRate(
            PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount, RelatedEntryNo, RelatedDetEntryNo, Correction, GenJnlPostLine, AdvancePostingParametersCZZ);
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
#if not CLEAN24
#pragma warning disable AL0432
    internal procedure RaiseOnBeforePostPaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
        OnBeforePostPaymentRepos(GenJournalLine, purchAdvLetterHeaderCZZ, PostedGenJournalLine);
    end;

    internal procedure RaiseOnAfterPostPaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
        OnAfterPostPaymentRepos(GenJournalLine, purchAdvLetterHeaderCZZ, PostedGenJournalLine);
    end;

    internal procedure RaiseOnBeforePostPayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
        OnBeforePostPayment(GenJournalLine, purchAdvLetterHeaderCZZ, PostedGenJournalLine);
    end;

    internal procedure RaiseOnAfterPostPayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
        OnAfterPostPayment(GenJournalLine, purchAdvLetterHeaderCZZ, PostedGenJournalLine);
    end;

    internal procedure RaiseOnAfterInitGenJnlLineFromVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        OnAfterInitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine);
    end;

    internal procedure RaiseOnAfterInitGenJnlLineFromAdvance(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        OnAfterInitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, GenJournalLine);
    end;

    internal procedure RaiseOnPostAdvancePaymentVATOnBeforeGenJnlPostLine(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        OnPostAdvancePaymentVATOnBeforeGenJnlPostLine(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, GenJournalLine);
    end;

    internal procedure RaiseOnBeforePostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; var PurchInvHeader: Record "Purch. Inv. Header"; var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean; var IsHandled: Boolean)
    begin
        OnBeforePostAdvancePaymentUsage(
            AdvLetterUsageDocTypeCZZ, DocumentNo, PurchInvHeader, VendorLedgerEntry, GenJnlPostLine, Preview, IsHandled);
    end;

    internal procedure RaiseOnPostAdvancePaymentUsageOnBeforeLoopPurchAdvLetterEntry(var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
        OnPostAdvancePaymentUsageOnBeforeLoopPurchAdvLetterEntry(AdvanceLetterApplicationCZZ, PurchAdvLetterEntryCZZ);
    end;

    internal procedure RaiseOnBeforePostAdvancePayment(VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var IsHandled: Boolean);
    begin
        OnBeforePostAdvancePayment(VendorLedgerEntry, GenJournalLine, LinkAmount, GenJnlPostLine, IsHandled);
    end;

    internal procedure RaiseOnBeforePostClosePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        OnBeforePostClosePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);
    end;

    internal procedure RaiseOnAfterPostClosePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        OnAfterPostClosePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);
    end;

    internal procedure RaiseOnBeforePostClosePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        OnBeforePostClosePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
    end;

    internal procedure RaiseOnAfterPostClosePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        OnAfterPostClosePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
    end;

    internal procedure RaiseOnBeforePostReversePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        OnBeforePostReversePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
    end;

    internal procedure RaiseOnAfterPostReversePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        OnAfterPostReversePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
    end;

    internal procedure RaiseOnBeforePostReversePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        OnBeforePostReversePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);
    end;

    internal procedure RaiseOnAfterPostReversePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        OnAfterPostReversePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);
    end;

    internal procedure RaiseOnBeforePostReversePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PostingDate: Date; var Preview: Boolean; var IsHandled: Boolean)
    begin
        OnBeforePostReversePaymentVAT(PurchAdvLetterEntryCZZ, PostingDate, Preview, IsHandled);
    end;

    internal procedure RaiseOnUnapplyVendLedgEntryOnBeforePostUnapplyVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        OnUnapplyVendLedgEntryOnBeforePostUnapplyVendLedgEntry(VendorLedgerEntry, DetailedVendorLedgEntry, GenJournalLine);
    end;
#pragma warning restore AL0432
#endif

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

    [Obsolete('Replaced by OnPostAdvancePaymentOnBeforePostPaymentApplication event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [Obsolete('Replaced by OnPostAdvancePaymentOnAfterPostPaymentApplication event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [Obsolete('Replaced by OnPostAdvancePaymentOnBeforePostAdvancePayment event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [Obsolete('Replaced by OnPostAdvancePaymentOnAfterPostAdvancePayment event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PostingDate: Date; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('Replaced by OnReverseAdvancePaymentOnBeforePostInvoiceApplication event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [Obsolete('Replaced by OnReverseAdvancePaymentOnAfterPostInvoiceApplication event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReversePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [Obsolete('Replaced by OnReverseAdvancePaymentOnBeforePostAdvancePaymentUsage event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [Obsolete('Replaced by OnReverseAdvancePaymentOnAfterPostAdvancePaymentUsage event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReversePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [Obsolete('Replaced by OnBeforeReverseAdvancePaymentVAT event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PostingDate: Date; var Preview: Boolean; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('Replaced by OnPostAdvancePaymentClosingEntryOnBeforePostBalance event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforePostClosePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [Obsolete('Replaced by OnPostAdvancePaymentClosingEntryOnAfterPostBalance event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterPostClosePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [Obsolete('Replaced by OnPostAdvancePaymentClosingEntryOnBeforePost event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforePostClosePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [Obsolete('Replaced by OnPostAdvancePaymentClosingEntryOnAfterPost event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterPostClosePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [Obsolete('Replaced by OnUnapplyVendLedgEntryOnBeforePostUnapplyVendLedgEntry event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(true, false)]
    local procedure OnUnapplyVendLedgEntryOnBeforePostUnapplyVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [Obsolete('Replaced by events in "Gen. Journal Line CZZ" table extension, e.g. one of the events OnAfterCopyFromVendorLedgerEntryCZZ.', '24.0')]
    [IntegrationEvent(true, false)]
    local procedure OnAfterInitGenJnlLineFromVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [Obsolete('Replaced by events in "Gen. Journal Line CZZ" table extension, e.g. one of the events OnAfterCopyGenJnlLineFromPurchAdvLetterHeaderCZZ.', '24.0')]
    [IntegrationEvent(true, false)]
    local procedure OnAfterInitGenJnlLineFromAdvance(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnApplyAdvanceLetterOnBeforeTestAmount(var AdvanceLetterApplication: Record "Advance Letter Application CZZ"; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

    [Obsolete('Replaced by OnBeforePostAdvancePayment event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
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

    [Obsolete('Replaced by OnPostAdvancePaymentUsageOnAfterSetPurchAdvLetterEntryFilter event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUsageOnBeforeLoopPurchAdvLetterEntry(var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostAdvanceCreditMemoVATOnAfterGetDocument(PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var PostingDate: Date; var VATDate: Date; var OriginalDocumentVATDate: Date)
    begin
    end;

    [Obsolete('Replaced by OnBeforePostAdvancePaymentUsage event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(true, false)]
    local procedure OnBeforePostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; var PurchInvHeader: Record "Purch. Inv. Header"; var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean; var IsHandled: Boolean)
    begin
    end;

    [Obsolete('Replaced by OnPostAdvancePaymentVATOnBeforePostVATDocumentAmounts event in "Purch. Adv. Letter-Post CZZ" codeunit.', '24.0')]
    [IntegrationEvent(true, false)]
    local procedure OnPostAdvancePaymentVATOnBeforeGenJnlPostLine(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckAdvancePayment(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentHeader: Variant; var IsHandled: Boolean);
    begin
    end;
}
