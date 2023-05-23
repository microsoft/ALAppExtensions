/// <summary>
/// Codeunit Shpfy Sync Products (ID 30185).
/// </summary>
codeunit 30185 "Shpfy Sync Products"
{
    Access = Internal;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    var
        SyncStartTime: DateTime;
    begin
        SetShop(Rec);
        SyncStartTime := CurrentDateTime;
        if OnlySyncPrice then
            ExportItemstoShopify()
        else
            case Shop."Sync Item" of
                Shop."Sync Item"::"To Shopify":
                    ExportItemstoShopify();
                Shop."Sync Item"::"From Shopify":
                    begin
                        ImportProductsFromShopify();
                        if Shop.Find() then
                            Shop.SetLastSyncTime("Shpfy Synchronization Type"::Products, SyncStartTime);
                    end;
            end;
    end;

    var
        Shop: Record "Shpfy Shop";
        ProductApi: Codeunit "Shpfy Product API";
        ProductExport: Codeunit "Shpfy Product Export";
        ProductImport: Codeunit "Shpfy Product Import";
        OnlySyncPrice: Boolean;
        NumberOfRecords: Integer;
        ErrMsg: Text;
        DialogMsg: Label '#1#########################', Locked = true;
        SyncInformationProgressLbl: Label 'Synchronizing information with Shopify.', Comment = 'Shopify is a product name.';
        FinishSyncProgressLbl: Label 'Finishing up synchronization with Shopify.', Comment = 'Shopify is a product name.';

    /// <summary> 
    /// Export Items To Shopify.
    /// </summary>
    local procedure ExportItemsToShopify()
    begin
        if OnlySyncPrice then
            ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.Run(Shop);
    end;

    /// <summary> 
    /// Import Products From Shopify.
    /// </summary>
    local procedure ImportProductsFromShopify()
    var
        Product: Record "Shpfy Product";
        TempProduct: Record "Shpfy Product" temporary;
        Id: BigInteger;
        UpdatedAt: DateTime;
        Dialog: Dialog;
        ProductIds: Dictionary of [BigInteger, DateTime];
        Imported: Integer;
        Skipped: Integer;
        ToImport: Integer;
        Msg: Label 'To Import:#1#######\Skipped:#2#######\Imported:#3#######', Comment = '#1 Number of to import, #2 = Number of skipped, #3 = Number of imported';
    begin
        ProductApi.RetrieveShopifyProductIds(ProductIds, NumberOfRecords);
        if GuiAllowed then begin
            ToImport := ProductIds.Count;
            Dialog.Open(Msg, ToImport, Skipped, Imported);
            Dialog.Update(1, ToImport);
        end;
        foreach Id in ProductIds.Keys do
            if Product.Get(Id) then begin
                ProductIDs.Get(Id, UpdatedAt);
                if ((Product."Updated At" < UpdatedAt) and (Product."Last Updated by BC" < UpdatedAt)) then begin
                    TempProduct := Product;
                    TempProduct.Insert(false);
                end;
            end else begin
                Clear(TempProduct);
                TempProduct.Id := Id;
                TempProduct.Insert(false);
            end;
        if GuiAllowed then begin
            Skipped := ToImport - TempProduct.Count;
            Dialog.Update(2, Skipped);
        end;
        Clear(TempProduct);
        if TempProduct.FindSet(false, false) then begin
            ProductImport.SetShop(Shop);
            repeat
                ProductImport.SetProduct(TempProduct);
                Commit();
                ClearLastError();
                if not ProductImport.Run() then
                    ErrMsg := GetLastErrorText;
                if GuiAllowed then begin
                    Imported += 1;
                    Dialog.Update(3, Imported);
                end;
            until TempProduct.Next() = 0;
        end;
        if GuiAllowed then
            Dialog.Close();
    end;

    internal procedure SetOnlySyncPriceOn()
    begin
        OnlySyncPrice := true;
    end;

    internal procedure SetNumberOfRecords(NumberOfRecordsParam: Integer)
    begin
        NumberOfRecords := NumberOfRecordsParam;
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        Shop.SetRecFilter();
        ProductApi.SetShop(Shop);
        ProductImport.SetShop(Shop);
        ProductExport.SetShop(Shop);
    end;

    internal procedure GetProductUrl(var ShopifyVariant: Record "Shpfy Variant"): Text
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        ShopifyVariant.FindFirst();
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        if ShopifyProduct.URL <> '' then
            exit(ShopifyProduct.URL);
        if ShopifyProduct."Preview URL" <> '' then
            exit(ShopifyProduct."Preview URL");
    end;

    internal procedure GetProductUrl(Item: Record Item; ShopCode: Code[20]): Text
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        ShopifyProduct.SetRange("Item SystemId", Item.SystemId);
        ShopifyProduct.SetRange("Shop Code", ShopCode);
        if ShopifyProduct.FindFirst() then begin
            if ShopifyProduct.URL <> '' then
                exit(ShopifyProduct.URL);
            if ShopifyProduct."Preview URL" <> '' then
                exit(ShopifyProduct."Preview URL");
        end;
    end;

    internal procedure GetProductsOverview(var ShopifyVariant: Record "Shpfy Variant")
    var
        ShopifyProduct: Record "Shpfy Product";
        ShopifyProductsOverview: Page "Shpfy Products Overview";
        ProductIdFilter: Text;
    begin
        ShopifyVariant.FindSet();
        repeat
            ProductIdFilter += Format(ShopifyVariant."Product Id") + '|';
        until ShopifyVariant.Next() = 0;
        ProductIdFilter := ProductIdFilter.TrimEnd('|');
        ShopifyProduct.SetFilter(Id, ProductIdFilter);
        ShopifyProductsOverview.SetTableView(ShopifyProduct);
        ShopifyProductsOverview.RunModal();
    end;

    internal procedure ConfirmAddItemToShopify(Item: Record Item; var ShopifyShop: Record "Shpfy Shop"): Boolean
    var
        ShopifyProduct: Record "Shpfy Product";
        ShopSelection: Page "Shpfy Shop Selection";
        AddItemConfirm: Page "Shpfy Add Item Confirm";
        MappedShopsFilter: Text;
    begin
        ShopifyShop.SetRange(Enabled, true);
        if ShopifyShop.Count = 1 then begin
            ShopifyShop.FindFirst();
            AddItemConfirm.SetItemDescription(Item.Description);
            AddItemConfirm.SetShopCode(ShopifyShop.Code);
            AddItemConfirm.SetIsActive(ShopifyShop."Status for Created Products" = ShopifyShop."Status for Created Products"::Active);
            if AddItemConfirm.RunModal() = Action::OK then
                exit(true);
        end else begin
            ShopifyProduct.SetRange("Item SystemId", Item.systemId);
            if ShopifyProduct.FindSet() then begin
                repeat
                    MappedShopsFilter += '<>' + ShopifyProduct."Shop Code" + '&';
                until ShopifyProduct.Next() = 0;
                MappedShopsFilter := MappedShopsFilter.TrimEnd('&');
                ShopifyShop.SetFilter(Code, MappedShopsFilter);
            end;
            ShopSelection.SetTableView(ShopifyShop);
            if ShopifyShop.Count = 1 then begin
                ShopifyShop.FindFirst();
                AddItemConfirm.SetItemDescription(Item.Description);
                AddItemConfirm.SetShopCode(ShopifyShop.Code);
                AddItemConfirm.SetIsActive(ShopifyShop."Status for Created Products" = ShopifyShop."Status for Created Products"::Active);
                if AddItemConfirm.RunModal() = Action::OK then
                    exit(true);
            end else begin
                ShopSelection.LookupMode(true);
                if ShopSelection.RunModal() = Action::LookupOK then begin
                    ShopSelection.GetRecord(ShopifyShop);
                    exit(true);
                end;
            end;
        end;
    end;

    internal procedure AddItemToShopify(Item: Record Item; ShopifyShop: Record "Shpfy Shop")
    var
        ShopLocation: Record "Shpfy Shop Location";
        ShopifyCreateProduct: Codeunit "Shpfy Create Product";
        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
        ProgressDialog: Dialog;
    begin
        if GuiAllowed then begin
            ProgressDialog.Open(DialogMsg);
            ProgressDialog.Update(1, SyncInformationProgressLbl);
        end;
        ShopifyCreateProduct.SetShop(ShopifyShop.Code);
        ShopifyCreateProduct.Run(Item);
        if ShopifyShop."Sync Item Images" = ShopifyShop."Sync Item Images"::"To Shopify" then begin
            if GuiAllowed then
                ProgressDialog.Update(1, FinishSyncProgressLbl);
            BackgroundSyncs.ProductImagesSync(ShopifyShop.Code, Format(ShopifyCreateProduct.GetProductId()));
        end;

        ShopLocation.SetRange("Shop Code", ShopifyShop.Code);
        ShopLocation.SetFilter("Stock Calculation", '<>%1', ShopLocation."Stock Calculation"::Disabled);
        if not ShopLocation.IsEmpty() then
            BackgroundSyncs.InventorySync(ShopifyShop.Code);
    end;
}