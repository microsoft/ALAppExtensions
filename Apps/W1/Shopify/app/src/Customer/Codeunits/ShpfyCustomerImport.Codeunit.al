/// <summary>
/// Codeunit Shpfy Customer Import (ID 30117).
/// </summary>
codeunit 30117 "Shpfy Customer Import"
{
    Access = Internal;

    trigger OnRun()
    var
        Address: Record "Shpfy Customer Address";
        CreateCustomer: Codeunit "Shpfy Create Customer";
        Mapping: Codeunit "Shpfy Customer Mapping";
        UpdateCustomer: Codeunit "Shpfy Update Customer";
    begin
        if ShopifyCustomer.Id = 0 then
            exit;
        CustomerApi.RetrieveShopifyCustomer(ShopifyCustomer);
        ClearLastError();
        Commit();
        if Mapping.FindMapping(ShopifyCustomer) and Shop."Shopify Can Update Customer" then begin
            UpdateCustomer.SetShop(Shop);
            UpdateCustomer.Run(ShopifyCustomer);
        end else
            if Shop."Auto Create Unknown Customers" or AllowCreate then begin
                CreateCustomer.SetShop(Shop);
                CreateCustomer.SetTemplateCode(TemplateCode);
                Address.SetRange("Customer Id", ShopifyCustomer.Id);
                Address.SetRange(Default, true);
                if Address.FindFirst() then
                    CreateCustomer.Run(Address)
                else begin
                    Address.SetRange(Default);
                    if Address.FindFirst() then
                        CreateCustomer.Run(Address);
                end;
            end;
    end;

    var
        ShopifyCustomer: Record "Shpfy Customer";
        Shop: Record "Shpfy Shop";
        CustomerApi: Codeunit "Shpfy Customer API";
        AllowCreate: Boolean;
        TemplateCode: Code[10];

    /// <summary> 
    /// Get Customer.
    /// </summary>
    /// <param name="ShopifyCustomerResult">Parameter of type Record "Shopify Customer".</param>
    internal procedure GetCustomer(var ShopifyCustomerResult: Record "Shpfy Customer")
    begin
        ShopifyCustomerResult := ShopifyCustomer;
    end;

    internal procedure SetAllowCreate(Value: Boolean)
    begin
        AllowCreate := Value;
    end;

    /// <summary> 
    /// Set Customer.
    /// </summary>
    /// <param name="Id">Parameter of type BigInteger.</param>
    internal procedure SetCustomer(Id: BigInteger)
    begin
        if Id <> 0 then begin
            Clear(ShopifyCustomer);
            ShopifyCustomer.SetRange(Id, Id);
            if not ShopifyCustomer.FindFirst() then begin
                ShopifyCustomer.Id := Id;
                ShopifyCustomer.Insert(false);
                if not CustomerApi.RetrieveShopifyCustomer(ShopifyCustomer) then
                    ShopifyCustomer.Delete();
            end;
        end;
    end;

    /// <summary> 
    /// Set Customer.
    /// </summary>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    internal procedure SetCustomer(ShopifyCustomer: Record "Shpfy Customer")
    begin
        SetCustomer(ShopifyCustomer.Id);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        CustomerApi.SetShop(Shop);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CustomerApi.SetShop(Shop);
    end;

    /// <summary> 
    /// Set Template Code.
    /// </summary>
    /// <param name="Code">Parameter of type Code[10].</param>
    internal procedure SetTemplateCode(Code: Code[10])
    begin
        TemplateCode := Code;
    end;

}