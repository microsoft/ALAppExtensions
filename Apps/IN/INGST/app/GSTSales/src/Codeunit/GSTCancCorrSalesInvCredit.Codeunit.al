// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Utilities;

codeunit 18152 "GST Canc Corr Sales Inv Credit"
{
    var
        PostedInvoiceIsPaidCancelErr: Label 'You cannot cancel this posted sales invoice because it is fully or partially paid.\\To reverse a paid sales invoice, you must manually create a sales credit memo.';
        CorrectCancellSalesInvoiceErr: Label 'You cannot cancel this posted Sales invoice because GST Customer Type is Export.\\You must manually create a Sales credit memo.';
        CorrectCancellSalesCrMemoErr: Label 'You cannot cancel this posted Sales Cr. Memo because GST Customer Type is Export.\\You must manually create a Sales Invoice.';
        UnappliedErr: Label 'You cannot cancel this posted sales credit memo because it is fully or partially applied.\\To reverse an applied sales credit memo, you must manually unapply all applied entries.';


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", 'OnBeforeTestIfInvoiceIsPaid', '', false, false)]
    local procedure OnBeforeTestGSTPurchaseInvoiceIsPaid(var SalesInvoiceHeader: Record "Sales Invoice Header"; var IsHandled: Boolean)
    begin
        TestGSTTDSTCSSalesInvoiceIsPaid(SalesInvoiceHeader, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cancel Posted Sales Cr. Memo", 'OnBeforeTestIfUnapplied', '', false, false)]
    local procedure OnBeforeOnBeforeTestIfUnapplied(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var IsHandled: Boolean)
    begin
        TestGSTTDSTCSSalesCrMemoUnapplied(SalesCrMemoHeader, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesDocument', '', false, false)]
    local procedure CalculateTaxOnPurchaseLine(var ToSalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", ToSalesHeader."Document Type");
        SalesLine.SetRange("Document No.", ToSalesHeader."No.");
        SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
        if SalesLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);
            until SalesLine.Next() = 0;
    end;

    local procedure TestGSTTDSTCSSalesInvoiceIsPaid(var SalesInvoiceHeader: Record "Sales Invoice Header"; var IsHandled: Boolean)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        TaxTransactionValue: Decimal;
    begin
        if SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::" " then
            exit;

        if SalesInvoiceHeader."GST Customer Type" in [SalesInvoiceHeader."GST Customer Type"::Export] then
            Error(CorrectCancellSalesInvoiceErr);

        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
        if SalesInvoiceLine.FindSet() then
            repeat
                TaxTransactionValue += FilterTaxTransactionValue(SalesInvoiceLine.RecordId);
            until SalesInvoiceLine.Next() = 0;

        IsHandled := true;
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        SalesInvoiceHeader.CalcFields("Remaining Amount");
        if (SalesInvoiceHeader."Amount Including VAT" + TaxTransactionValue) <> SalesInvoiceHeader."Remaining Amount" then
            Error(PostedInvoiceIsPaidCancelErr);
    end;

    local procedure TestGSTTDSTCSSalesCrMemoUnapplied(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var IsHandled: Boolean)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        TaxTransactionValue: Decimal;
    begin
        if SalesCrMemoHeader."GST Customer Type" = SalesCrMemoHeader."GST Customer Type"::" " then
            exit;

        if SalesCrMemoHeader."GST Customer Type" in [SalesCrMemoHeader."GST Customer Type"::Export] then
            Error(CorrectCancellSalesCrMemoErr);

        SalesCrMemoLine.Reset();
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Type, '<>%1', SalesCrMemoLine.Type::" ");
        if SalesCrMemoLine.FindSet() then
            repeat
                TaxTransactionValue += FilterTaxTransactionValue(SalesCrMemoLine.RecordId);
            until SalesCrMemoLine.Next() = 0;

        IsHandled := true;
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        SalesCrMemoHeader.CalcFields("Remaining Amount");
        if (SalesCrMemoHeader."Amount Including VAT" + TaxTransactionValue) <> -SalesCrMemoHeader."Remaining Amount" then
            Error(UnappliedErr);
    end;

    local procedure FilterTaxTransactionValue(RecordId: RecordId): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.SetRange("Tax Record ID", RecordId);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        TaxTransactionValue.CalcSums(TaxTransactionValue.Amount);
        exit(TaxTransactionValue.Amount);
    end;
}
