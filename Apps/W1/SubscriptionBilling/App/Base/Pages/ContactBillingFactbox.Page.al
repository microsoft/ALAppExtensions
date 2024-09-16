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
                field("Customer Contracts"; Rec."Customer Contracts")
                {
                    Caption = 'Customer Contracts';
                    DrillDownPageId = "Customer Contracts";
                    ToolTip = 'Specifies the number of customer contracts that have been registered for the customer.';
                }
                field("Service Objects"; Rec."Service Objects")
                {
                    Caption = 'Service Objects';
                    DrillDownPageId = "Service Objects";
                    ToolTip = 'Specifies the number of service objects that have been registered for the customer.';
                }
            }
        }
    }
}