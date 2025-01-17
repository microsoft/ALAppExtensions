namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;
using Microsoft.Foundation.UOM;
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item.Catalog;

/// <summary>
/// Codeunit Shpfy Create Item (ID 30171).
/// </summary>
codeunit 30171 "Shpfy Create Item"
{
    Access = Internal;
    Permissions =
        tabledata Item = rim,
        tabledata "Item Category" = rim,
        tabledata "Item Reference" = rim,
        tabledata "Item Unit of Measure" = rim,
        tabledata "Item Variant" = rim,
        tabledata "Item Vendor" = rim,
        tabledata "Unit of Measure" = rim,
        tabledata Vendor = rim;
    TableNo = "Shpfy Variant";

    var
        Shop: Record "Shpfy Shop";
        FilterMgt: Codeunit "Shpfy Filter Mgt.";
        ProductEvents: Codeunit "Shpfy Product Events";
        TemplateCode: Code[20];

    trigger OnRun()
    var
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        Handled: Boolean;
    begin
        if ShopifyProduct.Get(Rec."Product Id") then begin
            SetShop(ShopifyProduct."Shop Code");
            if IsNullGuid(ShopifyProduct."Item SystemId") or (not Item.GetBySystemId(ShopifyProduct."Item SystemId")) then
                if ExistItem(ShopifyProduct, Rec, Item) then begin
                    ShopifyProduct."Item SystemId" := Item.SystemId;
                    ShopifyProduct.Modify();
                end else begin
                    ProductEvents.OnBeforeCreateItem(Shop, ShopifyProduct, Rec, Item, Handled);
                    if not Handled then
                        DoCreateItem(ShopifyProduct, Rec, Item, true);
                    ShopifyProduct."Item SystemId" := Item.SystemId;
                    ShopifyProduct.Modify();
                    ProductEvents.OnAfterCreateItem(Shop, ShopifyProduct, Rec, Item);
                end;
            case Shop."SKU Mapping" of
                Shop."SKU Mapping"::"Item No. + Variant Code",
                Shop."SKU Mapping"::"Variant Code":
                    begin
                        CreateItemVariant(ShopifyProduct, Rec, Item);
                        CreateItemUnitOfMeasure(Rec, Item);
                    end;
                Shop."SKU Mapping"::"Item No.":
                    if IsNullGuid(Rec."Item SystemId") or (not Item.GetBySystemId(Rec."Item SystemId")) then
                        if ExistItem(ShopifyProduct, Rec, Item) then begin
                            Rec."Item SystemId" := Item.SystemId;
                            Rec.Modify();
                        end else begin
                            ProductEvents.OnBeforeCreateItem(Shop, ShopifyProduct, Rec, Item, Handled);
                            if not Handled then
                                DoCreateItem(ShopifyProduct, Rec, Item, true);
                            ProductEvents.OnAfterCreateItem(Shop, ShopifyProduct, Rec, Item);
                        end;
                Shop."SKU Mapping"::"Vendor Item No.":
                    if IsNullGuid(Rec."Item SystemId") or (not Item.GetBySystemId(Rec."Item SystemId")) then
                        if ExistItem(ShopifyProduct, Rec, Item) then begin
                            Rec."Item SystemId" := Item.SystemId;
                            Rec.Modify();
                        end else begin
                            ProductEvents.OnBeforeCreateItem(Shop, ShopifyProduct, Rec, Item, Handled);
                            if not Handled then
                                DoCreateItem(ShopifyProduct, Rec, Item, true);
                            ProductEvents.OnAfterCreateItem(Shop, ShopifyProduct, Rec, Item);
                        end;
                Shop."SKU Mapping"::"Bar Code":
                    if IsNullGuid(Rec."Item SystemId") or (not Item.GetBySystemId(Rec."Item SystemId")) then
                        if ExistItem(ShopifyProduct, Rec, Item) then begin
                            Rec."Item SystemId" := Item.SystemId;
                            Rec.Modify();
                        end else begin
                            ProductEvents.OnBeforeCreateItem(Shop, ShopifyProduct, Rec, Item, Handled);
                            if not Handled then
                                DoCreateItem(ShopifyProduct, Rec, Item, true);
                            ProductEvents.OnAfterCreateItem(Shop, ShopifyProduct, Rec, Item);
                        end;
            end;
        end;
    end;

    /// <summary> 
    /// Create Item Variant.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    local procedure CreateItemVariant(var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item);
    var
        ItemVariant: Record "Item Variant";
        CreateItem: Codeunit "Shpfy Create Item";
        IsHandled: Boolean;
        Codes: List of [Text];
        ItemNo: Text;
        VariantCode: Text;
    begin
        if (not ShopifyProduct."Has Variants" and not (Shop."SKU Mapping" = Shop."SKU Mapping"::"Variant Code")) or ((ShopifyVariant."UoM Option Id" = 1) and (ShopifyVariant."Option 2 Name" = '')) then begin
            Clear(ItemVariant);
            CreateReferences(ShopifyProduct, ShopifyVariant, Item, ItemVariant);
            if IsNullGuid(ShopifyVariant."Item SystemId") then begin
                ShopifyVariant."Item SystemId" := ShopifyProduct."Item SystemId";
                ShopifyVariant.Modify();
            end;
        end else begin
            ProductEvents.OnBeforeCreateItemVariant(Shop, ShopifyProduct, ShopifyVariant, Item, ItemVariant, IsHandled);
            if not IsHandled then begin
                if ShopifyVariant.SKU <> '' then
                    case Shop."SKU Mapping" of
                        Shop."SKU Mapping"::"Variant Code":
                            if StrLen(ShopifyVariant.SKU) <= MaxStrLen(ItemVariant.Code) then
                                VariantCode := ShopifyVariant.SKU;
                        Shop."SKU Mapping"::"Item No. + Variant Code":
                            begin
                                Codes := ShopifyVariant.SKU.Split(Shop."SKU Field Separator");
                                Codes.Get(1, ItemNo);
                                if (Codes.Count = 2) and Codes.Get(2, VariantCode) then
                                    if StrLen(VariantCode) > MaxStrLen(ItemVariant.Code) then
                                        Clear(VariantCode);
                                if Item."No." <> ItemNo then
                                    if IsNullGuid(ShopifyVariant."Item SystemId") or (not Item.GetBySystemId(ShopifyVariant."Item SystemId")) then
                                        if ExistItem(ShopifyProduct, ShopifyVariant, Item) then begin
                                            ShopifyVariant."Item SystemId" := Item.SystemId;
                                            ShopifyVariant.Modify();
                                        end else begin
                                            ProductEvents.OnBeforeCreateItem(Shop, ShopifyProduct, ShopifyVariant, Item, IsHandled);
                                            if not IsHandled then
                                                DoCreateItem(ShopifyProduct, ShopifyVariant, Item, true);
                                            ProductEvents.OnAfterCreateItem(Shop, ShopifyProduct, ShopifyVariant, Item);
                                        end;
                            end;
                    end;
                if (VariantCode = '') then
                    VariantCode := CreateNewVariantCode(ShopifyProduct, ShopifyVariant, Item);
                if not ItemVariant.Get(Item."No.", CopyStr(VariantCode, 1, MaxStrLen(ItemVariant.Code))) then begin
                    Clear(ItemVariant);
                    ItemVariant.Code := CopyStr(VariantCode, 1, MaxStrLen(ItemVariant.Code));
                    ItemVariant."Item No." := Item."No.";
                    ItemVariant.Description := ShopifyVariant.Title;
                    ItemVariant.Insert();
                end;
                ShopifyVariant."Item SystemId" := Item.SystemId;
                ShopifyVariant."Item Variant SystemId" := ItemVariant.SystemId;
                ShopifyVariant.Modify();
                CreateItem.CreateReferences(ShopifyProduct, ShopifyVariant, Item, ItemVariant);
            end;
            ProductEvents.OnAfterCreateItemVariant(Shop, ShopifyProduct, ShopifyVariant, Item, ItemVariant);
        end;
    end;

    /// <summary> 
    /// Create New Variant Code.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shpfy Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shpfy Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <returns>Return variable "Result" of type Code[10].</returns>
    local procedure CreateNewVariantCode(ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; Item: Record Item) Result: Code[10]
    var
        ItemVariant: Record "Item Variant";
        IsHandled: Boolean;
    begin
        ProductEvents.OnBeforeCreateItemVariantCode(Shop, ShopifyProduct, ShopifyVariant, Item, Result, IsHandled);
        if not IsHandled then begin
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetFilter(Code, Shop."Variant Prefix" + '*');
            if ItemVariant.IsEmpty then
                Result := Shop."Variant Prefix" + '001'
            else begin
                ItemVariant.FindLast();
                Result := IncStr(ItemVariant.Code);
            end;
        end;
    end;

    /// <summary> 
    /// Create References.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shpfy Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shpfy Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    internal procedure CreateReferences(ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; ItemVariant: Record "Item Variant")
    var
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
    begin
        if ShopifyVariant.Barcode <> '' then
            ItemReferenceMgt.CreateItemBarCode(Item."No.", ItemVariant.Code, FindUoMCode(ShopifyVariant), ShopifyVariant.Barcode);
        if ShopifyVariant.SKU <> '' then
            case Shop."SKU Mapping" of
                Shop."SKU Mapping"::"Bar Code":
                    ItemReferenceMgt.CreateItemBarCode(Item."No.", ItemVariant.Code, FindUoMCode(ShopifyVariant), ShopifyVariant.SKU);
                Shop."SKU Mapping"::"Vendor Item No.":
                    if Item."Vendor No." <> '' then begin
                        if ItemVariant.code = '' then begin
                            Item."Vendor Item No." := ShopifyVariant.SKU;
                            Item.Modify();
                        end;
                        ItemReferenceMgt.CreateItemReference(Item."No.", ItemVariant.Code, FindUoMCode(ShopifyVariant), "Item Reference Type"::Vendor, Item."Vendor No.", ShopifyVariant.SKU);
                    end;
            end;
    end;

    /// <summary> 
    /// Do Create Item.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ForVariant">Parameter of type Boolean.</param>
    local procedure DoCreateItem(var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; ForVariant: Boolean)
    var
        ItemCategory: Record "Item Category";
        ItemVariant: Record "Item Variant";
        Vendor: Record Vendor;
        CurrentTemplateCode: Code[20];
        ItemNo: Code[20];
        Code: Text;
    begin
        if TemplateCode = '' then
            CurrentTemplateCode := FindItemTemplate(ShopifyProduct, ShopifyVariant)
        else
            CurrentTemplateCode := TemplateCode;

        if ShopifyVariant.SKU <> '' then
            case Shop."SKU Mapping" of
                Shop."SKU Mapping"::"Item No.":
                    ItemNo := CopyStr(ShopifyVariant.SKU, 1, MaxStrLen(ItemNo));
                Shop."SKU Mapping"::"Item No. + Variant Code":
                    begin
                        ShopifyVariant.SKU.Split(Shop."SKU Field Separator").Get(1, Code);
                        ItemNo := CopyStr(Code, 1, MaxStrLen(ItemNo));
                    end;
            end;
        Clear(Item."Item Category Code");
        CreateItemFromTemplate(Item, CurrentTemplateCode, ItemNo);
        Item.Description := ShopifyProduct.Title;

        CreateItemUnitOfMeasure(ShopifyVariant, Item);

        if ShopifyVariant."Unit Cost" <> 0 then
            Item.Validate("Unit Cost", ShopifyVariant."Unit Cost");

        if ShopifyVariant.Price <> 0 then
            Item.Validate("Unit Price", ShopifyVariant.Price);

        if ShopifyProduct."Product Type" <> '' then begin
            ItemCategory.SetFilter(Description, FilterMgt.CleanFilterValue(ShopifyProduct."Product Type", MaxStrLen(ItemCategory.Description)));
            if ItemCategory.FindFirst() then
                Item."Item Category Code" := ItemCategory.Code;
        end;

        if ShopifyProduct.Vendor <> '' then begin
            Vendor.SetFilter(Name, FilterMgt.CleanFilterValue(ShopifyProduct.Vendor, MaxStrLen(Vendor.Name)));
            if Vendor.FindFirst() then
                Item."Vendor No." := Vendor."No.";
        end;

        Item.Modify();
        if ForVariant then begin
            ShopifyVariant."Item SystemId" := Item.SystemId;
            ShopifyVariant.Modify();
        end else begin
            ShopifyProduct."Item SystemId" := Item.SystemId;
            ShopifyProduct.Modify();
        end;

        Clear(ItemVariant);
        CreateReferences(ShopifyProduct, ShopifyVariant, Item, ItemVariant);
    end;

    local procedure CreateItemUnitOfMeasure(ShopifyVariant: Record "Shpfy Variant"; Item: Record Item)
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        Code: Text;
    begin
        case ShopifyVariant."UoM Option Id" of
            1:
                Code := ShopifyVariant."Option 1 Value";
            2:
                Code := ShopifyVariant."Option 2 Value";
            3:
                Code := ShopifyVariant."Option 3 Value";
        end;
        if Code <> '' then begin
            Code := FindUoMCode(ShopifyVariant);
            if Code <> '' then begin
                ItemUnitofMeasure.SetRange("Item No.", Item."No.");
                ItemUnitofMeasure.SetRange(Code, Code);
                if ItemUnitofMeasure.IsEmpty() then begin
                    Clear(ItemUnitofMeasure);
                    ItemUnitofMeasure."Item No." := Item."No.";
                    ItemUnitofMeasure.Code := CopyStr(Code, 1, MaxStrLen(ItemUnitofMeasure.Code));
                    ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
                    ItemUnitofMeasure.Insert();
                end;
            end;
        end;
    end;

    local procedure CreateItemFromTemplate(var Item: Record Item; ItemTemplCode: Code[20]; ItemNo: Code[20])
    var
        ItemTempl: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
    begin
        if not ItemTempl.Get(ItemTemplCode) then
            exit;
        Item."No." := ItemNo;
        Item.Insert(true);
        ItemTemplMgt.ApplyItemTemplate(Item, ItemTempl);
    end;

    /// <summary> 
    /// Exist Item.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>/// 
    /// <param name="ShopifyVariant">Parameter of type Record "Shpfy Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure ExistItem(ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item): Boolean
    var
        Vendor: Record Vendor;
        ItemReference: Record "Item Reference";
        Code: Text;
    begin
        if ShopifyVariant.SKU <> '' then
            case Shop."SKU Mapping" of
                Shop."SKU Mapping"::"Item No.":
                    if StrLen(ShopifyVariant.SKU) <= MaxStrLen(Item."No.") then
                        exit(Item.Get(ShopifyVariant.SKU.ToUpper()));
                Shop."SKU Mapping"::"Item No. + Variant Code":
                    begin
                        ShopifyVariant.SKU.Split(Shop."SKU Field Separator").Get(1, Code);
                        if StrLen(Code) <= MaxStrLen(Item."No.") then
                            exit(Item.Get(Code.ToUpper()));
                    end;
                Shop."SKU Mapping"::"Vendor Item No.":
                    if ShopifyProduct.Vendor <> '' then begin
                        Vendor.SetFilter(Name, '@' + ShopifyProduct.Vendor);
                        if Vendor.FindFirst() then begin
                            Item.SetRange("Vendor No.", Vendor."No.");
                            Item.SetRange("Vendor Item No.", '@' + ShopifyVariant.SKU.ToUpper());
                            if Item.FindFirst() then
                                exit(true);
                            Clear(Item);
                            ItemReference.SetRange("Reference Type", Enum::"Item Reference Type"::Vendor);
                            ItemReference.SetRange("Reference Type No.", Vendor."No.");
                            ItemReference.SetFilter("Reference No.", '@' + ShopifyVariant.SKU.ToUpper());
                            if ItemReference.FindFirst() then
                                exit(Item.Get(ItemReference."Item No."));
                        end;
                    end;
                Shop."SKU Mapping"::"Bar Code":
                    begin
                        ItemReference.SetRange("Reference Type", Enum::"Item Reference Type"::"Bar Code");
                        ItemReference.SetFilter("Reference No.", '@' + ShopifyVariant.SKU.ToUpper());
                        if ItemReference.FindFirst() then
                            exit(Item.Get(ItemReference."Item No."));
                    end;
            end;

    end;

    /// <summary> 
    /// Find Item Template.
    /// </summary>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <returns>Return variable "Result" of type Code[20].</returns>
    local procedure FindItemTemplate(ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant") Result: Code[20]
    var
        IsHandled: Boolean;
    begin
        ProductEvents.OnBeforeFindItemTemplate(Shop, ShopifyProduct, ShopifyVariant, Result, IsHandled);
        if not IsHandled then begin
            Shop.TestField("Item Templ. Code");
            Result := Shop."Item Templ. Code";
        end;
        ProductEvents.OnAfterFindItemTemplate(Shop, ShopifyProduct, ShopifyVariant, Result);
        exit(Result);
    end;

    /// <summary> 
    /// Find Unit of Mesure Code.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <returns>Return value of type Code[10].</returns>
    local procedure FindUoMCode(ShopifyVariant: Record "Shpfy Variant"): Code[10]
    var
        UnitofMeasure: Record "Unit of Measure";
        Code: Text;
    begin
        case ShopifyVariant."UoM Option Id" of
            1:
                Code := ShopifyVariant."Option 1 Value";
            2:
                Code := ShopifyVariant."Option 2 Value";
            3:
                Code := ShopifyVariant."Option 3 Value";
        end;
        if Code <> '' then
            if UnitofMeasure.Get(CopyStr(Code.ToUpper(), 1, MaxStrLen(UnitofMeasure.Code))) then
                exit(UnitofMeasure.Code)
            else begin
                UnitofMeasure.SetFilter(Description, '@' + Code);
                if UnitofMeasure.IsEmpty then begin
#pragma warning disable AA0139
                    if (StrLen(Code) <= MaxStrLen(UnitofMeasure.Code)) then begin
                        Clear(UnitofMeasure);
                        UnitofMeasure.Code := Code;
                        UnitofMeasure.Description := Code;
                        UnitofMeasure.Insert();
                        exit(UnitofMeasure.Code);
                    end;
#pragma warning restore AA0139
                end else begin
                    UnitofMeasure.FindFirst();
                    exit(UnitofMeasure.Code);
                end;
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
        TemplateCode := Shop."Item Templ. Code";
    end;

    /// <summary> 
    /// Set Template Code.
    /// </summary>
    /// <param name="Code">Parameter of type Code[10].</param>
    internal procedure SetTemplateCode(Code: Code[10])
    begin
        TemplateCode := Code;
    end;
}