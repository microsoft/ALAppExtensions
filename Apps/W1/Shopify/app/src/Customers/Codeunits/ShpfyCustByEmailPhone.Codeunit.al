// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit ShoShpfypify Cust. By Email/Phone (ID 30113) implements Interface Shpfy ICustomer Mapping.
/// </summary>
codeunit 30113 "Shpfy Cust. By Email/Phone" implements "Shpfy ICustomer Mapping"
{
    Access = Internal;

    /// <summary>
    /// DoMapping.
    /// </summary>
    /// <param name="CustomerId">BigInteger.</param>
    /// <param name="JCustomerInfo">JsonObject: {"Name": "", "Name2": "", "Address": "", "Address2": "", "PostCode": "", "City": "", "County": "", "CountryCode": ""}.</param>
    /// <param name="ShopCode">Code[20].</param>
    /// <returns>Return value of type Code[20].</returns>
    internal procedure DoMapping(CustomerId: BigInteger; JCustomerInfo: JsonObject; ShopCode: Code[20]): Code[20];
    begin
        exit(DoMapping(CustomerId, JCustomerInfo, ShopCode, '', false));
    end;

    /// <summary>
    /// DoMapping.
    /// </summary>
    /// <param name="CustomerId">BigInteger.</param>
    /// <param name="JCustomerInfo">JsonObject: {"Name": "", "Name2": "", "Address": "", "Address2": "", "PostCode": "", "City": "", "County": "", "CountryCode": ""}.</param>
    /// <param name="ShopCode">Code[20].</param>
    /// <param name="TemplateCode">Code[10].</param>
    /// <param name="AllowCreate">Boolean.</param>
    /// <returns>Return value of type Code[20].</returns>
    internal procedure DoMapping(CustomerId: BigInteger; JCustomerInfo: JsonObject; ShopCode: Code[20]; TemplateCode: Code[20]; AllowCreate: Boolean): Code[20];
    var
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
        CustomerImport: Codeunit "Shpfy Customer Import";
        CreateCustomer: Codeunit "Shpfy Create Customer";
    begin
        ShopifyCustomer.SetAutoCalcFields("Customer No.");
        if ShopifyCustomer.Get(CustomerId) then begin
            if not IsNullGuid(ShopifyCustomer."Customer SystemId") then begin
                ShopifyCustomer.CalcFields("Customer No.");
                if ShopifyCustomer."Customer No." = '' then begin
                    Clear(ShopifyCustomer."Customer SystemId");
                    ShopifyCustomer.Modify();
                end else
                    exit(ShopifyCustomer."Customer No.");
            end;
            if AllowCreate then begin
                CustomerAddress.SetRange("Customer Id", CustomerId);
                CustomerAddress.SetRange(Default, true);
                if CustomerAddress.FindFirst() then begin
                    CreateCustomer.SetShop(ShopCode);
                    CreateCustomer.SetTemplateCode(TemplateCode);
                    CustomerAddress.SetRecFilter();
                    CreateCustomer.Run(CustomerAddress);
                    ShopifyCustomer.CalcFields("Customer No.");
                    exit(ShopifyCustomer."Customer No.");
                end;
            end;

        end else begin
            CustomerImport.SetShop(ShopCode);
            CustomerImport.SetTemplateCode(TemplateCode);
            CustomerImport.SetCustomer(CustomerId);
            CustomerImport.SetAllowCreate(AllowCreate);
            CustomerImport.Run();
            CustomerImport.GetCustomer(ShopifyCustomer);
            if ShopifyCustomer.Find() then
                ShopifyCustomer.CalcFields("Customer No.");
            exit(ShopifyCustomer."Customer No.");
        end;
        exit('');
    end;
}