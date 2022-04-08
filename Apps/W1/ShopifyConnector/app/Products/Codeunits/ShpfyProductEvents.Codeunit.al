/// <summary>
/// Codeunit Shpfy Product Events (ID 30177).
/// </summary>
codeunit 30177 "Shpfy Product Events"
{
    Access = Internal;

    [InternalEvent(false)]
    /// <summary> 
    /// Description for OnAfterSetProductTitle.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="LanguageCode">Parameter of type Code[10].</param>
    /// <param name="Title">Parameter of type Text.</param>
    internal procedure OnAfterSetProductTitle(Item: Record Item; LanguageCode: Code[10]; var Title: Text)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Create Item.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    internal procedure OnAfterCreateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Create Item Variant.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    internal procedure OnAfterCreateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant");
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Create Item Variant Code.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariantCode">Parameter of type Code[10].</param>
    internal procedure OnAfterCreateItemVariantCode(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariantCode: Code[10]);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Create Product Body Html.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ProductBodyHtml">Parameter of type Text.</param>
    internal procedure OnAfterCreateProductBodyHtml(ItemNo: Code[20]; ShopifyShop: Record "Shpfy Shop"; var ProductBodyHtml: Text)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Find Item Template.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="TemplateCode">Parameter of type Code[20].</param>
    internal procedure OnAfterFindItemTemplate(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var TemplateCode: Code[10]);
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnAfterGetCommaSeperatedTags(ShopifyProduct: Record "Shpfy Product"; var Tags: Text)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Description for OnAfterGetBarcode.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="VariantCode">Parameter of type Code[10].</param>
    /// <param name="UoM">Parameter of type Code[10].</param>
    /// <param name="Barcode">Parameter of type Text.</param>
    internal procedure OnAfterGetBarcode(ItemNo: Code[20]; VariantCode: Code[10]; UoM: Code[10]; var Barcode: Text)
    begin
    end;


    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Create Item.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; var Handled: Boolean);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Create Item Variant.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant"; var Handled: Boolean);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Create Item Variant Code.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariantCode">Parameter of type Code[10].</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateItemVariantCode(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariantCode: Code[10]; var Handled: Boolean);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Create Product Body Html.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ProductBodyHtml">Parameter of type Text.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateProductBodyHtml(ItemNo: Code[20]; ShopifyShop: Record "Shpfy Shop"; var ProductBodyHtml: Text; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Find Item Template.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="TemplateCode">Parameter of type Code[20].</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeFindItemTemplate(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var TemplateCode: Code[10]; var Handled: Boolean);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Description for OnBeforGetBarcode.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="VariantCode">Parameter of type Code[10].</param>
    /// <param name="UoM">Parameter of type Code[10].</param>
    /// <param name="Barcode">Parameter of type Text.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforGetBarcode(ItemNo: Code[20]; VariantCode: Code[10]; UoM: Code[10]; var Barcode: Text; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Description for OnBeforSetProductTitle.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="LanguageCode">Parameter of type Code[10].</param>
    /// <param name="Title">Parameter of type Text.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforSetProductTitle(Item: Record Item; LanguageCode: Code[10]; var Title: Text; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Find Mapping.
    /// </summary>
    /// <param name="Direction">Parameter of type enum "Shopify Mapping Direction".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    internal procedure OnAfterFindMapping(Direction: enum "Shpfy Mapping Direction"; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; ItemVariant: Record "Item Variant");
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Find Mapping.
    /// </summary>
    /// <param name="Direction">Parameter of type enum "Shopify Mapping Direction".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeFindMapping(Direction: enum "Shpfy Mapping Direction"; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; ItemVariant: Record "Item Variant"; var Handled: Boolean);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Calculate Unit Price.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="VariantCode">Parameter of type Code[20].</param>
    /// <param name="UnitOfMeasure">Parameter of type Code[20].</param>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="UnitCost">Parameter of type Decimal.</param>
    /// <param name="Price">Parameter of type Decimal.</param>
    /// <param name="ComparePrice">Parameter of type Decimal.</param>
    internal procedure OnAfterCalculateUnitPrice(Item: Record Item; VariantCode: Code[20]; UnitOfMeasure: Code[20]; ShopifyShop: Record "Shpfy Shop"; var UnitCost: Decimal; var Price: Decimal; var ComparePrice: Decimal)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Calculate Unit Price.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="VariantCode">Parameter of type Code[20].</param>
    /// <param name="UnitOfMeasure">Parameter of type Code[20].</param>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="UnitCost">Parameter of type Decimal.</param>
    /// <param name="Price">Parameter of type Decimal.</param>
    /// <param name="ComparePrice">Parameter of type Decimal.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCalculateUnitPrice(Item: Record Item; VariantCode: Code[20]; UnitOfMeasure: Code[20]; ShopifyShop: Record "Shpfy Shop"; var UnitCost: Decimal; var Price: Decimal; var ComparePrice: Decimal; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Update Item.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    internal procedure OnAfterUpdateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Update Item Variant.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    internal procedure OnAfterUpdateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant");
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Update Item.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeUpdateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; var Handled: Boolean);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Update Item Variant.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeUpdateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant"; var Handled: Boolean);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Send Create Shopify Product.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    internal procedure OnBeforeSendCreateShopifyProduct(ShopifyShop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Send Update Shopify Product.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="xShopifyProduct">Parameter of type Record "Shopify Product".</param>
    internal procedure OnBeforeSendUpdateShopifyProduct(ShopifyShop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; xShopifyProduct: Record "Shpfy Product")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Send Add Shopify Product Variant.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    internal procedure OnBeforeSendAddShopifyProductVariant(ShopifyShop: Record "Shpfy Shop"; var ShopifyVariant: Record "Shpfy Variant")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Send Update Shopify Product Variant.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="xShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    internal procedure OnBeforeSendUpdateShopifyProductVariant(ShopifyShop: Record "Shpfy Shop"; var ShopifyVariant: Record "Shpfy Variant"; xShopifyVariant: Record "Shpfy Variant")
    begin
    end;
}