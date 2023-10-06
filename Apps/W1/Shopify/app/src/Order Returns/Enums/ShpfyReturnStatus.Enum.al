namespace Microsoft.Integration.Shopify;

enum 30136 "Shpfy Return Status"
{
    value(0; Canceled)
    {
        Caption = 'Canceled';
    }
    value(1; Closed)
    {
        Caption = 'Closed';
    }
    value(2; Declined)
    {
        Caption = 'Declined';
    }
    value(3; Open)
    {
        Caption = 'Open';
    }
    value(4; Requested)
    {
        Caption = 'Requested';
    }
}