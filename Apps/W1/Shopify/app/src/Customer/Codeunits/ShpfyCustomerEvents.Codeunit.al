/// <summary>
/// Codeunit Shpfy Customer Events (ID 30115).
/// </summary>
codeunit 30115 "Shpfy Customer Events"
{
    Access = Internal;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Create Customer.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyCustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    internal procedure OnAfterCreateCustomer(Shop: Record "Shpfy Shop"; var ShopifyCustomerAddress: Record "Shpfy Customer Address"; var Customer: Record Customer);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Find Customer Template.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="CountryCode">Parameter of type code[20].</param>
    /// <param name="TemplateCode">Parameter of type Code[20].</param>
    internal procedure OnAfterFindCustomerTemplate(Shop: Record "Shpfy Shop"; CountryCode: code[20]; var TemplateCode: Code[10]);
    begin
    end;


    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Create Customer.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyCustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeCreateCustomer(Shop: Record "Shpfy Shop"; var ShopifyCustomerAddress: Record "Shpfy Customer Address"; var Customer: Record Customer; var Handled: Boolean);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Send Create Shopify Customer.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="ShopifyCustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    internal procedure OnBeforeSendCreateShopifyCustomer(ShopifyShop: Record "Shpfy Shop"; var ShopifyCustomer: Record "Shpfy Customer"; var ShopifyCustomerAddress: Record "Shpfy Customer Address")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Send Update Shopify Customer.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="ShopifyCustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <param name="xShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="xShopifyCustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    internal procedure OnBeforeSendUpdateShopifyCustomer(ShopifyShop: Record "Shpfy Shop"; var ShopifyCustomer: Record "Shpfy Customer"; var ShopifyCustomerAddress: Record "Shpfy Customer Address"; xShopifyCustomer: Record "Shpfy Customer"; xShopifyCustomerAddress: Record "Shpfy Customer Address")
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Find Customer Template.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="CountryCode">Parameter of type code[20].</param>
    /// <param name="TemplateCode">Parameter of type Code[20].</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeFindCustomerTemplate(Shop: Record "Shpfy Shop"; CountryCode: code[20]; var TemplateCode: Code[10]; var Handled: Boolean);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Find Mapping.
    /// </summary>
    /// <param name="Direction">Parameter of type enum "Shopify Mapping Direction".</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    internal procedure OnAfterFindMapping(Direction: enum "Shpfy Mapping Direction"; var ShopifyCustomer: Record "Shpfy Customer"; var Customer: Record Customer);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Find Mapping.
    /// </summary>
    /// <param name="Direction">Parameter of type enum "Shopify Mapping Direction".</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeFindMapping(Direction: enum "Shpfy Mapping Direction"; var ShopifyCustomer: Record "Shpfy Customer"; var Customer: Record Customer; var Handled: Boolean);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised After Update Customer.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    internal procedure OnAfterUpdateCustomer(Shop: Record "Shpfy Shop"; var ShopifyCustomer: Record "Shpfy Customer"; var Customer: Record Customer);
    begin
    end;

    [InternalEvent(false)]
    /// <summary> 
    /// Raised Before Update Customer.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="Handled">Parameter of type Boolean.</param>
    internal procedure OnBeforeUpdateCustomer(Shop: Record "Shpfy Shop"; var ShopifyCustomer: Record "Shpfy Customer"; var Customer: Record Customer; var Handled: Boolean);
    begin
    end;
}