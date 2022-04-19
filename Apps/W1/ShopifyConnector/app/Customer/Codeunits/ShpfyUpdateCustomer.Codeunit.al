/// <summary>
/// Codeunit Shpfy Update Customer (ID 30124).
/// </summary>
codeunit 30124 "Shpfy Update Customer"
{
    Access = Internal;
    Permissions =
        tabledata "Config. Template Header" = r,
        tabledata "Config. Template Line" = r,
        tabledata "Country/Region" = r,
        tabledata Customer = rim,
        tabledata "Dimensions Template" = r;
    TableNo = "Shpfy Customer";

    var
        Shop: Record "Shpfy Shop";
        CustomerEvents: Codeunit "Shpfy Customer Events";

    trigger OnRun()
    var
        Customer: Record Customer;
        Handled: Boolean;
    begin
        if Customer.GetBySystemId(Rec."Customer SystemId") then begin
            CustomerEvents.OnBeforeUpdateCustomer(Shop, Rec, Customer, Handled);
            if not Handled then begin
                DoUpdateCustomer(Shop, Rec, Customer);
                CustomerEvents.OnAfterUpdateCustomer(Shop, Rec, Customer);
            end;
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
        Address: Record "Shpfy Customer Address";
        CustCont: Codeunit "CustCont-Update";
        NoDefaltAddressErr: Label 'No default address found for Shopify customer id: %1', Comment = '%1 = Shopify customer id';
    begin
        Address.SetRange("Customer Id", ShopifyCustomer.Id);
        Address.SetRange(Default, true);
        if not Address.FindFirst() then
            Error(NoDefaltAddressErr, ShopifyCustomer.Id);

        FillInCustomerFields(Customer, Shop, ShopifyCustomer, Address);
        Customer.Modify();
        CustCont.OnModify(Customer);
    end;


    /// <summary> 
    /// Description for FillInCustomerFields.
    /// </summary>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="Address">Parameter of type Record "Shopify Customer Address".</param>
    internal procedure FillInCustomerFields(var Customer: Record Customer; Shop: Record "Shpfy Shop"; ShopifyCustomer: Record "Shpfy Customer"; Address: Record "Shpfy Customer Address")
    var
        Country: Record "Country/Region";
        ShopifyTaxArea: Record "Shpfy Tax Area";
        IName: Interface "Shpfy ICustomer Name";
        ICounty: interface "Shpfy ICounty";
    begin
        IName := Shop."Name Source";
        Customer.Validate(Name, IName.GetName(Address."First Name", Address."Last Name", Address.Company));
        IName := Shop."Name 2 Source";
        Customer.Validate("Name 2", IName.GetName(Address."First Name", Address."Last Name", Address.Company));

        if Customer.Name = '' then begin
            Customer.Validate(Name, Customer."Name 2");
            Customer.Validate("Name 2", '');
        end;

        IName := Shop."Contact Source";
        Customer.Validate(Contact, IName.GetName(Address."First Name", Address."Last Name", Address.Company));

        if Customer.Name = '' then begin
            Customer.Validate(Name, Customer.Contact);
            Customer.Validate(Contact, '');
        end;

        Customer.Validate(Address, Address."Address 1");
        Customer.Validate("Address 2", CopyStr(Address."Address 2", 1, MaxStrLen(Customer."Address 2")));
        Customer.Validate("Post Code", Address.Zip);
        Customer.Validate(City, CopyStr(Address.City, 1, MaxStrLen(Customer.City)));

        ICounty := Shop."County Source";
        Customer.Validate(County, ICounty.County((Address)));

        Country.SetRange("ISO Code", Address."Country/Region Code");
        if Country.FindFirst() then
            Customer.Validate("Country/Region Code", Country.Code)
        else
            Customer.Validate("Country/Region Code", Address."Country/Region Code");

        if Address.Phone = '' then begin
            if ShopifyCustomer."Phone No." <> '' then
                Customer.Validate("Phone No.", ShopifyCustomer."Phone No.");
        end else
            Customer.Validate("Phone No.", Address.Phone);

        if ShopifyCustomer.Email <> '' then
            Customer.Validate("E-Mail", CopyStr(ShopifyCustomer.Email, 1, MaxStrLen(Customer."E-Mail")));

        if ShopifyTaxArea.Get(Address."Country/Region Code", Address."Province Name") then begin
            if (ShopifyTaxArea."Tax Area Code" <> '') then begin
                Customer.Validate("Tax Area Code", ShopifyTaxArea."Tax Area Code");
                Customer.Validate("Tax Liable", ShopifyTaxArea."Tax Liable");
            end;
            if (ShopifyTaxArea."VAT Bus. Posting Group" <> '') then
                Customer.Validate("VAT Bus. Posting Group", ShopifyTaxArea."VAT Bus. Posting Group");
        end;
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