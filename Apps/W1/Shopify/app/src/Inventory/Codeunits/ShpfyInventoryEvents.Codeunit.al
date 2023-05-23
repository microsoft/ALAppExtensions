/// <summary>
/// Codeunit Shpfy Inventory Events (ID 30196).
/// </summary>
codeunit 30196 "Shpfy Inventory Events"
{
    Access = Internal;

    [InternalEvent(false)]
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

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Calculation Stock.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="LocationFilter">Parameter of type Text.</param>
    /// <param name="StockResult">Parameter of type Decimal.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCalculationStock(Item: Record Item; ShopifyShop: Record "Shpfy Shop"; LocationFilter: Text; CurrentShopifyStock: Decimal; var StockResult: Decimal; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeExportStock(Item: Record Item; ShopifyShop: Record "Shpfy Shop"; ShopInventory: Record "Shpfy Shop Inventory"; ShopLocation: Record "Shpfy Shop Location"; var Handled: Boolean)
    begin
    end;
}