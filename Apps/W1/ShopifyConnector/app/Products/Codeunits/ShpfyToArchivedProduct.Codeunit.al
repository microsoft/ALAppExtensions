/// <summary>
/// Codeunit Shpfy ToArchivedProduct (ID 30186) implements Interface Shpfy IRemoveProductAction.
/// </summary>
codeunit 30186 "Shpfy ToArchivedProduct" implements "Shpfy IRemoveProductAction"
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
        if Product.Status <> "Shpfy Product Status"::Archived then begin
            TempProduct := Product;
            Product.Status := "Shpfy Product Status"::Archived;
            ProductApi.SetShop(Product."Shop Code");
            ProductApi.UpdateProduct(Product, TempProduct);
        end;
    end;
}
