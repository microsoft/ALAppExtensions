// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.PostingHandler;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Sales.Document;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Posting;

codeunit 20339 "Service Posting Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforePostWithLines', '', false, false)]
    local procedure OnBeforePostServiceDoc(var PassedServHeader: Record "Service Header")
    var
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        TaxPostingBufferMgmt.ClearPostingInstance();
        TaxPostingBufferMgmt.SetDocument(PassedServHeader);
        TaxPostingBufferMgmt.CreateTaxID();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnAfterServCrMemoLineInsert', '', false, false)]
    procedure OnAfterServiceCrMemoLineInsert(ServiceLine: Record "Service Line"; var ServiceCrMemoLine: Record "Service Cr.Memo Line")
    var
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        ServiceHeader: Record "Service Header";
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        // Prepares Transaction value based on Quantity and and Qty to Invoice
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");

        TaxDocumentGLPosting.PrepareTransactionValueToPost(
            ServiceLine.RecordId(),
            ServiceLine.Quantity,
            ServiceCrMemoLine.Quantity,
            ServiceHeader."Currency Code",
            ServiceHeader."Currency Factor",
            TempTaxTransactionValue);

        // Updates Posting Buffers in Tax Posting Buffer Mgmt. Codeunit
        // Creates tax ledger if the configuration is set for Line / Component on Use Case
        TaxDocumentGLPosting.UpdateTaxPostingBuffer(
            TempTaxTransactionValue,
            ServiceLine.RecordId(),
            TaxPostingBufferMgmt.GetTaxID(),
            ServiceLine."Dimension Set ID",
            ServiceLine."Gen. Bus. Posting Group",
            ServiceLine."Gen. Prod. Posting Group",
            ServiceLine.Quantity,
            ServiceLine."Qty. to Invoice",
            ServiceHeader."Currency Code",
            ServiceHeader."Currency Factor",
            ServiceCrMemoLine."Document No.",
            ServiceCrMemoLine."Line No.");

        //Copies transaction value from upposted document to posted record ID
        TaxDocumentGLPosting.TransferTransactionValue(
            ServiceLine.RecordId(),
            ServiceCrMemoLine.RecordId(),
            TempTaxTransactionValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnAfterServInvLineInsert', '', false, false)]
    procedure OnAfterServiceInvoiceLineInsert(ServiceLine: Record "Service Line"; var ServiceInvoiceLine: Record "Service Invoice Line")
    var
        TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        ServiceHeader: Record "Service Header";
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        // Prepares Transaction value based on Quantity and and Qty to Invoice
        TaxDocumentGLPosting.PrepareTransactionValueToPost(
            ServiceLine.RecordId(),
            ServiceLine.Quantity,
            ServiceInvoiceLine.Quantity,
            ServiceHeader."Currency Code",
            ServiceHeader."Currency Factor",
            TempTaxTransactionValue);

        // Updates Posting Buffers in Tax Posting Buffer Mgmt. Codeunit
        // Creates tax ledger if the configuration is set for Line / Component on Use Case
        TaxDocumentGLPosting.UpdateTaxPostingBuffer(
            TempTaxTransactionValue,
            ServiceLine.RecordId(),
            TaxPostingBufferMgmt.GetTaxID(),
            ServiceLine."Dimension Set ID",
            ServiceLine."Gen. Bus. Posting Group",
            ServiceLine."Gen. Prod. Posting Group",
            ServiceLine.Quantity,
            ServiceLine."Qty. to Invoice",
            ServiceHeader."Currency Code",
            ServiceHeader."Currency Factor",
            ServiceInvoiceLine."Document No.",
            ServiceInvoiceLine."Line No.");

        //Copies transaction value from upposted document to posted record ID
        TaxDocumentGLPosting.TransferTransactionValue(
            ServiceLine.RecordId(),
            ServiceInvoiceLine.RecordId(),
            TempTaxTransactionValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Amounts Mgt.", 'OnBeforeInvoiceRoundingAmount', '', false, false)]
    local procedure OnBeforeInvoiceRoundingAmount(var ServiceHeader: Record "Service Header"; var AmountIncludingVAT: Decimal; var InvoiceRoundingAmount: Decimal)
    var
        Currency: Record Currency;
        TaxPostingHandler: Codeunit "Tax Posting Handler";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
        TotalAmount: Decimal;
    begin
        TaxPostingHandler.GetCurrency(ServiceHeader."Currency Code", Currency);
        Currency.TestField("Invoice Rounding Precision");
        if ServiceHeader."Document Type" in ["Sales Document Type"::"Credit Memo", "Sales Document Type"::"Return Order"] then
            TotalAmount := AmountIncludingVAT + TaxPostingBufferMgmt.GetTotalTaxAmount()
        else
            TotalAmount := AmountIncludingVAT - TaxPostingBufferMgmt.GetTotalTaxAmount();

        InvoiceRoundingAmount :=
          -Round(
            TotalAmount -
            Round(
              TotalAmount, Currency."Invoice Rounding Precision", Currency.InvoiceRoundingDirection()),
            Currency."Amount Rounding Precision");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Post Invoice Events", 'OnPostLedgerEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnPostLedgerEntryOnBeforeGenJnlPostLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        GenJournalLine."Tax ID" := TaxPostingBufferMgmt.GetTaxID();
    end;
}
