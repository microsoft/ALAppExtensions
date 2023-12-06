namespace Microsoft.Integration.Shopify;

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
        ProductApi: Codeunit "Shpfy Product API";
    begin
        if Product.Status <> "Shpfy Product Status"::Archived then begin
            ProductApi.SetShop(Product."Shop Code");
            ProductApi.UpdateProductStatus(Product, "Shpfy Product Status"::Archived);
        end;
    end;
}
