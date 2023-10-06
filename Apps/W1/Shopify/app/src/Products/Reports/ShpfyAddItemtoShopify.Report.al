namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

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

                if GuiAllowed then begin
                    CurrItemNo := Item."No.";
                    ProcessDialog.Open(ProcessMsg, CurrItemNo);
                    ProcessDialog.Update();
                end;
            end;

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed then begin
                    CurrItemNo := Item."No.";
                    ProcessDialog.Update();
                end;

                ShopifyCreateProduct.Run(Item);

                ProductFilter += Format(ShopifyCreateProduct.GetProductId()) + '|';
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed then
                    ProcessDialog.Close();
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
                            Shop: Record "Shpfy Shop";
                            ShopLocation: Record "Shpfy Shop Location";
                        begin
                            if Shop.Get(ShopCode) then begin
                                SyncImagesVisible := Shop."Sync Item Images" = Shop."Sync Item Images"::"To Shopify";
                                if not SyncImagesVisible or GuiAllowed then
                                    SyncImages := SyncImagesVisible;
                                ShopLocation.SetRange("Shop Code", Shop.Code);
                                ShopLocation.SetFilter("Stock Calculation", '<>%1', ShopLocation."Stock Calculation"::Disabled);
                                SyncInventoryVisible := not ShopLocation.IsEmpty();
                                if not SyncInventoryVisible or GuiAllowed then
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
            Shop: Record "Shpfy Shop";
            ShopLocation: Record "Shpfy Shop Location";
        begin
            if Shop.Get(ShopCode) then begin
                SyncImagesVisible := Shop."Sync Item Images" = Shop."Sync Item Images"::"To Shopify";
                if not SyncImagesVisible then
                    SyncImages := SyncImagesVisible;
                ShopLocation.SetRange("Shop Code", Shop.Code);
                ShopLocation.SetFilter("Stock Calculation", '<>%1', ShopLocation."Stock Calculation"::Disabled);
                SyncInventoryVisible := not ShopLocation.IsEmpty();
                if not SyncInventoryVisible then
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
        ProductFilter := ProductFilter.TrimEnd('|');
        if SyncImages then
            BackgroundSyncs.ProductImagesSync(ShopCode, ProductFilter);
        if SyncInventory then
            BackgroundSyncs.InventorySync(ShopCode);
    end;

    var
        ShopifyCreateProduct: Codeunit "Shpfy Create Product";
        ShopCode: Code[20];
        CurrItemNo: Code[20];
        SyncImages: Boolean;
        SyncInventory: Boolean;
        SyncInventoryVisible: Boolean;
        SyncImagesVisible: Boolean;
        ProcessMsg: Label 'Adding item #1####################', Comment = '#1 = Item no.';
        ProcessDialog: Dialog;
        ProductFilter: Text;



    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Shop">Parameter of type Code[20].</param>
    internal procedure SetShop(Shop: Code[20])
    begin
        ShopCode := Shop;
    end;
}