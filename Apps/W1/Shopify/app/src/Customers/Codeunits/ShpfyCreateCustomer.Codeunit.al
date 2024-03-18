namespace Microsoft.Integration.Shopify;

#if not CLEAN22
using System.IO;
using Microsoft.Foundation.NoSeries;
#endif
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
#if not CLEAN22
        tabledata "Config. Template Header" = r,
        tabledata "Config. Template Line" = r,
#endif
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
#if not CLEAN22
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigConfigTemplateLine: Record "Config. Template Line";
        DimensionsTemplate: Record "Dimensions Template";
#endif
        ShopifyCustomer: Record "Shpfy Customer";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        CustContUpdate: Codeunit "CustCont-Update";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        UpdateCustomer: Codeunit "Shpfy Update Customer";
        CustomerRecordRef: RecordRef;
#endif
        CurrentTemplateCode: Code[20];
    begin

        ShopifyCustomer.Get(CustomerAddress."Customer Id");

        if TemplateCode = '' then
            CurrentTemplateCode := FindCustomerTemplate(Shop, CustomerAddress."Country/Region Code")
        else
            CurrentTemplateCode := TemplateCode;

#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then begin
            if (CurrentTemplateCode <> '') and ConfigTemplateHeader.Get(CurrentTemplateCode) then begin
                Clear(Customer);
                ConfigConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateHeader.Code);
                ConfigConfigTemplateLine.SetRange(Type, ConfigConfigTemplateLine.Type::Field);
                ConfigConfigTemplateLine.SetRange("Table ID", Database::Customer);
                ConfigConfigTemplateLine.SetRange("Field ID", Customer.FieldNo("No. Series"));
                if ConfigConfigTemplateLine.FindFirst() and (ConfigConfigTemplateLine."Default Value" <> '') then
                    NoSeriesManagement.InitSeries(CopyStr(ConfigConfigTemplateLine."Default Value", 1, 20), CopyStr(ConfigConfigTemplateLine."Default Value", 1, 20), 0D, Customer."No.", Customer."No. Series");
                Customer.Insert(true);
                CustomerRecordRef.GetTable(Customer);
                ConfigTemplateManagement.UpdateRecord(ConfigTemplateHeader, CustomerRecordRef);
                DimensionsTemplate.InsertDimensionsFromTemplates(ConfigTemplateHeader, Customer."No.", Database::Customer);
                CustomerRecordRef.SetTable(Customer);
                UpdateCustomer.FillInCustomerFields(Customer, Shop, ShopifyCustomer, CustomerAddress);
                Customer.Modify();
                CustomerAddress.CustomerSystemId := Customer.SystemId;
                CustomerAddress.Modify();
                if IsNullGuid(ShopifyCustomer."Customer SystemId") then begin
                    ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                    ShopifyCustomer.Modify();
                end;
                CustContUpdate.OnModify(Customer);
            end
        end else
            CreateCustomerFromTemplate(Customer, CurrentTemplateCode, ShopifyCustomer, CustomerAddress);
#else
        CreateCustomerFromTemplate(Customer, CurrentTemplateCode, ShopifyCustomer, CustomerAddress);
#endif
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
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        IsHandled: Boolean;
    begin
        CustomerEvents.OnBeforeFindCustomerTemplate(Shop, CountryCode, Result, IsHandled);
        if not IsHandled then begin
            if CustomerTemplate.Get(Shop.Code, CountryCode) then begin
#if not CLEAN22
                if ShpfyTemplates.NewTemplatesEnabled() then begin
                    if CustomerTemplate."Customer Templ. Code" <> '' then
                        Result := CustomerTemplate."Customer Templ. Code";
                end else
                    if CustomerTemplate."Customer Template Code" <> '' then
                        Result := CustomerTemplate."Customer Template Code";
#else
                if CustomerTemplate."Customer Templ. Code" <> '' then
                    Result := CustomerTemplate."Customer Templ. Code";
#endif
            end else begin
                Clear(CustomerTemplate);
                CustomerTemplate."Shop Code" := Shop.Code;
                CustomerTemplate."Country/Region Code" := CountryCode;
                CustomerTemplate.Insert();
            end;
#if not CLEAN22
            if Result = '' then
                if ShpfyTemplates.NewTemplatesEnabled() then begin
                    Shop.TestField("Customer Templ. Code");
                    Result := Shop."Customer Templ. Code"
                end else begin
                    Shop.TestField("Customer Template Code");
                    Result := Shop."Customer Template Code";
                end;
#else
            if Result = '' then begin
                Shop.TestField("Customer Templ. Code");
                Result := Shop."Customer Templ. Code";
            end;
#endif
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
#if not CLEAN22
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigConfigTemplateLine: Record "Config. Template Line";
        DimensionsTemplate: Record "Dimensions Template";
        ShpfyTemplates: Codeunit "Shpfy Templates";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        NoSeriesManagement: Codeunit NoSeriesManagement;
#endif
        CustContUpdate: Codeunit "CustCont-Update";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
#if not CLEAN22
        CustomerRecordRef: RecordRef;
#endif
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

#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then begin
            if (CurrentTemplateCode <> '') and ConfigTemplateHeader.Get(CurrentTemplateCode) then begin
                Clear(Customer);
                ConfigConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateHeader.Code);
                ConfigConfigTemplateLine.SetRange(Type, ConfigConfigTemplateLine.Type::Field);
                ConfigConfigTemplateLine.SetRange("Table ID", Database::Customer);
                ConfigConfigTemplateLine.SetRange("Field ID", Customer.FieldNo("No. Series"));
                if ConfigConfigTemplateLine.FindFirst() and (ConfigConfigTemplateLine."Default Value" <> '') then
                    NoSeriesManagement.InitSeries(CopyStr(ConfigConfigTemplateLine."Default Value", 1, 20), CopyStr(ConfigConfigTemplateLine."Default Value", 1, 20), 0D, Customer."No.", Customer."No. Series");
                Customer.Insert(true);
                CustomerRecordRef.GetTable(Customer);
                ConfigTemplateManagement.UpdateRecord(ConfigTemplateHeader, CustomerRecordRef);
                DimensionsTemplate.InsertDimensionsFromTemplates(ConfigTemplateHeader, Customer."No.", Database::Customer);
                CustomerRecordRef.SetTable(Customer);

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

                Customer.Modify();

                if ShopifyCustomer.Get(TempShopifyCustomer.Id) then begin
                    ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                    ShopifyCustomer.Modify();
                end else begin
                    ShopifyCustomer.Copy(TempShopifyCustomer);
                    ShopifyCustomer.Insert();
                end;

                ShopifyCompany."Customer SystemId" := Customer.SystemId;
                ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
                ShopifyCompany.Modify();

                CustContUpdate.OnModify(Customer);
            end
        end else begin
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

            Customer.Modify();

            ShopifyCustomer.Copy(TempShopifyCustomer);
            ShopifyCustomer."Customer SystemId" := Customer.SystemId;
            ShopifyCustomer.Insert();

            ShopifyCompany."Customer SystemId" := Customer.SystemId;
            ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
            ShopifyCompany.Modify();

            CustContUpdate.OnModify(Customer);
        end;
#else
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

        Customer.Modify();

        ShopifyCustomer.Copy(TempShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Insert();

        ShopifyCompany."Customer SystemId" := Customer.SystemId;
        ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
        ShopifyCompany.Modify();

        CustContUpdate.OnModify(Customer);
#endif
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