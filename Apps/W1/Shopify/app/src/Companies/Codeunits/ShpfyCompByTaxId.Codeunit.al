// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy Comp. By Tax Id (ID 30398) implements Interface Shpfy ICompany Mapping.
/// </summary>
codeunit 30398 "Shpfy Comp. By Tax Id" implements "Shpfy ICompany Mapping", "Shpfy IFind Company Mapping"
{
    Access = Internal;

    internal procedure DoMapping(CompanyId: BigInteger; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
    var
        ShopifyCompany: Record "Shpfy Company";
    begin
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
    end;

    internal procedure FindMapping(var ShopifyCompany: Record "Shpfy Company"; var TempShopifyCustomer: Record "Shpfy Customer" temporary): Boolean
    var
        Customer: Record Customer;
        CompanyLocation: Record "Shpfy Company Location";
    begin
        if not IsNullGuid(ShopifyCompany."Customer SystemId") then
            if Customer.GetBySystemId(ShopifyCompany."Customer SystemId") then
                exit(true)
            else begin
                Clear(ShopifyCompany."Customer SystemId");
                ShopifyCompany.Modify(true);
            end;

        if IsNullGuid(ShopifyCompany."Customer SystemId") then
            if ShopifyCompany."Location Id" <> 0 then begin
                CompanyLocation.Get(ShopifyCompany."Location Id");
                if CompanyLocation."Tax Registration Id" <> '' then
                    exit(FindByTaxRegistrationId(ShopifyCompany, TempShopifyCustomer, CompanyLocation));
            end;
    end;

    local procedure CreateCompany(CompanyId: BigInteger; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
    var
        ShopifyCompany: Record "Shpfy Company";
        TempShopifyCompany: Record "Shpfy Company" temporary;
        CompanyImport: Codeunit "Shpfy Company Import";
    begin
        CompanyImport.SetShop(ShopCode);
        CompanyImport.SetAllowCreate(AllowCreate);
        CompanyImport.SetTemplateCode(TemplateCode);
        TempShopifyCompany.Id := CompanyId;
        TempShopifyCompany.Insert(false);

        CompanyImport.Run(TempShopifyCompany);
        CompanyImport.GetCompany(ShopifyCompany);
        if ShopifyCompany.Find() then
            ShopifyCompany.CalcFields("Customer No.");

        exit(ShopifyCompany."Customer No.");
    end;

    local procedure FindByTaxRegistrationId(var ShopifyCompany: Record "Shpfy Company"; var TempShopifyCustomer: Record "Shpfy Customer" temporary; CompanyLocation: Record "Shpfy Company Location"): Boolean
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        Shop: Record "Shpfy Shop";
        TaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
    begin
        Clear(Customer);
        Shop.Get(ShopifyCompany."Shop Code");
        TaxRegistrationIdMapping := Shop."Shpfy Comp. Tax Id Mapping";
        TaxRegistrationIdMapping.SetMappingFiltersForCustomers(Customer, CompanyLocation);
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
}