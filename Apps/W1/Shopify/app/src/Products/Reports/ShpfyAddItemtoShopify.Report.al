/// <summary>
/// Report Shpfy Add Item to Shopify (ID 30106).
/// </summary>
report 30106 "Shpfy Add Item to Shopify"
{
    ApplicationArea = All;
    Caption = 'Shopify Add Item to Shopify';
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
                    Caption = 'Shop Filter';
                    field(Shop; ShopCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Shop Code';
                        Lookup = true;
                        LookupPageId = "Shpfy Shops";
                        TableRelation = "Shpfy Shop";
                        ToolTip = 'Specifies the Shopify Shop.';
                    }
                }
            }
        }
    }

    var
        ShopifyCreateProduct: Codeunit "Shpfy Create Product";
        ShopCode: Code[20];

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Shop">Parameter of type Code[20].</param>
    internal procedure SetShop(Shop: Code[20])
    begin
        ShopCode := Shop;
    end;
}