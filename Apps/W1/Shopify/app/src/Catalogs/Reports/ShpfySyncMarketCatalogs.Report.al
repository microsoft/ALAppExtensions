namespace Microsoft.Integration.Shopify;

/// <summary>
/// Report Shpfy Sync Market Catalogs (ID 30121).
/// </summary>
report 30121 "Shpfy Sync Market Catalogs"
{
    ApplicationArea = All;
    Caption = 'Shopify Sync Market Catalogs';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            begin
                CatalogAPI.SetShop(Shop);
                CatalogAPI.GetMarketCatalogs();
            end;
        }
    }

    var
        CatalogAPI: Codeunit "Shpfy Catalog API";

    internal procedure SetShop(ShopCode: Code[20])
    begin
        Shop.Get(ShopCode);
        CatalogAPI.SetShop(Shop);
    end;
}
