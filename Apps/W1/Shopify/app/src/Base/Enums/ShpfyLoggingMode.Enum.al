namespace Microsoft.Integration.Shopify;

enum 30141 "Shpfy Logging Mode"
{
    Access = Internal;
    Extensible = false;

    value(0; "Error Only")
    {
        Caption = 'Error Only';
    }
    value(1; All)
    {
        Caption = 'All';
    }
    value(2; Disabled)
    {
        Caption = 'Disabled';
    }
}