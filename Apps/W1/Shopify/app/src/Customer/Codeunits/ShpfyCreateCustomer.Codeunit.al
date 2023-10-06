namespace Microsoft.Integration.Shopify;

using System.IO;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Dimension;
using Microsoft.CRM.BusinessRelation;
using Microsoft.Foundation.NoSeries;
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
            if CustomerTemplate.Get(SHop.Code, CountryCode) then begin
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