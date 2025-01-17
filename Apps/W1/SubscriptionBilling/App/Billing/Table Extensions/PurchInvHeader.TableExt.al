namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.History;

tableextension 8062 "Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(8051; "Recurring Billing"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Recurring Billing';
        }
    }
}
