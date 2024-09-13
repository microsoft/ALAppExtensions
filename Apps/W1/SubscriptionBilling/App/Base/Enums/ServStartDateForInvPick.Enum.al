namespace Microsoft.SubscriptionBilling;

enum 8000 "Serv. Start Date For Inv. Pick"
{
    Extensible = false;

    value(0; "Shipment Date")
    {
        Caption = 'Shipment Date';
    }
    value(1; "Posting Date")
    {
        Caption = 'Posting Date';
    }
}