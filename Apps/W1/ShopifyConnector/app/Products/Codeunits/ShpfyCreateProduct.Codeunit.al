/// <summary>
/// Codeunit Shpfy Create Product (ID 30174).
/// </summary>
codeunit 30174 "Shpfy Create Product"
{
    Access = Internal;
    TableNo = Item;

    var
        Shop: Record "Shpfy Shop";
        ProductApi: Codeunit "Shpfy Product API";
        ProductExport: Codeunit "Shpfy Product Export";
        ProductPriceCalc: Codeunit "Shpfy Product Price Calc.";
        VariantApi: Codeunit "Shpfy Variant API";


    trigger OnRun()
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        ShopifyProduct.SetRange("Shop Code", Shop.Code);
        ShopifyProduct.SetRange(ItemSystemId, Rec.SystemId);
        if ShopifyProduct.IsEmpty then
            CreateProduct(Rec);
    end;

    /// <summary> 
    /// Create Product.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    local procedure CreateProduct(Item: Record Item)
    var
        ItemUoM: Record "Item Unit of Measure";
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        Id: Integer;
        ICreateProductStatus: Interface "Shpfy ICreateProductStatusValue";
    begin
        Clear(TempShopifyProduct);
        TempShopifyProduct."Shop Code" := Shop.Code;
        TempShopifyProduct.ItemSystemId := Item.SystemId;
        ProductExport.FillInProductFields(Item, TempShopifyProduct);
        ICreateProductStatus := Shop."Create Product Status Value";
        TempShopifyProduct.Status := ICreateProductStatus.GetStatus(Item);
        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet(false, false) then
            repeat
                TempShopifyProduct."Has Variants" := true;
                if Shop."UOM as Variant" then begin
                    ItemUoM.SetRange("Item No.", Item."No.");
                    if ItemUoM.FindSet(false, false) then
                        repeat
                            Id += 1;
                            Clear(TempShopifyVariant);
                            TempShopifyVariant.Id := Id;
                            TempShopifyVariant."Available For Sales" := true;
                            TempShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", ItemVariant.Code, ItemUoM.Code), 1, MaxStrLen(TempShopifyVariant.Barcode));
                            ProductPriceCalc.CalcPrice(Item, ItemVariant.Code, ItemUoM.Code, TempShopifyVariant."Unit Cost", TempShopifyVariant.Price, TempShopifyVariant."Compare at Price");
                            TempShopifyVariant.Title := ItemVariant.Description;
                            TempShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
                            case Shop."SKU Type" of
                                Shop."SKU Type"::Barcode:
                                    TempShopifyVariant.SKU := TempShopifyVariant.Barcode;
                                Shop."SKU Type"::"Item No.":
                                    TempShopifyVariant.SKU := Item."No.";
                                Shop."SKU Type"::"Item No. + Variant Code":
                                    if ItemVariant.Code <> '' then
                                        TempShopifyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                                    else
                                        TempShopifyVariant.SKU := Item."No.";
                                Shop."SKU Type"::"Vendor Item No.":
                                    TempShopifyVariant.SKU := Item."Vendor Item No.";
                            end;
                            TempShopifyVariant."Tax Code" := Item."Tax Group Code";
                            TempShopifyVariant.Taxable := true;
                            TempShopifyVariant.Weight := Item."Gross Weight";
                            TempShopifyVariant."Option 1 Name" := 'Variant';
                            TempShopifyVariant."Option 1 Value" := ItemVariant.Code;
                            TempShopifyVariant."Option 2 Name" := Shop."Option Name for UOM";
                            TempShopifyVariant."Option 2 Value" := ItemUoM.Code;
                            TempShopifyVariant."Shop Code" := Shop.Code;
                            TempShopifyVariant.ItemSystemId := Item.SystemId;
                            TempShopifyVariant.ItemVariantSystemId := ItemVariant.SystemId;
                            TempShopifyVariant."UOM Option Id" := 2;
                            TempShopifyVariant.Insert(false);
                        until ItemUoM.Next() = 0;
                end else begin
                    Id += 1;
                    Clear(TempShopifyVariant);
                    TempShopifyVariant.Id := Id;
                    TempShopifyVariant."Available For Sales" := true;
                    TempShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure"), 1, MaxStrLen(TempShopifyVariant.Barcode));
                    ProductPriceCalc.CalcPrice(Item, ItemVariant.Code, Item."Sales Unit of Measure", TempShopifyVariant."Unit Cost", TempShopifyVariant.Price, TempShopifyVariant."Compare at Price");
                    TempShopifyVariant.Title := ItemVariant.Description;
                    TempShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
                    case Shop."SKU Type" of
                        Shop."SKU Type"::Barcode:
                            TempShopifyVariant.SKU := TempShopifyVariant.Barcode;
                        Shop."SKU Type"::"Item No.":
                            TempShopifyVariant.SKU := Item."No.";
                        Shop."SKU Type"::"Item No. + Variant Code":
                            if ItemVariant.Code <> '' then
                                TempShopifyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                            else
                                TempShopifyVariant.SKU := Item."No.";
                        Shop."SKU Type"::"Vendor Item No.":
                            TempShopifyVariant.SKU := CopyStr(GetVendorItemNo(Item."No.", TempShopifyVariant."Variant Code", Item."Sales Unit of Measure"), 1, MaxStrLen(TempShopifyVariant.SKU));
                    end;
                    TempShopifyVariant."Tax Code" := Item."Tax Group Code";
                    TempShopifyVariant.Taxable := true;
                    TempShopifyVariant.Weight := Item."Gross Weight";
                    TempShopifyVariant."Option 1 Name" := 'Variant';
                    TempShopifyVariant."Option 1 Value" := ItemVariant.Code;
                    TempShopifyVariant."Shop Code" := Shop.Code;
                    TempShopifyVariant.ItemSystemId := Item.SystemId;
                    TempShopifyVariant.ItemVariantSystemId := ItemVariant.SystemId;
                    TempShopifyVariant.Insert(false);
                end;
            until ItemVariant.Next() = 0
        else
            if Shop."UOM as Variant" then begin
                ItemUoM.SetRange("Item No.", Item."No.");
                if ItemUoM.FindSet(false, false) then
                    repeat
                        Id += 1;
                        Clear(TempShopifyVariant);
                        TempShopifyVariant.Id := Id;
                        TempShopifyVariant."Available For Sales" := true;
                        TempShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", '', ItemUoM.Code), 1, MaxStrLen(TempShopifyVariant.Barcode));
                        ProductPriceCalc.CalcPrice(Item, '', ItemUoM.Code, TempShopifyVariant."Unit Cost", TempShopifyVariant.Price, TempShopifyVariant."Compare at Price");
                        TempShopifyVariant.Title := Item.Description;
                        TempShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
                        case Shop."SKU Type" of
                            Shop."SKU Type"::Barcode:
                                TempShopifyVariant.SKU := TempShopifyVariant.Barcode;
                            Shop."SKU Type"::"Item No.",
                            SHop."SKU Type"::"Item No. + Variant Code":
                                if ItemVariant.Code <> '' then
                                    TempShopifyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                                else
                                    TempShopifyVariant.SKU := Item."No.";
                            Shop."SKU Type"::"Vendor Item No.":
                                TempShopifyVariant.SKU := Item."Vendor Item No.";
                        end;
                        TempShopifyVariant."Tax Code" := Item."Tax Group Code";
                        TempShopifyVariant.Taxable := true;
                        TempShopifyVariant.Weight := Item."Gross Weight";
                        TempShopifyVariant."Option 1 Name" := Shop."Option Name for UOM";
                        TempShopifyVariant."Option 1 Value" := ItemUoM.Code;
                        TempShopifyVariant."Shop Code" := Shop.Code;
                        TempShopifyVariant.ItemSystemId := Item.SystemId;
                        TempShopifyVariant."UOM Option Id" := 1;
                        TempShopifyVariant.Insert(false);
                    until ItemUoM.Next() = 0;
            end else begin
                Clear(TempShopifyVariant);
                TempShopifyVariant."Available For Sales" := true;
                TempShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", '', Item."Sales Unit of Measure"), 1, MaxStrLen(TempShopifyVariant.Barcode));
                ProductPriceCalc.CalcPrice(Item, '', Item."Sales Unit of Measure", TempShopifyVariant."Unit Cost", TempShopifyVariant.Price, TempShopifyVariant."Compare at Price");
                TempShopifyVariant.Title := ItemVariant.Description;
                TempShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
                case Shop."SKU Type" of
                    Shop."SKU Type"::Barcode:
                        TempShopifyVariant.SKU := TempShopifyVariant.Barcode;
                    Shop."SKU Type"::"Item No.",
                    SHop."SKU Type"::"Item No. + Variant Code":
                        if ItemVariant.Code <> '' then
                            TempShopifyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code
                        else
                            TempShopifyVariant.SKU := Item."No.";
                    Shop."SKU Type"::"Vendor Item No.":
                        TempShopifyVariant.SKU := Item."Vendor Item No.";
                end;
                TempShopifyVariant."Tax Code" := Item."Tax Group Code";
                TempShopifyVariant.Taxable := true;
                TempShopifyVariant.Weight := Item."Gross Weight";
                TempShopifyVariant."Shop Code" := Shop.Code;
                TempShopifyVariant.ItemSystemId := Item.SystemId;
                TempShopifyVariant.Insert(false);
            end;
        TempShopifyProduct.Insert(false);
        if not VariantApi.FindShopifyProductVariant(TempShopifyProduct, TempShopifyVariant) then
            ProductApi.CreateProduct(TempShopifyProduct, TempShopifyVariant);
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
        ItemRefMgt: Codeunit "Shpfy Item Reference Mgt.";
    begin
        exit(ItemRefMgt.GetItemBarcode(ItemNo, VariantCode, UoM));
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
        ItemRefMgt: Codeunit "Shpfy Item Reference Mgt.";
    begin
        if Item.Get(ItemNo) then
            exit(ItemRefMgt.GetItemReference(ItemNo, VariantCode, UoM, "Item Reference Type"::Vendor, Item."Vendor No."));
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
            Codeunit.Run(Codeunit::"Shpfy Sync Shop Locations", Shop);
            Commit();
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