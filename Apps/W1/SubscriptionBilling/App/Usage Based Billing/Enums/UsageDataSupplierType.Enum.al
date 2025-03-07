namespace Microsoft.SubscriptionBilling;

enum 8015 "Usage Data Supplier Type" implements "Usage Data Processing"
{
    Extensible = true;
    DefaultImplementation = "Usage Data Processing" = "Generic Connector Processing";
    value(0; Generic)
    {
        Caption = 'Generic';
        Implementation = "Usage Data Processing" = "Generic Connector Processing";
    }
}
