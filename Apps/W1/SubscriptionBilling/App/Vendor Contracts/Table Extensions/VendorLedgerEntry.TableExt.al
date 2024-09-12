namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Payables;

tableextension 8004 "Vendor Ledger Entry" extends "Vendor Ledger Entry"
{
    fields
    {
        field(8000; "Recurring Billing"; Boolean)
        {
            Caption = 'Recurring Billing';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
