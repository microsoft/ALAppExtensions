// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.PostingHandler;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

codeunit 20336 "Sales Posting Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        TaxPostingBufferMgmt.ClearPostingInstance();
        TaxPostingBufferMgmt.SetDocument(SalesHeader);
        TaxPostingBufferMgmt.CreateTaxID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoLineInsert', '', false, false)]
    procedure OnAfterSalesCrMemoLineInsert(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesLine: Record "Sales Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        // Prepares Transaction value based on Quantity and and Qty to Invoice
        TaxDocumentGLPosting.PrepareTransactionValueToPost(
            SalesLine.RecordId(),
            SalesLine.Quantity,
            SalesCrMemoLine.Quantity,
            SalesCrMemoHeader."Currency Code",
            SalesCrMemoHeader."Currency Factor",
            TempTaxTransactionValue);

        // Updates Posting Buffers in Tax Posting Buffer Mgmt. Codeunit
        // Creates tax ledger if the configuration is set for Line / Component on Use Case
        TaxDocumentGLPosting.UpdateTaxPostingBuffer(
            TempTaxTransactionValue,
            SalesLine.RecordId(),
            TaxPostingBufferMgmt.GetTaxID(),
            SalesLine."Dimension Set ID",
            SalesLine."Gen. Bus. Posting Group",
            SalesLine."Gen. Prod. Posting Group",
            SalesLine.Quantity,
            SalesLine."Qty. to Invoice",
            SalesCrMemoHeader."Currency Code",
            SalesCrMemoHeader."Currency Factor",
            SalesCrMemoLine."Document No.",
            SalesCrMemoLine."Line No.");

        //Copies transaction value from upposted document to posted record ID
        TaxDocumentGLPosting.TransferTransactionValue(
            SalesLine.RecordId(),
            SalesCrMemoLine.RecordId(),
            TempTaxTransactionValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvLineInsert', '', false, false)]
    procedure OnAfterSalesInvLineInsert(SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; var SalesInvLine: Record "Sales Invoice Line")
    var
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        // Prepares Transaction value based on Quantity and and Qty to Invoice
        TaxDocumentGLPosting.PrepareTransactionValueToPost(
            SalesLine.RecordId(),
            SalesLine.Quantity,
            SalesInvLine.Quantity,
            SalesInvHeader."Currency Code",
            SalesInvHeader."Currency Factor",
            TempTaxTransactionValue);

        // Updates Posting Buffers in Tax Posting Buffer Mgmt. Codeunit
        // Creates tax ledger if the configuration is set for Line / Component on Use Case
        TaxDocumentGLPosting.UpdateTaxPostingBuffer(
            TempTaxTransactionValue,
            SalesLine.RecordId(),
            TaxPostingBufferMgmt.GetTaxID(),
            SalesLine."Dimension Set ID",
            SalesLine."Gen. Bus. Posting Group",
            SalesLine."Gen. Prod. Posting Group",
            SalesLine.Quantity,
            SalesLine."Qty. to Invoice",
            SalesInvHeader."Currency Code",
            SalesInvHeader."Currency Factor",
            SalesInvLine."Document No.",
            SalesInvLine."Line No.");

        //Copies transaction value from upposted document to posted record ID
        TaxDocumentGLPosting.TransferTransactionValue(
            SalesLine.RecordId(),
            SalesInvLine.RecordId(),
            TempTaxTransactionValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeInvoiceRoundingAmount', '', false, false)]
    local procedure OnBeforeInvoiceRoundingAmount(SalesHeader: Record "Sales Header"; TotalAmountIncludingVAT: Decimal; var InvoiceRoundingAmount: Decimal)
    var
        Currency: Record Currency;
        TaxPostingHandler: Codeunit "Tax Posting Handler";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
        TotalAmount: Decimal;
    begin
        TaxPostingHandler.GetCurrency(SalesHeader."Currency Code", Currency);
        Currency.TestField("Invoice Rounding Precision");
        if SalesHeader."Document Type" in ["Sales Document Type"::"Credit Memo", "Sales Document Type"::"Return Order"] then
            TotalAmount := TotalAmountIncludingVAT + TaxPostingBufferMgmt.GetTotalTaxAmount()
        else
            TotalAmount := TotalAmountIncludingVAT - TaxPostingBufferMgmt.GetTotalTaxAmount();

        InvoiceRoundingAmount :=
            -Round(
                TotalAmount -
                Round(
                    TotalAmount, Currency."Invoice Rounding Precision", Currency.InvoiceRoundingDirection()),
                    Currency."Amount Rounding Precision");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostLedgerEntryOnBeforeGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header")
    var
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        GenJnlLine."Tax ID" := TaxPostingBufferMgmt.GetTaxID();
    end;
}
