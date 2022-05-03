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
        ErrMsg: Text;

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
        Window: Dialog;
        ProductIds: Dictionary of [BigInteger, DateTime];
        Imported: Integer;
        Skipped: Integer;
        ToImport: Integer;
        Msg: Label 'To Import:#1#######\Skipped:#2#######\Imported:#3#######', Comment = '#1 Number of to import, #2 = Number of skipped, #3 = Number of imported';
    begin
        ProductApi.RetrieveShopifyProductIds(ProductIds);
        if GuiAllowed then begin
            ToImport := ProductIds.Count;
            Window.Open(Msg, ToImport, Skipped, Imported);
            Window.Update(1, ToImport);
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
            Window.Update(2, Skipped);
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
                    Window.Update(3, Imported);
                end;
            until TempProduct.Next() = 0;
        end;
        if GuiAllowed then
            Window.Close();
    end;

    internal procedure SetOnlySyncPriceOn()
    begin
        OnlySyncPrice := true;
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

}