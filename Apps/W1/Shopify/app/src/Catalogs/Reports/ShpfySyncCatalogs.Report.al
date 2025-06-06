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
                this.SyncShopifyShopCatalogs();
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
        case this.CatalogType of
            this.CatalogType::Company:
                this.SyncCompanyCatalogs();
            this.CatalogType::Market:
                this.SyncMarketCatalogs();
            this.CatalogType::" ":
                begin
                    this.SyncCompanyCatalogs();
                    this.SyncMarketCatalogs();
                end;
        end;
    end;

    local procedure SyncCompanyCatalogs()
    var
        ShopifyCompany: Record "Shpfy Company";
    begin
        if this.RunForOneCompany then
            exit;
        if this.CompanyId <> 0 then begin
            ShopifyCompany.SetRange(Id, this.CompanyId);
            this.RunForOneCompany := true;
        end else begin
            this.CatalogAPI.SetShop(Shop);
            ShopifyCompany.SetRange("Shop Id", Shop."Shop Id");
        end;

        if ShopifyCompany.FindSet() then
            repeat
                this.CatalogAPI.GetCatalogs(ShopifyCompany);
            until ShopifyCompany.Next() = 0;
    end;

    local procedure SyncMarketCatalogs()
    begin
        this.CatalogAPI.SetShop(Shop);
        this.CatalogAPI.GetMarketCatalogs();
    end;

    internal procedure SetCompany(ShopifyCompany: Record "Shpfy Company")
    begin
        this.CompanyId := ShopifyCompany.Id;
        Shop.Get(ShopifyCompany."Shop Code");
        this.CatalogAPI.SetShop(Shop);
    end;

    internal procedure SetCatalogType(ShopifyCatalogType: Enum "Shpfy Catalog Type")
    begin
        this.CatalogType := ShopifyCatalogType;
        this.CatalogAPI.SetCatalogType(this.CatalogType);
    end;
}
