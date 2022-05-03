/// <summary>
/// Codeunit Shpfy Sync Customers (ID 30123).
/// </summary>
codeunit 30123 "Shpfy Sync Customers"
{
    Access = Internal;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    var
        SyncStartTime: DateTime;
    begin
        SetShop(Rec);
        SyncStartTime := CurrentDateTime;
        if Shop."Customer Import From Shopify" = Shop."Customer Import From Shopify"::AllCustomers then
            ImportCustomersFromShopify();
        if Shop."Export Customer To Shopify" then
            ExportCustomersToShopify();

        if Shop.Find() then begin
            Shop.SetLastSyncTime("Shpfy Synchronization Type"::Customers, SyncStartTime);
            Shop.Modify();
        end;
    end;

    var
        Shop: Record "Shpfy Shop";
        CustomerApi: Codeunit "Shpfy Customer API";
        CustomerExport: Codeunit "Shpfy Customer Export";
        CustomerImport: Codeunit "Shpfy Customer Import";
        ErrMsg: Text;

    /// <summary> 
    /// Export Customers To Shopify.
    /// </summary>
    local procedure ExportCustomersToShopify()
    var
        Customer: Record Customer;
    begin
        CustomerExport.Run(Customer);
    end;

    /// <summary> 
    /// Import Customers From Shopify.
    /// </summary>
    local procedure ImportCustomersFromShopify()
    var
        Customer: Record "Shpfy Customer";
        TempCustomer: Record "Shpfy Customer" temporary;
        Id: BigInteger;
        UpdatedAt: DateTime;
        CustomerIds: Dictionary of [BigInteger, DateTime];
    begin
        CustomerApi.RetrieveShopifyCustomerIds(CustomerIds);
        foreach Id in CustomerIds.Keys do begin
            Customer.SetRange(Id, Id);
            if Customer.FindFirst() then begin
                CustomerIds.Get(Id, UpdatedAt);
                if ((Customer."Updated At" = 0DT) or (Customer."Updated At" < UpdatedAt)) and (Customer."Last Updated by BC" < UpdatedAt) then begin
                    TempCustomer := Customer;
                    TempCustomer.Insert(false);
                end;
            end else begin
                Clear(TempCustomer);
                TempCustomer.Id := Id;
                TempCustomer.Insert(false);
            end;
        end;
        Clear(TempCustomer);
        if TempCustomer.FindSet(False, False) then begin
            CustomerImport.SetShop(Shop);
            Repeat
                CustomerImport.SetCustomer(TempCustomer);
                Commit();
                ClearLastError();
                if not CustomerImport.Run() then
                    ErrMsg := GetLastErrorText;
            until TempCustomer.Next() = 0;
        end;
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CustomerApi.SetShop(Shop);
        CustomerImport.SetShop(Shop);
        CustomerExport.SetShop(Shop);
    end;
}