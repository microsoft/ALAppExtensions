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
        }
    }

    var
        CatalogAPI: Codeunit "Shpfy Catalog API";
        RunForOneCompany: Boolean;
        CompanyId: BigInteger;

    internal procedure SetCompany(ShopifyCompany: Record "Shpfy Company")
    begin
        CompanyId := ShopifyCompany.Id;
        Shop.Get(ShopifyCompany."Shop Code");
        CatalogAPI.SetShop(Shop);
    end;
}
