namespace Microsoft.Integration.Shopify;

using System.Reflection;

codeunit 30281 "Shpfy Bulk UpdateProductPrice" implements "Shpfy IBulk Operation"
{
    Access = Internal;

    var
        NameLbl: Label 'Update product price';

    procedure GetGraphQL(): Text
    begin
        exit('mutation call($productId: ID!, $variants: [ProductVariantsBulkInput!]!) { productVariantsBulkUpdate(productId: $productId, variants: $variants) { productVariants {id updatedAt}, userErrors {field, message}}}');
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

    procedure RevertFailedRequests(var BulkOperation: Record "Shpfy Bulk Operation")
    var
        Shop: Record "Shpfy Shop";
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        TypeHelper: Codeunit "Type Helper";
        JsonlResult: Text;
        Result: List of [Text];
        Line: Text;
        JLine: JsonObject;
        JVariants: JsonArray;
        JVariant: JsonToken;
        SuccessList: List of [BigInteger];
    begin
        if not Shop.Get(BulkOperation."Shop Code") then
            exit;

        JsonlResult := BulkOperationMgt.GetBulkOperationResult(Shop, BulkOperation);
        if JsonlResult = '' then
            exit;

        Result := JsonlResult.Split(TypeHelper.LFSeparator());
        foreach Line in Result do
            if JLine.ReadFrom(Line) then
                if JsonHelper.ContainsToken(JLine, 'data.productVariantsBulkUpdate.productVariants') then begin
                    JVariants := JsonHelper.GetJsonArray(JLine, 'data.productVariantsBulkUpdate.productVariants');
                    if JVariants.Count = 1 then
                        if JVariants.Get(0, JVariant) then
                            if JsonHelper.GetValueAsDateTime(JVariant, 'updatedAt') > 0DT then
                                SuccessList.Add(CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JVariant, 'id')));
                end;

        RevertRequests(BulkOperation, SuccessList);
    end;

    local procedure RevertRequests(var BulkOperation: Record "Shpfy Bulk Operation"; var SuccessList: List of [BigInteger])
    var
        ShopifyVariant: Record "Shpfy Variant";
        JRequestData: JsonArray;
        JRequest: JsonToken;
        JVariant: JsonObject;
    begin
        JRequestData := BulkOperation.GetRequestData();
        foreach JRequest in JRequestData do begin
            JVariant := JRequest.AsObject();
            if not SuccessList.Contains(JVariant.GetBigInteger('id')) then
                if ShopifyVariant.Get(JVariant.GetBigInteger('id')) then begin
                    ShopifyVariant.Price := JVariant.GetDecimal('price');
                    ShopifyVariant."Compare at Price" := JVariant.GetDecimal('compareAtPrice');
                    ShopifyVariant."Updated At" := JVariant.GetDateTime('updatedAt');
                    ShopifyVariant.Modify();
                end;
        end;
    end;

    procedure RevertAllRequests(var BulkOperation: Record "Shpfy Bulk Operation")
    var
        EmptyList: List of [BigInteger];
    begin
        RevertRequests(BulkOperation, EmptyList);
    end;
}