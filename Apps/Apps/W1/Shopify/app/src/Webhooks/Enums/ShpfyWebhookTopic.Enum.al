namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Webhook Topic (ID 30167).
/// </summary>
enum 30167 "Shpfy Webhook Topic"
{
    Caption = 'Shopify Webhook Topic';
    Extensible = false;

    value(1; "BULK_OPERATIONS_FINISH")
    {
        Caption = 'bulk_operations/finish', Locked = true;
    }
    value(2; "ORDERS_CREATE")
    {
        Caption = 'orders/create', Locked = true;
    }
}
