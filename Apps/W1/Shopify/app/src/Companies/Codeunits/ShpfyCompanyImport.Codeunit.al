namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy Company Import (ID 30301).
/// </summary>
codeunit 30301 "Shpfy Company Import"
{
    Access = Internal;
    TableNo = "Shpfy Company";

    trigger OnRun()
    begin
        if Rec.Id = 0 then
            exit;

        SetCompany(Rec.Id);

        if not CompanyApi.RetrieveShopifyCompany(ShopifyCompany, TempShopifyCustomer) then begin
            ShopifyCompany.Delete();
            exit;
        end;

        Commit();
        if FindMapping(ShopifyCompany, TempShopifyCustomer) then begin
            if Shop."Shopify Can Update Companies" then begin
                UpdateCustomer.SetShop(Shop);
                UpdateCustomer.UpdateCustomerFromCompany(ShopifyCompany);
            end;
        end else
            if Shop."Auto Create Unknown Companies" then begin
                CreateCustomer.SetShop(Shop);
                CreateCustomer.CreateCustomerFromCompany(ShopifyCompany, TempShopifyCustomer);
            end;
    end;

    var
        Shop: Record "Shpfy Shop";
        ShopifyCompany: Record "Shpfy Company";
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        CompanyApi: Codeunit "Shpfy Company API";
        CreateCustomer: Codeunit "Shpfy Create Customer";
        UpdateCustomer: Codeunit "Shpfy Update Customer";

    internal procedure FindMapping(var Company: Record "Shpfy Company"; var ShopifyCustomer: Record "Shpfy Customer"): Boolean;
    var
        Customer: Record Customer;
        CustomerMapping: Codeunit "Shpfy Customer Mapping";
        PhoneFilter: Text;
    begin
        if not IsNullGuid(Company."Customer SystemId") then
            if Customer.GetBySystemId(Company."Customer SystemId") then
                exit(true)
            else begin
                Clear(Company."Customer SystemId");
                Company.Modify();
            end;

        if IsNullGuid(Company."Customer SystemId") then begin
            if ShopifyCustomer.Email <> '' then begin
                Customer.SetFilter("E-Mail", '@' + ShopifyCustomer.Email);
                if Customer.FindFirst() then begin
                    Company."Customer SystemId" := Customer.SystemId;
                    Company.Modify();
                    exit(true);
                end;
            end;
            if ShopifyCustomer."Phone No." <> '' then begin
                PhoneFilter := CustomerMapping.CreatePhoneFilter(ShopifyCustomer."Phone No.");
                if PhoneFilter <> '' then begin
                    Clear(Customer);
                    Customer.SetFilter("Phone No.", PhoneFilter);
                    if Customer.FindFirst() then begin
                        Company."Customer SystemId" := Customer.SystemId;
                        Company.Modify();
                        exit(true);
                    end;
                end;
            end;
        end;
    end;

    local procedure SetCompany(Id: BigInteger)
    begin
        if Id <> 0 then begin
            Clear(ShopifyCompany);
            ShopifyCompany.SetRange(Id, Id);
            if not ShopifyCompany.FindFirst() then begin
                ShopifyCompany.Id := Id;
                ShopifyCompany."Shop Id" := Shop."Shop Id";
                ShopifyCompany."Shop Code" := Shop.Code;
                ShopifyCompany.Insert(false);
            end;
        end;
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CompanyApi.SetShop(Shop);
    end;
}