/// <summary>
/// Codeunit Shpfy Product Init Test (ID 139603).
/// </summary>
codeunit 139603 "Shpfy Product Init Test"
{
    var
        Any: codeunit Any;
        LastItemNo: Code[20];

    internal procedure CreateGenProdPostingGroup(Code: Code[20]) GenProdPostingGroup: Record "Gen. Product Posting Group";
    begin
        GenProdPostingGroup.SetRange(Code);
        if not GenProdPostingGroup.Get(Code) then begin
            Clear(GenProdPostingGroup);
            GenProdPostingGroup.Code := Code;
            GenProdPostingGroup."Def. VAT Prod. Posting Group" := CreateVatProdPostingGroup(Code).Code;
            GenProdPostingGroup.Insert();
        end;
    end;

    internal procedure CreateVatProdPostingGroup(Code: Code[20]) VatProdPostingGroup: Record "VAT Product Posting Group"
    begin
        VatProdPostingGroup.SetRange(Code);
        if not VatProdPostingGroup.Get(Code) then begin
            Clear(VatProdPostingGroup);
            VatProdPostingGroup.Code := Code;
            VatProdPostingGroup.Insert();
        end;
    end;

    internal procedure CreateInventoryPostingGroup(Code: Code[20]) InventoryPostingGroup: Record "Inventory Posting Group"
    begin
        InventoryPostingGroup.SetRange(Code);
        if not InventoryPostingGroup.Get(Code) then begin
            Clear(InventoryPostingGroup);
            InventoryPostingGroup.Code := Code;
            InventoryPostingGroup.Insert();
        end;
    end;

    internal procedure CreateItem(): Record Item
    begin
        exit(CreateItem(false));
    end;

    internal procedure CreateItem(WithVariants: Boolean): Record Item
    var
        Shop: Record "Shpfy Shop";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ItemTemplateCode: Code[20];
    begin
        Shop := InitializeTest.CreateShop();
        ItemTemplateCode := Shop."Item Templ. Code";
        exit(CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 500, 2), WithVariants));
    end;

    internal procedure CreateItem(TemplateCode: code[20]; InitUnitCost: Decimal; InitPrice: Decimal): Record Item
    begin
        exit(CreateItem(TemplateCode, InitUnitCost, InitPrice, false));
    end;

    internal procedure CreateItem(TemplateCode: code[20]; InitUnitCost: Decimal; InitPrice: Decimal; WithVariants: Boolean) Item: Record Item
    var
        ItemTempl: Record "Item Templ.";
        ItemVendor: Record "Item Vendor";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        Index: Integer;
    begin
        Any.SetDefaultSeed();
        Item.Init();
        Item."No." := Any.AlphabeticText(MaxStrLen(Item."No."));
        Item.Insert(true);
        ItemTempl.Get(TemplateCode);
        ItemTemplMgt.ApplyItemTemplate(Item, ItemTempl);
        Item.Validate("Price/Profit Calculation", Enum::"Item Price Profit Calculation"::"Profit=Price-Cost");
        Item.Validate("Unit Price", InitPrice);
        Item.Validate("Unit Cost", InitUnitCost);
        Item."Vendor No." := Any.AlphabeticText(MaxStrLen(Item."Vendor No."));
        Item."Vendor Item No." := Any.AlphabeticText(MaxStrLen(Item."Vendor Item No."));
        Item.Modify();
        ItemVendor.Init();
        ItemVendor."Item No." := Item."No.";
        ItemVendor."Vendor Item No." := Item."Vendor Item No.";
        ItemVendor.Insert();
        CreateExtendedText(Item);
        CreateItemAttributes(Item);
        ItemReferenceMgt.CreateItemBarCode(Item."No.", '', Item."Sales Unit of Measure", Any.AlphabeticText(10));
        if WithVariants then
            for Index := 1 to Any.IntegerInRange(1, 5) do
                CreateVariantForItem(Item);
    end;

    local procedure CreateVariantForItem(Item: Record Item)
    var
        ItemVariant: Record "Item Variant";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
    begin
        ItemVariant.Init();
        ItemVariant.Validate("Item No.", Item."No.");
        ItemVariant.Code := Any.AlphabeticText(MaxStrLen(ItemVariant.Code));
        ItemVariant.Description := Any.AlphanumericText(50);
        ItemVariant.Insert();
        ItemReferenceMgt.CreateItemBarCode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", Any.AlphabeticText(10));
        ItemReferenceMgt.CreateItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.", Any.AlphabeticText(10));
    end;

    local procedure CreateExtendedText(Item: Record Item)
    var
        ExtendedTextHeader: Record "Extended Text Header";
        LineNo: Integer;
    begin
        ExtendedTextHeader.Init();
        ExtendedTextHeader."Table Name" := "Extended Text Table Name"::Item;
        ExtendedTextHeader."No." := Item."No.";
        ExtendedTextHeader.Insert();
        for LineNo := 1 to Any.IntegerInRange(2, 5) do
            CreateExtendedTextLine(ExtendedTextHeader, LineNo * 10000);
    end;

    local procedure CreateExtendedTextLine(ExtendedTextHeader: Record "Extended Text Header"; LineNo: Integer)
    var
        ExtendedTextLine: Record "Extended Text Line";
    begin
        ExtendedTextLine.Init();
        ExtendedTextLine."Table Name" := ExtendedTextHeader."Table Name";
        ExtendedTextLine."No." := ExtendedTextHeader."No.";
        ExtendedTextLine."Language Code" := ExtendedTextHeader."Language Code";
        ExtendedTextLine."Text No." := ExtendedTextHeader."Text No.";
        ExtendedTextLine."Line No." := LineNo;
        ExtendedTextLine.Text := Any.AlphanumericText(Any.IntegerInRange(1, MaxStrLen(ExtendedTextLine.Text)));
        ExtendedTextLine.Insert();
    end;

    local procedure CreateItemAttributes(Item: Record Item)
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        Index: Integer;
    begin
        for index := 1 to Any.IntegerInRange(1, 5) do begin
            ItemAttribute := CreateItemAttribute();

            ItemAttributeValueMapping.Init();
            ItemAttributeValueMapping."Table ID" := Database::Item;
            ItemAttributeValueMapping."No." := Item."No.";
            ItemAttributeValueMapping."Item Attribute ID" := ItemAttribute.ID;
            ItemAttributeValueMapping."Item Attribute Value ID" := CreateItemAttributeValueForItemAttribute(ItemAttribute).ID;
            ItemAttributeValueMapping.Insert();
        end;
    end;

    local procedure CreateItemAttribute() ItemAttribute: Record "Item Attribute"
    begin
        ItemAttribute.Init();
        ItemAttribute.Name := Any.AlphabeticText(20);
        ItemAttribute.Type := Any.IntegerInRange(0, 4);
        ItemAttribute.Insert();
    end;

    local procedure CreateItemAttributeValueForItemAttribute(ItemAttribute: Record "Item Attribute") ItemAttributeValue: Record "Item Attribute Value";
    begin
        ItemAttributeValue.Init();
        ItemAttributeValue."Attribute ID" := ItemAttribute.ID;
        case ItemAttribute.Type of
            ItemAttribute.Type::Text:
                ItemAttributeValue.Value := Any.AlphanumericText(50);
            ItemAttribute.Type::Integer,
            ItemAttribute.Type::Option:
                ItemAttributeValue."Numeric Value" := Any.IntegerInRange(0, 5);
            ItemAttribute.Type::Decimal:
                ItemAttributeValue."Numeric Value" := Any.DecimalInRange(0, 100, 2);
            ItemAttribute.Type::Date:
                ItemAttributeValue."Date Value" := Any.DateInRange(5);
        end;
        ItemAttributeValue.Insert();
    end;


