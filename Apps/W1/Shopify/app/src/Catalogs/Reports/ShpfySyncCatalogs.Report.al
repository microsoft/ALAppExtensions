namespace Microsoft.Integration.Shopify;

/// <summary>
/// Report Shpfy Sync Catalogs (ID 30115).
/// </summary>
report 30115 "Shpfy Sync Catalogs"
{
    ApplicationArea = All;
    Caption = 'Shopify Sync Catalogs';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            begin
                SyncShopifyShopCatalogs();
            end;
        }
    }

    var
        CatalogAPI: Codeunit "Shpfy Catalog API";
        RunForOneCompany: Boolean;
        CompanyId: BigInteger;
        CatalogType: Enum "Shpfy Catalog Type";

    local procedure SyncShopifyShopCatalogs()
    begin
        case CatalogType of
            CatalogType::Company:
                SyncCompanyCatalogs();
            CatalogType::Market:
                SyncMarketCatalogs();
            CatalogType::" ":
                begin
                    SyncCompanyCatalogs();
                    SyncMarketCatalogs();
                end;
        end;
    end;

    local procedure SyncCompanyCatalogs()
    var
        ShopifyCompany: Record "Shpfy Company";
    begin
        if RunForOneCompany then
            exit;
        if CompanyId <> 0 then begin
            ShopifyCompany.SetRange(Id, CompanyId);
            RunForOneCompany := true;
        end else begin
            CatalogAPI.SetShop(Shop);
            ShopifyCompany.SetRange("Shop Id", Shop."Shop Id");
        end;

        if ShopifyCompany.FindSet() then
            repeat
                CatalogAPI.GetCatalogs(ShopifyCompany);
            until ShopifyCompany.Next() = 0;
    end;

    local procedure SyncMarketCatalogs()
    begin
        CatalogAPI.SetShop(Shop);
        CatalogAPI.GetMarketCatalogs();
    end;

    internal procedure SetCompany(ShopifyCompany: Record "Shpfy Company")
    begin
        CompanyId := ShopifyCompany.Id;
        Shop.Get(ShopifyCompany."Shop Code");
        CatalogAPI.SetShop(Shop);
    end;

    internal procedure SetCatalogType(ShopifyCatalogType: Enum "Shpfy Catalog Type")
    begin
        CatalogType := ShopifyCatalogType;
        CatalogAPI.SetCatalogType(CatalogType);
    end;
}
