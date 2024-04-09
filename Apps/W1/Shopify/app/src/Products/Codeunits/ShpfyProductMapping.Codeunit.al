namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Purchases.Vendor;

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
        if ShopifyProduct.FindSet(true) then
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
        if ShopifyVariant.FindSet(true) then
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
        MappingResult: Boolean;
        Direction: enum "Shpfy Mapping Direction";
    begin
        SetShop(ShopifyProduct."Shop Code");
        Direction := Direction::ShopifyToBC;
        if IsNullGuid(ShopifyProduct."Item SystemId") or (ShopifyProduct."Has Variants" and IsNullGuid(ShopifyVariant."Item Variant SystemId") and not ShopifyVariant."Mapped By Item") then begin
#if not CLEAN24
            ProductEvents.OnBeforeFindMapping(Direction, ShopifyProduct, ShopifyVariant, Item, ItemVariant, Handled);
#endif
            ProductEvents.OnBeforeFindProductMapping(Direction, ShopifyProduct, ShopifyVariant, Item, ItemVariant, Handled);
            if Handled then
                MappingResult := true
            else
                MappingResult := DoFindMapping(Direction, ShopifyProduct, ShopifyVariant, Item, ItemVariant);
            if MappingResult then
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
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
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
                                if StrLen(ShopifyVariant.SKU) <= MaxStrLen(FindItem."No.") then
                                    if FindItem.Get(ShopifyVariant.SKU) then begin
                                        Item := FindItem;
                                        exit(true);
                                    end;
                            Shop."SKU Mapping"::"Vendor Item No.":
                                if StrLen(ShopifyVariant.SKU) <= MaxStrLen(ItemVendor."Vendor Item No.") then begin
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
                                                Founded := ItemReferenceMgt.FindByReference(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), "Item Reference Type"::Vendor, CopyStr(ShopifyVariant."Option 1 Value", 1, 10), ItemNo, VariantCode);
                                            2:
                                                Founded := ItemReferenceMgt.FindByReference(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), "Item Reference Type"::Vendor, CopyStr(ShopifyVariant."Option 2 Value", 1, 10), ItemNo, VariantCode);
                                            3:
                                                Founded := ItemReferenceMgt.FindByReference(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), "Item Reference Type"::Vendor, CopyStr(ShopifyVariant."Option 3 Value", 1, 10), ItemNo, VariantCode);
                                            else
                                                Founded := ItemReferenceMgt.FindByReference(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), "Item Reference Type"::Vendor, '', ItemNo, VariantCode);
                                        end
                                    else
                                        Founded := ItemReferenceMgt.FindByReference(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), "Item Reference Type"::Vendor, '', ItemNo, VariantCode);
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
                            Shop."SKU Mapping"::"Variant Code":
                                if StrLen(ShopifyVariant.SKU) <= MaxStrLen(FindItemVariant.Code) then begin
                                    FindItemVariant.SetRange(Code, ShopifyVariant.SKU.ToUpper());
                                    if FindItemVariant.FindFirst() then begin
                                        ItemVariant := FindItemVariant;
                                        Item.Get(ItemVariant."Item No.");
                                        exit(true);
                                    end;
                                end;
                            Shop."SKU Mapping"::"Item No. + Variant Code":
                                begin
                                    Codes := ShopifyVariant.SKU.Split(Shop."SKU Field Separator");
                                    Case Codes.Count of
                                        1:
                                            begin
                                                CodeNo := Codes.Get(1);
                                                if StrLen(CodeNo) <= MaxStrLen(FindItem."No.") then
                                                    if FindItem.Get(CodeNo) then begin
                                                        Item := FindItem;
                                                        exit(true);
                                                    end;
                                            end;
                                        2:
                                            begin
                                                CodeNo := Codes.Get(1);
                                                if StrLen(CodeNo) <= MaxStrLen(FindItem."No.") then
                                                    if FindItem.Get(CodeNo) then begin
                                                        Item := FindItem;
                                                        CodeNo := Codes.Get(2);
                                                        if StrLen(CodeNo) <= MaxStrLen(FindItemVariant.Code) then
                                                            if FindItemVariant.Get(Item."No.", CodeNo) then begin
                                                                ItemVariant := FindItemVariant;
                                                                exit(true);
                                                            end;
                                                    end;
                                            end;
                                    end;
                                end;
                            Shop."SKU Mapping"::"Bar Code":
                                begin
                                    if ShopifyProduct."Has Variants" then
                                        case ShopifyVariant."UoM Option Id" of
                                            1:
                                                Founded := ItemReferenceMgt.FindByBarcode(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 1 Value", 1, 10), ItemNo, VariantCode);
                                            2:
                                                Founded := ItemReferenceMgt.FindByBarcode(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 2 Value", 1, 10), ItemNo, VariantCode);
                                            3:
                                                Founded := ItemReferenceMgt.FindByBarcode(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 3 Value", 1, 10), ItemNo, VariantCode);
                                            else
                                                Founded := ItemReferenceMgt.FindByBarcode(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), '', ItemNo, VariantCode);
                                        end
                                    else
                                        Founded := ItemReferenceMgt.FindByBarcode(CopyStr(ShopifyVariant.SKU.ToUpper(), 1, 50), '', ItemNo, VariantCode);
                                    if Founded then
                                        if FindItem.Get(ItemNo) then begin
                                            Item := FindItem;
                                            if ShopifyProduct."Has Variants" then
                                                if (VariantCode <> '') and FindItemVariant.Get(Item."No.", VariantCode) then begin
                                                    ItemVariant := FindItemVariant;
                                                    exit(true);
                                                end else
                                                    exit(true);
                                        end;
                                end;
                        end;
                    if Item."No." <> '' then
                        if Founded or (ItemVariant.Code <> '') then
                            Found := true
                        else
                            Found := (not ShopifyProduct."Has Variants") or ((ShopifyVariant."UoM Option Id" = 1) and (ShopifyVariant."Option 2 Name" = ''));
                    if not Found then
                        if ShopifyProduct."Has Variants" then
                            case ShopifyVariant."UoM Option Id" of
                                1:
                                    Found := ItemReferenceMgt.FindByBarcode(CopyStr(ShopifyVariant.BarCode.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 1 Value", 1, 10), ItemNo, VariantCode);
                                2:
                                    Found := ItemReferenceMgt.FindByBarcode(CopyStr(ShopifyVariant.BarCode.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 2 Value", 1, 10), ItemNo, VariantCode);
                                3:
                                    Found := ItemReferenceMgt.FindByBarcode(CopyStr(ShopifyVariant.BarCode.ToUpper(), 1, 50), CopyStr(ShopifyVariant."Option 3 Value", 1, 10), ItemNo, VariantCode);
                                else
                                    Found := ItemReferenceMgt.FindByBarcode(CopyStr(ShopifyVariant.BarCode.ToUpper(), 1, 50), '', ItemNo, VariantCode);
                            end
                        else
                            Found := ItemReferenceMgt.FindByBarcode(CopyStr(ShopifyVariant.BarCode.ToUpper(), 1, 50), '', ItemNo, VariantCode);
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