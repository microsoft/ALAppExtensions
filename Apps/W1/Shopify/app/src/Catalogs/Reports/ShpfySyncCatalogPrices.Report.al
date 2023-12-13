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

            trigger OnAfterGetRecord()
            begin
                if CompanyId <> '' then
                    SyncCatalogPrices.SetCompanyId(CompanyId);
                SyncCatalogPrices.Run(Shop);
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
                }
            }
        }
    }

    var
        SyncCatalogPrices: Codeunit "Shpfy Sync Catalog Prices";
        CompanyId: Text;
}