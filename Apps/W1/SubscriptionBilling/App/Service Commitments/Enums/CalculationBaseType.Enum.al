namespace Microsoft.SubscriptionBilling;

enum 8052 "Calculation Base Type"
{
    Extensible = false;

    value(0; "Item Price")
    {
        Caption = 'Item Price';
    }
    value(1; "Document Price")
    {
        Caption = 'Document Price';
    }
    value(2; "Document Price And Discount")
    {
        Caption = 'Document Price And Discount';
    }
}
