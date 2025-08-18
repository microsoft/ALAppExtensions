// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

pageextension 30119 "Shpfy Item Card" extends "Item Card"
{
    actions
    {
        addlast(Navigation_Item)
        {
            group(Shopify)
            {
                Visible = ShopifyEnabled;
                ShowAs = SplitButton;

                action("Show product in Shopify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Opens the product in Shopify.';
                    Image = CoupledItem;
                    Enabled = IsProductMapped;

                    trigger OnAction()
                    var
                        ShopifyVariant: Record "Shpfy Variant";
                        SyncProducts: Codeunit "Shpfy Sync Products";
                    begin
                        ShopifyVariant.SetRange("Item SystemId", Rec.SystemId);
                        if ShopifyVariant.Count = 1 then
                            HyperLink(SyncProducts.GetProductUrl(ShopifyVariant))
                        else
                            SyncProducts.GetProductsOverview(ShopifyVariant);
                    end;
                }
                action("Add to Shopify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Adds the item to your Shopify shop.';
                    Image = AddAction;
                    Enabled = AvailableStoresToMap;
                    AccessByPermission = TableData "Shpfy Product" = IMD;

                    trigger OnAction()
                    var
                        Shop: Record "Shpfy Shop";
                        SyncProducts: Codeunit "Shpfy Sync Products";
                    begin
                        if SyncProducts.ConfirmAddItemToShopify(Rec, Shop) then begin
                            SyncProducts.AddItemToShopify(Rec, Shop);
                            if Confirm(ViewInShopifyLbl) then
                                Hyperlink(SyncProducts.GetProductUrl(Rec, Shop.Code));
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
        }
        addlast(Category_Process)
        {
            group(Category_Shopify)
            {
                Visible = ShopifyEnabled;
                Caption = 'Shopify';
                ShowAs = SplitButton;

                actionref("Open product in Shopify_Promoted"; "Show product in Shopify")
                {
                }
                actionref("Add to Shopify_Promoted"; "Add to Shopify")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ShopMgt: Codeunit "Shpfy Shop Mgt.";
    begin
        if GuiAllowed() then
            ShopifyEnabled := ShopMgt.IsEnabled();
    end;

    trigger OnAfterGetRecord()
    begin
        if GuiAllowed() then
            if ShopifyEnabled then begin
                SetIsProductMapped();
                SetAvailableStoresToMap();
            end;
    end;

    var
        ShopifyEnabled: Boolean;
        IsProductMapped: Boolean;
        AvailableStoresToMap: Boolean;
        ViewInShopifyLbl: Label 'The item was added successfully. Do you want to view the new product in Shopify?';

    local procedure SetIsProductMapped()
    var
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
    begin
        IsProductMapped := false;
        ShopifyProduct.SetLoadFields("Item SystemId", "Shop Code");
        ShopifyProduct.SetRange("Item SystemId", Rec.SystemId);
        if ShopifyProduct.FindSet() then
            repeat
                if Shop.Get(ShopifyProduct."Shop Code") then
                    if Shop.Enabled then begin
                        IsProductMapped := true;
                        exit;
                    end;
            until ShopifyProduct.Next() = 0;
    end;

    local procedure SetAvailableStoresToMap()
    var
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
    begin
        AvailableStoresToMap := false;
        Shop.SetRange(Enabled, true);
        if Shop.FindSet() then
            repeat
                ShopifyProduct.SetRange("Item SystemId", Rec.SystemId);
                ShopifyProduct.SetRange("Shop Code", Shop.Code);
                if ShopifyProduct.IsEmpty() then begin
                    AvailableStoresToMap := true;
                    exit;
                end;
            until Shop.Next() = 0;
    end;
}