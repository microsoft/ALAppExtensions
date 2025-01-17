namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Receivables;

tableextension 8003 "Cust. Ledger Entry" extends "Cust. Ledger Entry"
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
