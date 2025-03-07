namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8000 "Contract Sales H. Sell Factbox" extends "Sales Hist. Sell-to FactBox"
{
    layout
    {
        addlast(Control2)
        {
            field("Customer Contracts"; Rec."Cust. Subscription Contracts")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer Subscription Contracts';
                DrillDownPageId = "Customer Contracts";
                ToolTip = 'Specifies the number of Customer Subscription Contracts that have been registered for the customer.';
            }
            field("Service Objects"; Rec."Subscription Headers")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Subscriptions';
                DrillDownPageId = "Service Objects";
                ToolTip = 'Specifies the number of Subscriptions that have been registered for the customer.';
            }
        }
    }
}