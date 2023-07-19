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
    value(9; GetNextOrderFulfillmentLines)
    {
        Caption = 'Get Next Order Fulfillment Lines';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextFulfillmentLines";
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
    value(27; ModifyInventory)
    {
        Caption = 'Modify Inventory';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL Modify Inventory";
    }
    value(28; GetLocations)
    {
        Caption = 'Get Locations';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL Locations";
    }
    value(29; GetNextLocations)
    {
        Caption = 'Get Next Locations';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL Next Locations";
    }
    value(30; GetOpenOrdersToImport)
    {
        Caption = 'Get Open Orders to Import';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL OpenOrdersToImport";
    }
    value(31; "GetNextOpenOrdersToImport")
    {
        Caption = 'Get Next Open Orders to Import';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextOpenOrdToImport";
    }
    value(32; GetOrderHeader)
    {
        Caption = 'Get Order Header';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL OrderHeader";
    }
    value(33; GetOrderLines)
    {
        Caption = 'Get Order Lines';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL OrderLines";
    }
    value(34; GetNextOrderLines)
    {
        Caption = 'Get Next Order Lines';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextOrderLines";
    }
    value(35; GetShipmentLines)
    {
        Caption = 'Get Shipment Lines';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL ShipmentLines";
    }
    value(36; GetNextShipmentLines)
    {
        Caption = 'Get Next Order Lines';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextShipmentLines";
    }
    value(37; CloseOrder)
    {
        Caption = 'Close Order';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL CloseOrder";
    }
    value(38; CreateImageUploadUrl)
    {
        Caption = 'Create Image Upload URL';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL CreateImageUploadUrl";
    }
    value(39; AddProductImage)
    {
        Caption = 'Add Product Image';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL AddProductImage";
    }
    value(40; UpdateProductImage)
    {
        Caption = 'Update Product Image';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL UpdateProductImage";
    }
    value(41; CreateFulfillmentService)
    {
        Caption = 'Create Fullfilment Service';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL CreateFulfillmentSvc";
    }
    value(42; GetOpenFulfillmentOrders)
    {
        Caption = 'Get Open Fullfilment Orders';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL OpenFulfillmOrders";
    }
    value(43; GetNextOpenFulfillmentOrders)
    {
        Caption = 'Get Next Open Fullfilment Orders';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextOpenFFOrders";
    }
    value(44; GetOpenFulfillmentOrderLines)
    {
        Caption = 'Get Open Fullfilment Orders Lines';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL OpenFulfillmOrdLines";
    }
    value(45; GetNextOpenFulfillmentOrderLines)
    {
        Caption = 'Get Open Fullfilment Orders Lines';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextOpenFFOrderLines";
    }
    value(46; GetAllCustomerIds)
    {
        Caption = 'Get All Customer Ids';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL AllCustomerIds";
    }
    value(47; GetNextAllCustomerIds)
    {
        Caption = 'Get Next All Customer Ids';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextAllCustomerIds";
    }
    value(48; GetFulfillmentOrdersFromOrder)
    {
        Caption = 'Get Fulfillment Orders From Order';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL FFOrdersFromOrder";
    }
    value(49; GetNextFulfillmentOrdersFromOrder)
    {
        Caption = 'Get Next Fulfillment Orders From Order';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextFFOrdersFromOrd";
    }
    value(50; NextOrderReturns)
    {
        Caption = 'Next Order Returns';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextOrderReturns";
    }
    value(51; GetReturnHeader)
    {
        Caption = 'Get Return Header';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL ReturnHeader";
    }
    value(52; GetReturnLines)
    {
        Caption = 'Get Return Lines';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL ReturnLines";
    }
    value(53; GetNextReturnLines)
    {
        Caption = 'Get Next Return Lines';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextReturnLines";
    }
    value(54; GetRefundHeader)
    {
        Caption = 'Get Refund Header';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL RefundHeader";
    }
    value(55; GetRefundLines)
    {
        Caption = 'Get Refund Lineser';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL RefundLines";
    }
    value(56; GetNextRefundLines)
    {
        Caption = 'Get Next Refund Lineser';
        Implementation = "Shpfy IGraphQL" = "Shpfy GQL NextRefundLines";
    }
}
