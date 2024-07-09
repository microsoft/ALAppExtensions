namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;
using System.Environment;

/// <summary>
/// Codeunit Shpfy Product API (ID 30176).
/// </summary>
codeunit 30176 "Shpfy Product API"
{
    Access = Internal;
    Permissions = tabledata Item = r;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        ProductEvents: Codeunit "Shpfy Product Events";
        VariantApi: Codeunit "Shpfy Variant API";

    /// <summary> 
    /// Create Product.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    internal procedure CreateProduct(var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var ShopifyTag: Record "Shpfy Tag"): BigInteger
    var
        NewShopifyProduct: Record "Shpfy Product";
        ShopLocation: Record "Shpfy Shop Location";
        NewShopifyVariant: Record "Shpfy Variant";
        IStockAvailable: Interface "Shpfy IStock Available";
        JArray: JsonArray;
        JResponse: JsonToken;
        JToken: JsonToken;
        Data: Text;
        GraphQuery: TextBuilder;

    begin
        ShopifyVariant.FindSet();
        ProductEvents.OnBeforeSendCreateShopifyProduct(Shop, ShopifyProduct, ShopifyVariant, ShopifyTag);
        GraphQuery.Append('{"query":"mutation {productCreate(input: {');
        GraphQuery.Append('title: \"');
        GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct.Title));
        GraphQuery.Append('\"');
        Data := ShopifyProduct.GetDescriptionHtml();
        if Data <> '' then begin
            GraphQuery.Append(', descriptionHtml: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(Data));
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct."Product Type" <> '' then begin
            GraphQuery.Append(', productType: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct."Product Type"));
            GraphQuery.Append('\"');
        end;
        GraphQuery.Append(', status: ');
        GraphQuery.Append(ConvertToProductStatus(ShopifyProduct.Status));
        Data := ShopifyTag.GetCommaSeparatedTags(ShopifyProduct.Id);
        if Data <> '' then begin
            GraphQuery.Append(', tags: \"');
            GraphQuery.Append(Data);
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct.Vendor <> '' then begin
            GraphQuery.Append(', vendor: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct.Vendor));
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct."Has Variants" or (ShopifyVariant."UoM Option Id" > 0) then begin
            GraphQuery.Append(', options: [\"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant."Option 1 Name"));
            if ShopifyVariant."Option 2 Name" <> '' then begin
                GraphQuery.Append('\", \"');
                GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant."Option 2 Name"));
            end;
            GraphQuery.Append('\"]');
        end;
        GraphQuery.Append(', published: true');
        GraphQuery.Append(', variants: {inventoryPolicy: ');
        GraphQuery.Append(ShopifyVariant."Inventory Policy".Names.Get(ShopifyVariant."Inventory Policy".Ordinals.IndexOf(ShopifyVariant."Inventory Policy".AsInteger())));
        if ShopifyVariant.Barcode <> '' then begin
            GraphQuery.Append(', barcode: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant.Barcode));
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.SKU <> '' then begin
            GraphQuery.Append(', sku: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyVariant.SKU));
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Taxable then
            GraphQuery.Append(', taxable: true');
        if ShopifyVariant."Tax Code" <> '' then begin
            GraphQuery.Append(', taxCode: \"');
            GraphQuery.Append(ShopifyVariant."Tax Code");
            GraphQuery.Append('\"');
        end;
        if ShopifyVariant.Weight > 0 then begin
            GraphQuery.Append(', weight: ');
            GraphQuery.Append(Format(ShopifyVariant.Weight, 0, 9));
        end;
        if ShopifyVariant.Price > 0 then begin
            GraphQuery.Append(', price: \"');
            GraphQuery.Append(Format(ShopifyVariant.Price, 0, 9));
            GraphQuery.Append('\"')
        end;
        if ShopifyVariant."Compare at Price" > ShopifyVariant.Price then begin
            GraphQuery.Append(', compareAtPrice: \"');
            GraphQuery.Append(Format(ShopifyVariant."Compare at Price", 0, 9));
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct."Has Variants" or (ShopifyVariant."UoM Option Id" > 0) then begin
            GraphQuery.Append(', options: [\"');
            GraphQuery.Append(ShopifyVariant."Option 1 Value");
            if ShopifyVariant."Option 2 Name" <> '' then begin
                GraphQuery.Append('\", \"');
                GraphQuery.Append(ShopifyVariant."Option 2 Value");
            end;
            GraphQuery.Append('\"]');
        end;
        ShopLocation.SetRange("Shop Code", ShopifyProduct."Shop Code");
        ShopLocation.SetRange(Active, true);
        ShopLocation.SetRange("Default Product Location", true);
        if ShopLocation.FindSet(false) then begin
            GraphQuery.Append(', inventoryQuantities: [');
            repeat
                IStockAvailable := ShopLocation."Stock Calculation";
                GraphQuery.Append('{availableQuantity: 0, locationId: \"gid://shopify/Location/');
                GraphQuery.Append(Format(ShopLocation.Id));
                GraphQuery.Append('\"}, ');
            until ShopLocation.Next() = 0;
            GraphQuery.Remove(GraphQuery.Length - 1, 2);
            GraphQuery.Append(']');
        end;
        GraphQuery.Append(', inventoryItem: {tracked: ');
        if Shop."Inventory Tracked" then
            GraphQuery.Append('true')
        else
            GraphQuery.Append('false');
        if ShopifyVariant."Unit Cost" > 0 then begin
            GraphQuery.Append(', cost: \"');
            GraphQuery.Append(Format(ShopifyVariant."Unit Cost", 0, 9));
            GraphQuery.Append('\"');
        end;
        GraphQuery.Append('}}}) ');

        GraphQuery.Append('{product {legacyResourceId, onlineStoreUrl, onlineStorePreviewUrl, createdAt, updatedAt, tags, variants(first: 1) {edges {node {legacyResourceId, createdAt, updatedAt}}}}, userErrors {field, message}}');
        GraphQuery.Append('}"}');

        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
        NewShopifyProduct := ShopifyProduct;
        NewShopifyProduct.Id := JsonHelper.GetValueAsBigInteger(JResponse, 'data.productCreate.product.legacyResourceId');
        if NewShopifyProduct.Id = 0 then
            exit;
#pragma warning disable AA0139
        NewShopifyProduct."Preview URL" := JsonHelper.GetValueAsText(JResponse, 'data.productCreate.product.onlineStorePreviewUrl', MaxStrLen(NewShopifyProduct."Preview URL"));
        NewShopifyProduct.URL := JsonHelper.GetValueAsText(JResponse, 'data.productCreate.product.onlineStoreUrl', MaxStrLen(NewShopifyProduct.URL));
        NewShopifyProduct.UpdateTags(JsonHelper.GetArrayAsText(JResponse, 'data.productCreate.product.tags'));
#pragma warning restore AA0139
        NewShopifyProduct."Created At" := JsonHelper.GetValueAsDateTime(JResponse, 'data.productCreate.product.createdAt');
        NewShopifyProduct."Updated At" := JsonHelper.GetValueAsDateTime(JResponse, 'data.productCreate.product.updatedAt');
        NewShopifyProduct.Insert();

        NewShopifyVariant := ShopifyVariant;
        NewShopifyVariant."Product Id" := NewShopifyProduct.Id;
        if JsonHelper.GetJsonArray(JResponse, JArray, 'data.productCreate.product.variants.edges') and JArray.Get(0, JToken) then begin
            NewShopifyVariant.Id := JsonHelper.GetValueAsBigInteger(JToken, 'edges.node.legacyResourceId');
            NewShopifyVariant."Created At" := JsonHelper.GetValueAsDateTime(JToken, 'edges.node.createdAt');
            NewShopifyVariant."Updated At" := JsonHelper.GetValueAsDateTime(JToken, 'edges.node.updatedAt');
            NewShopifyVariant.Insert();
        end;

        while ShopifyVariant.Next() > 0 do begin
            ShopifyVariant."Product Id" := NewShopifyProduct.Id;
            VariantApi.AddProductVariant(ShopifyVariant);
        end;

        exit(NewShopifyProduct.Id);
    end;

    local procedure CreateImageUploadUrl(Item: Record Item; var Url: Text; var ResourceUrl: Text; var TenantMedia: Record "Tenant Media"): boolean
    var
        MimeType: Text;
        MediaId: Guid;
        Filename: Text;
        JResponse: JsonToken;
        JArray: JsonArray;
        Parameters: Dictionary of [Text, Text];
    begin
        Clear(Url);
        Clear(ResourceUrl);
        if Item.Picture.Count > 0 then begin
            MediaId := Item.Picture.Item(1);
            if TenantMedia.Get(MediaId) then begin
                MimeType := TenantMedia."Mime Type";
                Filename := 'BC_Upload.' + MimeType.Split('/').Get(MimeType.Split('/').Count);
                Parameters.Add('Filename', Filename);
                Parameters.Add('MimeType', MimeType);
                Parameters.Add('Resource', 'IMAGE');
                Parameters.Add('HttpMethod', 'PUT');
                JResponse := CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::CreateUploadUrl, Parameters);
                JArray := JsonHelper.GetJsonArray(JResponse, 'data.stagedUploadsCreate.stagedTargets');
                if JArray.Count = 1 then
                    if JArray.Get(0, JResponse) then begin
                        Url := JsonHelper.GetValueAsText(JResponse, 'url');
                        ResourceUrl := JsonHelper.GetValueAsText(JResponse, 'resourceUrl');
                        exit((Url <> '') and (ResourceUrl <> ''));
                    end;
            end;
        end;
    end;

    [TryFunction]
    local procedure UploadImage(TenantMedia: Record "Tenant Media"; Url: Text)
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        InStream: InStream;
    begin
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', TenantMedia."Mime Type");
        TenantMedia.CalcFields(Content);
        if TenantMedia.Content.HasValue then begin
            TenantMedia.Content.CreateInStream(InStream);
            Content.WriteFrom(InStream);
            Client.Put(Url, Content, Response);
        end;
    end;

    local procedure SetProductImage(Product: Record "Shpfy Product"; ResourceUrl: Text): BigInteger
    var
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
        JArray: JsonArray;
    begin
        Parameters.Add('ProductId', Format(Product.Id));
        Parameters.Add('ResourceUrl', ResourceUrl);
        JResponse := CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::AddProductImage, Parameters);
        JArray := JsonHelper.GetJsonArray(JResponse, 'data.productCreateMedia.media');
        if JArray.Count = 1 then
            if JArray.Get(0, JResponse) then
                exit(CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JResponse, 'id')));
    end;

    local procedure UpdateProductImage(Product: Record "Shpfy Product"; ResourceUrl: Text): BigInteger
    var
        Parameters: Dictionary of [Text, Text];
    begin
        Parameters.Add('ProductId', Format(Product.Id));
        Parameters.Add('ResourceUrl', ResourceUrl);
        Parameters.Add('ImageId', Format(Product."Image Id"));
        CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::UpdateProductImage, Parameters);
        exit(Product."Image Id");
    end;

    internal procedure UpdateProductImage(Parameters: Dictionary of [Text, Text])
    begin
        CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::UpdateProductImage, Parameters);
    end;

    /// <summary> 
    /// Update Shopify Product Image.
    /// </summary>
    /// <param name="Product">Parameter of type Record "Shopify Product".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <returns>Return value of type BigInteger.</returns>
    internal procedure UpdateShopifyProductImage(Product: Record "Shpfy Product"; Item: Record Item; var BulkOperationInput: TextBuilder; var ParametersList: List of [Dictionary of [Text, Text]]; RecordCount: Integer): BigInteger
    var
        TenantMedia: Record "Tenant Media";
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
        BulkOperationType: Enum "Shpfy Bulk Operation Type";
        IBulkOperation: Interface "Shpfy IBulk Operation";
        Parameters: Dictionary of [Text, Text];
        Url: Text;
        ResourceUrl: Text;
    begin
        if Item.Picture.Count > 0 then
            if CreateImageUploadUrl(Item, Url, ResourceUrl, TenantMedia) then
                if UploadImage(TenantMedia, Url) then
