/// <summary>
/// Codeunit Shpfy Product Mapping (ID 30181).
/// </summary>
codeunit 30181 "Shpfy Product Mapping"
{
    Access = Internal;
    Permissions =
        tabledata Item = r,
        tabledata "Item Reference" = r,
        tabledata "Item Variant" = r,
        tabledata "Item Vendor" = r,
        tabledata Vendor = r;

    var
        Shop: Record "Shpfy Shop";
        ProductApi: Codeunit "Shpfy Product API";
        ProductEvents: Codeunit "Shpfy Product Events";
        SyncProducts: Codeunit "Shpfy Sync Products";

    /// <summary>
    /// FindMappings.
    /// </summary>
    internal procedure FindMappings()
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        if ShopifyProduct.FindSet(true, false) then
            repeat
                FindMapping(ShopifyProduct);
            until ShopifyProduct.Next() = 0;
    end;

    /// <summary>
    /// FindMapping.
    /// </summary>
    /// <param name="ShopifyProduct">VAR Record "Shopify Product".</param>
    internal procedure FindMapping(var ShopifyProduct: Record "Shpfy Product")
    var
        ShopifyVariant: Record "Shpfy Variant";
    begin
        ShopifyVariant.SetRange("Product Id", ShopifyProduct.Id);
        if ShopifyVariant.FindSet(true, false) then
            repeat
                FindMapping(ShopifyProduct, ShopifyVariant);
            until ShopifyVariant.Next() = 0;
    end;

    /// <summary> 
    /// Find Mapping.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <returns>Return variable "Result" of type Boolean.</returns>
    internal procedure FindMapping(var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant") Result: Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Handled: Boolean;
        Direction: enum "Shpfy Mapping Direction";
    begin
        SetShop(ShopifyProduct."Shop Code");
        Direction := Direction::ShopifyToBC;
        if Handled then begin
            if not IsNullGuid(ShopifyProduct."Item SystemId") then
                if ShopifyProduct."Has Variants" then
                    exit(((not IsNullGuid(ShopifyVariant."Item Variant SystemId")) or (ShopifyVariant."Mapped By Item" and (not IsNullGuid(ShopifyVariant."Item SystemId")))) or ((ShopifyVariant."UoM Option Id" = 1) and (ShopifyVariant."Option 2 Name" = '')))
                else
                    exit(true);
        end else
            if IsNullGuid(ShopifyProduct."Item SystemId") or (ShopifyProduct."Has Variants" and IsNullGuid(ShopifyVariant."Item Variant SystemId") and not ShopifyVariant."Mapped By Item") then begin
                ProductEvents.OnBeforeFindMapping(Direction, ShopifyProduct, ShopifyVariant, Item, ItemVariant, Handled);
                if DoFindMapping(Direction, ShopifyProduct, ShopifyVariant, Item, ItemVariant) then begin
                    ProductEvents.OnAfterFindMapping(Direction, ShopifyProduct, ShopifyVariant, Item, ItemVariant);
                    if Item."No." <> '' then begin
                        if IsNullGuid(ShopifyProduct."Item SystemId") then begin
                            ShopifyProduct."Item SystemId" := Item.SystemId;
                            ShopifyProduct.Modify();
                        end;
                        ShopifyVariant."Item SystemId" := Item.SystemId;
                        if ItemVariant.Code <> '' then begin
                            ShopifyVariant."Item Variant SystemId" := ItemVariant.SystemId;
                            ShopifyVariant."Mapped By Item" := false;
                        end else begin
                            Clear(ShopifyVariant."Item Variant SystemId");
                            ShopifyVariant."Mapped By Item" := true;
                        end;
                        ShopifyVariant.Modify();
                        exit(ShopifyVariant."Mapped By Item" or (not ShopifyProduct."Has Variants") OR (not IsNullGuid(ShopifyVariant."Item Variant SystemId")) or ((ShopifyVariant."UoM Option Id" = 1) and (ShopifyVariant."Option 2 Name" = '')));
                    end;
                end;
            end else
                exit(true);
    end;

    /// <summary> 
    /// Do Find Mapping.
    /// </summary>
    /// <param name="Direction">Parameter of type enum "Shopify Mapping Direction".</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <returns>Return variable "Found" of type Boolean.</returns>
    local procedure DoFindMapping(Direction: enum "Shpfy Mapping Direction"; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; var ItemVariant: Record "Item Variant") Found: Boolean
    var
        FindItem: Record Item;
        FindItemVariant: Record "Item Variant";
        ItemVendor: Record "Item Vendor";
        Vendor: Record Vendor;
        ItemRefMgt: Codeunit "Shpfy Item Reference Mgt.";
        Founded: Boolean;
        VariantCode: Code[10];
        ItemNo: Code[20];
        Codes: List of [Text];
        CodeNo: Text;
    begin
        case Direction of
            Direction::ShopifyToBC:
                begin
                    Clear(Item);
                    Clear(ItemVariant);
                    if not IsNullGuid(ShopifyProduct."Item SystemId") then
                        if FindItem.GetBySystemId(ShopifyProduct."Item SystemId") then
                            Item := FindItem
                        else
                            Clear(ShopifyProduct.SystemId);
                    if (ShopifyVariant.SKU <> '') then
                        case Shop."SKU Mapping" of
                            Shop."SKU Mapping"::"Item No.":
                                if FindItem.Get(ShopifyVariant.SKU) then begin
                                    Item := FindItem;
                                    exit(true);
                                end;
                            Shop."SKU Mapping"::"Vendor Item No.":
                                begin
                                    ItemVendor.SetRange("Vendor Item No.", ShopifyVariant.SKU);
                                    if ShopifyProduct.Vendor <> '' then
                                        if StrLen(ShopifyProduct.Vendor) <= MaxStrLen(Vendor."No.") then begin
                                            if Vendor.Get(ShopifyProduct.Vendor) then
                                                ItemVendor.SetRange("Vendor No.", Vendor."No.");
                                        end else begin
                                            Vendor.SetFilter("Name", '@' + ShopifyProduct.Vendor);
                                            if Vendor.FindFirst() then
                                                ItemVendor.SetRange("Vendor No.", Vendor."No.")
                                            else begin
                                                Clear(Vendor);
                                                Vendor.SetFilter("Search Name", '@' + ShopifyProduct.Vendor);
                                                if Vendor.FindFirst() then
                                                    ItemVendor.SetRange("Vendor No.", Vendor."No.");
                                            end;
                                        end;
                                    if ItemVendor.FindFirst() then
                                        if FindItem.Get(ItemVendor."Item No.") then begin
                                            Item := FIndItem;
                                            if ShopifyProduct."Has Variants" then
                                                if (ItemVendor."Variant Code" <> '') and FindItemVariant.Get(Item."No.", ItemVendor."Variant Code") then begin
                                                    ItemVariant := FindItemVariant;
                                                    exit(true);
                                                end
                                                else
                                                    exit(true);
                                        end;
                                    Clear(Founded);
                                    if ShopifyProduct."Has Variants" then
                                        case ShopifyVariant."UoM Option Id" of
                                            1:
                                                founded := ItemRefMgt.FindByReference(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), "Item Reference Type"::Vendor, CopyStr(ShopifyVariant."Option 1 Value", 1, 10), ItemNo, VariantCode);
                                            2:
                                                founded := ItemRefMgt.FindByReference(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), "Item Reference Type"::Vendor, CopyStr(ShopifyVariant."Option 2 Value", 1, 10), ItemNo, VariantCode);
                                            3:
                                                founded := ItemRefMgt.FindByReference(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), "Item Reference Type"::Vendor, CopyStr(ShopifyVariant."Option 3 Value", 1, 10), ItemNo, VariantCode);
                                            else
                                                founded := ItemRefMgt.FindByReference(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), "Item Reference Type"::Vendor, '', ItemNo, VariantCode);
                                        end;
                                    if Founded then
                                        if FindItem.Get(ItemNo) then begin
                                            Item := FindItem;
                                            if ShopifyProduct."Has Variants" then
                                                if (VariantCode <> '') and FindItemVariant.Get(Item."No.", VariantCode) then begin
                                                    ItemVariant := FindItemVariant;
                                                    exit(true);
                                                end
                                                else
                                                    exit(true);
                                        end;
                                end;
                            Shop."SKU Mapping"::"Item No. + Variant Code":
                                begin
                                    Codes := ShopifyVariant.SKU.Split(Shop."SKU Field Separator");
                                    Case Codes.Count of
                                        1:
                                            if Codes.Get(1, CodeNo) and FindItem.Get(CodeNo) then begin
                                                Item := FindItem;
                                                exit(true);
                                            end;
                                        2:
                                            if Codes.Get(1, CodeNo) and FindItem.Get(CodeNo) then begin
                                                Item := FindItem;
                                                if Codes.Get(2, CodeNo) and FindItemVariant.Get(Item."No.", CodeNo) then begin
                                                    ItemVariant := FindItemVariant;
                                                    exit(true);
                                                end;
                                            end;
                                    end;
                                end;
                            Shop."SKU Mapping"::"Bar Code":
                                begin
                                    if ShopifyProduct."Has Variants" then
                                        case ShopifyVariant."UoM Option Id" of
                                            1:
                                                founded := ItemRefMgt.FindByBarcode(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 1 Value", 1, 10), ItemNo, VariantCode);
                                            2:
                                                founded := ItemRefMgt.FindByBarcode(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 2 Value", 1, 10), ItemNo, VariantCode);
                                            3:
                                                founded := ItemRefMgt.FindByBarcode(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 3 Value", 1, 10), ItemNo, VariantCode);
                                            else
                                                founded := ItemRefMgt.FindByBarcode(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), '', ItemNo, VariantCode);
                                        end;
                                    if Founded then
                                        if FindItem.Get(ItemNo) then begin
                                            Item := FindItem;
                                            if ShopifyProduct."Has Variants" then
                                                if (VariantCode <> '') and FindItemVariant.Get(Item."No.", VariantCode) then begin
                                                    ItemVariant := FindItemVariant;
                                                    exit(true);
                                                end
                                                else
                                                    exit(true);
                                        end;
                                end;
                        end;
                    if Item."No." <> '' then
                        if founded or (ItemVariant.Code <> '') then
                            Found := true
                        else
                            Found := (not ShopifyProduct."Has Variants") or ((ShopifyVariant."UoM Option Id" = 1) and (ShopifyVariant."Option 2 Name" = ''));
                    if not Found then
                        if ShopifyProduct."Has Variants" then
                            case ShopifyVariant."UoM Option Id" of
                                1:
                                    Found := ItemRefMgt.FindByBarcode(CopyStr(ShopifyVariant.BarCode.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 1 Value", 1, 10), ItemNo, VariantCode);
                                2:
                                    Found := ItemRefMgt.FindByBarcode(CopyStr(ShopifyVariant.BarCode.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 2 Value", 1, 10), ItemNo, VariantCode);
                                3:
                                    Found := ItemRefMgt.FindByBarcode(CopyStr(ShopifyVariant.BarCode.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 3 Value", 1, 10), ItemNo, VariantCode);
                                else
                                    Found := ItemRefMgt.FindByBarcode(CopyStr(ShopifyVariant.BarCode.ToUpper(), 1, 50), '', ItemNo, VariantCode);
                            end;
                    if Found then
                        if FindItem.Get(ItemNo) then begin
                            Item := FindItem;
                            if ShopifyProduct."Has Variants" then
                                if (VariantCode <> '') and FindItemVariant.Get(Item."No.", VariantCode) then
                                    ItemVariant := FindItemVariant;
                        end;
                end;
        end;
    end;

    /// <summary> 
    /// Set Shop.
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
        SyncProducts.SetShop(Shop);
        ProductApi.SetShop(Shop);
    end;

}