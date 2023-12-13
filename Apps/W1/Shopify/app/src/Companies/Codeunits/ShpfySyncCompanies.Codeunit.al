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

    /// <summary> 
    /// Export Customers To Shopify.
    /// </summary>
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
    end;
}