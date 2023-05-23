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
        Events: Codeunit "Shpfy Product Events";
        Getlocations: Boolean;
        ProductId: BigInteger;

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
        TempShopifyProduct: Record "Shpfy Product" temporary;
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempShopifyTag: Record "Shpfy Tag" temporary;
    begin
<<<<<<< HEAD
        CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);
=======
        CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempShopifyTag);
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        if not VariantApi.FindShopifyProductVariant(TempShopifyProduct, TempShopifyVariant) then
            ProductId := ProductApi.CreateProduct(TempShopifyProduct, TempShopifyVariant, TempShopifyTag);
    end;

<<<<<<< HEAD
    internal procedure CreateProduct(Item: Record Item; var ShopifyProduct: Record "Shpfy Product" temporary; var ShopifyVariant: Record "Shpfy Variant" temporary)
=======
    internal procedure CreateTempProduct(Item: Record Item; var TempShopifyProduct: Record "Shpfy Product" temporary; var TempShopifyVariant: Record "Shpfy Variant" temporary; var TempShopifyTag: Record "Shpfy Tag" temporary)
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
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
<<<<<<< HEAD
                            Clear(ShopifyVariant);
                            ShopifyVariant.Id := Id;
                            ShopifyVariant."Available For Sales" := true;
                            ShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", ItemVariant.Code, ItemUnitofMeasure.Code), 1, MaxStrLen(ShopifyVariant.Barcode));
                            ProductPriceCalc.CalcPrice(Item, ItemVariant.Code, ItemUnitofMeasure.Code, ShopifyVariant."Unit Cost", ShopifyVariant.Price, ShopifyVariant."Compare at Price");
                            ShopifyVariant.Title := ItemVariant.Description;
                            ShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
=======
                            Clear(TempShopifyVariant);
                            TempShopifyVariant.Id := Id;
                            TempShopifyVariant."Available For Sales" := true;
                            TempShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", ItemVariant.Code, ItemUnitofMeasure.Code), 1, MaxStrLen(TempShopifyVariant.Barcode));
                            ProductPriceCalc.CalcPrice(Item, ItemVariant.Code, ItemUnitofMeasure.Code, TempShopifyVariant."Unit Cost", TempShopifyVariant.Price, TempShopifyVariant."Compare at Price");
                            TempShopifyVariant.Title := ItemVariant.Description;
                            TempShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
                            case Shop."SKU Mapping" of
                                Shop."SKU Mapping"::"Bar Code":
                                    ShopifyVariant.SKU := ShopifyVariant.Barcode;
                                Shop."SKU Mapping"::"Item No.":
                                    ShopifyVariant.SKU := Item."No.";
                                Shop."SKU Mapping"::"Variant Code":
                                    if ItemVariant.Code <> '' then
                                        ShopifyVariant.SKU := ItemVariant.Code;
                                Shop."SKU Mapping"::"Item No. + Variant Code":
                                    if ItemVariant.Code <> '' then
                                        ShopifyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                                    else
                                        ShopifyVariant.SKU := Item."No.";
                                Shop."SKU Mapping"::"Vendor Item No.":
                                    ShopifyVariant.SKU := Item."Vendor Item No.";
                            end;
<<<<<<< HEAD
                            ShopifyVariant."Tax Code" := Item."Tax Group Code";
                            ShopifyVariant.Taxable := true;
                            ShopifyVariant.Weight := Item."Gross Weight";
                            ShopifyVariant."Option 1 Name" := 'Variant';
                            ShopifyVariant."Option 1 Value" := ItemVariant.Code;
                            ShopifyVariant."Option 2 Name" := Shop."Option Name for UoM";
                            ShopifyVariant."Option 2 Value" := ItemUnitofMeasure.Code;
                            ShopifyVariant."Shop Code" := Shop.Code;
                            ShopifyVariant."Item SystemId" := Item.SystemId;
                            ShopifyVariant."Item Variant SystemId" := ItemVariant.SystemId;
                            ShopifyVariant."UoM Option Id" := 2;
                            ShopifyVariant.Insert(false);
