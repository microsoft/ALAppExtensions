// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Sales.Document;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.ExtendedText;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.GST.Base;

codeunit 19063 "Contoso IN Sales Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Sales Header" = rim,
                tabledata "Sales Line" = rim;


    procedure InsertSalesHeader(DocumentType: Enum "Sales Document Type"; SelltoCustomerNo: Code[20]; PostingDate: Date; DocumentNo: Code[20]; TDSCert: Boolean; PostingNoSeries: Code[20]; CurrencyCode: Code[10]; ShippingAgentCode: Code[10])
    var
        SalesHeader: Record "Sales Header";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        SalesHeader.Validate("Document Type", DocumentType);

        if DocumentNo = '' then
            SalesHeader.Validate("No.", '')
        else
            SalesHeader."No." := DocumentNo;

        SalesHeader."Posting Date" := ContosoUtilities.AdjustDate(PostingDate);
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", SelltoCustomerNo);
        SalesHeader.Validate("Posting Date");
        SalesHeader.Validate("Order Date", ContosoUtilities.AdjustDate(PostingDate));
        SalesHeader.Validate("Shipment Date", ContosoUtilities.AdjustDate(PostingDate));
        SalesHeader.Validate("Document Date", ContosoUtilities.AdjustDate(PostingDate));
        SalesHeader.Validate("Shipping Agent Code", ShippingAgentCode);
        SalesHeader.Validate("Currency Code", CurrencyCode);

        if SalesHeader."Currency Code" <> '' then
            SalesHeader."Currency Factor" := CurrencyExchangeRate.ExchangeRate(WorkDate(), SalesHeader."Currency Code");

        if PostingNoSeries <> '' then
            SalesHeader."Posting No. Series" := PostingNoSeries;

        SalesHeader."TDS Certificate Receivable" := TDSCert;
        SalesHeader.Modify(true);
    end;

    procedure InsertSalesLine(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; Type: Enum "Sales Line Type"; No: Code[20]; LocationCode: Code[10]; Quantity: Decimal; NOC: Code[20]; UnitPrice: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        SalesHeader.Get(DocumentType, DocumentNo);

        SalesLine.Init();
        SalesLine.Validate("Document Type", DocumentType);
        SalesLine.Validate("Document No.", DocumentNo);
        SalesLine.Validate("Line No.", GetNextSalesLineNo(SalesHeader));
        SalesLine.Validate(Type, Type);
        SalesLine.Validate("No.", No);


        if SalesHeader."Location Code" <> '' then
            SalesLine.Validate("Location Code", SalesHeader."Location Code");

        SalesLine.Validate(Quantity, Quantity);
        SalesLine.Validate("TCS Nature of Collection", NOC);

        if UnitPrice <> 0 then
            SalesLine.Validate("Unit Price", UnitPrice);

        SalesLine.Insert(true);

        CalculateTax.CallTaxEngineOnSalesLine(SalesLine, SalesLine);

        if TransferExtendedText.SalesCheckIfAnyExtText(SalesLine, false) then
            TransferExtendedText.InsertSalesExtText(SalesLine);
    end;

    procedure InsertRefInvNo(DocumentType: Enum "Document Type Enum"; DocumentNo: Code[20]; SourceNo: Code[20])
    var
        ReferenceInvNo: Record "Reference Invoice No.";
    begin
        ReferenceInvNo.Init();
        ReferenceInvNo."Document Type" := DocumentType;
        ReferenceInvNo."Document No." := DocumentNo;
        ReferenceInvNo."Source Type" := ReferenceInvNo."Source Type"::Customer;
        ReferenceInvNo."Source No." := SourceNo;
        ReferenceInvNo.Insert();
    end;

    local procedure GetNextSalesLineNo(SalesHeader: Record "Sales Header"): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetCurrentKey("Line No.");

        if SalesLine.FindLast() then
            exit(SalesLine."Line No." + 10000)
        else
            exit(10000);
    end;
}
