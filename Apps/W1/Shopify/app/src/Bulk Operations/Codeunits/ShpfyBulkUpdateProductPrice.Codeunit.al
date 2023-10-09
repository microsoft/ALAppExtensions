namespace Microsoft.Integration.Shopify;

codeunit 30281 "Shpfy Bulk UpdateProductPrice" implements "Shpfy IBulk Operation"
{
    Access = Internal;

    var
        NameLbl: Label 'Update product price';

    procedure GetGraphQL(): Text
    begin
        exit('mutation call($input: ProductVariantInput!) { productVariantUpdate(input: $input) { productVariant {updatedAt}, userErrors {field, message}}}');
    end;

    procedure GetInput(): Text
    begin
        exit('{ "input": { "id": "gid://shopify/ProductVariant/%1", "price": "%2", "compareAtPrice": "%3" } }');
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