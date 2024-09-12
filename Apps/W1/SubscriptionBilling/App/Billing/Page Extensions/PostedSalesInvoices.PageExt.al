namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

pageextension 8060 "Posted Sales Invoices" extends "Posted Sales Invoices"
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