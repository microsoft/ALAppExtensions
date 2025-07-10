namespace Microsoft.Integration.Shopify;

/// <summary>
/// Report Shpfy Sync Catalog Prices (ID 30116).
/// </summary>
report 30116 "Shpfy Sync Catalog Prices"
{
    Caption = 'Shopify Sync Catalog Prices';
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            trigger OnPreDataItem()
            begin
                if not Shop.HasFilter() then
                    Error(NoShopSelectedErr);
            end;

            trigger OnAfterGetRecord()
            begin
                this.SetCatalogType(this.CatalogType);
                this.SyncCatalogPrices.SetCompanyId(this.CompanyId);
                this.SyncCatalogPrices.Run(Shop);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                field(ShopifyCompanyId; CompanyId)
                {
                    Caption = 'Company Id';
                    Tooltip = 'Specifies the company id to sync prices for. If empty, all companies will be synced.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ShopifyCatalogType; CatalogType)
                {
                    Caption = 'Catalog Type';
                    Tooltip = 'Specifies the catalog type to sync prices for.';
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    var
        SyncCatalogPrices: Codeunit "Shpfy Sync Catalog Prices";
        CompanyId: Text;
        NoShopSelectedErr: Label 'You must select a shop to sync prices for.';
        CatalogType: Enum "Shpfy Catalog Type";

    internal procedure SetCatalogType(ShpfyCatalogType: Enum "Shpfy Catalog Type")
    begin
        this.CatalogType := ShpfyCatalogType;
        this.SyncCatalogPrices.SetCatalogType(ShpfyCatalogType);
    end;
}