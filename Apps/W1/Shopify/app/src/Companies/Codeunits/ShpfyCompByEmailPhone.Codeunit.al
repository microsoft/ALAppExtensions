namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit ShoShpfypify Comp. By Email/Phone (ID 30304) implements Interface Shpfy ICompany Mapping.
/// </summary>
codeunit 30304 "Shpfy Comp. By Email/Phone" implements "Shpfy ICompany Mapping", "Shpfy IFind Company Mapping"
{
    Access = Internal;

    internal procedure DoMapping(CompanyId: BigInteger; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
    var
        ShopifyCompany: Record "Shpfy Company";
    begin
        ShopifyCompany.SetAutoCalcFields("Customer No.");
        if ShopifyCompany.Get(CompanyId) then begin
            if not IsNullGuid(ShopifyCompany."Customer SystemId") then begin
                ShopifyCompany.CalcFields("Customer No.");
                if ShopifyCompany."Customer No." = '' then begin
                    Clear(ShopifyCompany."Customer SystemId");
                    ShopifyCompany.Modify(true);
                end else
                    exit(ShopifyCompany."Customer No.");
            end;
            exit(CreateCompany(CompanyId, ShopCode, TemplateCode, AllowCreate));
        end else
            exit(CreateCompany(CompanyId, ShopCode, TemplateCode, AllowCreate));
        exit('');
    end;

    internal procedure FindMapping(var ShopifyCompany: Record "Shpfy Company"; var TempShopifyCustomer: Record "Shpfy Customer" temporary): Boolean
    var
        Customer: Record Customer;
    begin
        if not IsNullGuid(ShopifyCompany."Customer SystemId") then
            if Customer.GetBySystemId(ShopifyCompany."Customer SystemId") then
                exit(true)
            else begin
                Clear(ShopifyCompany."Customer SystemId");
                ShopifyCompany.Modify(true);
            end;

        if IsNullGuid(ShopifyCompany."Customer SystemId") then begin
            if TempShopifyCustomer.Email <> '' then
                exit(FindByEmail(ShopifyCompany, TempShopifyCustomer));

            if TempShopifyCustomer."Phone No." <> '' then
                exit(FindByPhoneNo(ShopifyCompany, TempShopifyCustomer));
        end;
    end;

    local procedure CreateCompany(CompanyId: BigInteger; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
    var
        ShopifyCompany: Record "Shpfy Company";
        TempCompany: Record "Shpfy Company" temporary;
        CompanyImport: Codeunit "Shpfy Company Import";
    begin
        CompanyImport.SetShop(ShopCode);
        CompanyImport.SetAllowCreate(AllowCreate);
        CompanyImport.SetTemplateCode(TemplateCode);
        TempCompany.Id := CompanyId;
        TempCompany.Insert();

        CompanyImport.Run(TempCompany);
        CompanyImport.GetCompany(ShopifyCompany);
        if ShopifyCompany.Find() then
            ShopifyCompany.CalcFields("Customer No.");

        exit(ShopifyCompany."Customer No.");
    end;

    local procedure FindByEmail(var ShopifyCompany: Record "Shpfy Company"; TempShopifyCustomer: Record "Shpfy Customer" temporary): Boolean
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
    begin
        Customer.SetFilter("E-Mail", '@' + TempShopifyCustomer.Email);
        if Customer.FindFirst() then begin
            ShopifyCompany."Customer SystemId" := Customer.SystemId;

            if not ShopifyCustomer.Get(TempShopifyCustomer.Id) then begin
                ShopifyCustomer.Copy(TempShopifyCustomer);
                ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                ShopifyCustomer.Insert(true);
            end;

            ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
            ShopifyCompany.Modify(true);
            exit(true);
        end;
    end;

    local procedure FindByPhoneNo(var ShopifyCompany: Record "Shpfy Company"; TempShopifyCustomer: Record "Shpfy Customer" temporary): Boolean
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerMapping: Codeunit "Shpfy Customer Mapping";
        PhoneFilter: Text;
    begin
        PhoneFilter := CustomerMapping.CreatePhoneFilter(TempShopifyCustomer."Phone No.");
        if PhoneFilter <> '' then begin
            Clear(Customer);
            Customer.SetFilter("Phone No.", PhoneFilter);
            if Customer.FindFirst() then begin
                ShopifyCompany."Customer SystemId" := Customer.SystemId;

                if not ShopifyCustomer.Get(TempShopifyCustomer.Id) then begin
                    ShopifyCustomer.Copy(TempShopifyCustomer);
                    ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                    ShopifyCustomer.Insert(true);
                end;

                ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
                ShopifyCompany.Modify(true);
                exit(true);
            end;
        end;
    end;
}