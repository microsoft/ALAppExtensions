
/// <summary>
/// Codeunit Shpfy Order Events (ID 30162).
/// </summary>
codeunit 30162 "Shpfy Order Events"
{
    Access = Internal;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Modify Shopify Order.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="OldShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterModifyShopifyOrder(var ShopifyOrderHeader: Record "Shpfy Order Header"; var OldShopifyOrderHeader: Record "Shpfy Order Header")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After NewShopify Order.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterNewShopifyOrder(var ShopifyOrderHeader: Record "Shpfy Order Header")
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

    [InternalEvent(false)]
    /// <summary> 
    /// Description for OnAfterMapCustomer.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterMapCustomer(var ShopifyOrderHeader: Record "Shpfy Order Header")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Description for OnBeforeMapShipmentMethod.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeMapShipmentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header"; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Description for OnAfterMapShipmentMethod.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterMapShipmentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Description for OnBeforeMapPaymentMethod.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeMapPaymentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header"; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Description for OnAfterMapPaymentMethod.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterMapPaymentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Release Sales Header.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeReleaseSalesHeader(var SalesHeader: Record "Sales Header"; ShopifyOrderHeader: Record "Shpfy Order Header"; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Release Sales Header.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="ShopifyHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure OnAfterReleaseSalesHeader(var SalesHeader: Record "Sales Header"; ShopifyHeader: Record "Shpfy Order Header")
    begin
    end;

    [InternalEvent(false)]
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

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Create Sales Header.
    /// </summary>
    /// <param name="ShopifyHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    internal procedure OnAfterCreateSalesHeader(ShopifyHeader: Record "Shpfy Order Header"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Create Shipping Cost Sales Line.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="ShopifyShippingCost">Parameter of type Record "Shopify Order Shipping Cost".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="SalesLine">Parameter of type Record "Sales Line".</param>
    internal procedure OnAfterCreateShippingCostSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; ShopifyShippingCost: Record "Shpfy Order Shipping Charges"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Create Sales Header.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateSalesHeader(ShopifyOrderHeader: Record "Shpfy Order Header"; var SalesHeader: Record "Sales Header"; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Create Shipping Cost Sales Line.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="ShopifyShippingCost">Parameter of type Record "Shopify Order Shipping Cost".</param>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="SalesLine">Parameter of type Record "Sales Line".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateShippingCostSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; ShopifyShippingCost: Record "Shpfy Order Shipping Charges"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
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

}
