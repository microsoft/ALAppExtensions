// ------------------------------------------------------------------------------------------------
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
using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.Utilities;

codeunit 31002 "SalesAdvLetterManagement CZZ"
{
    Permissions = tabledata "Cust. Ledger Entry" = m,
                  tabledata "Sales Invoice Line" = i;

    var
        SalesAdvLetterEntryCZZGlob: Record "Sales Adv. Letter Entry CZZ";
        TempSalesAdvLetterEntryCZZGlob: Record "Sales Adv. Letter Entry CZZ" temporary;
        SalesAdvLetterPostCZZ: Codeunit "Sales Adv. Letter-Post CZZ";
        DocumentNoOrDatesEmptyErr: Label 'Document No. and Dates cannot be empty.';
        VATDocumentExistsErr: Label 'VAT Document already exists.';
        DateEmptyErr: Label 'Posting Date and VAT Date cannot be empty.';
        PostingDateEmptyErr: Label 'Posting Date cannot be empty.';
        LaterPostingDateQst: Label 'The linked advance letter %1 is paid after %2. If you continue, the advance letter won''t be deducted.\\Do you want to continue?', Comment = '%1 = advance letter no., %2 = posting date';

    procedure AdvEntryInit(Preview: Boolean)
    begin
        if (SalesAdvLetterEntryCZZGlob."Entry No." = 0) and (not Preview) then begin
            SalesAdvLetterEntryCZZGlob.LockTable();
            if SalesAdvLetterEntryCZZGlob.FindLast() then;
        end;
        SalesAdvLetterEntryCZZGlob.Init();
        SalesAdvLetterEntryCZZGlob."Entry No." += 1;
    end;

    procedure AdvEntryInsert(EntryType: Enum "Advance Letter Entry Type CZZ"; AdvLetterNo: Code[20]; PostingDate: Date; Amt: Decimal; AmtLCY: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; DocumentNo: Code[20]; GlDim1Code: Code[20]; GlDim2Code: Code[20]; DimSetID: Integer; Preview: Boolean) InsertedEntryNo: Integer
    begin
        SalesAdvLetterEntryCZZGlob."Entry Type" := EntryType;
        SalesAdvLetterEntryCZZGlob."Sales Adv. Letter No." := AdvLetterNo;
        SalesAdvLetterEntryCZZGlob."Posting Date" := PostingDate;
        SalesAdvLetterEntryCZZGlob.Amount := Amt;
        SalesAdvLetterEntryCZZGlob."Amount (LCY)" := AmtLCY;
        SalesAdvLetterEntryCZZGlob."Currency Code" := CurrencyCode;
        SalesAdvLetterEntryCZZGlob."Currency Factor" := CurrencyFactor;
        SalesAdvLetterEntryCZZGlob."Document No." := DocumentNo;
        SalesAdvLetterEntryCZZGlob."User ID" := CopyStr(UserId(), 1, MaxStrLen(SalesAdvLetterEntryCZZGlob."User ID"));
        SalesAdvLetterEntryCZZGlob."Global Dimension 1 Code" := GlDim1Code;
        SalesAdvLetterEntryCZZGlob."Global Dimension 2 Code" := GlDim2Code;
        SalesAdvLetterEntryCZZGlob."Dimension Set ID" := DimSetID;
        SalesAdvLetterEntryCZZGlob."Customer No." := SalesAdvLetterEntryCZZGlob.GetCustomerNo();
        OnBeforeInsertAdvEntry(SalesAdvLetterEntryCZZGlob, Preview);
        if Preview then begin
            TempSalesAdvLetterEntryCZZGlob := SalesAdvLetterEntryCZZGlob;
            TempSalesAdvLetterEntryCZZGlob.Insert();
        end else begin
            SalesAdvLetterEntryCZZGlob.Insert();
            InsertedEntryNo := SalesAdvLetterEntryCZZGlob."Entry No.";
        end;
        OnAfterInsertAdvEntry(SalesAdvLetterEntryCZZGlob, Preview);
    end;

    procedure AdvEntryInitVAT(VATBusPostGr: Code[20]; VATProdPostGr: Code[20]; VATDate: Date; VATEntryNo: Integer; VATPer: Decimal; VATIdentifier: Code[20]; VATCalcType: Enum "Tax Calculation Type"; VATAmount: Decimal; VATAmountLCY: Decimal; VATBase: Decimal; VATBaseLCY: Decimal)
    begin
        SalesAdvLetterEntryCZZGlob."VAT Bus. Posting Group" := VATBusPostGr;
        SalesAdvLetterEntryCZZGlob."VAT Prod. Posting Group" := VATProdPostGr;
        SalesAdvLetterEntryCZZGlob."VAT Date" := VATDate;
        SalesAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
        SalesAdvLetterEntryCZZGlob."VAT %" := VATPer;
        SalesAdvLetterEntryCZZGlob."VAT Identifier" := VATIdentifier;
        SalesAdvLetterEntryCZZGlob."VAT Calculation Type" := VATCalcType;
        SalesAdvLetterEntryCZZGlob."VAT Amount" := VATAmount;
        SalesAdvLetterEntryCZZGlob."VAT Amount (LCY)" := VATAmountLCY;
        SalesAdvLetterEntryCZZGlob."VAT Base Amount" := VATBase;
        SalesAdvLetterEntryCZZGlob."VAT Base Amount (LCY)" := VATBaseLCY;
    end;

    procedure AdvEntryInitCustLedgEntryNo(CustLedgEntryNo: Integer)
    begin
        SalesAdvLetterEntryCZZGlob."Cust. Ledger Entry No." := CustLedgEntryNo;
    end;

    procedure AdvEntryInitDetCustLedgEntryNo(DetCustLedgEntryNo: Integer)
    begin
        SalesAdvLetterEntryCZZGlob."Det. Cust. Ledger Entry No." := DetCustLedgEntryNo;
    end;

    procedure AdvEntryInitRelatedEntry(RelatedEntry: Integer)
    begin
        SalesAdvLetterEntryCZZGlob."Related Entry" := RelatedEntry;
    end;

    procedure AdvEntryInitCancel()
    begin
        SalesAdvLetterEntryCZZGlob.Cancelled := true;
    end;

    procedure GetTempAdvLetterEntry(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
        if TempSalesAdvLetterEntryCZZGlob.FindSet() then begin
            repeat
                SalesAdvLetterEntryCZZ := TempSalesAdvLetterEntryCZZGlob;
                SalesAdvLetterEntryCZZ.Insert();
            until TempSalesAdvLetterEntryCZZGlob.Next() = 0;
            TempSalesAdvLetterEntryCZZGlob.DeleteAll();
        end;
    end;

    procedure UpdateStatus(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; DocStatus: Enum "Advance Letter Doc. Status CZZ")
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        OnBeforeUpdateStatus(SalesAdvLetterHeaderCZZ, DocStatus);
        case DocStatus of
            DocStatus::New:
                begin
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                    SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
                    SalesAdvLetterEntryCZZ.CalcSums(Amount);
                    if SalesAdvLetterEntryCZZ.Amount = 0 then begin
                        SalesAdvLetterHeaderCZZ.Status := SalesAdvLetterHeaderCZZ.Status::New;
                        SalesAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::"To Pay":
                begin
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                    SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
                    SalesAdvLetterEntryCZZ.CalcSums(Amount);
                    if SalesAdvLetterEntryCZZ.Amount <> 0 then begin
                        SalesAdvLetterHeaderCZZ.Status := SalesAdvLetterHeaderCZZ.Status::"To Pay";
                        SalesAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::"To Use":
                begin
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                    SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry", SalesAdvLetterEntryCZZ."Entry Type"::Payment, SalesAdvLetterEntryCZZ."Entry Type"::Close);
                    SalesAdvLetterEntryCZZ.CalcSums(Amount);
                    if SalesAdvLetterEntryCZZ.Amount = 0 then begin
                        SalesAdvLetterHeaderCZZ.Status := SalesAdvLetterHeaderCZZ.Status::"To Use";
                        SalesAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::Closed:
                begin
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                    SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry", SalesAdvLetterEntryCZZ."Entry Type"::Payment, SalesAdvLetterEntryCZZ."Entry Type"::Close);
                    SalesAdvLetterEntryCZZ.CalcSums(Amount);
                    if SalesAdvLetterEntryCZZ.Amount = 0 then begin
                        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3|%4|%5|%6', SalesAdvLetterEntryCZZ."Entry Type"::Payment, SalesAdvLetterEntryCZZ."Entry Type"::Usage, SalesAdvLetterEntryCZZ."Entry Type"::Close,
                            SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Close");
                        SalesAdvLetterEntryCZZ.CalcSums(Amount);
                        if SalesAdvLetterEntryCZZ.Amount = 0 then begin
                            SalesAdvLetterHeaderCZZ.Status := SalesAdvLetterHeaderCZZ.Status::Closed;
                            SalesAdvLetterHeaderCZZ.Modify();
                        end;
                    end;
                end;
            else
                OnUpdateStatus(SalesAdvLetterHeaderCZZ, DocStatus);
        end;
    end;

    procedure CancelInitEntry(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; EntryDate: Date; Cancel: Boolean)
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        ToPayLCY: Decimal;
    begin
        SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
        if SalesAdvLetterHeaderCZZ."To Pay" = 0 then
            exit;

        if Cancel then begin
            SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
            SalesAdvLetterHeaderCZZ.TestField("To Pay", SalesAdvLetterHeaderCZZ."Amount Including VAT");
        end;

        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if SalesAdvLetterEntryCZZ.FindFirst() then begin
            if EntryDate = 0D then
                EntryDate := SalesAdvLetterEntryCZZ."Posting Date";

            if SalesAdvLetterEntryCZZ."Currency Factor" = 0 then
                ToPayLCY := SalesAdvLetterHeaderCZZ."To Pay"
            else
                ToPayLCY := Round(SalesAdvLetterHeaderCZZ."To Pay" / SalesAdvLetterEntryCZZ."Currency Factor");

            AdvEntryInit(false);
            if Cancel then
                AdvEntryInitCancel();
            AdvEntryInsert("Advance Letter Entry Type CZZ"::"Initial Entry", SalesAdvLetterHeaderCZZ."No.", EntryDate,
                -SalesAdvLetterHeaderCZZ."To Pay", -ToPayLCY,
                SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor", SalesAdvLetterHeaderCZZ."No.",
                SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", SalesAdvLetterHeaderCZZ."Dimension Set ID", false);

            if Cancel then begin
                SalesAdvLetterEntryCZZ.Cancelled := true;
                SalesAdvLetterEntryCZZ.Modify();
            end;
        end;
    end;

    procedure LinkAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        TempAdvanceLetterLinkBufferCZZ: Record "Advance Letter Link Buffer CZZ" temporary;
        AdvanceLetterLinkCZZ: Page "Advance Letter Link CZZ";
        PostingDate: Date;
    begin
        AdvanceLetterLinkCZZ.SetCVEntry(CustLedgerEntry.RecordId);
        AdvanceLetterLinkCZZ.LookupMode(true);
        if AdvanceLetterLinkCZZ.RunModal() = Action::LookupOK then begin
            AdvanceLetterLinkCZZ.GetLetterLink(TempAdvanceLetterLinkBufferCZZ);
            TempAdvanceLetterLinkBufferCZZ.SetFilter(Amount, '>0');
            if not TempAdvanceLetterLinkBufferCZZ.IsEmpty() then begin
                PostingDate := CustLedgerEntry."Posting Date";
                if not GetPostingDateUI(PostingDate) then
                    exit;
                if PostingDate = 0D then
                    Error(PostingDateEmptyErr);
                LinkAdvancePayment(CustLedgerEntry, TempAdvanceLetterLinkBufferCZZ, PostingDate);
            end;
        end;
    end;

    procedure LinkAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry"; var TempAdvanceLetterLinkBufferCZZ: Record "Advance Letter Link Buffer CZZ" temporary; PostingDate: Date)
    var
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        InsertedEntryNo: Integer;
    begin
        TempAdvanceLetterLinkBufferCZZ.SetFilter(Amount, '>0');
        if TempAdvanceLetterLinkBufferCZZ.FindSet() then begin
            repeat
                InsertedEntryNo := PostAdvancePayment(CustLedgerEntry, TempAdvanceLetterLinkBufferCZZ."Advance Letter No.", TempAdvanceLetterLinkBufferCZZ.Amount, GenJnlPostLine, PostingDate);
                SalesAdvLetterEntryCZZ.Get(InsertedEntryNo);
                TempSalesAdvLetterEntryCZZ := SalesAdvLetterEntryCZZ;
                TempSalesAdvLetterEntryCZZ.Insert();
            until TempAdvanceLetterLinkBufferCZZ.Next() = 0;

            if TempSalesAdvLetterEntryCZZ.FindSet() then
                repeat
                    SalesAdvLetterHeaderCZZ.Get(TempSalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                    if SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" then
                        PostAdvancePaymentVAT(TempSalesAdvLetterEntryCZZ, 0D);
                until TempSalesAdvLetterEntryCZZ.Next() = 0;
        end;
    end;

    procedure PostAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry"; AdvanceLetterNo: Code[20]; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line") InsertedEntryNo: Integer
    var
        PostingDate: Date;
    begin
        PostingDate := CustLedgerEntry."Posting Date";
        if not GetPostingDateUI(PostingDate) then
            exit;
        if PostingDate = 0D then
            Error(PostingDateEmptyErr);

        InsertedEntryNo := PostAdvancePayment(CustLedgerEntry, AdvanceLetterNo, LinkAmount, GenJnlPostLine, PostingDate);
    end;

    procedure PostAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry"; PostedGenJournalLine: Record "Gen. Journal Line"; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line") InsertedEntryNo: Integer
    var
        PostingDate: Date;
    begin
        PostingDate := CustLedgerEntry."Posting Date";
        if not GetPostingDateUI(PostingDate) then
            exit;
        if PostingDate = 0D then
            Error(PostingDateEmptyErr);

        InsertedEntryNo := PostAdvancePayment(CustLedgerEntry, PostedGenJournalLine, LinkAmount, GenJnlPostLine, PostingDate);
    end;

    procedure PostAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry"; AdvanceLetterNo: Code[20]; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PostingDate: Date) InsertedEntryNo: Integer
    var
        PostedGenJournalLine: Record "Gen. Journal Line";
    begin
        PostedGenJournalLine."Advance Letter No. CZZ" := AdvanceLetterNo;
        InsertedEntryNo := PostAdvancePayment(CustLedgerEntry, PostedGenJournalLine, LinkAmount, GenJnlPostLine, PostingDate);
    end;

    procedure PostAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry"; PostedGenJournalLine: Record "Gen. Journal Line"; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PostingDate: Date) InsertedEntryNo: Integer
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
    begin
        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."Amount to Link" := LinkAmount;

        InsertedEntryNo := SalesAdvLetterPostCZZ.PostAdvancePayment(
            CustLedgerEntry, PostedGenJournalLine, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;
#if not CLEAN25
    [Obsolete('Replaced by GetAdvanceGLAccountNoCZZ function in GenJournalLine.', '25.0')]
    procedure GetAdvanceGLAccount(var GenJournalLine: Record "Gen. Journal Line"): Code[20]
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
    begin
        SalesAdvLetterHeaderCZZ.Get(GenJournalLine."Adv. Letter No. (Entry) CZZ");
        SalesAdvLetterHeaderCZZ.TestField("Advance Letter Code");
        AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter G/L Account");
        exit(AdvanceLetterTemplateCZZ."Advance Letter G/L Account");
    end;
#endif

    procedure PostAdvancePaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; PostingDate: Date)
    begin
        PostAdvancePaymentVAT(SalesAdvLetterEntryCZZ, PostingDate, true);
    end;

    procedure PostAdvancePaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; PostingDate: Date; Silently: Boolean)
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeries: Codeunit "No. Series";
        VATDocumentCZZ: Page "VAT Document CZZ";
        DocumentNo: Code[20];
        IsHandled: Boolean;
        VATDate: Date;
    begin
        OnBeforePostPaymentVAT(SalesAdvLetterEntryCZZ, PostingDate, IsHandled);
        if IsHandled then
            exit;

        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        if SalesAdvLetterHeaderCZZ."Amount Including VAT" = 0 then
            exit;

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if not SalesAdvLetterEntryCZZ2.IsEmpty() then
            Error(VATDocumentExistsErr);

        if PostingDate = 0D then
            PostingDate := SalesAdvLetterEntryCZZ."Posting Date";
        VATDate := SalesAdvLetterEntryCZZ."VAT Date";

        CustLedgerEntry.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
        AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter Invoice Nos.");

        InitVATAmountLine(TempAdvancePostingBufferCZZ, SalesAdvLetterEntryCZZ."Sales Adv. Letter No.", SalesAdvLetterEntryCZZ.Amount, SalesAdvLetterEntryCZZ."Currency Factor");

        TempAdvancePostingBufferCZZ.Reset();
        TempAdvancePostingBufferCZZ.SetRange("Auxiliary Entry", false);
        if TempAdvancePostingBufferCZZ.IsEmpty() then
            DocumentNo := SalesAdvLetterHeaderCZZ."No.";
        TempAdvancePostingBufferCZZ.Reset();

        if Silently or not GuiAllowed then begin
            if DocumentNo = '' then
                DocumentNo := NoSeries.GetNextNo(AdvanceLetterTemplateCZZ."Advance Letter Invoice Nos.", PostingDate);
            TempAdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        end else begin
            VATDocumentCZZ.InitSalesDocument(AdvanceLetterTemplateCZZ."Advance Letter Invoice Nos.", DocumentNo,
              SalesAdvLetterHeaderCZZ."Document Date", PostingDate, VATDate, 0D,
              SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor", '', TempAdvancePostingBufferCZZ);
            if VATDocumentCZZ.RunModal() <> Action::OK then
                exit;

            VATDocumentCZZ.SaveNoSeries();
            VATDocumentCZZ.GetDocument(DocumentNo, PostingDate, VATDate, TempAdvancePostingBufferCZZ);
            if (DocumentNo = '') or (PostingDate = 0D) or (VATDate = 0D) then
                Error(DocumentNoOrDatesEmptyErr);
        end;

        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Document Type" := Enum::"Gen. Journal Document Type"::Invoice;
        AdvancePostingParametersCZZ."Document No." := DocumentNo;
        AdvancePostingParametersCZZ."Posting Description" := SalesAdvLetterHeaderCZZ."Posting Description";
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."VAT Date" := VATDate;
        AdvancePostingParametersCZZ."Original Document VAT Date" := VATDate;
        AdvancePostingParametersCZZ."Currency Code" := SalesAdvLetterEntryCZZ."Currency Code";
        AdvancePostingParametersCZZ."Currency Factor" := SalesAdvLetterEntryCZZ."Currency Factor";

        SalesAdvLetterPostCZZ.PostAdvancePaymentVAT(
            SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure InitVATAmountLine(var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; AdvanceNo: Code[20]; Amount: Decimal; CurrencyFactor: Decimal)
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        AmountRemainder: Decimal;
        Coeff: Decimal;
    begin
        AdvancePostingBufferCZZ.Reset();
        AdvancePostingBufferCZZ.DeleteAll();

        if Amount = 0 then
            exit;

        SalesAdvLetterHeaderCZZ.Get(AdvanceNo);
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");

        Coeff := Amount / SalesAdvLetterHeaderCZZ."Amount Including VAT";
        AmountRemainder := 0;

        BufferAdvanceLines(SalesAdvLetterHeaderCZZ, TempAdvancePostingBufferCZZ);
        TempAdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        if TempAdvancePostingBufferCZZ.FindSet() then
            repeat
                AdvancePostingBufferCZZ.Init();
                AdvancePostingBufferCZZ := TempAdvancePostingBufferCZZ;
                AmountRemainder += AdvancePostingBufferCZZ.Amount * Coeff;
                AdvancePostingBufferCZZ.Amount := AmountRemainder;
                AdvancePostingBufferCZZ.UpdateVATAmounts();
                AdvancePostingBufferCZZ.UpdateLCYAmounts(SalesAdvLetterHeaderCZZ."Currency Code", CurrencyFactor);
                AdvancePostingBufferCZZ.Insert();
                AmountRemainder -= AdvancePostingBufferCZZ.Amount;
            until TempAdvancePostingBufferCZZ.Next() = 0;
    end;

    procedure PostAndSendAdvancePaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.TestField("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        PostAdvancePaymentVAT(SalesAdvLetterEntryCZZ, 0D, false);

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ2.EmailRecords(true);
    end;

    local procedure BufferAdvanceLines(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    var
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
    begin
        AdvancePostingBufferCZZ.Reset();
        AdvancePostingBufferCZZ.DeleteAll();

        AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");

        SalesAdvLetterLineCZZ.SetRange("Document No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterLineCZZ.SetFilter(Amount, '<>0');
        if SalesAdvLetterLineCZZ.FindSet() then
            repeat
                TempAdvancePostingBufferCZZ.PrepareForSalesAdvLetterLine(SalesAdvLetterLineCZZ);
                AdvancePostingBufferCZZ.Update(TempAdvancePostingBufferCZZ);

                if (not AdvanceLetterTemplateCZZ."Post VAT Doc. for Rev. Charge") and
                   (AdvancePostingBufferCZZ."VAT Calculation Type" = "Tax Calculation Type"::"Reverse Charge VAT")
                then begin
                    AdvancePostingBufferCZZ."Auxiliary Entry" := true;
                    AdvancePostingBufferCZZ.Modify();
                end;
            until SalesAdvLetterLineCZZ.Next() = 0;
    end;

    procedure LinkAdvanceLetter(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; BillToCustomerNo: Code[20]; PostingDate: Date; CurrencyCode: Code[10])
    var
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        AdvanceLetterApplEditPageCZZ: Page "Advance Letter Appl. Edit CZZ";
        ModifyRecord: Boolean;
    begin
        AdvanceLetterApplEditPageCZZ.InitializeSales(AdvLetterUsageDocTypeCZZ, DocumentNo, BillToCustomerNo, PostingDate, CurrencyCode);
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
                    AdvanceLetterApplicationCZZ."Job No." := TempAdvanceLetterApplicationCZZ."Job No.";
                    AdvanceLetterApplicationCZZ."Job Task No." := TempAdvanceLetterApplicationCZZ."Job Task No.";
                    AdvanceLetterApplicationCZZ.Amount := TempAdvanceLetterApplicationCZZ.Amount;
                    AdvanceLetterApplicationCZZ."Amount (LCY)" := TempAdvanceLetterApplicationCZZ."Amount (LCY)";
                    OnLinkAdvanceLetterOnBeforeInsertAdvanceLetterApplication(AdvanceLetterApplicationCZZ, TempAdvanceLetterApplicationCZZ);
                    AdvanceLetterApplicationCZZ.Insert();
                until TempAdvanceLetterApplicationCZZ.Next() = 0;
        end;
    end;

    procedure UnlinkAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        PostingDate: Date;
    begin
        CustLedgerEntry.TestField("Advance Letter No. CZZ");

        PostingDate := CustLedgerEntry."Posting Date";
        if not GetPostingDateUI(PostingDate) then
            exit;
        if PostingDate = 0D then
            Error(PostingDateEmptyErr);

        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", CustLedgerEntry."Advance Letter No. CZZ");
        SalesAdvLetterEntryCZZ1.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ1.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
        if SalesAdvLetterEntryCZZ1.FindSet() then
            repeat
                SalesAdvLetterEntryCZZ2 := SalesAdvLetterEntryCZZ1;
                UnlinkAdvancePayment(SalesAdvLetterEntryCZZ2, PostingDate);
            until SalesAdvLetterEntryCZZ1.Next() = 0;
    end;

    procedure UnlinkAdvancePayment(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PostingDate: Date;
    begin
        CustLedgerEntry.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
        PostingDate := CustLedgerEntry."Posting Date";
        if not GetPostingDateUI(PostingDate) then
            exit;
        if PostingDate = 0D then
            Error(PostingDateEmptyErr);
        UnlinkAdvancePayment(SalesAdvLetterEntryCZZ, PostingDate);
    end;

    procedure UnlinkAdvancePayment(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; PostingDate: Date)
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        UsedOnDocument: Text;
        IsHandled: Boolean;
        UnlinkIsNotPossibleErr: Label 'Unlink is not possible, because %1 entry exists.', Comment = '%1 = Entry type';
        UsedOnDocumentQst: Label 'Advance is used on document(s) %1.\Continue?', Comment = '%1 = Advance No. list';
    begin
        IsHandled := false;
        OnBeforeUnlinkAdvancePayment(SalesAdvLetterEntryCZZ, PostingDate, IsHandled);
        if IsHandled then
            exit;
        SalesAdvLetterEntryCZZ.TestField("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if SalesAdvLetterEntryCZZ2.FindFirst() then
            Error(UnlinkIsNotPossibleErr, SalesAdvLetterEntryCZZ2."Entry Type");

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
        AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
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

        SalesAdvLetterPostCZZ.PostAdvancePaymentUnlinking(SalesAdvLetterEntryCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; var SalesInvoiceHeader: Record "Sales Invoice Header"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
    begin
        AdvancePostingParametersCZZ."Temporary Entries Only" := Preview;

        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
        SalesAdvLetterPostCZZ.PostAdvancePaymentUsage(SalesInvoiceHeader, AdvanceLetterApplicationCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure CorrectDocumentAfterPaymentUsage(DocumentNo: Code[20]; var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        FirstVATPostingSetup: Record "VAT Posting Setup";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerPostingGroup: Record "Customer Posting Group";
        GenJournalLine: Record "Gen. Journal Line";
        VATBaseCorr, VATAmountCorr : Decimal;
        CorrectLineDescriptionTxt: Label 'Advance VAT Correction';
        IsHandled: Boolean;
    begin
        OnBeforeCorrectDocumentAfterPaymentUsage(DocumentNo, CustLedgerEntry, GenJnlPostLine, IsHandled);
        if IsHandled then
            exit;

        if DocumentNo = '' then
            exit;

        SalesInvoiceHeader.SetAutoCalcFields("Amount Including VAT");
        SalesInvoiceHeader.Get(DocumentNo);
        if SalesInvoiceHeader."Currency Code" <> '' then
            exit;

        SalesAdvLetterEntryCZZ.SetRange("Document No.", DocumentNo);
        SalesAdvLetterEntryCZZ.SetRange(SalesAdvLetterEntryCZZ."Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if SalesAdvLetterEntryCZZ.IsEmpty() then
            exit;

        SalesAdvLetterEntryCZZ.CalcSums(Amount);

        if SalesAdvLetterEntryCZZ.Amount <> SalesInvoiceHeader."Amount Including VAT" then
            exit;

        VATEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        VATEntry.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
        // check whether multiple VAT rates is used
        VATEntry.FindFirst();
        FirstVATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
        VATEntry.SetFilter("VAT Prod. Posting Group", '<>%1', VATEntry."VAT Prod. Posting Group");
        if VATEntry.FindSet() then
            repeat
                VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
                // correction should applied only when one VAT rate is used
                if FirstVATPostingSetup."VAT %" <> VATPostingSetup."VAT %" then
                    exit;
            until VATEntry.Next() = 0;
        VATEntry.SetRange("VAT Prod. Posting Group");
        VATEntry.CalcSums(Base, Amount);
        VATBaseCorr := VATEntry.Base;
        VATAmountCorr := VATEntry.Amount;
        if (VATBaseCorr <> -VATAmountCorr) or (VATBaseCorr = 0) or (Abs(VATBaseCorr) > 1) then
            exit;

#pragma warning disable AA0210
        VATEntry.SetFilter(Amount, '<>0');
#pragma warning restore AA0210
        VATEntry.FindFirst();
        VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");

        CustomerPostingGroup.Get(SalesInvoiceHeader."Customer Posting Group");
        CustomerPostingGroup.TestField("Invoice Rounding Account");

        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindLast();

        SalesInvoiceLine.Init();
        SalesInvoiceLine."Line No." += 10000;
        SalesInvoiceLine."Posting Date" := SalesInvoiceHeader."Posting Date";
        SalesInvoiceLine."Sell-to Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
        SalesInvoiceLine."Bill-to Customer No." := SalesInvoiceHeader."Bill-to Customer No.";
        SalesInvoiceLine."Gen. Bus. Posting Group" := SalesInvoiceHeader."Gen. Bus. Posting Group";
        SalesInvoiceLine."Responsibility Center" := SalesInvoiceHeader."Responsibility Center";
        SalesInvoiceLine.Type := SalesInvoiceLine.Type::"G/L Account";
        SalesInvoiceLine."No." := CustomerPostingGroup."Invoice Rounding Account";
        SalesInvoiceLine."Qty. per Unit of Measure" := 1;
        SalesInvoiceLine.Description := CorrectLineDescriptionTxt;
        SalesInvoiceLine."VAT Bus. Posting Group" := VATEntry."VAT Bus. Posting Group";
        SalesInvoiceLine."VAT Prod. Posting Group" := VATEntry."VAT Prod. Posting Group";
        SalesInvoiceLine."VAT %" := VATPostingSetup."VAT %";
        SalesInvoiceLine."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
        SalesInvoiceLine."VAT Identifier" := VATPostingSetup."VAT Identifier";
        SalesInvoiceLine."VAT Clause Code" := VATPostingSetup."VAT Clause Code";
        SalesInvoiceLine."Tax Area Code" := VATEntry."Tax Area Code";
        SalesInvoiceLine."Tax Liable" := VATEntry."Tax Liable";
        SalesInvoiceLine.Amount := VATBaseCorr;
        SalesInvoiceLine."Amount Including VAT" := 0;
        SalesInvoiceLine."VAT Base Amount" := VATBaseCorr;
        if SalesInvoiceHeader."Prices Including VAT" then
            SalesInvoiceLine."Line Amount" := 0
        else
            SalesInvoiceLine."Line Amount" := VATBaseCorr;
        SalesInvoiceLine."VAT Difference" := VATAmountCorr - Round(SalesInvoiceLine.Amount * SalesInvoiceLine."VAT %" / (100 + SalesInvoiceLine."VAT %"));
        SalesInvoiceLine.Insert();

        InitGenJnlLineFromCustLedgEntry(CustLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::Invoice);
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Account No." := SalesInvoiceLine."No.";
        GenJournalLine.Description := CorrectLineDescriptionTxt;
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
        GenJournalLine."VAT Calculation Type" := SalesInvoiceLine."VAT Calculation Type";
        GenJournalLine."VAT Bus. Posting Group" := SalesInvoiceLine."VAT Bus. Posting Group";
        GenJournalLine.Validate("VAT Prod. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group");
        GenJournalLine."Bill-to/Pay-to No." := SalesInvoiceHeader."Bill-to Customer No.";
        GenJournalLine."Country/Region Code" := SalesInvoiceHeader."Bill-to Country/Region Code";
        GenJournalLine."VAT Registration No." := SalesInvoiceHeader."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := SalesInvoiceHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := SalesInvoiceHeader."Tax Registration No. CZL";
        GenJournalLine.Amount := 0;
        GenJournalLine."VAT Amount" := -VATAmountCorr;
        GenJournalLine."VAT Base Amount" := -VATBaseCorr;
        GenJournalLine."VAT Difference" := SalesInvoiceLine."VAT Difference";

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    procedure PostAdvancePaymentUsageVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CurrencyFactor: Decimal;
    begin
        SalesAdvLetterEntryCZZ.TestField("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        if not SalesAdvLetterEntryCZZ2.IsEmpty() then
            Error(VATDocumentExistsErr);

        SalesAdvLetterEntryCZZ2.Get(SalesAdvLetterEntryCZZ."Related Entry");
        SalesAdvLetterEntryCZZ2.TestField("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::Payment);

        CustLedgerEntry.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");

        if SalesInvoiceHeader.Get(CustLedgerEntry."Document No.") then
            CurrencyFactor := SalesInvoiceHeader."VAT Currency Factor CZL"
        else
            CurrencyFactor := CustLedgerEntry."Original Currency Factor";

        SalesAdvLetterPostCZZ.BufferAdvanceVATLines(SalesAdvLetterEntryCZZ2, TempAdvancePostingBufferCZZ, 0D);
        SalesAdvLetterPostCZZ.SuggestUsageVAT(SalesAdvLetterEntryCZZ2, TempAdvancePostingBufferCZZ, CustLedgerEntry."Document No.",
            SalesAdvLetterEntryCZZ.Amount, CurrencyFactor, false);

        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ.CopyFromCustLedgerEntry(CustLedgerEntry);
        AdvancePostingParametersCZZ."Document Type" := "Gen. Journal Document Type"::Invoice;
        AdvancePostingParametersCZZ."Original Document VAT Date" := CustLedgerEntry."VAT Date CZL";
        AdvancePostingParametersCZZ."Currency Code" := SalesAdvLetterEntryCZZ2."Currency Code";
        AdvancePostingParametersCZZ."Currency Factor" := CurrencyFactor;

        SalesAdvLetterPostCZZ.PostAdvancePaymentUsageVAT(
            SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure InitGenJnlLineFromCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; GenJournalDocumentType: Enum "Gen. Journal Document Type")
    begin
        GenJournalLine.InitNewLine(
            CustLedgerEntry."Posting Date", CustLedgerEntry."Document Date", CustLedgerEntry."VAT Date CZL", CustLedgerEntry.Description,
            CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code",
            CustLedgerEntry."Dimension Set ID", CustLedgerEntry."Reason Code");
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine.CopyDocumentFields(GenJournalDocumentType, CustLedgerEntry."Document No.", '', CustLedgerEntry."Source Code", '');
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
        GenJournalLine."Account No." := CustLedgerEntry."Customer No.";
        GenJournalLine."Source Currency Code" := CustLedgerEntry."Currency Code";
        GenJournalLine."Currency Factor" := CustLedgerEntry."Original Currency Factor";
        GenJournalLine."Sell-to/Buy-from No." := CustLedgerEntry."Sell-to Customer No.";
        GenJournalLine."Bill-to/Pay-to No." := CustLedgerEntry."Customer No.";
        GenJournalLine."IC Partner Code" := CustLedgerEntry."IC Partner Code";
        GenJournalLine."Salespers./Purch. Code" := CustLedgerEntry."Salesperson Code";
        GenJournalLine."On Hold" := CustLedgerEntry."On Hold";
        GenJournalLine."Posting Group" := CustLedgerEntry."Customer Posting Group";
        GenJournalLine.Validate("VAT Reporting Date", CustLedgerEntry."VAT Date CZL");
        GenJournalLine."System-Created Entry" := true;
    end;

    procedure GetRemAmtSalAdvPayment(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; BalanceAtDate: Date): Decimal
    var
        SalesAdvLetterEntry2: Record "Sales Adv. Letter Entry CZZ";
    begin
        if (SalesAdvLetterEntryCZZ."Posting Date" > BalanceAtDate) and (BalanceAtDate <> 0D) then
            exit(0);

        SalesAdvLetterEntry2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntry2.SetRange(Cancelled, false);
        SalesAdvLetterEntry2.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntry2."Entry Type"::Payment,
            SalesAdvLetterEntry2."Entry Type"::Usage, SalesAdvLetterEntry2."Entry Type"::Close);
        SalesAdvLetterEntry2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            SalesAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        SalesAdvLetterEntry2.CalcSums(Amount);
        exit(-SalesAdvLetterEntryCZZ.Amount - SalesAdvLetterEntry2.Amount);
    end;

    procedure GetRemAmtLCYSalAdvPayment(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; BalanceAtDate: Date): Decimal
    var
        SalesAdvLetterEntry2: Record "Sales Adv. Letter Entry CZZ";
    begin
        if (SalesAdvLetterEntryCZZ."Posting Date" > BalanceAtDate) and (BalanceAtDate <> 0D) then
            exit(0);

        SalesAdvLetterEntry2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntry2.SetRange(Cancelled, false);
        SalesAdvLetterEntry2.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntry2."Entry Type"::Payment,
            SalesAdvLetterEntry2."Entry Type"::Usage, SalesAdvLetterEntry2."Entry Type"::Close);
        SalesAdvLetterEntry2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            SalesAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        SalesAdvLetterEntry2.CalcSums("Amount (LCY)");
        exit(-SalesAdvLetterEntryCZZ."Amount (LCY)" - SalesAdvLetterEntry2."Amount (LCY)");
    end;

    procedure GetRemAmtLCYVATAdjust(var AmountLCY: Decimal; var VATAmountLCY: Decimal; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; BalanceAtDate: Date; VATBusPostGr: Code[20]; VATProdPostGr: Code[20])
    var
        SalesAdvLetterEntry2: Record "Sales Adv. Letter Entry CZZ";
        AmountLCY2, VATAmountLCY2 : Decimal;
    begin
        SalesAdvLetterEntry2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntry2.SetRange(Cancelled, false);
        SalesAdvLetterEntry2.SetRange("Entry Type", SalesAdvLetterEntry2."Entry Type"::"VAT Adjustment");
        SalesAdvLetterEntry2.SetRange("VAT Bus. Posting Group", VATBusPostGr);
        SalesAdvLetterEntry2.SetRange("VAT Prod. Posting Group", VATProdPostGr);
        SalesAdvLetterEntry2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            SalesAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        SalesAdvLetterEntry2.CalcSums("Amount (LCY)", "VAT Amount (LCY)");
        AmountLCY := SalesAdvLetterEntry2."Amount (LCY)";
        VATAmountLCY := SalesAdvLetterEntry2."VAT Amount (LCY)";

        SalesAdvLetterEntry2.SetRange("VAT Bus. Posting Group");
        SalesAdvLetterEntry2.SetRange("VAT Prod. Posting Group");
        SalesAdvLetterEntry2.SetRange("Entry Type", SalesAdvLetterEntry2."Entry Type"::Usage);
        if SalesAdvLetterEntry2.FindSet() then
            repeat
                GetRemAmtLCYVATAdjust(AmountLCY2, VATAmountLCY2, SalesAdvLetterEntry2, BalanceAtDate, VATBusPostGr, VATProdPostGr);
                AmountLCY += AmountLCY2;
                VATAmountLCY += VATAmountLCY2;
            until SalesAdvLetterEntry2.Next() = 0
    end;

    procedure CloseAdvanceLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        AdvPaymentCloseDialogCZZ: Page "Adv. Payment Close Dialog CZZ";
        PostingDate: Date;
        VATDate: Date;
        CurrencyFactor: Decimal;
    begin
        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::Closed then
            exit;

        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::New then begin
            SalesAdvLetterHeaderCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ.Status::Closed);
            exit;
        end;

        AdvPaymentCloseDialogCZZ.SetValues(WorkDate(), WorkDate(), SalesAdvLetterHeaderCZZ."Currency Code", 0, '', false);
        if AdvPaymentCloseDialogCZZ.RunModal() <> Action::OK then
            exit;

        AdvPaymentCloseDialogCZZ.GetValues(PostingDate, VATDate, CurrencyFactor);
        if (PostingDate = 0D) or (VATDate = 0D) then
            Error(DateEmptyErr);

        CloseAdvanceLetter(SalesAdvLetterHeaderCZZ, PostingDate, VATDate, CurrencyFactor);
    end;

    procedure CloseAdvanceLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; PostingDate: Date; VATDate: Date; CurrencyFactor: Decimal)
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::Closed then
            exit;

        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::New then begin
            SalesAdvLetterHeaderCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ.Status::Closed);
            exit;
        end;

        if PostingDate = 0D then
            PostingDate := WorkDate();
        if VATDate = 0D then
            VATDate := WorkDate();
        if CurrencyFactor = 0 then
            CurrencyFactor := CurrencyExchangeRate.ExchangeRate(PostingDate, SalesAdvLetterHeaderCZZ."Currency Code");

        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."Document Date" := PostingDate;
        AdvancePostingParametersCZZ."VAT Date" := VATDate;
        AdvancePostingParametersCZZ."Currency Code" := SalesAdvLetterHeaderCZZ."Currency Code";
        AdvancePostingParametersCZZ."Currency Factor" := CurrencyFactor;

        SalesAdvLetterPostCZZ.PostAdvanceLetterClosing(SalesAdvLetterHeaderCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure PostAdvanceCreditMemoVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        VATEntry: Record "VAT Entry";
        NoSeries: Codeunit "No. Series";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvPaymentCloseDialog: Page "Adv. Payment Close Dialog CZZ";
        DocumentNo: Code[20];
        SourceCode: Code[10];
        VATDate: Date;
        PostingDate: Date;
        CurrencyFactor: Decimal;
    begin
        SalesAdvLetterEntryCZZ.TestField("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        AdvPaymentCloseDialog.SetValues(SalesAdvLetterEntryCZZ."Posting Date", SalesAdvLetterEntryCZZ."VAT Date", SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor", '', false);
        if AdvPaymentCloseDialog.RunModal() = Action::OK then begin
            AdvPaymentCloseDialog.GetValues(PostingDate, VATDate, CurrencyFactor);
            if (PostingDate = 0D) or (VATDate = 0D) then
                Error(DateEmptyErr);
            OnPostAdvanceCreditMemoVATOnAfterGetValues(SalesAdvLetterEntryCZZ, PostingDate, VATDate);
            if SalesAdvLetterEntryCZZ."Currency Code" = '' then
                CurrencyFactor := 1;

            SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
            SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
            SalesAdvLetterEntryCZZ2.SetRange("Document No.", SalesAdvLetterEntryCZZ."Document No.");
            SalesAdvLetterEntryCZZ2.FindSet();
            repeat
                TempAdvancePostingBufferCZZ2.PrepareForSalesAdvLetterEntry(SalesAdvLetterEntryCZZ2);
                TempAdvancePostingBufferCZZ.Update(TempAdvancePostingBufferCZZ2);
                TempAdvancePostingBufferCZZ.UpdateLCYAmounts(SalesAdvLetterEntryCZZ2."Currency Code", CurrencyFactor);
                TempAdvancePostingBufferCZZ.Modify();
            until SalesAdvLetterEntryCZZ2.Next() = 0;

            SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");

            // find VAT entry of the VAT document due to source code
            SourceCode := '';
            VATEntry.SetRange("Document No.", SalesAdvLetterEntryCZZ."Document No.");
            VATEntry.SetRange("Posting Date", SalesAdvLetterEntryCZZ."Posting Date");
            if VATEntry.FindFirst() then
                SourceCode := VATEntry."Source Code";

            TempAdvancePostingBufferCZZ.Reset();
            TempAdvancePostingBufferCZZ.SetRange("Auxiliary Entry", false);
            if TempAdvancePostingBufferCZZ.IsEmpty() then
                DocumentNo := SalesAdvLetterHeaderCZZ."No.";
            TempAdvancePostingBufferCZZ.Reset();

            if DocumentNo = '' then
                DocumentNo := NoSeries.GetNextNo(AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", WorkDate());

            Clear(AdvancePostingParametersCZZ);
            AdvancePostingParametersCZZ."Document Type" := "Gen. Journal Document Type"::"Credit Memo";
            AdvancePostingParametersCZZ."Document No." := DocumentNo;
            AdvancePostingParametersCZZ."Source Code" := SourceCode;
            AdvancePostingParametersCZZ."Posting Description" := SalesAdvLetterHeaderCZZ."Posting Description";
            AdvancePostingParametersCZZ."Posting Date" := PostingDate;
            AdvancePostingParametersCZZ."Document Date" := PostingDate;
            AdvancePostingParametersCZZ."VAT Date" := VATDate;
            AdvancePostingParametersCZZ."Original Document VAT Date" := VATDate;
            AdvancePostingParametersCZZ."Currency Code" := SalesAdvLetterEntryCZZ."Currency Code";
            AdvancePostingParametersCZZ."Currency Factor" := CurrencyFactor;

            SalesAdvLetterPostCZZ.PostAdvanceCreditMemoVAT(
                SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ, GenJnlPostLine, AdvancePostingParametersCZZ);
        end;
    end;

    procedure PostAdvancePaymentUsagePreview(var SalesHeader: Record "Sales Header"; Amount: Decimal; AmountLCY: Decimal; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
        SalesAdvLetterPostCZZ.PostAdvancePaymentUsageForStatistics(SalesHeader, Amount, AmountLCY, SalesAdvLetterEntryCZZ);
    end;

    procedure UnapplyAdvanceLetter(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        TempSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        ConfirmManagement: Codeunit "Confirm Management";
        AdvLetters: Text;
        UnapplyAdvLetterQst: Label 'Unapply advance letter: %1\Continue?', Comment = '%1 = Advance Letters';
    begin
        SalesAdvLetterEntryCZZ.SetRange(SalesAdvLetterEntryCZZ."Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if not SalesAdvLetterEntryCZZ.FindSet() then
            exit;

        repeat
            if not TempSalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.") then begin
                TempSalesAdvLetterHeaderCZZ."No." := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
                TempSalesAdvLetterHeaderCZZ.Insert();
            end;
        until SalesAdvLetterEntryCZZ.Next() = 0;

        if TempSalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                if AdvLetters <> '' then
                    AdvLetters := AdvLetters + ', ';
                AdvLetters := AdvLetters + TempSalesAdvLetterHeaderCZZ."No.";
            until TempSalesAdvLetterHeaderCZZ.Next() = 0;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(UnapplyAdvLetterQst, AdvLetters), false) then
            exit;

        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Document No." := SalesInvoiceHeader."No.";

        SalesAdvLetterPostCZZ.PostAdvanceLetterUnapplying(SalesInvoiceHeader, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure ApplyAdvanceLetter(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
        ConfirmManagement: Codeunit "Confirm Management";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        ApplyAdvanceLetterQst: Label 'Apply Advance Letter?';
        CannotApplyErr: Label 'You cannot apply more than %1.', Comment = '%1 = Remaining amount to apply';
    begin
        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvanceLetterApplicationCZZ."Document Type"::"Posted Sales Invoice");
        AdvanceLetterApplicationCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        if AdvanceLetterApplicationCZZ.IsEmpty() then
            SalesAdvLetterManagementCZZ.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Posted Sales Invoice", SalesInvoiceHeader."No.", SalesInvoiceHeader."Bill-to Customer No.", SalesInvoiceHeader."Posting Date", SalesInvoiceHeader."Currency Code");

        if AdvanceLetterApplicationCZZ.IsEmpty() then
            exit;

        if not ConfirmManagement.GetResponseOrDefault(ApplyAdvanceLetterQst, false) then
            exit;

        CheckAdvancePayment(AdvanceLetterApplicationCZZ."Document Type"::"Posted Sales Invoice", SalesInvoiceHeader);
        AdvanceLetterApplicationCZZ.CalcSums(Amount);
        CustLedgerEntry.SetCurrentKey("Document No.");
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        CustLedgerEntry.SetRange(Open, true);
        OnApplyAdvanceLetterOnAfterSetCustLedgerEntryFilter(CustLedgerEntry, SalesInvoiceHeader, AdvanceLetterApplicationCZZ);
        CustLedgerEntry.FindLast();
        CustLedgerEntry.CalcFields("Remaining Amount");
        OnApplyAdvanceLetterOnBeforeTestAmount(AdvanceLetterApplicationCZZ, CustLedgerEntry);
        if AdvanceLetterApplicationCZZ.Amount > CustLedgerEntry."Remaining Amount" then
            Error(CannotApplyErr, CustLedgerEntry."Remaining Amount");

        SalesAdvLetterPostCZZ.PostAdvanceLetterApplying(SalesInvoiceHeader, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    procedure CheckAdvancePayment(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentHeader: Variant)
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
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
            AdvLetterUsageDocTypeCZZ::"Posted Sales Invoice":
                begin
                    SalesInvoiceHeader := DocumentHeader;
                    DocumentNo := SalesInvoiceHeader."No.";
                    PostingDate := SalesInvoiceHeader."Posting Date";
                end;
            AdvLetterUsageDocTypeCZZ::"Sales Invoice",
            AdvLetterUsageDocTypeCZZ::"Sales Order":
                begin
                    SalesHeader := DocumentHeader;
                    DocumentNo := SalesHeader."No.";
                    PostingDate := SalesHeader."Posting Date";
                end;
        end;

        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
        if AdvanceLetterApplicationCZZ.FindSet() then
            repeat
                SalesAdvLetterHeaderCZZ.SetAutoCalcFields("To Use");
                SalesAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
                if SalesAdvLetterHeaderCZZ."To Use" < AdvanceLetterApplicationCZZ.Amount then
                    if not ConfirmManagement.GetResponseOrDefault(UsageQst, false) then
                        Error('');
                SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
                SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
                SalesAdvLetterEntryCZZ.SetFilter("Posting Date", '%1..', PostingDate + 1);
                OnCheckAdvancePaymentOnAfterSetFilters(SalesAdvLetterEntryCZZ, AdvanceLetterApplicationCZZ);
                if not SalesAdvLetterEntryCZZ.IsEmpty() then
                    if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(LaterPostingDateQst, AdvanceLetterApplicationCZZ."Advance Letter No.", Format(PostingDate)), false) then
                        Error('');
            until AdvanceLetterApplicationCZZ.Next() = 0;
    end;

    procedure AdjustVATExchangeRate(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; Amount: Decimal; DetEntryNo: Integer; ToDate: Date; DocumentNo: Code[20]; PostDescription: Text[100])
    var
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ3: Record "Sales Adv. Letter Entry CZZ";
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
        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        SalesAdvLetterEntryCZZ2.SetRange("Det. Cust. Ledger Entry No.", DetEntryNo);
        if not SalesAdvLetterEntryCZZ2.IsEmpty() then
            exit;

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");

        SalesAdvLetterPostCZZ.BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, ToDate);
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
                    PostUnrealizedExchangeRate(SalesAdvLetterEntryCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup,
                        TempAdvancePostingBufferCZZ2.Amount, TempAdvancePostingBufferCZZ2."VAT Amount",
                        SalesAdvLetterEntryCZZ."Entry No.", DetEntryNo, DocumentNo, ToDate, ToDate, PostDescription,
                        GenJnlPostLine, false, false, TempAdvancePostingBufferCZZ2."Auxiliary Entry");
                until TempAdvancePostingBufferCZZ2.Next() = 0;

            SalesAdvLetterPostCZZ.BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, 0D);
            TempAdvancePostingBufferCZZ1.CalcSums(Amount);
            TempAdvancePostingBufferCZZ2.CalcSums(Amount);
            if TempAdvancePostingBufferCZZ1.Amount = 0 then
                AmountToDivide := TempAdvancePostingBufferCZZ2.Amount
            else begin
                SalesAdvLetterEntryCZZ2.Reset();
                SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
                SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
                SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
                SalesAdvLetterEntryCZZ2.CalcSums(Amount);
                AmountToDivide := Round(TempAdvancePostingBufferCZZ2.Amount * (VATDocAmtToDate - TempAdvancePostingBufferCZZ1.Amount) / SalesAdvLetterEntryCZZ2.Amount);
            end;

            AmountTotal := 0;
            SalesAdvLetterEntryCZZ2.Reset();
            SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
            SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
            SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::Usage);
            SalesAdvLetterEntryCZZ2.SetFilter("Posting Date", '>%1', ToDate);
            if SalesAdvLetterEntryCZZ2.FindSet() then begin
                repeat
                    SalesAdvLetterEntryCZZ3.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                    SalesAdvLetterEntryCZZ3.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ3.SetRange("Related Entry", SalesAdvLetterEntryCZZ2."Entry No.");
                    SalesAdvLetterEntryCZZ3.SetRange("Entry Type", SalesAdvLetterEntryCZZ3."Entry Type"::"VAT Usage");
                    SalesAdvLetterEntryCZZ3.SetFilter("Posting Date", '>%1', ToDate);
                    SalesAdvLetterEntryCZZ3.CalcSums(Amount);
                    AmountTotal += SalesAdvLetterEntryCZZ3.Amount;
                until SalesAdvLetterEntryCZZ2.Next() = 0;

                Coeff := AmountToDivide / AmountTotal;
                SalesAdvLetterEntryCZZ2.FindSet();
                repeat
                    SalesAdvLetterEntryCZZ3.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                    SalesAdvLetterEntryCZZ3.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ3.SetRange("Related Entry", SalesAdvLetterEntryCZZ2."Entry No.");
                    SalesAdvLetterEntryCZZ3.SetRange("Entry Type", SalesAdvLetterEntryCZZ3."Entry Type"::"VAT Usage");
                    SalesAdvLetterEntryCZZ3.SetFilter("Posting Date", '>%1', ToDate);
                    if SalesAdvLetterEntryCZZ3.FindSet() then
                        repeat
                            AmountToPost := Round(SalesAdvLetterEntryCZZ3.Amount * Coeff);
                            case SalesAdvLetterEntryCZZ3."VAT Calculation Type" of
                                SalesAdvLetterEntryCZZ3."VAT Calculation Type"::"Normal VAT":
                                    VATAmountToPost := Round(AmountToPost * SalesAdvLetterEntryCZZ3."VAT %" / (100 + SalesAdvLetterEntryCZZ3."VAT %"));
                                SalesAdvLetterEntryCZZ3."VAT Calculation Type"::"Reverse Charge VAT":
                                    VATAmountToPost := 0;
                            end;

                            VATPostingSetup.Get(SalesAdvLetterEntryCZZ3."VAT Bus. Posting Group", SalesAdvLetterEntryCZZ3."VAT Prod. Posting Group");
                            PostUnrealizedExchangeRate(SalesAdvLetterEntryCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup,
                                -AmountToPost, -VATAmountToPost, SalesAdvLetterEntryCZZ2."Entry No.", 0, DocumentNo,
                                SalesAdvLetterEntryCZZ3."Posting Date", SalesAdvLetterEntryCZZ3."VAT Date", PostDescription,
                                GenJnlPostLine, false, false, SalesAdvLetterEntryCZZ3."Auxiliary Entry");
                        until SalesAdvLetterEntryCZZ3.Next() = 0;
                until SalesAdvLetterEntryCZZ2.Next() = 0;
            end;
        end;
    end;

    local procedure PostUnrealizedExchangeRate(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var VATPostingSetup: Record "VAT Posting Setup";
        Amount: Decimal; VATAmount: Decimal; RelatedEntryNo: Integer; RelatedDetEntryNo: Integer; DocumentNo: Code[20]; PostingDate: Date; VATDate: Date; PostDescription: Text[100]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Correction: Boolean; Preview: Boolean; AuxiliaryEntry: Boolean)
    var
        AdvancePostingParametersCZZ: Record "Advance Posting Parameters CZZ";
    begin
        Clear(AdvancePostingParametersCZZ);
        AdvancePostingParametersCZZ."Document No." := DocumentNo;
        AdvancePostingParametersCZZ."Posting Date" := PostingDate;
        AdvancePostingParametersCZZ."VAT Date" := VATDate;
        AdvancePostingParametersCZZ."Posting Description" := PostDescription;
        AdvancePostingParametersCZZ."Temporary Entries Only" := Preview;

        SalesAdvLetterPostCZZ.PostUnrealizedExchangeRate(
            SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup, Amount, VATAmount,
            RelatedEntryNo, RelatedDetEntryNo, Correction, AuxiliaryEntry, GenJnlPostLine, AdvancePostingParametersCZZ);
    end;

    local procedure GetPostingDateUI(var PostingDate: Date): Boolean
    var
        GetPostingDateCZZ: Page "Get Posting Date CZZ";
    begin
        if not GuiAllowed() then
            exit(true);

        GetPostingDateCZZ.SetValues(PostingDate);
        if GetPostingDateCZZ.RunModal() <> Action::OK then
            exit(false);

        GetPostingDateCZZ.GetValues(PostingDate);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertAdvEntry(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var Preview: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertAdvEntry(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var Preview: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateStatus(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; AdvanceLetterDocStatusCZZ: Enum "Advance Letter Doc. Status CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateStatus(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; AdvanceLetterDocStatusCZZ: Enum "Advance Letter Doc. Status CZZ")
    begin
    end;





    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; PostingDate: Date; var IsHandled: Boolean)
    begin
    end;









    [IntegrationEvent(true, false)]
    local procedure OnPostAdvanceCreditMemoVATOnAfterGetValues(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; PostingDate: Date; VATDate: Date)
    begin
    end;


    [IntegrationEvent(true, false)]
    local procedure OnApplyAdvanceLetterOnBeforeTestAmount(var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry")
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




    [IntegrationEvent(true, false)]
    local procedure OnBeforeCorrectDocumentAfterPaymentUsage(DocumentNo: Code[20]; var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var IsHandled: Boolean)
    begin
    end;


    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckAdvancePayment(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentHeader: Variant; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUnlinkAdvancePayment(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; PostingDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckAdvancePaymentOnAfterSetFilters(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnApplyAdvanceLetterOnAfterSetCustLedgerEntryFilter(var CustLedgerEntry: Record "Cust. Ledger Entry"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var AdvanceLetterApplication: Record "Advance Letter Application CZZ")
    begin
    end;
}