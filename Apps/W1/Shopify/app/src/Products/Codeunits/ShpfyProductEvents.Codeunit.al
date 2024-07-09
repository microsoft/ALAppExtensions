namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

/// <summary>
/// Codeunit Shpfy Product Events (ID 30177).
/// </summary>
codeunit 30177 "Shpfy Product Events"
{
    /// <summary> 
    /// Description for OnAfterSetProductTitle.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="LanguageCode">Parameter of type Code[10].</param>
    /// <param name="Title">Parameter of type Text.</param>
    [InternalEvent(false)]
    internal procedure OnAfterSetProductTitle(Item: Record Item; LanguageCode: Code[10]; var Title: Text)
    begin
    end;

    /// <summary> 
    /// Raised After Create Item.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterCreateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item);
    begin
    end;

    /// <summary> 
    /// Raised After Create Item Variant.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterCreateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant");
    begin
    end;

    /// <summary> 
    /// Raised After Temp Shopify Product and Variant are created.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="ShopifyTag">Parameter of type Record "Shopify Tag".</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterCreateTempShopifyProduct(Item: Record Item; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var ShopifyTag: Record "Shpfy Tag")
    begin
    end;

    /// <summary> 
    /// Raised After Create Product Body Html.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ProductBodyHtml">Parameter of type Text.</param>
    /// <param name="LanguageCode">Parameter of type Code[10].</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterCreateProductBodyHtml(ItemNo: Code[20]; ShopifyShop: Record "Shpfy Shop"; var ProductBodyHtml: Text; LanguageCode: Code[10])
    begin
    end;

#pragma warning disable AS0027
    /// <summary> 
    /// Raised After Find Item Template.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="TemplateCode">Parameter of type Code[20].</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterFindItemTemplate(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var TemplateCode: Code[20]);
    begin
    end;
#pragma warning restore AS0027

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetCommaSeparatedTags(ShopifyProduct: Record "Shpfy Product"; var Tags: Text)
    begin
    end;

    /// <summary> 
    /// Description for OnAfterGetBarcode.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="VariantCode">Parameter of type Code[10].</param>
    /// <param name="UoM">Parameter of type Code[10].</param>
    /// <param name="Barcode">Parameter of type Text.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetBarcode(ItemNo: Code[20]; VariantCode: Code[10]; UoM: Code[10]; var Barcode: Text)
    begin
    end;

    /// <summary> 
    /// Raised Before Create Item.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCreateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; var Handled: Boolean);
    begin
    end;

    /// <summary> 
    /// Raised Before Create Item Variant.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCreateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant"; var Handled: Boolean);
    begin
    end;

    /// <summary> 
    /// Raised Before Create Item Variant Code.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariantCode">Parameter of type Code[10].</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCreateItemVariantCode(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariantCode: Code[10]; var Handled: Boolean);
    begin
    end;

    /// <summary> 
    /// Raised Before Create Product Body Html.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ProductBodyHtml">Parameter of type Text.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    /// <param name="LanguageCode">Parameter of type Code[10].</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCreateProductBodyHtml(ItemNo: Code[20]; ShopifyShop: Record "Shpfy Shop"; var ProductBodyHtml: Text; var Handled: Boolean; LanguageCode: Code[10])
    begin
    end;

#pragma warning disable AS0027
    /// <summary> 
    /// Raised Before Find Item Template.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="TemplateCode">Parameter of type Code[20].</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindItemTemplate(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var TemplateCode: Code[20]; var Handled: Boolean);
    begin
    end;
#pragma warning restore AS0027

    /// <summary> 
    /// Description for OnBeforGetBarcode.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="VariantCode">Parameter of type Code[10].</param>
    /// <param name="UoM">Parameter of type Code[10].</param>
    /// <param name="Barcode">Parameter of type Text.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforGetBarcode(ItemNo: Code[20]; VariantCode: Code[10]; UoM: Code[10]; var Barcode: Text; var Handled: Boolean)
    begin
    end;

    /// <summary> 
    /// Description for OnBeforSetProductTitle.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="LanguageCode">Parameter of type Code[10].</param>
    /// <param name="Title">Parameter of type Text.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforSetProductTitle(Item: Record Item; LanguageCode: Code[10]; var Title: Text; var Handled: Boolean)
    begin
    end;

#if not CLEAN24
    /// <summary> 
    /// Raised Before Find Mapping.
    /// </summary>
    /// <param name="Direction">Parameter of type enum "Shopify Mapping Direction".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [Obsolete('This event is deprecated. Please use OnBeforeFindProductMapping', '24.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindMapping(Direction: enum "Shpfy Mapping Direction"; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; ItemVariant: Record "Item Variant"; var Handled: Boolean);
    begin
    end;
#endif

    /// <summary> 
    /// Raised Before Find Mapping.
    /// </summary>
    /// <param name="Direction">Parameter of type enum "Shopify Mapping Direction".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindProductMapping(Direction: Enum "Shpfy Mapping Direction"; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; var ItemVariant: Record "Item Variant"; var Handled: Boolean);
    begin
    end;

    /// <summary> 
    /// Raised After Calculate Unit Price.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="VariantCode">Parameter of type Code[20].</param>
    /// <param name="UnitOfMeasure">Parameter of type Code[20].</param>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="Catalog">Parameter of type Record "Shopify Catalog".</param>
    /// <param name="UnitCost">Parameter of type Decimal.</param>
    /// <param name="Price">Parameter of type Decimal.</param>
    /// <param name="ComparePrice">Parameter of type Decimal.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterCalculateUnitPrice(Item: Record Item; VariantCode: Code[20]; UnitOfMeasure: Code[20]; ShopifyShop: Record "Shpfy Shop"; Catalog: Record "Shpfy Catalog"; var UnitCost: Decimal; var Price: Decimal; var ComparePrice: Decimal)
    begin
    end;

    /// <summary> 
    /// Raised Before Calculate Unit Price.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="VariantCode">Parameter of type Code[20].</param>
    /// <param name="UnitOfMeasure">Parameter of type Code[20].</param>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="Catalog">Parameter of type Record "Shopify Catalog".</param>
    /// <param name="UnitCost">Parameter of type Decimal.</param>
    /// <param name="Price">Parameter of type Decimal.</param>
    /// <param name="ComparePrice">Parameter of type Decimal.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCalculateUnitPrice(Item: Record Item; VariantCode: Code[20]; UnitOfMeasure: Code[20]; ShopifyShop: Record "Shpfy Shop"; Catalog: Record "Shpfy Catalog"; var UnitCost: Decimal; var Price: Decimal; var ComparePrice: Decimal; var Handled: Boolean)
    begin
    end;

    /// <summary> 
    /// Raised After Update Item.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item);
    begin
    end;

    /// <summary> 
    /// Raised After Update Item Variant.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant");
    begin
    end;

    /// <summary> 
    /// Raised Before Update Item.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUpdateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; var Handled: Boolean);
    begin
    end;

    /// <summary> 
    /// Raised Before Update Item Variant.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUpdateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant"; var Handled: Boolean);
    begin
    end;

    /// <summary> 
    /// Raised Before Send Create Shopify Product.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSendCreateShopifyProduct(ShopifyShop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var ShpfyTag: Record "Shpfy Tag")
    begin
    end;

    /// <summary> 
    /// Raised Before Send Update Shopify Product.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="xShopifyProduct">Parameter of type Record "Shopify Product".</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSendUpdateShopifyProduct(ShopifyShop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; xShopifyProduct: Record "Shpfy Product")
    begin
    end;

    /// <summary> 
    /// Raised Before Send Add Shopify Product Variant.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSendAddShopifyProductVariant(ShopifyShop: Record "Shpfy Shop"; var ShopifyVariant: Record "Shpfy Variant")
    begin
    end;

    /// <summary> 
    /// Raised Before Send Update Shopify Product Variant.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="xShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSendUpdateShopifyProductVariant(ShopifyShop: Record "Shpfy Shop"; var ShopifyVariant: Record "Shpfy Variant"; xShopifyVariant: Record "Shpfy Variant")
    begin
    end;

    /// <summary> 
    /// Raised Before Modify on Items.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shpfy Product".</param>
    /// <param name="Item">Parameter of type Record "Item".</param>
    /// <param name="IsModified">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnDoUpdateItemBeforeModify(var ShopifyShop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; var Item: Record Item; var IsModifiedByEvent: Boolean);
    begin
    end;

    /// <summary> 
    /// Raised Before Modify Items Variant.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shpfy Variant".</param>
    /// <param name="ItemVariant">Parameter of type Record "Shpfy Variant".</param>
    /// <param name="IsModified">Parameter of type Boolean.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnDoUpdateItemVariantBeforeModify(var ShopifyShop: Record "Shpfy Shop"; var ShopifyVariant: Record "Shpfy Variant"; var ItemVariant: Record "Item Variant"; var IsModifiedByEvent: Boolean);
    begin
    end;

    /// <summary> 
    /// Raised After Modify Item Picture.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ImageUrl">Parameter of type Text.</param>
    /// <param name="InStream">Parameter of type InStream.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateItemPicture(var Item: Record Item; ImageUrl: Text; InStream: InStream)
    begin
    end;

    /// <summary> 
    /// Raised After Shopify Product fields are filled from Business Central Item. These fields are sent to Shopify when creating or updating a product.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ShopifyProduct">Parameter of Record "Shopify Product".</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterFillInShopifyProductFields(Item: Record Item; var ShopifyProduct: Record "Shpfy Product")
    begin
    end;
}