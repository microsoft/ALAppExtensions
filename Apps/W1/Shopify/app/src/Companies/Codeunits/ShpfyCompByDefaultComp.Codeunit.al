// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy Comp. By Default Comp. (ID 30305) implements Interface Shpfy ICompany Mapping.
/// </summary>
codeunit 30305 "Shpfy Comp. By Default Comp." implements "Shpfy ICompany Mapping", "Shpfy IFind Company Mapping"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";

    internal procedure DoMapping(CompanyId: BigInteger; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20]
    begin
        Shop.Get(ShopCode);
        exit(Shop."Default Company No.");
    end;

    internal procedure FindMapping(var ShopifyCompany: Record "Shpfy Company"; var TempShopifyCustomer: Record "Shpfy Customer" temporary): Boolean
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
    begin
        if not IsNullGuid(ShopifyCompany."Customer SystemId") then
            if Customer.GetBySystemId(ShopifyCompany."Customer SystemId") then
                exit(true)
            else begin
                Clear(ShopifyCompany."Customer SystemId");
                ShopifyCompany.Modify(true);
            end;

        if IsNullGuid(ShopifyCompany."Customer SystemId") then begin
            Shop.Get(ShopifyCompany."Shop Code");
            if Customer.Get(Shop."Default Company No.") then begin
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