namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;

/// <summary>
/// Codeunit Shpfy Order Events (ID 30162).
/// </summary>
codeunit 30162 "Shpfy Order Events"
{
    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised after import Shopify Order Header.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="IsNew">Parameter of type boolean.</param>
    internal procedure OnAfterImportShopifyOrderHeader(var ShopifyOrderHeader: Record "Shpfy Order Header"; IsNew: Boolean)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Description for OnBeforeMapCustomer.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeMapCustomer(var ShopifyOrderHeader: Record "Shpfy Order Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Description for OnAfterMapCustomer.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterMapCustomer(var ShopifyOrderHeader: Record "Shpfy Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Description for OnBeforeMapShipmentMethod.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeMapShipmentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Description for OnAfterMapShipmentMethod.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterMapShipmentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Description for OnBeforeMapShipmentAgent.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeMapShipmentAgent(var ShopifyOrderHeader: Record "Shpfy Order Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Description for OnAfterMapShipmentAgent.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterMapShipmentAgent(var ShopifyOrderHeader: Record "Shpfy Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Description for OnBeforeMapPaymentMethod.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeMapPaymentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Description for OnAfterMapPaymentMethod.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterMapPaymentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header")
    begin
    end;

#pragma warning disable AS0025
    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised After Processing of Sales Document.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterProcessSalesDocument(var SalesHeader: Record "Sales Header"; OrderHeader: Record "Shpfy Order Header")
    begin
    end;
#pragma warning restore AS0025

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised Before Processing of Sales Document.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnBeforeProcessSalesDocument(var ShopifyOrderHeader: Record "Shpfy Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised After Create Item Sales Line.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="ShopifyOrderLine">Parameter of type Record "Shopify Order Line".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="SalesLine">Parameter of type Record "Sales Line".</param>
    internal procedure OnAfterCreateItemSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; ShopifyOrderLine: Record "Shpfy Order Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

#pragma warning disable AS0025
    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised After Create Sales Header.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    internal procedure OnAfterCreateSalesHeader(OrderHeader: Record "Shpfy Order Header"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised After Create Shipping Cost Sales Line.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="OrderShippingCharges">Parameter of type Record "Shopify Order Shipping Cost".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="SalesLine">Parameter of type Record "Sales Line".</param>
    internal procedure OnAfterCreateShippingCostSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; OrderShippingCharges: Record "Shpfy Order Shipping Charges"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;
#pragma warning restore AS0025

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised Before Create Sales Header.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateSalesHeader(ShopifyOrderHeader: Record "Shpfy Order Header"; var SalesHeader: Record "Sales Header"; var LastCreatedDocumentId: Guid; var Handled: Boolean)
    begin
    end;

#pragma warning disable AS0025
    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised Before Create Shipping Cost Sales Line.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="OrderShippingCharges">Parameter of type Record "Shopify Order Shipping Cost".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="SalesLine">Parameter of type Record "Sales Line".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateShippingCostSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; OrderShippingCharges: Record "Shpfy Order Shipping Charges"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;
#pragma warning restore AS0025

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised Before Create Item Sales Line.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="ShopifyOrderLine">Parameter of type Record "Shopify Order Line".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="SalesLine">Parameter of type Record "Sales Line".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateItemSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; ShopifyOrderLine: Record "Shpfy Order Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeTranslateCurrencyCode(ShopifyCurrencyCode: Text; var CurrencyCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeConvertToFinancialStatus(Value: Text; var ShpfyFinancialStatus: Enum "Shpfy Financial Status"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeConvertToFulfillmentStatus(Value: Text; var ShpfyOrderFulfillStatus: Enum "Shpfy Order Fulfill. Status"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeConvertToOrderReturnStatus(Value: Text; var ShpfyOrderReturnStatus: Enum "Shpfy Order Return Status"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeMapCompany(var ShopifyOrderHeader: Record "Shpfy Order Header"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Description for OnAfterMapCompany.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterMapCompany(var ShopifyOrderHeader: Record "Shpfy Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised after refunds are deducted from the quantity and amounts of the orders.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="OrderLine">Parameter of type Record "Shopify Order Line".</param>
    /// <param name="RefundLine">Parameter of type Record "Shopify Refund Line".</param>
    internal procedure OnAfterConsiderRefundsInQuantityAndAmounts(OrderHeader: Record "Shpfy Order Header"; var OrderLine: Record "Shpfy Order Line"; RefundLine: Record "Shpfy Refund Line")
    begin
    end;
}
