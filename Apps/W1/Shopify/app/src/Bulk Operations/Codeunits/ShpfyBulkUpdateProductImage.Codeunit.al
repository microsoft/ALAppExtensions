namespace Microsoft.Integration.Shopify;

codeunit 30280 "Shpfy Bulk UpdateProductImage" implements "Shpfy IBulk Operation"
{
    Access = Internal;

    var
        NameLbl: Label 'Update product image';

    procedure GetGraphQL(): Text
    begin
        exit('mutation call($media: [UpdateMediaInput!]!, $productId: ID!) { productUpdateMedia(media: $media, productId: $productId) { media { ...mediaFieldsByType }}} fragment mediaFieldsByType on Media { ... on MediaImage { id }}');
    end;

    procedure GetInput(): Text
    begin
        exit('{ "media": { "id": "gid://shopify/MediaImage/%1", "previewImageSource": "%2"}, "productId": "gid://shopify/Product/%3" }');
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