#if not CLEAN25
    internal procedure CreateSalesPrice(Code: Code[10]; ItemNo: Code[20]; Price: Decimal)
    var
        CustomerPriceGroup: Record "Customer Price Group";
        SalesPrice: Record "Sales Price";
    begin
        if not CustomerPriceGroup.Get(Code) then begin
            CustomerPriceGroup.Init();
            CustomerPriceGroup.Code := Code;
            CustomerPriceGroup."Allow Line Disc." := true;
            CustomerPriceGroup.Insert();
        end;

        SalesPrice.Init();
        SalesPrice."Sales Type" := Enum::"Sales Price Type"::"All Customers";
        SalesPrice.Validate("Item No.", ItemNo);
        SalesPrice.Validate("Unit Price", Price);
        SalesPrice.Insert();
    end;

    internal procedure CreateSalesLineDiscount(Code: Code[10]; ItemNo: Code[20]; DiscountPerc: Decimal) CustDiscGrp: Record "Customer Discount Group"
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        if not CustDiscGrp.get(Code) then begin
            CustDiscGrp.Init();
            CustDiscGrp.Code := Code;
            CustDiscGrp.Insert();
        end;

        SalesLineDiscount.Init();
        SalesLineDiscount.Type := Enum::"Sales Line Discount Type"::Item;
        SalesLineDiscount.Code := ItemNo;
        SalesLineDiscount."Sales Type" := SalesLineDiscount."Sales Type"::"Customer Disc. Group";
        SalesLineDiscount."Sales Code" := CustDiscGrp.Code;
        SalesLineDiscount.Validate("Line Discount %", DiscountPerc);
        SalesLineDiscount.Insert();
    end;
