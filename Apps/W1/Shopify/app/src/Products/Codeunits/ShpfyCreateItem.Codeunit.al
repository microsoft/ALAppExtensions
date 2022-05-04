/// <summary>
/// Codeunit Shpfy Create Item (ID 30171).
/// </summary>
codeunit 30171 "Shpfy Create Item"
{
    Access = Internal;
    Permissions =
        tabledata "Config. Template Header" = r,
        tabledata "Config. Template Line" = r,
        tabledata "Dimensions Template" = r,
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
        TemplateCode: Code[10];

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
                    if not Handled then begin
                        DoCreateItem(ShopifyProduct, Rec, Item, true);
                        ShopifyProduct."Item SystemId" := Item.SystemId;
                        ShopifyProduct.Modify();
                        ProductEvents.OnAfterCreateItem(Shop, ShopifyProduct, Rec, Item);
                    end;
                end;
            case Shop."SKU Mapping" of
                Shop."SKU Mapping"::"Item No. + Variant Code",
                Shop."SKU Mapping"::"Variant Code":
                    CreateItemVariant(ShopifyProduct, Rec, Item);
                Shop."SKU Mapping"::"Item No.":
                    if IsNullGuid(Rec."Item SystemId") or (not Item.GetBySystemId(Rec."Item SystemId")) then
                        if ExistItem(ShopifyProduct, Rec, Item) then begin
                            Rec."Item SystemId" := Item.SystemId;
                            Rec.Modify();
                        end else begin
                            ProductEvents.OnBeforeCreateItem(Shop, ShopifyProduct, Rec, Item, Handled);
                            if not Handled then begin
                                DoCreateItem(ShopifyProduct, Rec, Item, true);
                                ProductEvents.OnAfterCreateItem(Shop, ShopifyProduct, Rec, Item);
                            end;
                        end;
                Shop."SKU Mapping"::"Vendor Item No.":
                    if IsNullGuid(Rec."Item SystemId") or (not Item.GetBySystemId(Rec."Item SystemId")) then
                        if ExistItem(ShopifyProduct, Rec, Item) then begin
                            Rec."Item SystemId" := Item.SystemId;
                            Rec.Modify();
                        end else begin
                            ProductEvents.OnBeforeCreateItem(Shop, ShopifyProduct, Rec, Item, Handled);
                            if not Handled then begin
                                DoCreateItem(ShopifyProduct, Rec, Item, true);
                                ProductEvents.OnAfterCreateItem(Shop, ShopifyProduct, Rec, Item);
                            end;
                        end;
                Shop."SKU Mapping"::"Bar Code":
                    if IsNullGuid(Rec."Item SystemId") or (not Item.GetBySystemId(Rec."Item SystemId")) then
                        if ExistItem(ShopifyProduct, Rec, Item) then begin
                            Rec."Item SystemId" := Item.SystemId;
                            Rec.Modify();
                        end else begin
                            ProductEvents.OnBeforeCreateItem(Shop, ShopifyProduct, Rec, Item, Handled);
                            if not Handled then begin
                                DoCreateItem(ShopifyProduct, Rec, Item, true);
                                ProductEvents.OnAfterCreateItem(Shop, ShopifyProduct, Rec, Item);
                            end;
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
    local procedure CreateItemVariant(var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item);
    var
        ItemVariant: Record "Item Variant";
        ShpfyCreateItem: Codeunit "Shpfy Create Item";
        IsHandled: Boolean;
        Codes: List of [Text];
        ItemNo: Text;
        VariantCode: Text;
    begin
        if (not ShopifyProduct."Has Variants") or ((ShopifyVariant."UoM Option Id" = 1) and (ShopifyVariant."Option 2 Name" = '')) then begin
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
                                            if not IsHandled then begin
                                                DoCreateItem(ShopifyProduct, ShopifyVariant, Item, true);
                                                ProductEvents.OnAfterCreateItem(Shop, ShopifyProduct, ShopifyVariant, Item);
                                            end;
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
                ShpfyCreateItem.CreateReferences(ShopifyProduct, ShopifyVariant, Item, ItemVariant);
                ProductEvents.OnAfterCreateItemVariant(Shop, ShopifyProduct, ShopifyVariant, Item, ItemVariant);
            end;
        end;
    end;

    /// <summary> 
    /// Create New Variant Code.
    /// </summary>
    /// <param name="ShpfyProduct">Parameter of type Record "Shpfy Product".</param>
    /// <param name="ShpfyVariant">Parameter of type Record "Shpfy Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <returns>Return variable "Result" of type Code[10].</returns>
    local procedure CreateNewVariantCode(ShpfyProduct: Record "Shpfy Product"; ShpfyVariant: Record "Shpfy Variant"; Item: Record Item) Result: Code[10]
    var
        ItemVariant: Record "Item Variant";
        IsHandled: Boolean;
    begin
        ProductEvents.OnBeforeCreateItemVariantCode(Shop, ShpfyProduct, ShpfyVariant, Item, Result, IsHandled);
        if not IsHandled then begin
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetFilter(Code, Shop."Variant Prefix" + '*');
            if ItemVariant.IsEmpty then
                Result := Shop."Variant Prefix" + '001'
            else begin
                ItemVariant.FindLast();
                Result := IncStr(ItemVariant.Code);
            end;
            ProductEvents.OnAfterCreateItemVariantCode(Shop, ShpfyProduct, ShpfyVariant, Item, Result);
        end;
    end;

    /// <summary> 
    /// Create References.
    /// </summary>
    /// <param name="ShpfyProduct">Parameter of type Record "Shpfy Product".</param>
    /// <param name="ShpfyVariant">Parameter of type Record "Shpfy Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Record "Item Variant".</param>
    internal procedure CreateReferences(ShpfyProduct: Record "Shpfy Product"; ShpfyVariant: Record "Shpfy Variant"; Item: Record Item; ItemVariant: Record "Item Variant")
    var
        ItemRefMgt: Codeunit "Shpfy Item Reference Mgt.";
    begin
        if ShpfyVariant.Barcode <> '' then
            ItemRefMgt.CreateItemBarCode(Item."No.", ItemVariant.Code, FindUoMCode(ShpfyVariant), ShpfyVariant.Barcode);
        if ShpfyVariant.SKU <> '' then
            case Shop."SKU Mapping" of
                Shop."SKU Mapping"::"Bar Code":
                    ItemRefMgt.CreateItemBarCode(Item."No.", ItemVariant.Code, FindUoMCode(ShpfyVariant), ShpfyVariant.SKU);
                Shop."SKU Mapping"::"Vendor Item No.":
                    if Item."Vendor No." <> '' then begin
                        if ItemVariant.code = '' then begin
                            Item."Vendor Item No." := ShpfyVariant.SKU;
                            Item.Modify();
                        end;
                        ItemRefMgt.CreateItemReference(Item."No.", ItemVariant.Code, FindUoMCode(ShpfyVariant), "Item Reference Type"::Vendor, Item."Vendor No.", ShpfyVariant.SKU);
                    end;
            end;
    end;

    /// <summary> 
    /// Do Create Item.
    /// </summary>
    /// <param name="ShpfyProduct">Parameter of type Record "Shopify Product".</param>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ForVariant">Parameter of type Boolean.</param>
    local procedure DoCreateItem(var ShpfyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; ForVariant: Boolean)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        DimensionsTemplate: Record "Dimensions Template";
        ItemCategory: Record "Item Category";
        ItemUOM: Record "Item Unit of Measure";
        ItemVariant: Record "Item Variant";
        Vendor: Record Vendor;
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        CurrentTemplateCode: Code[10];
        Code: Text;
    begin
        if TemplateCode = '' then
            CurrentTemplateCode := FindItemTemplate(ShpfyProduct, ShopifyVariant)
        else
            CurrentTemplateCode := TemplateCode;
        if ConfigTemplateHeader.Get(CurrentTemplateCode) then begin
            Clear(Item);
            if ShopifyVariant.SKU <> '' then
                case Shop."SKU Mapping" of
                    Shop."SKU Mapping"::"Item No.":
                        Item."No." := CopyStr(ShopifyVariant.SKU, 1, MaxStrLen(Item."No."));
                    Shop."SKU Mapping"::"Item No. + Variant Code":
                        begin
                            ShopifyVariant.SKU.Split(Shop."SKU Field Separator").Get(1, Code);
                            Item."No." := CopyStr(Code, 1, MaxStrLen(Item."No."));
                        end;
                end;
            Item.Insert(true);
            RecRef.GetTable(Item);
            ConfigTemplateManagement.UpdateRecord(ConfigTemplateHeader, RecRef);
            DimensionsTemplate.InsertDimensionsFromTemplates(ConfigTemplateHeader, Item."No.", Database::Item);
            RecRef.SetTable(Item);
            Item.Description := ShpfyProduct.Title;
        end;
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
                ItemUOM.SetRange("Item No.", Item."No.");
                ItemUOM.SetRange(Code, Code);
                if ItemUOM.IsEmpty() then begin
                    Clear(ItemUOM);
                    ItemUOM."Item No." := Item."No.";
                    ItemUOM.Code := CopyStr(Code, 1, MaxStrLen(ItemUOM.Code));
                    ITemUOM."Qty. per Unit of Measure" := 1;
                    ItemUOM.Insert();
                end;
            end;
        end;
        if ShopifyVariant."Unit Cost" <> 0 then
            Item.Validate("Unit Cost", ShopifyVariant."Unit Cost");
        if (Shop."Customer Price Group" <> '') and (ShopifyVariant.Price > 0) then;

        if ShpfyProduct."Product Type" <> '' then begin
            ItemCategory.SetFilter(Description, FilterMgt.CleanFilterValue(ShpfyProduct."Product Type", MaxStrLen(ItemCategory.Description)));
            if ItemCategory.FindFirst() then
                Item."Item Category Code" := ItemCategory.Code;
        end;

        if ShpfyProduct.Vendor <> '' then begin
            Vendor.SetFilter(Name, FilterMgt.CleanFilterValue(ShpfyProduct.Vendor, MaxStrLen(Vendor.Name)));
            if Vendor.FindFirst() then
                Item."Vendor No." := Vendor."No.";
        end;

        Item.Modify();
        if ForVariant then begin
            ShopifyVariant."Item SystemId" := Item.SystemId;
            ShopifyVariant.Modify();
        end else begin
            ShpfyProduct."Item SystemId" := Item.SystemId;
            ShpfyProduct.Modify();
        end;

        Clear(ItemVariant);
        CreateReferences(ShpfyProduct, ShopifyVariant, Item, ItemVariant);
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
    local procedure FindItemTemplate(ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant") Result: Code[10]
    var
        IsHandled: Boolean;
    begin
        ProductEvents.OnBeforeFindItemTemplate(Shop, ShopifyProduct, ShopifyVariant, Result, IsHandled);
        if not IsHandled then begin
            Shop.TestField("Item Template Code");
            Result := Shop."Item Template Code";
            ProductEvents.OnAfterFindItemTemplate(Shop, ShopifyProduct, ShopifyVariant, Result);
        end;
        exit(Result);
    end;

    /// <summary> 
    /// Find Unit of Mesure Code.
    /// </summary>
    /// <param name="ShopifyVariant">Parameter of type Record "Shopify Variant".</param>
    /// <returns>Return value of type Code[10].</returns>
    local procedure FindUoMCode(ShopifyVariant: Record "Shpfy Variant"): Code[10]
    var
        UOM: Record "Unit of Measure";
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
            if UOM.Get(CopyStr(Code.ToUpper(), 1, MaxStrLen(UOM.Code))) then
                exit(UOM.Code)
            else begin
                UOM.SetFilter(Description, '@' + Code);
                if UOM.IsEmpty then begin
#pragma warning disable AA0139
                    if (StrLen(Code) <= MaxStrLen(UOM.Code)) then begin
                        Clear(UOM);
                        UOM.Code := Code;
                        UOM.Description := Code;
                        UOM.Insert();
                        exit(UOM.Code);
                    end;
#pragma warning restore AA0139
                end else begin
                    UOM.FindFirst();
                    exit(UOM.Code);
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
        TemplateCode := Shop."Item Template Code";
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