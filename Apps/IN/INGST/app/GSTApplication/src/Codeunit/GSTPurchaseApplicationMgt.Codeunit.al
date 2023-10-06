// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GST.Base;
using Microsoft.Purchases.Payables;

codeunit 18432 "GST Purchase Application Mgt."
{
    var
        UpdateGSTNosErr: Label 'Please Update GST Registration No. for Document No. %1 through batch first, then proceed for application.', Comment = '%1 = Document No';
        GSTInvoiceLiabilityErr: Label 'Cr. & Libty. Adjustment Type should be Liability Reverse or Blank.';
        GSTVendorTypeErr: Label 'Purchase Document document must be Reverse Charge in Document %1 and Entry No %2.', Comment = '%1 = Document No., %2 = Entry No.';
        GSTGroupCodeEqualErr: Label 'GST Group Code & GST % must be same in Advance Payment Entry No. %1 and Document Type %2, Document No %3.', Comment = '%1 = Payment Entry No., %2 = Document Type, %3 = Document No.';
        NoGSTEntryErr: Label 'There is no Detailed GST Entry Records for Advance Payment Entry %1.', Comment = '%1 = Entry No.';

    procedure GetPurchaseInvoiceAmountOffline(
        var VendorLedgerEntry: Record "Vendor Ledger Entry";
        var ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        TDSTCSAmount: Decimal)
    var
        GSTApplicationLibrary: Codeunit "GST Application Library";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        ApplyingVendorLedgerEntry.TestField("Document Type", ApplyingVendorLedgerEntry."Document Type"::Invoice);
        if not ApplyingVendorLedgerEntry."GST Reverse Charge" then
            Error(GSTVendorTypeErr, ApplyingVendorLedgerEntry."Document No.", ApplyingVendorLedgerEntry."Entry No.");

        GSTApplicationLibrary.CheckEarlierPostingDate(
            VendorLedgerEntry."Posting Date",
            ApplyingVendorLedgerEntry."Posting Date",
            VendorLedgerEntry."Document Type",
            VendorLedgerEntry."Document No.",
            ApplyingVendorLedgerEntry."Document Type",
            ApplyingVendorLedgerEntry."Vendor No.");

        ApplyingVendorLedgerEntry.CalcFields("Remaining Amount");
        ApplyingVendorLedgerEntry.TestField("Remaining Amount");
        ApplyingVendorLedgerEntry.TestField("GST Vendor Type", VendorLedgerEntry."GST Vendor Type");
        ApplyingVendorLedgerEntry.TestField("GST Reverse Charge", true);
        ApplyingVendorLedgerEntry.TestField("GST Jurisdiction Type", VendorLedgerEntry."GST Jurisdiction Type");
        ApplyingVendorLedgerEntry.TestField("Location State Code", VendorLedgerEntry."Location State Code");
        ApplyingVendorLedgerEntry.TestField("Location GST Reg. No.", VendorLedgerEntry."Location GST Reg. No.");
        ApplyingVendorLedgerEntry.TestField("Location ARN No.", VendorLedgerEntry."Location ARN No.");
        ApplyingVendorLedgerEntry.TestField("Buyer GST Reg. No.", VendorLedgerEntry."Buyer GST Reg. No.");
        ApplyingVendorLedgerEntry.TestField("Currency Code", VendorLedgerEntry."Currency Code");
        ApplyingVendorLedgerEntry.TestField("Buyer State Code", VendorLedgerEntry."Buyer State Code");

        GSTApplicationLibrary.FillAppBufferInvoiceOffline(
            GenJournalLine,
            TransactionType::Purchase,
            ApplyingVendorLedgerEntry."Document No.",
            ApplyingVendorLedgerEntry."Vendor No.",
            VendorLedgerEntry."Document No.",
            TDSTCSAmount,
            VendorLedgerEntry."Original Currency Factor");

        FillPurchaseAppBufferPaymentOfflline(VendorLedgerEntry, ApplyingVendorLedgerEntry, GenJournalLine);
    end;

    procedure GetPurchaseInvoiceAmountWithPaymentOffline(
        var VendorLedgerEntry: Record "Vendor Ledger Entry";
        var ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        TDSTCSAmount: Decimal)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTApplicationLibrary: Codeunit "GST Application Library";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        VendorLedgerEntry.TestField("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        if not VendorLedgerEntry."GST Reverse Charge" then
            Error(GSTVendorTypeErr, VendorLedgerEntry."Document No.", VendorLedgerEntry."Entry No.");

        GSTApplicationLibrary.CheckEarlierPostingDate(
            ApplyingVendorLedgerEntry."Posting Date",
            VendorLedgerEntry."Posting Date",
            ApplyingVendorLedgerEntry."Document Type",
            ApplyingVendorLedgerEntry."Document No.",
            VendorLedgerEntry."Document Type",
            VendorLedgerEntry."Vendor No.");

        VendorLedgerEntry.TestField("GST Reverse Charge", true);
        VendorLedgerEntry.TestField("GST Vendor Type", ApplyingVendorLedgerEntry."GST Vendor Type");
        VendorLedgerEntry.TestField("GST Jurisdiction Type", ApplyingVendorLedgerEntry."GST Jurisdiction Type");
        VendorLedgerEntry.TestField("Location State Code", ApplyingVendorLedgerEntry."Location State Code");
        VendorLedgerEntry.TestField("Location GST Reg. No.", ApplyingVendorLedgerEntry."Location GST Reg. No.");
        if VendorLedgerEntry."Buyer GST Reg. No." <> ApplyingVendorLedgerEntry."Buyer GST Reg. No." then begin
            DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
            DetailedGSTLedgerEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
            if DetailedGSTLedgerEntry.FindFirst() then
                if (DetailedGSTLedgerEntry."Buyer/Seller Reg. No." = '') and (DetailedGSTLedgerEntry."ARN No." <> '') then
                    Error(UpdateGSTNosErr, VendorLedgerEntry."Document No.");

            VendorLedgerEntry.TestField("Buyer GST Reg. No.", ApplyingVendorLedgerEntry."Buyer GST Reg. No.");
        end;

        VendorLedgerEntry.TestField("Currency Code", ApplyingVendorLedgerEntry."Currency Code");
        VendorLedgerEntry.TestField("Buyer State Code", ApplyingVendorLedgerEntry."Buyer State Code");

        GSTApplicationLibrary.FillAppBufferInvoiceOffline(
            GenJournalLine,
            TransactionType::Purchase,
            VendorLedgerEntry."Document No.",
            VendorLedgerEntry."Vendor No.",
            ApplyingVendorLedgerEntry."Document No.",
            TDSTCSAmount,
            ApplyingVendorLedgerEntry."Original Currency Factor");

        FillPurchaseAppBufferPaymentOfflline(ApplyingVendorLedgerEntry, VendorLedgerEntry, GenJournalLine);
    end;

    local procedure FillPurchaseAppBufferPaymentOfflline(
        var VendorLedgerEntry: Record "Vendor Ledger Entry";
        var ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line")
    var
        DetailedGSTLedgerEntryInv: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryPmt: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTApplicationLibrary: Codeunit "GST Application Library";
        GSTDocumentType: Enum "GST Document Type";
        OriginalDocumentType: Enum "Original Doc Type";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        GSTApplicationLibrary.DeletePaymentAplicationBuffer(TransactionType::Purchase, VendorLedgerEntry."Entry No.");
        DetailedGSTLedgerEntryPmt.SetCurrentKey("Transaction Type", "Source No.", "Document Type", "Document No.", "GST Group Code");
        DetailedGSTLedgerEntryPmt.SetRange("Transaction Type", DetailedGSTLedgerEntryPmt."Transaction Type"::Purchase);
        DetailedGSTLedgerEntryPmt.SetRange("Source No.", VendorLedgerEntry."Vendor No.");
        DetailedGSTLedgerEntryPmt.SetRange("Document Type", DetailedGSTLedgerEntryPmt."Document Type"::Payment);
        DetailedGSTLedgerEntryPmt.SetRange("Document No.", VendorLedgerEntry."Document No.");
        DetailedGSTLedgerEntryPmt.SetRange("GST Group Code", VendorLedgerEntry."GST Group Code");
        if not DetailedGSTLedgerEntryPmt.FindFirst() then
            Error(NoGSTEntryErr, VendorLedgerEntry."Entry No.");

        GSTApplicationLibrary.GetGSTDocumentTypeFromGenJournalDocumentType(GSTDocumentType, ApplyingVendorLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntryInv.SetCurrentKey("Transaction Type", "Source No.", "Document Type", "Document No.", "GST Group Code");
        DetailedGSTLedgerEntryInv.SetRange("Transaction Type", DetailedGSTLedgerEntryInv."Transaction Type"::Purchase);
        DetailedGSTLedgerEntryInv.SetRange("Source No.", ApplyingVendorLedgerEntry."Vendor No.");
        DetailedGSTLedgerEntryInv.SetRange("Document Type", GSTDocumentType);
        if GenJournalLine."Purch. Invoice Type" = GenJournalLine."Purch. Invoice Type"::" " then
            DetailedGSTLedgerEntryInv.SetRange("Document No.", ApplyingVendorLedgerEntry."Document No.")
        else
            DetailedGSTLedgerEntryInv.SetRange("Document No.", GenJournalLine."Old Document No.");

        DetailedGSTLedgerEntryInv.SetRange("GST Group Code", VendorLedgerEntry."GST Group Code");
        if DetailedGSTLedgerEntryInv.FindFirst() then begin
            if ((DetailedGSTLedgerEntryPmt."GST Vendor Type" = DetailedGSTLedgerEntryPmt."GST Vendor Type"::Registered) or
               (DetailedGSTLedgerEntryPmt."GST Customer Type" = DetailedGSTLedgerEntryPmt."GST Customer Type"::Registered)) and
               (DetailedGSTLedgerEntryPmt."Buyer/Seller Reg. No." = '') and
               (DetailedGSTLedgerEntryPmt."ARN No." <> '')
            then
                Error(UpdateGSTNosErr, DetailedGSTLedgerEntryPmt."Document No.");

            DetailedGSTLedgerEntryInv.TestField("Location  Reg. No.", DetailedGSTLedgerEntryPmt."Location  Reg. No.");
            DetailedGSTLedgerEntryInv.TestField("Currency Code", DetailedGSTLedgerEntryPmt."Currency Code");
            DetailedGSTLedgerEntryInv.TestField("GST Rounding Precision", DetailedGSTLedgerEntryPmt."GST Rounding Precision");
            DetailedGSTLedgerEntryInv.TestField("GST Rounding Type", DetailedGSTLedgerEntryPmt."GST Rounding Type");
            DetailedGSTLedgerEntryInv.TestField("GST Group Type", DetailedGSTLedgerEntryPmt."GST Group Type");
            DetailedGSTLedgerEntryInv.TestField("GST Vendor Type", DetailedGSTLedgerEntryPmt."GST Vendor Type");
            DetailedGSTLedgerEntryInv.TestField("GST Jurisdiction Type", DetailedGSTLedgerEntryPmt."GST Jurisdiction Type");
            DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntryInv."Entry No.");
            if not DetailedGSTLedgerEntryInv."GST Exempted Goods" and not DetailedGSTLedgerEntryInfo."RCM Exempt" then
                DetailedGSTLedgerEntryInv.TestField("GST %", DetailedGSTLedgerEntryPmt."GST %");

            DetailedGSTLedgerEntryInv.TestField("Reverse Charge", DetailedGSTLedgerEntryPmt."Reverse Charge");
            if DetailedGSTLedgerEntryInv."Cr. & Liab. Adjustment Type" = DetailedGSTLedgerEntryInv."Cr. & Liab. Adjustment Type"::Generate then
                Error(GSTInvoiceLiabilityErr);
        end else
            Error(GSTGroupCodeEqualErr, VendorLedgerEntry."Entry No.", Format(ApplyingVendorLedgerEntry."Document Type"), ApplyingVendorLedgerEntry."Document No.");

        GSTApplicationLibrary.GetGSTDocumentTypeFromGenJournalDocumentType(GSTDocumentType, VendorLedgerEntry."Document Type"::Payment);
        DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Source No.", "GST Group Code");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Purchase);
        DetailedGSTLedgerEntry.SetRange("Source No.", VendorLedgerEntry."Vendor No.");
        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType); // Payment
        DetailedGSTLedgerEntry.SetRange("Document No.", VendorLedgerEntry."Document No.");
        DetailedGSTLedgerEntry.SetRange("GST Group Code", VendorLedgerEntry."GST Group Code");
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                GSTApplicationLibrary.FillGSTAppBufferHSNComponentPayment(
                    DetailedGSTLedgerEntry,
                    GSTApplicationLibrary.OriginalDocumentType2CurrentDocumentTypeEnum(OriginalDocumentType::Invoice), ApplyingVendorLedgerEntry."Document No.",
                    VendorLedgerEntry."Vendor No.",
                    GSTApplicationLibrary.OriginalDocumentType2CurrentDocumentTypeEnum(OriginalDocumentType::Invoice), '', VendorLedgerEntry."Amount to Apply");
            until DetailedGSTLedgerEntry.Next() = 0
        else
            Error(NoGSTEntryErr, VendorLedgerEntry."Entry No.");
    end;
}
