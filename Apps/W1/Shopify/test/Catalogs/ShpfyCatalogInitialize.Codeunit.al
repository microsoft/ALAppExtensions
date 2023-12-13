codeunit 139639 "Shpfy Catalog Initialize"
{
    SingleInstance = true;

    var
        Any: Codeunit Any;

    internal procedure CreateCatalog(Company: Record "Shpfy Company"): Record "Shpfy Catalog"
    var
        Catalog: Record "Shpfy Catalog";
    begin

        Catalog.DeleteAll();
        Catalog.Init();
        Catalog.Id := Any.IntegerInRange(1, 99999);
        Catalog.Name := 'Name';
        Catalog."Company SystemId" := Company.SystemId;
        Catalog.Insert();
        exit(Catalog);
    end;

    internal procedure CopyParametersFromShop(var Catalog: Record "Shpfy Catalog"; var Shop: Record "Shpfy Shop")
    begin
        Catalog."Allow Line Disc." := Shop."Allow Line Disc.";
        Catalog."Customer Discount Group" := Shop."Customer Discount Group";
        Catalog."Customer Posting Group" := Shop."Customer Posting Group";
        Catalog."Customer Price Group" := Shop."Customer Price Group";
        Catalog."Gen. Bus. Posting Group" := Shop."Gen. Bus. Posting Group";
        Catalog."Prices Including VAT" := Shop."Prices Including VAT";
        Catalog."Tax Area Code" := Shop."Tax Area Code";
        Catalog."Tax Liable" := Shop."Tax Liable";
        Catalog."VAT Bus. Posting Group" := Shop."VAT Bus. Posting Group";
        Catalog."VAT Country/Region Code" := Shop."VAT Country/Region Code";
        Catalog.Modify();
    end;

    internal procedure CatalogResponse(): JsonObject
    var
        JResult: JsonObject;
        ResultLbl: Label '{"data":{"catalogs":{"pageInfo":{"hasNextPage":false},"edges":[{"cursor":"eyJsYXN0X2lkIjoyNTMyNjcxNTExMCwibGFzdF92YWx1ZSI6MjUzMjY3MTUxMTB9","node":{"id":"gid://shopify/CompanyLocationCatalog/25326715110","title":"Test"}}]}},"extensions":{"cost":{"requestedQueryCost":27,"actualQueryCost":3,"throttleStatus":{"maximumAvailable":1000.0,"currentlyAvailable":997,"restoreRate":50.0}}}}';
    begin
        JResult.ReadFrom(ResultLbl);
        exit(JResult);
    end;

    internal procedure CatalogPriceResponse(): JsonObject
    var
        JResult: JsonObject;
        ResultLbl: Label '{"data":{"catalog":{"id":"gid://shopify/CompanyLocationCatalog/25217368294","priceList":{"id":"gid://shopify/PriceList/20079640806","prices":{"edges":[{"cursor":"eyJsYXN0X2lkIjo0NDA2OTAzMTMxMzYzOCwibGFzdF92YWx1ZSI6IjQ0MDY5MDMxMzEzNjM4In0=","node":{"variant":{"id":"gid://shopify/ProductVariant/44069031313638"},"price":{"amount":"4500.0"},"compareAtPrice":null}},{"cursor":"eyJsYXN0X2lkIjo0NDA3NDAwMzc1OTMzNCwibGFzdF92YWx1ZSI6IjQ0MDc0MDAzNzU5MzM0In0=","node":{"variant":{"id":"gid://shopify/ProductVariant/44074003759334"},"price":{"amount":"900.0"},"compareAtPrice":null}},{"cursor":"eyJsYXN0X2lkIjo0NDA3NDAwMzc5MjEwMiwibGFzdF92YWx1ZSI6IjQ0MDc0MDAzNzkyMTAyIn0=","node":{"variant":{"id":"gid://shopify/ProductVariant/44074003792102"},"price":{"amount":"1000.0"},"compareAtPrice":null}},{"cursor":"eyJsYXN0X2lkIjo0NDA3NDEzMjYzNTg3OCwibGFzdF92YWx1ZSI6IjQ0MDc0MTMyNjM1ODc4In0=","node":{"variant":{"id":"gid://shopify/ProductVariant/44074132635878"},"price":{"amount":"0.0"},"compareAtPrice":null}},{"cursor":"eyJsYXN0X2lkIjo0NDA3NDEzMzU4NjE1MCwibGFzdF92YWx1ZSI6IjQ0MDc0MTMzNTg2MTUwIn0=","node":{"variant":{"id":"gid://shopify/ProductVariant/44074133586150"},"price":{"amount":"0.0"},"compareAtPrice":null}},{"cursor":"eyJsYXN0X2lkIjo0NDA3NDEzMzYxODkxOCwibGFzdF92YWx1ZSI6IjQ0MDc0MTMzNjE4OTE4In0=","node":{"variant":{"id":"gid://shopify/ProductVariant/44074133618918"},"price":{"amount":"0.0"},"compareAtPrice":null}}],"pageInfo":{"hasNextPage":false}}}}},"extensions":{"cost":{"requestedQueryCost":204,"actualQueryCost":16,"throttleStatus":{"maximumAvailable":1000.0,"currentlyAvailable":984,"restoreRate":50.0}}}}';
    begin
        JResult.ReadFrom(ResultLbl);
        exit(JResult);
    end;
}
