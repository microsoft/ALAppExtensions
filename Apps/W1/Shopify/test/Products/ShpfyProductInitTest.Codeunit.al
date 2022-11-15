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
        ShpfyShop: Record "Shpfy Shop";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        exit(CreateItem(ShpfyShop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 500, 2), WithVariants));
    end;

    internal procedure CreateItem(TemplateCode: code[10]; InitUnitCost: Decimal; InitPrice: Decimal): Record Item
    begin
        exit(CreateItem(TemplateCode, InitUnitCost, InitPrice, false));
    end;

    internal procedure CreateItem(TemplateCode: code[10]; InitUnitCost: Decimal; InitPrice: Decimal; WithVariants: Boolean) Item: Record Item
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ItemVendor: Record "Item Vendor";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        ShpfyItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        RecordRef: RecordRef;
        Index: Integer;
    begin
        Any.SetDefaultSeed();
        Item.Init();
        Item."No." := Any.AlphabeticText(MaxStrLen(Item."No."));
        Item.Insert(true);
        RecordRef.GetTable(Item);
        ConfigTemplateHeader.Get(TemplateCode);
        ConfigTemplateManagement.UpdateRecord(ConfigTemplateHeader, RecordRef);
        RecordRef.SetTable(Item);
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
        ShpfyItemReferenceMgt.CreateItemBarCode(Item."No.", '', Item."Sales Unit of Measure", Any.AlphabeticText(10));
        if WithVariants then
            for Index := 1 to Any.IntegerInRange(1, 5) do
                CreateVariantForItem(Item);
    end;

    local procedure CreateVariantForItem(Item: Record Item)
    var
        ItemVariant: Record "Item Variant";
        ShpfyItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
    begin
        ItemVariant.Init();
        ItemVariant.Validate("Item No.", Item."No.");
        ItemVariant.Code := Any.AlphabeticText(MaxStrLen(ItemVariant.Code));
        ItemVariant.Description := Any.AlphanumericText(50);
        ItemVariant.Insert();
        ShpfyItemReferenceMgt.CreateItemBarCode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", Any.AlphabeticText(10));
        ShpfyItemReferenceMgt.CreateItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.", Any.AlphabeticText(10));
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

#if not CLEAN19
    internal procedure CreateSalesPrice(Code: Code[10]; ItemNo: Code[20]; Price: Decimal)
    var
        CustomerPriceGroup: Record "Customer Price Group";
        SalesPrice: Record "Sales Price";
    begin
        CustomerPriceGroup.Init();
        CustomerPriceGroup.Code := Code;
        CustomerPriceGroup."Allow Line Disc." := true;
        CustomerPriceGroup.Insert();

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
        CustDiscGrp.Init();
        CustDiscGrp.Code := Code;
        CustDiscGrp.Insert();

        SalesLineDiscount.Init();
        SalesLineDiscount.Type := Enum::"Sales Line Discount Type"::Item;
        SalesLineDiscount.Code := ItemNo;
        SalesLineDiscount."Sales Type" := SalesLineDiscount."Sales Type"::"Customer Disc. Group";
        SalesLineDiscount."Sales Code" := CustDiscGrp.Code;
        SalesLineDiscount.Validate("Line Discount %", DiscountPerc);
        SalesLineDiscount.Insert();
    end;