#if not CLEAN23
                    if not BulkOperationMgt.IsBulkOperationFeatureEnabled() or (RecordCount < BulkOperationMgt.GetBulkOperationThreshold()) then
#else
                    if RecordCount <= BulkOperationMgt.GetBulkOperationThreshold() then
#endif
                        exit(UpdateProductImage(Product, ResourceUrl))
                    else begin
                        IBulkOperation := BulkOperationType::UpdateProductImage;
                        Parameters.Add('ProductId', Format(Product.Id));
                        Parameters.Add('ResourceUrl', ResourceUrl);
                        Parameters.Add('ImageId', Format(Product."Image Id"));
                        ParametersList.Add(Parameters);
                        BulkOperationInput.AppendLine(StrSubstNo(IBulkOperation.GetInput(), Format(Product."Image Id"), ResourceUrl, Format(Product.Id)));
                        exit(Product."Image Id");
                    end;
    end;

    /// <summary> 
    /// Create Shopify Product Image.
    /// </summary>
    /// <param name="Product">Parameter of type Record "Shopify Product".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <returns>Return value of type BigInteger.</returns>
    internal procedure CreateShopifyProductImage(Product: Record "Shpfy Product"; Item: Record Item): BigInteger
    var
        TenantMedia: Record "Tenant Media";
        Url: Text;
        ResourceUrl: Text;
    begin
        if Item.Picture.Count > 0 then
            if Product."Image Id" = 0 then
                if CreateImageUploadUrl(Item, Url, ResourceUrl, TenantMedia) then
                    if UploadImage(TenantMedia, Url) then
                        exit(SetProductImage(Product, ResourceUrl));
    end;

    /// <summary> 
    /// Get Image Data.
    /// </summary>
    /// <param name="JImageNode">Parameter of type JsonToken.</param>
    /// <param name="ImageData">Parameter of type Dictionary of [BigInteger, Text].</param>
    local procedure GetImageData(JImageNode: JsonToken; var ImageData: Dictionary of [BigInteger, Text])
    var
        Data: Dictionary of [BigInteger, Text];
    begin
        Data.Add(CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JImageNode, 'node.id')), JsonHelper.GetValueAsText(JImageNode, 'node.image.url'));
        ImageData := Data;
    end;

    /// <summary> 
    /// Retrieve Shopify Product.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure RetrieveShopifyProduct(var ShopifyProduct: Record "Shpfy Product"): Boolean
    var
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JProduct: JsonObject;
        JResponse: JsonToken;
    begin
        Parameters.Add('ProductId', Format(ShopifyProduct.Id));
        Parameters.add('MaxLengthDescription', Format(MaxStrLen(ShopifyProduct.Description)));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::GetProductById, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JProduct, 'data.product') then
            exit(UpdateShopifyProductFields(ShopifyProduct, JProduct));
    end;


    /// <summary> 
    /// Retrieve Shopify Product Ids.
    /// </summary>
    /// <param name="ProductIds">Parameter of type Dictionary of [BigInteger, DateTime].</param>
    internal procedure RetrieveShopifyProductIds(var ProductIds: Dictionary of [BigInteger, DateTime]; NumberOfRecords: Integer)
    var
        Math: Codeunit "Shpfy Math";
        Id: BigInteger;
        LastSyncTime: DateTime;
        UpdatedAt: DateTime;
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JProducts: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
    begin
        Clear(ProductIds);
        GraphQLType := GraphQLType::GetProductIds;
        LastSyncTime := Shop.GetLastSyncTime("Shpfy Synchronization Type"::Products);
        Parameters.Add('Time', Format(LastSyncTime, 0, 9));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonArray(JResponse, JProducts, 'data.products.edges') then begin
                foreach JItem in JProducts do begin
                    Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id'));
                        UpdatedAt := JsonHelper.GetValueAsDateTime(JNode, 'updatedAt');
                        if not ProductIds.ContainsKey(Id) then
                            ProductIds.Add(Id, UpdatedAt)
                        else
                            ProductIds.Set(Id, Math.Max(ProductIds.Get(Id), UpdatedAt));
                    end;
                    if NumberOfRecords <> 0 then
                        if ProductIds.Count >= NumberOfRecords then
                            exit;
                end;
                GraphQLType := GraphQLType::GetNextProductIds;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
            end;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.products.pageInfo.hasNextPage');
    end;

    /// <summary> 
    /// Retrieve Shopify Product Images.
    /// </summary>
    /// <param name="ProductImages">Parameter of type Dictionary of [BigInteger, Dictionary of [BigInteger, Text]].</param>
    internal procedure RetrieveShopifyProductImages(var ProductImages: Dictionary of [BigInteger, Dictionary of [BigInteger, Text]])
    var
        Id: BigInteger;
        ImageData: Dictionary of [BigInteger, Text];
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JImages: JsonArray;
        JProducts: JsonArray;
        JNode: JsonObject;
        JImage: JsonToken;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
        MediaContentType: Text;
    begin
        Clear(ProductImages);
        GraphQLType := GraphQLType::GetProductImages;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonArray(JResponse, JProducts, 'data.products.edges') then begin
                foreach JItem in JProducts do begin
                    Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := JsonHelper.GetValueAsBigInteger(JNode, 'legacyResourceId');
                        if JsonHelper.GetJsonArray(JNode, JImages, 'media.edges') then
                            if JImages.Count = 1 then begin
                                JImages.Get(0, JImage);
                                MediaContentType := JsonHelper.GetValueAsText(JImage, 'node.mediaContentType');
                                if MediaContentType = 'IMAGE' then begin
                                    GetImageData(JImage, ImageData);
                                    ProductImages.Add(Id, ImageData);
                                end;
                            end;
                    end
                end;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
            end;
            GraphQLType := GraphQLType::GetNextProductImages;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.products.pageInfo.hasNextPage');
    end;

    /// <summary> 
    ///  Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        SetShop(Shop);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        VariantApi.SetShop(Shop);
        CommunicationMgt.SetShop(Shop);
    end;

    /// <summary> 
    /// Update Product.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="xShopifyProduct">Parameter of type Record "Shopify Product".</param>
    internal procedure UpdateProduct(var ShopifyProduct: Record "Shpfy Product"; var xShopifyProduct: Record "Shpfy Product")
    var
        JResponse: JsonToken;
        Data: Text;
        GraphQuery: TextBuilder;
    begin
        ProductEvents.OnBeforeSendUpdateShopifyProduct(Shop, ShopifyProduct, xShopifyProduct);
        GraphQuery.Append('{"query":"mutation {productUpdate(input: {id: \"gid://shopify/Product/');
        GraphQuery.Append(Format(ShopifyProduct.Id));
        GraphQuery.Append('\"');
        if ShopifyProduct.Title <> xShopifyProduct.Title then begin
            GraphQuery.Append(', title: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct.Title));
            GraphQuery.Append('\"');
        end;
        Data := ShopifyProduct.GetDescriptionHtml();
        if Data <> xShopifyProduct.GetDescriptionHtml() then begin
            GraphQuery.Append(', descriptionHtml: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(Data));
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct."Product Type" <> xShopifyProduct."Product Type" then begin
            GraphQuery.Append(', productType: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct."Product Type"));
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct.Status <> xShopifyProduct.Status then begin
            GraphQuery.Append(', status: ');
            GraphQuery.Append(ConvertToProductStatus(ShopifyProduct.Status));
        end;
        Data := ShopifyProduct.GetCommaSeparatedTags();
        if Data <> '' then begin
            GraphQuery.Append(', tags: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(Data));
            GraphQuery.Append('\"');
        end;
        if ShopifyProduct.Vendor <> xShopifyProduct.Vendor then begin
            GraphQuery.Append(', vendor: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct.Vendor));
            GraphQuery.Append('\"');
        end;
        if (ShopifyProduct."SEO Title" <> xShopifyProduct."SEO Title") or (ShopifyProduct."SEO Description" <> xShopifyProduct."SEO Description") then begin
            GraphQuery.Append(', seo: {');
            GraphQuery.Append('description: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct."SEO Description"));
            GraphQuery.Append('\", ');
            GraphQuery.Append('title: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(ShopifyProduct."SEO Title"));
            GraphQuery.Append('\", ');
            GraphQuery.Remove(GraphQuery.Length - 1, 2);
            GraphQuery.Append('}')
        end;
        GraphQuery.Append('}) ');
        GraphQuery.Append('{product {id, onlineStoreUrl, onlineStorePreviewUrl, updatedAt}, userErrors {field, message}}');
        GraphQuery.Append('}"}');

        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
#pragma warning disable AA0139
        ShopifyProduct."Preview URL" := JsonHelper.GetValueAsText(JResponse, 'data.productUpdate.product.onlineStorePreviewUrl', MaxStrLen(ShopifyProduct."Preview URL"));
        ShopifyProduct.URL := JsonHelper.GetValueAsText(JResponse, 'data.productUpdate.product.onlineStoreUrl', MaxStrLen(ShopifyProduct.URL));
#pragma warning restore AA0139
        ShopifyProduct."Updated At" := JsonHelper.GetValueAsDateTime(JResponse, 'data.productUpdate.product.updatedAt');
    end;

    internal procedure UpdateProductStatus(ShopifyProduct: Record "Shpfy Product"; Status: Enum "Shpfy Product Status")
    var
        JResponse: JsonToken;
        GraphQuery: TextBuilder;
    begin
        GraphQuery.Append('{"query":"mutation {productUpdate(input: {id: \"gid://shopify/Product/');
        GraphQuery.Append(Format(ShopifyProduct.Id));
        GraphQuery.Append('\"');
        if ShopifyProduct.Status <> Status then begin
            GraphQuery.Append(', status: ');
            GraphQuery.Append(ConvertToProductStatus(Status));
        end;
        GraphQuery.Append('}) ');
        GraphQuery.Append('{product {id}, userErrors {field, message}}');
        GraphQuery.Append('}"}');

        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
    end;

    /// <summary> 
    /// Update Shopify Product Fields.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type record "Shopify Product".</param>
    /// <param name="JProduct">Parameter of type JsonObject.</param>
    /// <returns>Return variable "Result" of type Boolean.</returns>
    internal procedure UpdateShopifyProductFields(var ShopifyProduct: record "Shpfy Product"; JProduct: JsonObject) Result: Boolean
    var
        MetafieldAPI: Codeunit "Shpfy Metafield API";
        UpdatedAt: DateTime;
        JMetafields: JsonArray;
    begin
        UpdatedAt := JsonHelper.GetValueAsDateTime(JProduct, 'updatedAt');
        if UpdatedAt < ShopifyProduct."Updated At" then
            exit(false);

        Result := true;
        ShopifyProduct."Updated At" := UpdatedAt;
        ShopifyProduct."Created At" := JsonHelper.GetValueAsDateTime(JProduct, 'createdAt');
        ShopifyProduct."Has Variants" := not JsonHelper.GetValueAsBoolean(JProduct, 'hasOnlyDefaultVariant');
#pragma warning disable AA0139
        ShopifyProduct.Description := JsonHelper.GetValueAsText(JProduct, 'description', MaxStrLen(ShopifyProduct.Description));
#pragma warning restore AA0139
        ShopifyProduct.SetDescriptionHtml(JsonHelper.GetValueAsText(JProduct, 'descriptionHtml'));
#pragma warning disable AA0139
        ShopifyProduct."Preview URL" := JsonHelper.GetValueAsText(JProduct, 'onlineStorePreviewUrl', MaxStrLen(ShopifyProduct."Preview URL"));
        ShopifyProduct.URL := JsonHelper.GetValueAsText(JProduct, 'onlineStoreUrl', MaxStrLen(ShopifyProduct.URL));
        ShopifyProduct."Product Type" := JsonHelper.GetValueAsText(JProduct, 'productType', MaxStrLen(ShopifyProduct."Product Type"));
#pragma warning restore AA0139
        ShopifyProduct.UpdateTags(JsonHelper.GetArrayAsText(JProduct, 'tags'));
#pragma warning disable AA0139        
        ShopifyProduct.Title := JsonHelper.GetValueAsText(JProduct, 'title', MaxStrLen(ShopifyProduct.Title));
        ShopifyProduct.Vendor := JsonHelper.GetValueAsText(JProduct, 'vendor', MaxStrLen(ShopifyProduct.Vendor));
        ShopifyProduct."SEO Description" := JsonHelper.GetValueAsText(JProduct, 'seo.description', MaxStrLen(ShopifyProduct."SEO Description"));
        ShopifyProduct."SEO Title" := JsonHelper.GetValueAsText(JProduct, 'seo.title', MaxStrLen(ShopifyProduct."SEO Title"));
#pragma warning restore AA0139
        ShopifyProduct.Status := ConvertToProductStatus(JsonHelper.GetValueAsText(JProduct, 'status'));
        ShopifyProduct.Modify(false);

        if JsonHelper.GetJsonArray(JProduct, JMetafields, 'metafields.edges') then
            MetafieldAPI.UpdateMetafieldsFromShopify(JMetafields, Database::"Shpfy Product", ShopifyProduct.Id);
    end;

    local procedure ConvertToProductStatus(Value: Text): Enum "Shpfy Product Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Product Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Product Status".FromInteger(Enum::"Shpfy Product Status".Ordinals().Get(Enum::"Shpfy Product Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Product Status"::Active);
    end;

    local procedure ConvertToProductStatus(Value: Enum "Shpfy Product Status"): Text
    begin
        exit(Value.Names.Get(Value.Ordinals.IndexOf(Value.AsInteger())).ToUpper());
    end;

    /// <summary>
    /// Gets all the Product Options for a product.
    /// </summary>
    /// <param name="ShopifyProductId">Shopify product ID for which the options are to be retrieved.</param>
    /// <returns>Dictionary of option IDs and option names.</returns>
    internal procedure GetProductOptions(ShopifyProductId: BigInteger) Options: Dictionary of [text, Text]
    var
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
        JOptions: JsonArray;
        JOption: JsonToken;
    begin
        Parameters.Add('ProductId', Format(ShopifyProductId));
        JResponse := CommunicationMgt.ExecuteGraphQL(Enum::"Shpfy GraphQL Type"::GetProductOptions, Parameters);

        JsonHelper.GetJsonArray(JResponse, JOptions, 'data.product.options');
        foreach JOption in JOptions do
            Options.Add(JsonHelper.GetValueAsText(JOption, 'id'), JsonHelper.GetValueAsText(JOption, 'name'));
    end;
}