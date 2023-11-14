Connect your Shopify store (or stores) with Business Central and maximize your business productivity. Manage and view insights from your business and your Shopify store as one unit.

## Product Help
The functionality in the default version of Business Central is described on the docs.microsoft.com site. The [Shopify](https://learn.microsoft.com/dynamics365/business-central/shopify/get-started) section offers descriptions of processes, such as synchronizing products and orders, and conceptual information about mapping various entities.
You can also explore the [FAQ](https://aka.ms/bcshopifyfaq) and a collection of [walkthroughs](https://learn.microsoft.com/dynamics365/business-central/shopify/walkthrough-setting-up-and-using-shopify) (how-to).

## Extensibility

The Shopify Connector has been non-extensible, but we're changing that by offering a few points of extensibility. We'll keep the number of points to a minimum so that we can follow the rapid development on the Shopify side without introducing breaking changes.

We're opening for extensibility for specific scenarios, based on feedback from our partners and customers. Please share your scenarios as comments to the following product suggestion: [Allow extensibility of the new Shopify Connector Extension](https://experience.dynamics.com/ideas/idea/?ideaid=ea059be1-9912-ed11-b5cf-0003ff45e42e).

Find overview of objects expected to become public in future releases:

## Object reference

The following sections show the codeunits, tables, and enums that are public.

### codeunit 30162 "Shpfy Order Events"

Available in version: 22.0

Exposes the following integration events:

- OnAfterImportShopifyOrderHeader(var ShopifyOrderHeader: Record "Shpfy Order Header"; IsNew: Boolean)
- OnAfterMapCustomer(var ShopifyOrderHeader: Record "Shpfy Order Header")
- OnBeforeMapShipmentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header"; var Handled: Boolean)
- OnAfterMapShipmentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header")
- OnBeforeMapPaymentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header"; var Handled: Boolean)
- OnAfterMapPaymentMethod(var ShopifyOrderHeader: Record "Shpfy Order Header")
- OnAfterCreateItemSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; ShopifyOrderLine: Record "Shpfy Order Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
- OnAfterCreateSalesHeader(ShopifyHeader: Record "Shpfy Order Header"; var SalesHeader: Record "Sales Header")
- OnAfterCreateShippingCostSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; ShopifyShippingCost: Record "Shpfy Order Shipping Charges"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
- OnBeforeProcessSalesDocument(var ShopifyOrderHeader: Record "Shpfy Order Header")
- OnBeforeCreateSalesHeader(ShopifyOrderHeader: Record "Shpfy Order Header"; var SalesHeader: Record "Sales Header"; var Handled: Boolean)
- OnBeforeCreateShippingCostSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; ShopifyShippingCost: Record "Shpfy Order Shipping Charges"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
- OnAfterProcessSalesDocument(var SalesHeader: Record "Sales Header"; ShopifyHeader: Record "Shpfy Order Header")
- OnBeforeCreateItemSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; ShopifyOrderLine: Record "Shpfy Order Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)

To explore examples of how to extend this codeunit, go to [Order processing](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-extending-shopify#order-processing).

### codeunit 30177 "Shpfy Product Events"

Available in version: 22.0

Exposes the following integration events:

- OnAfterCreateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item);
- OnAfterCreateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant");
- OnAfterCreateProductBodyHtml(ItemNo: Code[20]; ShopifyShop: Record "Shpfy Shop"; var ProductBodyHtml: Text)
- OnAfterFindItemTemplate(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var TemplateCode: Code[10]);
- OnAfterGetCommaSeparatedTags(ShopifyProduct: Record "Shpfy Product"; var Tags: Text)
- OnAfterGetBarcode(ItemNo: Code[20]; VariantCode: Code[10]; UoM: Code[10]; var Barcode: Text)
- OnBeforeCreateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; var Handled: Boolean);
- OnBeforeCreateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant"; var Handled: Boolean);
- OnBeforeCreateItemVariantCode(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariantCode: Code[10]; var Handled: Boolean);
- OnBeforeCreateProductBodyHtml(ItemNo: Code[20]; ShopifyShop: Record "Shpfy Shop"; var ProductBodyHtml: Text; var Handled: Boolean)
- OnBeforeFindItemTemplate(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var TemplateCode: Code[10]; var Handled: Boolean);
- OnBeforGetBarcode(ItemNo: Code[20]; VariantCode: Code[10]; UoM: Code[10]; var Barcode: Text; var Handled: Boolean)
- OnBeforSetProductTitle(Item: Record Item; LanguageCode: Code[10]; var Title: Text; var Handled: Boolean)
- OnBeforeFindMapping(Direction: enum "Shpfy Mapping Direction"; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; ItemVariant: Record "Item Variant"; var Handled: Boolean);
- OnAfterCalculateUnitPrice(Item: Record Item; VariantCode: Code[20]; UnitOfMeasure: Code[20]; ShopifyShop: Record "Shpfy Shop"; var UnitCost: Decimal; var Price: Decimal; var ComparePrice: Decimal)
- OnBeforeCalculateUnitPrice(Item: Record Item; VariantCode: Code[20]; UnitOfMeasure: Code[20]; ShopifyShop: Record "Shpfy Shop"; var UnitCost: Decimal; var Price: Decimal; var ComparePrice: Decimal; var Handled: Boolean)
- OnAfterUpdateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item);
- OnAfterUpdateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant");
- OnBeforeUpdateItem(Shop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; var Handled: Boolean);
- OnBeforeUpdateItemVariant(Shop: Record "Shpfy Shop"; ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; Item: Record Item; var ItemVariant: Record "Item Variant"; var Handled: Boolean);
- OnBeforeSendCreateShopifyProduct(ShopifyShop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var ShpfyTag: Record "Shpfy Tag")
- OnBeforeSendUpdateShopifyProduct(ShopifyShop: Record "Shpfy Shop"; var ShopifyProduct: Record "Shpfy Product"; xShopifyProduct: Record "Shpfy Product")
- OnBeforeSendAddShopifyProductVariant(ShopifyShop: Record "Shpfy Shop"; var ShopifyVariant: Record "Shpfy Variant")
- OnBeforeSendUpdateShopifyProductVariant(ShopifyShop: Record "Shpfy Shop"; var ShopifyVariant: Record "Shpfy Variant"; xShopifyVariant: Record "Shpfy Variant")
- OnAfterCreateTempShopifyProduct(Item: Record Item; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var ShopifyTag: Record "Shpfy Tag")

