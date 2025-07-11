namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;
using Microsoft.Finance.Dimension;
using Microsoft.CRM.BusinessRelation;
using Microsoft.Foundation.Address;

/// <summary>
/// Codeunit Shpfy Create Customer (ID 30110).
/// </summary>
codeunit 30110 "Shpfy Create Customer"
{
    Access = Internal;
    Permissions =
        tabledata "Country/Region" = r,
        tabledata Customer = rim,
        tabledata "Dimensions Template" = r;
    TableNo = "Shpfy Customer Address";

    var
        Shop: Record "Shpfy Shop";
        CustomerEvents: Codeunit "Shpfy Customer Events";
        TemplateCode: Code[20];
        NoLocationErr: Label 'No location was found for Shopify company id: %1', Comment = 'Shopify should not be translated. %1 = Shopify company id';

    trigger OnRun()
    var
        Customer: Record Customer;
        Handled: Boolean;
    begin
        CustomerEvents.OnBeforeCreateCustomer(Shop, Rec, Customer, Handled);
        if not Handled then
            DoCreateCustomer(Shop, Rec, Customer);
        CustomerEvents.OnAfterCreateCustomer(Shop, Rec, Customer);
    end;

    /// <summary> 
    /// Do Create Customer.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="CustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    local procedure DoCreateCustomer(Shop: Record "Shpfy Shop"; var CustomerAddress: Record "Shpfy Customer Address"; var Customer: Record Customer);
    var
        ShopifyCustomer: Record "Shpfy Customer";
        CurrentTemplateCode: Code[20];
    begin

        ShopifyCustomer.Get(CustomerAddress."Customer Id");

        if TemplateCode = '' then
            CurrentTemplateCode := FindCustomerTemplate(Shop, CustomerAddress."Country/Region Code")
        else
            CurrentTemplateCode := TemplateCode;

        CreateCustomerFromTemplate(Customer, CurrentTemplateCode, ShopifyCustomer, CustomerAddress);
    end;

    local procedure CreateCustomerFromTemplate(var Customer: Record Customer; CustomerTemplCode: Code[20]; var ShpfyCustomer: Record "Shpfy Customer"; var ShpfyCustomerAddress: Record "Shpfy Customer Address")
    var
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        ShpfyUpdateCustomer: Codeunit "Shpfy Update Customer";
        CustContUpdate: Codeunit "CustCont-Update";
        IsHandled: Boolean;
    begin
        CustomerTemplMgt.CreateCustomerFromTemplate(Customer, IsHandled, CustomerTemplCode);
        ShpfyUpdateCustomer.FillInCustomerFields(Customer, Shop, ShpfyCustomer, ShpfyCustomerAddress);
        Customer.Modify();
        ShpfyCustomerAddress.CustomerSystemId := Customer.SystemId;
        ShpfyCustomerAddress.Modify();
        if IsNullGuid(ShpfyCustomer."Customer SystemId") then begin
            ShpfyCustomer."Customer SystemId" := Customer.SystemId;
            ShpfyCustomer.Modify();
        end;
        CustContUpdate.OnModify(Customer);
    end;

    /// <summary> 
    /// Find Customer Template.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="CountryCode">Parameter of type code[20].</param>
    /// <returns>Return variable "Result" of type Code[20].</returns>
    local procedure FindCustomerTemplate(Shop: Record "Shpfy Shop"; CountryCode: code[20]) Result: Code[20]
    var
        CustomerTemplate: Record "Shpfy Customer Template";
        IsHandled: Boolean;
    begin
        CustomerEvents.OnBeforeFindCustomerTemplate(Shop, CountryCode, Result, IsHandled);
        if not IsHandled then begin
            if CustomerTemplate.Get(Shop.Code, CountryCode) then begin
                if CustomerTemplate."Customer Templ. Code" <> '' then
                    Result := CustomerTemplate."Customer Templ. Code";
            end else begin
                Clear(CustomerTemplate);
                CustomerTemplate."Shop Code" := Shop.Code;
                CustomerTemplate."Country/Region Code" := CountryCode;
                CustomerTemplate.Insert();
            end;
            if Result = '' then begin
                Shop.TestField("Customer Templ. Code");
                Result := Shop."Customer Templ. Code";
            end;
        end;
        CustomerEvents.OnAfterFindCustomerTemplate(Shop, CountryCode, Result);
        exit(Result);
    end;

    internal procedure CreateCustomerFromCompany(var ShopifyCompany: Record "Shpfy Company"; TempShopifyCustomer: Record "Shpfy Customer" temporary)
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        CountryRegion: Record "Country/Region";
        CompanyLocation: Record "Shpfy Company Location";
        ShopifyTaxArea: Record "Shpfy Tax Area";
        CustContUpdate: Codeunit "CustCont-Update";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        UpdateCustomer: Codeunit "Shpfy Update Customer";
        ICounty: Interface "Shpfy ICounty";
        CountryCode: Code[20];
        CurrentTemplateCode: Code[20];
        IsHandled: Boolean;
    begin
        if not CompanyLocation.Get(ShopifyCompany."Location Id") then begin
            ShopifyCompany.Delete();
            Commit();
            Error(NoLocationErr, ShopifyCompany.Id);
        end;

        CountryRegion.SetRange("ISO Code", CompanyLocation."Country/Region Code");
        if CountryRegion.FindFirst() then
            CountryCode := CountryRegion.Code
        else
            CountryCode := CompanyLocation."Country/Region Code";

        if TemplateCode = '' then
            CurrentTemplateCode := FindCustomerTemplate(Shop, CountryCode)
        else
            CurrentTemplateCode := TemplateCode;

        CustomerTemplMgt.CreateCustomerFromTemplate(Customer, IsHandled, CurrentTemplateCode);
        Customer.Validate(Name, ShopifyCompany.Name);
        Customer.Validate("E-Mail", TempShopifyCustomer.Email);
        Customer.Validate(Address, CompanyLocation.Address);
        Customer.Validate("Address 2", CompanyLocation."Address 2");
        Customer.Validate("Country/Region Code", CountryCode);
        Customer.Validate(City, CompanyLocation.City);
        Customer.Validate("Post Code", CompanyLocation.Zip);

        ICounty := Shop."County Source";
        Customer.Validate(County, ICounty.County(CompanyLocation));

        if CompanyLocation."Phone No." <> '' then
            Customer.Validate("Phone No.", CompanyLocation."Phone No.");

        if ShopifyTaxArea.Get(CompanyLocation."Country/Region Code", CompanyLocation."Province Name") then begin
            if (ShopifyTaxArea."Tax Area Code" <> '') then begin
                Customer.Validate("Tax Area Code", ShopifyTaxArea."Tax Area Code");
                Customer.Validate("Tax Liable", ShopifyTaxArea."Tax Liable");
            end;
            if (ShopifyTaxArea."VAT Bus. Posting Group" <> '') then
                Customer.Validate("VAT Bus. Posting Group", ShopifyTaxArea."VAT Bus. Posting Group");
        end;

        if CompanyLocation."Shpfy Payment Terms Id" <> 0 then
            Customer.Validate("Payment Terms Code", UpdateCustomer.GetPaymentTermsCodeFromShopifyPaymentTermsId(CompanyLocation."Shpfy Payment Terms Id"));

        Customer.Modify();

        ShopifyCustomer.Copy(TempShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Insert();

        ShopifyCompany."Customer SystemId" := Customer.SystemId;
        ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
        ShopifyCompany.Modify();

        CustContUpdate.OnModify(Customer);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
    end;

    /// <summary> 
    /// Set Template Code.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetTemplateCode(Code: Code[20])
    begin
        TemplateCode := Code;
    end;
}