#else
    internal procedure CreatePriceList(Code: Code[10]; ItemNo: Code[20]; Price: Decimal; DiscountPerc: Decimal) CustDiscGrp: Record "Customer Discount Group"
    var
        PriceListLine: Record "Price List Line";
        CustomerPriceGroup: Record "Customer Price Group";
    begin
        if not CustomerPriceGroup.Get(Code) then begin
            CustomerPriceGroup.Init();
            CustomerPriceGroup.Code := Code;
            CustomerPriceGroup."Allow Line Disc." := true;
            CustomerPriceGroup.Insert();
        end;

        if not CustDiscGrp.Get(Code) then begin
            CustDiscGrp.Init();
            CustDiscGrp.Code := Code;
            CustDiscGrp.Insert();
        end;

        PriceListLine.Init();
        PriceListLine."Asset Type" := PriceListLine."Asset Type"::Item;
        PriceListLine."Asset No." := ItemNo;
        PriceListLine."Product No." := ItemNo;
        PriceListLine."Price Type" := PriceListLine."Price Type"::Sale;
        PriceListLine."Amount Type" := PriceListLine."Amount Type"::Discount;
        PriceListLine."Source Type" := PriceListLine."Source Type"::"Customer Disc. Group";
        PriceListLine."Source No." := CustDiscGrp.Code;
        PriceListLine.Validate("Line Discount %", DiscountPerc);
        PriceListLine.Status := PriceListLine.Status::Active;
        PriceListLine.Insert();
    end;

    internal procedure CreateAllCustomerPriceList(Code: Code[10]; ItemNo: Code[20]; Price: Decimal; DiscountPerc: Decimal)
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine.Init();
        PriceListLine."Asset Type" := PriceListLine."Asset Type"::Item;
        PriceListLine."Asset No." := ItemNo;
        PriceListLine."Product No." := ItemNo;
        PriceListLine."Price Type" := PriceListLine."Price Type"::Sale;
        PriceListLine."Amount Type" := PriceListLine."Amount Type"::Discount;
        PriceListLine."Source Type" := PriceListLine."Source Type"::"All Customers";
        PriceListLine.Validate("Line Discount %", DiscountPerc);
        PriceListLine.Status := PriceListLine.Status::Active;
        PriceListLine.Insert();
    end;

    internal procedure CreateCustomerPriceList(Code: Code[10]; ItemNo: Code[20]; Price: Decimal; DiscountPerc: Decimal; Cust: Record "Customer")
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine.Init();
        PriceListLine."Asset Type" := PriceListLine."Asset Type"::Item;
        PriceListLine."Asset No." := ItemNo;
        PriceListLine."Product No." := ItemNo;
        PriceListLine."Price Type" := PriceListLine."Price Type"::Sale;
        PriceListLine."Amount Type" := PriceListLine."Amount Type"::Discount;
        PriceListLine."Source Type" := PriceListLine."Source Type"::Customer;
        PriceListLine."Source No." := Cust."No.";
        PriceListLine.Validate("Line Discount %", DiscountPerc);
        PriceListLine.Status := PriceListLine.Status::Active;
        PriceListLine.Insert();
    end;
