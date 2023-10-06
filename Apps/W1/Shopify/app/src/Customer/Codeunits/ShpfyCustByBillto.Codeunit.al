namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy Cust. By Bill-to (ID 30111) implements Interface Shpfy ICustomer Mapping.
/// </summary>
codeunit 30111 "Shpfy Cust. By Bill-to" implements "Shpfy ICustomer Mapping"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";
        CustomerApi: Codeunit "Shpfy Customer API";
        FilterMgt: Codeunit "Shpfy Filter Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

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
        CustomerAddress2: Record "Shpfy Customer Address";
        CreateCustomer: Codeunit "Shpfy Create Customer";
        Equal1: Boolean;
        Equal2: Boolean;
        IName: Interface "Shpfy ICustomer Name";
        Name: Text;
        Name2: Text;
        xName: Text;
        xName2: Text;
    begin
        SetShop(ShopCode);
        ShopifyCustomer.SetAutoCalcFields("Customer No.");
        if not ShopifyCustomer.Get(CustomerId) then begin
            Clear(ShopifyCustomer);
            ShopifyCustomer.Id := CustomerId;
            ShopifyCustomer."Shop Id" := Shop."Shop Id";
            ShopifyCustomer.Insert();
            CustomerApi.RetrieveShopifyCustomer(ShopifyCustomer);
        end;
        CustomerAddress.SetAutoCalcFields("Customer No.");
        CustomerAddress.SetRange("Customer Id", CustomerId);
        CustomerAddress.SetFilter("Address 1", FilterMgt.CleanFilterValue(JsonHelper.GetValueAsText(JCustomerInfo, 'Address'), MaxStrLen(CustomerAddress."Address 1")));
        CustomerAddress.SetFilter("Address 2", FilterMgt.CleanFilterValue(JsonHelper.GetValueAsText(JCustomerInfo, 'Address2'), MaxStrLen(CustomerAddress."Address 2")));
        CustomerAddress.SetRange(Zip, JsonHelper.GetValueAsText(JCustomerInfo, 'PostCode'));
        CustomerAddress.SetRange(City, JsonHelper.GetValueAsText(JCustomerInfo, 'City'));
        CustomerAddress.SetRange("Country/Region Code", JsonHelper.GetValueAsText(JCustomerInfo, 'CountryCode'));
        if CustomerAddress.IsEmpty then
            CustomerApi.RetrieveShopifyCustomer(ShopifyCustomer);
        if CustomerAddress.FindSet() then
            repeat
                IName := Shop."Name Source";
                Name := IName.GetName(CustomerAddress."First Name", CustomerAddress."Last Name", CustomerAddress.Company);
                IName := Shop."Name 2 Source";
                Name2 := IName.GetName(CustomerAddress."First Name", CustomerAddress."Last Name", CustomerAddress.Company);
                if Name = '' then begin
                    Name := Name2;
                    Name2 := '';
                end;
                if Name = '' then begin
                    IName := Shop."Contact Source";
                    Name := IName.GetName(CustomerAddress."First Name", CustomerAddress."Last Name", CustomerAddress.Company);
                end;
                xName := Format(JsonHelper.GetValueAsText(JCustomerInfo, 'Name'));
                Name := Format(Name);
                xName2 := Format(JsonHelper.GetValueAsText(JCustomerInfo, 'Name2'));
                Name2 := Format(Name2);
                Equal1 := xName.ToUpper() = Name.ToUpper();
                Equal2 := xName2.ToUpper() = Name2.ToUpper();
                if Equal1 and Equal2 then
                    if CustomerAddress."Customer No." = '' then begin
                        if not FindCustomer(Name, Name2, CustomerAddress) then begin
                            CreateCustomer.SetShop(ShopCode);
                            CreateCustomer.SetTemplateCode(TemplateCode);
                            CreateCustomer.Run(CustomerAddress);
                        end;
                        CustomerAddress2.SetAutoCalcFields("Customer No.");
                        CustomerAddress2.Get(CustomerAddress.Id);
                        exit(CustomerAddress2."Customer No.");
                    end else
                        exit(CustomerAddress."Customer No.");
            until CustomerAddress.Next() = 0;

        ShopifyCustomer.CalcFields("Customer No.");
        if (ShopifyCustomer."Customer No." = '') and (Shop."Auto Create Unknown Customers" or AllowCreate) then begin
            Clear(CustomerAddress);
            CustomerAddress.SetAutoCalcFields("Customer No.");
            CustomerAddress.SetRange("Customer Id", CustomerId);
            CustomerAddress.SetRange(Default, true);
            if CustomerAddress.FindFirst() then begin
                if CustomerAddress."Customer No." = '' then begin
                    if not FindCustomer(Name, Name2, CustomerAddress) then begin
                        CreateCustomer.SetShop(ShopCode);
                        CreateCustomer.SetTemplateCode(TemplateCode);
                        CreateCustomer.Run(CustomerAddress);
                    end;
                    CustomerAddress.SetAutoCalcFields("Customer No.");
                    CustomerAddress.Get(CustomerAddress.Id);
                    exit(CustomerAddress."Customer No.");
                end else
                    exit(CustomerAddress."Customer No.");
            end else begin
                CustomerAddress.SetRange(Default, false);
                if CustomerAddress.FindFirst() then
                    if CustomerAddress."Customer No." = '' then begin
                        if not FindCustomer(Name, Name2, CustomerAddress) then begin
                            CreateCustomer.SetShop(ShopCode);
                            CreateCustomer.SetTemplateCode(TemplateCode);
                            CreateCustomer.Run(CustomerAddress);
                        end;
                        CustomerAddress2.SetAutoCalcFields("Customer No.");
                        CustomerAddress2.Get(CustomerAddress.Id);
                        exit(CustomerAddress2."Customer No.");
                    end else
                        exit(CustomerAddress."Customer No.");
            end;
        end;
        exit(ShopifyCustomer."Customer No.");
    end;

    local procedure FindCustomer(Name: Text; Name2: Text; var CustomerAddress: Record "Shpfy Customer Address"): Boolean
    var
        Customer: Record Customer;
        ICounty: Interface "Shpfy ICounty";
    begin
        Customer.SetRange(Name, Name);
        Customer.SetRange("Name 2", Name2);
        Customer.SetRange(Address, CustomerAddress."Address 1");
        Customer.SetRange("Address 2", CopyStr(CustomerAddress."Address 2", 1, MaxStrLen(Customer."Address 2")));
        Customer.SetRange("Post Code", CustomerAddress.Zip);
        Customer.SetRange(City, CustomerAddress.City);
        ICounty := Shop."County Source";
        Customer.SetRange(County, ICounty.County(CustomerAddress));
        Customer.SetRange("Country/Region Code", CustomerAddress."Country/Region Code");
        if Customer.FindFirst() then begin
            CustomerAddress.CustomerSystemId := Customer.SystemId;
            CustomerAddress.Modify();
            CustomerAddress.CalcFields("Customer No.");
            exit(true);
        end;
    end;


    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    local procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        SetShop(Shop);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    local procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CustomerApi.SetShop(Shop);
    end;
}