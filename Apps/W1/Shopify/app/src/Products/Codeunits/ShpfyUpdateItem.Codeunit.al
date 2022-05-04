/// <summary>
/// Codeunit Shpfy Update Item (ID 30188).
/// </summary>
codeunit 30188 "Shpfy Update Item"
{
    Access = Internal;
    Permissions =
        tabledata Item = rim,
        tabledata "Item Category" = r,
        tabledata "Item Variant" = rim,
        tabledata Vendor = r;
    TableNo = "Shpfy Variant";

    var
        Shop: Record "Shpfy Shop";
        ProductEvents: Codeunit "Shpfy Product Events";

    trigger OnRun()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ShopifyProduct: Record "Shpfy Product";
        CreateItem: Codeunit "Shpfy Create Item";
        IsHandled: Boolean;
    begin
        if ShopifyProduct.Get(Rec."Product Id") then begin
            SetShop(ShopifyProduct."Shop Code");
            if Item.GetBySystemId(ShopifyProduct."Item SystemId") then begin
                ProductEvents.OnBeforeUpdateItem(Shop, ShopifyProduct, Rec, Item, IsHandled);

                if not IsHandled then
                    if DoUpdateItem(ShopifyProduct, Item) then
                        ProductEvents.OnAfterUpdateItem(Shop, ShopifyProduct, Rec, Item);

                IsHandled := false;
                if (not IsNullGuid(Rec."Item Variant SystemId")) and ItemVariant.GetBySystemId(Rec."Item Variant SystemId") then begin
                    ProductEvents.OnBeforeUpdateItemVariant(Shop, ShopifyProduct, Rec, Item, ItemVariant, IsHandled);
                    if not IsHandled then begin
                        CreateItem.CreateReferences(ShopifyProduct, Rec, Item, ItemVariant);
                        if DoUpdateItemVariant(Rec, ItemVariant) then
                            ProductEvents.OnAfterUpdateItemVariant(Shop, ShopifyProduct, Rec, Item, ItemVariant);
                    end;
                end else begin
                    Clear(ItemVariant);
                    CreateItem.CreateReferences(ShopifyProduct, Rec, Item, ItemVariant);
                end;
            end;
        end;
    end;

    /// <summary> 
    /// Do Update Item.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure DoUpdateItem(var ShopifyProduct: Record "Shpfy Product"; var Item: Record Item): Boolean
    var
        ItemCategory: Record "Item Category";
        Vendor: Record Vendor;
        IsModified: Boolean;
    begin
        if Item.Description <> ShopifyProduct.Title then begin
            IsModified := true;
            Item.Description := ShopifyProduct.Title;
        end;
        if ShopifyProduct."Product Type" <> '' then begin
            ItemCategory.SetFilter(Description, '@' + ShopifyProduct."Product Type");
            if ItemCategory.FindFirst() then
                if Item."Item Category Code" <> ItemCategory.Code then begin
                    IsModified := true;
                    Item."Item Category Code" := ItemCategory.Code;
                end;
        end;
        if ShopifyProduct.Vendor <> '' then begin
            Vendor.SetFilter(Name, '@' + ShopifyProduct.Vendor);
            if Vendor.FindFirst() then
                if Item."Vendor No." <> Vendor."No." then begin
                    IsModified := true;
                    Item."Vendor No." := Vendor."No.";
                end;
        end;
        if IsModified then
            exit(item.Modify());
    end;

    /// <summary> 
    /// Do Update Item Variant.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure DoUpdateItemVariant(ShopifyVariant: Record "Shpfy Variant"; var ItemVariant: Record "Item Variant"): Boolean
    begin
        if ItemVariant.Description <> ShopifyVariant.Title then begin
            ItemVariant.Description := ShopifyVariant.Title;
            exit(ItemVariant.Modify());
        end;
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        if (Code <> '') and (Shop.Code <> Code) then begin
            Clear(Shop);
            Shop.Get(Code);
        end;
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
    end;
}