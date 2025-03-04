namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;

pageextension 8052 "Customer List" extends "Customer List"
{
    actions
    {
        addlast(creation)
        {
            action(NewContract)
            {
                AccessByPermission = tabledata "Customer Subscription Contract" = RIM;
                ApplicationArea = Basic, Suite;
                Caption = 'Subscription Contract';
                Image = FileContract;
                RunObject = page "Customer Contract";
                RunPageLink = "Sell-to Customer No." = field("No.");
                RunPageMode = Create;
                ToolTip = 'Create a Subscription Contract for the customer.';
            }
        }
        addlast(Category_Category5)
        {
            actionref(NewContract_Promoted; NewContract)
            {
            }
        }
        addlast("&Customer")
        {
            action(Contracts)
            {
                AccessByPermission = tabledata "Customer Subscription Contract" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Subscription Contracts';
                Image = FileContract;
                RunObject = page "Customer Contracts";
                RunPageLink = "Sell-to Customer No." = field("No.");
                ToolTip = 'View a list of ongoing Customer Subscription Contracts.';
            }
            action(ServiceObjects)
            {
                AccessByPermission = tabledata "Subscription Header" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Subscriptions';
                Image = ServiceItem;
                RunObject = page "Service Object";
                RunPageLink = "End-User Customer No." = field("No.");
                ToolTip = 'View a list of Subscriptions for the customer.';
            }
        }
        addlast(Category_Category7)
        {
            actionref(Contracts_Promoted; Contracts)
            {
            }
            actionref(ServiceObjects_Promoted; ServiceObjects)
            {
            }
        }
        addlast(reporting)
        {
            action(OverviewOfContractComponents)
            {
                Caption = 'Overview of Subscription Contract components';
                ToolTip = 'View a detailed list of Subscription Line for the selected customer(s).';
                Image = QualificationOverview;
                ApplicationArea = All;
                RunObject = Report "Overview Of Contract Comp";
            }
        }
    }
}