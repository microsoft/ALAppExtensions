#if CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Utilities;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;

codeunit 10591 "Format Report GB"
{

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Draft Invoice", 'OnBeforeFormatLineValues', '', false, false)]
    local procedure OnBeforeFormatLineValuesInStandardSalesDraftInvoiceReport(SalesLine: Record "Sales Line"; var FormattedQuantity: Text; var FormattedUnitPrice: Text; var FormattedVATPercentage: Text; var FormattedLineAmount: Text; var IsHandled: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        FormatDocument: Codeunit "Format Document";
    begin
        if VATPostingSetup.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group") then
            if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" then
                SalesLine."VAT %" := VATPostingSetup."VAT %";
        FormatDocument.SetSalesLine(
          SalesLine, FormattedQuantity, FormattedUnitPrice, FormattedVATPercentage, FormattedLineAmount);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Invoice", 'OnBeforeFormatLineValues', '', false, false)]
    local procedure OnBeforeFormatLineValuesInStandardSalesInvoiceReport(SalesInvoiceLine: Record "Sales Invoice Line"; var FormattedQuantity: Text; var FormattedUnitPrice: Text; var FormattedVATPercentage: Text; var FormattedLineAmount: Text; var IsHandled: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        FormatDocument: Codeunit "Format Document";
    begin
        if VATPostingSetup.Get(SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group") then
            if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" then
                SalesInvoiceLine."VAT %" := VATPostingSetup."VAT %";
        FormatDocument.SetSalesInvoiceLine(
          SalesInvoiceLine, FormattedQuantity, FormattedUnitPrice, FormattedVATPercentage, FormattedLineAmount);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Credit Memo", 'OnBeforeFormatLineValues', '', false, false)]
    local procedure OnBeforeFormatLineValuesInStandardSalesCrMemoReport(SalesCrMemoLine: Record "Sales Cr.Memo Line"; var FormattedQuantity: Text; var FormattedUnitPrice: Text; var FormattedVATPercentage: Text; var FormattedLineAmount: Text; var IsHandled: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        FormatDocument: Codeunit "Format Document";
    begin
        if VATPostingSetup.Get(SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group") then
            if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" then
                SalesCrMemoLine."VAT %" := VATPostingSetup."VAT %";
        FormatDocument.SetSalesCrMemoLine(
          SalesCrMemoLine, FormattedQuantity, FormattedUnitPrice, FormattedVATPercentage, FormattedLineAmount);
        IsHandled := true;
    end;
}
#endif

