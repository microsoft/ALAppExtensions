namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy Company Mapping (ID 30303).
/// </summary>
codeunit 30303 "Shpfy Company Mapping"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";

    internal procedure DoMapping(CompanyId: BigInteger; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
    var
        IMapping: Interface "Shpfy ICompany Mapping";
    begin
        IMapping := Shop."Company Mapping Type";
        exit(IMapping.DoMapping(CompanyId, Shop.Code, TemplateCode, AllowCreate));
    end;

    internal procedure FindMapping(var ShopifyCompany: Record "Shpfy Company"; var TempShopifyCustomer: Record "Shpfy Customer" temporary): Boolean;
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerMapping: Codeunit "Shpfy Customer Mapping";
        PhoneFilter: Text;
    begin
        if not IsNullGuid(ShopifyCompany."Customer SystemId") then
            if Customer.GetBySystemId(ShopifyCompany."Customer SystemId") then
                exit(true)
            else begin
                Clear(ShopifyCompany."Customer SystemId");
                ShopifyCompany.Modify();
            end;

        if IsNullGuid(ShopifyCompany."Customer SystemId") then begin
            if TempShopifyCustomer.Email <> '' then begin
                Customer.SetFilter("E-Mail", '@' + TempShopifyCustomer.Email);
                if Customer.FindFirst() then begin
                    ShopifyCompany."Customer SystemId" := Customer.SystemId;

                    if not ShopifyCustomer.Get(TempShopifyCustomer.Id) then begin
                        ShopifyCustomer.Copy(TempShopifyCustomer);
                        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                        ShopifyCustomer.Insert();
                    end;

                    ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
                    ShopifyCompany.Modify();
                    exit(true);
                end;
            end;
            if TempShopifyCustomer."Phone No." <> '' then begin
                PhoneFilter := CustomerMapping.CreatePhoneFilter(TempShopifyCustomer."Phone No.");
                if PhoneFilter <> '' then begin
                    Clear(Customer);
                    Customer.SetFilter("Phone No.", PhoneFilter);
                    if Customer.FindFirst() then begin
                        ShopifyCompany."Customer SystemId" := Customer.SystemId;

                        if not ShopifyCustomer.Get(TempShopifyCustomer.Id) then begin
                            ShopifyCustomer.Copy(TempShopifyCustomer);
                            ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                            ShopifyCustomer.Insert();
                        end;

                        ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
                        ShopifyCompany.Modify();
                        exit(true);
                    end;
                end;
            end;
        end;
    end;

    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        SetShop(Shop);
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
    end;
}