/// <summary>
/// Report Shpfy Sync Stock to Shopify (ID 30102).
/// </summary>
report 30102 "Shpfy Sync Stock to Shopify"
{
    ApplicationArea = All;
    Caption = 'Sync Stock To Shopify';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            var
                ShopifyShopInventory: Record "Shpfy Shop Inventory";
            begin
                ShopifyShopInventory.Reset();
                ShopifyShopInventory.SetRange("Shop Code", Shop.Code);
                CodeUnit.Run(Codeunit::"Shpfy Sync Inventory", ShopifyShopInventory);
            end;
        }
    }

}