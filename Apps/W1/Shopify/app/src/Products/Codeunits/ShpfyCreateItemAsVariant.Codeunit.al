namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

codeunit 30105 "Shpfy Create Item As Variant"
{
    TableNo = Item;

    var
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        CreateProduct: Codeunit "Shpfy Create Product";
        VariantApi: Codeunit "Shpfy Variant API";
        ProductApi: Codeunit "Shpfy Product API";
        RenameProductOption: Boolean;
        DefaultVariantId: BigInteger;

    trigger OnRun()
    begin
        CreateVariantFromItem(Rec);
    end;

    /// <summary>
    /// Creates a variant from a given item and adds it to the parent product.
    /// </summary>
    /// <param name="Item">The item to be added as a variant.</param>
    internal procedure CreateVariantFromItem(var Item: Record "Item")
    var
        TempShopifyVariant: Record "Shpfy Variant" temporary;
    begin
        CreateProduct.CreateTempShopifyVariantFromItem(Item, TempShopifyVariant);
        TempShopifyVariant."Product Id" := ShopifyProduct."Id";
        TempShopifyVariant.Title := Item.Description;
        TempShopifyVariant."Option 1 Name" := 'Item';
        TempShopifyVariant."Option 1 Value" := Item."No.";

        if VariantApi.AddProductVariant(TempShopifyVariant) then begin
            ShopifyProduct."Has Variants" := true;
            ShopifyProduct.Modify(true);
        end;
    end;

    /// <summary>
    /// Checks if the product has only the default variant assigned and prepares the variant for deletion.
    /// </summary>
    internal procedure CheckIfProductHasDefaultVariant()
    var
        ProductVariantIds: Dictionary of [BigInteger, DateTime];
    begin
        if not ShopifyProduct."Has Variants" then begin
            RenameProductOption := true;
            VariantApi.RetrieveShopifyProductVariantIds(ShopifyProduct, ProductVariantIds);
            DefaultVariantId := ProductVariantIds.Keys.Get(1);
        end;
    end;

    /// <summary>
    /// Removes the default variant and renames the option if the product had only the default variant.
    /// </summary>
    internal procedure RemoveDefaultVariantAndRenameOption()
    var
        ShopifyVariant: Record "Shpfy Variant";
        Options: Dictionary of [Text, Text];
    begin
        // If new variants were added to the product that only had the default variant, 
        // we need to remove the default variant from Shopify and BC and rename the option. 
        if RenameProductOption and ShopifyProduct."Has Variants" then begin
            VariantApi.DeleteProductVariant(DefaultVariantId);
            if ShopifyVariant.Get(DefaultVariantId) then
                ShopifyVariant.Delete(true);

            Options := ProductApi.GetProductOptions(ShopifyProduct.Id);
            ProductApi.UpdateProductOption(ShopifyProduct.Id, Options.Keys.Get(1), 'Item');
        end;
    end;

    /// <summary>
    /// Sets the parent product to which the variant will be added.
    /// </summary>
    /// <param name="ShopifyProductId">The parent Shopify product ID.</param>
    internal procedure SetParentProduct(ShopifyProductId: BigInteger)
    begin
        ShopifyProduct.Get(ShopifyProductId);
        SetShop(ShopifyProduct."Shop Code");
    end;

    local procedure SetShop(ShopCode: Code[20])
    begin
        Shop.Get(ShopCode);
        VariantApi.SetShop(Shop);
        ProductApi.SetShop(Shop);
        CreateProduct.SetShop(Shop);
    end;

}