=======
                            TempShopifyVariant."Tax Code" := Item."Tax Group Code";
                            TempShopifyVariant.Taxable := true;
                            TempShopifyVariant.Weight := Item."Gross Weight";
                            TempShopifyVariant."Option 1 Name" := 'Variant';
                            TempShopifyVariant."Option 1 Value" := ItemVariant.Code;
                            TempShopifyVariant."Option 2 Name" := Shop."Option Name for UoM";
                            TempShopifyVariant."Option 2 Value" := ItemUnitofMeasure.Code;
                            TempShopifyVariant."Shop Code" := Shop.Code;
                            TempShopifyVariant."Item SystemId" := Item.SystemId;
                            TempShopifyVariant."Item Variant SystemId" := ItemVariant.SystemId;
                            TempShopifyVariant."UoM Option Id" := 2;
                            TempShopifyVariant.Insert(false);
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
                        until ItemUnitofMeasure.Next() = 0;
                end else begin
                    Id += 1;
                    Clear(ShopifyVariant);
                    ShopifyVariant.Id := Id;
                    ShopifyVariant."Available For Sales" := true;
                    ShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure"), 1, MaxStrLen(ShopifyVariant.Barcode));
                    ProductPriceCalc.CalcPrice(Item, ItemVariant.Code, Item."Sales Unit of Measure", ShopifyVariant."Unit Cost", ShopifyVariant.Price, ShopifyVariant."Compare at Price");
                    ShopifyVariant.Title := ItemVariant.Description;
                    ShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
                    case Shop."SKU Mapping" of
                        Shop."SKU Mapping"::"Bar Code":
                            ShopifyVariant.SKU := ShopifyVariant.Barcode;
                        Shop."SKU Mapping"::"Item No.":
                            ShopifyVariant.SKU := Item."No.";
                        Shop."SKU Mapping"::"Variant Code":
                            if ItemVariant.Code <> '' then
                                ShopifyVariant.SKU := ItemVariant.Code;
                        Shop."SKU Mapping"::"Item No. + Variant Code":
                            if ItemVariant.Code <> '' then
                                ShopifyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                            else
                                ShopifyVariant.SKU := Item."No.";
                        Shop."SKU Mapping"::"Vendor Item No.":
                            ShopifyVariant.SKU := CopyStr(GetVendorItemNo(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure"), 1, MaxStrLen(ShopifyVariant.SKU));
                    end;
                    ShopifyVariant."Tax Code" := Item."Tax Group Code";
                    ShopifyVariant.Taxable := true;
                    ShopifyVariant.Weight := Item."Gross Weight";
                    ShopifyVariant."Option 1 Name" := 'Variant';
                    ShopifyVariant."Option 1 Value" := ItemVariant.Code;
                    ShopifyVariant."Shop Code" := Shop.Code;
                    ShopifyVariant."Item SystemId" := Item.SystemId;
                    ShopifyVariant."Item Variant SystemId" := ItemVariant.SystemId;
                    ShopifyVariant.Insert(false);
                end;
            until ItemVariant.Next() = 0
        else
            if Shop."UoM as Variant" then begin
                ItemUnitofMeasure.SetRange("Item No.", Item."No.");
                if ItemUnitofMeasure.FindSet(false, false) then
                    repeat
                        Id += 1;
<<<<<<< HEAD
                        Clear(ShopifyVariant);
                        ShopifyVariant.Id := Id;
                        ShopifyVariant."Available For Sales" := true;
                        ShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", '', ItemUnitofMeasure.Code), 1, MaxStrLen(ShopifyVariant.Barcode));
                        ProductPriceCalc.CalcPrice(Item, '', ItemUnitofMeasure.Code, ShopifyVariant."Unit Cost", ShopifyVariant.Price, ShopifyVariant."Compare at Price");
                        ShopifyVariant.Title := Item.Description;
                        ShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
=======
                        Clear(TempShopifyVariant);
                        TempShopifyVariant.Id := Id;
                        TempShopifyVariant."Available For Sales" := true;
                        TempShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", '', ItemUnitofMeasure.Code), 1, MaxStrLen(TempShopifyVariant.Barcode));
                        ProductPriceCalc.CalcPrice(Item, '', ItemUnitofMeasure.Code, TempShopifyVariant."Unit Cost", TempShopifyVariant.Price, TempShopifyVariant."Compare at Price");
                        TempShopifyVariant.Title := Item.Description;
                        TempShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
                        case Shop."SKU Mapping" of
                            Shop."SKU Mapping"::"Bar Code":
                                ShopifyVariant.SKU := ShopifyVariant.Barcode;
                            Shop."SKU Mapping"::"Item No.":
                                ShopifyVariant.SKU := Item."No.";
                            Shop."SKU Mapping"::"Variant Code":
                                if ItemVariant.Code <> '' then
                                    ShopifyVariant.SKU := ItemVariant.Code;
                            SHop."SKU Mapping"::"Item No. + Variant Code":
                                if ItemVariant.Code <> '' then
                                    ShopifyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                                else
                                    ShopifyVariant.SKU := Item."No.";
                            Shop."SKU Mapping"::"Vendor Item No.":
                                ShopifyVariant.SKU := Item."Vendor Item No.";
                        end;
<<<<<<< HEAD
                        ShopifyVariant."Tax Code" := Item."Tax Group Code";
                        ShopifyVariant.Taxable := true;
                        ShopifyVariant.Weight := Item."Gross Weight";
                        ShopifyVariant."Option 1 Name" := Shop."Option Name for UoM";
                        ShopifyVariant."Option 1 Value" := ItemUnitofMeasure.Code;
                        ShopifyVariant."Shop Code" := Shop.Code;
                        ShopifyVariant."Item SystemId" := Item.SystemId;
                        ShopifyVariant."UoM Option Id" := 1;
                        ShopifyVariant.Insert(false);
=======
                        TempShopifyVariant."Tax Code" := Item."Tax Group Code";
                        TempShopifyVariant.Taxable := true;
                        TempShopifyVariant.Weight := Item."Gross Weight";
                        TempShopifyVariant."Option 1 Name" := Shop."Option Name for UoM";
                        TempShopifyVariant."Option 1 Value" := ItemUnitofMeasure.Code;
                        TempShopifyVariant."Shop Code" := Shop.Code;
                        TempShopifyVariant."Item SystemId" := Item.SystemId;
                        TempShopifyVariant."UoM Option Id" := 1;
                        TempShopifyVariant.Insert(false);
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
                    until ItemUnitofMeasure.Next() = 0;
            end else begin
                Clear(ShopifyVariant);
                ShopifyVariant."Available For Sales" := true;
                ShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", '', Item."Sales Unit of Measure"), 1, MaxStrLen(ShopifyVariant.Barcode));
                ProductPriceCalc.CalcPrice(Item, '', Item."Sales Unit of Measure", ShopifyVariant."Unit Cost", ShopifyVariant.Price, ShopifyVariant."Compare at Price");
                ShopifyVariant.Title := ItemVariant.Description;
                ShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
                case Shop."SKU Mapping" of
                    Shop."SKU Mapping"::"Bar Code":
                        ShopifyVariant.SKU := ShopifyVariant.Barcode;
                    Shop."SKU Mapping"::"Item No.":
                        ShopifyVariant.SKU := Item."No.";
                    Shop."SKU Mapping"::"Variant Code":
                        if ItemVariant.Code <> '' then
                            ShopifyVariant.SKU := ItemVariant.Code;
                    SHop."SKU Mapping"::"Item No. + Variant Code":
                        if ItemVariant.Code <> '' then
                            ShopifyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                        else
                            ShopifyVariant.SKU := Item."No.";
                    Shop."SKU Mapping"::"Vendor Item No.":
                        ShopifyVariant.SKU := Item."Vendor Item No.";
                end;
                ShopifyVariant."Tax Code" := Item."Tax Group Code";
                ShopifyVariant.Taxable := true;
                ShopifyVariant.Weight := Item."Gross Weight";
                ShopifyVariant."Shop Code" := Shop.Code;
                ShopifyVariant."Item SystemId" := Item.SystemId;
                ShopifyVariant.Insert(false);
            end;
<<<<<<< HEAD
        ShopifyProduct.Insert(false);
=======
        TempShopifyProduct.Insert(false);
        Events.OnAfterCreateTempShopifyProduct(Item, TempShopifyProduct, TempShopifyVariant, TempShopifyTag);

>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
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

    internal procedure GetProductId(): BigInteger
    begin
        exit(ProductId);
    end;
}