To explore examples of how to extend this codeunit, go to [Price management](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-extending-shopify#price-management) and [Product properties](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-extending-shopify#product-properties).

### codeunit 30115 "Shpfy Customer Events"

Available in version: 22.0

Exposes the following integration events:

- OnAfterCreateCustomer(Shop: Record "Shpfy Shop"; var ShopifyCustomerAddress: Record "Shpfy Customer Address"; var Customer: Record Customer);
- OnBeforeCreateCustomer(Shop: Record "Shpfy Shop"; var ShopifyCustomerAddress: Record "Shpfy Customer Address"; var Customer: Record Customer; var Handled: Boolean);
- OnBeforeSendCreateShopifyCustomer(ShopifyShop: Record "Shpfy Shop"; var ShopifyCustomer: Record "Shpfy Customer"; var ShopifyCustomerAddress: Record "Shpfy Customer Address")
- OnBeforeSendUpdateShopifyCustomer(ShopifyShop: Record "Shpfy Shop"; var ShopifyCustomer: Record "Shpfy Customer"; var ShopifyCustomerAddress: Record "Shpfy Customer Address"; xShopifyCustomer: Record "Shpfy Customer"; xShopifyCustomerAddress: Record "Shpfy Customer Address")
- OnBeforeFindMapping(Direction: enum "Shpfy Mapping Direction"; var ShopifyCustomer: Record "Shpfy Customer"; var Customer: Record Customer; var Handled: Boolean);
- OnAfterUpdateCustomer(Shop: Record "Shpfy Shop"; var ShopifyCustomer: Record "Shpfy Customer"; var Customer: Record Customer);
- OnBeforeUpdateCustomer(Shop: Record "Shpfy Shop"; var ShopifyCustomer: Record "Shpfy Customer"; var Customer: Record Customer; var Handled: Boolean);

### codeunit 30196 "Shpfy Inventory Events"

Available in version: 22.0

Exposes the following integration events:

- OnAfterCalculationStock(Item: Record Item; ShopifyShop: Record "Shpfy Shop"; LocationFilter: Text; var StockResult: Decimal)

### Tables and enums

The following table lists the table and enum objects that we've made public, and in which version they became available.

|Object  |Availabile in Version  | Comments |
|---------|---------|---------|
|table 30118 "Shpfy Order Header"     | 22.0        |         |
|table 30119 "Shpfy Order Line"     | 22.0         |         |
|table 30130 "Shpfy Order Shipping Charges"     | 22.0         |         |
|table 30116 "Shpfy Order Attribute"     | 22.0        |         |
|table 30127 "Shpfy Product"     | 22.0        |         |
|table 30129 "Shpfy Variant"     | 22.0        |         |
|table 30105 "Shpfy Customer"     | 22.0         |         |
|table 30106 "Shpfy Customer Address"     | 22.0        |         |
|table 30102 "Shpfy Shop"     | 22.0        |         |
|table 30104 "Shpfy Tag"     | 22.0        |         |
|table 30124 "Shpfy Payment Transaction"     | 22.4        |         |
|table 30125 "Shpfy Payout"     | 22.4        |         |
|table 30133 "Shpfy Order Transaction"     | 23.0        |         |
|Enum "Shpfy Mapping Direction"     | 22.0        | Extensible = false;   |
|Enum "Shpfy Inventory Policy"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Product Status"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Risk Level"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Processing Method"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Financial Status"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Order Fulfill. Status"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Cancel Reason"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Customer State"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Customer Import Range"     | 22.0        | Extensible = false;        | 
|Enum "Shpfy Name Source"     | 22.0        | Extensible = false;        |
|Enum "Shpfy County Source"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Customer Mapping"     | 22.0        | Extensible = True;        |
|Enum "Shpfy Cr. Prod. Status Value"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Remove Product Action"     | 22.0        | Extensible = false;        |
|Enum "Shpfy SKU Mapping"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Tax By"     | 22.0        | Extensible = false;        |
|Enum "Shpfy Stock Calculation"     | 21.3        | Extensible = true; <br><br>[Example](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-extending-shopify#stock-calculation)|