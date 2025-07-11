namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;

codeunit 30247 "Shpfy Refund Process Events"
{
    [IntegrationEvent(false, false)]
    /// <summary>
    /// Raised Before Create Sales Header.
    /// </summary>
    /// <param name="RefundHeader">Parameter of type Record "Shopify Refund Header".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateSalesHeader(RefundHeader: Record "Shpfy Refund Header"; var SalesHeader: Record "Sales Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary>
    /// Raised After Create Sales Header.
    /// </summary>
    /// <param name="RefundHeader">Parameter of type Record "Shopify Refund Header".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    internal procedure OnAfterCreateSalesHeader(RefundHeader: Record "Shpfy Refund Header"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeCreateItemSalesLine(RefundHeader: Record "Shpfy Refund Header"; RefundLine: Record "Shpfy Refund Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var NextLineNo: Integer; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary>
    /// Raised After Create Item Sales Line.
    /// </summary>
    /// <param name="RefundHeader">Parameter of type Record "Shopify Refund Header".</param>
    /// <param name="RefundLine">Parameter of type Record "Shopify Refund Line".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="SalesLine">Parameter of type Record "Sales Line".</param>
    internal procedure OnAfterCreateItemSalesLine(RefundHeader: Record "Shpfy Refund Header"; RefundLine: Record "Shpfy Refund Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeCreateItemSalesLineFromReturnLine(RefundHeader: Record "Shpfy Refund Header"; ReturnLine: Record "Shpfy Return Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var NextLineNo: Integer; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnAfterCreateItemSalesLineFromReturnLine(RefundHeader: Record "Shpfy Refund Header"; ReturnLine: Record "Shpfy Return Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary>
    /// Raised After Process Sales Document.
    /// </summary>
    /// <param name="RefundHeader">Parameter of type Record "Shopify Refund Header".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    internal procedure OnAfterProcessSalesDocument(RefundHeader: Record "Shpfy Refund Header"; var SalesHeader: Record "Sales Header")
    begin
    end;
}