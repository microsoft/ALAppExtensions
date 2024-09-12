namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8059 "Sales Credit Memos" extends "Sales Credit Memos"
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