// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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

    procedure RevertFailedRequests(var BulkOperation: Record "Shpfy Bulk Operation")
    begin
        exit; // No implementation needed for this operation
    end;

    procedure RevertAllRequests(var BulkOperation: Record "Shpfy Bulk Operation")
    var
        Product: Record "Shpfy Product";
        JRequestData: JsonArray;
        JRequest: JsonToken;
        JProduct: JsonObject;
    begin
        JRequestData := BulkOperation.GetRequestData();
        foreach JRequest in JRequestData do begin
            JProduct := JRequest.AsObject();
            if Product.Get(JProduct.GetBigInteger('id')) then begin
                Product."Image Hash" := JProduct.GetInteger('imageHash');
                Product.Modify();
            end;
        end;
    end;
}