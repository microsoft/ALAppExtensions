namespace Microsoft.Integration.Shopify;

enum 30161 "Shpfy Resource Type" implements "Shpfy ICreate Translation"
{
    Access = Internal;
    Caption = 'Shopify  Resource Type';
    Extensible = false;

    value(0; Product)
    {
        Caption = 'Product';
        Implementation = "Shpfy ICreate Translation" = "Shpfy Create Transl. Product";
    }

    value(1; ProductVariant)
    {
        Caption = 'Product Variant';
        Implementation = "Shpfy ICreate Translation" = "Shpfy Create Transl. Variant";
    }
}