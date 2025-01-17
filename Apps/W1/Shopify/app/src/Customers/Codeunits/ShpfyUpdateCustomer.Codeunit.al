namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;
using Microsoft.CRM.BusinessRelation;
using Microsoft.Foundation.Address;

/// <summary>
/// Codeunit Shpfy Update Customer (ID 30124).
/// </summary>
codeunit 30124 "Shpfy Update Customer"
{
    Access = Internal;
    Permissions =
        tabledata "Country/Region" = r,
        tabledata Customer = rim;

    TableNo = "Shpfy Customer";

    var
        Shop: Record "Shpfy Shop";
        CustomerEvents: Codeunit "Shpfy Customer Events";
        NoLocationErr: Label 'No location was found for Shopify company id: %1', Comment = 'Shopify should not be translated. %1 = Shopify company id';

    trigger OnRun()
    var
        Customer: Record Customer;
        Handled: Boolean;
    begin
        if Customer.GetBySystemId(Rec."Customer SystemId") then begin
            CustomerEvents.OnBeforeUpdateCustomer(Shop, Rec, Customer, Handled);
            if not Handled then
                DoUpdateCustomer(Shop, Rec, Customer);
            CustomerEvents.OnAfterUpdateCustomer(Shop, Rec, Customer);
        end;
    end;

    /// <summary> 
    /// Do Update Customer.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    local procedure DoUpdateCustomer(Shop: Record "Shpfy Shop"; var ShopifyCustomer: Record "Shpfy Customer"; var Customer: Record Customer);
    var
        CustomerAddress: Record "Shpfy Customer Address";
        CustContUpdate: Codeunit "CustCont-Update";
        NoDefaltAddressErr: Label 'No default address found for Shopify customer id: %1', Comment = '%1 = Shopify customer id';
    begin
        CustomerAddress.SetRange("Customer Id", ShopifyCustomer.Id);
        CustomerAddress.SetRange(Default, true);
        if not CustomerAddress.FindFirst() then
            Error(NoDefaltAddressErr, ShopifyCustomer.Id);

        FillInCustomerFields(Customer, Shop, ShopifyCustomer, CustomerAddress);
        Customer.Modify();
        CustContUpdate.OnModify(Customer);
    end;


    /// <summary> 
    /// Description for FillInCustomerFields.
    /// </summary>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="CustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    internal procedure FillInCustomerFields(var Customer: Record Customer; Shop: Record "Shpfy Shop"; ShopifyCustomer: Record "Shpfy Customer"; CustomerAddress: Record "Shpfy Customer Address")
    var
        CountryRegion: Record "Country/Region";
        ShopifyTaxArea: Record "Shpfy Tax Area";
        IName: Interface "Shpfy ICustomer Name";
        ICounty: interface "Shpfy ICounty";
    begin
        IName := Shop."Name Source";
        Customer.Validate(Name, IName.GetName(CustomerAddress."First Name", CustomerAddress."Last Name", CustomerAddress.Company));

        IName := Shop."Name 2 Source";
        if Customer.Name = '' then
            Customer.Validate(Name, IName.GetName(CustomerAddress."First Name", CustomerAddress."Last Name", CustomerAddress.Company))
        else
            Customer.Validate("Name 2", CopyStr(IName.GetName(CustomerAddress."First Name", CustomerAddress."Last Name", CustomerAddress.Company), 1, MaxStrLen(Customer."Name 2")));

        IName := Shop."Contact Source";
        Customer.Validate(Contact, IName.GetName(CustomerAddress."First Name", CustomerAddress."Last Name", CustomerAddress.Company));

        if Customer.Name = '' then begin
            Customer.Validate(Name, Customer.Contact);
            Customer.Validate(Contact, '');
        end;

        Customer.Validate(Address, CustomerAddress."Address 1");
        Customer.Validate("Address 2", CopyStr(CustomerAddress."Address 2", 1, MaxStrLen(Customer."Address 2")));

        CountryRegion.SetRange("ISO Code", CustomerAddress."Country/Region Code");
        if CountryRegion.FindFirst() then
            Customer.Validate("Country/Region Code", CountryRegion.Code)
        else
            Customer."Country/Region Code" := CustomerAddress."Country/Region Code";

        ICounty := Shop."County Source";
        Customer.Validate(County, ICounty.County((CustomerAddress)));

        Customer.Validate("Post Code", CustomerAddress.Zip);
        Customer.City := CopyStr(CustomerAddress.City, 1, MaxStrLen(Customer.City));

        if CustomerAddress.Phone = '' then begin
            if ShopifyCustomer."Phone No." <> '' then
                Customer.Validate("Phone No.", ShopifyCustomer."Phone No.");
        end else
            Customer.Validate("Phone No.", CustomerAddress.Phone);

        if ShopifyCustomer.Email <> '' then
            Customer.Validate("E-Mail", CopyStr(ShopifyCustomer.Email, 1, MaxStrLen(Customer."E-Mail")));

        if ShopifyTaxArea.Get(CustomerAddress."Country/Region Code", CustomerAddress."Province Name") then begin
            if (ShopifyTaxArea."Tax Area Code" <> '') then begin
                Customer.Validate("Tax Area Code", ShopifyTaxArea."Tax Area Code");
                Customer.Validate("Tax Liable", ShopifyTaxArea."Tax Liable");
            end;
            if (ShopifyTaxArea."VAT Bus. Posting Group" <> '') then
                Customer.Validate("VAT Bus. Posting Group", ShopifyTaxArea."VAT Bus. Posting Group");
        end;
    end;

    internal procedure UpdateCustomerFromCompany(var ShopifyCompany: Record "Shpfy Company")
    var
        Customer: Record Customer;
        CountryRegion: Record "Country/Region";
        CompanyLocation: Record "Shpfy Company Location";
        ShopifyTaxArea: Record "Shpfy Tax Area";
        ICounty: Interface "Shpfy ICounty";
    begin
        if not Customer.GetBySystemId(ShopifyCompany."Customer SystemId") then
            exit;

        if not CompanyLocation.Get(ShopifyCompany."Location Id") then
            Error(NoLocationErr, ShopifyCompany.Id);

        Customer.Validate(Name, ShopifyCompany.Name);
        Customer.Validate(Address, CompanyLocation.Address);
        Customer.Validate("Address 2", CompanyLocation."Address 2");

        CountryRegion.SetRange("ISO Code", CompanyLocation."Country/Region Code");
        if CountryRegion.FindFirst() then
            Customer.Validate("Country/Region Code", CountryRegion.Code)
        else
            Customer."Country/Region Code" := CompanyLocation."Country/Region Code";

        Customer.Validate(City, CompanyLocation.City);
        Customer.Validate("Post Code", CompanyLocation.Zip);
        Customer.Validate(County, CompanyLocation."Province Code");

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

        Customer.Modify();
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
}