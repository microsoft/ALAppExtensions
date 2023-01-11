/// <summary>
/// Report Shpfy Add Item to Shopify (ID 30106).
/// </summary>
report 30106 "Shpfy Add Item to Shopify"
{
    ApplicationArea = All;
    Caption = 'Add Item to Shopify';
    ProcessingOnly = true;
    UsageCategory = Administration;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Item Category Code";
            trigger OnPreDataItem()
            var
                NoShopSellectedErr: Label 'You must select a shop to add the items to.';
            begin
                if ShopCode = '' then
                    Error(NoShopSellectedErr);

                Clear(ShopifyCreateProduct);
                ShopifyCreateProduct.SetShop(ShopCode);
            end;

            trigger OnAfterGetRecord()
            begin
                ShopifyCreateProduct.Run(Item);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(ShopFilter)
                {
                    Caption = 'Options';
                    field(Shop; ShopCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Shop Code';
                        Lookup = true;
                        LookupPageId = "Shpfy Shops";
                        TableRelation = "Shpfy Shop";
                        ToolTip = 'Specifies the Shopify Shop.';
                        ShowMandatory = true;

                        trigger OnValidate()
                        var
                            ShpfyShop: Record "Shpfy Shop";
                            ShpfyLocation: Record "Shpfy Shop Location";
                        begin
                            if ShpfyShop.Get(ShopCode) then begin
                                SyncImagesVisible := ShpfyShop."Sync Item Images" = ShpfyShop."Sync Item Images"::"To Shopify";
                                SyncImages := SyncImagesVisible;
                                ShpfyLocation.SetRange("Shop Code", ShpfyShop.Code);
                                ShpfyLocation.SetFilter("Stock Calculation", '<>%1', ShpfyLocation."Stock Calculation"::Disabled);
                                SyncInventoryVisible := not ShpfyLocation.IsEmpty();
                                SyncInventory := SyncInventoryVisible;
                            end else begin
                                SyncImages := false;
                                SyncImagesVisible := false;
                                SyncInventory := false;
                                SyncInventoryVisible := false;
                            end;
                        end;
                    }
                    field(ImageSync; SyncImages)
                    {
                        ApplicationArea = All;
                        Caption = 'Sync Images';
                        ToolTip = 'Specifies if item images are synced.';
                        Editable = SyncImagesVisible;
                    }
                    field(InventorySync; SyncInventory)
                    {
                        ApplicationArea = All;
                        Caption = 'Sync Inventory';
                        ToolTip = 'Specifies if inventory is synced.';
                        Editable = SyncInventoryVisible;
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            ShpfyShop: Record "Shpfy Shop";
            ShpfyLocation: Record "Shpfy Shop Location";
        begin
            if ShpfyShop.Get(ShopCode) then begin
                SyncImagesVisible := ShpfyShop."Sync Item Images" = ShpfyShop."Sync Item Images"::"To Shopify";
                SyncImages := SyncImagesVisible;
                ShpfyLocation.SetRange("Shop Code", ShpfyShop.Code);
                ShpfyLocation.SetFilter("Stock Calculation", '<>%1', ShpfyLocation."Stock Calculation"::Disabled);
                SyncInventoryVisible := not ShpfyLocation.IsEmpty();
                SyncInventory := SyncInventoryVisible;
            end else begin
                SyncImages := false;
                SyncImagesVisible := false;
                SyncInventory := false;
                SyncInventoryVisible := false;
            end;
        end;
    }

    trigger OnPostReport()
    var
        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
    begin
        if SyncImages then
            BackgroundSyncs.ProductImagesSync(ShopCode);
        if SyncInventory then
            BackgroundSyncs.InventorySync(ShopCode);
    end;

    var
        ShopifyCreateProduct: Codeunit "Shpfy Create Product";
        ShopCode: Code[20];
        SyncImages: Boolean;
        SyncInventory: Boolean;
        SyncInventoryVisible: Boolean;
        SyncImagesVisible: Boolean;



    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Shop">Parameter of type Code[20].</param>
    internal procedure SetShop(Shop: Code[20])
    begin
        ShopCode := Shop;
    end;
}