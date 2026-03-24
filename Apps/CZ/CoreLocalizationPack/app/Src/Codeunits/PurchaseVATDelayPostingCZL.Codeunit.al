// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Posting;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.Document;

codeunit 11760 "Purchase VAT Delay Posting CZL"
{
    var
        Currency: Record Currency;
        SourceCodeSetup: Record "Source Code Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJnlLineDocType: Enum "Gen. Journal Document Type";
        GenJnlLineDocNo: Code[20];
        GenJnlLineExtDocNo: Code[35];
        GlobalAmountType: Option Base,VAT;

    /// <summary>
    /// Posts the purchase VAT delay entries for a purchase document when the currency factor differs from the VAT currency factor.
    /// This handles the exchange rate difference between the document currency factor and the VAT currency factor
    /// by posting corrective VAT entries to the purchase VAT currency exchange account.
    /// </summary>
    /// <param name="GenJnlLine">The general journal line used to retrieve document type, document number, and external document number.</param>
    /// <param name="TempInvoicePostingBuffer">The invoice posting buffer containing VAT calculation type, amounts, and posting group information.</param>
    /// <param name="PurchHeader">The purchase header containing currency codes, currency factors, and posting information.</param>
    /// <param name="GenJnlPostLine">The general journal post line codeunit used to post the generated journal lines.</param>
    procedure PostPurchaseVATDelay(var GenJnlLine: Record "Gen. Journal Line"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; PurchHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        RecalcFactor: Decimal;
    begin
        if (PurchHeader."Currency Code" <> '') and (PurchHeader."Currency Factor" <> PurchHeader."VAT Currency Factor CZL") and
           ((TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Reverse Charge VAT") or
            (TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Normal VAT"))
        then begin
            VATPostingSetup.Get(TempInvoicePostingBuffer."VAT Bus. Posting Group", TempInvoicePostingBuffer."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Purch. VAT Curr. Exch. Acc CZL");
            SourceCodeSetup.Get();
            SourceCodeSetup.TestField("Purchase VAT Delay CZL");
            GenJnlLineDocType := GenJnlLine."Document Type";
            GenJnlLineDocNo := GenJnlLine."Document No.";
            GenJnlLineExtDocNo := GenJnlLine."External Document No.";

            RecalcFactor := 1;
            if PurchHeader."VAT Currency Factor CZL" <> 0 then
                RecalcFactor := PurchHeader."Currency Factor" / PurchHeader."VAT Currency Factor CZL";

            PostVATDelay(PurchHeader, TempInvoicePostingBuffer, -1, 1, PurchHeader."Currency Factor", true, GenJnlPostLine);
            PostVATDelay(PurchHeader, TempInvoicePostingBuffer, 1, RecalcFactor, PurchHeader."VAT Currency Factor CZL", false, GenJnlPostLine);
            if TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Normal VAT" then begin
                PostVATDelayDifference(PurchHeader, TempInvoicePostingBuffer, GlobalAmountType::Base, RecalcFactor, GenJnlPostLine);
                PostVATDelayDifference(PurchHeader, TempInvoicePostingBuffer, GlobalAmountType::VAT, RecalcFactor, GenJnlPostLine);
            end;
        end;
    end;

    local procedure PostVATDelay(PurchaseHeader: Record "Purchase Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; Sign: Integer; RecalcFactor: Decimal; CurrFactor: Decimal; IsCorrection: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GetCurrency(PurchaseHeader."Currency Code");
        if RecalcFactor = 0 then
            RecalcFactor := 1;

        InitGenJournalLine(PurchaseHeader, TempInvoicePostingBuffer, GenJournalLine);

        GenJournalLine."Currency Factor" := CurrFactor;
        GenJournalLine.Quantity := Sign * GenJournalLine.Quantity;
        GenJournalLine.Amount :=
            Sign * Round(TempInvoicePostingBuffer.Amount * RecalcFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Amount" :=
            Sign * Round(TempInvoicePostingBuffer."VAT Amount" * RecalcFactor, Currency."Amount Rounding Precision");
        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount;
        GenJournalLine."VAT Difference" :=
            Sign * Round(TempInvoicePostingBuffer."VAT Difference" * RecalcFactor, Currency."Amount Rounding Precision");
        GenJournalLine."Non-Deductible VAT %" := TempInvoicePostingBuffer."Non-Deductible VAT %";
        GenJournalLine."Non-Deductible VAT Base LCY" :=
            Sign * Round(TempInvoicePostingBuffer."Non-Deductible VAT Base" * RecalcFactor, Currency."Amount Rounding Precision");
        GenJournalLine."Non-Deductible VAT Amount LCY" :=
            Sign * Round(TempInvoicePostingBuffer."Non-Deductible VAT Amount" * RecalcFactor, Currency."Amount Rounding Precision");
        GenJournalLine."Non-Deductible VAT Diff." :=
            Sign * Round(TempInvoicePostingBuffer."Non-Deductible VAT Diff." * RecalcFactor, Currency."Amount Rounding Precision");

        GenJournalLine.Correction := TempInvoicePostingBuffer."Correction CZL" xor IsCorrection;
        GenJournalLine."VAT Bus. Posting Group" := TempInvoicePostingBuffer."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := TempInvoicePostingBuffer."VAT Prod. Posting Group";
        GenJournalLine."Gen. Bus. Posting Group" := TempInvoicePostingBuffer."Gen. Bus. Posting Group";
        GenJournalLine."Gen. Prod. Posting Group" := TempInvoicePostingBuffer."Gen. Prod. Posting Group";
        GenJournalLine."EU 3-Party Trade" := PurchaseHeader."EU 3 Party Trade";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := PurchaseHeader."EU 3-Party Intermed. Role CZL";

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure PostVATDelayDifference(PurchaseHeader: Record "Purchase Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; AmountType: Option Base,VAT; RecalcFactor: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Amount: Decimal;
    begin
        GetCurrency(PurchaseHeader."Currency Code");
        if RecalcFactor = 0 then
            RecalcFactor := 1;

        case AmountType of
            AmountType::Base:
                Amount := TempInvoicePostingBuffer.Amount + TempInvoicePostingBuffer."Non-Deductible VAT Amount";
            AmountType::VAT:
                Amount := TempInvoicePostingBuffer."VAT Amount" - TempInvoicePostingBuffer."Non-Deductible VAT Amount";
        end;

        InitGenJournalLine(PurchaseHeader, TempInvoicePostingBuffer, GenJournalLine);
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::" ";
        if AmountType = AmountType::VAT then
            if Amount < 0 then
                GenJournalLine."Account No." := Currency."Realized Gains Acc."
            else
                GenJournalLine."Account No." := Currency."Realized Losses Acc.";
        GenJournalLine.Amount := Amount - Round(Amount * RecalcFactor, Currency."Amount Rounding Precision");

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure InitGenJournalLine(PurchaseHeader: Record "Purchase Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Init();
        GenJournalLine."Document Type" := GenJnlLineDocType;
        GenJournalLine."Document No." := GenJnlLineDocNo;
        GenJournalLine."External Document No." := GenJnlLineExtDocNo;
        GenJournalLine."Account No." := VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
        if TempInvoicePostingBuffer."VAT Calculation Type" = TempInvoicePostingBuffer."VAT Calculation Type"::"Reverse Charge VAT" then
            GenJournalLine."Bal. Account No." := VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
        GenJournalLine."Posting Date" := PurchaseHeader."Posting Date";
        GenJournalLine."Document Date" := PurchaseHeader."Document Date";
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
        GenJournalLine."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
        GenJournalLine.Description := PurchaseHeader."Posting Description";
        GenJournalLine."Reason Code" := PurchaseHeader."Reason Code";
        GenJournalLine."System-Created Entry" := TempInvoicePostingBuffer."System-Created Entry";
        GenJournalLine."Source Currency Code" := PurchaseHeader."Currency Code";
        GenJournalLine.Correction := TempInvoicePostingBuffer."Correction CZL";
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
        GenJournalLine."Tax Area Code" := TempInvoicePostingBuffer."Tax Area Code";
        GenJournalLine."Tax Liable" := TempInvoicePostingBuffer."Tax Liable";
        GenJournalLine."Tax Group Code" := TempInvoicePostingBuffer."Tax Group Code";
        GenJournalLine."Use Tax" := TempInvoicePostingBuffer."Use Tax";
        GenJournalLine."VAT Calculation Type" := TempInvoicePostingBuffer."VAT Calculation Type";
        GenJournalLine."VAT Base Discount %" := PurchaseHeader."VAT Base Discount %";
        GenJournalLine."VAT Posting" := GenJournalLine."VAT Posting"::"Manual VAT Entry";
        GenJournalLine."Shortcut Dimension 1 Code" := TempInvoicePostingBuffer."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TempInvoicePostingBuffer."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TempInvoicePostingBuffer."Dimension Set ID";
        GenJournalLine."Job No." := TempInvoicePostingBuffer."Job No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Purchase VAT Delay CZL";
        GenJournalLine."Bill-to/Pay-to No." := PurchaseHeader."Pay-to Vendor No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Vendor;
        GenJournalLine."Source No." := PurchaseHeader."Pay-to Vendor No.";
        GenJournalLine."Posting No. Series" := PurchaseHeader."Posting No. Series";
        GenJournalLine."Country/Region Code" := PurchaseHeader."VAT Country/Region Code";
        GenJournalLine."VAT Registration No." := PurchaseHeader."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := PurchaseHeader."Registration No. CZL";
        GenJournalLine.Quantity := TempInvoicePostingBuffer.Quantity;
        GenJournalLine."VAT Delay CZL" := true;
        OnAfterInitGenJournalLine(PurchaseHeader, TempInvoicePostingBuffer, GenJournalLine);
    end;

    local procedure GetCurrency(CurrencyCode: Code[10])
    begin
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitGenJournalLine(PurchaseHeader: Record "Purchase Header"; TempInvoicePostingBuffer: Record "Invoice Posting Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}