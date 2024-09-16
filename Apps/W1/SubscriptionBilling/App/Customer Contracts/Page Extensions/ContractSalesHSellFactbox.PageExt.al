namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8000 "Contract Sales H. Sell Factbox" extends "Sales Hist. Sell-to FactBox"
{
    layout
    {
        addlast(Control2)
        {
            field("Customer Contracts"; Rec."Customer Contracts")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer Contracts';
                DrillDownPageId = "Customer Contracts";
                ToolTip = 'Specifies the number of customer contracts that have been registered for the customer.';
            }
            field("Service Objects"; Rec."Service Objects")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Service Objects';
                DrillDownPageId = "Service Objects";
                ToolTip = 'Specifies the number of service objects that have been registered for the customer.';
            }
        }
    }
}