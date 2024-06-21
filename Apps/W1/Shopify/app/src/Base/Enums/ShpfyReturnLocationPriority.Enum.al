namespace Microsoft.Integration.Shopify;

enum 30156 "Shpfy Return Location Priority"
{
    Extensible = true;

    value(0; "Default Return Location")
    {
        Caption = 'Default Return Location';
    }
    value(1; "Original -> Default Location")
    {
        Caption = 'Original -> Default Location';
    }
}