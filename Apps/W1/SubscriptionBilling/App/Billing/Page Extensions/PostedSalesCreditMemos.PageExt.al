namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

pageextension 8061 "Posted Sales Credit Memos" extends "Posted Sales Credit Memos"
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