#endif

    internal procedure CreateStandardProduct(ShpfyShop: Record "Shpfy Shop") ShpfyVariant: Record "Shpfy Variant"
    var
        ShpfyProduct: Record "Shpfy Product";
    begin
        ShpfyProduct := InitProduct(ShpfyShop);
        ShpfyProduct.Insert();

        exit(AddProductVariants(ShpfyShop, ShpfyProduct, 1));
    end;

    internal procedure CreateProductWithMultiVariants(ShpfyShop: Record "Shpfy Shop") ShpfyVariant: Record "Shpfy Variant"
    var
        ShpfyProduct: Record "Shpfy Product";
    begin
        ShpfyProduct := InitProduct(ShpfyShop);
        ShpfyProduct."Has Variants" := (ShpfyShop."SKU Mapping" = Enum::"Shpfy SKU Mappging"::"Item No. + Variant Code");
        ShpfyProduct.Insert();
        Clear(LastItemNo);
        exit(AddProductVariants(ShpfyShop, ShpfyProduct, Any.IntegerInRange(2, 5)));
    end;

    internal procedure CreateProductWithVariantCode(ShpfyShop: Record "Shpfy Shop") ShpfyVariant: Record "Shpfy Variant"
    var
        ShpfyProduct: Record "Shpfy Product";
    begin
        ShpfyProduct := InitProduct(ShpfyShop);
        ShpfyProduct."Has Variants" := true;
        ShpfyProduct.Insert();

        exit(AddProductVariants(ShpfyShop, ShpfyProduct, 1));
    end;


    local procedure AddProductVariants(ShpfyShop: Record "Shpfy Shop"; ShpfyProduct: Record "Shpfy Product"; numberOfVariants: Integer) ShpfyVariant: Record "Shpfy Variant"
    var
        Index: Integer;
    begin
        for Index := 1 to numberOfVariants do begin
            clear(ShpfyVariant);
            ShpfyVariant."Shop Code" := ShpfyShop.Code;
            ShpfyVariant.Id := GetShpfyVariantId();
            ShpfyVariant."Product Id" := ShpfyProduct.Id;
            ShpfyVariant.Barcode := Format(Any.IntegerInRange(1111111, 9999999));
            ShpfyVariant."Unit Cost" := Any.DecimalInRange(10, 20, 2);
            ShpfyVariant.SKU := CreateSKUValue(ShpfyShop);
            if ShpfyProduct."Has Variants" then begin
                ShpfyVariant."Option 1 Name" := 'Test Option';
                ShpfyVariant."Option 1 Value" := Any.AlphabeticText(5);
            end;
            ShpfyVariant.Insert();
        end;
        ShpfyVariant.SetRange("Product Id", ShpfyProduct.Id);
        ShpfyVariant.FindFirst();
    end;

    local procedure CreateSKUValue(ShpfyShop: Record "Shpfy Shop"): Text[50]
    var
    begin
        case ShpfyShop."SKU Mapping" of
            "Shpfy SKU Mappging"::" ":
                exit('');
            "Shpfy SKU Mappging"::"Bar Code":
                exit(Format(Any.IntegerInRange(1111111, 9999999)));
            "Shpfy SKU Mappging"::"Item No.",
            "Shpfy SKU Mappging"::"Variant Code",
            "Shpfy SKU Mappging"::"Vendor Item No.":
                exit(Any.AlphabeticText(10));
            "Shpfy SKU Mappging"::"Item No. + Variant Code":
                begin
                    if LastItemNo = '' then
                        LastItemNo := Any.AlphabeticText(10).ToUpper();
                    exit(LastItemNo + ShpfyShop."SKU Field Separator" + ANy.AlphabeticText(5).ToUpper());
                end;
        end;
    end;

    local procedure InitProduct(var ShpfyShop: Record "Shpfy Shop") ShpfyProduct: Record "Shpfy Product"
    var
        ItemCategory: Record "Item Category";
        Vendor: Record Vendor;
    begin
        Any.SetDefaultSeed();
        ShpfyProduct.Init();
        ShpfyProduct.Id := Any.IntegerInRange(10000, 99999);
        ShpfyProduct."Shop Code" := ShpfyShop.Code;
        ShpfyProduct.Title := Any.AlphabeticText(100);
        if ItemCategory.FindFirst() then
            if ItemCategory.Description <> '' then
                ShpfyProduct."Product Type" := ItemCategory.Description
            else
                ShpfyProduct."Product Type" := ItemCategory.Code;
        if Vendor.FindFirst() then
            ShpfyProduct.Vendor := Vendor.Name;
    end;

    local procedure GetShpfyVariantId(): BigInteger
    var
        ShpfyVariant: Record "Shpfy Variant";
    begin
        if ShpfyVariant.FindLast() then
            exit(ShpfyVariant.Id + 1)
        else
            exit(10000);
    end;
}