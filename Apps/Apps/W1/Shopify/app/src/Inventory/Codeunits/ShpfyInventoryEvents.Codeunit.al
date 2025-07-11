namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

/// <summary>
/// Codeunit Shpfy Inventory Events (ID 30196).
/// </summary>
codeunit 30196 "Shpfy Inventory Events"
{
    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised After Calculation Stock.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="LocationFilter">Parameter of type Text.</param>
    /// <param name="StockResult">Parameter of type Decimal.</param>
    internal procedure OnAfterCalculationStock(Item: Record Item; ShopifyShop: Record "Shpfy Shop"; LocationFilter: Text; var StockResult: Decimal)
    begin
    end;
}