/// <summary>
/// Codeunit Shpfy Sync Product Image (ID 30184).
/// </summary>
codeunit 30184 "Shpfy Sync Product Image"
{
    Access = Internal;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    begin
        SetShop(Rec);
        case Shop."Sync Item Images" of
            Shop."Sync Item Images"::"To Shopify":
                ExportImages();
            Shop."Sync Item Images"::"From Shopify":
                ImportImages();
        end;
    end;

    var
        Shop: Record "Shpfy Shop";
        ImageExport: Codeunit "Shpfy Product Image Export";

    /// <summary> 
    /// Export Images.
    /// </summary>
    local procedure ExportImages()
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        ShopifyProduct.SetRange("Shop Code", Shop.Code);
        if ShopifyProduct.FindSet() then
            repeat
                Commit();
                if ImageExport.Run(ShopifyProduct) then;
            until ShopifyProduct.Next() = 0;
    end;

    /// <summary> 
    /// Import Images.
    /// </summary>
    local procedure ImportImages()
    var
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ProductApi: Codeunit "Shpfy Product API";
        VariantApi: Codeunit "Shpfy Variant API";
        ImageId: BigInteger;
        Id: BigInteger;
        Images: Dictionary of [BigInteger, Dictionary of [BigInteger, Text]];
        ImageData: Dictionary of [BigInteger, Text];
    begin
        ProductApi.SetShop(Shop);
        ProductApi.RetrieveShopifyProductImages(Images);
        foreach Id in Images.Keys do
            if ShopifyProduct.Get(Id) and Item.GetBySystemId(ShopifyProduct."Item SystemId") then begin
                ImageData := Images.Get(Id);
                foreach ImageId in ImageData.Keys do
                    if ImageId <> ShopifyProduct."Image Id" then
                        if UpdateItemImage(Item, ImageData.Get(ImageId)) then begin
                            ShopifyProduct."Image Id" := ImageId;
                            ShopifyProduct.Modify();
                        end;
            end;

        VariantApi.SetShop(Shop);
        Clear(Images);
        VariantApi.RetrieveShopifyProductVaraintImages(Images);
        foreach Id in Images.Keys do
            if ShopifyVariant.Get(Id) and Item.GetBySystemId(ShopifyVariant."Item SystemId") then begin
                ImageData := Images.Get(Id);
                foreach ImageId in ImageData.Keys do
                    if ImageId <> ShopifyVariant."Image Id" then
                        if UpdateItemImage(Item, ImageData.Get(ImageId)) then begin
                            ShopifyVariant."Image Id" := ImageId;
                            ShopifyVariant.Modify();
                        end;
            end;

    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        ImageExport.SetShop(Shop);
    end;

    /// <summary> 
    /// Update Item Image.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ImageUrl">Parameter of type Text.</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure UpdateItemImage(Item: Record Item; ImageUrl: Text): Boolean
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Stream: InStream;
    begin
        if Client.Get(ImageUrl, Response) then begin
            Response.Content.ReadAs(Stream);
            Clear(Item.Picture);
            Item.Picture.ImportStream(Stream, Item.Description);
            Item.Modify();
        end;
    end;
}