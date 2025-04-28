namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

reportextension 8007 "Contract Stand. Sales Cr. Memo" extends "Standard Sales - Credit Memo"
{
    dataset
    {
        add(Header)
        {
            column(RecurringBilling; "Recurring Billing")
            {
            }
        }
        add(Line)
        {
            column(ContractLineNo; "Subscription Contract Line No.")
            {
            }
            column(ContractNo; "Subscription Contract No.")
            {
            }
            column(RecurringBillingfrom; "Recurring Billing from")
            {
            }
            column(RecurringBillingto; "Recurring Billing to")
            {
            }
        }
    }
}
