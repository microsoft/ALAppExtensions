enum 30144 "Shpfy Shop Document Type" implements "Shpfy IOpenShopifyDocument"
{
    Extensible = true;
    DefaultImplementation = "Shpfy IOpenShopifyDocument" = "Shpfy OpenDoc NotSupported";

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Shopify Shop Order")
    {
        Caption = 'Shopify Order';
        Implementation = "Shpfy IOpenShopifyDocument" = "Shpfy Open Order";
    }
    value(2; "Shopify Shop Return")
    {
        Caption = 'Shopify Return';
        Implementation = "Shpfy IOpenShopifyDocument" = "Shpfy Open Return";
    }
    value(3; "Shopify Shop Refund")
    {
        Caption = 'Shopify Refund';
        Implementation = "Shpfy IOpenShopifyDocument" = "Shpfy Open Refund";
    }
}