#endif

    internal procedure CreateStandardProduct(Shop: Record "Shpfy Shop") ShopifyVariant: Record "Shpfy Variant"
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        ShopifyProduct := InitProduct(Shop);
        ShopifyProduct.Insert();

        exit(AddProductVariants(Shop, ShopifyProduct, 1));
    end;

    internal procedure CreateProductWithMultiVariants(Shop: Record "Shpfy Shop") ShopifyVariant: Record "Shpfy Variant"
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        ShopifyProduct := InitProduct(Shop);
        ShopifyProduct."Has Variants" := (Shop."SKU Mapping" = Enum::"Shpfy SKU Mapping"::"Item No. + Variant Code");
        ShopifyProduct.Insert();
        Clear(LastItemNo);
        exit(AddProductVariants(Shop, ShopifyProduct, Any.IntegerInRange(2, 5)));
    end;

    internal procedure CreateProductWithVariantCode(Shop: Record "Shpfy Shop") ShopifyVariant: Record "Shpfy Variant"
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        ShopifyProduct := InitProduct(Shop);
        ShopifyProduct."Has Variants" := true;
        ShopifyProduct.Insert();

        exit(AddProductVariants(Shop, ShopifyProduct, 1));
    end;


    local procedure AddProductVariants(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; numberOfVariants: Integer) ShopifyVariant: Record "Shpfy Variant"
    var
        Index: Integer;
    begin
        for Index := 1 to numberOfVariants do begin
            clear(ShopifyVariant);
            ShopifyVariant."Shop Code" := Shop.Code;
            ShopifyVariant.Id := GetShopifyVariantId();
            ShopifyVariant."Product Id" := ShopifyProduct.Id;
            ShopifyVariant.Barcode := Format(Any.IntegerInRange(1111111, 9999999));
            ShopifyVariant."Unit Cost" := Any.DecimalInRange(10, 20, 2);
            ShopifyVariant.SKU := CreateSKUValue(Shop);
            if ShopifyProduct."Has Variants" then begin
                ShopifyVariant."Option 1 Name" := 'Test Option';
                ShopifyVariant."Option 1 Value" := Any.AlphabeticText(5);
            end;
            ShopifyVariant.Insert();
        end;
        ShopifyVariant.SetRange("Product Id", ShopifyProduct.Id);
        ShopifyVariant.FindFirst();
    end;

    local procedure CreateSKUValue(Shop: Record "Shpfy Shop"): Text[50]
    begin
        case Shop."SKU Mapping" of
            "Shpfy SKU Mapping"::" ":
                exit('');
            "Shpfy SKU Mapping"::"Bar Code":
                exit(Format(Any.IntegerInRange(1111111, 9999999)));
            "Shpfy SKU Mapping"::"Item No.",
            "Shpfy SKU Mapping"::"Variant Code",
            "Shpfy SKU Mapping"::"Vendor Item No.":
                exit(Any.AlphabeticText(10));
            "Shpfy SKU Mapping"::"Item No. + Variant Code":
                begin
                    if LastItemNo = '' then
                        LastItemNo := Any.AlphabeticText(10).ToUpper();
                    exit(LastItemNo + Shop."SKU Field Separator" + ANy.AlphabeticText(5).ToUpper());
                end;
        end;
    end;

    local procedure InitProduct(var Shop: Record "Shpfy Shop") ShopifyProduct: Record "Shpfy Product"
    var
        ItemCategory: Record "Item Category";
        Vendor: Record Vendor;
    begin
        Any.SetDefaultSeed();
        ShopifyProduct.Init();
        ShopifyProduct.Id := Any.IntegerInRange(10000, 99999);
        ShopifyProduct."Shop Code" := Shop.Code;
        ShopifyProduct.Title := Any.AlphabeticText(100);
        if ItemCategory.FindFirst() then
            if ItemCategory.Description <> '' then
                ShopifyProduct."Product Type" := ItemCategory.Description
            else
                ShopifyProduct."Product Type" := ItemCategory.Code;
        if Vendor.FindFirst() then
            ShopifyProduct.Vendor := Vendor.Name;
    end;

    internal procedure GetShopifyVariantId(): BigInteger
    var
        ShopifyVariant: Record "Shpfy Variant";
    begin
        if ShopifyVariant.FindLast() then
            exit(ShopifyVariant.Id + 1)
        else
            exit(10000);
    end;
}