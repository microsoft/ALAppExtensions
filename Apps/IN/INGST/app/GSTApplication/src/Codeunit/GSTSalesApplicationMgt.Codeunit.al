// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GST.Base;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

codeunit 18431 "GST Sales Application Mgt."
{
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTCustomerTypeErr: Label 'Customer Type must not be Blank or Exempted in Document %1 and Entry No %2.', Comment = '%1 = Document No., %2 = Entry No.';
        GSTGroupCodeEqualErr: Label 'GST Group Code & GST % must be same in Advance Payment Entry No. %1 and Document Type %2, Document No %3.', Comment = '%1 = Payment Entry No., %2 = Document Type, %3 = Document No.';
        NoGSTEntryErr: Label 'There is no Detailed GST Entry Records for Advance Payment Entry %1.', Comment = '%1 = Entry No.';

    procedure GetSalesInvoiceAmountOffline(
        var CustLedgerEntry: Record "Cust. Ledger Entry";
        var ApplyingCustLedgEntry: Record "Cust. Ledger Entry";
        TDSTCSAmount: Decimal)
    var
        GSTApplicationLibrary: Codeunit "GST Application Library";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        ApplyingCustLedgEntry.TestField("Document Type", ApplyingCustLedgEntry."Document Type"::Invoice);
        if ApplyingCustLedgEntry."GST Customer Type" in [
            ApplyingCustLedgEntry."GST Customer Type"::" ",
            ApplyingCustLedgEntry."GST Customer Type"::Exempted]
        then
            Error(GSTCustomerTypeErr, ApplyingCustLedgEntry."Document No.", ApplyingCustLedgEntry."Entry No.");

        GSTApplicationLibrary.CheckEarlierPostingDate(
            CustLedgerEntry."Posting Date",
            ApplyingCustLedgEntry."Posting Date",
            CustLedgerEntry."Document Type",
            CustLedgerEntry."Document No.",
            ApplyingCustLedgEntry."Document Type",
            ApplyingCustLedgEntry."Customer No.");

        ApplyingCustLedgEntry.CalcFields("Remaining Amount");
        ApplyingCustLedgEntry.TestField("Remaining Amount");
        ApplyingCustLedgEntry.TestField("GST Customer Type", CustLedgerEntry."GST Customer Type");
        ApplyingCustLedgEntry.TestField("GST Jurisdiction Type", CustLedgerEntry."GST Jurisdiction Type");
        ApplyingCustLedgEntry.TestField("Location State Code", CustLedgerEntry."Location State Code");
        ApplyingCustLedgEntry.TestField("Location GST Reg. No.", CustLedgerEntry."Location GST Reg. No.");
        ApplyingCustLedgEntry.TestField("Location ARN No.", CustLedgerEntry."Location ARN No.");
        ApplyingCustLedgEntry.TestField("Seller GST Reg. No.", CustLedgerEntry."Seller GST Reg. No.");
        ApplyingCustLedgEntry.TestField("Currency Code", CustLedgerEntry."Currency Code");
        ApplyingCustLedgEntry.TestField("Seller State Code", CustLedgerEntry."Seller State Code");

        GSTApplicationLibrary.FillAppBufferInvoiceOffline(
            GenJournalLine,
            TransactionType::Sales,
            ApplyingCustLedgEntry."Document No.",
            ApplyingCustLedgEntry."Customer No.",
            CustLedgerEntry."Document No.",
            TDSTCSAmount,
            0);

        FillSalesAppBufferPaymentOfflline(CustLedgerEntry, ApplyingCustLedgEntry);
    end;

    procedure GetSalesInvoiceAmountWithPaymentOffline(
        var CustLedgerEntry: Record "Cust. Ledger Entry";
        var ApplyingCustLedgerEntry: Record "Cust. Ledger Entry";
        TDSTCSAmount: Decimal)
    var
        Cust: Record Customer;
        GSTApplicationLibrary: Codeunit "GST Application Library";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        Cust.Get(CustLedgerEntry."Customer No.");
        CustLedgerEntry.TestField("Document Type", CustLedgerEntry."Document Type"::Invoice);
        if CustLedgerEntry."GST Customer Type" in [CustLedgerEntry."GST Customer Type"::" ", CustLedgerEntry."GST Customer Type"::Exempted] then
            Error(GSTCustomerTypeErr, CustLedgerEntry."Document No.", CustLedgerEntry."Entry No.");

        GSTApplicationLibrary.CheckEarlierPostingDate(
            ApplyingCustLedgerEntry."Posting Date",
            CustLedgerEntry."Posting Date",
            ApplyingCustLedgerEntry."Document Type",
            ApplyingCustLedgerEntry."Document No.",
            CustLedgerEntry."Document Type",
            CustLedgerEntry."Customer No.");

        CheckCustLedgerEntry(CustLedgerEntry, ApplyingCustLedgerEntry);

        GSTApplicationLibrary.FillAppBufferInvoiceOffline(
            GenJournalLine,
            TransactionType::Sales,
            CustLedgerEntry."Document No.",
            CustLedgerEntry."Customer No.",
            ApplyingCustLedgerEntry."Document No.",
            TDSTCSAmount,
            0);

        FillSalesAppBufferPaymentOfflline(ApplyingCustLedgerEntry, CustLedgerEntry);
    end;

    local procedure CheckCustLedgerEntry(
        var CustLedgerEntry: Record "Cust. Ledger Entry";
        var ApplyingCustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry.TestField("GST Customer Type", ApplyingCustLedgerEntry."GST Customer Type");
        CustLedgerEntry.TestField("GST Jurisdiction Type", ApplyingCustLedgerEntry."GST Jurisdiction Type");
        CustLedgerEntry.TestField("Location State Code", ApplyingCustLedgerEntry."Location State Code");
        CustLedgerEntry.TestField("Location GST Reg. No.", ApplyingCustLedgerEntry."Location GST Reg. No.");
        CustLedgerEntry.TestField("Seller GST Reg. No.", ApplyingCustLedgerEntry."Seller GST Reg. No.");
        CustLedgerEntry.TestField("Currency Code", ApplyingCustLedgerEntry."Currency Code");
        CustLedgerEntry.TestField("Seller State Code", ApplyingCustLedgerEntry."Seller State Code");
    end;

    local procedure FillSalesAppBufferPaymentOfflline(
        var CustLedgerEntry: Record "Cust. Ledger Entry";
        var ApplyingCustLedgerEntry: Record "Cust. Ledger Entry")
    var
        DetailedGSTLedgerEntryInv: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryPmt: Record "Detailed GST Ledger Entry";
        GSTApplicationLibrary: Codeunit "GST Application Library";
        OriginalDocumentType: Enum "Original Doc Type";
        GSTDocumentType: Enum "GST Document Type";
        TransactionType: Enum "Detail Ledger Transaction Type";
    begin
        GSTApplicationLibrary.DeletePaymentAplicationBuffer(TransactionType::Sales, CustLedgerEntry."Entry No.");

        DetailedGSTLedgerEntryPmt.SetCurrentKey("Transaction Type", "Source No.", "Document Type", "Document No.", "GST Group Code");
        DetailedGSTLedgerEntryPmt.SetRange("Transaction Type", TransactionType::Sales);
        DetailedGSTLedgerEntryPmt.SetRange("Source No.", CustLedgerEntry."Customer No.");
        DetailedGSTLedgerEntryPmt.SetRange("Document Type", DetailedGSTLedgerEntryPmt."Document Type"::Payment);
        DetailedGSTLedgerEntryPmt.SetRange("Document No.", CustLedgerEntry."Document No.");
        DetailedGSTLedgerEntryPmt.SetRange("GST Group Code", CustLedgerEntry."GST Group Code");
        if not DetailedGSTLedgerEntryPmt.FindFirst() then
            Error(NoGSTEntryErr, CustLedgerEntry."Entry No.");

        GSTApplicationLibrary.GetGSTDocumentTypeFromGenJournalDocumentType(GSTDocumentType, ApplyingCustLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntryInv.SetCurrentKey("Transaction Type", "Source No.", "Document Type", "Document No.", "GST Group Code");
        DetailedGSTLedgerEntryInv.SetRange("Transaction Type", DetailedGSTLedgerEntryInv."Transaction Type"::Sales);
        DetailedGSTLedgerEntryInv.SetRange("Source No.", ApplyingCustLedgerEntry."Customer No.");
        DetailedGSTLedgerEntryInv.SetRange("Document Type", GSTDocumentType);
        DetailedGSTLedgerEntryInv.SetRange("Document No.", ApplyingCustLedgerEntry."Document No.");
        DetailedGSTLedgerEntryInv.SetRange("GST Group Code", CustLedgerEntry."GST Group Code");
        if DetailedGSTLedgerEntryInv.FindFirst() then begin
            DetailedGSTLedgerEntryInv.TestField("Location  Reg. No.", DetailedGSTLedgerEntryPmt."Location  Reg. No.");
            DetailedGSTLedgerEntryInv.TestField("Currency Code", DetailedGSTLedgerEntryPmt."Currency Code");
            DetailedGSTLedgerEntryInv.TestField("GST Rounding Precision", DetailedGSTLedgerEntryPmt."GST Rounding Precision");
            DetailedGSTLedgerEntryInv.TestField("GST Rounding Type", DetailedGSTLedgerEntryPmt."GST Rounding Type");
            DetailedGSTLedgerEntryInv.TestField("GST Group Type", DetailedGSTLedgerEntryPmt."GST Group Type");
            DetailedGSTLedgerEntryInv.TestField("GST Customer Type", DetailedGSTLedgerEntryPmt."GST Customer Type");
            DetailedGSTLedgerEntryInv.TestField("GST Jurisdiction Type", DetailedGSTLedgerEntryPmt."GST Jurisdiction Type");
            if not DetailedGSTLedgerEntryInv."GST Exempted Goods" then
                DetailedGSTLedgerEntryInv.TestField("GST %", DetailedGSTLedgerEntryPmt."GST %");
        end else
            Error(GSTGroupCodeEqualErr, CustLedgerEntry."Entry No.", Format(ApplyingCustLedgerEntry."Document Type"), ApplyingCustLedgerEntry."Document No.");

        GSTApplicationLibrary.GetGSTDocumentTypeFromGenJournalDocumentType(GSTDocumentType, CustLedgerEntry."Document Type"::Payment);
        DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Source No.", "GST Group Code");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
        DetailedGSTLedgerEntry.SetRange("Source No.", CustLedgerEntry."Customer No.");
        DetailedGSTLedgerEntry.SetRange("Document Type", GSTDocumentType); // Payment
        DetailedGSTLedgerEntry.SetRange("Document No.", CustLedgerEntry."Document No.");
        DetailedGSTLedgerEntry.SetRange("GST Group Code", CustLedgerEntry."GST Group Code");
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                GSTApplicationLibrary.FillGSTAppBufferHSNComponentPayment(
                    DetailedGSTLedgerEntry,
                    GSTApplicationLibrary.OriginalDocumentType2CurrentDocumentTypeEnum(OriginalDocumentType::Invoice), ApplyingCustLedgerEntry."Document No.",
                    CustLedgerEntry."Customer No.",
                    GSTApplicationLibrary.OriginalDocumentType2CurrentDocumentTypeEnum(OriginalDocumentType::Invoice), '', 0);
            until DetailedGSTLedgerEntry.Next() = 0
        else
            Error(NoGSTEntryErr, CustLedgerEntry."Entry No.");
    end;
}
