/// <summary>
/// Codeunit Shpfy Create Product (ID 30174).
/// </summary>
codeunit 30174 "Shpfy Create Product"
{
    Access = Internal;
    Permissions =
        tabledata Item = r,
        tabledata "Item Reference" = r,
        tabledata "Item Unit of Measure" = r,
        tabledata "Item Variant" = r;
    TableNo = Item;

    var
        Shop: Record "Shpfy Shop";
        ProductApi: Codeunit "Shpfy Product API";
        ProductExport: Codeunit "Shpfy Product Export";
        ProductPriceCalc: Codeunit "Shpfy Product Price Calc.";
        VariantApi: Codeunit "Shpfy Variant API";
        Getlocations: Boolean;

    trigger OnRun()
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        if Getlocations then begin
            Codeunit.Run(Codeunit::"Shpfy Sync Shop Locations", Shop);
            Commit();
            Getlocations := false;
        end;
        ShopifyProduct.SetRange("Shop Code", Shop.Code);
        ShopifyProduct.SetRange("Item SystemId", Rec.SystemId);
        if ShopifyProduct.IsEmpty then
            CreateProduct(Rec);
    end;

    /// <summary> 
    /// Create Product.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    local procedure CreateProduct(Item: Record Item)
    var
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
    begin
        CreateProduct(Item, ShopifyProduct, ShopifyVariant);
        if not VariantApi.FindShopifyProductVariant(ShopifyProduct, ShopifyVariant) then
            ProductApi.CreateProduct(ShopifyProduct, ShopifyVariant);
    end;

    internal procedure CreateProduct(Item: Record Item; var ShopifyProduct: Record "Shpfy Product"; var ShpfyVariant: Record "Shpfy Variant")
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        ItemVariant: Record "Item Variant";
        Id: Integer;
        ICreateProductStatus: Interface "Shpfy ICreateProductStatusValue";
    begin
        Clear(ShopifyProduct);
        ShopifyProduct."Shop Code" := Shop.Code;
        ShopifyProduct."Item SystemId" := Item.SystemId;
        ProductExport.FillInProductFields(Item, ShopifyProduct);
        ICreateProductStatus := Shop."Status for Created Products";
        ShopifyProduct.Status := ICreateProductStatus.GetStatus(Item);
        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet(false, false) then
            repeat
                ShopifyProduct."Has Variants" := true;
                if Shop."UoM as Variant" then begin
                    ItemUnitofMeasure.SetRange("Item No.", Item."No.");
                    if ItemUnitofMeasure.FindSet(false, false) then
                        repeat
                            Id += 1;
                            Clear(ShpfyVariant);
                            ShpfyVariant.Id := Id;
                            ShpfyVariant."Available For Sales" := true;
                            ShpfyVariant.Barcode := CopyStr(GetBarcode(Item."No.", ItemVariant.Code, ItemUnitofMeasure.Code), 1, MaxStrLen(ShpfyVariant.Barcode));
                            ProductPriceCalc.CalcPrice(Item, ItemVariant.Code, ItemUnitofMeasure.Code, ShpfyVariant."Unit Cost", ShpfyVariant.Price, ShpfyVariant."Compare at Price");
                            ShpfyVariant.Title := ItemVariant.Description;
                            ShpfyVariant."Inventory Policy" := Shop."Default Inventory Policy";
                            case Shop."SKU Mapping" of
                                Shop."SKU Mapping"::"Bar Code":
                                    ShpfyVariant.SKU := ShpfyVariant.Barcode;
                                Shop."SKU Mapping"::"Item No.":
                                    ShpfyVariant.SKU := Item."No.";
                                Shop."SKU Mapping"::"Variant Code":
                                    if ItemVariant.Code <> '' then
                                        ShpfyVariant.SKU := ItemVariant.Code;
                                Shop."SKU Mapping"::"Item No. + Variant Code":
                                    if ItemVariant.Code <> '' then
                                        ShpfyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                                    else
                                        ShpfyVariant.SKU := Item."No.";
                                Shop."SKU Mapping"::"Vendor Item No.":
                                    ShpfyVariant.SKU := Item."Vendor Item No.";
                            end;
                            ShpfyVariant."Tax Code" := Item."Tax Group Code";
                            ShpfyVariant.Taxable := true;
                            ShpfyVariant.Weight := Item."Gross Weight";
                            ShpfyVariant."Option 1 Name" := 'Variant';
                            ShpfyVariant."Option 1 Value" := ItemVariant.Code;
                            ShpfyVariant."Option 2 Name" := Shop."Option Name for UoM";
                            ShpfyVariant."Option 2 Value" := ItemUnitofMeasure.Code;
                            ShpfyVariant."Shop Code" := Shop.Code;
                            ShpfyVariant."Item SystemId" := Item.SystemId;
                            ShpfyVariant."Item Variant SystemId" := ItemVariant.SystemId;
                            ShpfyVariant."UoM Option Id" := 2;
                            ShpfyVariant.Insert(false);
                        until ItemUnitofMeasure.Next() = 0;
                end else begin
                    Id += 1;
                    Clear(ShpfyVariant);
                    ShpfyVariant.Id := Id;
                    ShpfyVariant."Available For Sales" := true;
                    ShpfyVariant.Barcode := CopyStr(GetBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure"), 1, MaxStrLen(ShpfyVariant.Barcode));
                    ProductPriceCalc.CalcPrice(Item, ItemVariant.Code, Item."Sales Unit of Measure", ShpfyVariant."Unit Cost", ShpfyVariant.Price, ShpfyVariant."Compare at Price");
                    ShpfyVariant.Title := ItemVariant.Description;
                    ShpfyVariant."Inventory Policy" := Shop."Default Inventory Policy";
                    case Shop."SKU Mapping" of
                        Shop."SKU Mapping"::"Bar Code":
                            ShpfyVariant.SKU := ShpfyVariant.Barcode;
                        Shop."SKU Mapping"::"Item No.":
                            ShpfyVariant.SKU := Item."No.";
                        Shop."SKU Mapping"::"Variant Code":
                            if ItemVariant.Code <> '' then
                                ShpfyVariant.SKU := ItemVariant.Code;
                        Shop."SKU Mapping"::"Item No. + Variant Code":
                            if ItemVariant.Code <> '' then
                                ShpfyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                            else
                                ShpfyVariant.SKU := Item."No.";
                        Shop."SKU Mapping"::"Vendor Item No.":
                            ShpfyVariant.SKU := CopyStr(GetVendorItemNo(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure"), 1, MaxStrLen(ShpfyVariant.SKU));
                    end;
                    ShpfyVariant."Tax Code" := Item."Tax Group Code";
                    ShpfyVariant.Taxable := true;
                    ShpfyVariant.Weight := Item."Gross Weight";
                    ShpfyVariant."Option 1 Name" := 'Variant';
                    ShpfyVariant."Option 1 Value" := ItemVariant.Code;
                    ShpfyVariant."Shop Code" := Shop.Code;
                    ShpfyVariant."Item SystemId" := Item.SystemId;
                    ShpfyVariant."Item Variant SystemId" := ItemVariant.SystemId;
                    ShpfyVariant.Insert(false);
                end;
            until ItemVariant.Next() = 0
        else
            if Shop."UoM as Variant" then begin
                ItemUnitofMeasure.SetRange("Item No.", Item."No.");
                if ItemUnitofMeasure.FindSet(false, false) then
                    repeat
                        Id += 1;
                        Clear(ShpfyVariant);
                        ShpfyVariant.Id := Id;
                        ShpfyVariant."Available For Sales" := true;
                        ShpfyVariant.Barcode := CopyStr(GetBarcode(Item."No.", '', ItemUnitofMeasure.Code), 1, MaxStrLen(ShpfyVariant.Barcode));
                        ProductPriceCalc.CalcPrice(Item, '', ItemUnitofMeasure.Code, ShpfyVariant."Unit Cost", ShpfyVariant.Price, ShpfyVariant."Compare at Price");
                        ShpfyVariant.Title := Item.Description;
                        ShpfyVariant."Inventory Policy" := Shop."Default Inventory Policy";
                        case Shop."SKU Mapping" of
                            Shop."SKU Mapping"::"Bar Code":
                                ShpfyVariant.SKU := ShpfyVariant.Barcode;
                            Shop."SKU Mapping"::"Item No.":
                                ShpfyVariant.SKU := Item."No.";
                            Shop."SKU Mapping"::"Variant Code":
                                if ItemVariant.Code <> '' then
                                    ShpfyVariant.SKU := ItemVariant.Code;
                            SHop."SKU Mapping"::"Item No. + Variant Code":
                                if ItemVariant.Code <> '' then
                                    ShpfyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                                else
                                    ShpfyVariant.SKU := Item."No.";
                            Shop."SKU Mapping"::"Vendor Item No.":
                                ShpfyVariant.SKU := Item."Vendor Item No.";
                        end;
                        ShpfyVariant."Tax Code" := Item."Tax Group Code";
                        ShpfyVariant.Taxable := true;
                        ShpfyVariant.Weight := Item."Gross Weight";
                        ShpfyVariant."Option 1 Name" := Shop."Option Name for UoM";
                        ShpfyVariant."Option 1 Value" := ItemUnitofMeasure.Code;
                        ShpfyVariant."Shop Code" := Shop.Code;
                        ShpfyVariant."Item SystemId" := Item.SystemId;
                        ShpfyVariant."UoM Option Id" := 1;
                        ShpfyVariant.Insert(false);
                    until ItemUnitofMeasure.Next() = 0;
            end else begin
                Clear(ShpfyVariant);
                ShpfyVariant."Available For Sales" := true;
                ShpfyVariant.Barcode := CopyStr(GetBarcode(Item."No.", '', Item."Sales Unit of Measure"), 1, MaxStrLen(ShpfyVariant.Barcode));
                ProductPriceCalc.CalcPrice(Item, '', Item."Sales Unit of Measure", ShpfyVariant."Unit Cost", ShpfyVariant.Price, ShpfyVariant."Compare at Price");
                ShpfyVariant.Title := ItemVariant.Description;
                ShpfyVariant."Inventory Policy" := Shop."Default Inventory Policy";
                case Shop."SKU Mapping" of
                    Shop."SKU Mapping"::"Bar Code":
                        ShpfyVariant.SKU := ShpfyVariant.Barcode;
                    Shop."SKU Mapping"::"Item No.":
                        ShpfyVariant.SKU := Item."No.";
                    Shop."SKU Mapping"::"Variant Code":
                        if ItemVariant.Code <> '' then
                            ShpfyVariant.SKU := ItemVariant.Code;
                    SHop."SKU Mapping"::"Item No. + Variant Code":
                        if ItemVariant.Code <> '' then
                            ShpfyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                        else
                            ShpfyVariant.SKU := Item."No.";
                    Shop."SKU Mapping"::"Vendor Item No.":
                        ShpfyVariant.SKU := Item."Vendor Item No.";
                end;
                ShpfyVariant."Tax Code" := Item."Tax Group Code";
                ShpfyVariant.Taxable := true;
                ShpfyVariant.Weight := Item."Gross Weight";
                ShpfyVariant."Shop Code" := Shop.Code;
                ShpfyVariant."Item SystemId" := Item.SystemId;
                ShpfyVariant.Insert(false);
            end;
        ShopifyProduct.Insert(false);
    end;

    /// <summary> 
    /// Get Barcode.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="VariantCode">Parameter of type Code[10].</param>
    /// <param name="UoM">Parameter of type Code[10].</param>
    /// <returns>Return value of type Text.</returns>
    local procedure GetBarcode(ItemNo: Code[20]; VariantCode: Code[10]; UoM: Code[10]): Text;
    var
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
    begin
        exit(ItemReferenceMgt.GetItemBarcode(ItemNo, VariantCode, UoM));
    end;

    /// <summary> 
    /// Get Vendor Item No.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="VariantCode">Parameter of type Code[10].</param>
    /// <param name="UoM">Parameter of type Code[10].</param>
    /// <returns>Return value of type Text.</returns>
    local procedure GetVendorItemNo(ItemNo: Code[20]; VariantCode: Code[10]; UoM: Code[10]): Text;
    var
        Item: Record Item;
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
    begin
        if Item.Get(ItemNo) then
            exit(ItemReferenceMgt.GetItemReference(ItemNo, VariantCode, UoM, "Item Reference Type"::Vendor, Item."Vendor No."));
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
            ProductApi.SetShop(Shop);
            VariantApi.SetShop(Shop);
            ProductPriceCalc.SetShop(Shop);
            ProductExport.SetShop(Shop);
            Getlocations := true;
        end;
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        SetShop(ShopifyShop.Code);
    end;
}