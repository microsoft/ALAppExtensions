// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Subcontracting;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

codeunit 18430 "GST Application Handler"
{
    var
        OnlineVendorLedgerEntry: Record "Vendor Ledger Entry";
        OnlineCustLedgerEntry: Record "Cust. Ledger Entry";
        GSTPostingBuffer: array[2] of Record "GST Posting Buffer" temporary;
        GSTApplSessionMgt: Codeunit "GST Application Session Mgt.";
        GSTPurchaseApplicationMgt: Codeunit "GST Purchase Application Mgt.";
        GSTSalesApplicationMgt: Codeunit "GST Sales Application Mgt.";
        GSTApplicationLibrary: Codeunit "GST Application Library";
        GSTTransactionType: Enum "Detail Ledger Transaction Type";
        TransactionNo: Integer;
        UnApplicationErr: Label 'Unapplication is not allowed as Credit Adjustment is posted against this transaction.';
        GSTInvoiceLiabilityErr: Label 'Cr. & Libty. Adjustment Type should be Liability Reverse or Blank.';

    local procedure SetGSTApplicationSourcePurch(
        var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
        var GenJnlLine: Record "Gen. Journal Line";
        Vend: Record Vendor)
    begin
        if (GenJnlLine."Applies-to ID" <> '') or (GenJnlLine."Applies-to Doc. No." <> '') then
            GenJnlLine.TestField("GST on Advance Payment", false);

        GSTApplSessionMgt.SetGSTApplicationSourcePurch(NewCVLedgEntryBuf."Transaction No.", Vend."No.");
    end;

    local procedure SetGSTApplicationSourceSales(
        var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
        var GenJnlLine: Record "Gen. Journal Line";
        Cust: Record Customer)
    begin
        if (GenJnlLine."Applies-to ID" <> '') or (GenJnlLine."Applies-to Doc. No." <> '') then
            GenJnlLine.TestField("GST on Advance Payment", false);

        GSTApplSessionMgt.SetGSTApplicationSourceSales(NewCVLedgEntryBuf."Transaction No.", Cust."No.");
    end;

    local procedure SetGSTApplicationAmount(
        AppliedAmount: Decimal;
        AppliedAmountLCY: Decimal)
    begin
        GSTApplSessionMgt.SetGSTApplicationAmount(AppliedAmount, AppliedAmountLCY);
    end;

    local procedure SetOnlineCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        GSTApplSessionMgt.SetOnlineCustLedgerEntry(CustLedgerEntry);
    end;

    local procedure SetOnlineVendLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        GSTApplSessionMgt.SetOnlineVendLedgerEntry(VendorLedgerEntry);
    end;

    local procedure PostGSTPurchaseApplication(
        var GenJournalLine: Record "Gen. Journal Line";
        var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        var OldCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        AmountToApply: Decimal)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        InvoiceGSTAmount: Decimal;
        InvoiceBase: Decimal;
        TotalTDSInclSHECessAmount: Decimal;
    begin
        if AmountToApply = 0 then
            exit;

        if GenJournalLine."Document Type" = GenJournalLine."Document Type"::Refund then
            exit;

        if GenJournalLine."Offline Application" then begin
            if not VendorLedgerEntry.Get(CVLedgerEntryBuffer."Entry No.") then
                exit;

            if not ApplyingVendorLedgerEntry.Get(OldCVLedgerEntryBuffer."Entry No.") then
                exit;

            if VendorLedgerEntry."GST on Advance Payment" and VendorLedgerEntry."GST Reverse Charge" then begin
                GSTPurchaseApplicationMgt.GetPurchaseInvoiceAmountOffline(
                    VendorLedgerEntry,
                    ApplyingVendorLedgerEntry,
                    GenJournalLine,
                    ApplyingVendorLedgerEntry."Total TDS Including SHE CESS");

                if OldCVLedgerEntryBuffer."Currency Code" <> '' then
                    GSTApplicationLibrary.GetApplicationRemainingAmountLCYForPurchase(
                        ApplyingVendorLedgerEntry,
                        VendorLedgerEntry,
                        AmountToApply,
                        CVLedgerEntryBuffer."Remaining Amt. (LCY)",
                        InvoiceGSTAmount,
                        InvoiceBase)
                else
                    GSTApplicationLibrary.GetApplicationRemainingAmountForPurchase(
                        ApplyingVendorLedgerEntry,
                        VendorLedgerEntry,
                        AmountToApply,
                        CVLedgerEntryBuffer."Remaining Amt. (LCY)",
                        InvoiceBase);

                GSTApplicationLibrary.CheckGroupAmount(
                    ApplyingVendorLedgerEntry."Document Type",
                    ApplyingVendorLedgerEntry."Document No.",
                    AmountToApply,
                    InvoiceBase,
                    VendorLedgerEntry."GST Group Code");

                PostPurchaseGSTApplicationGL(
                    GenJournalLine,
                    VendorLedgerEntry."Document No.",
                    ApplyingVendorLedgerEntry."Document No.",
                    VendorLedgerEntry."Entry No.",
                    VendorLedgerEntry."GST Group Code");
            end else
                if ApplyingVendorLedgerEntry."GST on Advance Payment" and ApplyingVendorLedgerEntry."GST Reverse Charge" then begin
                    GSTPurchaseApplicationMgt.GetPurchaseInvoiceAmountWithPaymentOffline(
                        VendorLedgerEntry,
                        ApplyingVendorLedgerEntry,
                        GenJournalLine,
                        VendorLedgerEntry."Total TDS Including SHE CESS");

                    if OldCVLedgerEntryBuffer."Currency Code" <> '' then
                        GSTApplicationLibrary.GetApplicationRemainingAmountLCYForPurchase(
                            VendorLedgerEntry,
                            ApplyingVendorLedgerEntry,
                            AmountToApply,
                            OldCVLedgerEntryBuffer."Amount (LCY)",
                            InvoiceGSTAmount,
                            InvoiceBase)
                    else
                        GSTApplicationLibrary.GetApplicationRemainingAmountForPurchase(
                            VendorLedgerEntry,
                            ApplyingVendorLedgerEntry,
                            AmountToApply,
                            OldCVLedgerEntryBuffer."Amount (LCY)",
                            InvoiceBase);

                    GSTApplicationLibrary.CheckGroupAmount(
                        VendorLedgerEntry."Document Type",
                        VendorLedgerEntry."Document No.",
                        AmountToApply,
                        InvoiceBase,
                        ApplyingVendorLedgerEntry."GST Group Code");

                    PostPurchaseGSTApplicationGL(
                        GenJournalLine,
                        ApplyingVendorLedgerEntry."Document No.",
                        VendorLedgerEntry."Document No.",
                        ApplyingVendorLedgerEntry."Entry No.",
                        ApplyingVendorLedgerEntry."GST Group Code");
                end else
                    PostGSTWithNormalPaymentOffline(GenJournalLine, CVLedgerEntryBuffer, OldCVLedgerEntryBuffer, AmountToApply);

            GSTApplSessionMgt.PostApplicationGenJournalLine(GenJnlPostLine);
        end else begin
            if not ApplyingVendorLedgerEntry.Get(OldCVLedgerEntryBuffer."Entry No.") then
                exit;

            GSTApplSessionMgt.GetOnlineVendLedgerEntry(OnlineVendorLedgerEntry);

            if ApplyingVendorLedgerEntry."GST on Advance Payment" then begin
                TotalTDSInclSHECessAmount := GSTApplSessionMgt.GetTotalTDSInclSHECessAmount();
                GSTPurchaseApplicationMgt.GetPurchaseInvoiceAmountWithPaymentOffline(
                    OnlineVendorLedgerEntry,
                    ApplyingVendorLedgerEntry,
                    GenJournalLine,
                    TotalTDSInclSHECessAmount);

                if OldCVLedgerEntryBuffer."Currency Code" <> '' then
                    GSTApplicationLibrary.GetApplicationRemainingAmountLCYForPurchase(
                        OnlineVendorLedgerEntry,
                        ApplyingVendorLedgerEntry,
                        AmountToApply,
                        OldCVLedgerEntryBuffer."Amount (LCY)",
                        InvoiceGSTAmount,
                        InvoiceBase)
                else
                    GSTApplicationLibrary.GetApplicationRemainingAmountForPurchase(
                            OnlineVendorLedgerEntry,
                            ApplyingVendorLedgerEntry,
                            AmountToApply,
                            OldCVLedgerEntryBuffer."Amount (LCY)",
                            InvoiceBase);

                GSTApplicationLibrary.CheckGroupAmountJnl(
                    OnlineVendorLedgerEntry."Document Type",
                    OnlineVendorLedgerEntry."Document No.",
                    AmountToApply,
                    InvoiceBase,
                    ApplyingVendorLedgerEntry."GST Group Code");

                PostPurchaseGSTApplicationGL(
                    GenJournalLine,
                    ApplyingVendorLedgerEntry."Document No.",
                    OnlineVendorLedgerEntry."Document No.",
                    ApplyingVendorLedgerEntry."Entry No.",
                    ApplyingVendorLedgerEntry."GST Group Code");
            end else
                PostGSTWithNormalPaymentOnline(GenJournalLine, CVLedgerEntryBuffer, OldCVLedgerEntryBuffer, AmountToApply);
        end;
    end;

    local procedure PostPurchaseGSTApplicationGL(
        var GenJournalLine: Record "Gen. Journal Line";
        PaymentDocNo: Code[20];
        InvoiceNo: Code[20];
        PaymentEntryNo: Integer;
        GSTGroupCode: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        GSTApplicationBuffer: Record "GST Application Buffer";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        SourceCodeSetup.Get();
        GSTApplicationBuffer.SetRange("Transaction Type", GSTApplicationBuffer."Transaction Type"::Purchase);
        GSTApplicationBuffer.SetRange("Account No.", GenJournalLine."Account No.");
        GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Payment);
        GSTApplicationBuffer.SetRange("Original Document No.", PaymentDocNo);
        GSTApplicationBuffer.SetRange("Applied Doc. Type", GSTApplicationBuffer."Applied Doc. Type"::Invoice);
        GSTApplicationBuffer.SetRange("Applied Doc. No.", InvoiceNo);
        GSTApplicationBuffer.SetRange("GST Group Code", GSTGroupCode);
        if GSTApplicationBuffer.FindSet() then
            repeat
                UpdateApplyDetailedGSTLedgerEntryPurchTables(GenJournalLine, Invoiceno, PaymentEntryNo, GSTApplicationBuffer, SourceCodeSetup);
            until GSTApplicationBuffer.Next() = 0;

        GSTApplicationLibrary.DeletePaymentAplicationBuffer(TransactionType::Purchase, PaymentEntryNo);
        GSTApplicationLibrary.DeleteInvoiceApplicationBufferOffline(
            TransactionType::Purchase,
            GenJournalLine."Account No.",
            GSTApplicationBuffer."Original Document Type"::Invoice,
            InvoiceNo);
    end;

    local procedure UpdateApplyDetailedGSTLedgerEntryPurchTables(
        var GenJournalLine: Record "Gen. Journal Line";
        InvoiceNo: Code[20];
        PaymentEntryNo: Integer;
        GSTApplicationBuffer: Record "GST Application Buffer";
        SourceCodeSetup: Record "Source Code Setup")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        ApplyDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ApplyDetailedGSTLedgerEntryNew: Record "Detailed GST Ledger Entry";
        GSTApplicationBufferToCheck: Record "GST Application Buffer";
        AccountNo: Code[20];
        BalanceAccountNo: Code[20];
        BalanceAccountNo2: Code[20];
        AppliedBase: Decimal;
        AppliedAmount: Decimal;
        RemainingBase: Decimal;
        RemainingAmount: Decimal;
        ApplicableRemainingGSTAmount: Decimal;
        ApplicationRatio: Decimal;
        AppliedBaseAmountInvoiceLCY: Decimal;
        AppliedAmountInvoiceLCY: Decimal;
        HigherInvoiceExchangeRate: Boolean;
    begin
        DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Source No.", "Document Type", "Document No.", "GST Group Code");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Source No.", GenJournalLine."Account No.");
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);

        if GenJournalLine."Purch. Invoice Type" = GenJournalLine."Purch. Invoice Type"::" " then
            DetailedGSTLedgerEntry.SetRange("Document No.", GSTApplicationBuffer."Applied Doc. No.")
        else
            DetailedGSTLedgerEntry.SetRange("Document No.", GenJournalLine."Old Document No.");

        DetailedGSTLedgerEntry.SetRange("GST Group Code", GSTApplicationBuffer."GST Group Code");
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("GST Component Code", GSTApplicationBuffer."GST Component Code");
        DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", false);
        if DetailedGSTLedgerEntry.FindSet() then begin
            RemainingBase := GSTApplicationBuffer."Applied Base Amount";
            RemainingAmount := GSTApplicationBuffer."Applied Amount";
            GSTPostingBuffer[1].DeleteAll();
            GSTApplicationLibrary.CheckGSTAccountingPeriod(GenJournalLine."Posting Date", false);

            repeat
                GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);
                if (not DetailedGSTLedgerEntryInfo."Remaining Amount Closed") and
                    (RemainingBase <> 0) and
                    (DetailedGSTLedgerEntry."Remaining Base Amount" > 0)
                then begin
                    Clear(ApplicableRemainingGSTAmount);
                    if DetailedGSTLedgerEntryInfo."RCM Exempt Transaction" then
                        ApplicableRemainingGSTAmount :=
                            DetailedGSTLedgerEntry."Remaining Base Amount" * GSTApplicationBuffer."Applied Amount" / GSTApplicationBuffer."Applied Base Amount"
                    else
                        ApplicableRemainingGSTAmount := DetailedGSTLedgerEntry."Remaining GST Amount";

                    ApplicationRatio := 1;
                    if (GSTApplicationBuffer."Currency Factor" <> DetailedGSTLedgerEntry."Currency Factor") and
                       (GSTApplicationBuffer."Currency Factor" > DetailedGSTLedgerEntry."Currency Factor") and
                       (DetailedGSTLedgerEntry."GST Group Type" = DetailedGSTLedgerEntry."GST Group Type"::Service)
                    then begin
                        GSTApplicationBufferToCheck.SetRange("Transaction Type", GSTApplicationBufferToCheck."Transaction Type"::Purchase);
                        GSTApplicationBufferToCheck.SetRange("Account No.", GSTApplicationBuffer."Account No.");
                        GSTApplicationBufferToCheck.SetRange("Original Document Type", GSTApplicationLibrary.CurrentDocumentType2OriginalDocumentTypeEnum(GSTApplicationBuffer."Applied Doc. Type"));
                        GSTApplicationBufferToCheck.SetRange("Original Document No.", GSTApplicationBuffer."Applied Doc. No.");
                        GSTApplicationBufferToCheck.SetRange("Applied Doc. Type", GSTApplicationBuffer."Applied Doc. Type"::Payment);
                        GSTApplicationBufferToCheck.SetRange("Applied Doc. No.", GSTApplicationBuffer."Original Document No.");
                        GSTApplicationBufferToCheck.SetRange("GST Group Code", GSTApplicationBuffer."GST Group Code");
                        GSTApplicationBufferToCheck.SetRange("GST Component Code", GSTApplicationBuffer."GST Component Code");
                        if GSTApplicationBufferToCheck.FindFirst() then
                            ApplicationRatio :=
                                GSTApplicationBuffer."Total Base(LCY)" / Round(GSTApplicationBuffer."Amt to Apply" / GSTApplicationBufferToCheck."Currency Factor");
                    end;

                    GSTApplicationLibrary.GetAppliedAmount(
                        Abs(RemainingBase),
                        Abs(RemainingAmount),
                        Abs(DetailedGSTLedgerEntry."Remaining Base Amount" * ApplicationRatio),
                        Abs(ApplicableRemainingGSTAmount * ApplicationRatio), AppliedBase, AppliedAmount);

                    CreateDetailedGSTApplicationEntry(
                        ApplyDetailedGSTLedgerEntry,
                        DetailedGSTLedgerEntry,
                        GenJournalLine,
                        InvoiceNo,
                        AppliedBase,
                        Round(AppliedAmount));

                    ApplyDetailedGSTLedgerEntry.Insert(true);

                    CreateDetailedGSTApplicationEntryInfo(
                        ApplyDetailedGSTLedgerEntry,
                        DetailedGSTLedgerEntry,
                        GSTApplicationBuffer."Original Document No.",
                        DetailedGSTLedgerEntryInfo."RCM Exempt Transaction");

                    UpdateDetailedGSTApplicationEntry(ApplyDetailedGSTLedgerEntry, PaymentEntryNo, DetailedGSTLedgerEntryInfo."RCM Exempt Transaction");

                    AppliedBaseAmountInvoiceLCY := 0;
                    HigherInvoiceExchangeRate := false;
                    AppliedBaseAmountInvoiceLCY := CalculateAndFillGSTPostingBufferForexFluctuation(GSTApplicationBuffer, 0, HigherInvoiceExchangeRate);

                    if AppliedBaseAmountInvoiceLCY <> 0 then begin
                        AppliedBaseAmountInvoiceLCY := Abs(AppliedBaseAmountInvoiceLCY) - Abs(GSTApplicationBuffer."Applied Base Amount");
                        GSTApplicationBuffer."Amt to Apply (Applied)" :=
                            GSTApplicationBuffer."Amt to Apply" / Abs(GSTApplicationBuffer."Applied Base Amount") * AppliedBase;
                        GSTApplicationBuffer.Modify();

                        AppliedBaseAmountInvoiceLCY := Round(
                            Abs(AppliedBaseAmountInvoiceLCY * GSTApplicationBuffer."Amt to Apply (Applied)" / GSTApplicationBuffer."Amt to Apply"));
                        AppliedAmountInvoiceLCY := Round(AppliedBaseAmountInvoiceLCY * GSTApplicationBuffer."GST %" / 100);

                        CreateDetailedGSTApplicationEntry(
                            ApplyDetailedGSTLedgerEntryNew,
                            DetailedGSTLedgerEntry,
                            GenJournalLine,
                            InvoiceNo,
                            AppliedBaseAmountInvoiceLCY,
                            AppliedAmountInvoiceLCY);

                        UpdateDetailedGSTApplicationEntryForex(
                            ApplyDetailedGSTLedgerEntryNew,
                            GSTApplicationBuffer."Currency Factor",
                            DetailedGSTLedgerEntry."Currency Factor");

                        ApplyDetailedGSTLedgerEntryNew.Insert(true);

                        CreateDetailedGSTApplicationEntryInfo(
                            ApplyDetailedGSTLedgerEntryNew,
                            DetailedGSTLedgerEntry,
                            GSTApplicationBuffer."Original Document No.",
                            DetailedGSTLedgerEntryInfo."RCM Exempt Transaction");

                        FillGSTPostingBufferWithApplication(ApplyDetailedGSTLedgerEntryNew, true, HigherInvoiceExchangeRate);
                    end;

                    GSTApplicationLibrary.GetApplicationDocTypeFromGSTDocumentType(
                        DetailedGSTLedgerEntry."Application Doc. Type",
                        ApplyDetailedGSTLedgerEntry."Document Type");
                    DetailedGSTLedgerEntry."Application Doc. No" := ApplyDetailedGSTLedgerEntry."Document No.";

                    if (GSTApplicationBuffer."Currency Factor" <> DetailedGSTLedgerEntry."Currency Factor") and
                       (GSTApplicationBuffer."Currency Factor" > DetailedGSTLedgerEntry."Currency Factor")
                    then begin
                        DetailedGSTLedgerEntry."Remaining Base Amount" -= AppliedBase + AppliedBaseAmountInvoiceLCY;
                        if not GSTApplicationBuffer."RCM Exempt" then
                            DetailedGSTLedgerEntry."Remaining GST Amount" -= AppliedAmount + AppliedAmountInvoiceLCY;
                    end else begin
                        DetailedGSTLedgerEntry."Remaining Base Amount" -= AppliedBase;
                        if not GSTApplicationBuffer."RCM Exempt" then
                            DetailedGSTLedgerEntry."Remaining GST Amount" -= AppliedAmount;
                    end;

                    DetailedGSTLedgerEntry.Modify();

                    RemainingBase := Abs(RemainingBase) - Abs(AppliedBase);
                    RemainingAmount := Abs(RemainingAmount) - Abs(AppliedAmount);
                    FillGSTPostingBufferWithApplication(ApplyDetailedGSTLedgerEntry, false, false);
                end;
            until DetailedGSTLedgerEntry.Next() = 0;

            if GSTPostingBuffer[1].FindLast() then
                repeat
                    GetCreditAccountAdvancePayment(DetailedGSTLedgerEntry, GSTPostingBuffer[1], AccountNo, BalanceAccountNo, BalanceAccountNo2);
                    CreateApplicationGSTLedger(
                        GSTPostingBuffer[1],
                        ApplyDetailedGSTLedgerEntry,
                        GenJournalLine."Posting Date",
                        SourceCodeSetup."Purchase Entry Application",
                        ApplyDetailedGSTLedgerEntry."Payment Type",
                        AccountNo,
                        BalanceAccountNo,
                        BalanceAccountNo2,
                        '');

                    PostPurchaseApplicationGLEntries(
                        GenJournalLine,
                        false,
                        AccountNo,
                        BalanceAccountNo,
                        BalanceAccountNo2,
                        GSTPostingBuffer[1]."GST Amount",
                        DetailedGSTLedgerEntryInfo."RCM Exempt Transaction");
                until GSTPostingBuffer[1].Next(-1) = 0;
        end;
    end;

    local procedure PostGSTWithNormalPaymentOffline(
        var GenJournalLine: Record "Gen. Journal Line";
        var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        var OldCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        AmountToApply: Decimal)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry";
        TransactionType: Enum "Detail Ledger Transaction Type";
        IsHandled: Boolean;
    begin
        OnBeforePostGSTWithNormalPaymentOffline(GenJournalLine, AmountToApply, IsHandled);
        if IsHandled then
            exit;

        if not ApplyingVendorLedgerEntry.Get(OldCVLedgerEntryBuffer."Entry No.") then
            exit;

        if not VendorLedgerEntry.Get(CVLedgerEntryBuffer."Entry No.") then
            exit;

        case ApplyingVendorLedgerEntry."Document Type" of
            ApplyingVendorLedgerEntry."Document Type"::Invoice:
                begin
                    if VendorLedgerEntry."GST on Advance Payment" then
                        exit;

                    if not ApplyingVendorLedgerEntry."GST Reverse Charge" then
                        exit;

                    if not GSTApplicationLibrary.DoesGSTExist(TransactionType::Purchase, ApplyingVendorLedgerEntry."Vendor No.", ApplyingVendorLedgerEntry."Document No.") then
                        exit;

                    VendorLedgerEntry.TestField("Document Type", VendorLedgerEntry."Document Type"::Payment);
                    ApplyingVendorLedgerEntry.TestField("Currency Code", VendorLedgerEntry."Currency Code");
                    if VendorLedgerEntry."GST Group Code" <> '' then
                        ApplyingVendorLedgerEntry.TestField("TDS Section Code", VendorLedgerEntry."TDS Section Code");

                    if not GSTApplicationLibrary.FillAppBufferInvoice(
                        TransactionType::Purchase,
                        ApplyingVendorLedgerEntry."Document No.",
                        ApplyingVendorLedgerEntry."Vendor No.",
                        VendorLedgerEntry."Document No.",
                        ApplyingVendorLedgerEntry."Total TDS Including SHE CESS",
                        AmountToApply,
                        VendorLedgerEntry."Original Currency Factor")
                    then
                        exit;

                    GSTApplicationLibrary.AllocateGSTWithNormalPayment(ApplyingVendorLedgerEntry."Vendor No.", ApplyingVendorLedgerEntry."Document No.", AmountToApply);
                    PostPurchGSTApplicationNormalPaymentGL(
                      GenJournalLine,
                      VendorLedgerEntry."Document No.",
                      ApplyingVendorLedgerEntry."Document No.",
                      VendorLedgerEntry."RCM Exempt",
                      VendorLedgerEntry."Original Currency Factor",
                      Round(Abs(OldCVLedgerEntryBuffer."Amount to Apply" / VendorLedgerEntry."Original Currency Factor")));
                end;
            ApplyingVendorLedgerEntry."Document Type"::Payment, ApplyingVendorLedgerEntry."Document Type"::" ":
                begin
                    if ApplyingVendorLedgerEntry."GST on Advance Payment" then
                        exit;

                    if not VendorLedgerEntry."GST Reverse Charge" then
                        exit;

                    if not GSTApplicationLibrary.DoesGSTExist(TransactionType::Purchase, VendorLedgerEntry."Vendor No.", VendorLedgerEntry."Document No.") then
                        exit;

                    ApplyingVendorLedgerEntry.TestField("Document Type", ApplyingVendorLedgerEntry."Document Type"::Payment);
                    ApplyingVendorLedgerEntry.TestField("Currency Code", VendorLedgerEntry."Currency Code");

                    if VendorLedgerEntry."GST Group Code" <> '' then
                        ApplyingVendorLedgerEntry.TestField(ApplyingVendorLedgerEntry."TDS Section Code", VendorLedgerEntry."TDS Section Code");

                    if not GSTApplicationLibrary.FillAppBufferInvoice(
                        TransactionType::Purchase,
                        VendorLedgerEntry."Document No.",
                        VendorLedgerEntry."Vendor No.",
                        ApplyingVendorLedgerEntry."Document No.",
                        VendorLedgerEntry."Total TDS Including SHE CESS",
                        ApplyingVendorLedgerEntry."Amount to Apply",
                        ApplyingVendorLedgerEntry."Original Currency Factor")
                    then
                        exit;

                    GSTApplicationLibrary.AllocateGSTWithNormalPayment(VendorLedgerEntry."Vendor No.", VendorLedgerEntry."Document No.", AmountToApply);
                    PostPurchGSTApplicationNormalPaymentGL(
                        GenJournalLine,
                        ApplyingVendorLedgerEntry."Document No.",
                        VendorLedgerEntry."Document No.",
                        ApplyingVendorLedgerEntry."RCM Exempt",
                        ApplyingVendorLedgerEntry."Original Currency Factor",
                        Round(ApplyingVendorLedgerEntry."Amount to Apply" / ApplyingVendorLedgerEntry."Original Currency Factor"));
                end;
        end;
    end;

    local procedure PostGSTWithNormalPaymentOnline(
        var GenJournalLine: Record "Gen. Journal Line";
        var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        var OldCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        AmountToApply: Decimal)
    var
        ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry";
        TransactionType: Enum "Detail Ledger Transaction Type";
        TotalTDSInclSHECessAmount: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforePostGSTWithNormalPaymentOnline(GenJournalLine, AmountToApply, IsHandled);
        if IsHandled then
            exit;

        if not ApplyingVendorLedgerEntry.Get(OldCVLedgerEntryBuffer."Entry No.") then
            exit;

        case ApplyingVendorLedgerEntry."Document Type" of
            ApplyingVendorLedgerEntry."Document Type"::Invoice:
                begin
                    if OnlineVendorLedgerEntry."GST on Advance Payment" then
                        exit;

                    if not ApplyingVendorLedgerEntry."GST Reverse Charge" then
                        exit;

                    if not GSTApplicationLibrary.DoesGSTExist(TransactionType::Purchase, ApplyingVendorLedgerEntry."Vendor No.", ApplyingVendorLedgerEntry."Document No.") then
                        exit;

                    OnlineVendorLedgerEntry.TestField("Document Type", OnlineVendorLedgerEntry."Document Type"::Payment);
                    ApplyingVendorLedgerEntry.TestField("Currency Code", OnlineVendorLedgerEntry."Currency Code");
                    GenJournalLine.TestField("Work Tax Nature Of Deduction", '');

                    if not GSTApplicationLibrary.FillAppBufferInvoice(
                        TransactionType::Purchase,
                        ApplyingVendorLedgerEntry."Document No.",
                        ApplyingVendorLedgerEntry."Vendor No.",
                        OnlineVendorLedgerEntry."Document No.",
                        ApplyingVendorLedgerEntry."Total TDS Including SHE CESS",
                        ApplyingVendorLedgerEntry."Amount to Apply",
                        CVLedgerEntryBuffer."Original Currency Factor")
                    then
                        exit;

                    GSTApplicationLibrary.AllocateGSTWithNormalPayment(ApplyingVendorLedgerEntry."Vendor No.", ApplyingVendorLedgerEntry."Document No.", AmountToApply);
                    PostPurchGSTApplicationNormalPaymentGL(
                        GenJournalLine,
                        OnlineVendorLedgerEntry."Document No.",
                        ApplyingVendorLedgerEntry."Document No.",
                        OnlineVendorLedgerEntry."RCM Exempt",
                        CVLedgerEntryBuffer."Original Currency Factor",
                        Round(Abs(ApplyingVendorLedgerEntry."Amount to Apply" / CVLedgerEntryBuffer."Original Currency Factor")));
                end;
            ApplyingVendorLedgerEntry."Document Type"::Payment, ApplyingVendorLedgerEntry."Document Type"::" ":
                begin
                    if ApplyingVendorLedgerEntry."GST on Advance Payment" then
                        exit;

                    if not OnlineVendorLedgerEntry."GST Reverse Charge" then
                        exit;

                    if not GSTApplicationLibrary.DoesGSTExist(TransactionType::Purchase, OnlineVendorLedgerEntry."Vendor No.", OnlineVendorLedgerEntry."Document No.") then
                        exit;

                    ApplyingVendorLedgerEntry.TestField("Document Type", ApplyingVendorLedgerEntry."Document Type"::Payment);
                    TotalTDSInclSHECessAmount := GSTApplSessionMgt.GetTotalTDSInclSHECessAmount();
                    if not GSTApplicationLibrary.FillAppBufferInvoice(
                        TransactionType::Purchase,
                        OnlineVendorLedgerEntry."Document No.",
                        OnlineVendorLedgerEntry."Vendor No.",
                        ApplyingVendorLedgerEntry."Document No.",
                        TotalTDSInclSHECessAmount,
                        ApplyingVendorLedgerEntry."Amount to Apply",
                        ApplyingVendorLedgerEntry."Original Currency Factor")
                    then
                        exit;

                    ApplyingVendorLedgerEntry.TestField("Currency Code", OnlineVendorLedgerEntry."Currency Code");
                    GenJournalLine.TestField("Work Tax Nature Of Deduction", '');
                    GSTApplicationLibrary.AllocateGSTWithNormalPayment(OnlineVendorLedgerEntry."Vendor No.", OnlineVendorLedgerEntry."Document No.", AmountToApply);
                    PostPurchGSTApplicationNormalPaymentGL(
                        GenJournalLine,
                        ApplyingVendorLedgerEntry."Document No.",
                        OnlineVendorLedgerEntry."Document No.",
                        ApplyingVendorLedgerEntry."RCM Exempt",
                        OldCVLedgerEntryBuffer."Original Currency Factor",
                        Round(ApplyingVendorLedgerEntry."Amount to Apply" / ApplyingVendorLedgerEntry."Original Currency Factor"));
                end;
        end;
    end;

    local procedure PostPurchGSTApplicationNormalPaymentGL(
        var GenJournalLine: Record "Gen. Journal Line";
        PaymentDocNo: Code[20];
        InvoiceNo: Code[20];
        RCMExempt: Boolean;
        PaymentCurrencyFactor: Decimal;
        PaymentOriginalAmountLCY: Decimal)
    var
        SourceCodeSetup: Record "Source Code Setup";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        ApplyDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ApplyDetailedGSTLedgerEntryNew: Record "Detailed GST Ledger Entry";
        GSTApplicationBuffer: Record "GST Application Buffer";
        TransactionType: Enum "Detail Ledger Transaction Type";
        AccountNo: Code[20];
        AccountNo2: Code[20];
        BalanceAccountNo: Code[20];
        BalanceAccountNo2: Code[20];
        AppliedBase: Decimal;
        AppliedAmount: Decimal;
        RemainingBase: Decimal;
        RemainingAmount: Decimal;
        ApplicationRatio: Decimal;
        AppliedBaseAmountInvoiceLCY: Decimal;
        AppliedAmountInvoiceLCY: Decimal;
        HigherInvoiceExchangeRate: Boolean;
    begin
        SourceCodeSetup.Get();

        GSTApplicationBuffer.SetRange("Transaction Type", GSTApplicationBuffer."Transaction Type"::Purchase);
        GSTApplicationBuffer.SetRange("Account No.", GenJournalLine."Account No.");
        GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Invoice);
        GSTApplicationBuffer.SetRange("Original Document No.", InvoiceNo);
        GSTApplicationBuffer.SetRange("Applied Doc. Type", GSTApplicationBuffer."Applied Doc. Type"::Payment);
        GSTApplicationBuffer.SetRange("Applied Doc. No.", PaymentDocNo);
        if GSTApplicationBuffer.FindSet() then
            repeat
                DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Source No.", "Document Type", "Document No.", "GST Group Code");
                DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
                DetailedGSTLedgerEntry.SetRange("Source No.", GenJournalLine."Account No.");
                DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
                DetailedGSTLedgerEntry.SetRange("Document No.", InvoiceNo);
                DetailedGSTLedgerEntry.SetRange("GST Group Code", GSTApplicationBuffer."GST Group Code");
                DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
                DetailedGSTLedgerEntry.SetRange("GST Component Code", GSTApplicationBuffer."GST Component Code");
                DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", false);
                if DetailedGSTLedgerEntry.FindSet() then begin
                    RemainingBase := GSTApplicationBuffer."Applied Base Amount";
                    RemainingAmount := GSTApplicationBuffer."Applied Amount";
                    GSTPostingBuffer[1].DeleteAll();
                    GSTApplicationLibrary.CheckGSTAccountingPeriod(GenJournalLine."Posting Date", false);

                    repeat
                        GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);
                        if (not DetailedGSTLedgerEntryInfo."Remaining Amount Closed") and
                            (RemainingBase <> 0) and
                            (DetailedGSTLedgerEntry."Remaining Base Amount" > 0)
                        then begin
                            ApplicationRatio := 1;
                            if (PaymentCurrencyFactor <> DetailedGSTLedgerEntry."Currency Factor") and
                               (DetailedGSTLedgerEntry."Currency Code" <> '') and
                               (PaymentCurrencyFactor > DetailedGSTLedgerEntry."Currency Factor") and
                               (DetailedGSTLedgerEntry."GST Group Type" = DetailedGSTLedgerEntry."GST Group Type"::Service)
                            then
                                ApplicationRatio := PaymentOriginalAmountLCY / Round(GSTApplicationBuffer."Amt to Apply" / GSTApplicationBuffer."Currency Factor");

                            if DetailedGSTLedgerEntry."Reverse Charge" then
                                ApplicationRatio := 1;

                            OnBeforeCalculateGSTAppliedAmount(PaymentCurrencyFactor, DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo, ApplicationRatio, RemainingBase, RemainingAmount, AppliedBase, AppliedAmount);
                            GSTApplicationLibrary.GetAppliedAmount(
                                Abs(RemainingBase),
                                Abs(RemainingAmount),
                                Abs(DetailedGSTLedgerEntry."Remaining Base Amount" * ApplicationRatio),
                                Abs(DetailedGSTLedgerEntry."Remaining GST Amount" * ApplicationRatio), AppliedBase, AppliedAmount);

                            OnAfterCalculateGSTApplicationAmount(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo, ApplicationRatio, RemainingBase, RemainingAmount);
                            CreateDetailedGSTApplicationEntry(
                                ApplyDetailedGSTLedgerEntry,
                                DetailedGSTLedgerEntry,
                                GenJournalLine,
                                InvoiceNo,
                                AppliedBase,
                                AppliedAmount);

                            UpdateDetailedGSTApplicationEntryNormalPayment(ApplyDetailedGSTLedgerEntry, RCMexempt);
                            ApplyDetailedGSTLedgerEntry.Insert(true);
                            CreateDetailedGSTApplicationEntryInfo(ApplyDetailedGSTLedgerEntry, DetailedGSTLedgerEntry, PaymentDocNo, RCMExempt);

                            AppliedBaseAmountInvoiceLCY := 0;
                            HigherInvoiceExchangeRate := false;
                            AppliedBaseAmountInvoiceLCY := CalculateAndFillGSTPostingBufferForexFluctuation(
                                GSTApplicationBuffer,
                                PaymentCurrencyFactor,
                                HigherInvoiceExchangeRate);

                            if AppliedBaseAmountInvoiceLCY <> 0 then begin
                                AppliedBaseAmountInvoiceLCY := Abs(AppliedBaseAmountInvoiceLCY) - Abs(GSTApplicationBuffer."Applied Base Amount");
                                GSTApplicationBuffer."Amt to Apply (Applied)" := GSTApplicationBuffer."Amt to Apply" /
                                    Abs(GSTApplicationBuffer."Applied Base Amount") * AppliedBase;
                                GSTApplicationBuffer.Modify();

                                if (not ApplyDetailedGSTLedgerEntry."Reverse Charge") then begin
                                    AppliedBaseAmountInvoiceLCY := Round(
                                        Abs(AppliedBaseAmountInvoiceLCY * GSTApplicationBuffer."Amt to Apply (Applied)" / GSTApplicationBuffer."Amt to Apply"));
                                    AppliedAmountInvoiceLCY := Round(AppliedBaseAmountInvoiceLCY * GSTApplicationBuffer."GST %" / 100);
                                    CreateDetailedGSTApplicationEntry(
                                        ApplyDetailedGSTLedgerEntryNew,
                                        DetailedGSTLedgerEntry,
                                        GenJournalLine,
                                        InvoiceNo,
                                        AppliedBaseAmountInvoiceLCY,
                                        AppliedAmountInvoiceLCY);

                                    ApplyDetailedGSTLedgerEntry."Forex Fluctuation" := true;
                                    ApplyDetailedGSTLedgerEntry."Payment Type" := ApplyDetailedGSTLedgerEntry."Payment Type"::Normal;
                                    ApplyDetailedGSTLedgerEntry.Quantity := 0;

                                    if ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::"Non-Availment" then
                                        ApplyDetailedGSTLedgerEntry."Amount Loaded on Item" := ApplyDetailedGSTLedgerEntry."GST Amount";

                                    if PaymentCurrencyFactor < DetailedGSTLedgerEntry."Currency Factor" then
                                        if ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::"Non-Availment" then
                                            ApplyDetailedGSTLedgerEntry."Liable to Pay" := true
                                        else
                                            if ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::Availment then begin
                                                ApplyDetailedGSTLedgerEntry."Credit Availed" := true;
                                                ApplyDetailedGSTLedgerEntry."Liable to Pay" := true;
                                            end;

                                    if (PaymentCurrencyFactor > DetailedGSTLedgerEntry."Currency Factor") and
                                        (ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::"Non-Availment")
                                    then
                                        ApplyDetailedGSTLedgerEntry."Fluctuation Amt. Credit" := true;

                                    ApplyDetailedGSTLedgerEntryNew.Insert(true);
                                    CreateDetailedGSTApplicationEntryInfo(ApplyDetailedGSTLedgerEntryNew, DetailedGSTLedgerEntry, PaymentDocNo, false);
                                    FillGSTPostingBufferWithApplication(ApplyDetailedGSTLedgerEntryNew, true, HigherInvoiceExchangeRate);
                                end;
                            end;

                            GSTApplicationLibrary.GetApplicationDocTypeFromGSTDocumentType(DetailedGSTLedgerEntry."Application Doc. Type", ApplyDetailedGSTLedgerEntry."Document Type");
                            DetailedGSTLedgerEntry."Application Doc. No" := ApplyDetailedGSTLedgerEntry."Document No.";

                            if (PaymentCurrencyFactor <> DetailedGSTLedgerEntry."Currency Factor") and
                               (PaymentCurrencyFactor > DetailedGSTLedgerEntry."Currency Factor")
                            then begin
                                DetailedGSTLedgerEntry."Remaining Base Amount" -= AppliedBase + AppliedBaseAmountInvoiceLCY;
                                DetailedGSTLedgerEntry."Remaining GST Amount" -= AppliedAmount + AppliedAmountInvoiceLCY;
                            end else begin
                                DetailedGSTLedgerEntry."Remaining Base Amount" -= AppliedBase;
                                DetailedGSTLedgerEntry."Remaining GST Amount" -= AppliedAmount;
                            end;

                            DetailedGSTLedgerEntry.Modify();

                            RemainingBase := Abs(RemainingBase) - Abs(AppliedBase);
                            RemainingAmount := Abs(RemainingAmount) - Abs(AppliedAmount);
                            FillGSTPostingBufferWithApplication(ApplyDetailedGSTLedgerEntry, false, false);
                        end;
                    until DetailedGSTLedgerEntry.Next() = 0;

                    if GSTPostingBuffer[1].FindLast() then
                        repeat
                            GetCreditAccountNormalPayment(DetailedGSTLedgerEntry, GSTPostingBuffer[1], AccountNo, AccountNo2, BalanceAccountNo, BalanceAccountNo2, RCMExempt);
                            CreateApplicationGSTLedger(
                                GSTPostingBuffer[1],
                                ApplyDetailedGSTLedgerEntry,
                                GenJournalLine."Posting Date",
                                SourceCodeSetup."Purchase Entry Application",
                                ApplyDetailedGSTLedgerEntry."Payment Type",
                                AccountNo,
                                BalanceAccountNo,
                                BalanceAccountNo2,
                                AccountNo2);

                            PostNormalPaymentApplicationGLEntries(
                                GenJournalLine,
                                false,
                                AccountNo,
                                AccountNo2,
                                BalanceAccountNo,
                                BalanceAccountNo2,
                                GSTPostingBuffer[1]."GST Amount");
                        until GSTPostingBuffer[1].Next(-1) = 0;
                end;
            until GSTApplicationBuffer.Next() = 0;

        GSTApplicationLibrary.DeleteInvoiceApplicationBufferOffline(
            TransactionType::Purchase,
            GenJournalLine."Account No.",
            GSTApplicationBuffer."Original Document Type"::Invoice,
            InvoiceNo);
    end;

    local procedure GetCreditAccountAdvancePayment(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTPostingBuffer: Record "GST Posting Buffer";
        var AccountNo: Code[20];
        var BalanceAccountNo: Code[20];
        var BalanceAccountNo2: Code[20])
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        Clear(AccountNo);
        Clear(BalanceAccountNo);
        Clear(BalanceAccountNo2);
        GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);

        if GSTPostingBuffer."GST Group Type" = GSTPostingBuffer."GST Group Type"::Goods then
            GetCreditAccountAdvancePaymentGoods(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo, GSTPostingBuffer, AccountNo, BalanceAccountNo);

        if GSTPostingBuffer."GST Group Type" = GSTPostingBuffer."GST Group Type"::Service then
            GetCreditAccountAdvancePaymentService(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo, GSTPostingBuffer, AccountNo, BalanceAccountNo, BalanceAccountNo2);

    end;

    local procedure GetCreditAccountAdvancePaymentGoods(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTPostingBuffer: Record "GST Posting Buffer";
        var AccountNo: Code[20];
        var BalanceAccountNo: Code[20])
    var
        GSTGLAccountType: Enum "GST GL Account Type";
    begin
        if DetailedGSTLedgerEntry."GST Vendor Type" = "GST Vendor Type"::Unregistered then begin
            AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                GSTGLAccountType::"Receivable Account (Interim)",
                DetailedGSTLedgerEntryInfo."Location State Code",
                GSTPostingBuffer."GST Component Code");

            BalanceAccountNo :=
                GSTApplicationLibrary.GetGSTGLAccountNo(
                    GSTGLAccountType::"Payable Account",
                    DetailedGSTLedgerEntryInfo."Location State Code",
                    GSTPostingBuffer."GST Component Code");
        end;
    end;

    local procedure GetCreditAccountAdvancePaymentService(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTPostingBuffer: Record "GST Posting Buffer";
        var AccountNo: Code[20];
        var BalanceAccountNo: Code[20];
        var BalanceAccountNo2: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GSTGLAccountType: Enum "GST GL Account Type";
    begin
        if DetailedGSTLedgerEntry."Associated Enterprises" then begin
            AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                GSTGLAccountType::"Receivable Account (Interim)",
                DetailedGSTLedgerEntryInfo."Location State Code",
                GSTPostingBuffer."GST Component Code");

            BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                GSTGLAccountType::"Payable Account",
                DetailedGSTLedgerEntryInfo."Location State Code",
                GSTPostingBuffer."GST Component Code");
        end else
            if not GSTPostingBuffer."Forex Fluctuation" then
                if GSTPostingBuffer.Availment then begin
                    AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                        GSTGLAccountType::"Receivable Account (Interim)",
                        DetailedGSTLedgerEntryInfo."Location State Code",
                        GSTPostingBuffer."GST Component Code");

                    if not DetailedGSTLedgerEntryInfo."RCM Exempt Transaction" then
                        BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                            GSTGLAccountType::"Payables Account (Interim)",
                            DetailedGSTLedgerEntryInfo."Location State Code",
                            GSTPostingBuffer."GST Component Code");

                    BalanceAccountNo2 := GSTApplicationLibrary.GetGSTGLAccountNo(
                        GSTGLAccountType::"Receivable Account",
                        DetailedGSTLedgerEntryInfo."Location State Code",
                        GSTPostingBuffer."GST Component Code");

                    if DetailedGSTLedgerEntry."Input Service Distribution" then begin
                        AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                            GSTGLAccountType::"Receivable Acc. Interim (Dist)",
                            DetailedGSTLedgerEntryInfo."Location State Code",
                            GSTPostingBuffer."GST Component Code");

                        BalanceAccountNo2 := GSTApplicationLibrary.GetGSTGLAccountNo(
                            GSTGLAccountType::"Receivable Acc. (Dist)",
                            DetailedGSTLedgerEntryInfo."Location State Code",
                            GSTPostingBuffer."GST Component Code");
                    end;
                end else begin
                    AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                        GSTGLAccountType::"Receivable Account (Interim)",
                        DetailedGSTLedgerEntryInfo."Location State Code",
                        GSTPostingBuffer."GST Component Code");

                    if not DetailedGSTLedgerEntryInfo."RCM Exempt Transaction" then
                        BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                            GSTGLAccountType::"Payables Account (Interim)",
                            DetailedGSTLedgerEntryInfo."Location State Code",
                            GSTPostingBuffer."GST Component Code")
                    else
                        BalanceAccountNo := GSTPostingBuffer."Account No.";
                end else
                case GSTPostingBuffer.Availment of
                    true:
                        if GSTPostingBuffer."Higher Inv. Exchange Rate" then begin
                            AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Receivable Account (Interim)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");

                            BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Payables Account (Interim)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");
                        end else begin
                            AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Receivable Account (Interim)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");

                            BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Receivable Account",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");
                        end;
                    false:
                        if GSTPostingBuffer."Higher Inv. Exchange Rate" then begin
                            if GSTPostingBuffer.Type = GSTPostingBuffer.Type::Item then begin
                                GeneralPostingSetup.Get(GSTPostingBuffer."Gen. Bus. Posting Group", GSTPostingBuffer."Gen. Prod. Posting Group");
                                AccountNo := GeneralPostingSetup."Purch. Account"
                            end else
                                if GSTPostingBuffer.Type in [GSTPostingBuffer.Type::"G/L Account", GSTPostingBuffer.Type::"Fixed Asset"] then
                                    AccountNo := GSTPostingBuffer."Account No.";

                            BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Payables Account (Interim)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");

                            if GSTPostingBuffer.Type = GSTPostingBuffer.Type::Item then
                                PostRevaluationEntry(GSTPostingBuffer, DetailedGSTLedgerEntry."Document No.", true, false)
                            else
                                if GSTPostingBuffer.Type = GSTPostingBuffer.Type::"Fixed Asset" then
                                    PostRevaluationEntry(GSTPostingBuffer, DetailedGSTLedgerEntry."Document No.", true, true)
                        end else begin
                            AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Receivable Account (Interim)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");

                            if GSTPostingBuffer.Type = GSTPostingBuffer.Type::Item then begin
                                GeneralPostingSetup.Get(GSTPostingBuffer."Gen. Bus. Posting Group", GSTPostingBuffer."Gen. Prod. Posting Group");
                                BalanceAccountNo := GeneralPostingSetup."Purch. Account";
                            end else
                                if GSTPostingBuffer.Type in [GSTPostingBuffer.Type::"G/L Account", GSTPostingBuffer.Type::"Fixed Asset"] then
                                    BalanceAccountNo := GSTPostingBuffer."Account No.";

                            if GSTPostingBuffer.Type = GSTPostingBuffer.Type::Item then
                                PostRevaluationEntry(GSTPostingBuffer, DetailedGSTLedgerEntry."Document No.", false, false)
                            else
                                if GSTPostingBuffer.Type = GSTPostingBuffer.Type::"Fixed Asset" then
                                    PostRevaluationEntry(GSTPostingBuffer, DetailedGSTLedgerEntry."Document No.", false, true)
                        end;
                end;
    end;

    local procedure PostPurchaseApplicationGLEntries(
        var GenJournalLine: Record "Gen. Journal Line";
        UnApplication: Boolean;
        AccountNo: Code[20];
        BalanceAccountNo: Code[20];
        BalanceAccountNo2: Code[20];
        GSTAmount: Decimal;
        RCMExempt: Boolean)
    begin
        if GSTAmount = 0 then
            exit;

        if UnApplication then begin
            if BalanceAccountNo2 <> '' then
                if not RCMExempt then
                    PostToGLEntry(GenJournalLine, AccountNo, Abs(GSTAmount) + Abs(GSTAmount))
                else
                    PostToGLEntry(GenJournalLine, AccountNo, Abs(GSTAmount))
            else
                PostToGLEntry(GenJournalLine, AccountNo, Abs(GSTAmount));

            if BalanceAccountNo <> '' then
                PostToGLEntry(GenJournalLine, BalanceAccountNo, -Abs(GSTAmount));

            if BalanceAccountNo2 <> '' then
                PostToGLEntry(GenJournalLine, BalanceAccountNo2, -Abs(GSTAmount));
        end else begin
            if BalanceAccountNo2 <> '' then
                if not RCMExempt then
                    PostToGLEntry(GenJournalLine, AccountNo, -(Abs(GSTAmount) + Abs(GSTAmount)))
                else
                    PostToGLEntry(GenJournalLine, AccountNo, -Abs(GSTAmount))
            else
                PostToGLEntry(GenJournalLine, AccountNo, -Abs(GSTAmount));

            if BalanceAccountNo <> '' then
                PostToGLEntry(GenJournalLine, BalanceAccountNo, Abs(GSTAmount));

            if BalanceAccountNo2 <> '' then
                PostToGLEntry(GenJournalLine, BalanceAccountNo2, Abs(GSTAmount));
        end;
    end;

    local procedure GetCreditAccountNormalPayment(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTPostingBuffer: Record "GST Posting Buffer";
        var AccountNo: Code[20];
        var AccountNo2: Code[20];
        var BalanceAccountNo: Code[20];
        var BalanceAccountNo2: Code[20];
        RCMExempt: Boolean)
    var
        GeneralPostingSetup: Record "General Posting Setup";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTGLAccountType: Enum "GST GL Account Type";
    begin
        Clear(AccountNo);
        Clear(AccountNo2);
        Clear(BalanceAccountNo);
        Clear(BalanceAccountNo2);
        GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);

        if GSTPostingBuffer.Availment then
            case GSTPostingBuffer."Forex Fluctuation" of
                false:
                    begin
                        if not RCMExempt then begin
                            AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Payable Account",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");

                            AccountNo2 := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Receivable Account (Interim)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");

                            BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Payables Account (Interim)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");

                            BalanceAccountNo2 := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Receivable Account",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");
                        end else begin
                            AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Receivable Account (Interim)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");

                            BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Payables Account (Interim)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");
                        end;

                        if DetailedGSTLedgerEntry."Input Service Distribution" then begin
                            AccountNo2 := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Receivable Acc. Interim (Dist)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");
                            BalanceAccountNo2 := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Receivable Acc. (Dist)",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code");
                        end;
                    end;
                true:
                    if GSTPostingBuffer."Higher Inv. Exchange Rate" then begin
                        AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                            GSTGLAccountType::"Payables Account (Interim)",
                            DetailedGSTLedgerEntryInfo."Location State Code",
                            GSTPostingBuffer."GST Component Code");

                        BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                            GSTGLAccountType::"Payables Account (Interim)",
                            DetailedGSTLedgerEntryInfo."Location State Code",
                            GSTPostingBuffer."GST Component Code");

                        OnAfterGetHigherExcRateGSTGLAccounts(GSTPostingBuffer, AccountNo, BalanceAccountNo);
                    end else begin
                        AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                            GSTGLAccountType::"Payable Account",
                            DetailedGSTLedgerEntryInfo."Location State Code",
                            GSTPostingBuffer."GST Component Code");

                        BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                            GSTGLAccountType::"Receivable Account",
                            DetailedGSTLedgerEntryInfo."Location State Code",
                            GSTPostingBuffer."GST Component Code");

                        OnAfterGetLessExcRateGSTGLAccounts(GSTPostingBuffer, AccountNo, BalanceAccountNo);
                    end;
            end else
            case GSTPostingBuffer."Forex Fluctuation" of
                true:
                    if GSTPostingBuffer."Higher Inv. Exchange Rate" then begin
                        if GSTPostingBuffer.Type = GSTPostingBuffer.Type::Item then begin
                            GeneralPostingSetup.Get(GSTPostingBuffer."Gen. Bus. Posting Group", GSTPostingBuffer."Gen. Prod. Posting Group");
                            AccountNo := GeneralPostingSetup."Purch. Account"
                        end else
                            if GSTPostingBuffer.Type in [GSTPostingBuffer.Type::"G/L Account", GSTPostingBuffer.Type::"Fixed Asset"] then
                                AccountNo := GSTPostingBuffer."Account No.";

                        OnAfterGetGLGSTPostingAccountNo(DetailedGSTLedgerEntryInfo, GSTPostingBuffer, AccountNo);
                        BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                            GSTGLAccountType::"Payables Account (Interim)",
                            DetailedGSTLedgerEntryInfo."Location State Code",
                            GSTPostingBuffer."GST Component Code");

                        if GSTPostingBuffer.Type = GSTPostingBuffer.Type::Item then
                            PostRevaluationEntry(GSTPostingBuffer, DetailedGSTLedgerEntry."Document No.", true, false)
                        else
                            if GSTPostingBuffer.Type = GSTPostingBuffer.Type::"Fixed Asset" then
                                PostRevaluationEntry(GSTPostingBuffer, DetailedGSTLedgerEntry."Document No.", true, true)
                    end else begin
                        AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                            GSTGLAccountType::"Payable Account",
                            DetailedGSTLedgerEntryInfo."Location State Code",
                            GSTPostingBuffer."GST Component Code");

                        OnAfterGetGSTGLAccountNoForLowerExchRate(DetailedGSTLedgerEntryInfo, GSTPostingBuffer, AccountNo);
                        if GSTPostingBuffer.Type = GSTPostingBuffer.Type::Item then begin
                            GeneralPostingSetup.Get(GSTPostingBuffer."Gen. Bus. Posting Group", GSTPostingBuffer."Gen. Prod. Posting Group");
                            BalanceAccountNo := GeneralPostingSetup."Purch. Account";
                        end else
                            if GSTPostingBuffer.Type in [GSTPostingBuffer.Type::"G/L Account", GSTPostingBuffer.Type::"Fixed Asset"] then
                                BalanceAccountNo := GSTPostingBuffer."Account No.";

                        OnAfterGetGSTGLBalAccountNoForLowerExchRate(DetailedGSTLedgerEntryInfo, GSTPostingBuffer, BalanceAccountNo);
                        if GSTPostingBuffer.Type = GSTPostingBuffer.Type::Item then
                            PostRevaluationEntry(GSTPostingBuffer, DetailedGSTLedgerEntry."Document No.", false, false)
                        else
                            if GSTPostingBuffer.Type = GSTPostingBuffer.Type::"Fixed Asset" then
                                PostRevaluationEntry(GSTPostingBuffer, DetailedGSTLedgerEntry."Document No.", false, true)
                    end;
                false:
                    begin
                        if not RCMExempt then
                            AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                                GSTGLAccountType::"Payable Account",
                                DetailedGSTLedgerEntryInfo."Location State Code",
                                GSTPostingBuffer."GST Component Code")
                        else
                            AccountNo := GSTPostingBuffer."Account No.";

                        BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(GSTGLAccountType::"Payables Account (Interim)", DetailedGSTLedgerEntryInfo."Location State Code", GSTPostingBuffer."GST Component Code");
                    end;
            end;
    end;

    local procedure PostNormalPaymentApplicationGLEntries(
        var GenJournalLine: Record "Gen. Journal Line";
        UnApplication: Boolean;
        AccountNo: Code[20];
        AccountNo2: Code[20];
        BalanceAccountNo: Code[20];
        BalanceAccountNo2: Code[20];
        GSTAmount: Decimal)
    begin
        if GSTAmount = 0 then
            exit;

        if UnApplication then begin
            PostToGLEntry(GenJournalLine, AccountNo, Abs(GSTAmount));
            PostToGLEntry(GenJournalLine, BalanceAccountNo, -Abs(GSTAmount));
            if AccountNo2 <> '' then begin
                PostToGLEntry(GenJournalLine, AccountNo2, Abs(GSTAmount));
                PostToGLEntry(GenJournalLine, BalanceAccountNo2, -Abs(GSTAmount));
            end;
        end else begin
            PostToGLEntry(GenJournalLine, AccountNo, -Abs(GSTAmount));
            PostToGLEntry(GenJournalLine, BalanceAccountNo, Abs(GSTAmount));
            if AccountNo2 <> '' then begin
                PostToGLEntry(GenJournalLine, AccountNo2, -Abs(GSTAmount));
                PostToGLEntry(GenJournalLine, BalanceAccountNo2, Abs(GSTAmount));
            end;
        end;
    end;

    local procedure PostRevaluationEntry(
        GSTPostingBuffer: Record "GST Posting Buffer";
        DocumentNo: Code[20];
        CreditValue: Boolean;
        FixedAsset: Boolean)
    var
        SourceCodeSetup: Record "Source Code Setup";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalLineToPost: Record "Item Journal Line";
        FALedgerEntry: Record "FA Ledger Entry";
        FALedgerEntryNew: Record "FA Ledger Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        EntryNo: Integer;
        Ctr: Integer;
    begin
        case FixedAsset of
            false:
                begin
                    ValueEntry.Reset();
                    ValueEntry.SetRange("Document No.", DocumentNo);
                    ValueEntry.SetRange("Document Line No.", GSTPostingBuffer."Document Line No.");
                    if ValueEntry.FindFirst() then begin
                        if not ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
                            exit;

                        SourceCodeSetup.Get();
                        if GSTPostingBuffer."GST Amount" <> 0 then begin
                            ItemJournalLine.Init();
                            ItemJournalLine.Validate("Posting Date", ItemLedgerEntry."Posting Date");
                            ItemJournalLine."Document Date" := ItemLedgerEntry."Posting Date";
                            ItemJournalLine.Validate("Document No.", ValueEntry."Document No.");
                            ItemJournalLine."Document Line No." := ItemLedgerEntry."Document Line No.";
                            ItemJournalLine."External Document No." := ItemLedgerEntry."External Document No.";
                            ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::Purchase);
                            ItemJournalLine."Value Entry Type" := ItemJournalLine."Value Entry Type"::Revaluation;
                            ItemJournalLine.Validate("Item No.", ItemLedgerEntry."Item No.");
                            ItemJournalLine."Source Type" := ItemJournalLine."Source Type"::Vendor;
                            ItemJournalLine."Source No." := ItemLedgerEntry."Source No.";
                            ItemJournalLine."Gen. Bus. Posting Group" := GSTPostingBuffer."Gen. Bus. Posting Group";
                            ItemJournalLine."Gen. Prod. Posting Group" := GSTPostingBuffer."Gen. Prod. Posting Group";
                            ItemJournalLine."Source Code" := SourceCodeSetup."Revaluation Journal";
                            ItemJournalLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");

                            if CreditValue then
                                ItemJournalLine.Validate(
                                    "Unit Cost (Revalued)",
                                    (ItemJournalLine."Unit Cost (Revalued)" + GSTPostingBuffer."GST Amount" / ItemLedgerEntry.Quantity))
                            else
                                ItemJournalLine.Validate(
                                    "Unit Cost (Revalued)",
                                    (ItemJournalLine."Unit Cost (Revalued)" - GSTPostingBuffer."GST Amount" / ItemLedgerEntry.Quantity));

                            Ctr := ItemJournalLineToPost."Line No." + 1;

                            ItemJournalLineToPost.Init();
                            ItemJournalLineToPost.TransferFields(ItemJournalLine);
                            ItemJournalLineToPost."Line No." := Ctr;
                            ItemJnlPostLine.Run(ItemJournalLineToPost);
                        end;
                    end;
                end;
            true:
                begin
                    FALedgerEntry.FindLast();
                    EntryNo := FALedgerEntry."Entry No." + 1;

                    FALedgerEntry.Reset();
                    FALedgerEntry.SetRange("Document No.", DocumentNo);
                    FALedgerEntry.SetRange("FA No.", GSTPostingBuffer."No.");
                    if FALedgerEntry.FindFirst() then begin
                        FALedgerEntryNew.Copy(FALedgerEntry);
                        FALedgerEntryNew."Entry No." := EntryNo;
                        if CreditValue then begin
                            FALedgerEntryNew.Amount := GSTPostingBuffer."GST Amount";
                            FALedgerEntryNew."Amount (LCY)" := GSTPostingBuffer."GST Amount";
                            FALedgerEntryNew."Debit Amount" := GSTPostingBuffer."GST Amount";
                            FALedgerEntryNew."Bal. Account No." := GSTPostingBuffer."Bal. Account No."
                        end else begin
                            FALedgerEntryNew.Amount := Abs(GSTPostingBuffer."GST Amount");
                            FALedgerEntryNew."Amount (LCY)" := Abs(GSTPostingBuffer."GST Amount");
                            FALedgerEntryNew."Debit Amount" := Abs(GSTPostingBuffer."GST Amount");
                            FALedgerEntryNew."Bal. Account No." := GSTPostingBuffer."Account No.";
                        end;

                        FALedgerEntryNew.Insert(true);
                    end;
                end;
        end;
    end;

    local procedure PostGSTSalesApplication(
        var GenJournalLine: Record "Gen. Journal Line";
        var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        var OldCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        AmountToApply: Decimal)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ApplyingCustLedgEntry: Record "Cust. Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GSTGroupRemAmount: Decimal;
        InvoiceGSTAmount: Decimal;
        AppliedGSTAmount: Decimal;
        InvoiceAmount: Decimal;
        TotalTCSInclSHECess: Decimal;
    begin
        if AmountToApply = 0 then
            exit;

        if GenJournalLine."Offline Application" then begin
            if not CustLedgerEntry.Get(CVLedgerEntryBuffer."Entry No.") then
                exit;

            if not ApplyingCustLedgEntry.Get(OldCVLedgerEntryBuffer."Entry No.") then
                exit;

            if CustLedgerEntry."GST on Advance Payment" then begin
                TotalTCSInclSHECess := GSTApplicationLibrary.GetTotalTCSInclSHECessAmount(ApplyingCustLedgEntry."Transaction No.");
                GSTSalesApplicationMgt.GetSalesInvoiceAmountOffline(CustLedgerEntry, ApplyingCustLedgEntry, TotalTCSInclSHECess);

                if OldCVLedgerEntryBuffer."Currency Code" <> '' then
                    GSTGroupRemAmount := GSTApplicationLibrary.GetApplicationRemainingAmountLCYForSales(
                        ApplyingCustLedgEntry,
                        CustLedgerEntry,
                        AmountToApply,
                        OldCVLedgerEntryBuffer."Remaining Amt. (LCY)",
                        InvoiceGSTAmount,
                        AppliedGSTAmount,
                        InvoiceAmount)
                else
                    GSTGroupRemAmount := GSTApplicationLibrary.GetApplicationRemainingAmountForSales(
                        ApplyingCustLedgEntry,
                        CustLedgerEntry,
                        AmountToApply,
                        OldCVLedgerEntryBuffer."Remaining Amt. (LCY)",
                        InvoiceGSTAmount,
                        AppliedGSTAmount,
                        InvoiceAmount);

                AmountToApply := GSTGroupRemAmount;

                GSTApplicationLibrary.CheckGroupAmount(
                    ApplyingCustLedgEntry."Document Type",
                    ApplyingCustLedgEntry."Document No.",
                    AmountToApply,
                    GSTGroupRemAmount,
                    CustLedgerEntry."GST Group Code");

                PostSaleGSTApplicationGL(
                    GenJournalLine,
                    CustLedgerEntry."Document No.",
                    ApplyingCustLedgEntry."Document No.",
                    CustLedgerEntry."Entry No.",
                    CustLedgerEntry."GST Group Code");
            end else
                if ApplyingCustLedgEntry."GST on Advance Payment" then begin
                    TotalTCSInclSHECess := GSTApplicationLibrary.GetTotalTCSInclSHECessAmount(CustLedgerEntry."Transaction No.");
                    GSTSalesApplicationMgt.GetSalesInvoiceAmountWithPaymentOffline(CustLedgerEntry, ApplyingCustLedgEntry, TotalTCSInclSHECess);

                    if OldCVLedgerEntryBuffer."Currency Code" <> '' then
                        GSTGroupRemAmount := GSTApplicationLibrary.GetApplicationRemainingAmountLCYForSales(
                            CustLedgerEntry,
                            ApplyingCustLedgEntry,
                            AmountToApply,
                            OldCVLedgerEntryBuffer."Amount (LCY)",
                            InvoiceGSTAmount,
                            AppliedGSTAmount,
                            InvoiceAmount)
                    else
                        GSTGroupRemAmount :=
                          GSTApplicationLibrary.GetApplicationRemainingAmountForSales(
                            CustLedgerEntry,
                            ApplyingCustLedgEntry,
                            AmountToApply,
                            OldCVLedgerEntryBuffer."Amount (LCY)",
                            InvoiceGSTAmount,
                            AppliedGSTAmount,
                            InvoiceAmount);

                    if Abs(AmountToApply) > Abs(GSTGroupRemAmount) then
                        AmountToApply := GSTGroupRemAmount;

                    GSTApplicationLibrary.CheckGroupAmount(
                        CustLedgerEntry."Document Type",
                        CustLedgerEntry."Document No.",
                        AmountToApply,
                        GSTGroupRemAmount * -1,
                        ApplyingCustLedgEntry."GST Group Code");

                    PostSaleGSTApplicationGL(
                        GenJournalLine,
                        ApplyingCustLedgEntry."Document No.",
                        CustLedgerEntry."Document No.",
                        ApplyingCustLedgEntry."Entry No.",
                        ApplyingCustLedgEntry."GST Group Code");
                end;

            GSTApplSessionMgt.PostApplicationGenJournalLine(GenJnlPostLine);
        end else begin
            if not ApplyingCustLedgEntry.Get(OldCVLedgerEntryBuffer."Entry No.") then
                exit;

            GSTApplSessionMgt.GetOnlineCustLedgerEntry(OnlineCustLedgerEntry);

            GetCustomerLedgerEntry(OnlineCustLedgerEntry, ApplyingCustLedgEntry);

            if ApplyingCustLedgEntry."GST on Advance Payment" then begin
                GSTApplicationLibrary.ApplyCurrencyFactorInvoice(true);
                TotalTCSInclSHECess := GSTApplSessionMgt.GetTotalTCSInclSHECessAmount();
                GSTSalesApplicationMgt.GetSalesInvoiceAmountWithPaymentOffline(OnlineCustLedgerEntry, ApplyingCustLedgEntry, TotalTCSInclSHECess);
                TotalTCSInclSHECess := GSTApplicationLibrary.GetTotalTCSInclSHECessAmount(OldCVLedgerEntryBuffer."Transaction No.");

                if OldCVLedgerEntryBuffer."Currency Code" <> '' then
                    GSTGroupRemAmount := GSTApplicationLibrary.GetApplicationRemainingAmountLCYForSales(
                        OnlineCustLedgerEntry,
                        ApplyingCustLedgEntry,
                        AmountToApply,
                        OldCVLedgerEntryBuffer."Amount (LCY)" - TotalTCSInclSHECess,
                        InvoiceGSTAmount,
                        AppliedGSTAmount,
                        InvoiceAmount)
                else
                    GSTGroupRemAmount := GSTApplicationLibrary.GetApplicationRemainingAmountForSales(
                        OnlineCustLedgerEntry,
                        ApplyingCustLedgEntry,
                        AmountToApply,
                        OldCVLedgerEntryBuffer."Amount (LCY)" - TotalTCSInclSHECess,
                        InvoiceGSTAmount,
                        AppliedGSTAmount,
                        InvoiceAmount);

                GSTGroupRemAmount += GSTApplicationLibrary.GetPartialRoundingAmt(AmountToApply, GSTGroupRemAmount);

                if Abs(AmountToApply) > Abs(GSTGroupRemAmount) then
                    AmountToApply := GSTGroupRemAmount;

                GSTApplicationLibrary.CheckGroupAmount(
                    OnlineCustLedgerEntry."Document Type",
                    OnlineCustLedgerEntry."Document No.",
                    AmountToApply,
                    GSTGroupRemAmount * -1,
                    ApplyingCustLedgEntry."GST Group Code");

                PostSaleGSTApplicationGL(
                    GenJournalLine,
                    ApplyingCustLedgEntry."Document No.",
                    OnlineCustLedgerEntry."Document No.",
                    ApplyingCustLedgEntry."Entry No.",
                    ApplyingCustLedgEntry."GST Group Code");
            end;
        end;
    end;

    local procedure GetCustomerLedgerEntry(var OnlineCustLedgerEntry: Record "Cust. Ledger Entry"; var ApplyingCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        if (OnlineCustLedgerEntry."Seller GST Reg. No." = '') and (OnlineCustLedgerEntry."Seller State Code" = '') then begin
            OnlineCustLedgerEntry."Seller GST Reg. No." := ApplyingCustLedgEntry."Seller GST Reg. No.";
            OnlineCustLedgerEntry."Seller State Code" := ApplyingCustLedgEntry."Seller State Code";
        end;
    end;

    local procedure PostSaleGSTApplicationGL(
        var GenJournalLine: Record "Gen. Journal Line";
        PaymentDocNo: Code[20];
        InvoiceNo: Code[20];
        EntryNo: Integer;
        GSTGroupCode: Code[20])
    var
        GSTApplicationBuffer: Record "GST Application Buffer";
        SourceCodeSetup: Record "Source Code Setup";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        SourceCodeSetup.Get();
        GSTApplicationBuffer.SetRange("Transaction Type", GSTApplicationBuffer."Transaction Type"::Sales);
        GSTApplicationBuffer.SetRange("Account No.", GenJournalLine."Account No.");
        GSTApplicationBuffer.SetRange("Original Document Type", GSTApplicationBuffer."Original Document Type"::Payment);
        GSTApplicationBuffer.SetRange("Original Document No.", PaymentDocNo);
        GSTApplicationBuffer.SetRange("Applied Doc. Type", GSTApplicationBuffer."Applied Doc. Type"::Invoice);
        GSTApplicationBuffer.SetRange("Applied Doc. No.", InvoiceNo);
        GSTApplicationBuffer.SetRange("GST Group Code", GSTGroupCode);
        if GSTApplicationBuffer.FindSet() then
            repeat
                UpdateApplyDetailedGSTLedgerEntryTables(GenJournalLine, Invoiceno, EntryNo, GSTApplicationBuffer, SourceCodeSetup);
            until GSTApplicationBuffer.Next() = 0;

        GSTApplicationLibrary.DeletePaymentAplicationBuffer(TransactionType::Sales, EntryNo);
        GSTApplicationLibrary.DeleteInvoiceApplicationBufferOffline(
            TransactionType::Sales,
            GenJournalLine."Account No.",
            GSTApplicationBuffer."Original Document Type"::Invoice,
            InvoiceNo);
    end;

    local procedure UpdateApplyDetailedGSTLedgerEntryTables(
        var GenJournalLine: Record "Gen. Journal Line";
        InvoiceNo: Code[20];
        EntryNo: Integer;
        GSTApplicationBuffer: Record "GST Application Buffer";
        SourceCodeSetup: Record "Source Code Setup")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ApplyDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        ApplyDetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTGLAccountType: Enum "GST GL Account Type";
        AccountNo: Code[20];
        BalanceAccountNo: Code[20];
        AppliedBase: Decimal;
        AppliedAmount: Decimal;
        RemainingBase: Decimal;
        RemainingAmount: Decimal;
    begin
        DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Source No.", "Document Type", "Document No.", "GST Group Code");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
        DetailedGSTLedgerEntry.SetRange("Source No.", GenJournalLine."Account No.");
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntry.SetRange("Document No.", GSTApplicationBuffer."Applied Doc. No.");
        DetailedGSTLedgerEntry.SetRange("GST Group Code", GSTApplicationBuffer."GST Group Code");
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("GST Component Code", GSTApplicationBuffer."GST Component Code");
        DetailedGSTLedgerEntry.SetRange("GST Exempted Goods", false);
        if DetailedGSTLedgerEntry.FindFirst() then begin
            RemainingBase := GSTApplicationBuffer."Applied Base Amount";
            RemainingAmount := GSTApplicationBuffer."Applied Amount";
            GSTPostingBuffer[1].DeleteAll();
            GSTApplicationLibrary.CheckGSTAccountingPeriod(GenJournalLine."Posting Date", false);

            repeat
                GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);
                if (not DetailedGSTLedgerEntryInfo."Remaining Amount Closed") and
                    (RemainingBase <> 0) and
                    (DetailedGSTLedgerEntry."Remaining Base Amount" < 0)
                then begin
                    GSTApplicationLibrary.GetAppliedAmount(
                        Abs(RemainingBase),
                        Abs(RemainingAmount),
                        Abs(DetailedGSTLedgerEntry."Remaining Base Amount"),
                        Abs(DetailedGSTLedgerEntry."Remaining GST Amount"),
                        AppliedBase,
                        AppliedAmount);
                    CreateDetailedGSTApplicationEntry(
                        ApplyDetailedGSTLedgerEntry,
                        DetailedGSTLedgerEntry,
                        GenJournalLine,
                        InvoiceNo,
                        AppliedBase * -1,
                        AppliedAmount * -1);

                    ApplyDetailedGSTLedgerEntry.Paid := false;
                    ApplyDetailedGSTLedgerEntry.Insert(true);

                    CreateApplyDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntryInfo, ApplyDetailedGSTLedgerEntry, EntryNo, ApplyDetailedGSTLedgerEntryInfo);

                    GSTApplicationLibrary.GetApplicationDocTypeFromGSTDocumentType(
                        DetailedGSTLedgerEntry."Application Doc. Type",
                        ApplyDetailedGSTLedgerEntry."Document Type");

                    DetailedGSTLedgerEntry."Application Doc. No" := ApplyDetailedGSTLedgerEntry."Document No.";
                    DetailedGSTLedgerEntry."Remaining Base Amount" += AppliedBase;
                    DetailedGSTLedgerEntry."Remaining GST Amount" += AppliedAmount;
                    DetailedGSTLedgerEntry.Modify();

                    RemainingBase := Abs(RemainingBase) - Abs(AppliedBase);
                    RemainingAmount := Abs(RemainingAmount) - Abs(AppliedAmount);
                    FillGSTPostingBufferWithApplication(ApplyDetailedGSTLedgerEntry, false, false);
                end;
            until DetailedGSTLedgerEntry.Next() = 0;

            AccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                GSTGLAccountType::"Payable Account",
                ApplyDetailedGSTLedgerEntryInfo."Location State Code",
                ApplyDetailedGSTLedgerEntry."GST Component Code");

            BalanceAccountNo := GSTApplicationLibrary.GetGSTGLAccountNo(
                GSTGLAccountType::"Payables Account (Interim)",
                ApplyDetailedGSTLedgerEntryInfo."Location State Code",
                ApplyDetailedGSTLedgerEntry."GST Component Code");

            if GSTPostingBuffer[1].FindLast() then
                repeat
                    CreateApplicationGSTLedger(
                        GSTPostingBuffer[1],
                        ApplyDetailedGSTLedgerEntry,
                        GenJournalLine."Posting Date",
                        SourceCodeSetup."Sales Entry Application",
                        ApplyDetailedGSTLedgerEntry."Payment Type",
                        AccountNo,
                        BalanceAccountNo,
                        '',
                        '');

                    PostSalesApplicationGLEntries(GenJournalLine, AccountNo, BalanceAccountNo, false, GSTPostingBuffer[1]."GST Amount");
                until GSTPostingBuffer[1].Next(-1) = 0;
        end;
    end;

    local procedure CreateApplyDetailedGSTLedgerEntryInfo(
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        ApplyDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        EntryNo: Integer;
        var ApplyDetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info")
    begin
        ApplyDetailedGSTLedgerEntryInfo.Init();
        ApplyDetailedGSTLedgerEntryInfo.TransferFields(DetailedGSTLedgerEntryInfo);
        ApplyDetailedGSTLedgerEntryInfo."Entry No." := ApplyDetailedGSTLedgerEntry."Entry No.";
        ApplyDetailedGSTLedgerEntryInfo."CLE/VLE Entry No." := EntryNo;
        ApplyDetailedGSTLedgerEntryInfo.Insert(true);
    end;

    local procedure PostSalesApplicationGLEntries(
        var GenJournalLine: Record "Gen. Journal Line";
        AccountNo: Code[20];
        BalAccountNo: Code[20];
        UnApplication: Boolean;
        GSTAmount: Decimal)
    begin
        if GSTAmount = 0 then
            exit;

        if UnApplication then begin
            PostToGLEntry(GenJournalLine, AccountNo, -Abs(GSTAmount));
            PostToGLEntry(GenJournalLine, BalAccountNo, Abs(GSTAmount));
        end else begin
            PostToGLEntry(GenJournalLine, AccountNo, Abs(GSTAmount));
            PostToGLEntry(GenJournalLine, BalAccountNo, -Abs(GSTAmount));
        end;
    end;

    local procedure CreateDetailedGSTApplicationEntry(
        var ApplyDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        InvoiceNo: Code[20];
        AppliedBase: Decimal;
        AppliedAmount: Decimal)
    begin
        ApplyDetailedGSTLedgerEntry.Init();
        ApplyDetailedGSTLedgerEntry.TransferFields(DetailedGSTLedgerEntry);
        ApplyDetailedGSTLedgerEntry."Entry No." := 0;
        ApplyDetailedGSTLedgerEntry."Entry Type" := ApplyDetailedGSTLedgerEntry."Entry Type"::Application;
        ApplyDetailedGSTLedgerEntry."Posting Date" := GenJournalLine."Posting Date";
        ApplyDetailedGSTLedgerEntry."Document Type" := ApplyDetailedGSTLedgerEntry."Document Type"::Invoice;
        ApplyDetailedGSTLedgerEntry."Document No." := InvoiceNo;
        GSTApplicationLibrary.GetApplicationDocTypeFromGenJournalDocumentType(ApplyDetailedGSTLedgerEntry."Application Doc. Type", GenJournalLine."Document Type");
        ApplyDetailedGSTLedgerEntry."Application Doc. No" := GenJournalLine."Document No.";
        ApplyDetailedGSTLedgerEntry."Payment Type" := ApplyDetailedGSTLedgerEntry."Payment Type"::Advance;
        ApplyDetailedGSTLedgerEntry."Transaction No." := TransactionNo;
        ApplyDetailedGSTLedgerEntry."Applied From Entry No." := DetailedGSTLedgerEntry."Entry No.";
        ApplyDetailedGSTLedgerEntry."GST Base Amount" := -AppliedBase;
        ApplyDetailedGSTLedgerEntry."GST Amount" := -AppliedAmount;
        ApplyDetailedGSTLedgerEntry."Remaining Base Amount" := 0;
        ApplyDetailedGSTLedgerEntry."Remaining GST Amount" := 0;
        ApplyDetailedGSTLedgerEntry."Amount Loaded on Item" := 0;
        ApplyDetailedGSTLedgerEntry.UnApplied := false;

        if DetailedGSTLedgerEntry."GST Amount" <> 0 then
            ApplyDetailedGSTLedgerEntry.Quantity := Round(
                -DetailedGSTLedgerEntry.Quantity * Abs(ApplyDetailedGSTLedgerEntry."GST Amount" / DetailedGSTLedgerEntry."GST Amount"),
                0.01)
        else
            ApplyDetailedGSTLedgerEntry.Quantity := -DetailedGSTLedgerEntry.Quantity;
    end;

    local procedure CreateDetailedGSTApplicationEntryInfo(
            ApplyDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
            DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
            PaymentDocNo: Code[20];
            RCMExempt: Boolean)
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        ApplyDetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);

        ApplyDetailedGSTLedgerEntryInfo.Init();
        ApplyDetailedGSTLedgerEntryInfo.TransferFields(DetailedGSTLedgerEntryInfo);
        ApplyDetailedGSTLedgerEntryInfo."Entry No." := ApplyDetailedGSTLedgerEntry."Entry No.";
        ApplyDetailedGSTLedgerEntryInfo."Original Doc. Type" := ApplyDetailedGSTLedgerEntryInfo."Original Doc. Type"::Payment;
        ApplyDetailedGSTLedgerEntryInfo."Original Doc. No." := PaymentDocNo;
        ApplyDetailedGSTLedgerEntryInfo.Positive := ApplyDetailedGSTLedgerEntry."GST Amount" > 0;
        ApplyDetailedGSTLedgerEntryInfo."User ID" := CopyStr(UserId, 1, MaxStrLen(ApplyDetailedGSTLedgerEntryInfo."User ID"));
        ApplyDetailedGSTLedgerEntryInfo."RCM Exempt Transaction" := RCMExempt;
        ApplyDetailedGSTLedgerEntryInfo.Insert();
    end;

    local procedure UpdateDetailedGSTApplicationEntryNormalPayment(
        var ApplyDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        RCMExempt: Boolean)
    begin
        ApplyDetailedGSTLedgerEntry.Paid := false;
        ApplyDetailedGSTLedgerEntry."Payment Type" := ApplyDetailedGSTLedgerEntry."Payment Type"::Normal;
        ApplyDetailedGSTLedgerEntry."Credit Availed" := ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::Availment;
        if not RCMExempt then
            ApplyDetailedGSTLedgerEntry."Liable to Pay" := true;

        if RCMExempt then begin
            ApplyDetailedGSTLedgerEntry."Liable to Pay" := false;
            ApplyDetailedGSTLedgerEntry."Credit Availed" := false;
            if (ApplyDetailedGSTLedgerEntry."GST Group Type" = ApplyDetailedGSTLedgerEntry."GST Group Type"::Service) and
                (ApplyDetailedGSTLedgerEntry.Type = ApplyDetailedGSTLedgerEntry.Type::"G/L Account") and
                (ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::"Non-Availment")
            then
                ApplyDetailedGSTLedgerEntry."Amount Loaded on Item" := ApplyDetailedGSTLedgerEntry."GST Amount";
        end;
    end;

    local procedure UpdateDetailedGSTApplicationEntry(
        var ApplyDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        PaymentEntryNo: Integer;
        RCMExempt: Boolean)
    var
        ApplyDetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(ApplyDetailedGSTLedgerEntry, ApplyDetailedGSTLedgerEntryInfo);
        if ApplyDetailedGSTLedgerEntryInfo."RCM Exempt Transaction" then begin
            ApplyDetailedGSTLedgerEntry."GST %" := Abs(Round(ApplyDetailedGSTLedgerEntry."GST Amount" * 100 /
            ApplyDetailedGSTLedgerEntry."GST Base Amount"));
            if (ApplyDetailedGSTLedgerEntry."GST Group Type" = ApplyDetailedGSTLedgerEntry."GST Group Type"::Service) and
               (ApplyDetailedGSTLedgerEntry.Type = ApplyDetailedGSTLedgerEntry.Type::"G/L Account") and
               (ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::"Non-Availment")
            then
                ApplyDetailedGSTLedgerEntry."Amount Loaded on Item" := ApplyDetailedGSTLedgerEntry."GST Amount";
        end;
        if ApplyDetailedGSTLedgerEntry."GST Group Type" = ApplyDetailedGSTLedgerEntry."GST Group Type"::Service then
            ApplyDetailedGSTLedgerEntry."Credit Availed" := true
        else
            if ApplyDetailedGSTLedgerEntry."GST Vendor Type" = ApplyDetailedGSTLedgerEntry."GST Vendor Type"::Unregistered then
                ApplyDetailedGSTLedgerEntry."Credit Availed" := false;
        if (ApplyDetailedGSTLedgerEntry."Associated Enterprises") or
           (ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::"Non-Availment")
        then
            ApplyDetailedGSTLedgerEntry."Credit Availed" := false;

        if RCMExempt then
            if (ApplyDetailedGSTLedgerEntry."GST Group Type" = ApplyDetailedGSTLedgerEntry."GST Group Type"::Goods) then
                ApplyDetailedGSTLedgerEntry."Liable to Pay" := true
            else
                if (ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::Availment) then
                    ApplyDetailedGSTLedgerEntry."Credit Availed" := true
                else
                    if (ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::"Non-Availment") then
                        ApplyDetailedGSTLedgerEntry."Credit Availed" := false;
        ApplyDetailedGSTLedgerEntry.Paid := false;
        ApplyDetailedGSTLedgerEntry.Modify();

        ApplyDetailedGSTLedgerEntryInfo."RCM Exempt" := false;
        ApplyDetailedGSTLedgerEntryInfo."CLE/VLE Entry No." := PaymentEntryNo;
        ApplyDetailedGSTLedgerEntryInfo.Modify();
    end;

    local procedure UpdateDetailedGSTApplicationEntryForex(
        var ApplyDetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        PaymentCurrencyFactor: Decimal;
        DtldGSTLedgerEntCurrencyFactor: Decimal)
    begin
        ApplyDetailedGSTLedgerEntry."Forex Fluctuation" := true;
        ApplyDetailedGSTLedgerEntry.Quantity := 0;

        if ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::"Non-Availment" then
            ApplyDetailedGSTLedgerEntry."Amount Loaded on Item" := ApplyDetailedGSTLedgerEntry."GST Amount";

        if (PaymentCurrencyFactor < DtldGSTLedgerEntCurrencyFactor) and
            (ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::Availment)
        then
            ApplyDetailedGSTLedgerEntry."Credit Availed" := true;
        if (PaymentCurrencyFactor > DtldGSTLedgerEntCurrencyFactor) and
            (ApplyDetailedGSTLedgerEntry."GST Credit" = ApplyDetailedGSTLedgerEntry."GST Credit"::"Non-Availment")
        then
            ApplyDetailedGSTLedgerEntry."Fluctuation Amt. Credit" := true;
    end;

    local procedure FillGSTPostingBufferWithApplication(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ForexFluctuation: Boolean;
        HigherInvoiceExchangeRate: Boolean)
    var
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        Clear(GSTPostingBuffer[1]);
        GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);
        if DetailedGSTLedgerEntry."Transaction Type" = DetailedGSTLedgerEntry."Transaction Type"::Purchase then
            GSTPostingBuffer[1]."Transaction Type" := GSTPostingBuffer[1]."Transaction Type"::Purchase
        else
            GSTPostingBuffer[1]."Transaction Type" := GSTPostingBuffer[1]."Transaction Type"::Sales;

        if DetailedGSTLedgerEntry."Transaction Type" = DetailedGSTLedgerEntry."Transaction Type"::Purchase then
            if DetailedGSTLedgerEntry."GST Group Type" = "GST Group Type"::Service then
                GSTPostingBuffer[1]."GST Group Type" := GSTPostingBuffer[1]."GST Group Type"::Service
            else
                GSTPostingBuffer[1]."GST Group Type" := GSTPostingBuffer[1]."GST Group Type"::Goods;

        if (GSTPostingBuffer[1]."GST Group Type" = GSTPostingBuffer[1]."GST Group Type"::Service) and
           (DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::"Non-Availment") and DetailedGSTLedgerEntryInfo."RCM Exempt Transaction"
        then begin
            DetailedGSTLedgerEntry.TestField(Type, DetailedGSTLedgerEntry.Type::"G/L Account");
            GSTPostingBuffer[1]."Account No." := DetailedGSTLedgerEntry."No."
        end else
            GSTPostingBuffer[1]."Account No." := DetailedGSTLedgerEntry."G/L Account No.";

        GSTPostingBuffer[1].Type := DetailedGSTLedgerEntry.Type;
        GSTPostingBuffer[1]."Gen. Bus. Posting Group" := DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group";
        GSTPostingBuffer[1]."Gen. Prod. Posting Group" := DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group";
        GSTPostingBuffer[1]."GST Base Amount" := DetailedGSTLedgerEntry."GST Base Amount";
        GSTPostingBuffer[1]."GST Amount" := DetailedGSTLedgerEntry."GST Amount";
        GSTPostingBuffer[1]."GST %" := DetailedGSTLedgerEntry."GST %";
        GSTPostingBuffer[1]."GST Component Code" := DetailedGSTLedgerEntry."GST Component Code";
        GSTPostingBuffer[1]."GST Reverse Charge" := DetailedGSTLedgerEntry."Reverse Charge";
        GSTPostingBuffer[1]."Normal Payment" := DetailedGSTLedgerEntry."Payment Type" = "Payment Type"::Normal;
        GSTPostingBuffer[1]."Forex Fluctuation" := ForexFluctuation;
        GSTPostingBuffer[1]."Higher Inv. Exchange Rate" := HigherInvoiceExchangeRate;
        if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::Availment then
            GSTPostingBuffer[1].Availment := true;

        if GSTPostingBuffer[1]."Forex Fluctuation" then
            GSTPostingBuffer[1]."Document Line No." := DetailedGSTLedgerEntry."Document Line No.";

        if GSTPostingBuffer[1]."Forex Fluctuation" and not GSTPostingBuffer[1].Availment then
            if GSTPostingBuffer[1].Type = GSTPostingBuffer[1].Type::"Fixed Asset" then begin
                FADepreciationBook.Get(DetailedGSTLedgerEntry."No.", DetailedGSTLedgerEntryInfo."Depreciation Book Code");
                FAPostingGroup.Get(FADepreciationBook."FA Posting Group");
                FAPostingGroup.TestField("Acquisition Cost Account");
                GSTPostingBuffer[1]."Account No." := FAPostingGroup."Acquisition Cost Account";
                GSTPostingBuffer[1]."No." := DetailedGSTLedgerEntry."No.";
            end else
                if GSTPostingBuffer[1].Type = GSTPostingBuffer[1].Type::"G/L Account" then
                    GSTPostingBuffer[1]."Account No." := DetailedGSTLedgerEntry."No.";

        UpdateGSTPostingBufferWithApplication();
    end;

    local procedure UpdateGSTPostingBufferWithApplication()
    begin
        GSTPostingBuffer[2] := GSTPostingBuffer[1];
        if GSTPostingBuffer[2].Find() then begin
            GSTPostingBuffer[2]."GST Base Amount" += GSTPostingBuffer[1]."GST Base Amount";
            GSTPostingBuffer[2]."GST Amount" += GSTPostingBuffer[1]."GST Amount";
            GSTPostingBuffer[2].Modify();
        end else
            GSTPostingBuffer[1].Insert();
    end;

    local procedure CalculateAndFillGSTPostingBufferForexFluctuation(
        GSTApplicationBuffer: Record "GST Application Buffer";
        PaymentCurrencyFactor: Decimal;
        var HigherInvoiceExchangeRate: Boolean) AppliedBaseAmountInvoiceLCY: Decimal
    var
        GSTApplicationBufferToCheck: Record "GST Application Buffer";
    begin
        if PaymentCurrencyFactor = 0 then begin
            GSTApplicationBufferToCheck.SetRange("Transaction Type", GSTApplicationBufferToCheck."Transaction Type"::Purchase);
            GSTApplicationBufferToCheck.SetRange("Account No.", GSTApplicationBuffer."Account No.");
            GSTApplicationBufferToCheck.SetRange(
                "Original Document Type",
                GSTApplicationLibrary.CurrentDocumentType2OriginalDocumentTypeEnum(GSTApplicationBuffer."Applied Doc. Type"));
            GSTApplicationBufferToCheck.SetRange("Original Document No.", GSTApplicationBuffer."Applied Doc. No.");
            GSTApplicationBufferToCheck.SetRange("Applied Doc. Type", GSTApplicationBufferToCheck."Applied Doc. Type"::Payment);
            GSTApplicationBufferToCheck.SetRange("Applied Doc. No.", GSTApplicationBuffer."Original Document No.");
            GSTApplicationBufferToCheck.SetRange("GST Group Code", GSTApplicationBuffer."GST Group Code");
            GSTApplicationBufferToCheck.SetRange("GST Component Code", GSTApplicationBuffer."GST Component Code");
            if GSTApplicationBufferToCheck.FindFirst() then
                if GSTApplicationBufferToCheck."Currency Factor" <> GSTApplicationBuffer."Currency Factor" then
                    if GSTApplicationBufferToCheck."Currency Factor" < GSTApplicationBuffer."Currency Factor" then
                        AppliedBaseAmountInvoiceLCY :=
                          Round(GSTApplicationBuffer."Applied Base Amount" * GSTApplicationBuffer."Currency Factor" / GSTApplicationBufferToCheck."Currency Factor")
                    else
                        if GSTApplicationBufferToCheck."Currency Factor" > GSTApplicationBuffer."Currency Factor" then
                            AppliedBaseAmountInvoiceLCY :=
                              Round(GSTApplicationBuffer."Applied Base Amount" * GSTApplicationBufferToCheck."Currency Factor" / GSTApplicationBuffer."Currency Factor");

            HigherInvoiceExchangeRate := GSTApplicationBufferToCheck."Currency Factor" < GSTApplicationBuffer."Currency Factor";
        end else begin
            if (GSTApplicationBuffer."Currency Factor" <> PaymentCurrencyFactor) and (GSTApplicationBuffer."Currency Code" <> '') then
                if GSTApplicationBuffer."Currency Factor" < PaymentCurrencyFactor then
                    AppliedBaseAmountInvoiceLCY := Round(Abs(GSTApplicationBuffer."Applied Base Amount") * PaymentCurrencyFactor / GSTApplicationBuffer."Currency Factor")
                else
                    if GSTApplicationBuffer."Currency Factor" > PaymentCurrencyFactor then
                        AppliedBaseAmountInvoiceLCY := Round(GSTApplicationBuffer."Applied Base Amount" * GSTApplicationBuffer."Currency Factor" / PaymentCurrencyFactor);

            HigherInvoiceExchangeRate := GSTApplicationBuffer."Currency Factor" < PaymentCurrencyFactor;
        end;
    end;

    local procedure CreateApplicationGSTLedger(
        GSTPostingBuffer: Record "GST Posting Buffer";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        PostingDate: Date;
        SourceCode: Code[10];
        PaymentType: Enum "Payment Type";
        AccountNo: Code[20];
        BalanceAccountNo: Code[20];
        BalanceAccountNo2: Code[20];
        AccountNo2: Code[20])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);

        GSTLedgerEntry.Init();
        GSTLedgerEntry."Entry No." := 0;
        GSTLedgerEntry."Entry Type" := "Entry Type"::Application;
        GSTLedgerEntry."Gen. Bus. Posting Group" := GSTPostingBuffer."Gen. Bus. Posting Group";
        GSTLedgerEntry."Gen. Prod. Posting Group" := GSTPostingBuffer."Gen. Prod. Posting Group";
        GSTLedgerEntry."Posting Date" := PostingDate;
        GSTLedgerEntry."Document No." := DetailedGSTLedgerEntry."Document No.";
        GSTApplicationLibrary.GetDetailedGSTDocumentTypeFromGSTDocumentType(GSTLedgerEntry."Document Type", DetailedGSTLedgerEntry."Document Type");
        GSTLedgerEntry."Currency Code" := DetailedGSTLedgerEntry."Currency Code";
        GSTLedgerEntry."Currency Factor" := DetailedGSTLedgerEntry."Currency Factor";
        GSTApplicationLibrary.GetGSTLedgerTransactionTypeFromDetailLedgerTransactioType(GSTLedgerEntry."Transaction Type", DetailedGSTLedgerEntry."Transaction Type");
        GSTLedgerEntry."GST Base Amount" := GSTPostingBuffer."GST Base Amount";
        GSTLedgerEntry."GST Amount" := GSTPostingBuffer."GST Amount";

        case DetailedGSTLedgerEntry."Source Type" of
            DetailedGSTLedgerEntry."Source Type"::Vendor:
                GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::Vendor;
            DetailedGSTLedgerEntry."Source Type"::Customer:
                GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::Customer;
        end;

        GSTLedgerEntry."Source No." := DetailedGSTLedgerEntry."Source No.";
        GSTLedgerEntry."Source Code" := SourceCode;
        GSTLedgerEntry."Payment Type" := PaymentType;
        GSTLedgerEntry."Reason Code" := DetailedGSTLedgerEntryInfo."Reason Code";
        GSTLedgerEntry."Transaction No." := DetailedGSTLedgerEntry."Transaction No.";
        GSTLedgerEntry."Input Service Distribution" := DetailedGSTLedgerEntry."Input Service Distribution";
        GSTLedgerEntry."External Document No." := DetailedGSTLedgerEntry."External Document No.";
        if GSTLedgerEntry."Transaction Type" = GSTLedgerEntry."Transaction Type"::Purchase then
            GSTApplicationLibrary.GetPurchGroupTypeFromGSTGroupType(GSTLedgerEntry."Purchase Group Type", GSTPostingBuffer."GST Group Type");
        GSTLedgerEntry."GST Component Code" := GSTPostingBuffer."GST Component Code";
        GSTLedgerEntry."Reverse Charge" := GSTPostingBuffer."GST Reverse Charge";
        GSTLedgerEntry.Availment := GSTPostingBuffer.Availment;
        GSTLedgerEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(GSTLedgerEntry."User ID"));
        GSTLedgerEntry."Account No." := AccountNo;
        GSTLedgerEntry."Bal. Account No." := BalanceAccountNo;
        GSTLedgerEntry."Bal. Account No. 2" := BalanceAccountNo2;
        GSTLedgerEntry."Account No. 2" := AccountNo2;
        GSTLedgerEntry.Insert(true);
    end;

    local procedure PostToGLEntry(
        var GenJournalLine: Record "Gen. Journal Line";
        GLAccountNo: Code[20];
        Amount: Decimal)
    begin
        GSTApplSessionMgt.CreateApplicationGenJournallLine(GenJournalLine, GLAccountNo, Amount, true);
    end;

    local procedure ApplyGSTApplicationCreditMemo(
        CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        OldCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        TransactionType: Enum "Detail Ledger Transaction Type")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CreditMemoNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeApplyGSTApplicationCreditMemo(CVLedgerEntryBuffer, OldCVLedgerEntryBuffer, TransactionType, IsHandled);
        if IsHandled then
            exit;

        if (CVLedgerEntryBuffer."Document Type" <> CVLedgerEntryBuffer."Document Type"::"Credit Memo") and
          (OldCVLedgerEntryBuffer."Document Type" <> OldCVLedgerEntryBuffer."Document Type"::"Credit Memo") then
            exit;

        if (CVLedgerEntryBuffer."Document Type" <> CVLedgerEntryBuffer."Document Type"::Invoice) and
          (OldCVLedgerEntryBuffer."Document Type" <> OldCVLedgerEntryBuffer."Document Type"::Invoice) then
            exit;

        if CVLedgerEntryBuffer."Document Type" = CVLedgerEntryBuffer."Document Type"::"Credit Memo" then
            CreditMemoNo := CVLedgerEntryBuffer."Document No."
        else
            CreditMemoNo := OldCVLedgerEntryBuffer."Document No.";

        DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Document Line No.");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", TransactionType);
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::"Credit Memo");
        DetailedGSTLedgerEntry.SetRange("Document No.", CreditMemoNo);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange(UnApplied, false);
    end;

    local procedure GSTUnapplicationRestrictionPurch(VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        DtldVendLedgEnt: Record "Detailed Vendor Ledg. Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        ApplicationEntryNo: Integer;
        GSTDocType: Enum "GST Document Type";
    begin
        ApplicationEntryNo := 0;
        DtldVendLedgEnt.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
        DtldVendLedgEnt.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        DtldVendLedgEnt.SetRange("Entry Type", DtldVendLedgEnt."Entry Type"::Application);
        DtldVendLedgEnt.SetRange(Unapplied, false);
        if DtldVendLedgEnt.FindSet() then
            repeat
                if DtldVendLedgEnt."Entry No." > ApplicationEntryNo then
                    ApplicationEntryNo := DtldVendLedgEnt."Entry No.";
            until DtldVendLedgEnt.Next() = 0;

        if VendorLedgerEntry."GST Reverse Charge" then
            case VendorLedgerEntry."Document Type" of
                VendorLedgerEntry."Document Type"::Invoice:
                    begin
                        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
                        DetailedGSTLedgerEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
                        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::Application);
                        DetailedGSTLedgerEntry.SetRange("GST Group Type", DetailedGSTLedgerEntry."GST Group Type"::Service);
                        DetailedGSTLedgerEntry.SetRange("Credit Availed", true);
                        DetailedGSTLedgerEntry.SetRange("Credit Adjustment Type", DetailedGSTLedgerEntry."Credit Adjustment Type"::"Credit Reversal");
                        if not DetailedGSTLedgerEntry.IsEmpty() then
                            Error(UnApplicationErr);

                        DetailedGSTLedgerEntry.SetRange("Credit Availed");
                        DetailedGSTLedgerEntry.SetRange("Credit Adjustment Type");
                        DetailedGSTLedgerEntry.SetRange("Credit Availed", false);
                        DetailedGSTLedgerEntry.SetRange("Credit Adjustment Type", DetailedGSTLedgerEntry."Credit Adjustment Type"::"Credit Availment");
                        if not DetailedGSTLedgerEntry.IsEmpty() then
                            Error(UnApplicationErr);
                    end;
                VendorLedgerEntry."Document Type"::Payment:
                    begin
                        if not DetailedVendorLedgEntry.Get(ApplicationEntryNo) then
                            exit;

                        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
                        DetailedGSTLedgerEntry.SetRange("Document No.", DetailedVendorLedgEntry."Document No.");
                        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::Application);
                        DetailedGSTLedgerEntry.SetRange("GST Group Type", DetailedGSTLedgerEntry."GST Group Type"::Service);
                        DetailedGSTLedgerEntry.SetRange("Credit Availed", true);
                        DetailedGSTLedgerEntry.SetRange("Credit Adjustment Type", DetailedGSTLedgerEntry."Credit Adjustment Type"::"Credit Reversal");
                        if not DetailedGSTLedgerEntry.IsEmpty() then
                            Error(UnApplicationErr);

                        DetailedGSTLedgerEntry.SetRange("Credit Availed");
                        DetailedGSTLedgerEntry.SetRange("Credit Adjustment Type");
                        DetailedGSTLedgerEntry.SetRange("Credit Availed", false);
                        DetailedGSTLedgerEntry.SetRange("Credit Adjustment Type", DetailedGSTLedgerEntry."Credit Adjustment Type"::"Credit Availment");
                        if not DetailedGSTLedgerEntry.IsEmpty() then
                            Error(UnApplicationErr);
                    end;
            end;

        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Source No.", VendorLedgerEntry."Vendor No.");
        GSTApplicationLibrary.GetGSTDocumentTypeFromGenJournalDocumentType(GSTDocType, VendorLedgerEntry."Document Type");
        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocType);
        DetailedGSTLedgerEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
        if DetailedGSTLedgerEntry.FindFirst() then
            if (DetailedGSTLedgerEntry."Cr. & Liab. Adjustment Type" = DetailedGSTLedgerEntry."Cr. & Liab. Adjustment Type"::Generate) and
                ((DetailedGSTLedgerEntry."GST Base Amount" - DetailedGSTLedgerEntry."AdjustmentBase Amount") < DtldVendLedgEnt."Amount (LCY)") then
                Error(GSTInvoiceLiabilityErr);
    end;

    local procedure UnApplyGSTApplication(
        GenJournalLine: Record "Gen. Journal Line";
        TransactionType: Enum "Detail Ledger Transaction Type";
        TransactionNo: Integer;
        DocumentNo: Code[20])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        if GenJournalLine."Document Type" = GenJournalLine."Document Type"::Refund then
            exit;

        DetailedGSTLedgerEntry.SetCurrentKey("Transaction No.");
        DetailedGSTLedgerEntry.SetRange("Transaction No.", TransactionNo);
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("Transaction Type", TransactionType);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::Application);
        DetailedGSTLedgerEntry.SetRange(UnApplied, false);
        if DetailedGSTLedgerEntry.FindSet() then begin
            GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntry, DetailedGSTLedgerEntryInfo);
            CreateUnapplicationGSTLedger(GenJournalLine, TransactionType, TransactionNo, DocumentNo, DetailedGSTLedgerEntryInfo."RCM Exempt Transaction");
            GSTPostingBuffer[1].DeleteAll();

            repeat
                InsertUnApplicationDetailedGSTLedgerEntry(DetailedGSTLedgerEntry);
            until DetailedGSTLedgerEntry.Next() = 0;
        end;
    end;

    local procedure InsertUnApplicationDetailedGSTLedgerEntry(DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry")
    var
        DetailedGSTLedgerEntryNew: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryOld: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfoOld: Record "Detailed GST Ledger Entry Info";
        DetailedGSTLedgerEntryInfoNew: Record "Detailed GST Ledger Entry Info";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        DetailedGSTLedgerEntryNew.Init();
        DetailedGSTLedgerEntryNew.TransferFields(DetailedGSTLedgerEntry);
        DetailedGSTLedgerEntryNew."Entry No." := 0;
        DetailedGSTLedgerEntryNew."Document No." := DetailedGSTLedgerEntryNew."Document No.";
        DetailedGSTLedgerEntryNew."Transaction No." := DetailedGSTLedgerEntry."Transaction No.";
        DetailedGSTLedgerEntryNew."Entry Type" := DetailedGSTLedgerEntryNew."Entry Type"::Application;
        DetailedGSTLedgerEntryNew."GST Base Amount" := -DetailedGSTLedgerEntry."GST Base Amount";
        DetailedGSTLedgerEntryNew."GST Amount" := -DetailedGSTLedgerEntry."GST Amount";
        DetailedGSTLedgerEntryNew.Quantity := -DetailedGSTLedgerEntry.Quantity;
        DetailedGSTLedgerEntryNew."Applied From Entry No." := DetailedGSTLedgerEntry."Entry No.";
        DetailedGSTLedgerEntryNew.UnApplied := true;
        DetailedGSTLedgerEntryNew.Paid := false;
        DetailedGSTLedgerEntryNew."Amount Loaded on Item" := -DetailedGSTLedgerEntry."Amount Loaded on Item";
        DetailedGSTLedgerEntryNew.Insert(true);

        DetailedGSTLedgerEntryOld.Get(DetailedGSTLedgerEntry."Entry No.");
        DetailedGSTLedgerEntryOld.UnApplied := true;
        DetailedGSTLedgerEntryOld.Modify(true);

        GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEntryOld, DetailedGSTLedgerEntryInfoOld);
        DetailedGSTLedgerEntryInfoNew.Init();
        DetailedGSTLedgerEntryInfoNew.TransferFields(DetailedGSTLedgerEntryInfoOld);
        DetailedGSTLedgerEntryInfoNew."Entry No." := DetailedGSTLedgerEntryNew."Entry No.";
        DetailedGSTLedgerEntryInfoNew."User ID" := CopyStr(UserId, 1, MaxStrLen(DetailedGSTLedgerEntryInfoNew."User ID"));
        DetailedGSTLedgerEntryInfoNew.Positive := DetailedGSTLedgerEntryNew."GST Amount" > 0;
        DetailedGSTLedgerEntryInfoNew.Insert();

        if not DetailedGSTLedgerEntryNew."Forex Fluctuation" then begin
            DetailedGSTLedgerEntryOld.Get(DetailedGSTLedgerEntry."Applied From Entry No.");
            DetailedGSTLedgerEntryOld."Remaining Base Amount" += DetailedGSTLedgerEntryNew."GST Base Amount";
            DetailedGSTLedgerEntryOld."Remaining GST Amount" += DetailedGSTLedgerEntryNew."GST Amount";
            DetailedGSTLedgerEntryOld.Modify();

            DetailedGSTLedgerEntryInfoOld."Remaining Amount Closed" := false;
            DetailedGSTLedgerEntryInfoOld.Modify();
        end else begin
            VendorLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntryInfoNew."Original Doc. Type");
            VendorLedgerEntry.SetRange("Document No.", DetailedGSTLedgerEntryInfoNew."Original Doc. No.");
            VendorLedgerEntry.SetRange("Vendor No.", DetailedGSTLedgerEntryNew."Source No.");
            if VendorLedgerEntry.FindFirst() then
                if VendorLedgerEntry."Original Currency Factor" > DetailedGSTLedgerEntryNew."Currency Factor" then begin
                    DetailedGSTLedgerEntryOld.Get(DetailedGSTLedgerEntry."Applied From Entry No.");
                    DetailedGSTLedgerEntryOld."Remaining Base Amount" += DetailedGSTLedgerEntryNew."GST Base Amount";
                    DetailedGSTLedgerEntryOld."Remaining GST Amount" += DetailedGSTLedgerEntryNew."GST Amount";
                    DetailedGSTLedgerEntryOld.Modify();

                    DetailedGSTLedgerEntryInfoOld."Remaining Amount Closed" := false;
                    DetailedGSTLedgerEntryInfoOld.Modify();
                end;
        end;

        UnapplyFluctuationRevaluationEntry(DetailedGSTLedgerEntryNew);
    end;

    local procedure CreateUnapplicationGSTLedger(
        GenJournalLine: Record "Gen. Journal Line";
        TransactionType: Enum "Detail Ledger Transaction Type";
        TransactionNo: Integer;
        DocumentNo: Code[20];
        RCMExempt: Boolean)
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        GSTLedgerTransactionType: Enum "GST Ledger Transaction Type";
    begin
        GSTApplicationLibrary.GetGSTLedgerTransactionTypeFromDetailLedgerTransactioType(GSTLedgerTransactionType, TransactionType);

        GSTLedgerEntry.SetCurrentKey("Transaction No.");
        GSTLedgerEntry.SetRange("Transaction No.", TransactionNo);
        GSTLedgerEntry.SetRange("Document No.", DocumentNo);
        GSTLedgerEntry.SetRange("Transaction Type", GSTLedgerTransactionType);
        GSTLedgerEntry.SetRange("Entry Type", "Entry Type"::Application);
        GSTLedgerEntry.SetRange(UnApplied, false);
        if GSTLedgerEntry.FindSet() then
            repeat
                InsertUnApplicationGSTLedgerEntry(GSTLedgerEntry, TransactionNo, GenJournalLine."Source Code");

                if GSTLedgerEntry."Transaction Type" = GSTLedgerEntry."Transaction Type"::Sales then
                    PostSalesApplicationGLEntries(GenJournalLine, GSTLedgerEntry."Account No.", GSTLedgerEntry."Bal. Account No.", true, GSTLedgerEntry."GST Amount")
                else
                    if GSTLedgerEntry."Payment Type" = GSTLedgerEntry."Payment Type"::Normal then
                        PostNormalPaymentApplicationGLEntries(
                            GenJournalLine,
                            true,
                            GSTLedgerEntry."Account No.",
                            GSTLedgerEntry."Account No. 2",
                            GSTLedgerEntry."Bal. Account No.",
                            GSTLedgerEntry."Bal. Account No. 2",
                            GSTLedgerEntry."GST Amount")
                    else
                        PostPurchaseApplicationGLEntries(
                            GenJournalLine,
                            true,
                            GSTLedgerEntry."Account No.",
                            GSTLedgerEntry."Bal. Account No.",
                            GSTLedgerEntry."Bal. Account No. 2",
                            GSTLedgerEntry."GST Amount", RCMExempt);
            until GSTLedgerEntry.Next() = 0;
    end;

    local procedure InsertUnApplicationGSTLedgerEntry(
        GSTLedgerEntry: Record "GST Ledger Entry";
        TransactionNo: Integer;
        SourceCode: Code[10])
    var
        GSTLedgerEntryNew: Record "GST Ledger Entry";
        GSTLedgerEntryOld: Record "GST Ledger Entry";
    begin
        GSTLedgerEntryNew.Init();
        GSTLedgerEntryNew.TransferFields(GSTLedgerEntry);
        GSTLedgerEntryNew."Entry No." := 0;
        GSTLedgerEntryNew."Document Type" := GSTLedgerEntryNew."Document Type"::Invoice;
        GSTLedgerEntryNew."Document No." := GSTLedgerEntry."Document No.";
        GSTLedgerEntryNew."Transaction No." := TransactionNo;
        GSTLedgerEntryNew."Source Code" := SourceCode;
        GSTLedgerEntryNew."GST Base Amount" := -GSTLedgerEntry."GST Base Amount";
        GSTLedgerEntryNew."GST Amount" := -GSTLedgerEntry."GST Amount";
        GSTLedgerEntryNew."User ID" := CopyStr(UserId, 1, MaxStrLen(GSTLedgerEntryNew."User ID"));
        GSTLedgerEntryNew.UnApplied := true;
        GSTLedgerEntryNew.Insert(true);
        GSTLedgerEntryOld.Get(GSTLedgerEntry."Entry No.");
        GSTLedgerEntryOld.UnApplied := true;
        GSTLedgerEntryOld.Modify(true);
    end;

    local procedure UnapplyFluctuationRevaluationEntry(DetailedGSTLedgerEnt: Record "Detailed GST Ledger Entry")
    var
        SourceCodeSetup: Record "Source Code Setup";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalLineToPost: Record "Item Journal Line";
        FALedgerEntry: Record "FA Ledger Entry";
        FALedgerEntryNew: Record "FA Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        EntryNo: Integer;
    begin
        if DetailedGSTLedgerEnt."Forex Fluctuation" and
           (DetailedGSTLedgerEnt."GST Credit" = DetailedGSTLedgerEnt."GST Credit"::"Non-Availment")
        then
            if DetailedGSTLedgerEnt.Type = DetailedGSTLedgerEnt.Type::Item then begin
                ValueEntry.Reset();
                ValueEntry.SetRange("Document No.", DetailedGSTLedgerEnt."Document No.");
                ValueEntry.SetRange("Document Line No.", DetailedGSTLedgerEnt."Document Line No.");
                if ValueEntry.FindFirst() then begin
                    if not ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
                        exit;

                    SourceCodeSetup.Get();
                    if DetailedGSTLedgerEnt."GST Amount" <> 0 then begin
                        GSTApplicationLibrary.GetDetailedGSTLedgerEntryInfo(DetailedGSTLedgerEnt, DetailedGSTLedgerEntryInfo);
                        ItemJournalLine.Init();
                        ItemJournalLine.Validate("Posting Date", ItemLedgerEntry."Posting Date");
                        ItemJournalLine."Document Date" := ItemLedgerEntry."Posting Date";
                        ItemJournalLine.Validate("Document No.", ValueEntry."Document No.");
                        ItemJournalLine."Document Line No." := ItemLedgerEntry."Document Line No.";
                        ItemJournalLine."External Document No." := ItemLedgerEntry."External Document No.";
                        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::Purchase);
                        ItemJournalLine."Value Entry Type" := ItemJournalLine."Value Entry Type"::Revaluation;
                        ItemJournalLine.Validate("Item No.", ItemLedgerEntry."Item No.");
                        ItemJournalLine."Source Type" := ItemJournalLine."Source Type"::Vendor;
                        ItemJournalLine."Source No." := ItemLedgerEntry."Source No.";
                        ItemJournalLine."Gen. Bus. Posting Group" := DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group";
                        ItemJournalLine."Gen. Prod. Posting Group" := DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group";
                        ItemJournalLine."Source Code" := SourceCodeSetup."Revaluation Journal";
                        ItemJournalLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");

                        if DetailedGSTLedgerEnt."Fluctuation Amt. Credit" then
                            ItemJournalLine.Validate(
                                "Unit Cost (Revalued)",
                                ItemJournalLine."Unit Cost (Revalued)" + DetailedGSTLedgerEnt."GST Amount" / ItemLedgerEntry.Quantity)
                        else
                            ItemJournalLine.Validate(
                                "Unit Cost (Revalued)",
                                ItemJournalLine."Unit Cost (Revalued)" - DetailedGSTLedgerEnt."GST Amount" / ItemLedgerEntry.Quantity);

                        ItemJournalLineToPost.Init();
                        ItemJournalLineToPost.TransferFields(ItemJournalLine);
                        ItemJnlPostLine.Run(ItemJournalLineToPost);
                    end;
                end;
            end else
                if DetailedGSTLedgerEnt.Type = DetailedGSTLedgerEnt.Type::"Fixed Asset" then begin
                    FALedgerEntry.FindLast();
                    EntryNo := FALedgerEntry."Entry No." + 1;

                    FALedgerEntry.Reset();
                    FALedgerEntry.SetRange("Document No.", DetailedGSTLedgerEnt."Document No.");
                    FALedgerEntry.SetRange("FA No.", DetailedGSTLedgerEnt."No.");
                    if FALedgerEntry.FindFirst() then begin
                        FALedgerEntryNew.Copy(FALedgerEntry);
                        FALedgerEntryNew."Entry No." := EntryNo;
                        if DetailedGSTLedgerEnt."Fluctuation Amt. Credit" then begin
                            FALedgerEntryNew.Amount := DetailedGSTLedgerEnt."GST Amount";
                            FALedgerEntryNew."Amount (LCY)" := DetailedGSTLedgerEnt."GST Amount";
                            FALedgerEntryNew."Debit Amount" := DetailedGSTLedgerEnt."GST Amount";
                        end else begin
                            FALedgerEntryNew.Amount := Abs(DetailedGSTLedgerEnt."GST Amount");
                            FALedgerEntryNew."Amount (LCY)" := Abs(DetailedGSTLedgerEnt."GST Amount");
                            FALedgerEntryNew."Debit Amount" := Abs(DetailedGSTLedgerEnt."GST Amount");
                        end;
                        FALedgerEntryNew.Insert(true);
                    end;
                end;
    end;

    local procedure UnApplyGSTApplicationCreditMemo(TransactionType: Enum "Detail Ledger Transaction Type"; DocumentNo: Code[20])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Document Type", "Document No.", "Document Line No.");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", TransactionType);
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::"Credit Memo");
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange(UnApplied, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeApplyVendLedgEntry', '', false, false)]
    local procedure OnBeforeApplyVendLedgEntry(
        var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
        var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer";
        var GenJnlLine: Record "Gen. Journal Line";
        Vend: Record Vendor;
        var IsAmountToApplyCheckHandled: Boolean)
    begin
        SetGSTApplicationSourcePurch(NewCVLedgEntryBuf, GenJnlLine, Vend);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeApplyCustLedgEntry', '', false, false)]
    local procedure OnBeforeApplyCustLedgEntry(
        var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
        var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer";
        var GenJnlLine: Record "Gen. Journal Line";
        Cust: Record Customer;
        var IsAmountToApplyCheckHandled: Boolean)
    begin
        SetGSTApplicationSourceSales(NewCVLedgEntryBuf, GenJnlLine, Cust);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterFindAmtForAppln', '', false, false)]
    local procedure OnAfterFindAmtForAppln(
        var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
        var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
        var OldCVLedgEntryBuf2: Record "CV Ledger Entry Buffer";
        var AppliedAmount: Decimal;
        var AppliedAmountLCY: Decimal;
        var OldAppliedAmount: Decimal)
    begin
        SetGSTApplicationAmount(AppliedAmount, AppliedAmountLCY);
    end;

    [EventSubscriber(ObjectType::Table, Database::"CV Ledger Entry Buffer", 'OnAfterCopyFromCustLedgerEntry', '', false, false)]
    local procedure OnAfterCopyCVLedgEntryBufFromCustLedgerEntry(
        var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        SetOnlineCustLedgerEntry(CustLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Table, Database::"CV Ledger Entry Buffer", 'OnAfterCopyFromVendLedgerEntry', '', false, false)]
    local procedure OnAfterCopyCVLedgEntryBufFFromVendLedgerEntry(
        var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        SetOnlineVendLedgerEntry(VendorLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnBeforePostApplyVendLedgEntry', '', false, false)]
    local procedure OnBeforePostApplyVendLedgEntry(
        var GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        GenJournalLine."Offline Application" := true;
        GenJournalLine."Currency Code" := VendorLedgerEntry."Currency Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnBeforePostApplyCustLedgEntry', '', false, false)]
    local procedure OnBeforePostApplyCustLedgEntry(
        var GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        GenJournalLine."Offline Application" := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnValidateAmountOnAfterAssignAmountLCY', '', false, false)]
    local procedure GenJnlLineOnValidateAmountOnAfterAssignAmountLCY(var sender: Record "Gen. Journal Line"; var AmountLCY: Decimal)
    begin
        if (sender."Journal Template Name" = '') and (sender."Journal Batch Name" = '') then
            sender.SetSuppressCommit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterPostApply', '', false, false)]
    local procedure OnAfterPostApply(
        GenJnlLine: Record "Gen. Journal Line";
        var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer";
        var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
        var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer";
        var NewCVLedgEntryBuf2: Record "CV Ledger Entry Buffer")
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        VendLedgEntry: Record "Vendor Ledger Entry";
        AppliedForeignCurrAmt: Decimal;
        VendNo: Code[20];
        CustNo: Code[20];
        AppliedAmt: Decimal;
        AppliedAmtLCY: Decimal;
    begin
        if Customer.Get(NewCVLedgEntryBuf."CV No.") and (GenJnlLine."Account Type" = GenJnlLine."Account Type"::Customer) then begin
            SetGSTApplicationSourceSales(NewCVLedgEntryBuf, GenJnlLine, Customer);
            GSTApplSessionMgt.GetGSTTransactionType(GSTTransactionType);
        end
        else
            if Vendor.Get(NewCVLedgEntryBuf."CV No.") and (GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor) then begin
                SetGSTApplicationSourcePurch(NewCVLedgEntryBuf, GenJnlLine, Vendor);
                GSTApplSessionMgt.GetGSTTransactionType(GSTTransactionType);
            end;

        case GSTTransactionType of
            GSTTransactionType::Purchase:
                begin
                    GSTApplSessionMgt.SetOnlinePostApplication(false);
                    GSTApplSessionMgt.GetGSTApplicationSourcePurch(TransactionNo, GSTTransactionType, VendNo);
                    GSTApplSessionMgt.GetGSTApplicationAmount(AppliedAmt, AppliedAmtLCY);
                    if Vendor.Get(VendNo) then begin
                        if GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::Payment] then
                            if OldCVLedgEntryBuf."Currency Code" <> '' then begin
                                if (NewCVLedgEntryBuf."Original Currency Factor" > OldCVLedgEntryBuf."Original Currency Factor") or (NewCVLedgEntryBuf."Original Currency Factor" < OldCVLedgEntryBuf."Original Currency Factor") then begin
                                    VendLedgEntry.Get(OldCVLedgEntryBuf."Entry No.");
                                    if VendLedgEntry."GST Reverse Charge" then
                                        AppliedForeignCurrAmt := Round(AppliedAmt / OldCVLedgEntryBuf."Adjusted Currency Factor")
                                    else
                                        AppliedForeignCurrAmt := Round(AppliedAmt / NewCVLedgEntryBuf."Adjusted Currency Factor");
                                    PostGSTPurchaseApplication(GenJnlLine, NewCVLedgEntryBuf, OldCVLedgEntryBuf, AppliedForeignCurrAmt);
                                end else
                                    PostGSTPurchaseApplication(GenJnlLine, NewCVLedgEntryBuf, OldCVLedgEntryBuf, AppliedAmtLCY);
                                SetPostApplication(Vendor, GenJnlLine);
                            end else
                                PostGSTPurchaseApplication(GenJnlLine, NewCVLedgEntryBuf, OldCVLedgEntryBuf, AppliedAmtLCY);

                        ApplyGSTApplicationCreditMemo(NewCVLedgEntryBuf, OldCVLedgEntryBuf, GSTTransactionType::Purchase);
                    end;
                end;
            GSTTransactionType::Sales:
                begin
                    GSTApplSessionMgt.GetGSTApplicationSourceSales(TransactionNo, GSTTransactionType, CustNo);
                    GSTApplSessionMgt.GetGSTApplicationAmount(AppliedAmt, AppliedAmtLCY);

                    if Customer.Get(CustNo) then begin
                        if GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::Payment] then
                            PostGSTSalesApplication(GenJnlLine, NewCVLedgEntryBuf, OldCVLedgEntryBuf, AppliedAmtLCY);

                        ApplyGSTApplicationCreditMemo(NewCVLedgEntryBuf, OldCVLedgEntryBuf, GSTTransactionType::Sales);
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithCheck', '', false, false)]
    local procedure OnGenJnlPostLineOnAfterRunWithCheck(sender: Codeunit "Gen. Jnl.-Post Line")
    begin
        GSTApplSessionMgt.PostApplicationGenJournalLine(sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithoutCheck', '', false, false)]
    local procedure OnGenJnlPostLineOnAfterRunWithOutCheck(sender: Codeunit "Gen. Jnl.-Post Line")
    begin
        GSTApplSessionMgt.PostApplicationGenJournalLine(sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnBeforePostUnapplyVendLedgEntry', '', false, false)]
    local procedure OnBeforePostUnapplyVendLedgEntry(
        var GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry")
    begin
        GSTUnapplicationRestrictionPurch(VendorLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertDtldVendLedgEntryUnapply', '', false, false)]
    local procedure OnBeforeInsertDtldVendLedgEntryUnapply(
        var NewDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        GenJournalLine: Record "Gen. Journal Line";
        OldDtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        if OldDtldVendLedgEntry."Initial Document Type" = OldDtldVendLedgEntry."Initial Document Type"::"Credit Memo" then
            if VendorLedgerEntry.Get(OldDtldVendLedgEntry."Vendor Ledger Entry No.") then
                UnApplyGSTApplicationCreditMemo(TransactionType::Purchase, VendorLedgerEntry."Document No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCreateGLEntriesForTotalAmountsUnapplyVendorV19', '', false, false)]
    local procedure OnBeforeCreateGLEntriesForTotalAmountsUnapplyVendor(
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        var VendorPostingGroup: Record "Vendor Posting Group";
        GenJournalLine: Record "Gen. Journal Line";
        var TempDimPostingBuffer: Record "Dimension Posting Buffer" temporary)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        VendorLedgerEntry.Get(DetailedVendorLedgEntry."Vendor Ledger Entry No.");
        UnApplyGSTApplication(GenJournalLine, TransactionType::Purchase, VendorLedgerEntry."Transaction No.", DetailedVendorLedgEntry."Document No.");
        GSTApplSessionMgt.PostApplicationGenJournalLine(GenJnlPostLine);
        GSTApplSessionMgt.ClearAllSessionVariables();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertDtldCustLedgEntryUnapply', '', false, false)]
    local procedure OnBeforeInsertDtldCustLedgEntryUnapply(
        var NewDtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GenJournalLine: Record "Gen. Journal Line";
        OldDtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        if OldDtldCustLedgEntry."Initial Document Type" = OldDtldCustLedgEntry."Initial Document Type"::"Credit Memo" then
            if CustLedgerEntry.Get(OldDtldCustLedgEntry."Cust. Ledger Entry No.") then
                UnApplyGSTApplicationCreditMemo(TransactionType::Sales, CustLedgerEntry."Document No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCreateGLEntriesForTotalAmountsUnapplyV19', '', false, false)]
    local procedure OnBeforeCreateGLEntriesForTotalAmountsUnapply(
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        var CustomerPostingGroup: Record "Customer Posting Group";
        GenJournalLine: Record "Gen. Journal Line";
        var TempIDimPostingBuffer: Record "Dimension Posting Buffer" temporary)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        CustLedgerEntry.Get(DetailedCustLedgEntry."Cust. Ledger Entry No.");
        UnApplyGSTApplication(GenJournalLine, TransactionType::Sales, CustLedgerEntry."Transaction No.", DetailedCustLedgEntry."Document No.");
        GSTApplSessionMgt.PostApplicationGenJournalLine(GenJnlPostLine);
        GSTApplSessionMgt.ClearAllSessionVariables();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed GST Ledger Entry", 'OnAfterModifyEvent', '', false, false)]
    local procedure UpdateDetLedgerEntInfoFields(Rec: Record "Detailed GST Ledger Entry")
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
    begin
        if (Rec."Entry Type" = Rec."Entry Type"::"Initial Entry") and (DetailedGSTLedgerEntryInfo.Get(Rec."Entry No.")) then begin
            DetailedGSTLedgerEntryInfo."Remaining Amount Closed" := (Rec."Remaining Base Amount" = 0);
            DetailedGSTLedgerEntryInfo.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', false, false)]
    local procedure OnAfterInitGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; Amount: Decimal; AddCurrAmount: Decimal; UseAddCurrAmount: Boolean; var CurrencyFactor: Decimal)
    var
        LastEntryNo: Integer;
    begin
        if GSTApplSessionMgt.GetOnlinePostApplication() then begin
            LastEntryNo := GSTApplSessionMgt.GetOnlinePostApplicationLastEntryNo();
            if LastEntryNo <> 0 then begin
                GLEntry."Entry No." := LastEntryNo + 1;
                GSTApplSessionMgt.SetOnlinePostApplicationLastEntryNo(GLEntry."Entry No.");
            end
            else begin
                LastEntryNo := InitNextEntryNo();
                GLEntry."Entry No." := LastEntryNo;
                GSTApplSessionMgt.SetOnlinePostApplicationLastEntryNo(LastEntryNo);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnAfterPostApplyVendLedgEntry', '', false, false)]
    local procedure OnAfterPostApplyVendLedgEntry(GenJournalLine: Record "Gen. Journal Line"; VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        ClearPostApplication();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLRegister', '', false, false)]
    local procedure OnAfterInitGLRegister(var GLRegister: Record "G/L Register"; var GenJournalLine: Record "Gen. Journal Line")
    var
        LastEntryNo: Integer;
    begin
        if GSTApplSessionMgt.GetOnlinePostApplication() then begin
            LastEntryNo := GSTApplSessionMgt.GetOnlinePostApplicationLastEntryNoForGLRegister();
            if LastEntryNo <> 0 then begin
                GLRegister."No." := LastEntryNo + 1;
                GSTApplSessionMgt.SetOnlinePostApplicationLastEntryNoForGLRegister(GLRegister."No.");
            end
            else begin
                LastEntryNo := InitGLRegNextEntryNo();
                GLRegister."No." := LastEntryNo;
                GSTApplSessionMgt.SetOnlinePostApplicationLastEntryNoForGLRegister(GLRegister."No.");
            end;
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', false, false)]
    local procedure OnRunPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    begin
        ClearPostApplication();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeUpdateGLReg', '', false, false)]
    local procedure OnBeforeUpdateGLReg(IsTransactionConsistent: Boolean; var IsGLRegInserted: Boolean; var GLReg: Record "G/L Register"; var IsHandled: Boolean; var GenJnlLine: Record "Gen. Journal Line"; GlobalGLEntry: Record "G/L Entry")
    begin
        BeforeUpdateGLReg(IsTransactionConsistent, IsGLRegInserted, GLReg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure PurchPostOnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header")
    begin
        CheckGSTVendorType(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure PurchPostOnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header")
    begin
        UpdateSubconPurchaseHeader(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterPostItemJnlLine', '', false, false)]
    local procedure OnAfterPostItemJnlLine(
        var ItemJournalLine: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        var ValueEntryNo: Integer;
        var InventoryPostingToGL: Codeunit "Inventory Posting To G/L";
        CalledFromAdjustment: Boolean;
        CalledFromInvtPutawayPick: Boolean;
        var ItemRegister: Record "Item Register";
        var ItemLedgEntryNo: Integer;
        var ItemApplnEntryNo: Integer)
    begin
        SubcontractingEntryNosAfterPostItemJnlLine(ItemJournalLine, ItemLedgEntryNo, ItemApplnEntryNo, ValueEntryNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure OnBeforePostItemJnlLine(
        var ItemJournalLine: Record "Item Journal Line";
        CalledFromAdjustment: Boolean;
        CalledFromInvtPutawayPick: Boolean;
        var ItemRegister: Record "Item Register";
        var ItemLedgEntryNo: Integer;
        var ValueEntryNo: Integer;
        var ItemApplnEntryNo: Integer)
    begin
        SubcontractingEntryNosBeforePostItemJnlLine(ItemJournalLine, ItemLedgEntryNo, ValueEntryNo, ItemApplnEntryNo);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Order Subcon Details Receipt", 'OnBeforeActionEvent', '&Receive', true, true)]
    local procedure OnBeforeActionEvent(var Rec: Record "Purchase Line")
    begin
        SubconOrderReceiptBeforeActionEvent(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Order Subcon Details Receipt", 'OnAfterActionEvent', '&Receive', true, true)]
    local procedure OnAfterActionEvent(Rec: Record "Purchase Line")
    begin
        SubconOrderReceiptAfterActionEvent(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Multiple Order Subcon Receipt", 'OnBeforeActionEvent', '&Receive', true, true)]
    local procedure OnBeforeActionEventMultipleSubCon(var Rec: Record "Multiple Subcon. Order Details")
    begin
        MultipleSubconOrderReceiptBeforeActionEvent(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Multiple Order Subcon Receipt", 'OnAfterActionEvent', '&Receive', true, true)]
    local procedure OnAfterActionEventMultipleSubCon(Rec: Record "Multiple Subcon. Order Details")
    begin
        MultipleSubconOrderReceiptAfterActionEvent(Rec."Subcontractor No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnCopyToTempLinesOnAfterSetFilters', '', false, false)]
    local procedure OnCopyToTempLinesOnAfterSetFilters(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header")
    begin
        PurchPostOnCopyToTempLinesOnAfterSetFilters(PurchaseLine, PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchLine', '', false, false)]
    local procedure OnBeforePostPurchLine(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        SubcontractingPurchPostBeforePostPurchLine(PurchHeader, PurchLine, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', false, false)]
    local procedure SubcontractingOnAfterInitGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; Amount: Decimal; AddCurrAmount: Decimal; UseAddCurrAmount: Boolean; var CurrencyFactor: Decimal)
    begin
        InitSubconMultipleRecieptNextGLEntry(GLEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnBeforeConfirmPost', '', false, false)]
    local procedure OnBeforeConfirmPost(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer)
    begin
        SubcontractingPurchPostYesNoBeforeConfirmPost(PurchaseHeader, DefaultOption);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforeCopyFromProdOrderComp', '', false, false)]
    local procedure OnBeforeCopyFromProdOrderComp(var ItemJournalLine: Record "Item Journal Line"; var ProdOrderComp: Record "Prod. Order Component"; var IsHandled: Boolean)
    begin
        OnBeforeCopyFromProdOrderCompSubcontract(IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Subcontracting Post", 'OnAfterValidateUnitofMeasureCodeSubcontract', '', false, false)]
    local procedure OnAfterValidateUnitofMeasureCodeSubcontract(var ItemJournalLine: Record "Item Journal Line"; ProdOrderComponent: Record "Prod. Order Component")
    begin
        CopyFromProdOrderCompSubcontract(ItemJournalLine, ProdOrderComponent);
    end;

    local procedure OnBeforeCopyFromProdOrderCompSubcontract(var IsHandled: Boolean): Boolean
    begin
        if not GSTApplSessionMgt.GetSubcontracting() then
            exit;

        IsHandled := true;
    end;

    local procedure CopyFromProdOrderCompSubcontract(var ItemJournalLine: Record "Item Journal Line"; ProdOrderComp: Record "Prod. Order Component")
    begin
        if not GSTApplSessionMgt.GetSubcontracting() then
            exit;

        ItemJournalLine.Validate("Order Line No.", ProdOrderComp."Prod. Order Line No.");
        ItemJournalLine.Validate("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
        ItemJournalLine."Unit of Measure Code" := ProdOrderComp."Unit of Measure Code";
        ItemJournalLine."Location Code" := ProdOrderComp."Location Code";
        ItemJournalLine.Validate("Variant Code", ProdOrderComp."Variant Code");
        ItemJournalLine.Validate("Bin Code", ProdOrderComp."Bin Code");
    end;

    local procedure SetPostApplication(Vendor: Record Vendor; GenJnlLine: Record "Gen. Journal Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforeSetPostApplication(Vendor, GenJnlLine, IsHandled);
        if IsHandled then
            exit;

        if (Vendor."GST Vendor Type" = Vendor."GST Vendor Type"::" ") then
            exit;

        if (GenJnlLine."Source Type" <> GenJnlLine."Source Type"::Vendor) then
            exit;

        if GenJnlLine."Offline Application" then
            GSTApplSessionMgt.SetOnlinePostApplication(true);
    end;

    local procedure ClearPostApplication()
    begin
        if GSTApplSessionMgt.GetOnlinePostApplication() then begin
            GSTApplSessionMgt.SetOnlinePostApplication(false);
            GSTApplSessionMgt.SetOnlinePostApplicationLastEntryNo(0);
            GSTApplSessionMgt.SetOnlinePostApplicationLastEntryNoForGLRegister(0);
        end;
    end;

    local procedure BeforeUpdateGLReg(IsTransactionConsistent: Boolean; var IsGLRegInserted: Boolean; var GLReg: Record "G/L Register")
    var
        GLRegister: Record "G/L Register";
    begin
        if GSTApplSessionMgt.GetOnlinePostApplication() then
            if IsTransactionConsistent then
                if GLRegister.Get(GLReg."No.") then
                    IsGLRegInserted := true;
    end;

    local procedure InitNextEntryNo(): Integer
    var
        GLEntry: Record "G/L Entry";
        LastEntryNo: Integer;
        LastTransactionNo: Integer;
    begin
        GLEntry.LockTable();
        GLEntry.GetLastEntry(LastEntryNo, LastTransactionNo);
        exit(LastEntryNo + 1);
    end;

    local procedure InitGLRegNextEntryNo(): Integer
    var
        GLReg: Record "G/L Register";
        LastEntryNo: Integer;
    begin
        GLReg.LockTable();
        if GLReg.FindLast() then
            LastEntryNo := GLReg."No." + 1
        else
            LastEntryNo := 1;
        exit(LastEntryNo);
    end;

    local procedure CheckGSTVendorType(PurchaseHeader: Record "Purchase Header")
    var
        Vendor: Record vendor;
    begin
        if not PurchaseHeader.Subcontracting then
            exit;

        Vendor.Get(PurchaseHeader."Buy-From Vendor No.");
        GSTApplSessionMgt.SetSubcontracting(Vendor."GST Vendor Type" <> Vendor."GST Vendor Type"::" ");
    end;

    local procedure UpdateSubconPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    var
        AppliestoIDReceipt: Code[50];
    begin
        if not PurchaseHeader.Subcontracting then
            exit;

        if GSTApplSessionMgt.GetSubcontracting() then begin
            GSTApplSessionMgt.SetSubcontracting(false);

            if GSTApplSessionMgt.GetSubContractingReceivingMultiple(AppliestoIDReceipt) then begin
                PurchaseHeader.SubConPostLine := 0;
                PurchaseHeader."Subcon. Multiple Receipt" := true;
            end
        end;
    end;

    local procedure SubcontractingEntryNosAfterPostItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer; var ItemApplnEntryNo: Integer; var ValueEntryNo: Integer)
    begin
        if not GSTApplSessionMgt.GetSubcontracting() then
            exit;

        if (ItemJournalLine.Subcontracting) or ((ItemJournalLine."Lot No." <> '') and (ItemJournalLine."Subcon Order No." <> '')) then
            if (ItemLedgEntryNo <> 0) and (ItemApplnEntryNo <> 0) and (ValueEntryNo <> 0) then
                GSTApplSessionMgt.SetSubcontractingEntryNo(ItemLedgEntryNo, ItemApplnEntryNo, ValueEntryNo);
    end;

    local procedure SubcontractingEntryNosBeforePostItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer; var ValueEntryNo: Integer; var ItemApplnEntryNo: Integer)
    begin
        if not GSTApplSessionMgt.GetSubcontracting() then
            exit;

        if not ItemJournalLine.Subcontracting then
            exit;

        CheckLastEntryNoAndSet(ItemLedgEntryNo, ValueEntryNo, ItemApplnEntryNo);
    end;

    local procedure CheckLastEntryNoAndSet(var ItemLedgEntryNo: Integer;
        var ValueEntryNo: Integer;
        var ItemApplnEntryNo: Integer)
    var
        LastItemLedgEntryNo: Integer;
        LastItemApplnEntryNo: Integer;
        LastValueEntryNo: Integer;
    begin
        GSTApplSessionMgt.GetSubcontractingEntryNo(LastItemLedgEntryNo, LastItemApplnEntryNo, LastValueEntryNo);

        if (LastItemLedgEntryNo = 0) and (LastItemApplnEntryNo = 0) and (LastValueEntryNo = 0) then
            exit;

        if LastItemLedgEntryNo <> 0 then
            if ItemLedgEntryNo = 0 then
                ItemLedgEntryNo := LastItemLedgEntryNo
            else
                ItemLedgEntryNo := LastItemLedgEntryNo + 1;

        if LastItemApplnEntryNo <> 0 then
            if ItemApplnEntryNo = 0 then
                ItemApplnEntryNo := LastItemApplnEntryNo
            else
                ItemApplnEntryNo := LastItemApplnEntryNo + 1;

        if LastValueEntryNo <> 0 then
            if ValueEntryNo = 0 then
                ValueEntryNo := LastValueEntryNo
            else
                ValueEntryNo := LastValueEntryNo + 1;
    end;

    local procedure SubconOrderReceiptBeforeActionEvent(var PurchaseLine: Record "Purchase Line")
    begin
        if not PurchaseLine.Subcontracting then
            exit;

        PurchaseLine.SubConReceive := true;
        PurchaseLine."Subcon. Receiving" := true;
        PurchaseLine.Modify(true);
        GSTApplSessionMgt.SetSubContractingReceiving(true);
        GSTApplSessionMgt.SetSubcontractingEntryNo(0, 0, 0);
    end;

    local procedure SubconOrderReceiptAfterActionEvent(var PurchLine: Record "Purchase Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if not GSTApplSessionMgt.GetSubContractingReceiving() then
            exit;

        if not PurchLine.Subcontracting then
            exit;

        if not PurchaseLine.Get(PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.") then
            exit;

        if PurchaseLine."Subcon. Receiving" then begin
            PurchaseLine."Subcon. Receiving" := false;
            PurchaseLine.Modify();
            GSTApplSessionMgt.SetSubContractingReceiving(false);
            if PurchaseLine.Subcontracting then
                GSTApplSessionMgt.SetSubcontractingEntryNo(0, 0, 0);
        end
    end;

    local procedure MultipleSubconOrderReceiptBeforeActionEvent(var MultipleSubconOrderDetails: Record "Multiple Subcon. Order Details")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetCurrentKey("Document Type", "Buy-from Vendor No.", Subcontracting, "Applies-to ID (Receipt)");
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Buy-from Vendor No.", MultipleSubconOrderDetails."Subcontractor No.");
        PurchaseLine.SetRange(Subcontracting, true);
        PurchaseLine.SetRange("Applies-to ID (Receipt)", MultipleSubconOrderDetails."No.");
        if PurchaseLine.FindFirst() then begin
            GSTApplSessionMgt.SetSubContractingReceivingMultiple(true, MultipleSubconOrderDetails."No.");
            GSTApplSessionMgt.SetSubcontractingEntryNo(0, 0, 0);
            GSTApplSessionMgt.SetSubcontractingLastGLEntryNo(0);
        end
    end;

    local procedure MultipleSubconOrderReceiptAfterActionEvent(SubcontractorNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        AppliestoIDReceipt: Code[50];
    begin
        if not GSTApplSessionMgt.GetSubContractingReceivingMultiple(AppliestoIDReceipt) then
            exit;

        PurchaseHeader.SetCurrentKey("Document Type", "Buy-from Vendor No.", "Subcon. Multiple Receipt", Subcontracting);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("Buy-from Vendor No.", SubcontractorNo);
        PurchaseHeader.SetRange("Subcon. Multiple Receipt", true);
        PurchaseHeader.SetRange(Subcontracting, true);
        if PurchaseHeader.FindSet() then
            PurchaseHeader.ModifyAll("Subcon. Multiple Receipt", false);

        AppliestoIDReceipt := '';
        GSTApplSessionMgt.SetSubContractingReceivingMultiple(false, AppliestoIDReceipt);
        GSTApplSessionMgt.SetSubcontractingEntryNo(0, 0, 0);
        GSTApplSessionMgt.SetSubcontractingLastGLEntryNo(0);
    end;

    local procedure PurchPostOnCopyToTempLinesOnAfterSetFilters(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header")
    var
        AppliestoIDReceipt: Code[50];
    begin
        if GSTApplSessionMgt.GetSubContractingReceiving() then
            if PurchaseHeader.Subcontracting then
                PurchaseLine.SetRange("Subcon. Receiving", true);

        if GSTApplSessionMgt.GetSubContractingReceivingMultiple(AppliestoIDReceipt) then
            if PurchaseHeader.Subcontracting then
                PurchaseLine.SetRange("Applies-to ID (Receipt)", AppliestoIDReceipt);
    end;

    local procedure SubcontractingPurchPostBeforePostPurchLine(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        if not GSTApplSessionMgt.GetSubContractingReceiving() then
            exit;

        if (PurchHeader.Subcontracting and PurchLine.Subcontracting) then begin
            if PurchLine."Vendor Shipment No." = '' then
                IsHandled := true;

            if not PurchLine."Subcon. Receiving" then
                IsHandled := true
            else
                IsHandled := false;
        end;
    end;

    local procedure SubcontractingPurchPostYesNoBeforeConfirmPost(var PurchaseHeader: Record "Purchase Header"; var DefaultOption: Integer)
    begin
        if not PurchaseHeader.Subcontracting then
            exit;

        DefaultOption := 2;
    end;

    local procedure InitSubconMultipleRecieptNextGLEntry(var GLEntry: Record "G/L Entry")
    var
        AppliestoIDReceipt: Code[50];
        LastEntryNo: Integer;
    begin
        if not GSTApplSessionMgt.GetSubcontracting() then
            exit;

        if GSTApplSessionMgt.GetSubContractingReceivingMultiple(AppliestoIDReceipt) then begin
            LastEntryNo := GSTApplSessionMgt.GetSubcontractingLastGLEntryNo();

            if LastEntryNo <> 0 then begin
                GLEntry."Entry No." := LastEntryNo + 1;
                GSTApplSessionMgt.SetSubcontractingLastGLEntryNo(GLEntry."Entry No.");
            end
            else begin
                LastEntryNo := InitNextEntryNo();
                GLEntry."Entry No." := LastEntryNo;
                GSTApplSessionMgt.SetSubcontractingLastGLEntryNo(LastEntryNo);
            end;
        end
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyGSTApplicationCreditMemo(CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer"; OldCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer"; TransactionType: Enum "Detail Ledger Transaction Type"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetPostApplication(Vendor: Record Vendor; GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateGSTApplicationAmount(
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        var ApplicationRatio: Decimal;
        var RemainingBase: Decimal;
        var RemainingAmount: Decimal);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetHigherExcRateGSTGLAccounts(GSTPostingBuffer: Record "GST Posting Buffer"; var AccountNo: Code[20]; var BalanceAccountNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetLessExcRateGSTGLAccounts(GSTPostingBuffer: Record "GST Posting Buffer"; var AccountNo: Code[20]; var BalanceAccountNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetGLGSTPostingAccountNo(DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info"; GSTPostingBuffer: Record "GST Posting Buffer"; var AccountNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetGSTGLAccountNoForLowerExchRate(DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info"; GSTPostingBuffer: Record "GST Posting Buffer"; var AccountNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetGSTGLBalAccountNoForLowerExchRate(DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info"; GSTPostingBuffer: Record "GST Posting Buffer"; var BalanceAccountNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateGSTAppliedAmount(
        PaymentCurrencyFactor: Decimal;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        var ApplicationRatio: Decimal;
        var RemainingBase: Decimal;
        var RemainingAmount: Decimal;
        var AppliedBase: Decimal;
        var AppliedAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGSTWithNormalPaymentOnline(var GenJournalLine: Record "Gen. Journal Line"; var AmountToApply: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGSTWithNormalPaymentOffline(var GenJournalLine: Record "Gen. Journal Line"; var AmountToApply: Decimal; var IsHandled: Boolean)
    begin
    end;
}
