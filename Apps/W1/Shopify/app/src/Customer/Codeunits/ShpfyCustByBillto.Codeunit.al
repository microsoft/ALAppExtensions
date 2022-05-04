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
    internal procedure DoMapping(CustomerId: BigInteger; JCustomerInfo: JsonObject; ShopCode: Code[20]; TemplateCode: Code[10]; AllowCreate: Boolean): Code[20];
    var
        ShopifyCustomer: Record "Shpfy Customer";
        Address: Record "Shpfy Customer Address";
        Address2: Record "Shpfy Customer Address";
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
            ShopifyCustomer.Insert();
            CustomerApi.RetrieveShopifyCustomer(ShopifyCustomer);
        end;
        Address.SetAutoCalcFields("Customer No.");
        Address.SetRange("Customer Id", CustomerId);
        Address.SetFilter("Address 1", FilterMgt.CleanFilterValue(JsonHelper.GetValueAsText(JCustomerInfo, 'Address'), MaxStrLen(Address."Address 1")));
        Address.SetFilter("Address 2", FilterMgt.CleanFilterValue(JsonHelper.GetValueAsText(JCustomerInfo, 'Address2'), MaxStrLen(Address."Address 2")));
        Address.SetRange(Zip, JsonHelper.GetValueAsText(JCustomerInfo, 'PostCode'));
        Address.SetRange(City, JsonHelper.GetValueAsText(JCustomerInfo, 'City'));
        Address.SetRange("Country/Region Code", JsonHelper.GetValueAsText(JCustomerInfo, 'CountryCode'));
        if Address.IsEmpty then
            CustomerApi.RetrieveShopifyCustomer(ShopifyCustomer);
        if Address.FindSet() then
            repeat
                IName := Shop."Name Source";
                Name := IName.GetName(Address."First Name", Address."Last Name", Address.Company);
                IName := Shop."Name 2 Source";
                Name2 := IName.GetName(Address."First Name", Address."Last Name", Address.Company);
                if Name = '' then begin
                    Name := Name2;
                    Name2 := '';
                end;
                if Name = '' then begin
                    IName := Shop."Contact Source";
                    Name := IName.GetName(Address."First Name", Address."Last Name", Address.Company);
                end;
                xName := Format(JsonHelper.GetValueAsText(JCustomerInfo, 'Name'));
                Name := Format(Name);
                xName2 := Format(JsonHelper.GetValueAsText(JCustomerInfo, 'Name2'));
                Name2 := Format(Name2);
                Equal1 := xName.ToUpper() = Name.ToUpper();
                Equal2 := xName2.ToUpper() = Name2.ToUpper();
                if Equal1 and Equal2 then
                    if Address."Customer No." = '' then begin
                        if not FindCustomer(Name, Name2, Address) then begin
                            CreateCustomer.SetShop(ShopCode);
                            CreateCustomer.SetTemplateCode(TemplateCode);
                            CreateCustomer.Run(Address);
                        end;
                        Address2.SetAutoCalcFields("Customer No.");
                        Address2.Get(Address.Id);
                        exit(Address2."Customer No.");
                    end else
                        exit(Address."Customer No.");
            until Address.Next() = 0;

        ShopifyCustomer.CalcFields("Customer No.");
        if (ShopifyCustomer."Customer No." = '') and (Shop."Auto Create Unknown Customers" or AllowCreate) then begin
            Clear(Address);
            Address.SetAutoCalcFields("Customer No.");
            Address.SetRange("Customer Id", CustomerId);
            Address.SetRange(Default, true);
            if Address.FindFirst() then begin
                if Address."Customer No." = '' then begin
                    if not FindCustomer(Name, Name2, Address) then begin
                        CreateCustomer.SetShop(ShopCode);
                        CreateCustomer.SetTemplateCode(TemplateCode);
                        CreateCustomer.Run(Address);
                    end;
                    Address.SetAutoCalcFields("Customer No.");
                    Address.Get(Address.Id);
                    exit(Address."Customer No.");
                end else
                    exit(Address."Customer No.");
            end else begin
                Address.SetRange(Default, false);
                if Address.FindFirst() then
                    if Address."Customer No." = '' then begin
                        if not FindCustomer(Name, Name2, Address) then begin
                            CreateCustomer.SetShop(ShopCode);
                            CreateCustomer.SetTemplateCode(TemplateCode);
                            CreateCustomer.Run(Address);
                        end;
                        Address2.SetAutoCalcFields("Customer No.");
                        Address2.Get(Address.Id);
                        exit(Address2."Customer No.");
                    end else
                        exit(Address."Customer No.");
            end;
        end;
        exit(ShopifyCustomer."Customer No.");
    end;

    local procedure FindCustomer(Name: Text; Name2: Text; var Address: Record "Shpfy Customer Address"): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.SetRange(Name, Name);
        Customer.SetRange("Name 2", Name2);
        Customer.SetRange(Address, Address."Address 1");
        Customer.SetRange("Address 2", CopyStr(Address."Address 2", 1, MaxStrLen(Customer."Address 2")));
        Customer.SetRange("Post Code", Address.Zip);
        Customer.SetRange(City, Address.City);
        Customer.SetRange(County, Address."Province Code");
        Customer.SetRange("Country/Region Code", Address."Country/Region Code");
        if Customer.FindFirst() then begin
            Address.CustomerSystemId := Customer.SystemId;
            Address.Modify();
            Address.CalcFields("Customer No.");
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