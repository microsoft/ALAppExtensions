namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

pageextension 30120 "Shpfy Item List" extends "Item List"
{
    actions
    {
        addlast(navigation)
        {
            group(Shopify)
            {
                Visible = ShopifyEnabled;

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

    trigger OnAfterGetCurrRecord()
    begin
        if GuiAllowed() then
            if ShopifyEnabled then
                SetIsProductMapped();
    end;

    var
        ShopifyEnabled: Boolean;
        IsProductMapped: Boolean;

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
}