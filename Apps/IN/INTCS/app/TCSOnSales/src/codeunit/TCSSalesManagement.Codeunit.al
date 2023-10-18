// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSOnSales;

using Microsoft.Sales.Document;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Sales.History;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

codeunit 18841 "TCS Sales Management"
{
    Access = Internal;
    procedure UpdateTaxAmount(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then begin
            SalesHeader.Modify();
            repeat
                CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);
            until SalesLine.Next() = 0;
        end;
    end;

    procedure UpdateTaxAmountOnSalesLine(SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        UpdateTaxAmount(SalesHeader);
    end;

    procedure GetStatisticsAmount(
        SalesHeader: Record "Sales Header";
        var TCSAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
        TCSManagement: Codeunit "TCS Management";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(TCSAmount);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document no.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                RecordIDList.Add(SalesLine.RecordId());
            until SalesLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            TCSAmount += GetTCSAmount(RecordIDList.Get(i));

        TCSAmount := TCSManagement.RoundTCSAmount(TCSAmount);
    end;

    procedure GetStatisticsAmountPostedInvoice(
        SalesInvoiceHeader: Record "Sales Invoice Header";
        var TCSAmount: Decimal)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        TCSManagement: Codeunit "TCS Management";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(TCSAmount);

        SalesInvoiceLine.SetRange("Document no.", SalesInvoiceHeader."No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                RecordIDList.Add(SalesInvoiceLine.RecordId());
            until SalesInvoiceLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            TCSAmount += GetTCSAmount(RecordIDList.Get(i));

        TCSAmount := TCSManagement.RoundTCSAmount(TCSAmount);
    end;

    procedure GetStatisticsAmountPostedCreditMemo(
            SalesCrMemoHeader: Record "Sales Cr.Memo Header";
            var TCSAmount: Decimal)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        TCSManagement: Codeunit "TCS Management";
        i: Integer;
        RecordIDList: List of [RecordID];
    begin
        Clear(TCSAmount);

        SalesCrMemoLine.SetRange("Document no.", SalesCrMemoHeader."No.");
        if SalesCrMemoLine.FindSet() then
            repeat
                RecordIDList.Add(SalesCrMemoLine.RecordId());
            until SalesCrMemoLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do
            TCSAmount += GetTCSAmount(RecordIDList.Get(i));

        TCSAmount := TCSManagement.RoundTCSAmount(TCSAmount);
    end;

    local procedure GetTCSAmount(RecID: RecordID): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TCSSetup: Record "TCS Setup";
    begin
        if not TCSSetup.Get() then
            exit;

        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetRange("Tax Type", TCSSetup."Tax Type");
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.CalcSums(Amount);

        exit(TaxTransactionValue.Amount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetSalesHeaderTCSAmount', '', false, false)]
    local procedure OnGetSalesHeaderTCSAmount(SalesHeader: Record "Sales Header"; var TCSAmount: Decimal)
    begin
        GetStatisticsAmount(SalesHeader, TCSAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetSalesInvHeaderTCSAmount', '', false, false)]
    local procedure OnGetSalesInvHeaderTCSAmount(SalesInvHeader: Record "Sales Invoice Header"; var TCSAmount: Decimal)
    begin
        GetStatisticsAmountPostedInvoice(SalesInvHeader, TCSAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetSalesCrMemoHeaderTCSAmount', '', false, false)]
    local procedure OnGetSalesCrMemoHeaderTCSAmount(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TCSAmount: Decimal)
    begin
        GetStatisticsAmountPostedCreditMemo(SalesCrMemoHeader, TCSAmount);
    end;
}
