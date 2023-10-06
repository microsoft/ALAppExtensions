// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.ReturnSettlement;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Document;
using Microsoft.Sales.Receivables;
using Microsoft.Service.Document;

codeunit 18433 "GST Application Library"
{
    var
        ApplyCurrencyFacInvoice: Boolean;
        AccountingPeriodErr: Label 'GST Accounting Period does not exist for the given Date %1.', Comment = '%1  = Posting Date';
        PeriodClosedErr: Label 'Accounting Period has been closed till %1, Document Posting Date must be greater than or equal to %2.', Comment = '%1 = Date, %2 = Posting Date';
        EarlierPostingDateErr: Label 'You cannot apply and post an entry to an entry with an earlier posting date.\\Instead, post the document of type %1 with the number %2 and then apply it to the document of type %3 with the number %4.', Comment = '%1 = Document Type, %2 = Document No., %3 = Payment, %4 = Payment Document';
        UpdateGSTNosErr: Label 'Please Update GST Registration No. for Document No. %1 through batch first, then proceed for application.', Comment = '%1 = Document No';
        GSTInvoiceLiabilityErr: Label 'Cr. & Libty. Adjustment Type should be Liability Reverse or Blank.';
        NoInvoiceGSTErr: Label 'There is no Invoice GST Amount in Document %1, for GST Group Code %2.', Comment = '%1 = Document No., %2 = GST Group Code';
        MismatchHSNErr: Label 'There is mismatch in GST component of Payment and Invoice document, Payment Document No is %1 Invoice Document No %2', Comment = '%1 = Payment Document No, %2 = Invoice Document No';
        GSTGroupAmountErr: Label 'Available Amount in Document Type %1 Document No %2 GST Group Code %3  is Amount %4, and Payment Remaining Amount %5.', Comment = '%1 = Document Type, %2 = Document No., %3 = GST Group Code, %4 = Amount, %5 = Payment Amount';
        GSTGroupAmountJnlErr: Label 'Available Amount in Document Type %1 Document No %2 GST Group Code %3  is Amount (LCY) %4, and Payment Applied Amount (LCY) %5.', Comment = '%1 = Document Type, %2 = Document No., %3 = GST Group Code, %4 = Amount, %5 = Payment Amount';

    procedure FillAppBufferInvoiceOffline(
        GenJournalLine: Record "Gen. Journal Line";
        TransactionType: Enum "Detail Ledger Transaction Type";
        InvoiceDocNo: Code[20];
        AccountNo: Code[20];
        PaymentDocNo: Code[20];
        TDSTCSAmount: Decimal;
        PaymentCurrFactor: Decimal)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTApplicationBufferStage: Record "GST Application Buffer";
        GSTApplicationBuff: Record "GST Application Buffer";
        DocTransType: Enum "Transaction Type Enum";
        CurrencyFactor: Decimal;
    begin
        DeleteInvoiceApplicationBufferOffline(TransactionType, AccountNo, GSTApplicationBuff."Original Document Type"::Invoice, InvoiceDocNo);
        DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Source No.", "Document Type", "Document No.", "GST Group Code");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", TransactionType);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");

        case TransactionType of
            TransactionType::Purchase:
                DetailedGSTLedgerEntry.SetRange("Source Type", DetailedGSTLedgerEntry."Source Type"::Vendor);
            TransactionType::Sales:
                DetailedGSTLedgerEntry.SetRange("Source Type", DetailedGSTLedgerEntry."Source Type"::Customer);
        end;

        DetailedGSTLedgerEntry.SetRange("Source No.", AccountNo);
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        if GenJournalLine."Purch. Invoice Type" = GenJournalLine."Purch. Invoice Type"::" " then
            DetailedGSTLedgerEntry.SetRange("Document No.", InvoiceDocNo)
        else
            DetailedGSTLedgerEntry.SetRange("Document No.", GenJournalLine."Old Document No.");

        DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", false);
        if (TransactionType = TransactionType::Purchase) then
            if (PaymentCurrFactor < GetCurrencyFactor(DetailedGSTLedgerEntry, InvoiceDocNo, AccountNo)) then
                DetailedGSTLedgerEntry.SetRange("Forex Fluctuation", false);

        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if ((DetailedGSTLedgerEntry."GST Vendor Type" = DetailedGSTLedgerEntry."GST Vendor Type"::Registered) or
                   (DetailedGSTLedgerEntry."GST Customer Type" = DetailedGSTLedgerEntry."GST Customer Type"::Registered)) and
                   ((DetailedGSTLedgerEntry."Buyer/Seller Reg. No." = '') and (DetailedGSTLedgerEntry."ARN No." <> ''))
                then
                    Error(UpdateGSTNosErr, DetailedGSTLedgerEntry."Document No.");

                GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);

                CurrencyFactor := 1;
                if ApplyCurrencyFacInvoice and (DetailedGSTLedgerEntry."Currency Factor" <> 0) then
                    CurrencyFactor := DetailedGSTLedgerEntry."Currency Factor";

                GSTApplicationBufferStage.Init();
                GSTApplicationBufferStage."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type";
                GSTApplicationBufferStage."Transaction No." := DetailedGSTLedgerEntry."Transaction No.";
                GSTApplicationBufferStage."Original Document Type" := GSTApplicationBufferStage."Original Document Type"::Invoice;
                GSTApplicationBufferStage."Original Document No." := InvoiceDocNo;
                GSTApplicationBufferStage."Account No." := AccountNo;
                if (DetailedGSTLedgerEntry."Transaction Type" = DetailedGSTLedgerEntry."Transaction Type"::Purchase) and
                   (DetailedGSTLedgerEntry."Cr. & Liab. Adjustment Type" = DetailedGSTLedgerEntry."Cr. & Liab. Adjustment Type"::Generate)
                then
                    Error(GSTInvoiceLiabilityErr);

                if PaymentDocNo <> '' then begin
                    GSTApplicationBufferStage."Applied Doc. Type(Posted)" := GSTApplicationBufferStage."Applied Doc. Type(Posted)"::Payment;
                    GSTApplicationBufferStage."Applied Doc. No.(Posted)" := PaymentDocNo;
                    GSTApplicationBufferStage."Applied Doc. Type" := GSTApplicationBufferStage."Applied Doc. Type"::Payment;
                    GSTApplicationBufferStage."Applied Doc. No." := PaymentDocNo;
                end;

                GSTApplicationBufferStage."GST Group Code" := DetailedGSTLedgerEntry."GST Group Code";
                GSTApplicationBufferStage."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
                GSTApplicationBufferStage."Current Doc. Type" := DetailedGSTLedgerEntry."Document Type";
                GSTApplicationBufferStage."Currency Code" := DetailedGSTLedgerEntry."Currency Code";
                GSTApplicationBufferStage."Currency Factor" := DetailedGSTLedgerEntry."Currency Factor";
                GSTApplicationBufferStage."GST Rounding Precision" := DetailedGSTLedgerEntry."GST Rounding Precision";
                GSTApplicationBufferStage."GST Rounding Type" := DetailedGSTLedgerEntry."GST Rounding Type";
                GSTApplicationBufferStage."GST Inv. Rounding Precision" := DetailedGSTLedgerEntry."GST Inv. Rounding Precision";
                GSTApplicationBufferStage."GST Inv. Rounding Type" := DetailedGSTLedgerEntry."GST Inv. Rounding Type";
                GSTApplicationBufferStage."GST Group Type" := DetailedGSTLedgerEntry."GST Group Type";
                GSTApplicationBufferStage."GST Credit" := DetailedGSTLedgerEntry."GST Credit";

                GSTApplicationBufferStage."TDS/TCS Amount" := TDSTCSAmount;
                if GSTApplicationBufferStage."Currency Code" <> '' then
                    GSTApplicationBufferStage."GST Base Amount" := Round(DetailedGSTLedgerEntry."GST Base Amount" * CurrencyFactor, 0.01)
                else
                    GSTApplicationBufferStage."GST Base Amount" := DetailedGSTLedgerEntry."GST Base Amount";

                if (GSTApplicationBufferStage."GST Base Amount" <> DetailedGSTLedgerEntryInfo."GST Base Amount FCY") and (GSTApplicationBufferStage."Currency Code" <> '')
                then
                    GSTApplicationBufferStage."GST Base Amount" := DetailedGSTLedgerEntryInfo."GST Base Amount FCY";

                GSTApplicationBufferStage."RCM Exempt" := DetailedGSTLedgerEntryInfo."RCM Exempt Transaction";

                if not GSTApplicationBufferStage."RCM Exempt" then
                    GSTApplicationBufferStage."GST Amount" := GSTApplicationRound(
                        DetailedGSTLedgerEntry."GST Rounding Type",
                        DetailedGSTLedgerEntry."GST Rounding Precision",
                        (DetailedGSTLedgerEntry."GST Amount" * CurrencyFactor));

                GSTApplicationBufferStage."GST Cess" := DetailedGSTLedgerEntryInfo.Cess;
                GSTApplicationBufferStage."Posting Date" := DetailedGSTLedgerEntry."Posting Date";

                if DetailedGSTLedgerEntry."Currency Code" <> '' then begin
                    GSTApplicationBufferStage."GST Base Amount(LCY)" := DetailedGSTLedgerEntry."GST Base Amount";
                    GSTApplicationBufferStage."GST Amount(LCY)" := DetailedGSTLedgerEntry."GST Amount";
                    GSTApplicationBufferStage."Total Base(LCY)" := GetBaseAmount(
                        DocTransType::Purchase,
                        DetailedGSTLedgerEntry."Document Type",
                        DetailedGSTLedgerEntry."Document No.",
                        false);
                end;

                if (GSTApplicationBufferStage."GST Amount" <> DetailedGSTLedgerEntryInfo."GST Amount FCY") and (GSTApplicationBufferStage."Currency Code" <> '') then
                    GSTApplicationBufferStage."GST Amount" := DetailedGSTLedgerEntryInfo."GST Amount FCY";

                GSTApplicationBufferStage."GST %" := DetailedGSTLedgerEntry."GST %";

                UpdateGSTApplicationBuffer(GSTApplicationBufferStage);
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    procedure FillGSTAppBufferHSNComponentPayment(
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        AppliedDocType: Enum "Current Doc. Type";
        AppliedDocNo: Code[20];
        AccountNo: Code[20];
        AppliedDocTypePosted: Enum "Current Doc. Type";
        AppliedDocNoPosted: Code[20];
        AmountToApply: Decimal)
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTApplicationBufferStage: Record "GST Application Buffer";
        CurrencyFactor: Decimal;
    begin
        CurrencyFactor := 1;
        if DetailedGSTLedgerEntry."Currency Factor" <> 0 then
            CurrencyFactor := DetailedGSTLedgerEntry."Currency Factor";

        GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);
        GSTApplicationBufferStage.Init();
        InitiateGSTApplicationBufferStage(GSTApplicationBufferStage, DetailedGSTLedgerEntry);
        GSTApplicationBufferStage."Account No." := AccountNo;
        GSTApplicationBufferStage."Original Document Type" := GSTApplicationBufferStage."Original Document Type"::Payment;
        GSTApplicationBufferStage."Original Document No." := DetailedGSTLedgerEntryInfo."Original Doc. No.";
        GSTApplicationBufferStage."GST Base Amount" := DetailedGSTLedgerEntry."GST Base Amount" * CurrencyFactor;
        GSTApplicationBufferStage."GST Amount" := DetailedGSTLedgerEntry."GST Amount" * CurrencyFactor;
        if DetailedGSTLedgerEntry."Currency Code" <> '' then begin
            GSTApplicationBufferStage."GST Base Amount(LCY)" := DetailedGSTLedgerEntry."GST Base Amount";
            GSTApplicationBufferStage."GST Amount(LCY)" := DetailedGSTLedgerEntry."GST Amount";
            GSTApplicationBufferStage."Amt to Apply" := AmountToApply;
            GSTApplicationBufferStage."Total Base(LCY)" := DetailedGSTLedgerEntry."GST Base Amount";
        end;
        if AppliedDocNo <> '' then begin
            GSTApplicationBufferStage."Applied Doc. Type" := AppliedDocType;
            GSTApplicationBufferStage."Applied Doc. No." := AppliedDocNo;
        end;

        if (AppliedDocNoPosted <> '') and (AppliedDocTypePosted <> AppliedDocTypePosted::Payment) then begin
            GSTApplicationBufferStage."Applied Doc. Type(Posted)" := AppliedDocTypePosted;
            GSTApplicationBufferStage."Applied Doc. No.(Posted)" := AppliedDocNoPosted;
        end;

        UpdateGSTApplicationBuffer(GSTApplicationBufferStage);
    end;

    procedure FillAppBufferInvoice(
        TransactionType: Enum "Detail Ledger Transaction Type";
        InvoiceDocNo: Code[20];
        AccountNo: Code[20];
        PaymentDocNo: Code[20];
        TDSTCSAmount: Decimal;
        AmountToApply: Decimal;
        PaymentCurrFactor: Decimal): Boolean
    var
        GSTApplicationBufferStage: Record "GST Application Buffer";
        GSTApplicationBuff: Record "GST Application Buffer";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CurrencyFactor: Decimal;
        DocTransType: Enum "Transaction Type Enum";
    begin
        DeleteInvoiceApplicationBufferOffline(TransactionType, AccountNo, GSTApplicationBuff."Original Document Type"::Invoice, InvoiceDocNo);
        DetailedGSTLedgerEntry.SetRange("Transaction Type", TransactionType);
        case TransactionType of
            TransactionType::Purchase:
                DetailedGSTLedgerEntry.SetRange("Source Type", DetailedGSTLedgerEntry."Source Type"::Vendor);
            TransactionType::Sales:
                DetailedGSTLedgerEntry.SetRange("Source Type", DetailedGSTLedgerEntry."Source Type"::Customer);
        end;

        DetailedGSTLedgerEntry.SetRange("Source No.", AccountNo);
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntry.SetRange("Document No.", InvoiceDocNo);
        DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", false);
        if (TransactionType = TransactionType::Purchase) then
            if (PaymentCurrFactor < GetCurrencyFactor(DetailedGSTLedgerEntry, InvoiceDocNo, AccountNo)) then
                DetailedGSTLedgerEntry.SetRange("Forex Fluctuation", false);

        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if (DetailedGSTLedgerEntry."Transaction Type" = DetailedGSTLedgerEntry."Transaction Type"::Purchase) and
                   (DetailedGSTLedgerEntry."Cr. & Liab. Adjustment Type" = DetailedGSTLedgerEntry."Cr. & Liab. Adjustment Type"::Generate)
                then begin
                    if DetailedGSTLedgerEntry."Remaining Base Amount" = 0 then
                        exit(false);

                    if (DetailedGSTLedgerEntry."Remaining Base Amount" = DetailedGSTLedgerEntry."AdjustmentBase Amount") then begin
                        DetailedGSTLedgerEntry."Remaining Base Amount" := 0;
                        DetailedGSTLedgerEntry."Remaining GST Amount" := 0;
                        DetailedGSTLedgerEntry.Modify();
                        exit(false);
                    end;
                end;

                CurrencyFactor := 1;
                if ApplyCurrencyFacInvoice and (DetailedGSTLedgerEntry."Currency Factor" <> 0) then
                    CurrencyFactor := DetailedGSTLedgerEntry."Currency Factor";

                GSTApplicationBufferStage.Init();
                InitiateGSTApplicationBufferStage(GSTApplicationBufferStage, DetailedGSTLedgerEntry);
                GSTApplicationBufferStage."Account No." := AccountNo;
                GSTApplicationBufferStage."Original Document Type" := GSTApplicationBufferStage."Original Document Type"::Invoice;
                GSTApplicationBufferStage."Original Document No." := InvoiceDocNo;
                GSTApplicationBufferStage."GST Credit" := DetailedGSTLedgerEntry."GST Credit";
                GSTApplicationBufferStage."TDS/TCS Amount" := TDSTCSAmount;
                if GSTApplicationBufferStage."Currency Code" <> '' then begin
                    GSTApplicationBufferStage."GST Base Amount" := Round(DetailedGSTLedgerEntry."GST Base Amount" * CurrencyFactor, 0.01);
                    if DetailedGSTLedgerEntry."Transaction Type" = DetailedGSTLedgerEntry."Transaction Type"::Purchase then
                        GSTApplicationBufferStage."Total Base(LCY)" := GetBaseAmount(
                            DocTransType::Purchase,
                            DetailedGSTLedgerEntry."Document Type",
                            DetailedGSTLedgerEntry."Document No.",
                            false);

                    GSTApplicationBufferStage."Amt to Apply" := AmountToApply;
                end else
                    GSTApplicationBufferStage."GST Base Amount" := DetailedGSTLedgerEntry."GST Base Amount";

                GSTApplicationBufferStage."GST Amount" := GSTApplicationRound(
                    DetailedGSTLedgerEntry."GST Rounding Type",
                    DetailedGSTLedgerEntry."GST Rounding Precision",
                    (DetailedGSTLedgerEntry."GST Amount" * CurrencyFactor));

                if PaymentDocNo <> '' then begin
                    GSTApplicationBufferStage."Applied Doc. Type(Posted)" := GSTApplicationBufferStage."Applied Doc. Type(Posted)"::Payment;
                    GSTApplicationBufferStage."Applied Doc. No.(Posted)" := PaymentDocNo;
                    GSTApplicationBufferStage."Applied Doc. Type" := GSTApplicationBufferStage."Applied Doc. Type"::Payment;
                    GSTApplicationBufferStage."Applied Doc. No." := PaymentDocNo;
                end;

                UpdateGSTApplicationBuffer(GSTApplicationBufferStage);
            until DetailedGSTLedgerEntry.Next() = 0;

        exit(true);
    end;

    procedure AllocateGSTWithNormalPayment(AccountNo: Code[20]; DocumentNo: Code[20]; AmountToApply: Decimal)
    var
        GSTApplicationBuffer: Record "GST Application Buffer";
        GSTGroupCode: Code[20];
        InvoiceBase: Decimal;
        Charges: Decimal;
        TDSTCS: Decimal;
        TotalInvoiceAmount: Decimal;
        AppliedAmount: Decimal;
        GSTRoundingPrecision: Decimal;
        GSTRoudingType: Enum "GST Inv Rounding Type";
        Sign: Integer;
        OriginalDocumentType: Enum "Gen. Journal Document Type";
        IsHandled: Boolean;
    begin
        GSTGroupCode := '';
        AppliedAmount := 0;
        Sign := AmountToApply / Abs(AmountToApply);

        GSTApplicationBuffer.SetCurrentKey("Transaction Type", "Account No.", "Original Document Type", "Original Document No.", "GST Group Code");
        GSTApplicationBuffer.SetRange("Transaction Type", GSTApplicationBuffer."Transaction Type"::Purchase);
        GSTApplicationBuffer.SetRange("Account No.", AccountNo);
        GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Invoice);
        GSTApplicationBuffer.SetRange("Original Document No.", DocumentNo);
        if GSTApplicationBuffer.FindSet() then
            repeat
                if GSTGroupCode <> GSTApplicationBuffer."GST Group Code" then begin
                    Clear(InvoiceBase);
                    Clear(Charges);
                    Clear(TDSTCS);
                    Clear(TotalInvoiceAmount);
                    GetInvoiceBaseAmount(GSTApplicationBuffer, InvoiceBase, Charges, TDSTCS, GSTRoudingType, GSTRoundingPrecision);
                    if GSTApplicationBuffer."Currency Code" <> '' then
                        TDSTCS := ConvertFCYAmountToLCY(
                            GSTApplicationBuffer."Currency Code",
                            TDSTCS,
                            GSTApplicationBuffer."Currency Factor",
                            GSTApplicationBuffer."Posting Date");

                    TotalInvoiceAmount := InvoiceBase + Charges - Abs(TDSTCS);
                    AmountToApply := (Abs(AmountToApply) - Abs(AppliedAmount)) * Sign;
                end;

                OnBeforeCalculateAppliedAmounts(TotalInvoiceAmount, AmountToApply, TDSTCS, GSTApplicationBuffer, IsHandled);
                if not IsHandled then
                    if Abs(TotalInvoiceAmount) > Abs(AmountToApply) then begin
                        GSTApplicationBuffer."Applied Base Amount" := Round(GSTApplicationBuffer."GST Base Amount" * AmountToApply / (TotalInvoiceAmount + Abs(TDSTCS)), 0.01);
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount" * AmountToApply / (TotalInvoiceAmount + Abs(TDSTCS)));
                    end else begin
                        GSTApplicationBuffer."Applied Base Amount" := Round(GetInvoiceGSTComponentWise(GSTApplicationBuffer, OriginalDocumentType::Invoice, DocumentNo, true), 0.01);
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationBuffer."GST Amount";
                    end;

                GSTApplicationBuffer.Modify(true);
                GSTGroupCode := GSTApplicationBuffer."GST Group Code";
                Clear(AppliedAmount);
                AppliedAmount := GSTApplicationBuffer."Applied Base Amount";
            until GSTApplicationBuffer.Next() = 0;
    end;

    procedure DeleteInvoiceApplicationBufferOffline(
        TransactionType: Enum "Detail Ledger Transaction Type";
        AccountNo: Code[20];
        DocumentType: Enum "Original Doc Type";
        DocumentNo: Code[20])
    var
        GSTApplicationBuffer: Record "GST Application Buffer";
    begin
        GSTApplicationBuffer.SetRange("Transaction Type", TransactionType);
        GSTApplicationBuffer.SetRange("Account No.", AccountNo);
        GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Invoice);
        GSTApplicationBuffer.SetRange("Original Document No.", DocumentNo);
        GSTApplicationBuffer.DeleteAll(true);
    end;

    procedure DeletePaymentAplicationBuffer(TransactionType: Enum "Detail Ledger Transaction Type"; EntryNo: Integer)
    var
        GSTApplicationBuffer: Record "GST Application Buffer";
    begin
        GSTApplicationBuffer.SetCurrentKey("Transaction No.", "CLE/VLE Entry No.");
        GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Payment);
        GSTApplicationBuffer.SetRange("Transaction Type", TransactionType);
        GSTApplicationBuffer.DeleteAll(true);
    end;

    procedure GetApplicationRemainingAmountLCYForSales(
        CustLedgEntry: Record "Cust. Ledger Entry";
        ApplyingCustLedgEntry: Record "Cust. Ledger Entry";
        AmountToApply: Decimal;
        RemainingAmount: Decimal;
        var InvoiceGSTAmount: Decimal;
        var AppliedGSTAmount: Decimal;
        var InvoiceBaseAmount: Decimal): Decimal
    var
        GSTApplicationBuffer: Record "GST Application Buffer";
        ChargeAmount: Decimal;
        TDSTCSAmount: Decimal;
        TotalInvoiceAmount: Decimal;
        PaymentAmount: Decimal;
        GSTRoundingPrecision: Decimal;
        TotalPaymentLine: Integer;
        RCMExempted: Boolean;
        GSTRoudingType: Enum "GST Inv Rounding Type";
        TransactionType: Enum "Detail Ledger Transaction Type";
        GSTCredit: Enum "GST Credit";
        OriginalDocumentType: Enum "Original Doc Type";
    begin
        AppliedGSTAmount := 0;
        InvoiceGSTAmount := 0;
        InvoiceBaseAmount := 0;
        PaymentAmount := 0;
        OriginalDocumentType := GenJnlDocumentType2OriginalDocumentTypeEnum(CustLedgEntry."Document Type");
        GSTApplicationBuffer.SetRange("Transaction Type", TransactionType::Sales);
        GSTApplicationBuffer.SetRange("Account No.", ApplyingCustLedgEntry."Customer No.");
        GSTApplicationBuffer.SetRange("Original Document Type", OriginalDocumentType);
        GSTApplicationBuffer.SetRange("Original Document No.", CustLedgEntry."Document No.");
        GSTApplicationBuffer.SetRange("GST Group Code", ApplyingCustLedgEntry."GST Group Code");
        if GSTApplicationBuffer.FindSet() then begin
            GetInvoiceBaseAmountLCY(GSTApplicationBuffer, InvoiceBaseAmount, ChargeAmount, TDSTCSAmount, GSTRoudingType, GSTRoundingPrecision);
            GSTCredit := GSTApplicationBuffer."GST Credit";

            repeat
                RCMExempted := GSTApplicationBuffer."RCM Exempt";
                InvoiceGSTAmount += GSTApplicationBuffer."GST Amount";
            until GSTApplicationBuffer.Next() = 0;
        end;

        if GSTApplicationBuffer."Currency Code" <> '' then
            ConvertLCYAmountToFCY(GSTApplicationBuffer."Currency Code", InvoiceGSTAmount, GSTApplicationBuffer."Currency Factor", 0D);

        TotalInvoiceAmount := InvoiceBaseAmount + ChargeAmount;

        TotalInvoiceAmount += InvoiceGSTAmount;

        if TotalInvoiceAmount = 0 then
            Error(NoInvoiceGSTErr, CustLedgEntry."Document No.", ApplyingCustLedgEntry."GST Group Code");

        GSTApplicationBuffer.Reset();
        GSTApplicationBuffer.SetRange("Transaction Type", TransactionType::Sales);
        GSTApplicationBuffer.SetRange("Account No.", ApplyingCustLedgEntry."Customer No.");
        GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Payment);
        GSTApplicationBuffer.SetRange("Applied Doc. Type", GenJnlDocumentType2CurrentDocumentTypeEnum(CustLedgEntry."Document Type"));
        GSTApplicationBuffer.SetRange("Applied Doc. No.", CustLedgEntry."Document No.");
        GSTApplicationBuffer.SetRange("GST Group Code", ApplyingCustLedgEntry."GST Group Code");
        TotalPaymentLine := GSTApplicationBuffer.Count;
        if GSTApplicationBuffer.FindFirst() then begin
            VerifyNoOfGSTComponent(GSTApplicationBuffer, TotalPaymentLine);

            repeat
                GSTApplicationBuffer."GST Credit" := GSTCredit;
                VerifySameGSTComponent(GSTApplicationBuffer);
                if Abs(TotalInvoiceAmount) > Abs(AmountToApply) then
                    if Abs(AmountToApply) = Abs(RemainingAmount) then begin
                        GSTApplicationBuffer."Applied Base Amount" := Round(GSTApplicationBuffer."GST Base Amount(LCY)", 0.01);
                        GSTApplicationBuffer."Applied Amount" := Round(GSTApplicationBuffer."GST Amount(LCY)", 0.01);
                    end else begin
                        GSTApplicationBuffer."Applied Base Amount" := Round(RemainingAmount * AmountToApply / RemainingAmount, 0.01);
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount(LCY)" * AmountToApply / RemainingAmount);
                    end
                else begin
                    if not GSTApplicationBuffer."GST Cess" then
                        GSTApplicationBuffer."Applied Base Amount" := Round(
                            GSTApplicationBuffer."GST Base Amount(LCY)" * InvoiceBaseAmount / GSTApplicationBuffer."GST Base Amount(LCY)",
                            0.01)
                    else
                        GSTApplicationBuffer."Applied Base Amount" := Round(
                            GSTApplicationBuffer."GST Base Amount(LCY)" *
                                GetInvoiceGSTComponentWiseLCY(
                                    GSTApplicationBuffer,
                                    CustLedgEntry."Document Type",
                                    CustLedgEntry."Document No.",
                                    true) /
                                GSTApplicationBuffer."GST Base Amount(LCY)",
                            0.01);

                    if not RCMExempted then
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount(LCY)" *
                                GetInvoiceGSTComponentWiseLCY(GSTApplicationBuffer, CustLedgEntry."Document Type", CustLedgEntry."Document No.", false) / GSTApplicationBuffer."GST Amount(LCY)")
                    else
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount(LCY)" *
                                GetInvoiceGSTComponentWiseLCY(GSTApplicationBuffer, CustLedgEntry."Document Type", CustLedgEntry."Document No.", true) / GSTApplicationBuffer."GST Base Amount(LCY)");
                end;

                if not GSTApplicationBuffer."GST Cess" then
                    if PaymentAmount = 0 then
                        PaymentAmount := GSTApplicationBuffer."Applied Base Amount";

                AppliedGSTAmount += GSTApplicationBuffer."Applied Amount";
                GSTApplicationBuffer.Modify(true);
            until GSTApplicationBuffer.Next() = 0;
        end;

        PaymentAmount += AppliedGSTAmount;

        AdjustPaymentAmount(
            TransactionType::Sales,
            CustLedgEntry."Document Type",
            CustLedgEntry."Document No.",
            ApplyingCustLedgEntry."Customer No.",
            ApplyingCustLedgEntry."GST Group Code",
            AmountToApply,
            PaymentAmount,
            RemainingAmount,
            TotalInvoiceAmount,
            GSTRoundingPrecision);

        exit(PaymentAmount);
    end;

    procedure GetApplicationRemainingAmountLCYForPurchase(
    VendLedgerEntry: Record "Vendor Ledger Entry";
    ApplyingVendLedgerEntry: Record "Vendor Ledger Entry";
    AmountToApply: Decimal;
    RemainingAmount: Decimal;
    var InvoiceGSTAmount: Decimal;
    var InvoiceBaseAmount: Decimal): Decimal
    var
        GSTApplicationBuffer: Record "GST Application Buffer";
        ChargeAmount: Decimal;
        TDSTCSAmount: Decimal;
        TotalInvoiceAmount: Decimal;
        PaymentAmount: Decimal;
        GSTRoundingPrecision: Decimal;
        TotalPaymentLine: Integer;
        RCMExempted: Boolean;
        GSTRoudingType: Enum "GST Inv Rounding Type";
        TransactionType: Enum "Detail Ledger Transaction Type";
        GSTCredit: Enum "GST Credit";
        OriginalDocumentType: Enum "Original Doc Type";
    begin
        InvoiceGSTAmount := 0;
        InvoiceBaseAmount := 0;
        PaymentAmount := 0;
        OriginalDocumentType := GenJnlDocumentType2OriginalDocumentTypeEnum(VendLedgerEntry."Document Type");
        GSTApplicationBuffer.SetRange("Transaction Type", TransactionType::Purchase);
        GSTApplicationBuffer.SetRange("Account No.", ApplyingVendLedgerEntry."Vendor No.");
        GSTApplicationBuffer.SetRange("Original Document Type", OriginalDocumentType);
        GSTApplicationBuffer.SetRange("Original Document No.", VendLedgerEntry."Document No.");
        GSTApplicationBuffer.SetRange("GST Group Code", ApplyingVendLedgerEntry."GST Group Code");
        if GSTApplicationBuffer.FindSet() then begin
            GetInvoiceBaseAmountLCY(GSTApplicationBuffer, InvoiceBaseAmount, ChargeAmount, TDSTCSAmount, GSTRoudingType, GSTRoundingPrecision);
            GSTCredit := GSTApplicationBuffer."GST Credit";

            repeat
                RCMExempted := GSTApplicationBuffer."RCM Exempt";
                InvoiceGSTAmount += GSTApplicationBuffer."GST Amount";
            until GSTApplicationBuffer.Next() = 0;
        end;

        if GSTApplicationBuffer."Currency Code" <> '' then
            ConvertLCYAmountToFCY(GSTApplicationBuffer."Currency Code", InvoiceGSTAmount, GSTApplicationBuffer."Currency Factor", 0D);

        TotalInvoiceAmount := InvoiceBaseAmount + ChargeAmount;

        if TotalInvoiceAmount = 0 then
            Error(NoInvoiceGSTErr, VendLedgerEntry."Document No.", ApplyingVendLedgerEntry."GST Group Code");

        GSTApplicationBuffer.Reset();
        GSTApplicationBuffer.SetRange("Transaction Type", TransactionType::Purchase);
        GSTApplicationBuffer.SetRange("Account No.", ApplyingVendLedgerEntry."Vendor No.");
        GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Payment);
        GSTApplicationBuffer.SetRange("Applied Doc. Type", GenJnlDocumentType2CurrentDocumentTypeEnum(VendLedgerEntry."Document Type"));
        GSTApplicationBuffer.SetRange("Applied Doc. No.", VendLedgerEntry."Document No.");
        GSTApplicationBuffer.SetRange("GST Group Code", ApplyingVendLedgerEntry."GST Group Code");
        TotalPaymentLine := GSTApplicationBuffer.Count;
        if GSTApplicationBuffer.FindFirst() then begin
            VerifyNoOfGSTComponent(GSTApplicationBuffer, TotalPaymentLine);

            repeat
                GSTApplicationBuffer."GST Credit" := GSTCredit;
                VerifySameGSTComponent(GSTApplicationBuffer);
                if Abs(TotalInvoiceAmount) > Abs(AmountToApply) then
                    if Abs(AmountToApply) = Abs(RemainingAmount) then begin
                        GSTApplicationBuffer."Applied Base Amount" := Round(GSTApplicationBuffer."GST Base Amount(LCY)", 0.01);
                        GSTApplicationBuffer."Applied Amount" := Round(GSTApplicationBuffer."GST Amount(LCY)", 0.01);
                    end else begin
                        GSTApplicationBuffer."Applied Base Amount" := Round(RemainingAmount * AmountToApply / RemainingAmount, 0.01);
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount(LCY)" * AmountToApply / RemainingAmount);
                    end
                else begin
                    if not GSTApplicationBuffer."GST Cess" then
                        GSTApplicationBuffer."Applied Base Amount" := Round(
                            GSTApplicationBuffer."GST Base Amount(LCY)" * InvoiceBaseAmount / GSTApplicationBuffer."GST Base Amount(LCY)",
                            0.01)
                    else
                        GSTApplicationBuffer."Applied Base Amount" := Round(
                            GSTApplicationBuffer."GST Base Amount(LCY)" *
                                GetInvoiceGSTComponentWiseLCY(
                                    GSTApplicationBuffer,
                                    VendLedgerEntry."Document Type",
                                    VendLedgerEntry."Document No.",
                                    true) /
                                GSTApplicationBuffer."GST Base Amount(LCY)",
                            0.01);

                    if not RCMExempted then
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount(LCY)" *
                                GetInvoiceGSTComponentWiseLCY(GSTApplicationBuffer, VendLedgerEntry."Document Type", VendLedgerEntry."Document No.", false) / GSTApplicationBuffer."GST Amount(LCY)")
                    else
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount(LCY)" *
                                GetInvoiceGSTComponentWiseLCY(GSTApplicationBuffer, VendLedgerEntry."Document Type", VendLedgerEntry."Document No.", true) / GSTApplicationBuffer."GST Base Amount(LCY)");
                end;

                if not GSTApplicationBuffer."GST Cess" then
                    if PaymentAmount = 0 then
                        PaymentAmount := GSTApplicationBuffer."Applied Base Amount";

                GSTApplicationBuffer.Modify(true);
            until GSTApplicationBuffer.Next() = 0;
        end;

        AdjustPaymentAmount(
            TransactionType::Purchase,
            VendLedgerEntry."Document Type",
            VendLedgerEntry."Document No.",
            ApplyingVendLedgerEntry."Vendor No.",
            ApplyingVendLedgerEntry."GST Group Code",
            AmountToApply,
            PaymentAmount,
            RemainingAmount,
            TotalInvoiceAmount,
            GSTRoundingPrecision);

        exit(PaymentAmount);
    end;

    procedure CheckEarlierPostingDate(
        PostingDate: Date;
        ApplyingEntryPostingDate: Date;
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        ApplyingEntryDocumentType: Enum "Gen. Journal Document Type";
        CVNo: Code[20])
    begin
        if PostingDate > ApplyingEntryPostingDate then
            Error(EarlierPostingDateErr, Format(DocumentType), DocumentNo, Format(ApplyingEntryDocumentType), CVNo);
    end;

    procedure GetApplicationRemainingAmountForSales(
    CustLedgEntry: Record "Cust. Ledger Entry";
    ApplyingCustLedgerEntry: Record "Cust. Ledger Entry";
    AmountToApply: Decimal;
    RemainingAmount: Decimal;
    var InvoiceGSTAmount: Decimal;
    var AppliedGSTAmount: Decimal;
    var InvoiceBaseAmount: Decimal): Decimal
    var
        GSTApplicationBuffer: Record "GST Application Buffer";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ChargeAmount: Decimal;
        TDSTCSAmount: Decimal;
        TotalInvoiceAmount: Decimal;
        PaymentAmount: Decimal;
        GSTRoundingPrecision: Decimal;
        TotalPaymentLine: Integer;
        RCMExempted: Boolean;
        GSTRoudingType: Enum "GST Inv Rounding Type";
        TransactionType: Enum "Detail Ledger Transaction Type";
        GSTCredit: Enum "GST Credit";
        OriginalDocumentType: Enum "Original Doc Type";
        CalcAmount: Decimal;
    begin
        AppliedGSTAmount := 0;
        InvoiceGSTAmount := 0;
        InvoiceBaseAmount := 0;
        PaymentAmount := 0;
        OriginalDocumentType := GenJnlDocumentType2OriginalDocumentTypeEnum(CustLedgEntry."Document Type");
        GSTApplicationBuffer.SetRange("Transaction Type", TransactionType::Sales);
        GSTApplicationBuffer.SetRange("Account No.", ApplyingCustLedgerEntry."Customer No.");
        GSTApplicationBuffer.SetRange("Original Document Type", OriginalDocumentType);
        GSTApplicationBuffer.SetRange("Original Document No.", CustLedgEntry."Document No.");
        GSTApplicationBuffer.SetRange("GST Group Code", ApplyingCustLedgerEntry."GST Group Code");
        if GSTApplicationBuffer.FindSet() then begin
            GetInvoiceBaseAmount(GSTApplicationBuffer, InvoiceBaseAmount, ChargeAmount, TDSTCSAmount, GSTRoudingType, GSTRoundingPrecision);
            GSTCredit := GSTApplicationBuffer."GST Credit";

            repeat
                RCMExempted := GSTApplicationBuffer."RCM Exempt";
                InvoiceGSTAmount += GSTApplicationBuffer."GST Amount";
            until GSTApplicationBuffer.Next() = 0;
        end;

        TotalInvoiceAmount := InvoiceBaseAmount + InvoiceGSTAmount + ChargeAmount;

        InvoiceBaseAmount += ChargeAmount;

        if TotalInvoiceAmount = 0 then
            Error(NoInvoiceGSTErr, CustLedgEntry."Document No.", ApplyingCustLedgerEntry."GST Group Code");

        GSTApplicationBuffer.Reset();
        GSTApplicationBuffer.SetRange("Transaction Type", TransactionType::Sales);
        GSTApplicationBuffer.SetRange("Account No.", ApplyingCustLedgerEntry."Customer No.");
        GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Payment);
        GSTApplicationBuffer.SetRange("Applied Doc. Type", GenJnlDocumentType2CurrentDocumentTypeEnum(CustLedgEntry."Document Type"));
        GSTApplicationBuffer.SetRange("Applied Doc. No.", CustLedgEntry."Document No.");
        GSTApplicationBuffer.SetRange("GST Group Code", ApplyingCustLedgerEntry."GST Group Code");
        TotalPaymentLine := GSTApplicationBuffer.Count;
        if GSTApplicationBuffer.FindFirst() then begin
            VerifyNoOfGSTComponent(GSTApplicationBuffer, TotalPaymentLine);

            repeat
                GSTApplicationBuffer."GST Credit" := GSTCredit;
                VerifySameGSTComponent(GSTApplicationBuffer);
                if Abs(TotalInvoiceAmount) > Abs(AmountToApply) then
                    if Abs(AmountToApply) = Abs(RemainingAmount) then begin
                        GSTApplicationBuffer."Applied Base Amount" := GSTApplicationBuffer."GST Base Amount";
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationBuffer."GST Amount";
                    end else begin
                        if GSTApplicationBuffer."GST %" <> 0 then
                            if CustLedgEntry."GST Jurisdiction Type" = CustLedgEntry."GST Jurisdiction Type"::Intrastate then
                                CalcAmount := AmountToApply * (100 / (100 + (GSTApplicationBuffer."GST %" * 2)))
                            else
                                CalcAmount := AmountToApply * (100 / (100 + (GSTApplicationBuffer."GST %")));

                        GSTApplicationBuffer."Applied Base Amount" := CalcAmount;

                        if GSTApplicationBuffer."GST %" <> 0 then
                            GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                                  GSTRoudingType,
                                  GSTRoundingPrecision,
                                  (GSTApplicationBuffer."GST %" / 100) * CalcAmount);
                    end
                else begin
                    if not GSTApplicationBuffer."GST Cess" then
                        GSTApplicationBuffer."Applied Base Amount" := Round(
                            GSTApplicationBuffer."GST Base Amount" * InvoiceBaseAmount / GSTApplicationBuffer."GST Base Amount",
                        0.01)
                    else
                        GSTApplicationBuffer."Applied Base Amount" := Round(
                            GSTApplicationBuffer."GST Base Amount" *
                                GetInvoiceGSTComponentWise(GSTApplicationBuffer, CustLedgEntry."Document Type", CustLedgEntry."Document No.", true) /
                                GSTApplicationBuffer."GST Base Amount",
                            0.01);

                    if not RCMExempted then
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount" *
                                GetInvoiceGSTComponentWise(
                                    GSTApplicationBuffer,
                                    CustLedgEntry."Document Type",
                                    CustLedgEntry."Document No.",
                                    false) /
                            GSTApplicationBuffer."GST Amount")
                    else
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount" *
                                GetInvoiceGSTComponentWise(
                                    GSTApplicationBuffer,
                                    CustLedgEntry."Document Type",
                                    CustLedgEntry."Document No.",
                                    true) /
                                GSTApplicationBuffer."GST Base Amount");
                end;

                if (not GSTApplicationBuffer."GST Cess") and (PaymentAmount = 0) then
                    PaymentAmount := GSTApplicationBuffer."Applied Base Amount";

                AppliedGSTAmount += GSTApplicationBuffer."Applied Amount";
                GSTApplicationBuffer.Modify(true);
            until GSTApplicationBuffer.Next() = 0;
        end;

        PaymentAmount += AppliedGSTAmount;

        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Document No.", GSTApplicationBuffer."Original Document No.");
        if CustLedgerEntry.FindFirst() then begin
            CustLedgerEntry.CalcFields("Remaining Amount");
            if Abs(PaymentAmount) <> Abs(CustLedgerEntry."Remaining Amount") then
                PaymentAmount := CustLedgerEntry."Remaining Amount";
        end;

        AdjustPaymentAmount(
            TransactionType::Sales,
            CustLedgEntry."Document Type",
            CustLedgEntry."Document No.",
            ApplyingCustLedgerEntry."Customer No.",
            ApplyingCustLedgerEntry."GST Group Code",
            AmountToApply,
            PaymentAmount, RemainingAmount,
            TotalInvoiceAmount,
            GSTRoundingPrecision);

        exit(PaymentAmount);
    end;

    procedure GetApplicationRemainingAmountForPurchase(
        VendLedgerEntry: Record "Vendor Ledger Entry";
        ApplyingVendLedgEntry: Record "Vendor Ledger Entry";
        AmountToApply: Decimal;
        RemainingAmount: Decimal;
        var InvoiceBaseAmount: Decimal): Decimal
    var
        GSTApplicationBuffer: Record "GST Application Buffer";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ChargeAmount: Decimal;
        TDSTCSAmount: Decimal;
        TotalInvoiceAmount: Decimal;
        PaymentAmount: Decimal;
        GSTRoundingPrecision: Decimal;
        TotalPaymentLine: Integer;
        RCMExempted: Boolean;
        GSTRoudingType: Enum "GST Inv Rounding Type";
        TransactionType: Enum "Detail Ledger Transaction Type";
        GSTCredit: Enum "GST Credit";
        OriginalDocumentType: Enum "Original Doc Type";
    begin
        InvoiceBaseAmount := 0;
        PaymentAmount := 0;
        OriginalDocumentType := GenJnlDocumentType2OriginalDocumentTypeEnum(VendLedgerEntry."Document Type");
        GSTApplicationBuffer.SetRange("Transaction Type", TransactionType::Purchase);
        GSTApplicationBuffer.SetRange("Account No.", ApplyingVendLedgEntry."Vendor No.");
        GSTApplicationBuffer.SetRange("Original Document Type", OriginalDocumentType);
        GSTApplicationBuffer.SetRange("Original Document No.", VendLedgerEntry."Document No.");
        GSTApplicationBuffer.SetRange("GST Group Code", ApplyingVendLedgEntry."GST Group Code");
        if GSTApplicationBuffer.FindSet() then begin
            GetInvoiceBaseAmount(GSTApplicationBuffer, InvoiceBaseAmount, ChargeAmount, TDSTCSAmount, GSTRoudingType, GSTRoundingPrecision);
            GSTCredit := GSTApplicationBuffer."GST Credit";

            repeat
                RCMExempted := GSTApplicationBuffer."RCM Exempt";
            until GSTApplicationBuffer.Next() = 0;
        end;

        TotalInvoiceAmount := InvoiceBaseAmount + ChargeAmount;

        InvoiceBaseAmount += ChargeAmount;

        if TotalInvoiceAmount = 0 then
            Error(NoInvoiceGSTErr, VendLedgerEntry."Document No.", ApplyingVendLedgEntry."GST Group Code");

        GSTApplicationBuffer.Reset();
        GSTApplicationBuffer.SetRange("Transaction Type", TransactionType::Purchase);
        GSTApplicationBuffer.SetRange("Account No.", ApplyingVendLedgEntry."Vendor No.");
        GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Payment);
        GSTApplicationBuffer.SetRange("Applied Doc. Type", GenJnlDocumentType2CurrentDocumentTypeEnum(VendLedgerEntry."Document Type"));
        GSTApplicationBuffer.SetRange("Applied Doc. No.", VendLedgerEntry."Document No.");
        GSTApplicationBuffer.SetRange("GST Group Code", ApplyingVendLedgEntry."GST Group Code");
        TotalPaymentLine := GSTApplicationBuffer.Count;
        if GSTApplicationBuffer.FindFirst() then begin
            VerifyNoOfGSTComponent(GSTApplicationBuffer, TotalPaymentLine);

            repeat
                GSTApplicationBuffer."GST Credit" := GSTCredit;
                VerifySameGSTComponent(GSTApplicationBuffer);
                if Abs(TotalInvoiceAmount) > Abs(AmountToApply) then
                    if Abs(AmountToApply) = Abs(RemainingAmount) then begin
                        GSTApplicationBuffer."Applied Base Amount" := GSTApplicationBuffer."GST Base Amount";
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationBuffer."GST Amount";
                    end else begin
                        GSTApplicationBuffer."Applied Base Amount" := Round(GSTApplicationBuffer."GST Base Amount" * AmountToApply / RemainingAmount, 0.01);
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                              GSTRoudingType,
                              GSTRoundingPrecision,
                              GSTApplicationBuffer."GST Amount" * AmountToApply / RemainingAmount);
                    end
                else begin
                    if not GSTApplicationBuffer."GST Cess" then
                        GSTApplicationBuffer."Applied Base Amount" := Round(
                            GSTApplicationBuffer."GST Base Amount" * InvoiceBaseAmount / GSTApplicationBuffer."GST Base Amount",
                        0.01)
                    else
                        GSTApplicationBuffer."Applied Base Amount" := Round(
                            GSTApplicationBuffer."GST Base Amount" *
                                GetInvoiceGSTComponentWise(GSTApplicationBuffer, VendLedgerEntry."Document Type", VendLedgerEntry."Document No.", true) /
                                GSTApplicationBuffer."GST Base Amount",
                            0.01);

                    if not RCMExempted then
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount" *
                                GetInvoiceGSTComponentWise(
                                    GSTApplicationBuffer,
                                    VendLedgerEntry."Document Type",
                                    VendLedgerEntry."Document No.",
                                    false) /
                            GSTApplicationBuffer."GST Amount")
                    else
                        GSTApplicationBuffer."Applied Amount" := GSTApplicationRound(
                            GSTRoudingType,
                            GSTRoundingPrecision,
                            GSTApplicationBuffer."GST Amount" *
                                GetInvoiceGSTComponentWise(
                                    GSTApplicationBuffer,
                                    VendLedgerEntry."Document Type",
                                    VendLedgerEntry."Document No.",
                                    true) /
                                GSTApplicationBuffer."GST Base Amount");
                end;

                VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
                VendorLedgerEntry.SetRange("Document No.", GSTApplicationBuffer."Original Document No.");
                if VendorLedgerEntry.FindFirst() then begin
                    VendorLedgerEntry.CalcFields("Remaining Amount");
                    if VendorLedgerEntry."Remaining Amount" <> Round(GSTApplicationBuffer."GST Base Amount", 0.01) then
                        GSTApplicationBuffer."Applied Base Amount" := VendorLedgerEntry."Remaining Amount";
                end;

                if (not GSTApplicationBuffer."GST Cess") and (PaymentAmount = 0) then
                    PaymentAmount := GSTApplicationBuffer."Applied Base Amount";

                GSTApplicationBuffer.Modify(true);
            until GSTApplicationBuffer.Next() = 0;
        end;

        AdjustPaymentAmount(
            TransactionType::Purchase,
            VendLedgerEntry."Document Type",
            VendLedgerEntry."Document No.",
            ApplyingVendLedgEntry."Vendor No.",
            ApplyingVendLedgEntry."GST Group Code",
            AmountToApply,
            PaymentAmount, RemainingAmount,
            TotalInvoiceAmount,
            GSTRoundingPrecision);

        exit(PaymentAmount);
    end;

    procedure CheckGroupAmount(
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        AmountToApply: Decimal;
        GSTGroupAmount: Decimal;
        GSTGroupCode: Code[20])
    begin
        if Abs(AmountToApply) > Abs(GSTGroupAmount) then
            Error(GSTGroupAmountErr, Format(DocumentType), DocumentNo, GSTGroupCode, GSTGroupAmount, Abs(AmountToApply));
    end;

    procedure CheckGroupAmountJnl(
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        AmountToApply: Decimal;
        GSTGroupAmount: Decimal;
        GSTGroupCode: Code[20])
    begin
        if Abs(AmountToApply) > Abs(GSTGroupAmount) then
            Error(GSTGroupAmountJnlErr, Format(DocumentType), DocumentNo, GSTGroupCode, GSTGroupAmount, Abs(AmountToApply));
    end;

    procedure GetAppliedAmount(
        RemainingBase: Decimal;
        RemainingAmount: Decimal;
        GSTBase: Decimal;
        GSTAmount: Decimal;
        var AppliedBase: Decimal;
        var AppliedAmount: Decimal)
    begin
        if RemainingBase >= GSTBase then begin
            AppliedBase := Round(GSTBase);
            AppliedAmount := Round(GSTAmount);
        end
        else begin
            AppliedBase := RemainingBase;
            AppliedAmount := RemainingAmount;
        end;
    end;

    procedure ApplyCurrencyFactorInvoice(ApplyCurrencyFac: Boolean)
    begin
        ApplyCurrencyFacInvoice := ApplyCurrencyFac;
    end;

    procedure GetGSTLedgerTransactionTypeFromDetailLedgerTransactioType(
        var GSTLedgerTransactionType: Enum "GST Ledger Transaction Type";
        DetailLedgerTransactionType: Enum "Detail Ledger Transaction Type")
    begin
        case DetailLedgerTransactionType of
            DetailLedgerTransactionType::Purchase:
                GSTLedgerTransactionType := GSTLedgerTransactionType::Purchase;
            DetailLedgerTransactionType::Sales:
                GSTLedgerTransactionType := GSTLedgerTransactionType::Sales;
        end;
    end;

    procedure GetPurchGroupTypeFromGSTGroupType(
        var PurchGroupType: Enum "Purchase Group Type";
        GSTGroupType: Enum "GST Group Type")
    begin
        case GSTGroupType of
            GSTGroupType::Goods:
                PurchGroupType := PurchGroupType::Goods;
            GSTGroupType::Service:
                PurchGroupType := PurchGroupType::Service;
        end;
    end;

    procedure GetDetailedGSTDocumentTypeFromGSTDocumentType(
        var DetailedGSTDocumentType: Enum "Detail GST Document Type";
        GSTDocumentType: Enum "GST Document Type")
    begin
        case GSTDocumentType of
            GSTDocumenTtype::" ":
                DetailedGSTDocumentType := DetailedGSTDocumentType::" ";
            GSTDocumenTtype::Payment:
                DetailedGSTDocumentType := DetailedGSTDocumentType::Payment;
            GSTDocumenTtype::Invoice:
                DetailedGSTDocumentType := DetailedGSTDocumentType::Invoice;
            GSTDocumenTtype::"Credit Memo":
                DetailedGSTDocumentType := DetailedGSTDocumentType::"Credit Memo";
            GSTDocumenTtype::Refund:
                DetailedGSTDocumentType := DetailedGSTDocumentType::Refund;
        end;
    end;

    procedure GetApplicationDocTypeFromGSTDocumentType(
        var ApplicationDocType: Enum "Application Doc Type";
        GSTDocumentType: Enum "GST Document Type")
    begin
        case GSTDocumentType of
            GSTDocumentType::" ":
                ApplicationDocType := ApplicationDoctype::" ";
            GSTDocumentType::Payment:
                ApplicationDocType := ApplicationDoctype::Payment;
            GSTDocumentType::Invoice:
                ApplicationDocType := ApplicationDoctype::Invoice;
            GSTDocumentType::"Credit Memo":
                ApplicationDocType := ApplicationDoctype::"Credit Memo";
            GSTDocumentType::Refund:
                ApplicationDocType := ApplicationDoctype::Refund;
        end;
    end;

    procedure GetApplicationDocTypeFromGenJournalDocumentType(
        var ApplicationDocType: Enum "Application Doc Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type")
    begin
        case GenJournalDocumentType of
            GenJournalDocumentType::" ":
                ApplicationDocType := ApplicationDoctype::" ";
            GenJournalDocumentType::Payment:
                ApplicationDocType := ApplicationDoctype::Payment;
            GenJournalDocumentType::Invoice:
                ApplicationDocType := ApplicationDoctype::Invoice;
            GenJournalDocumentType::"Credit Memo":
                ApplicationDocType := ApplicationDoctype::"Credit Memo";
            GenJournalDocumentType::Refund:
                ApplicationDocType := ApplicationDoctype::Refund;
        end;
    end;

    procedure GetGSTDocumentTypeFromGenJournalDocumentType(
        var GSTDocumentType: Enum "GST Document Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type")
    begin
        case GenJournalDocumentType of
            GenJournalDocumentType::" ":
                GSTDocumentType := GSTDocumentType::" ";
            GenJournalDocumentType::Payment:
                GSTDocumentType := GSTDocumentType::Payment;
            GenJournalDocumentType::Invoice:
                GSTDocumentType := GSTDocumentType::Invoice;
            GenJournalDocumentType::"Credit Memo":
                GSTDocumentType := GSTDocumentType::"Credit Memo";
            GenJournalDocumentType::Refund:
                GSTDocumentType := GSTDocumentType::Refund;
        end;
    end;

    procedure GetOriginalDocTypeFromGenJournalDocumentType(
        var OriginalDocType: Enum "Original Doc Type";
        GenJournalDocumentType: Enum "Gen. Journal Document Type")
    begin
        case GenJournalDocumentType of
            GenJournalDocumentType::" ":
                OriginalDocType := OriginalDocType::" ";
            GenJournalDocumentType::Payment:
                OriginalDocType := OriginalDocType::Payment;
            GenJournalDocumentType::Invoice:
                OriginalDocType := OriginalDocType::Invoice;
            GenJournalDocumentType::"Credit Memo":
                OriginalDocType := OriginalDocType::"Credit Memo";
            GenJournalDocumentType::Refund:
                OriginalDocType := OriginalDocType::Refund;
        end;
    end;

    procedure GetPartialRoundingAmt(AmountToApply: Decimal; GSTCalculatedAmountToApply: Decimal): Decimal
    var
        ApplyAmount: Decimal;
    begin
        ApplyAmount := AmountToApply - GSTCalculatedAmountToApply;
        if Abs(ApplyAmount) < 1 then
            exit(ApplyAmount);
    end;

    procedure CheckGSTAccountingPeriod(PostingDate: Date; UsedForSettlement: Boolean)
    var
        GSTSetup: Record "GST Setup";
        GSTAccountingPeriod: Record "Tax Accounting Period";
        GSTAccountingSubPeriod: Record "Tax Accounting Period";
        LastClosedDate: Date;
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");
        LastClosedDate := GetLastClosedSubAccPeriod();

        GSTAccountingSubPeriod.SetRange("Tax Type Code", GSTSetup."GST Tax Type");
        GSTAccountingSubPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        GSTAccountingSubPeriod.SetFilter("Ending Date", '>=%1', PostingDate);
        if GSTAccountingSubPeriod.FindLast() then begin
            if not UsedForSettlement then
                if LastClosedDate <> 0D then
                    if PostingDate < CalcDate('<1M>', LastClosedDate) then
                        Error(PeriodClosedErr, CalcDate('<-1D>', CalcDate('<1M>', LastClosedDate)), CalcDate('<1M>', LastClosedDate));
            GSTAccountingPeriod.Get(GSTSetup."GST Tax Type", GSTAccountingSubPeriod."Starting Date");
        end else
            Error(AccountingPeriodErr, PostingDate);

        GSTAccountingSubPeriod.SetRange("Tax Type Code", GSTSetup."GST Tax Type");
        if not UsedForSettlement then
            GSTAccountingSubPeriod.SetRange(Closed, false);
        GSTAccountingSubPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        GSTAccountingSubPeriod.SetFilter("Ending Date", '>=%1', PostingDate);
        if GSTAccountingSubPeriod.FindLast() then begin
            if not UsedForSettlement then
                GSTAccountingSubPeriod.TestField(Closed, false);
        end else
            if LastClosedDate <> 0D then
                if PostingDate < CalcDate('<1M>', LastClosedDate) then
                    Error(PeriodClosedErr, CalcDate('<-1D>', CalcDate('<1M>', LastClosedDate)), CalcDate('<1M>', LastClosedDate));
    end;

    procedure GetGSTGLAccountNo(GSTGLAccountType: Enum "GST GL Account Type"; GSTStateCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
        GSTComponentID: Integer;
    begin
        GSTComponentID := GetGSTComponentID(GSTComponentCode);
        GSTPostingSetup.Get(GSTStateCode, GSTComponentID);

        case GSTGLAccountType of
            GSTGLAccountType::"Payable Account":
                begin
                    GSTPostingSetup.TestField("Payable Account");
                    exit(GSTPostingSetup."Payable Account");
                end;
            GSTGLAccountType::"Payables Account (Interim)":
                begin
                    GSTPostingSetup.TestField("Payables Account (Interim)");
                    exit(GSTPostingSetup."Payables Account (Interim)");
                end;
            GSTGLAccountType::"Receivable Account":
                begin
                    GSTPostingSetup.TestField("Receivable Account");
                    exit(GSTPostingSetup."Receivable Account");
                end;
            GSTGLAccountType::"Receivable Account (Interim)":
                begin
                    GSTPostingSetup.TestField("Receivable Account (Interim)");
                    exit(GSTPostingSetup."Receivable Account (Interim)");
                end;
            GSTGLAccountType::"Receivable Acc. (Dist)":
                begin
                    GSTPostingSetup.TestField("Receivable Acc. (Dist)");
                    exit(GSTPostingSetup."Receivable Acc. (Dist)");
                end;
            GSTGLAccountType::"Receivable Acc. Interim (Dist)":
                begin
                    GSTPostingSetup.TestField("Receivable Acc. Interim (Dist)");
                    exit(GSTPostingSetup."Receivable Acc. Interim (Dist)");
                end;
            GSTGLAccountType::"Refund Account":
                begin
                    GSTPostingSetup.TestField("Refund Account");
                    exit(GSTPostingSetup."Refund Account");
                end;
            GSTGLAccountType::"Expense Account":
                begin
                    GSTPostingSetup.TestField("Expense Account");
                    exit(GSTPostingSetup."Expense Account");
                end;
            GSTGLAccountType::"Credit Mismatch Account":
                begin
                    GSTPostingSetup.TestField("GST Credit Mismatch Account");
                    exit(GSTPostingSetup."GST Credit Mismatch Account");
                end;
        end;
    end;

    procedure DoesGSTExist(TransactionType: Enum "Detail Ledger Transaction Type"; CVNo: Code[20]; DocumentNo: Code[20]): Boolean
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Source Type", "Source No.", "Document Type", "Document No.", "GST Group Type");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", TransactionType);
        DetailedGSTLedgerEntry.SetRange("Source No.", CVNo);
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("GST Group Type", DetailedGSTLedgerEntry."GST Group Type"::Service);
        DetailedGSTLedgerEntry.SetRange("Associated Enterprises", false);
        exit(not DetailedGSTLedgerEntry.IsEmpty());
    end;

    procedure GetTotalTCSInclSHECessAmount(TransactionNo: Integer) TotalTCSInclSHECess: Decimal
    var
        TaxBaseSubscribers: Codeunit "Tax Base Subscribers";
    begin
        TaxBaseSubscribers.GetTCSAmountFromTransNo(TransactionNo, TotalTCSInclSHECess);
    end;

    procedure GetNextGSTLedgerEntryNo(): Integer
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
    begin
        GSTLedgerEntry.LockTable();
        if GSTLedgerEntry.FindLast() then
            exit(GSTLedgerEntry."Entry No." + 1);

        exit(1);
    end;

    procedure GenJnlDocumentType2OriginalDocumentTypeEnum(GenJournalDocumentType: Enum "Gen. Journal Document Type"): Enum "Original Doc Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Gen. Journal Document Type';
    begin
        case GenJournalDocumentType of
            GenJournalDocumentType::" ":
                exit("Original Doc Type"::" ");
            GenJournalDocumentType::Payment:
                exit("Original Doc Type"::Payment);
            GenJournalDocumentType::Invoice:
                exit("Original Doc Type"::Invoice);
            GenJournalDocumentType::"Credit Memo":
                exit("Original Doc Type"::"Credit Memo");
            GenJournalDocumentType::"Finance Charge Memo":
                exit("Original Doc Type"::"Finance Charge Memo");
            GenJournalDocumentType::"Reminder":
                exit("Original Doc Type"::"Reminder");
            GenJournalDocumentType::"Refund":
                exit("Original Doc Type"::"Refund");
            else
                Error(ConversionErr, GenJournalDocumentType);
        end;
    end;

    procedure GenJnlDocumentType2CurrentDocumentTypeEnum(GenJournalDocumentType: Enum "Gen. Journal Document Type"): Enum "Current Doc. Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Gen. Journal Document Type';
    begin
        case GenJournalDocumentType of
            GenJournalDocumentType::Payment:
                exit("Current Doc. Type"::Payment);
            GenJournalDocumentType::Invoice:
                exit("Current Doc. Type"::Invoice);
            GenJournalDocumentType::"Credit Memo":
                exit("Current Doc. Type"::"Credit Memo");
            GenJournalDocumentType::"Refund":
                exit("Current Doc. Type"::"Refund");
            else
                Error(ConversionErr, GenJournalDocumentType);
        end;
    end;

    procedure OriginalDocumentType2CurrentDocumentTypeEnum(OriginalDocType: Enum "Original Doc Type"): Enum "Current Doc. Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Original Document Type';
    begin
        case OriginalDocType of
            OriginalDocType::Payment:
                exit("Current Doc. Type"::Payment);
            OriginalDocType::Invoice:
                exit("Current Doc. Type"::Invoice);
            OriginalDocType::"Credit Memo":
                exit("Current Doc. Type"::"Credit Memo");
            OriginalDocType::"Refund":
                exit("Current Doc. Type"::"Refund");
            else
                Error(ConversionErr, OriginalDocType);
        end;
    end;

    procedure CurrentDocumentType2OriginalDocumentTypeEnum(CurrentDocType: Enum "Current Doc. Type"): Enum "Original Doc Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Original Document Type';
    begin
        case CurrentDocType of
            CurrentDocType::Payment:
                exit("Original Doc Type"::Payment);
            CurrentDocType::Invoice:
                exit("Original Doc Type"::Invoice);
            CurrentDocType::"Credit Memo":
                exit("Original Doc Type"::"Credit Memo");
            CurrentDocType::"Refund":
                exit("Original Doc Type"::"Refund");
            else
                Error(ConversionErr, CurrentDocType);
        end;
    end;

    local procedure GetCurrencyFactor(DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; InvoiceNo: Code[20]; VendorNo: Code[20]) CurrFactor: Decimal
    var
        DetailedGSTLedgerEntryInv: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntryInv.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntryInv.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntryInv.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntryInv.SetRange("Document No.", InvoiceNo);
        DetailedGSTLedgerEntryInv.SetRange("Source No.", VendorNo);
        DetailedGSTLedgerEntryInv.FindFirst();
        CurrFactor := DetailedGSTLedgerEntryInv."Currency Factor";
        exit(CurrFactor);
    end;

    local procedure GetBaseAmount(
        DocTransType: Enum "Transaction Type Enum";
        DocumentType: Enum "GST Document Type";
        DocumentNo: Code[20];
        CurrentDocument: Boolean) BaseAmount: Decimal
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTBaseAmount: Decimal;
        LineNo: Integer;
    begin
        LineNo := 0;
        if CurrentDocument then begin
            case DocTransType of
                DocTransType::Sales:
                    begin
                        if DocumentNo <> '' then
                            SalesHeader.Get(DocumentType, DocumentNo);

                        SalesLine.Reset();
                        SalesLine.SetRange("Document Type", DocumentType);
                        SalesLine.SetRange("Document No.", DocumentNo);
                        SalesLine.SetFilter(Quantity, '<>%1', 0);
                        if SalesLine.FindSet() then
                            repeat
                                if SalesLine."GST On Assessable Value" then
                                    GSTBaseAmount := SalesLine."GST Assessable Value (LCY)"
                                else
                                    GSTBaseAmount := SalesLine."Line Amount";

                                BaseAmount += GSTBaseAmount * SalesLine."Return Qty. to Receive" / SalesLine.Quantity;
                            until SalesLine.Next() = 0;

                        exit(BaseAmount);
                    end;
            end;
            case DocTransType of
                DocTransType::Service:
                    begin
                        if DocumentNo <> '' then
                            ServiceHeader.Get(DocumentType, DocumentNo);

                        ServiceLine.Reset();
                        ServiceLine.SetRange("Document Type", DocumentType);
                        ServiceLine.SetRange("Document No.", DocumentNo);
                        if ServiceLine.FindSet() then
                            repeat
                                GSTBaseAmount := ServiceLine."Line Amount";
                                BaseAmount += GSTBaseAmount;
                            until ServiceLine.Next() = 0;

                        exit(BaseAmount);
                    end;
            end;
            case DocTransType of
                DocTransType::Purchase:
                    begin
                        if DocumentNo <> '' then
                            PurchaseHeader.Get(DocumentType, DocumentNo);

                        PurchaseLine.Reset();
                        PurchaseLine.SetRange("Document Type", DocumentType);
                        PurchaseLine.SetRange("Document No.", DocumentNo);
                        PurchaseLine.SetFilter(Quantity, '<>%1', 0);
                        if PurchaseLine.FindSet() then
                            repeat
                                GSTBaseAmount := PurchaseLine."Line Amount";
                                BaseAmount += GSTBaseAmount * PurchaseLine."Return Qty. to Ship" / PurchaseLine.Quantity;
                            until PurchaseLine.Next() = 0;

                        exit(BaseAmount);
                    end;
            end;
        end else begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Document Line No.");
            if DocTransType = DocTransType::Purchase then
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase)
            else
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);

            DetailedGSTLedgerEntry.SetRange("Document Type", DocumentType);
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            if DetailedGSTLedgerEntry.FindSet() then
                repeat
                    GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);
                    if not DetailedGSTLedgerEntryInfo.Cess then begin
                        if LineNo <> DetailedGSTLedgerEntry."Document Line No." then
                            BaseAmount += DetailedGSTLedgerEntry."GST Base Amount";

                        LineNo := DetailedGSTLedgerEntry."Document Line No.";
                    end;
                until DetailedGSTLedgerEntry.Next() = 0;

            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Document Line No.");
            if DocTransType = DocTransType::Purchase then
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase)
            else
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);

            DetailedGSTLedgerEntry.SetRange("Original Invoice No.", DocumentNo);
            if DetailedGSTLedgerEntry.FindSet() then
                repeat
                    GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);
                    if not DetailedGSTLedgerEntryInfo.Cess then begin
                        if LineNo <> DetailedGSTLedgerEntry."Document Line No." then
                            BaseAmount += DetailedGSTLedgerEntry."GST Base Amount";

                        LineNo := DetailedGSTLedgerEntry."Document Line No.";
                    end;
                until DetailedGSTLedgerEntry.Next() = 0;

            exit(BaseAmount);
        end;
    end;

    local procedure GetInvoiceBaseAmountLCY(
        var GSTApplicationBuffer: Record "GST Application Buffer";
        var GSTBaseAmount: Decimal;
        var TotalCharges: Decimal;
        var TDSTCSAmount: Decimal;
        var GSTRoundingType: Enum "GST Inv Rounding Type";
        var GSTRounding: Decimal)
    var
        GSTApplicationBuff: Record "GST Application Buffer";
    begin
        GSTApplicationBuff.SetRange("Transaction Type", GSTApplicationBuffer."Transaction Type");
        GSTApplicationBuff.SetRange("Account No.", GSTApplicationBuffer."Account No.");
        GSTApplicationBuff.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type");
        GSTApplicationBuff.SetRange("Original Document No.", GSTApplicationBuffer."Original Document No.");
        GSTApplicationBuff.SetRange("GST Group Code", GSTApplicationBuffer."GST Group Code");
        GSTApplicationBuff.SetRange("GST Cess", false);
        GSTApplicationBuff.SetFilter("GST Base Amount", '<>%1', 0);
        if GSTApplicationBuff.FindFirst() then begin
            GSTBaseAmount := Round(
                ConvertFCYAmountToLCY(
                    GSTApplicationBuff."Currency Code",
                    GSTApplicationBuff."GST Base Amount",
                    GSTApplicationBuff."Currency Factor",
                    GSTApplicationBuff."Posting Date"),
                0.01);

            TotalCharges := GSTApplicationBuff."Charge To Cust/Vend";
            TDSTCSAmount := GSTApplicationBuff."TDS/TCS Amount";
            GSTRounding := GSTApplicationBuff."GST Rounding Precision";
            GSTRoundingType := GSTApplicationBuff."GST Rounding Type";
        end;
    end;

    local procedure VerifyNoOfGSTComponent(GSTApplicationBuffer: Record "GST Application Buffer"; TotalPaymentLine: Integer)
    var
        GSTApplicationBuff: Record "GST Application Buffer";
    begin
        FilterGSTApplicationBuffer(GSTApplicationBuff, GSTApplicationBuffer);
        if TotalPaymentLine <> GSTApplicationBuff.Count then
            Error(MismatchHSNErr, GSTApplicationBuffer."Original Document No.", GSTApplicationBuffer."Applied Doc. No.");
    end;

    local procedure VerifySameGSTComponent(GSTApplicationBuffer: Record "GST Application Buffer")
    var
        GSTApplicationBuff: Record "GST Application Buffer";
    begin
        FilterGSTApplicationBuffer(GSTApplicationBuff, GSTApplicationBuffer);
        GSTApplicationBuff.SetRange("GST Component Code", GSTApplicationBuffer."GST Component Code");
        if GSTApplicationBuff.IsEmpty() then
            Error(MismatchHSNErr, GSTApplicationBuffer."Original Document No.", GSTApplicationBuffer."Applied Doc. No.");
    end;

    local procedure FilterGSTApplicationBuffer(
        var GSTApplicationBuff: Record "GST Application Buffer";
        GSTApplicationBuffer: Record "GST Application Buffer")
    begin
        GSTApplicationBuff.SetRange("Transaction Type", GSTApplicationBuffer."Transaction Type");
        GSTApplicationBuff.SetRange("Account No.", GSTApplicationBuffer."Account No.");
        GSTApplicationBuff.SetRange("Original Document Type", CurrentDocumentType2OriginalDocumentTypeEnum(GSTApplicationBuffer."Applied Doc. Type"));
        GSTApplicationBuff.SetRange("Original Document No.", GSTApplicationBuffer."Applied Doc. No.");
        GSTApplicationBuff.SetRange("GST Group Code", GSTApplicationBuffer."GST Group Code");
    end;

    local procedure GSTApplicationRound(GSTRoudingType: Enum "GST Inv Rounding Type"; GSTRoundingPrecision: Decimal; Amount: Decimal): Decimal
    var
        GSTRoundingDirection: Text[1];
    begin
        case GSTRoudingType of
            GSTRoudingType::Nearest:
                GSTRoundingDirection := '=';
            GSTRoudingType::Up:
                GSTRoundingDirection := '>';
            GSTRoudingType::Down:
                GSTRoundingDirection := '<';
        end;

        if GSTRoundingPrecision = 0 then
            GSTRoundingPrecision := 0.01;

        exit(Round(Amount, GSTRoundingPrecision, GSTRoundingDirection));
    end;

    local procedure GetInvoiceGSTComponentWiseLCY(
        var GSTApplicationBuffer: Record "GST Application Buffer";
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        Base: Boolean): Decimal
    var
        GSTApplicationBuff: Record "GST Application Buffer";
    begin
        FilterGSTApplicationBufferWithOriginalDoc(GSTApplicationBuff, GSTApplicationBuffer, DocumentType, DocumentNo);
        if GSTApplicationBuff.FindFirst() then begin
            if Base then
                exit(GSTApplicationBuff."GST Base Amount(LCY)");

            exit(GSTApplicationBuff."GST Amount(LCY)");
        end;
    end;

    local procedure AdjustPaymentAmount(
        TransactionType: Enum "Detail Ledger Transaction Type";
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        AccountNo: Code[20];
        PaymentGSTGroupCode: Code[20];
        AmountToApply: Decimal;
        var PaymentAmount: Decimal;
        RemainingAmount: Decimal;
        TotalInvoiceAmount: Decimal;
        GSTRoundingPrecision: Decimal)
    var
        GSTApplicationBuffer: Record "GST Application Buffer";
    begin
        if (TransactionType = TransactionType::Sales) and (Abs(PaymentAmount) < Abs(AmountToApply)) and
           (Abs(RemainingAmount) >= Abs(AmountToApply)) and
           (PaymentAmount <> 0) and (Abs(AmountToApply) - Abs(PaymentAmount) > 0) and
           (Abs(AmountToApply) - Abs(PaymentAmount) <= 1) and
           (GSTRoundingPrecision > 0.1) and (Abs(TotalInvoiceAmount) >= Abs(PaymentAmount))
        then begin
            GSTApplicationBuffer.Reset();
            GSTApplicationBuffer.SetRange("Transaction Type", TransactionType);
            GSTApplicationBuffer.SetRange("Account No.", AccountNo);
            GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Payment);
            GSTApplicationBuffer.SetRange("Applied Doc. Type", GenJnlDocumentType2CurrentDocumentTypeEnum(DocumentType));
            GSTApplicationBuffer.SetRange("Applied Doc. No.", DocumentNo);
            GSTApplicationBuffer.SetRange("GST Group Code", PaymentGSTGroupCode);
            if GSTApplicationBuffer.FindSet() then begin
                repeat
                    if GSTApplicationBuffer."Applied Base Amount" < 0 then
                        GSTApplicationBuffer."Applied Base Amount" -= Abs(AmountToApply) - Abs(PaymentAmount)
                    else
                        GSTApplicationBuffer."Applied Base Amount" += Abs(AmountToApply) - Abs(PaymentAmount);

                    GSTApplicationBuffer.Modify(true);
                until GSTApplicationBuffer.Next() = 0;

                if PaymentAmount < 0 then
                    PaymentAmount -= Abs(AmountToApply) - Abs(PaymentAmount)
                else
                    PaymentAmount += Abs(AmountToApply) - Abs(PaymentAmount);
            end;
        end else
            if (TransactionType = TransactionType::Sales) and (Abs(RemainingAmount) >= Abs(AmountToApply)) and
                (PaymentAmount <> 0) and (TotalInvoiceAmount <> 0) and
                (Abs(PaymentAmount) - Abs(TotalInvoiceAmount) > 0) and
                (Abs(PaymentAmount) - Abs(TotalInvoiceAmount) <= 1) and
                (GSTRoundingPrecision > 0.1) and (Abs(TotalInvoiceAmount) < Abs(PaymentAmount))
            then begin
                GSTApplicationBuffer.Reset();
                GSTApplicationBuffer.SetRange("Transaction Type", TransactionType);
                GSTApplicationBuffer.SetRange("Account No.", AccountNo);
                GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Payment);
                GSTApplicationBuffer.SetRange("Applied Doc. Type", GenJnlDocumentType2CurrentDocumentTypeEnum(DocumentType));
                GSTApplicationBuffer.SetRange("Applied Doc. No.", DocumentNo);
                GSTApplicationBuffer.SetRange("GST Group Code", PaymentGSTGroupCode);
                if GSTApplicationBuffer.FindSet() then begin
                    repeat
                        if GSTApplicationBuffer."Applied Base Amount" < 0 then
                            GSTApplicationBuffer."Applied Base Amount" += Abs(PaymentAmount) - Abs(TotalInvoiceAmount)
                        else
                            GSTApplicationBuffer."Applied Base Amount" -= Abs(PaymentAmount) - Abs(TotalInvoiceAmount);

                        GSTApplicationBuffer.Modify(true);
                    until GSTApplicationBuffer.Next() = 0;

                    if PaymentAmount < 0 then
                        PaymentAmount += Abs(PaymentAmount) - Abs(TotalInvoiceAmount)
                    else
                        PaymentAmount -= Abs(PaymentAmount) - Abs(TotalInvoiceAmount);
                end;
            end;
    end;

    local procedure GetInvoiceBaseAmount(
        var GSTApplicationBuffer: Record "GST Application Buffer";
        var GSTBaseAmount: Decimal;
        var TotalCharges: Decimal;
        var TDSTCSAmount: Decimal;
        var GSTRoundingType: Enum "GST Inv Rounding Type";
        var GSTRounding: Decimal)
    var
        GSTApplicationBuff: Record "GST Application Buffer";
    begin
        GSTApplicationBuff.SetRange("Transaction Type", GSTApplicationBuffer."Transaction Type");
        GSTApplicationBuff.SetRange("Account No.", GSTApplicationBuffer."Account No.");
        GSTApplicationBuff.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type");
        GSTApplicationBuff.SetRange("Original Document No.", GSTApplicationBuffer."Original Document No.");
        GSTApplicationBuff.SetRange("GST Group Code", GSTApplicationBuffer."GST Group Code");
        GSTApplicationBuff.SetRange("GST Cess", false);
        GSTApplicationBuff.SetFilter("GST Base Amount", '<>%1', 0);
        if GSTApplicationBuff.FindFirst() then begin
            GSTBaseAmount := GSTApplicationBuff."GST Base Amount";
            TotalCharges := GSTApplicationBuff."Charge To Cust/Vend";
            TDSTCSAmount := GSTApplicationBuff."TDS/TCS Amount";
            GSTRounding := GSTApplicationBuff."GST Rounding Precision";
            GSTRoundingType := GSTApplicationBuff."GST Rounding Type";
        end;
    end;

    local procedure GetInvoiceGSTComponentWise(
        var GSTApplicationBuffer: Record "GST Application Buffer";
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        IsBase: Boolean): Decimal
    var
        GSTApplicationBuff: Record "GST Application Buffer";
    begin
        FilterGSTApplicationBufferWithOriginalDoc(GSTApplicationBuff, GSTApplicationBuffer, DocumentType, DocumentNo);
        if GSTApplicationBuff.FindFirst() then begin
            if IsBase then
                exit(GSTApplicationBuff."GST Base Amount");

            exit(GSTApplicationBuff."GST Amount");
        end;
    end;

    local procedure FilterGSTApplicationBufferWithOriginalDoc(
        var GSTApplicationBuff: Record "GST Application Buffer";
        GSTApplicationBuffer: Record "GST Application Buffer";
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20])
    var
        OriginalDocumentType: Enum "Original Doc Type";
    begin
        OriginalDocumentType := GenJnlDocumentType2OriginalDocumentTypeEnum(DocumentType);
        GSTApplicationBuff.SetRange("Transaction Type", GSTApplicationBuffer."Transaction Type");
        GSTApplicationBuff.SetRange("Account No.", GSTApplicationBuffer."Account No.");
        GSTApplicationBuff.SetRange("Original Document Type", OriginalDocumentType);
        GSTApplicationBuff.SetRange("Original Document No.", DocumentNo);
        GSTApplicationBuff.SetRange("GST Component Code", GSTApplicationBuffer."GST Component Code");
        GSTApplicationBuff.SetRange("GST Group Code", GSTApplicationBuffer."GST Group Code");
    end;

    local procedure InitiateGSTApplicationBufferStage(
        var GSTApplicationBufferStage: Record "GST Application Buffer";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry")
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);
        if DetailedGSTLedgerEntryInfo.FindFirst() then begin
            GSTApplicationBufferStage."GST Cess" := DetailedGSTLedgerEntryInfo.Cess;
            GSTApplicationBufferStage."CLE/VLE Entry No." := DetailedGSTLedgerEntryInfo."CLE/VLE Entry No.";
        end;

        GSTApplicationBufferStage."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type";
        GSTApplicationBufferStage."Transaction No." := DetailedGSTLedgerEntry."Transaction No.";
        GSTApplicationBufferStage."GST Group Code" := DetailedGSTLedgerEntry."GST Group Code";
        GSTApplicationBufferStage."GST %" := DetailedGSTLedgerEntry."GST %";
        GSTApplicationBufferStage."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
        GSTApplicationBufferStage."Current Doc. Type" := DetailedGSTLedgerEntry."Document Type";
        GSTApplicationBufferStage."GST Group Type" := DetailedGSTLedgerEntry."GST Group Type";
        GSTApplicationBufferStage."Currency Code" := DetailedGSTLedgerEntry."Currency Code";
        GSTApplicationBufferStage."Currency Factor" := DetailedGSTLedgerEntry."Currency Factor";
        GSTApplicationBufferStage."GST Rounding Precision" := DetailedGSTLedgerEntry."GST Rounding Precision";
        GSTApplicationBufferStage."GST Rounding Type" := DetailedGSTLedgerEntry."GST Rounding Type";
        GSTApplicationBufferStage."GST Inv. Rounding Precision" := DetailedGSTLedgerEntry."GST Inv. Rounding Precision";
        GSTApplicationBufferStage."GST Inv. Rounding Type" := DetailedGSTLedgerEntry."GST Inv. Rounding Type";
        GSTApplicationBufferStage."Posting Date" := DetailedGSTLedgerEntry."Posting Date";
    end;

    local procedure ConvertFCYAmountToLCY(CurrencyCode: Code[10]; Amount: Decimal; CurrencyFactor: Decimal; PostingDate: Date): Decimal
    var
        GLSetup: Record "General Ledger Setup";
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        GLSetup.Get();
        if CurrencyCode = '' then
            exit(Amount);

        exit(CurrExchRate.ExchangeAmtFCYToLCY(PostingDate, CurrencyCode, Amount, CurrencyFactor));
    end;

    local procedure ConvertLCYAmountToFCY(CurrencyCode: Code[10]; Amount: Decimal; CurrencyFactor: Decimal; PostingDate: Date): Decimal
    var
        GLSetup: Record "General Ledger Setup";
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        GLSetup.Get();
        if CurrencyCode = '' then
            exit(Amount);

        exit(CurrExchRate.ExchangeAmtLCYToFCY(PostingDate, CurrencyCode, Amount, CurrencyFactor));
    end;

    local procedure GetLastClosedSubAccPeriod(): Date
    var
        GSTAccountingSubPeriod: Record "Tax Accounting Period";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");

        GSTAccountingSubPeriod.SetRange("Tax Type Code", GSTSetup."GST Tax Type");
        GSTAccountingSubPeriod.SetRange(Closed, true);
        if GSTAccountingSubPeriod.FindLast() then
            exit(GSTAccountingSubPeriod."Starting Date");
    end;

    local procedure GetGSTComponentID(GSTComponentCode: Code[30]): Integer
    var
        TaxComponent: Record "Tax Component";
    begin
        TaxComponent.SetRange(Name, GSTComponentCode);
        TaxComponent.FindFirst();
        exit(TaxComponent.Id);
    end;

    local procedure UpdateGSTApplicationBuffer(GSTApplicationBufferStage: Record "GST Application Buffer")
    var
        GSTApplicationBufferFinal: Record "GST Application Buffer";
    begin
        ApplyFilterOnGSTApplicationBuffer(GSTApplicationBufferFinal, GSTApplicationBufferStage);
        if GSTApplicationBufferFinal.FindFirst() then begin
            GSTApplicationBufferFinal."GST Base Amount" += GSTApplicationBufferStage."GST Base Amount";
            GSTApplicationBufferFinal."GST Amount" += GSTApplicationBufferStage."GST Amount";
            GSTApplicationBufferFinal."GST Base Amount(LCY)" += GSTApplicationBufferStage."GST Base Amount(LCY)";
            GSTApplicationBufferFinal."GST Amount(LCY)" += GSTApplicationBufferStage."GST Amount(LCY)";
            GSTApplicationBufferFinal.Modify(true);
        end else begin
            GSTApplicationBufferFinal := GSTApplicationBufferStage;
            GSTApplicationBufferFinal.Insert(true);
        end;
    end;

    local procedure ApplyFilterOnGSTApplicationBuffer(var GSTApplicationBufferFinal: Record "GST Application Buffer"; GSTApplicationBufferStage: Record "GST Application Buffer")
    begin
        GSTApplicationBufferFinal.SetRange("Transaction Type", GSTApplicationBufferStage."Transaction Type");
        GSTApplicationBufferFinal.SetRange("Account No.", GSTApplicationBufferStage."Account No.");
        GSTApplicationBufferFinal.SetRange("Original Document Type", GSTApplicationBufferStage."Original Document Type");
        GSTApplicationBufferFinal.SetRange("Original Document No.", GSTApplicationBufferStage."Original Document No.");
        GSTApplicationBufferFinal.SetRange("GST Group Code", GSTApplicationBufferStage."GST Group Code");
        GSTApplicationBufferFinal.SetRange("GST Component Code", GSTApplicationBufferStage."GST Component Code");
    end;

    procedure GetDetailedGSTLedgerEntryInfo(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        var DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info")
    begin
        DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateAppliedAmounts(
        TotalInvoiceAmount: Decimal;
        AmountToApply: Decimal;
        TDSTCS: Decimal;
        var GSTApplicationBuffer: Record "GST Application Buffer";
        var IsHandled: Boolean)
    begin
    end;
}
