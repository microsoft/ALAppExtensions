/// <summary>
/// Codeunit Shpfy Product Export (ID 30178).
/// </summary>
codeunit 30178 "Shpfy Product Export"
{
    Access = Internal;
    Permissions =
        tabledata "Extended Text Header" = r,
        tabledata "Extended Text Line" = r,
        tabledata Item = rim,
        tabledata "Item Attr. Value Translation" = r,
        tabledata "Item Attribute" = r,
        tabledata "Item Attribute Translation" = r,
        tabledata "Item Attribute Value" = r,
        tabledata "Item Attribute Value Mapping" = r,
        tabledata "Item Category" = r,
        tabledata "Item Reference" = r,
        tabledata "Item Unit of Measure" = rim,
        tabledata "Item Variant" = rim,
        tabledata Vendor = r;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        ShopifyProduct.SetFilter("Item SystemId", '<>%1', NullGuid);
        ShopifyProduct.SetFilter("Shop Code", Rec.GetFilter(Code));
        if ShopifyProduct.FindSet(false, false) then
            repeat
                SetShop(ShopifyProduct."Shop Code");
                if Shop."Can Update Shopify Products" or OnlyUpdatePrice then
                    UpdateProductData(ShopifyProduct.Id);
            until ShopifyProduct.Next() = 0;
    end;

    var
        Shop: Record "Shpfy Shop";
        ProductApi: Codeunit "Shpfy Product API";
        Events: Codeunit "Shpfy Product Events";
        ProductPriceCalc: Codeunit "Shpfy Product Price Calc.";
        VariantApi: Codeunit "Shpfy Variant API";
        OnlyUpdatePrice: Boolean;
        NullGuid: Guid;

    /// <summary> 
    /// Create Product Body.
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <returns>Return variable "ProductBodyHtml" of type Text.</returns>
    local procedure CreateProductBody(ItemNo: Code[20]) ProductBodyHtml: Text
    var
        ExtendedTextHeader: Record "Extended Text Header";
        ExtendedTextLine: Record "Extended Text Line";
        ItemAttrValueTranslation: Record "Item Attr. Value Translation";
        ItemAttribute: Record "Item Attribute";
        ItemAttributeTranslation: Record "Item Attribute Translation";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        IsHandled: Boolean;
        AttributeTitleLbl: Label 'Item Attributes';
        Result: TextBuilder;
    begin
        Events.OnBeforeCreateProductBodyHtml(ItemNo, Shop, ProductBodyHtml, IsHandled);
        if not IsHandled then begin
            if Shop."Sync Item Extended Text" then begin
                ExtendedTextHeader.SetRange("Table Name", ExtendedTextHeader."Table Name"::Item);
                ExtendedTextHeader.SetRange("No.", ItemNo);
                ExtendedTextHeader.SetFilter("Language Code", '%1|%2', '', Shop."Language Code");
                ExtendedTextHeader.SetFilter("Starting Date", '%1|>=%2', 0D, Today());
                ExtendedTextHeader.SetFilter("Ending Date", '%1|<=%2', 0D, Today());
                if ExtendedTextHeader.FindSet() then begin
                    result.Append('<div class="productDescription">');
                    repeat
                        if (ExtendedTextHeader."Language Code" = Shop."Language Code") or ExtendedTextHeader."All Language Codes" then begin
                            ExtendedTextLine.SetRange("Table Name", ExtendedTextHeader."Table Name");
                            ExtendedTextLine.SetRange("No.", ExtendedTextHeader."No.");
                            ExtendedTextLine.SetRange("Language Code", ExtendedTextHeader."Language Code");
                            ExtendedTextLine.SetRange("Text No.", ExtendedTextHeader."Text No.");
                            if ExtendedTextLine.FindSet() then begin
                                Result.Append('  ');
                                repeat

                                    Result.Append(ExtendedTextLine.Text);
                                    if strlen(ExtendedTextLine.Text) > 0 then
                                        case ExtendedTextLine.Text[StrLen(ExtendedTextLine.Text)] of
                                            '.', '?', '!', ':':
                                                begin
                                                    Result.Append('<br />');
                                                    Result.Append('  ');
                                                end;
                                            '/':
                                                ;
                                            else
                                                Result.Append(' ');
                                        end
                                    else begin
                                        Result.Append('<br />');
                                        Result.Append('  ');
                                    end;
                                until ExtendedTextLine.Next() = 0;
                            end;
                        end;
                    until ExtendedTextHeader.Next() = 0;
                    result.Append('</div>');
                end;
            end;

            if Shop."Sync Item Attributes" then begin
                ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
                ItemAttributeValueMapping.SetRange("No.", ItemNo);
                if ItemAttributeValueMapping.FindSet() then begin
                    Result.Append('<div class="productAttributes">');
                    Result.Append('  <div class="productAttributesTitle">');
                    Result.Append(AttributeTitleLbl);
                    Result.Append('  </div>');
                    Result.Append('  <table>');
                    Repeat
                        if ItemAttribute.Get(ItemAttributeValueMapping."Item Attribute ID") and (not ItemAttribute.Blocked) then begin
                            Result.Append('    <tr>');
                            Result.Append('      <td class="attributeName">');
                            if ItemAttributeTranslation.Get(ItemAttributeValueMapping."Item Attribute ID", Shop."Language Code") then
                                Result.Append(ItemAttributeTranslation.Name)
                            else
                                Result.Append(ItemAttribute.Name);
                            Result.Append('      </td>');
                            Result.Append('      <td class="attributeValue">');
                            if ItemAttrValueTranslation.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID", Shop."Language Code") then
                                Result.Append(ItemAttrValueTranslation.Name)
                            else
                                if ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID") then begin
                                    Result.Append(ItemAttributeValue.Value);
                                    case ItemAttribute.Type of
                                        ItemAttribute.Type::Integer, ItemAttribute.Type::Decimal:
                                            begin
                                                Result.Append(' ');
                                                Result.Append(ItemAttribute."Unit of Measure");
                                            end;
                                    end;
                                end;
                            Result.Append('      </td>');
                            Result.Append('    </tr>');
                        end;
                    until ItemAttributeValueMapping.Next() = 0;
                    Result.Append('  </table>');
                    Result.Append('</div>');
                end;
            end;
            ProductBodyHtml := Result.ToText();
        end;
        Events.OnAfterCreateProductbodyHtml(ItemNo, Shop, ProductBodyHtml);
    end;

    /// <summary> 
    /// Create Product Variant.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemUoM">Parameter of type Record "Item Unit of Measure".</param>
    local procedure CreateProductVariant(ProductId: BigInteger; Item: Record Item; ItemUoM: Record "Item Unit of Measure")
    var
        TempShopifyVariant: Record "Shpfy Variant" temporary;
    begin
        if OnlyUpdatePrice then
            exit;
        Clear(TempShopifyVariant);
        TempShopifyVariant."Product Id" := ProductId;
        FillInProductVariantData(TempShopifyVariant, Item, ItemUoM);
        TempShopifyVariant.Insert(false);
        VariantApi.AddProductVariant(TempShopifyVariant);
    end;

    /// <summary> 
    /// Create Product Variant.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    local procedure CreateProductVariant(ProductId: BigInteger; Item: Record Item; ItemVariant: Record "Item Variant")
    var
        TempShopifyVariant: Record "Shpfy Variant" temporary;
    begin
        Clear(TempShopifyVariant);
        TempShopifyVariant."Product Id" := ProductId;
        FillInProductVariantData(TempShopifyVariant, Item, ItemVariant);
        TempShopifyVariant.Insert(false);
        VariantApi.AddProductVariant(TempShopifyVariant);
    end;

    /// <summary> 
    /// Create Product Variant.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <param name="ItemUoM">Parameter of type Record "Item Unit of Measure".</param>
    local procedure CreateProductVariant(ProductId: BigInteger; Item: Record Item; ItemVariant: Record "Item Variant"; ItemUoM: Record "Item Unit of Measure")
    var
        TempShopifyVariant: Record "Shpfy Variant" temporary;
    begin
        Clear(TempShopifyVariant);
        TempShopifyVariant."Product Id" := ProductId;
        FillInProductVariantData(TempShopifyVariant, Item, ItemVariant, ItemUoM);
        TempShopifyVariant.Insert(false);
        VariantApi.AddProductVariant(TempShopifyVariant);
    end;


    /// <summary> 
    /// Fill In Product Fields.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ShopifyProduct">Parameter of type Record "Shopify Product".</param>
    internal procedure FillInProductFields(Item: Record Item; var ShopifyProduct: Record "Shpfy Product")
    var
        ItemTranslation: Record "Item Translation";
        IsHandled: Boolean;
        Title: Text;
    begin
        if OnlyUpdatePrice then
            exit;
        ItemTranslation.SetRange("Item No.", Item."No.");
        ItemTranslation.SetRange("Language Code", Shop."Language Code");
        ItemTranslation.SetRange("Variant Code", '');
        if ItemTranslation.FindFirst() and (ItemTranslation.Description <> '') then
            Title := ItemTranslation.Description
        else
            Title := Item.Description;
        Events.OnBeforSetProductTitle(Item, Shop."Language Code", Title, IsHandled);
        if not IsHandled then begin
            Events.OnAfterSetProductTitle(Item, Shop."Language Code", Title);
            ShopifyProduct.Title := CopyStr(Title, 1, MaxStrLen(ShopifyProduct.Title));
        end;
        ShopifyProduct.Vendor := CopyStr(GetVendor(Item."Vendor No."), 1, MaxStrLen(ShopifyProduct.Vendor));
        ShopifyProduct."Product Type" := CopyStr(GetProductType(Item."Item Category Code"), 1, MaxStrLen(ShopifyProduct."Product Type"));
        ShopifyProduct.SetDescriptionHtml(CreateProductBody(Item."No."));
        ShopifyProduct."Tags Hash" := ShopifyProduct.CalcTagsHash();
    end;

    /// <summary> 
    /// Fill In Product Variant Data.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemUoM">Parameter of type Record "Item Unit of Measure".</param>
    local procedure FillInProductVariantData(var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; ItemUoM: Record "Item Unit of Measure")
    begin
        if (not Item.Blocked) and (not Item."Sales Blocked") then
            ProductPriceCalc.CalcPrice(Item, '', ItemUoM.Code, ShopifyVariant."Unit Cost", ShopifyVariant.Price, ShopifyVariant."Compare at Price");
        if not OnlyUpdatePrice then begin
            ShopifyVariant."Available For Sales" := (not Item.Blocked) and (not Item."Sales Blocked");
            ShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", '', ItemUoM.Code), 1, MaxStrLen(ShopifyVariant.Barcode));
            ShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
            case Shop."SKU Mapping" of
                Shop."SKU Mapping"::"Bar Code":
                    ShopifyVariant.SKU := ShopifyVariant.Barcode;
                Shop."SKU Mapping"::"Item No.",
                Shop."SKU Mapping"::"Item No. + Variant Code":
                    ShopifyVariant.SKU := Item."No.";
                Shop."SKU Mapping"::"Vendor Item No.":
                    ShopifyVariant.SKU := Item."Vendor Item No.";
            end;
            ShopifyVariant."Tax Code" := Item."Tax Group Code";
            ShopifyVariant.Taxable := true;
            ShopifyVariant.Weight := Item."Gross Weight";
            ShopifyVariant."Option 1 Name" := Shop."Option Name for UoM";
            ShopifyVariant."Option 1 Value" := ItemUoM.Code;
            ShopifyVariant."Shop Code" := Shop.Code;
            ShopifyVariant."Item SystemId" := Item.SystemId;
            ShopifyVariant."UoM Option Id" := 1;
        end;
    end;

    /// <summary> 
    /// Fill In Product Variant Data.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    local procedure FillInProductVariantData(var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; ItemVariant: Record "Item Variant")
    begin
        if (not Item.Blocked) and (not Item."Sales Blocked") then
            ProductPriceCalc.CalcPrice(Item, ItemVariant.Code, Item."Sales Unit of Measure", ShopifyVariant."Unit Cost", ShopifyVariant.Price, ShopifyVariant."Compare at Price");
        if not OnlyUpdatePrice then begin
            ShopifyVariant."Available For Sales" := (not Item.Blocked) and (not Item."Sales Blocked");
            ShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure"), 1, MaxStrLen(ShopifyVariant.Barcode));
            ShopifyVariant.Title := ItemVariant.Description;
            ShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
            case Shop."SKU Mapping" of
                Shop."SKU Mapping"::"Bar Code":
                    ShopifyVariant.SKU := ShopifyVariant.Barcode;
                Shop."SKU Mapping"::"Item No.":
                    ShopifyVariant.SKU := Item."No.";
                Shop."SKU Mapping"::"Item No. + Variant Code":
                    ShopifyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code;
                Shop."SKU Mapping"::"Vendor Item No.":
                    ShopifyVariant.SKU := Item."Vendor Item No.";
            end;
            ShopifyVariant."Tax Code" := Item."Tax Group Code";
            ShopifyVariant.Taxable := true;
            ShopifyVariant.Weight := Item."Gross Weight";
            ShopifyVariant."Option 1 Name" := 'Variant';
            ShopifyVariant."Option 1 Value" := ItemVariant.Code;
            ShopifyVariant."Shop Code" := Shop.Code;
            ShopifyVariant."Item SystemId" := Item.SystemId;
            ShopifyVariant."Item Variant SystemId" := ItemVariant.SystemId;
            ShopifyVariant."UoM Option Id" := 2;
        end;
    end;

    /// <summary> 
    /// Fill In Product Variant Data.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <param name="ItemUoM">Parameter of type Record "Item Unit of Measure".</param>
    local procedure FillInProductVariantData(var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; ItemVariant: Record "Item Variant"; ItemUoM: Record "Item Unit of Measure")

    begin
        if (not Item.Blocked) and (not Item."Sales Blocked") then
            ProductPriceCalc.CalcPrice(Item, ItemVariant.Code, ItemUoM.Code, ShopifyVariant."Unit Cost", ShopifyVariant.Price, ShopifyVariant."Compare at Price");
        if not OnlyUpdatePrice then begin
            ShopifyVariant."Available For Sales" := (not Item.Blocked) and (not Item."Sales Blocked");
            ShopifyVariant.Barcode := CopyStr(GetBarcode(Item."No.", ItemVariant.Code, ItemUoM.Code), 1, MaxStrLen(ShopifyVariant.Barcode));
            ShopifyVariant.Title := ItemVariant.Description;
            ShopifyVariant."Inventory Policy" := Shop."Default Inventory Policy";
            case Shop."SKU Mapping" of
                Shop."SKU Mapping"::"Bar Code":
                    ShopifyVariant.SKU := ShopifyVariant.Barcode;
                Shop."SKU Mapping"::"Item No.":
                    ShopifyVariant.SKU := Item."No.";
                Shop."SKU Mapping"::"Item No. + Variant Code":
                    ShopifyVariant.SKU := Item."No." + Shop."SKU Field Separator" + ItemVariant.Code;
                Shop."SKU Mapping"::"Vendor Item No.":
                    ShopifyVariant.SKU := Item."Vendor Item No.";
            end;
            ShopifyVariant."Tax Code" := Item."Tax Group Code";
            ShopifyVariant.Taxable := true;
            ShopifyVariant.Weight := Item."Gross Weight";
            ShopifyVariant."Option 1 Name" := 'Variant';
            ShopifyVariant."Option 1 Value" := ItemVariant.Code;
            ShopifyVariant."Option 2 Name" := Shop."Option Name for UoM";
            ShopifyVariant."Option 2 Value" := ItemUoM.Code;
            ShopifyVariant."Shop Code" := Shop.Code;
            ShopifyVariant."Item SystemId" := Item.SystemId;
            ShopifyVariant."Item Variant SystemId" := ItemVariant.SystemId;
            ShopifyVariant."UoM Option Id" := 2;
        end;
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
    /// Get Product Type.
    /// </summary>
    /// <param name="ItemCategoryCode">Parameter of type Code[20].</param>
    /// <returns>Return value of type Text.</returns>
    local procedure GetProductType(ItemCategoryCode: Code[20]): Text
    var
        ItemCategory: Record "Item Category";
    begin
        if ItemCategoryCode <> '' then
            if ItemCategory.Get(ItemCategoryCode) then
                if ItemCategory.Description <> '' then
                    exit(ItemCategory.Description);
        exit(ItemCategoryCode);
    end;

    /// <summary> 
    /// Get Vendor.
    /// </summary>
    /// <param name="VendorNo">Parameter of type Code[20].</param>
    /// <returns>Return value of type Text.</returns>
    local procedure GetVendor(VendorNo: Code[20]): Text
    var
        Vendor: Record Vendor;
    begin
        if VendorNo <> '' then
            if Vendor.Get(VendorNo) then
                if Vendor.Name <> '' then
                    exit(Vendor.Name);
        exit(VendorNo);
    end;

    /// <summary> 
    /// Has Change.
    /// </summary>
    /// <param name="RecRef1">Parameter of type RecordRef.</param>
    /// <param name="RecRef2">Parameter of type RecordRef.</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure HasChange(var RecRef1: RecordRef; var RecRef2: RecordRef): Boolean
    var
        Index: Integer;
    begin
        if RecRef1.Number = RecRef2.Number then begin
            for Index := 1 to RecRef1.FieldCount do
                if RecRef1.FieldIndex(Index).Value <> RecRef2.FieldIndex(Index).Value then
                    exit(true);
            exit(false);
        end;
        exit(false);
    end;


    internal procedure SetOnlyUpdatePriceOn()
    begin
        OnlyUpdatePrice := true;
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        if (Shop.Code <> Code) then begin
            Clear(Shop);
            Shop.Get(Code);
            SetShop(Shop);
        end;
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        ProductApi.SetShop(Shop);
        VariantApi.SetShop(Shop);
        ProductPriceCalc.SetShop(Shop);
    end;

    /// <summary> 
    /// Update Product Data.
    /// </summary>
    /// <param name="ProductId">Parameter of type BigInteger.</param>
    local procedure UpdateProductData(ProductId: BigInteger)
    var
        Item: Record Item;
        ItemUoM: Record "Item Unit of Measure";
        ItemVariant: Record "Item Variant";
        ShopifyProduct: Record "Shpfy Product";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        ShopifyVariant: Record "Shpfy Variant";
        RecRef1: RecordRef;
        RecRef2: RecordRef;
        VariantAction: Option " ",Create,Update;
    begin
        if ShopifyProduct.Get(ProductId) and Item.GetBySystemId(ShopifyProduct."Item SystemId") then begin
            if Item.Blocked then
                exit;
            TempShopifyProduct := ShopifyProduct;
            FillInProductFields(Item, ShopifyProduct);
            RecRef1.GetTable(ShopifyProduct);
            RecRef2.GetTable(TempShopifyProduct);
            if HasChange(RecRef1, RecRef2) then begin
                ShopifyProduct."Last Updated by BC" := CurrentDateTime;
                ProductApi.UpdateProduct(ShopifyProduct, TempShopifyProduct);
                ShopifyProduct.Modify();
            end;
            ShopifyVariant.SetRange("Product Id", ProductId);
            if ShopifyVariant.FindSet(false, false) then
                repeat
                    if not IsNullGuid(ShopifyVariant."Item SystemId") then
                        if Item.GetBySystemId(ShopifyVariant."Item SystemId") then begin
                            Clear(ItemVariant);
                            if not IsNullGuid((ShopifyVariant."Item Variant SystemId")) then
                                if ItemVariant.GetBySystemId(ShopifyVariant."Item Variant SystemId") then;
                            Clear(ItemUoM);
                            if Shop."UoM as Variant" then
                                case ShopifyVariant."UoM Option Id" of
                                    1:
                                        if ItemUoM.Get(Item."No.", ShopifyVariant."Option 1 Value") then
                                            ;
                                    2:
                                        if ItemUoM.Get(Item."No.", ShopifyVariant."Option 2 Value") then
                                            ;
                                    3:
                                        if ItemUoM.Get(Item."No.", ShopifyVariant."Option 3 Value") then
                                            ;
                                end;
                            UpdateProductVariant(ShopifyVariant, Item, ItemVariant, ItemUoM);
                        end;
                until ShopifyVariant.Next() = 0;
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemUoM.SetRange("Item No.", Item."No.");
            if ItemVariant.FindSet(false, false) then
                repeat
                    VariantAction := VariantAction::" ";
                    Clear(ShopifyVariant);
                    ShopifyVariant.SetRange("Product Id", ProductId);
                    ShopifyVariant.SetRange("Item Variant SystemId", ItemVariant.SystemId);
                    if Shop."UoM as Variant" then begin
                        if ItemUoM.FindSet(false, false) then
                            repeat
                                ShopifyVariant.SetRange("Option 2 Name", Shop."Option Name for UoM");
                                ShopifyVariant.SetRange("Option 2 Value", ItemUoM.Code);
                                if ShopifyVariant.FindFirst() then begin
                                    VariantAction := VariantAction::Update;
                                    ShopifyVariant.SetRange("Option 2 Name");
                                    ShopifyVariant.SetRange("Option 2 Value");
                                end else begin
                                    ShopifyVariant.SetRange("Option 2 Name");
                                    ShopifyVariant.SetRange("Option 2 Value");
                                    ShopifyVariant.SetRange("Option 1 Name", Shop."Option Name for UoM");
                                    ShopifyVariant.SetRange("Option 1 Value", ItemUoM.Code);
                                    if ShopifyVariant.FindFirst() then begin
                                        VariantAction := VariantAction::Update;
                                        ShopifyVariant.SetRange("Option 1 Name");
                                        ShopifyVariant.SetRange("Option 1 Value");
                                    end else begin
                                        ShopifyVariant.SetRange("Option 1 Name");
                                        ShopifyVariant.SetRange("Option 1 Value");
                                        ShopifyVariant.SetRange("Option 3 Name", Shop."Option Name for UoM");
                                        ShopifyVariant.SetRange("Option 3 Value", ItemUoM.Code);
                                        if ShopifyVariant.FindFirst() then begin
                                            VariantAction := VariantAction::Update;
                                            ShopifyVariant.SetRange("Option 3 Name");
                                            ShopifyVariant.SetRange("Option 3 Value");
                                        end else begin
                                            ShopifyVariant.SetRange("Option 3 Name");
                                            ShopifyVariant.SetRange("Option 3 Value");
                                            VariantAction := VariantAction::Create;
                                        end;
                                    end;
                                end;
                                case VariantAction of
                                    VariantAction::Create:
                                        CreateProductVariant(ProductId, Item, ItemVariant, ItemUoM);
                                    VariantAction::Update:
                                        UpdateProductVariant(ShopifyVariant, Item, ItemVariant, ItemUoM);
                                end;
                            until ItemUoM.Next() = 0;
                    end else
                        if ShopifyVariant.FindFirst() then
                            UpdateProductVariant(ShopifyVariant, Item, ItemVariant)
                        else
                            CreateProductVariant(ProductId, Item, ItemVariant);
                until ItemVariant.Next() = 0
            else begin
                Clear(ShopifyVariant);
                ShopifyVariant.SetRange("Product Id", ProductId);
                ShopifyVariant.SetRange("Item Variant SystemId");
                if Shop."UoM as Variant" then
                    if ItemUoM.FindSet(false, false) then
                        repeat
                            ShopifyVariant.SetRange("Option 1 Name", Shop."Option Name for UoM");
                            ShopifyVariant.SetRange("Option 1 Value", ItemUoM.Code);
                            if ShopifyVariant.FindFirst() then begin
                                VariantAction := VariantAction::Update;
                                ShopifyVariant.SetRange("Option 1 Name");
                                ShopifyVariant.SetRange("Option 1 Value");
                            end else begin
                                ShopifyVariant.SetRange("Option 1 Name");
                                ShopifyVariant.SetRange("Option 1 Value");
                                ShopifyVariant.SetRange("Option 2 Name", Shop."Option Name for UoM");
                                ShopifyVariant.SetRange("Option 2 Value", ItemUoM.Code);
                                if ShopifyVariant.FindFirst() then begin
                                    VariantAction := VariantAction::Update;
                                    ShopifyVariant.SetRange("Option 2 Name");
                                    ShopifyVariant.SetRange("Option 2 Value");
                                end else begin
                                    ShopifyVariant.SetRange("Option 2 Name");
                                    ShopifyVariant.SetRange("Option 2 Value");
                                    ShopifyVariant.SetRange("Option 3 Name", Shop."Option Name for UoM");
                                    ShopifyVariant.SetRange("Option 3 Value", ItemUoM.Code);
                                    if ShopifyVariant.FindFirst() then begin
                                        VariantAction := VariantAction::Update;
                                        ShopifyVariant.SetRange("Option 3 Name");
                                        ShopifyVariant.SetRange("Option 3 Value");
                                    end else begin
                                        ShopifyVariant.SetRange("Option 3 Name");
                                        ShopifyVariant.SetRange("Option 3 Value");
                                        VariantAction := VariantAction::Create;
                                    end;
                                end;
                            end;
                            case VariantAction of
                                VariantAction::Create:
                                    CreateProductVariant(ProductId, Item, ItemUoM);
                                VariantAction::Update:
                                    UpdateProductVariant(ShopifyVariant, Item, ItemUoM);
                            end;
                        until ItemUoM.Next() = 0;
            end;
        end;
    end;

    /// <summary> 
    /// Update Product Variant.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemUoM">Parameter of type Record "Item Unit of Measure".</param>
    local procedure UpdateProductVariant(ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; ItemUoM: Record "Item Unit of Measure")
    var
        TempShopifyVariant: Record "Shpfy Variant" temporary;
    begin
        Clear(TempShopifyVariant);
        TempShopifyVariant := ShopifyVariant;
        FillInProductVariantData(ShopifyVariant, Item, ItemUoM);
        VariantApi.UpdateProductVariant(ShopifyVariant, TempShopifyVariant);
    end;

    /// <summary> 
    /// Update Product Variant.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    local procedure UpdateProductVariant(var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; ItemVariant: Record "Item Variant")
    var
        TempShopifyVariant: Record "Shpfy Variant" temporary;
    begin
        Clear(TempShopifyVariant);
        TempShopifyVariant := ShopifyVariant;
        FillInProductVariantData(ShopifyVariant, Item, ItemVariant);
        VariantApi.UpdateProductVariant(ShopifyVariant, TempShopifyVariant);
    end;

    /// <summary> 
    /// Update Product Variant.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    /// <param name="ItemUoM">Parameter of type Record "Item Unit of Measure".</param>
    local procedure UpdateProductVariant(ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; ItemVariant: Record "Item Variant"; ItemUoM: Record "Item Unit of Measure")
    var
        TempShopifyVariant: Record "Shpfy Variant" temporary;
    begin
        Clear(TempShopifyVariant);
        TempShopifyVariant := ShopifyVariant;
        FillInProductVariantData(ShopifyVariant, Item, ItemVariant, ItemUoM);
        VariantApi.UpdateProductVariant(ShopifyVariant, TempShopifyVariant);
    end;
}
