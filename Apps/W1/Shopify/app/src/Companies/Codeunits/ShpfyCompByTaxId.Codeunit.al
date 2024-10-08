namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit ShoShpfypify Comp. By Email/Phone (ID 30304) implements Interface Shpfy ICompany Mapping.
/// </summary>
codeunit 30366 "Shpfy Comp. By Tax Id" implements "Shpfy ICompany Mapping"
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
                    ShopifyCompany.Modify();
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
        ShopifyCustomer: Record "Shpfy Customer";
        Shop: Record "Shpfy Shop";
        CompanyLocation: Record "Shpfy Company Location";
        ShpfyTaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
    begin
        if not IsNullGuid(ShopifyCompany."Customer SystemId") then
            if Customer.GetBySystemId(ShopifyCompany."Customer SystemId") then
                exit(true)
            else begin
                Clear(ShopifyCompany."Customer SystemId");
                ShopifyCompany.Modify();
            end;

        if IsNullGuid(ShopifyCompany."Customer SystemId") then begin
            if ShopifyCompany."Location Id" <> 0 then begin
                CompanyLocation.Get(ShopifyCompany."Location Id");
                if CompanyLocation."Tax Registration Id" <> '' then begin
                    Clear(Customer);
                    Shop.Get(ShopifyCompany."Shop Code");
                    ShpfyTaxRegistrationIdMapping := Shop."Shpfy Comp. Tax Id Mapping";
                    ShpfyTaxRegistrationIdMapping.SetMappingFiltersForCustomers(Customer, CompanyLocation);
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
}