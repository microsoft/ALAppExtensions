/// <summary>
/// Enum Shpfy GraphQL Type (ID 70007617).
/// </summary>
enum 30111 "Shpfy GraphQL Type" implements "Shpfy IGraphQL"
{
    Access = Internal;
    Caption = 'Shopify GraphQL Type';
    Extensible = true;

    value(0; GetApiKey)
    {
        Caption = 'Get API Key';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL ApiKey";
    }
    value(1; GetCustomerIds)
    {
        Caption = 'Get Customer Ids';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL CustomerIds";
    }
    value(2; GetNextCustomerIds)
    {
        Caption = 'Get Next Customer Ids';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextCustomerIds";
    }
    value(3; GetCustomer)
    {
        Caption = 'Get Customer';

        Implementation = "Shpfy IGraphQL" = "Shpfy GQL Customer";

    }
    value(4; GetOrdersToImport)
    {
        Caption = 'Get Orders to Import';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL OrdersToImport";
    }
    value(5; "GetNextOrdersToImport")
    {
        Caption = 'Get Next Orders to Import';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextOrdersToImport";
    }
    value(6; OrderRisks)
    {
        Caption = 'Order Risks';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL OrderRisks";
    }
    value(7; UpdateOrderAttributes)
    {
        Caption = 'Update Order Attributes';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL UpdateOrderAttr";
    }
    value(8; GetOrderFulfillment)
    {
        Caption = 'Get Order Fulfillment';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL OrderFulfillment";
    }
    value(9; GetNextOrderFulfillment)
    {
        Caption = 'Get Next Order Fulfillment';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextOrderFulfillment";
    }
    value(10; GetProductImages)
    {
        Caption = 'Get Product Images';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL ProductImages";
    }
    value(11; GetNextProductImages)
    {
        Caption = 'Get Product Images';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextProductImages";
    }
    value(12; GetProductVariantImages)
    {
        Caption = 'Get Next Product Variant Images';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL VariantImages";
    }
    value(13; GetNextProductVariantImages)
    {
        Caption = 'Get Next Product Variant Images';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextVariantImages";
    }
    value(14; FindCustomerIdByEMail)
    {
        Caption = 'Find Customer Id By E-Mail';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL FindCustByEMail";
    }
    value(15; FindCustomerIdByPhone)
    {
        Caption = 'Find Customer Id By Phone';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL FindCustByPhone";
    }
    value(16; GetInventoryEntries)
    {
        Caption = 'Get Inventory Entries';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL InventoryEntries";
    }
    value(17; GetNextInventoryEntries)
    {
        Caption = 'Get Next Inventory Entries';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextInvEntries";
    }
    value(18; GetProductById)
    {
        Caption = 'Get Product By Id';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL ProductById";
    }
    value(19; GetProductIds)
    {
        Caption = 'Get Product Ids';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL ProductIds";
    }
    value(20; GetNextProductIds)
    {
        Caption = 'Get Next Product Ids';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextProductIds";
    }
    value(21; FindVariantByBarcode)
    {
        Caption = 'Find Variant by Barcode';

        Implementation = "Shpfy IGraphQL" = "Shpfy GQL FindVariantByBarcode";
    }
    value(22; FindVariantBySKU)
    {
        Caption = 'Find Variant by SKU';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL FindVariantBySKU";
    }
    value(23; GetProductVariantIds)
    {
        Caption = 'Get Product Variant Ids';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL VariantIds";
    }
    value(24; GetNextProductVariantIds)
    {
        Caption = 'Get Next Product Variant Ids';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextVariantIds";
    }
    value(25; GetVariantById)
    {
        Caption = 'Get Variant by Id';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL VariantById";
    }
    value(26; GetLocationOfOrderLines)
    {
        Caption = 'Get Location of the Order Lines';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL LocationOrderLines";
    }

}
