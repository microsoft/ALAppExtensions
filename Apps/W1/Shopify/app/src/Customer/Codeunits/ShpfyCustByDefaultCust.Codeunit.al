/// <summary>
/// Codeunit Shpfy Cust. By Default Cust. (ID 30112) implements Interface Shpfy ICustomer Mapping.
/// </summary>
codeunit 30112 "Shpfy Cust. By Default Cust." implements "Shpfy ICustomer Mapping"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";
        CustomerApi: Codeunit "Shpfy Customer API";

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
    begin
        SetShop(ShopCode);
        exit(Shop."Default Customer No.");
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