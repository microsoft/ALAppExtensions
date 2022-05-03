/// <summary>
/// Codeunit Shpfy ToDraftProduct (ID 30187) implements Interface Shpfy IRemoveProductAction.
/// </summary>
codeunit 30187 "Shpfy ToDraftProduct" implements "Shpfy IRemoveProductAction"
{
    Access = Internal;

    /// <summary>
    /// RemoveProductAction.
    /// </summary>
    /// <param name="Product">VAR Record "Shopify Product".</param>
    internal procedure RemoveProductAction(var Product: Record "Shpfy Product")
    var
        TempProduct: Record "Shpfy Product" temporary;
        ProductApi: Codeunit "Shpfy Product API";
    begin
        if Product.Status <> "Shpfy Product Status"::Draft then begin
            TempProduct := Product;
            Product.Status := "Shpfy Product Status"::Draft;
            ProductApi.SetShop(Product."Shop Code");
            ProductApi.UpdateProduct(Product, TempProduct);
        end;
    end;
}
