namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.History;

tableextension 8063 "Purch. Cr. Memo Hdr." extends "Purch. Cr. Memo Hdr."
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
