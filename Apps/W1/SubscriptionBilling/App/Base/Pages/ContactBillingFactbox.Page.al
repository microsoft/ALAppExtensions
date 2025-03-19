namespace Microsoft.SubscriptionBilling;

using Microsoft.CRM.Contact;

page 8000 "Contact Billing Factbox"
{
    Caption = 'Recurring Billing';
    PageType = CardPart;
    SourceTable = Contact;
    RefreshOnActivate = true;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(Content)
        {
            cuegroup(CueGroupControl)
            {
                ShowCaption = false;
                field("Customer Contracts"; Rec."Cust. Subscription Contracts")
                {
                    DrillDownPageId = "Customer Contracts";
                    ToolTip = 'Specifies the number of Customer Subscription Contracts that have been registered for the customer.';
                }
                field("Service Objects"; Rec."Subscription Headers")
                {
                    DrillDownPageId = "Service Objects";
                    ToolTip = 'Specifies the number of Subscriptions that have been registered for the customer.';
                }
            }
        }
    }
}