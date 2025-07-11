namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Bulk Operation Type.
/// </summary>
enum 30146 "Shpfy Bulk Operation Type" implements "Shpfy IBulk Operation"
{
    Access = Internal;
    Caption = 'Shopify Bulk Mutation Type';
    Extensible = true;

    value(0; UpdateProductImage)
    {
        Caption = 'Update Product Image';
        Implementation = "Shpfy IBulk Operation" = "Shpfy Bulk UpdateProductImage";
    }
    value(1; UpdateProductPrice)
    {
        Caption = 'Update Product Price';
        Implementation = "Shpfy IBulk Operation" = "Shpfy Bulk UpdateProductPrice";
    }
}
