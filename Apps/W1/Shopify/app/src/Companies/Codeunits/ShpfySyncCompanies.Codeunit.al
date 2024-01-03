namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy Sync Companies (ID 30285).
/// </summary>
codeunit 30285 "Shpfy Sync Companies"
{
    Access = Internal;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    var
        SyncStartTime: DateTime;
    begin
        Rec.TestField(Enabled, true);
        SetShop(Rec);
        SyncStartTime := CurrentDateTime;
        if Shop."Company Import From Shopify" = Shop."Company Import From Shopify"::AllCompanies then
            ImportCompaniesFromShopify();
        if Shop."Can Update Shopify Companies" then
            ExportCompaniesToShopify();

        if Shop.Find() then begin
            Shop.SetLastSyncTime("Shpfy Synchronization Type"::Companies, SyncStartTime);
            Shop.Modify();
        end;
    end;

    var
        Shop: Record "Shpfy Shop";
        CompanyExport: Codeunit "Shpfy Company Export";
        CompanyImport: Codeunit "Shpfy Company Import";
        CompanyApi: Codeunit "Shpfy Company API";

    local procedure ImportCompaniesFromShopify()
    var
        Company: Record "Shpfy Company";
        TempCompany: Record "Shpfy Company" temporary;
        Id: BigInteger;
        UpdatedAt: DateTime;
        CompanyIds: Dictionary of [BigInteger, DateTime];
    begin
        CompanyApi.RetrieveShopifyCompanyIds(CompanyIds);
        foreach Id in CompanyIds.Keys do begin
            Company.SetRange(Id, Id);
            if Company.FindFirst() then begin
                CompanyIds.Get(Id, UpdatedAt);
                if ((Company."Updated At" = 0DT) or (Company."Updated At" < UpdatedAt)) and (Company."Last Updated by BC" < UpdatedAt) then begin
                    TempCompany := Company;
                    TempCompany.Insert(false);
                end;
            end else begin
                Clear(TempCompany);
                TempCompany.Id := Id;
                TempCompany.Insert(false);
            end;
        end;
        Clear(TempCompany);
        if TempCompany.FindSet(false) then
            repeat
                CompanyImport.Run(TempCompany);
            until TempCompany.Next() = 0;
    end;

    local procedure ExportCompaniesToShopify()
    var
        Customer: Record Customer;
    begin
        CompanyExport.SetCreateCompanies(false);
        CompanyExport.Run(Customer);
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CompanyExport.SetShop(Shop);
        CompanyImport.SetShop(Shop);
        CompanyApi.SetShop(Shop);
    end;
}