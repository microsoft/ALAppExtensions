namespace Microsoft.Integration.Shopify;

codeunit 30281 "Shpfy Bulk UpdateProductPrice" implements "Shpfy IBulk Operation"
{
    Access = Internal;

    var
        NameLbl: Label 'Update product price';

    procedure GetGraphQL(): Text
    begin
        exit('mutation call($productId: ID!, $variants: [ProductVariantsBulkInput]!) { productVariantsBulkUpdate(productId: $productId, variants: $variants) { productVariants {updatedAt}, userErrors {field, message}}}');
    end;

    procedure GetInput(): Text
    begin
        exit('{ "productId": "gid://shopify/Product/%1", "variants": [{ "id": "gid://shopify/ProductVariant/%2", "price": "%3", "compareAtPrice": "%4" }]}');
    end;

    procedure GetName(): Text[250]
    begin
        exit(NameLbl);
    end;

    procedure GetType(): Text
    begin
        exit('mutation');
    end;
}