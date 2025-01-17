namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8058 "Sales Invoice List" extends "Sales Invoice List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }

    views
    {
        addfirst
        {
            view(RecurringBillingView)
            {
                Caption = 'Recurring Billing';
                Filters = where("Recurring Billing" = const(true));
            }
        }
    }
}